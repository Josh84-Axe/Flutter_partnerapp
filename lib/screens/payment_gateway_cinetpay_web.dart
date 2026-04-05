import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:dio/dio.dart';
import 'dart:html' as html;
import 'dart:js' as js;
import '../services/api/token_storage.dart';

/// Optimized CinetPay Gateway (v1.1.103)
/// Reverted to redirect-mode for mobile to support bank/mobile-money secondary popups,
/// while maintaining seamless overlay for desktop.
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
    
    // JS Callbacks for Seamless Mode (Desktop)
    js.context['onPaymentSuccess'] = js.allowInterop((transactionId) {
       if (mounted) setState(() => _status = 'SUCCESS');
       Future.delayed(const Duration(seconds: 1), () { 
          if (mounted) widget.onResult(true, transactionId ?? _transactionId, 'payment_success'.tr()); 
       });
    });
    
    js.context['onPaymentError'] = js.allowInterop((data) {
       debugPrint('CinetPay Error/Cancel (JS): $data');
       if (mounted) widget.onResult(false, null, 'payment_cancelled'.tr());
    });

    // Check if we just returned from a mobile redirect
    final uri = Uri.parse(html.window.location.href.replaceFirst('/#/', '/'));
    if (uri.queryParameters.containsKey('transaction_id')) {
       _transactionId = uri.queryParameters['transaction_id']!;
       _startStatusPolling();
    } else {
       WidgetsBinding.instance.addPostFrameCallback((_) { _launchPaymentGateway(); });
    }
  }

  @override
  void dispose() { _statusTimer?.cancel(); super.dispose(); }

  void _startStatusPolling() {
    _statusTimer?.cancel();
    _statusTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (_status == 'PENDING' || _status == 'INITIAL') _checkTransactionStatus();
      else timer.cancel();
    });
  }

  Future<void> _checkTransactionStatus() async {
    if (_checkCount++ > 30) { _statusTimer?.cancel(); return; }
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
    
    final userAgent = html.window.navigator.userAgent.toLowerCase();
    final isMobile = userAgent.contains('mobile') || userAgent.contains('android') || userAgent.contains('iphone');

    // PRESERVE REVERT: Use redirect for mobile to allow bank/SIM-toolkit popups to function
    if (isMobile) {
      try {
        final response = await Dio().post(
          'https://api-checkout.cinetpay.com/v2/payment',
          data: {
            'apikey': '297929662685d35c4021b02.21438964', 'site_id': widget.siteId, 'transaction_id': _transactionId,
            'amount': widget.amount.toInt(), 'currency': widget.currency == 'CFA' ? 'XOF' : widget.currency,
            'description': widget.description, 'notify_url': 'https://api.tiknetafrica.com/v1/partner/payment/notify/',
            'return_url': html.window.location.href, // Return to this exact page
            'customer_name': widget.firstName, 'customer_surname': widget.lastName,
            'customer_email': widget.email, 'customer_phone_number': widget.phoneNumber, 'channels': 'ALL', 'lang': 'fr'
          }
        );
        if (response.data['code'] == '201') {
          html.window.location.assign(response.data['data']['payment_url']);
        } else { throw Exception(); }
      } catch (e) { if (mounted) widget.onResult(false, null, 'error_occurred'.tr()); }
    } else {
      // Use Seamless for Desktop
      js.context.callMethod('launchCinetPay', [
        js.JsObject.jsify({
          'apiKey': '297929662685d35c4021b02.21438964', 'siteId': widget.siteId,
          'notifyUrl': 'https://api.tiknetafrica.com/v1/partner/payment/notify/', 'transactionId': _transactionId,
          'amount': widget.amount.toInt(), 'currency': widget.currency == 'CFA' ? 'XOF' : widget.currency,
          'description': widget.description, 'customerName': widget.firstName, 'customerSurname': widget.lastName,
          'customerEmail': widget.email, 'customerPhoneNumber': widget.phoneNumber, 'returnUrl': html.window.location.href,
        })
      ]);
      _startStatusPolling();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(blurRadius: 20, color: Colors.black26)]),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('payment_redirecting', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)).tr(),
            if (_status == 'PENDING') ...[
               const SizedBox(height: 8),
               TextButton(
                 onPressed: () => widget.onResult(false, null, 'payment_cancelled'.tr()),
                 child: Text('cancel'.tr(), style: const TextStyle(color: Colors.red)),
               )
            ]
          ],
        ),
      ),
    );
  }
}
