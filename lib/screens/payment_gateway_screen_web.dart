import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'payment_gateway_cinetpay_web.dart';
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;

/// Screen for handling Paystack inline payment popup
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
  late String _transactionId;

  @override
  void initState() {
    super.initState();
    // Unique ID for the transaction (Numeric-ish only)
    _transactionId = 'TXN${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Widget build(BuildContext context) {
    // Determine target gateway based on currency OR user country
    final rawCountry = widget.userData?['country']?.toString()?.toLowerCase() ?? '';
    final isFrancophoneCountry = rawCountry == 'ci' || rawCountry == 'sn' || rawCountry == 'ml' || rawCountry == 'bj' || 
                                 rawCountry == 'bf' || rawCountry == 'ne' || rawCountry == 'tg' || rawCountry == 'cm' || 
                                 rawCountry == 'ga' || rawCountry == 'cg' || rawCountry == 'td' || rawCountry == 'gn' ||
                                 rawCountry.contains('ivoire') || rawCountry.contains('senegal');

    final isFrancophoneCurrency = widget.currency == 'XOF' || widget.currency == 'XAF' || widget.currency == 'GNF' || 
                                  widget.currency == 'FG' || widget.currency == 'CFA' || widget.currency.contains('CFA');

    // Paystack remains default for NGN, GHS and non-francophone cases
    final bool isCinetPay = isFrancophoneCurrency || isFrancophoneCountry || widget.email == 'ketiglo15@gmail.com';
    
    if (isCinetPay) {
       final fName = widget.userData?['firstName'] ?? '';
       final lName = widget.userData?['lastName'] ?? '';
       final phone = widget.userData?['phone'] ?? '';

       return PaymentGatewayCinetPay(
          email: widget.email,
          amount: widget.amount,
          currency: (widget.currency == 'CFA' || widget.currency == 'USD') ? 'XOF' : widget.currency,
          description: 'Payment for ${widget.planName}',
          firstName: fName,
          lastName: lName,
          phoneNumber: phone,
          siteId: '105899723',
       );
    }

    // Default to Paystack
    return PaymentGatewayPaystackWeb(
      email: widget.email,
      amount: widget.amount,
      planId: widget.planId,
      planName: widget.planName,
      currency: widget.currency,
    );
  }
}

class PaymentGatewayPaystackWeb extends StatefulWidget {
  final String email;
  final double amount;
  final String planId;
  final String planName;
  final String currency;

  const PaymentGatewayPaystackWeb({
    super.key,
    required this.email,
    required this.amount,
    required this.planId,
    required this.planName,
    required this.currency,
  });

  @override
  State<PaymentGatewayPaystackWeb> createState() => _PaymentGatewayPaystackWebState();
}

class _PaymentGatewayPaystackWebState extends State<PaymentGatewayPaystackWeb> {
  late String _transactionId;
  String _status = 'INITIAL'; // INITIAL, PENDING, SUCCESS, ERROR
  Timer? _statusTimer;
  int _checkCount = 0;

  @override
  void initState() {
    super.initState();
    _transactionId = 'PSK${DateTime.now().millisecondsSinceEpoch}';
    
    // JS Callbacks for Paystack
    js.context['onPaystackSuccess'] = js.allowInterop((reference) {
      debugPrint('✅ [Paystack] Payment Successful: $reference');
      if (mounted) setState(() { _status = 'SUCCESS'; });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context, {'success': true, 'reference': reference});
      });
    });

    js.context['onPaystackCancel'] = js.allowInterop(() {
      debugPrint('⚠️ [Paystack] Payment Cancelled');
      if (mounted) setState(() { _status = 'INITIAL'; });
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
      if (_status == 'PENDING') {
        _checkTransactionStatus();
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _checkTransactionStatus() async {
    // This polls the Tiknet backend to see if the subscription was activated via webhook
    if (_checkCount > 15) { // 2.5 minutes
       _statusTimer?.cancel();
       return;
    }
    _checkCount++;
    
    try {
      final dio = Dio(); 
      // Use the existing subscription check endpoint
      final response = await dio.get('https://api.tiknetafrica.com/api/partner/subscription-plans/check/');
      if (response.data != null && response.data['is_active'] == true) {
         _statusTimer?.cancel();
         if (mounted) setState(() { _status = 'SUCCESS'; });
         Future.delayed(const Duration(seconds: 2), () {
            if (mounted) Navigator.pop(context, {'success': true, 'reference': _transactionId});
         });
      }
    } catch (e) {
       debugPrint('ℹ️ [Paystack] Status polling check: $e');
    }
  }

  void _launchPaystack() {
     if (mounted) setState(() { _status = 'PENDING'; });
     
     final amountInKobo = (widget.amount * 100).toInt();
     
     js.context.callMethod('launchPaystack', [
       js.JsObject.jsify({
         'key': 'pk_live_ba6137ee394e83ff5b0cfec596851545e1dea426',
         'email': widget.email,
         'amount': amountInKobo,
         'currency': widget.currency,
         'ref': _transactionId,
         'planId': widget.planId,
         'planName': widget.planName,
       })
     ]);
     
     _startStatusPolling();
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
                const Icon(Icons.payment, color: Colors.blueAccent, size: 80),
                const SizedBox(height: 24),
                Text(
                  widget.planName,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.currency} ${widget.amount.toInt()}',
                  style: TextStyle(fontSize: 18, color: Colors.blue.shade700, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 24),
                const Text(
                  'payment_ready',
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
                    onPressed: () => _launchPaystack(),
                    child: const Text('pay_now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)).tr(),
                  ),
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
                const Text('payment_activation_pending').tr(),
              ] else if (_status == 'ERROR') ...[
                const Icon(Icons.error_outline, color: Colors.red, size: 80),
                const SizedBox(height: 24),
                const Text(
                  'payment_failed_desc',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ).tr(),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _launchPaystack(),
                  child: const Text('retry_payment').tr(),
                ),
              ],
              const SizedBox(height: 48),
              const Text('Build v1.1.85 - Resilient Paystack Gateway (Final)', style: TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
