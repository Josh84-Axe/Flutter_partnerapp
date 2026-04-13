import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import '../services/api/token_storage.dart';

/// Sealed Gateway Wrapper for Mobile with Unified Response Logic (v1.1.101)
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
  bool _isExiting = false;

  Future<void> _finalize({required bool success, String? reference, String? message}) async {
    if (mounted && !_isExiting) {
      setState(() => _isExiting = true);
      await Future.delayed(Duration.zero);
      if (mounted) {
        Navigator.of(context).pop({
          'success': success,
          'reference': reference,
          'message': message ?? (success ? 'payment_success'.tr() : 'payment_cancelled'.tr())
        });
      }
    }
  }

  Future<bool> _handleManualPop({bool isPaystack = true}) async {
    if (_isExiting) return true;
    
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text('cancel_payment'.tr()),
        content: Text('cancel_payment_confirm'.tr()),
        actions: [
          TextButton(child: Text('no'.tr()), onPressed: () => Navigator.of(dialogContext).pop(false)),
          TextButton(style: TextButton.styleFrom(foregroundColor: Colors.red), onPressed: () => Navigator.of(dialogContext).pop(true), child: Text('yes'.tr())),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isExiting = true);
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final rawCountry = widget.userData?['country']?.toString().toLowerCase() ?? 'ci';
    final isFrancophoneCountry = rawCountry == 'ci' || rawCountry == 'sn' || rawCountry == 'ml' || rawCountry == 'bj' || 
                                 rawCountry == 'bf' || rawCountry == 'ne' || rawCountry == 'tg' || rawCountry == 'cm' || 
                                 rawCountry == 'ga' || rawCountry == 'cg' || rawCountry == 'td' || rawCountry == 'gn';

    final isFrancophoneCurrency = widget.currency == 'XOF' || widget.currency == 'XAF' || widget.currency == 'GNF' || 
                                  widget.currency == 'FG' || widget.currency == 'CFA';

    final bool isCinetPay = isFrancophoneCurrency || isFrancophoneCountry;
    
    return PopScope(
      canPop: _isExiting,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final confirmed = await _handleManualPop(isPaystack: !isCinetPay);
        if (confirmed && mounted) Navigator.of(context).pop();
      },
      child: isCinetPay 
        ? _PaymentGatewayCinetPayMobile(
            apiKey: '297929662685d35c4021b02.21438964',
            siteId: '105899723',
            transactionId: 'txn_${DateTime.now().millisecondsSinceEpoch}',
            amount: widget.amount,
            currency: widget.currency == 'CFA' ? 'XOF' : widget.currency,
            description: 'Payment for ${widget.planName}',
            email: widget.email,
            userData: widget.userData,
            onRequestClose: () => _handleManualPop(isPaystack: false).then((conf) { if (conf && mounted) Navigator.of(context).pop(); }),
            onResult: (success, reference, message) => _finalize(success: success, reference: reference, message: message),
          )
        : _PaymentGatewayPaystackMobile(
            email: widget.email,
            amount: widget.amount,
            planId: widget.planId,
            planName: widget.planName,
            currency: widget.currency,
            onRequestClose: () => _handleManualPop(isPaystack: true).then((conf) { if (conf && mounted) Navigator.of(context).pop(); }),
            onResult: (success, reference, message) => _finalize(success: success, reference: reference, message: message),
          ),
    );
  }
}

class _PaymentGatewayPaystackMobile extends StatefulWidget {
  final String email;
  final double amount;
  final String planId;
  final String planName;
  final String currency;
  final VoidCallback onRequestClose;
  final Function(bool success, String? reference, String? message) onResult;

  const _PaymentGatewayPaystackMobile({
    required this.email,
    required this.amount,
    required this.planId,
    required this.planName,
    required this.currency,
    required this.onRequestClose,
    required this.onResult,
  });

  @override
  State<_PaymentGatewayPaystackMobile> createState() => _PaymentGatewayPaystackMobileState();
}

class _PaymentGatewayPaystackMobileState extends State<_PaymentGatewayPaystackMobile> {
  WebViewController? _controller;
  Timer? _statusTimer;
  late String _transactionId;

