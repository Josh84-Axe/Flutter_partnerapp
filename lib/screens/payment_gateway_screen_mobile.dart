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
  final Map<String, dynamic>? userData;

  const PaymentGatewayScreen({
    super.key,
    required this.email,
    required this.amount,
    required this.planId,
    required this.planName,
    required this.currency,
    this.userData,
  });

  @override
  State<PaymentGatewayScreen> createState() => _PaymentGatewayScreenState();
}

class _PaymentGatewayScreenState extends State<PaymentGatewayScreen> {
  @override
  Widget build(BuildContext context) {
    // Conditional routing based on currency
    if (widget.currency == 'XOF' || widget.currency == 'XAF' || widget.currency == 'CFA') {
       return _PaymentGatewayCinetPayMobile(
          apiKey: '297929662685d35c4021b02.21438964',
          siteId: '105899723',
          transactionId: 'txn_${DateTime.now().millisecondsSinceEpoch}',
          amount: widget.amount,
          currency: widget.currency == 'CFA' ? 'XOF' : widget.currency,
          description: 'Payment for ${widget.planName}',
          email: widget.email,
          userData: widget.userData,
       );
    }
    
    return _PaymentGatewayPaystackMobile(
      email: widget.email,
      amount: widget.amount,
      planId: widget.planId,
      planName: widget.planName,
      currency: widget.currency,
    );
  }
}

// ================== PAYSTACK IMPLEMENTATION ==================

class _PaymentGatewayPaystackMobile extends StatefulWidget {
  final String email;
  final double amount;
  final String planId;
  final String planName;
  final String currency;

  const _PaymentGatewayPaystackMobile({
    required this.email,
    required this.amount,
    required this.planId,
    required this.planName,
    required this.currency,
  });

  @override
  State<_PaymentGatewayPaystackMobile> createState() => _PaymentGatewayPaystackMobileState();
}

