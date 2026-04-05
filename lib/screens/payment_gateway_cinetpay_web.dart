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
  String _status = 'INITIAL'; // INITIAL, PENDING, SUCCESS, ERROR
  Timer? _statusTimer;
  int _checkCount = 0;

  @override
  void initState() {
    super.initState();
    _transactionId = 'TXW${DateTime.now().millisecondsSinceEpoch}';
    
    js.context['onPaymentSuccess'] = js.allowInterop((data) {
       if (mounted) setState(() { _status = 'SUCCESS'; });
       Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Navigator.pop(context, {'success': true, 'reference': _transactionId});
       });
    });

    js.context['onPaymentError'] = js.allowInterop((data) {
       if (mounted) setState(() { _status = 'ERROR'; });
    });
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  void _startStatusPolling() {
    _statusTimer?.cancel();
    _checkCount = 0;
    _statusTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_status == 'PENDING') _checkTransactionStatus();
      else timer.cancel();
    });
  }

  Future<void> _checkTransactionStatus() async {
    if (_checkCount > 15) { _statusTimer?.cancel(); return; }
    _checkCount++;
    
    try {
      final token = await TokenStorage().getAccessToken();
      final dio = Dio(); 
      final response = await dio.get(
        'https://api.tiknetafrica.com/api/partner/subscription-plans/check/',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.data != null && response.data['is_active'] == true) {
         _statusTimer?.cancel();
         if (mounted) setState(() { _status = 'SUCCESS'; });
         Future.delayed(const Duration(seconds: 2), () {
            if (mounted) Navigator.pop(context, {'success': true, 'reference': _transactionId});
         });
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
          if (mounted) setState(() { _status = 'SUCCESS'; });
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) Navigator.pop(context, {'success': true, 'reference': _transactionId});
          });
      }
    } catch (_) {}
  }

  Future<void> _launchPaymentGateway() async {
    final String returnUrl = html.window.location.href.split('?').first;
    final userAgent = html.window.navigator.userAgent.toLowerCase();
    final isMobile = userAgent.contains('mobile') || userAgent.contains('android') || userAgent.contains('iphone');

    if (isMobile) {
      if (mounted) setState(() { _status = 'PENDING'; });
      try {
        final dio = Dio();
        final response = await dio.post(
          'https://api-checkout.cinetpay.com/v2/payment',
          data: {
            'apikey': '297929662685d35c4021b02.21438964',
            'site_id': widget.siteId,
            'transaction_id': _transactionId,
            'amount': widget.amount.toInt(),
            'currency': widget.currency == 'CFA' ? 'XOF' : widget.currency,
            'description': widget.description,
            'notify_url': 'https://api.tiknetafrica.com/api/payment/notify/',
            'return_url': returnUrl,
            'customer_name': widget.firstName,
            'customer_surname': widget.lastName,
            'customer_email': widget.email,
            'customer_phone_number': widget.phoneNumber,
            'channels': 'ALL',
            'lang': 'fr'
          }
        );
        if (response.data['code'] == '201') {
          _startStatusPolling();
          html.window.location.assign(response.data['data']['payment_url']);
        } else {
          throw Exception('CinetPay API Error');
        }
      } catch (e) {
        if (mounted) setState(() { _status = 'ERROR'; });
      }
    } else {
      if (mounted) setState(() { _status = 'PENDING'; });
      js.context.callMethod('launchCinetPay', [
        js.JsObject.jsify({
          'apiKey': '297929662685d35c4021b02.21438964',
          'siteId': widget.siteId,
          'notifyUrl': 'https://api.tiknetafrica.com/api/payment/notify/',
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('payment'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onRequestClose,
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_status == 'PENDING' || _status == 'INITIAL') ...[
                const Icon(Icons.security, color: Colors.blue, size: 80),
                const SizedBox(height: 24),
                const Text('payment_ready', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)).tr(),
                const SizedBox(height: 12),
                const Text('payment_portal_desc', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)).tr(),
                const SizedBox(height: 32),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320, minHeight: 60),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade800,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 4,
                    ),
                    onPressed: () => _launchPaymentGateway(),
                    child: Center(child: Text(_status == 'INITIAL' ? 'pay_now'.tr() : 'verify_my_payment'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                  ),
                ),
                if (_status == 'PENDING') ...[
                  const SizedBox(height: 32),
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text('payment_activation_pending', style: TextStyle(color: Colors.blueGrey)).tr(),
                ],
              ] else if (_status == 'SUCCESS') ...[
                const Icon(Icons.check_circle, color: Colors.green, size: 80),
                const SizedBox(height: 24),
                const Text('payment_success', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)).tr(),
                const SizedBox(height: 12),
                const Text('payment_redirecting', textAlign: TextAlign.center).tr(),
              ] else if (_status == 'ERROR') ...[
                const Icon(Icons.error_outline, color: Colors.red, size: 80),
                const SizedBox(height: 24),
                const Text('payment_failed_desc', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)).tr(),
                const SizedBox(height: 32),
                ElevatedButton(onPressed: () => _launchPaymentGateway(), child: const Text('retry_payment').tr()),
              ],
              const SizedBox(height: 60),
              const Text('Build v1.1.92 - Resilient Navigation Fix', style: TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
