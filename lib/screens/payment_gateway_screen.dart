import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

/// Screen for handling Paystack payment gateway
class PaymentGatewayScreen extends StatefulWidget {
  final String authorizationUrl;
  final String planName;
  final double amount;

  const PaymentGatewayScreen({
    super.key,
    required this.authorizationUrl,
    required this.planName,
    required this.amount,
  });

  @override
  State<PaymentGatewayScreen> createState() => _PaymentGatewayScreenState();
}

class _PaymentGatewayScreenState extends State<PaymentGatewayScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
            _checkPaymentStatus(url);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.authorizationUrl));
  }

  void _checkPaymentStatus(String url) {
    // Paystack redirects to callback URL with reference
    // Format: https://your-callback-url?reference=PAYMENT_REF&trxref=PAYMENT_REF
    
    if (url.contains('reference=') || url.contains('trxref=')) {
      final uri = Uri.parse(url);
      final reference = uri.queryParameters['reference'] ?? 
                       uri.queryParameters['trxref'];
      
      if (reference != null && reference.isNotEmpty) {
        // Payment successful - return reference
        Navigator.pop(context, {
          'success': true,
          'reference': reference,
        });
      }
    }
    
    // Check for cancellation
    if (url.contains('cancelled') || url.contains('cancel')) {
      Navigator.pop(context, {
        'success': false,
        'message': 'Payment cancelled',
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('payment'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            // Confirm cancellation
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('cancel_payment'.tr()),
                content: Text('cancel_payment_confirmation'.tr()),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('no'.tr()),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(context, {
                        'success': false,
                        'message': 'Payment cancelled by user',
                      }); // Close payment screen
                    },
                    child: Text('yes'.tr(), style: const TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: Column(
        children: [
          // Payment info banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: colorScheme.primaryContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.planName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Amount: ${widget.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          
          // Loading indicator
          if (_isLoading)
            const LinearProgressIndicator(),
          
          // WebView
          Expanded(
            child: WebViewWidget(controller: _controller),
          ),
        ],
      ),
    );
  }
}
