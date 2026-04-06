import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:webview_flutter/webview_flutter.dart';
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
    required this.apiKey, required this.siteId, required this.transactionId,
    required this.amount, required this.currency, required this.description,
    required this.email, required this.onRequestClose, required this.onResult, this.userData,
  });

  @override
  State<_PaymentGatewayCinetPayMobile> createState() => _PaymentGatewayCinetPayMobileState();
}

class _PaymentGatewayCinetPayMobileState extends State<_PaymentGatewayCinetPayMobile> {
  WebViewController? _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) _initializeWebView(); });
  }

  void _initializeWebView() {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel('CinetPayFlutter', onMessageReceived: (message) {
        if (message.message.contains('"success":true')) {
           widget.onResult(true, widget.transactionId, 'payment_success'.tr());
        } else if (message.message.contains('"success":false')) {
           widget.onResult(false, null, 'payment_cancelled'.tr());
        }
      })
      ..loadHtmlString(_buildCinetPayHTML(), baseUrl: 'https://cinetpay.com');
    setState(() => _controller = controller);
  }

  String _buildCinetPayHTML() {
    return '''
<!DOCTYPE html><html><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<script src="https://checkout.cinetpay.com/sdk/dist/cinetpay.min.js"></script></head>
<body><script>
function checkout() {
  CinetPay.setConfig({ apiKey: '${widget.apiKey}', site_id: '${widget.siteId}', notify_url: 'https://api.tiknetafrica.com/v1/partner/payment/notify/', mode: 'PRODUCTION' });
  CinetPay.getCheckout({ transaction_id: '${widget.transactionId}', amount: ${widget.amount.toInt()}, currency: '${widget.currency}', channels: 'ALL', description: '${widget.description}', customer_email: '${widget.email}' });
  CinetPay.waitResponse(function(data) { 
    if (data.status == "ACCEPTED") window.CinetPayFlutter.postMessage(JSON.stringify({success:true}));
    else window.CinetPayFlutter.postMessage(JSON.stringify({success:false}));
  });
  CinetPay.onError(function(data) { window.CinetPayFlutter.postMessage(JSON.stringify({success:false})); });
}
window.onload = function(){ setTimeout(checkout, 1000); };
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
