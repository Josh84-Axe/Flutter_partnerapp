import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:dio/dio.dart';
import 'dart:html' as html;
import 'dart:js' as js;

class PaymentGatewayCinetPay extends StatefulWidget {
  final String email;
  final double amount;
  final String currency;
  final String description;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String siteId;

  const PaymentGatewayCinetPay({
    super.key,
    required this.email,
    required this.amount,
    required this.currency,
    required this.description,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
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
    
    // Register JS callbacks for payment outcomes correctly using allowInterop
    js.context['onPaymentSuccess'] = js.allowInterop((data) {
       debugPrint('✅ [CinetPay] Payment Success (JS Callback): $data');
       if (mounted) setState(() { _status = 'SUCCESS'; });
       Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Navigator.pop(context, {'success': true, 'reference': _transactionId});
       });
    });

    js.context['onPaymentError'] = js.allowInterop((data) {
       debugPrint('❌ [CinetPay] Payment Error (JS Callback): $data');
       if (mounted) setState(() { _status = 'ERROR'; });
    });

    // Auto-launch current BUILD logic
    // WidgetsBinding.instance.addPostFrameCallback((_) => _launchPaymentGateway());
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
      if (_status == 'PENDING') {
        _checkTransactionStatus();
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _checkTransactionStatus() async {
    if (_checkCount > 12) { // Stop after 2 minutes
      _statusTimer?.cancel();
      return;
    }
    _checkCount++;
    
    final String siteId = widget.siteId.isEmpty ? '105899723' : widget.siteId;
    final String apiKey = '297929662685d35c4021b02.21438964';

    try {
      final dio = Dio();
      final response = await dio.post(
        'https://api-checkout.cinetpay.com/v2/payment/check',
        data: {
          'apikey': apiKey,
          'site_id': siteId,
          'transaction_id': _transactionId,
        }
      );

      if (response.data['code'] == '00') {
        final data = response.data['data'];
        if (data['status'] == 'ACCEPTED') {
          _statusTimer?.cancel();
          if (mounted) setState(() { _status = 'SUCCESS'; });
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) Navigator.pop(context, {'success': true, 'reference': _transactionId});
          });
        }
      }
    } catch (e) {
      debugPrint('ℹ️ [CinetPay] Status check silent fail (normal if unpaid yet): $e');
    }
  }

  Future<void> _launchPaymentGateway() async {
    final String siteId = widget.siteId.isEmpty ? '105899723' : widget.siteId;
    final String apiKey = '297929662685d35c4021b02.21438964';
    final String returnUrl = html.window.location.href.split('?').first;
    
    // Detect if this is a mobile browser or PWA
    final userAgent = html.window.navigator.userAgent.toLowerCase();
    final isMobile = userAgent.contains('mobile') || userAgent.contains('android') || userAgent.contains('iphone');

    if (isMobile) {
      if (mounted) setState(() { _status = 'PENDING'; });
      debugPrint('📱 [CinetPay] Mobile detected. Initiating API Handshake (v1.1.83)');
      
      try {
        final dio = Dio();
        final response = await dio.post(
          'https://api-checkout.cinetpay.com/v2/payment',
          data: {
            'apikey': apiKey,
            'site_id': siteId,
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
          final paymentUrl = response.data['data']['payment_url'];
          debugPrint('🚀 [CinetPay] Redirecting to: $paymentUrl');
          _startStatusPolling(); // Start polling in case they return
          html.window.location.assign(paymentUrl);
        } else {
          throw Exception('CinetPay API Error: ${response.data['message']}');
        }
      } catch (e) {
        debugPrint('❌ [CinetPay] API Handshake Failed: $e');
        if (mounted) setState(() { _status = 'ERROR'; });
      }
    } else {
      debugPrint('💻 [CinetPay] Desktop detected. Using Seamless In-App Modal.');
      if (mounted) setState(() { _status = 'PENDING'; });
      
      js.context.callMethod('launchCinetPay', [
        js.JsObject.jsify({
          'apiKey': apiKey,
          'siteId': siteId,
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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_status == 'PENDING' || _status == 'INITIAL') ...[
                const Icon(Icons.security, color: Colors.blue, size: 80),
                const SizedBox(height: 24),
                const Text(
                  'payment_ready',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ).tr(),
                const SizedBox(height: 12),
                const Text(
                  'payment_portal_desc',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ).tr(),
                const SizedBox(height: 32),
                SizedBox(
                  width: 280,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                    ),
                    onPressed: () => _launchPaymentGateway(),
                    child: const Text('pay_now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)).tr(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Build v1.1.85 - Resilient Polling Gateway (Final Optimization)',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: Colors.blueGrey),
                ),
                if (_status == 'PENDING') ...[
                  const SizedBox(height: 24),
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () => _checkTransactionStatus(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('verify_my_payment').tr(),
                  ),
                ],
              ] else if (_status == 'SUCCESS') ...[
                const Icon(Icons.check_circle, color: Colors.green, size: 80),
                const SizedBox(height: 24),
                const Text(
                  'payment_success',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
                ).tr(),
                const SizedBox(height: 8),
                const Text('payment_redirecting').tr(),
              ] else if (_status == 'ERROR') ...[
                const Icon(Icons.error_outline, color: Colors.red, size: 80),
                const SizedBox(height: 24),
                const Text(
                  'payment_failed_desc',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ).tr(),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _launchPaymentGateway(),
                  child: const Text('retry_payment').tr(),
                ),
              ],
              const SizedBox(height: 48),
              const Text('Build v1.1.85 - Resilient Polling Gateway (Final Optimization)', style: TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