class _PaymentGatewayPaystackMobileState extends State<_PaymentGatewayPaystackMobile> {
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
      debugPrint('🚀 [PaystackMobile] Initializing WebView...');
      
      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              if (mounted) setState(() => _isLoading = true);
            },
            onPageFinished: (String url) {
              if (mounted) setState(() => _isLoading = false);
            },
            onWebResourceError: (WebResourceError error) {
              debugPrint('❌ [PaystackMobile] WebView error: ${error.description}');
            },
          ),
        )
        ..addJavaScriptChannel(
          'PaystackFlutter',
          onMessageReceived: (JavaScriptMessage message) {
            _handlePaymentResponse(message.message);
          },
        )
        ..loadHtmlString(_buildPaystackHTML());
      
      if (mounted) {
        setState(() {
          _controller = controller;
        });
      }
    } catch (e) {
      debugPrint('❌ [PaystackMobile] Error: $e');
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
    <script src="https://js.paystack.co/v1/inline.js"></script>
    <style>body{display:flex;justify-content:center;align-items:center;height:100vh;margin:0;font-family:sans-serif;background:#f0f2f5}</style>
</head>
<body>
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
                },
                callback: function(response) {
                    if (window.PaystackFlutter) {
                        window.PaystackFlutter.postMessage(JSON.stringify({
                            success: true,
                            reference: response.reference
                        }));
                    }
                },
                onClose: function() {
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
        window.onload = function() { setTimeout(payWithPaystack, 500); };
    </script>
</body>
</html>
    ''';
  }

  void _handlePaymentResponse(String message) {
    try {
      if (message.contains('"success":true')) {
        final referenceMatch = RegExp(r'"reference":"([^"]+)"').firstMatch(message);
        final reference = referenceMatch?.group(1);
        if (reference != null) {
          Navigator.pop(context, {'success': true, 'reference': reference});
        }
      } else {
        Navigator.pop(context, {'success': false, 'message': 'Payment cancelled'});
      }
    } catch (e) {
      Navigator.pop(context, {'success': false, 'message': 'Error processing payment'});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('payment'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context, {'success': false, 'message': 'Cancelled'}),
        ),
      ),
      body: _controller == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                WebViewWidget(controller: _controller!),
                if (_isLoading) const Center(child: CircularProgressIndicator()),
              ],
            ),
    );
  }
}

// ================== CINETPAY IMPLEMENTATION ==================

class _PaymentGatewayCinetPayMobile extends StatefulWidget {
  final String apiKey;
  final String siteId;
  final String transactionId;
  final double amount;
  final String currency;
  final String description;
  final String email;
  final Map<String, dynamic>? userData;

  const _PaymentGatewayCinetPayMobile({
    required this.apiKey,
    required this.siteId,
    required this.transactionId,
    required this.amount,
    required this.currency,
    required this.description,
    required this.email,
    this.userData,
  });

  @override
  State<_PaymentGatewayCinetPayMobile> createState() => _PaymentGatewayCinetPayMobileState();
}

class _PaymentGatewayCinetPayMobileState extends State<_PaymentGatewayCinetPayMobile> {
  WebViewController? _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _initializeWebView();
    });
  }

  void _initializeWebView() {
    try {
      debugPrint('🚀 [CinetPayMobile] Initializing WebView...');
      
      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              if (mounted) setState(() => _isLoading = true);
            },
            onPageFinished: (String url) {
              if (mounted) setState(() => _isLoading = false);
            },
            onWebResourceError: (WebResourceError error) {
              debugPrint('❌ [CinetPayMobile] WebView error: ${error.description}');
            },
          ),
        )
        ..addJavaScriptChannel(
          'CinetPayFlutter',
          onMessageReceived: (JavaScriptMessage message) {
             _handlePaymentResponse(message.message);
          },
        )
        // Set a valid base URL to avoid CORS/Origin issues with CinetPay
        ..loadHtmlString(_buildCinetPayHTML(), baseUrl: 'https://cinetpay.com');
      
      if (mounted) {
        setState(() {
          _controller = controller;
        });
      }
    } catch (e) {
      debugPrint('❌ [CinetPayMobile] Error: $e');
    }
  }

  String _buildCinetPayHTML() {
    // Extract user data with fallbacks
    final fName = widget.userData?['firstName'] ?? '';
    final lName = widget.userData?['lastName'] ?? '';
    final addr = widget.userData?['address'] ?? 'Abidjan';
    final city = widget.userData?['city'] ?? 'Abidjan';
    final country = widget.userData?['country'] ?? 'CI';
    final phone = widget.userData?['phone'] ?? '';
    final zip = '00000';

    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://cdn.cinetpay.com/seamless/main.js"></script>
    <style>body{display:flex;justify-content:center;align-items:center;height:100vh;margin:0;font-family:sans-serif;background:#f0f2f5}</style>
</head>
<body>
    <script>
        function checkout() {
            var transId = '${widget.transactionId}';
            
            CinetPay.setConfig({
                apikey: '${widget.apiKey}',
                site_id: '${widget.siteId}',
                notify_url: 'http://mondomaine.com/notify/',
                mode: 'PRODUCTION' // or 'PRODUCTION'
            });
            
            CinetPay.getCheckout({
                transaction_id: transId,
                amount: ${widget.amount.toInt()},
                currency: '${widget.currency}',
                channels: 'ALL',
                description: '${widget.description}',
                // Customer data
                customer_name: '$fName',
                customer_surname: '$lName',
                customer_email: '${widget.email}',
                customer_phone_number: '$phone',
                customer_address: '$addr',
                customer_city: '$city',
                customer_country: '$country',
                customer_state: '$country',
                customer_zip_code: '$zip',
            });
            
            CinetPay.waitResponse(function(data) {
                if (window.CinetPayFlutter) {
                    if (data.status == "ACCEPTED") {
                         window.CinetPayFlutter.postMessage(JSON.stringify({
                            success: true,
                            reference: data.operator_id || transId, // CinetPay uses operator_id
                            message: 'Payment verified'
                        }));
                    } else {
                         window.CinetPayFlutter.postMessage(JSON.stringify({
                            success: false,
                            message: 'Payment failed status: ' + data.status
                        }));
                    }
                }
            });
            
            CinetPay.onError(function(data) {
                if (window.CinetPayFlutter) {
                    window.CinetPayFlutter.postMessage(JSON.stringify({
                        success: false,
                        message: 'Error: ' + data.description
                    }));
                }
            });
        }
        
        window.onload = function() { setTimeout(checkout, 1000); };
    </script>
</body>
</html>
    ''';
  }

  void _handlePaymentResponse(String message) {
    try {
      debugPrint('CinetPay Response: $message');
      if (message.contains('"success":true')) {
         final referenceMatch = RegExp(r'"reference":"([^"]+)"').firstMatch(message);
         final reference = referenceMatch?.group(1) ?? widget.transactionId;
         Navigator.pop(context, {'success': true, 'reference': reference});
      } else {
         Navigator.pop(context, {'success': false, 'message': 'Payment failed'});
      }
    } catch (e) {
       Navigator.pop(context, {'success': false, 'message': 'Error processing payment'});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('payment'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context, {'success': false, 'message': 'Cancelled'}),
        ),
      ),
      body: _controller == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                WebViewWidget(controller: _controller!),
                if (_isLoading) const Center(child: CircularProgressIndicator()),
              ],
            ),
    );
  }
}
