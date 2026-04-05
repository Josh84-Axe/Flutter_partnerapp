import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:dio/dio.dart';
import 'dart:html' as html;
import 'dart:js' as js;
import '../services/api/token_storage.dart';

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
    js.context['onPaymentSuccess'] = js.allowInterop((data) {
       if (mounted) setState(() => _status = 'SUCCESS');
       Future.delayed(const Duration(seconds: 1), () { if (mounted) Navigator.pop(context, {'success': true}); });
    });
    js.context['onPaymentError'] = js.allowInterop((data) { if (mounted) setState(() => _status = 'ERROR'); });
    
    // Auto-launch CinetPay
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
      final dio = Dio(); 
      final response = await dio.get(
        'https://api.tiknetafrica.com/api/partner/subscription-plans/check/',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.data != null && response.data['is_active'] == true) {
         _statusTimer?.cancel();
         if (mounted) setState(() => _status = 'SUCCESS');
         Future.delayed(const Duration(seconds: 2), () { if (mounted) Navigator.pop(context, {'success': true}); });
         return;
      }
    } catch (_) {}

    try {
      final dio = Dio();
      final response = await dio.post(
        'https://api-checkout.cinetpay.com/v2/payment/check',
        data: { 'apikey': '297929662685d35c4021b02.21438964', 'site_id': widget.siteId, 'transaction_id': _transactionId }
      );
      if (response.data['code'] == '00' && response.data['data']['status'] == 'ACCEPTED') {
          _statusTimer?.cancel();
          if (mounted) setState(() => _status = 'SUCCESS');
          Future.delayed(const Duration(seconds: 2), () { if (mounted) Navigator.pop(context, {'success': true}); });
      }
    } catch (_) {}
  }

  Future<void> _launchPaymentGateway() async {
    if (mounted) setState(() => _status = 'PENDING');
    final returnUrl = html.window.location.href.split('?').first;
    final userAgent = html.window.navigator.userAgent.toLowerCase();
    final isMobile = userAgent.contains('mobile') || userAgent.contains('android') || userAgent.contains('iphone');

    if (isMobile) {
      try {
        final response = await Dio().post(
          'https://api-checkout.cinetpay.com/v2/payment',
          data: {
            'apikey': '297929662685d35c4021b02.21438964', 'site_id': widget.siteId, 'transaction_id': _transactionId,
            'amount': widget.amount.toInt(), 'currency': widget.currency == 'CFA' ? 'XOF' : widget.currency,
            'description': widget.description, 'notify_url': 'https://api.tiknetafrica.com/api/payment/notify/',
            'return_url': returnUrl, 'customer_name': widget.firstName, 'customer_surname': widget.lastName,
            'customer_email': widget.email, 'customer_phone_number': widget.phoneNumber, 'channels': 'ALL', 'lang': 'fr'
          }
        );
        if (response.data['code'] == '201') {
          _startStatusPolling();
          html.window.location.assign(response.data['data']['payment_url']);
        } else { throw Exception(); }
      } catch (e) { if (mounted) setState(() => _status = 'ERROR'); }
    } else {
      js.context.callMethod('launchCinetPay', [
        js.JsObject.jsify({
          'apiKey': '297929662685d35c4021b02.21438964', 'siteId': widget.siteId,
          'notifyUrl': 'https://api.tiknetafrica.com/api/payment/notify/', 'transactionId': _transactionId,
          'amount': widget.amount.toInt(), 'currency': widget.currency == 'CFA' ? 'XOF' : widget.currency,
          'description': widget.description, 'customerName': widget.firstName, 'customerSurname': widget.lastName,
          'customerEmail': widget.email, 'customerPhoneNumber': widget.phoneNumber, 'returnUrl': returnUrl,
        })
      ]);
      _startStatusPolling();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('payment'.tr()), leading: IconButton(icon: const Icon(Icons.close), onPressed: widget.onRequestClose)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_status == 'PENDING' || _status == 'INITIAL') ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              const Text('payment_redirecting', style: TextStyle(fontSize: 16, color: Colors.blueGrey)).tr(),
              const SizedBox(height: 8),
              const Text('Initializing Secure Gateway...', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ] else if (_status == 'SUCCESS') ...[
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 24),
              const Text('payment_success', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)).tr(),
            ] else if (_status == 'ERROR') ...[
              const Icon(Icons.error_outline, color: Colors.red, size: 80),
              const SizedBox(height: 24),
              const Text('payment_failed_desc', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)).tr(),
              const SizedBox(height: 32),
              ElevatedButton(onPressed: () => _launchPaymentGateway(), child: const Text('retry_payment').tr()),
            ],
            const SizedBox(height: 60),
            const Text('Build v1.1.95 - Seamless Integrated Gateway', style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
