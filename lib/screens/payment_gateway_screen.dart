import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

/// Screen for handling Paystack inline payment popup
class PaymentGatewayScreen extends StatefulWidget {
  final String email;
  final double amount;
  final String planId;
  final String planName;
  final String currency;

  const PaymentGatewayScreen({
    super.key,
    required this.email,
    required this.amount,
    required this.planId,
    required this.planName,
    required this.currency,
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
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
          },
        ),
      )
      ..addJavaScriptChannel(
        'PaystackFlutter',
        onMessageReceived: (JavaScriptMessage message) {
          // Handle payment response from Paystack
          _handlePaymentResponse(message.message);
        },
      )
      ..loadHtmlString(_buildPaystackHTML());
  }

  String _buildPaystackHTML() {
    // Convert amount to kobo/pesewas (Paystack expects smallest currency unit)
    final amountInKobo = (widget.amount * 100).toInt();
    
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment</title>
    <script src="https://js.paystack.co/v1/inline.js"></script>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            margin: 0;
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .payment-container {
            background: white;
            border-radius: 16px;
            padding: 32px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            max-width: 400px;
            width: 100%;
            text-align: center;
        }
        .plan-name {
            font-size: 24px;
            font-weight: bold;
            color: #1a202c;
            margin-bottom: 8px;
        }
        .amount {
            font-size: 32px;
            font-weight: bold;
            color: #667eea;
            margin: 16px 0;
        }
        .currency {
            font-size: 14px;
            color: #718096;
            margin-bottom: 24px;
        }
        .pay-button {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            padding: 16px 32px;
            font-size: 16px;
            font-weight: 600;
            border-radius: 8px;
            cursor: pointer;
            width: 100%;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .pay-button:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(102, 126, 234, 0.4);
        }
        .pay-button:active {
            transform: translateY(0);
        }
        .info {
            margin-top: 16px;
            font-size: 12px;
            color: #718096;
        }
        .loading {
            display: none;
            margin-top: 16px;
        }
        .loading.active {
            display: block;
        }
        .spinner {
            border: 3px solid #f3f3f3;
            border-top: 3px solid #667eea;
            border-radius: 50%;
            width: 40px;
            height: 40px;
            animation: spin 1s linear infinite;
            margin: 0 auto;
        }
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
    </style>
</head>
<body>
    <div class="payment-container">
        <div class="plan-name">${widget.planName}</div>
        <div class="amount">${widget.amount.toStringAsFixed(2)}</div>
        <div class="currency">${widget.currency}</div>
        <button class="pay-button" onclick="payWithPaystack()">
            Pay Now
        </button>
        <div class="info">
            Secure payment powered by Paystack
        </div>
        <div class="loading" id="loading">
            <div class="spinner"></div>
        </div>
    </div>

    <script>
        function payWithPaystack() {
            var handler = PaystackPop.setup({
                key: 'pk_live_ba6137ee394e83ff5b0cfec596851545e1dea426',
                email: '${widget.email}',
                amount: $amountInKobo,
                currency: '${widget.currency}',
                ref: 'PSK_' + Math.floor((Math.random() * 1000000000) + 1),
                metadata: {
                    plan_id: '${widget.planId}',
                    plan_name: '${widget.planName}',
                    custom_fields: [
                        {
                            display_name: "Subscription Plan",
                            variable_name: "subscription_plan",
                            value: "${widget.planName}"
                        }
                    ]
                },
                callback: function(response) {
                    // Payment successful
                    document.getElementById('loading').classList.add('active');
                    
                    // Send success message to Flutter
                    if (window.PaystackFlutter) {
                        window.PaystackFlutter.postMessage(JSON.stringify({
                            success: true,
                            reference: response.reference,
                            message: 'Payment successful'
                        }));
                    }
                },
                onClose: function() {
                    // User closed the popup
                    if (window.PaystackFlutter) {
                        window.PaystackFlutter.postMessage(JSON.stringify({
                            success: false,
                            message: 'Payment cancelled'
                        }));
                    }
                }
            });
            handler.openIframe();
        }
        
        // Auto-trigger payment on page load
        window.onload = function() {
            setTimeout(function() {
                payWithPaystack();
            }, 500);
        };
    </script>
</body>
</html>
    ''';
  }

  void _handlePaymentResponse(String message) {
    try {
      // Parse the JSON message from JavaScript
      final response = message;
      debugPrint('Payment response: $response');
      
      // Close the screen and return the result
      if (response.contains('"success":true')) {
        // Extract reference from JSON
        final referenceMatch = RegExp(r'"reference":"([^"]+)"').firstMatch(response);
        final reference = referenceMatch?.group(1);
        
        if (reference != null) {
          Navigator.pop(context, {
            'success': true,
            'reference': reference,
          });
        }
      } else {
        Navigator.pop(context, {
          'success': false,
          'message': 'Payment cancelled',
        });
      }
    } catch (e) {
      debugPrint('Error parsing payment response: $e');
      Navigator.pop(context, {
        'success': false,
        'message': 'Error processing payment',
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
                content: const Text('Are you sure you want to cancel this payment?'),
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
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          
          // Loading indicator
          if (_isLoading)
            Container(
              color: Colors.white,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
