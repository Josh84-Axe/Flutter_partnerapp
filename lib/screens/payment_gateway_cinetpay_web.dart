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
  final String address;
  final String city;
  final String country;
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
    this.address = 'Main Street',
    this.city = 'Abidjan',
    this.country = 'CI',
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
      if (_status == 'PENDING' || _status == 'INITIAL') {
        _checkTransactionStatus();
      } else {
        timer.cancel();
      }
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
    
    // Universal Phone Sanitization & Prefixing
    String phone = widget.phoneNumber.replaceAll(RegExp(r'\D'), '');
    final country = widget.country.toUpperCase();
    if (phone.length >= 8 && phone.length <= 10) {
      if (country == 'CI') phone = '225$phone';
      else if (country == 'SN') phone = '221$phone';
      else if (country == 'ML') phone = '223$phone';
      else if (country == 'BJ') phone = '229$phone';
      else if (country == 'TG') phone = '228$phone';
      else if (country == 'BF') phone = '226$phone';
    }

    final userAgent = html.window.navigator.userAgent.toLowerCase();
    final isMobile = userAgent.contains('mobile') || userAgent.contains('android') || userAgent.contains('iphone');

    // Hardened Payload Preparation
    final String safeTransactionId = _transactionId.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    final String finalPhone = phone.startsWith('+') ? phone : '+$phone';
    final String safeDesc = widget.description.length > 30 
        ? widget.description.substring(0, 30) 
        : widget.description.replaceAll(RegExp(r'[^a-zA-Z0-9 ]'), '');

    if (isMobile) {
      try {
        final response = await Dio().post(
          'https://api-checkout.cinetpay.com/v2/payment',
          data: {
            'api_key': '297929662685d35c4021b02.21438964', // Strictly required as api_key for REST
            'site_id': '${widget.siteId}', 
            'transaction_id': safeTransactionId,
            'amount': widget.amount.toInt(), 'currency': widget.currency == 'CFA' ? 'XOF' : widget.currency,
            'description': safeDesc, 'notify_url': 'https://api.tiknetafrica.com/v1/partner/payment/notify/',
            'return_url': html.window.location.href, 
            'customer_name': widget.lastName, 'customer_surname': widget.firstName,
            'customer_email': widget.email, 'customer_phone_number': finalPhone, 
            'customer_address': widget.address, 'customer_city': widget.city, 'customer_country': country,
            'channels': 'MOBILE_MONEY,WALLET,CREDIT_CARD', 'lang': 'fr'
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
          'apikey': '297929662685d35c4021b02.21438964', 
          'api_key': '297929662685d35c4021b02.21438964', // Doubling for safety
          'siteId': widget.siteId,
          'notifyUrl': 'https://api.tiknetafrica.com/v1/partner/payment/notify/', 'transactionId': safeTransactionId,
          'amount': widget.amount.toInt(), 'currency': widget.currency == 'CFA' ? 'XOF' : widget.currency,
          'description': safeDesc, 'customerName': widget.lastName, 'customerSurname': widget.firstName,
          'customerEmail': widget.email, 'customerPhoneNumber': finalPhone, 'returnUrl': html.window.location.href,
          'customerAddress': widget.address, 'customerCity': widget.city, 'customerCountry': country,
          'channels': 'MOBILE_MONEY,WALLET,CREDIT_CARD',
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
