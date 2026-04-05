import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:dio/dio.dart';
import 'dart:html' as html;
import 'dart:js' as js;
import '../services/api/token_storage.dart';

/// Sealed CinetPay Gateway with Seamless-Only Logic (v1.1.102)
class PaymentGatewayCinetPay extends StatefulWidget {
  final String email;
  final double amount;
  final String currency;
  final String description;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String siteId;
  final VoidCallback onRequestClose;
  final Function(bool success, String? reference, String? message) onResult;

  const PaymentGatewayCinetPay({
    super.key,
    required this.email,
    required this.amount,
    required this.currency,
    required this.description,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.onRequestClose,
    required this.onResult,
    this.siteId = '105899723',
  });

  @override
  State<PaymentGatewayCinetPay> createState() => _PaymentGatewayCinetPayState();
}

class _PaymentGatewayCinetPayState extends State<PaymentGatewayCinetPay> {
  late String _transactionId;
  String _status = 'INITIAL';
  Timer? _statusTimer;
  int _checkCount = 0;

  @override
  void initState() {
    super.initState();
    _transactionId = 'TXW${DateTime.now().millisecondsSinceEpoch}';
    
    js.context['onPaymentSuccess'] = js.allowInterop((transactionId) {
       if (mounted) setState(() => _status = 'SUCCESS');
       Future.delayed(const Duration(seconds: 1), () { 
          if (mounted) widget.onResult(true, transactionId ?? _transactionId, 'payment_success'.tr()); 
       });
    });
    
    js.context['onPaymentError'] = js.allowInterop((data) {
       debugPrint('CinetPay Error/Cancel triggered from JS: $data');
       if (mounted) widget.onResult(false, null, 'payment_cancelled'.tr());
    });

    WidgetsBinding.instance.addPostFrameCallback((_) { _launchPaymentGateway(); });
  }

  @override
  void dispose() { _statusTimer?.cancel(); super.dispose(); }

  void _startStatusPolling() {
    _statusTimer?.cancel();
    _statusTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_status == 'PENDING') _checkTransactionStatus();
      else timer.cancel();
    });
  }

  Future<void> _checkTransactionStatus() async {
    if (_checkCount++ > 15) { _statusTimer?.cancel(); return; }
    try {
      final token = await TokenStorage().getAccessToken();
      final response = await Dio().get(
        'https://api.tiknetafrica.com/v1/partner/subscription-plans/check/',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.data != null && response.data['is_active'] == true) {
         _statusTimer?.cancel();
         if (mounted) setState(() => _status = 'SUCCESS');
         Future.delayed(const Duration(seconds: 1), () { 
            if (mounted) widget.onResult(true, _transactionId, 'payment_success'.tr()); 
         });
      }
    } catch (_) {}
  }

  Future<void> _launchPaymentGateway() async {
    if (mounted) setState(() => _status = 'PENDING');
    final returnUrl = html.window.location.href.split('?').first;

    // FIXED v1.1.102: Always use launchCinetPay (Seamless SDK) instead of html redirect.
    // This maintains the Flutter app state on mobile browsers, allowing Navigator.pop to work on return.
    js.context.callMethod('launchCinetPay', [
      js.JsObject.jsify({
        'apiKey': '297929662685d35c4021b02.21438964', 
        'siteId': widget.siteId,
        'notifyUrl': 'https://api.tiknetafrica.com/v1/partner/payment/notify/', 
        'transactionId': _transactionId,
        'amount': widget.amount.toInt(), 
        'currency': widget.currency == 'CFA' ? 'XOF' : widget.currency,
        'description': widget.description, 
        'customerName': widget.firstName, 
        'customerSurname': widget.lastName,
        'customerEmail': widget.email, 
        'customerPhoneNumber': widget.phoneNumber, 
        'returnUrl': returnUrl,
      })
    ]);
    _startStatusPolling();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _status == 'PENDING' 
        ? Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(blurRadius: 20, color: Colors.black26)]),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text('payment_redirecting', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)).tr(),
              ],
            ),
          )
        : const SizedBox.shrink(),
    );
  }
}