  @override
  void initState() {
    super.initState();
    _transactionId = 'PSK${DateTime.now().millisecondsSinceEpoch}';
    WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) _initializeWebView(); });
    _startStatusPolling();
  }

  @override
  void dispose() { _statusTimer?.cancel(); super.dispose(); }

  void _startStatusPolling() {
    _statusTimer = Timer.periodic(const Duration(seconds: 10), (timer) { _checkTransactionStatus(); });
  }

  Future<void> _checkTransactionStatus() async {
    try {
      final token = await TokenStorage().getAccessToken();
      final response = await Dio().get(
        'https://api.tiknetafrica.com/v1/partner/subscription-plans/check/',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.data != null && response.data['is_active'] == true) {
        _statusTimer?.cancel();
        if (mounted) widget.onResult(true, _transactionId, 'payment_success'.tr());
      }
    } catch (_) {}
  }

  void _initializeWebView() {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel('PaystackFlutter', onMessageReceived: (JavaScriptMessage message) {
        if (message.message.contains('"success":true')) {
           // Extract reference if possible or use transaction ID
           widget.onResult(true, _transactionId, 'payment_success'.tr());
        } else if (message.message.contains('"success":false')) {
           widget.onResult(false, null, 'payment_cancelled'.tr());
        }
      })
      ..loadHtmlString(_buildPaystackHTML());
    setState(() => _controller = controller);
  }

  String _buildPaystackHTML() {
    return '''
<!DOCTYPE html><html><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<script src="https://js.paystack.co/v1/inline.js"></script></head>
<body style="background:#f0f2f5"><script>
function pay() { PaystackPop.setup({
  key: 'pk_live_ba6137ee394e83ff5b0cfec596851545e1dea426',
  email: '${widget.email}', amount: ${(widget.amount*100).toInt()},
  currency: '${widget.currency}', ref: '$_transactionId',
  callback: function(r){ window.PaystackFlutter.postMessage(JSON.stringify({success:true, reference: r.reference})); },
  onClose: function(){ window.PaystackFlutter.postMessage(JSON.stringify({success:false})); }
}).open(); }
window.onload = function(){ setTimeout(pay, 500); };
</script></body></html>''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('payment'.tr()), leading: IconButton(icon: const Icon(Icons.close), onPressed: widget.onRequestClose)),
      body: _controller == null ? const Center(child: CircularProgressIndicator()) : WebViewWidget(controller: _controller!),
    );
  }
}

class _PaymentGatewayCinetPayMobile extends StatefulWidget {
  final String apiKey;
  final String siteId;
  final String transactionId;
  final double amount;
  final String currency;
  final String description;
  final String email;
  final Map<String, dynamic>? userData;
  final VoidCallback onRequestClose;
  final Function(bool success, String? reference, String? message) onResult;

  const _PaymentGatewayCinetPayMobile({
    required this.apiKey,
    required this.siteId,
    required this.transactionId,
    required this.amount,
    required this.currency,
    required this.description,
    required this.email,
    required this.onRequestClose,
    required this.onResult,
    this.userData,
  });

  @override
  State<_PaymentGatewayCinetPayMobile> createState() => _PaymentGatewayCinetPayMobileState();
}

class _PaymentGatewayCinetPayMobileState extends State<_PaymentGatewayCinetPayMobile> {
  WebViewController? _controller;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _initializeWebView();
    });
  }

  void _initializeWebView() {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..addJavaScriptChannel(
        'CinetPayFlutter',
        onMessageReceived: (message) {
          try {
            final data = jsonDecode(message.message);
            if (data['success'] == true) {
              widget.onResult(true, widget.transactionId, 'payment_success'.tr());
            } else {
              widget.onResult(false, null, data['message'] ?? 'payment_failed'.tr());
            }
          } catch (e) {
            widget.onResult(false, null, 'error_occurred'.tr());
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            if (mounted) setState(() => _isInitializing = false);
          },
          onNavigationRequest: (NavigationRequest request) async {
            // Allow standard web URLs
            if (request.url.startsWith('http')) {
              return NavigationDecision.navigate;
            }
            
            // Handle external apps (Wave, MTN, Moov, Tel, etc.)
            try {
              final Uri uri = Uri.parse(request.url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
                return NavigationDecision.prevent;
              }
            } catch (e) {
              debugPrint('Error launching external URL: $e');
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadHtmlString(_buildCinetPayHTML(), baseUrl: 'https://cinetpay.com');
    
    setState(() => _controller = controller);
  }

  String _buildCinetPayHTML() {
    final String firstName = (widget.userData?['firstName'] ?? 'Customer').toString().replaceAll('"', "'");
    final String lastName = (widget.userData?['lastName'] ?? 'User').toString().replaceAll('"', "'");
    final String address = (widget.userData?['address'] ?? 'Main Street').toString().replaceAll('"', "'");
    final String city = (widget.userData?['city'] ?? 'Abidjan').toString().replaceAll('"', "'");
    final String country = (widget.userData?['country'] ?? 'CI').toString().toUpperCase();
    final String email = (widget.userData?['email'] ?? widget.email ?? 'support@tiknet.ci').toString().replaceAll('"', "'");
    
    // Universal Phone Sanitization: Remove everything except digits
    String phone = (widget.userData?['phone'] ?? '').toString().replaceAll(RegExp(r'\D'), '');
    
    // Smart Prefixing if not international
    if (phone.length >= 8 && phone.length <= 10) {
      if (country == 'CI') phone = '225$phone';
      else if (country == 'SN') phone = '221$phone';
      else if (country == 'ML') phone = '223$phone';
      else if (country == 'BJ') phone = '229$phone';
      else if (country == 'TG') phone = '228$phone';
      else if (country == 'BF') phone = '226$phone';
    }

    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <script src="https://checkout.cinetpay.com/sdk/dist/cinetpay.min.js"></script>
    <style>
        body { margin: 0; padding: 0; display: flex; justify-content: center; align-items: center; height: 100vh; background-color: white; }
    </style>
</head>
<body>
    <script>
        function checkout() {
            try {
                CinetPay.setConfig({
                    apikey: '${widget.apiKey}',
                    api_key: '${widget.apiKey}',
                    apiKey: '${widget.apiKey}',
                    site_id: ${widget.siteId},
                    notify_url: 'https://api.tiknetafrica.com/v1/partner/payment/notify/',
                    mode: 'PRODUCTION'
                });

                final String safeTransactionId = '${widget.transactionId}'.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
                final String finalPhone = phone.startsWith('+') ? phone : '+$phone';

                CinetPay.getCheckout({
                    transaction_id: safeTransactionId,
                    amount: ${((widget.amount / 5).round() * 5).toInt()},
                    currency: '${widget.currency}',
                    channels: 'MOBILE_MONEY,WALLET,CREDIT_CARD',
                    description: '${widget.description.length > 30 ? widget.description.substring(0, 30) : widget.description.replaceAll(RegExp(r'[^a-zA-Z0-9 ]'), '')}',
                    customer_email: '$email',
                    customer_name: '${lastName.isEmpty ? "Tiknet" : lastName}',
                    customer_surname: '${firstName.isEmpty ? "Client" : firstName}',
                    customer_phone_number: finalPhone,
                    customer_address: '${address.isEmpty ? "Abidjan" : address}',
                    customer_city: '${city.isEmpty ? "Abidjan" : city}',
                    customer_country: '$country'
                });

                CinetPay.waitResponse(function(data) {
                    console.log("CinetPay Response: " + JSON.stringify(data));
                    if (data.status == "REFUSED") {
                        console.error("Payment Refused: " + data.description);
                    }
                    if (window.CinetPayFlutter) {
                        window.CinetPayFlutter.postMessage(JSON.stringify({
                            'success': data.status == 'ACCEPTED',
                            'message': data.description,
                            'operator_id': data.operator_id,
                            'payment_method': data.payment_method
                        }));
                    }
                });
                
                CinetPay.onError(function(data) {
                    window.CinetPayFlutter.postMessage(JSON.stringify({
                        success: false, 
                        message: data.description || "Payment failed",
                        code: data.code
                    }));
                });
            } catch (e) {
                window.CinetPayFlutter.postMessage(JSON.stringify({success: false, message: "SDK Error"}));
            }
        }
        window.onload = function(){ setTimeout(checkout, 500); };
    </script>
</body>
</html>''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('payment'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onRequestClose,
        ),
      ),
      body: Stack(
        children: [
          if (_controller != null) WebViewWidget(controller: _controller!),
          if (_controller == null || _isInitializing)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
