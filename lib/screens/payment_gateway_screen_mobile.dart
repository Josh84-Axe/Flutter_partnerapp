import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Screen for handling Paystack inline payment popup (Mobile platforms)
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
  WebViewController? _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeWebView();
      }
    });
  }

  void _initializeWebView() {
    try {
      debugPrint('🚀 [PaymentGateway] Initializing WebView for mobile...');
      
      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              debugPrint('🌐 [PaymentGateway] Page started: $url');
              if (mounted) setState(() => _isLoading = true);
            },
            onPageFinished: (String url) {
              debugPrint('✅ [PaymentGateway] Page finished: $url');
              if (mounted) setState(() => _isLoading = false);
            },
            onWebResourceError: (WebResourceError error) {
              debugPrint('❌ [PaymentGateway] WebView error: ${error.description}');
            },
          ),
        )
        ..addJavaScriptChannel(
          'PaystackFlutter',
          onMessageReceived: (JavaScriptMessage message) {
            debugPrint('💬 [PaymentGateway] Message from JS: ${message.message}');
            _handlePaymentResponse(message.message);
          },
        )
        ..loadHtmlString(_buildPaystackHTML());
      
      if (mounted) {
        setState(() {
          _controller = controller;
        });
      }
      
      debugPrint('✅ [PaymentGateway] WebView initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ [PaymentGateway] Error initializing WebView: $e');
      debugPrint('   Stack trace: $stackTrace');
    }
  }

  String _buildPaystackHTML() {
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
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        .payment-container {
            background: white;
            border-radius: 16px;
            padding: 40px;
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
            font-size: 36px;
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
            transition: all 0.3s ease;
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
    </style>
</head>
<body>
    <div class="payment-container">
        <div class="plan-name">${widget.planName}</div>
        <div class="amount">${widget.currency} ${widget.amount.toInt()}</div>
        <div class="currency">Subscription Plan</div>
        <button class="pay-button" onclick="payWithPaystack()">
            Pay Now
        </button>
        <div class="info">
            Secure payment powered by Paystack
        </div>
    </div>

    <script>
        console.log('🚀 Payment page loaded');
        
        function payWithPaystack() {
            console.log('💳 Initiating payment...');
            
            try {
                var handler = PaystackPop.setup({
                    key: 'pk_live_ba6137ee394e83ff5b0cfec596851545e1dea426',
                    email: '${widget.email}',
                    amount: $amountInKobo,
                    currency: '${widget.currency}',
                    ref: 'PSK_' + Math.floor((Math.random() * 1000000000) + 1),
                    metadata: {
                        plan_id: '${widget.planId}',
                        plan_name: '${widget.planName}',
                    },
                    callback: function(response) {
                        console.log('✅ Payment successful:', response);
                        
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
                        console.log('⚠️ Payment popup closed');
                        
                        // Send cancellation message to Flutter
                        if (window.PaystackFlutter) {
                            window.PaystackFlutter.postMessage(JSON.stringify({
                                success: false,
                                message: 'Payment cancelled'
                            }));
                        }
                    }
                });
                
                console.log('🎯 Opening Paystack iframe...');
                handler.openIframe();
            } catch (error) {
                console.error('❌ Error in payWithPaystack:', error);
                alert('Error: ' + error.message);
            }
        }
        
        // Auto-trigger payment on page load
        window.onload = function() {
            console.log('📄 Window loaded, triggering payment in 1 second...');
            setTimeout(function() {
                payWithPaystack();
            }, 1000);
        };
    </script>
</body>
</html>
    ''';
  }

  void _handlePaymentResponse(String message) {
    try {
      debugPrint('💬 [PaymentGateway] Processing payment response: $message');
      
      if (message.contains('"success":true')) {
        final referenceMatch = RegExp(r'"reference":"([^"]+)"').firstMatch(message);
        final reference = referenceMatch?.group(1);
        
        if (reference != null) {
          debugPrint('✅ [PaymentGateway] Payment successful with reference: $reference');
          Navigator.pop(context, {
            'success': true,
            'reference': reference,
          });
        }
      } else {
        debugPrint('⚠️ [PaymentGateway] Payment cancelled or failed');
        Navigator.pop(context, {
          'success': false,
          'message': 'Payment cancelled',
        });
      }
    } catch (e) {
      debugPrint('❌ [PaymentGateway] Error parsing payment response: $e');
      Navigator.pop(context, {
        'success': false,
        'message': 'Error processing payment',
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('payment'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
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
                      Navigator.pop(context);
                      Navigator.pop(context, {
                        'success': false,
                        'message': 'Payment cancelled by user',
                      });
                    },
                    child: Text('yes'.tr(), style: const TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: _controller == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                WebViewWidget(controller: _controller!),
                
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
