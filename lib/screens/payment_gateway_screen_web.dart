import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:dio/dio.dart';
import 'dart:js' as js;
import 'payment_gateway_cinetpay_web.dart';
import '../services/api/token_storage.dart';

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
    
    // Add PopScope for resilience against accidental closures
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final bool? shouldPop = await _showCancelConfirmation(context);
        if (shouldPop == true && context.mounted) {
           Navigator.of(context).pop();
        }
      },
      child: isCinetPay 
        ? PaymentGatewayCinetPay(
            email: widget.email,
            amount: widget.amount,
            currency: (widget.currency == 'CFA' || widget.currency == 'USD') ? 'XOF' : widget.currency,
            description: 'Payment for ${widget.planName}',
            firstName: widget.userData?['firstName'] ?? '',
            lastName: widget.userData?['lastName'] ?? '',
            phoneNumber: widget.userData?['phone'] ?? '',
            siteId: '105899723',
          )
        : PaymentGatewayPaystackWeb(
            email: widget.email,
            amount: widget.amount,
            planId: widget.planId,
            planName: widget.planName,
            currency: widget.currency,
          ),
    );
  }

  Future<bool?> _showCancelConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('cancel_payment'.tr()),
        content: Text('cancel_payment_confirm'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('no'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('yes'.tr()),
          ),
        ],
      ),
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
      debugPrint('✅ [Paystack] Payment Successful (JS Bridge): $reference');
      if (mounted) setState(() { _status = 'SUCCESS'; });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context, {'success': true, 'reference': reference});
      });
    });

    js.context['onPaystackCancel'] = js.allowInterop(() {
      debugPrint('⚠️ [Paystack] Payment Cancelled (JS Bridge)');
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
    if (_checkCount > 18) { // ~3 minutes
       _statusTimer?.cancel();
       return;
    }
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
      }
    } catch (e) {
       debugPrint('ℹ️ [Paystack] Polling check silent (normal): $e');
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
          onPressed: () async {
            final shouldPop = await Navigator.of(context).maybePop();
            if (shouldPop == false) {
                 // Fallback if PopScope wasn't triggered
                 final bool? confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                        title: Text('cancel_payment'.tr()),
                        content: Text('cancel_payment_confirm'.tr()),
                        actions: [
                            TextButton(child: Text('no'.tr()), onPressed: () => Navigator.pop(context, false)),
                            TextButton(child: Text('yes'.tr()), style: TextButton.styleFrom(foregroundColor: Colors.red), onPressed: () => Navigator.pop(context, true)),
                        ],
                    ),
                 );
                 if (confirm == true && mounted) Navigator.pop(context);
            }
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
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
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.currency} ${widget.amount.toInt()}',
                  style: TextStyle(fontSize: 20, color: Colors.blue.shade700, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  maxWidth: 320,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade800,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 4,
                    ),
                    onPressed: () => _launchPaystack(),
                    child: Text(_status == 'INITIAL' ? 'pay_now'.tr() : 'verify_my_payment'.tr(), 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'payment_ready',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ).tr(),
                const SizedBox(height: 8),
                const Text(
                  'Secure payment powered by Paystack',
                  style: TextStyle(fontSize: 11, color: Colors.blueGrey, fontStyle: FontStyle.italic),
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
                const Text(
                  'payment_success',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
                ).tr(),
                const SizedBox(height: 12),
                const Text('payment_redirecting', textAlign: TextAlign.center).tr(),
              ] else if (_status == 'ERROR') ...[
                const Icon(Icons.error_outline, color: Colors.red, size: 80),
                const SizedBox(height: 24),
                const Text(
                  'payment_failed_desc',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ).tr(),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => _launchPaystack(),
                  child: const Text('retry_payment').tr(),
                ),
              ],
              const SizedBox(height: 60),
              const Text('Build v1.1.90 - Resilient Polling Gateway (Final Optimization)', 
                style: TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
