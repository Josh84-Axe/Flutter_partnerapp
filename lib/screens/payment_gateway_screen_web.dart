import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:dio/dio.dart';
import 'dart:js' as js;
import 'payment_gateway_cinetpay_web.dart';
import '../services/api/token_storage.dart';

/// Unified Screen for handling Payment Gateways on Web
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

  Future<bool> _handlePop() async {
    if (_isExiting) return true;
    
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text('cancel_payment'.tr()),
        content: Text('cancel_payment_confirm'.tr()),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text('no'.tr())),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('yes'.tr()),
          ),
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
    final rawCountry = widget.userData?['country']?.toString()?.toLowerCase() ?? '';
    final isFrancophoneCountry = rawCountry == 'ci' || rawCountry == 'sn' || rawCountry == 'ml' || rawCountry == 'bj' || 
                                 rawCountry == 'bf' || rawCountry == 'ne' || rawCountry == 'tg' || rawCountry == 'cm' || 
                                 rawCountry == 'ga' || rawCountry == 'cg' || rawCountry == 'td' || rawCountry == 'gn' ||
                                 rawCountry.contains('ivoire') || rawCountry.contains('senegal');

    final isFrancophoneCurrency = widget.currency == 'XOF' || widget.currency == 'XAF' || widget.currency == 'GNF' || 
                                  widget.currency == 'FG' || widget.currency == 'CFA' || widget.currency.contains('CFA');

    final bool isCinetPay = isFrancophoneCurrency || isFrancophoneCountry || widget.email == 'ketiglo15@gmail.com';
    
    return PopScope(
      canPop: _isExiting,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final confirmed = await _handlePop();
        if (confirmed && mounted) Navigator.of(context).pop();
      },
      child: isCinetPay 
        ? PaymentGatewayCinetPay(
            email: widget.email,
            amount: widget.amount,
            currency: widget.currency == 'CFA' ? 'XOF' : widget.currency,
            description: 'Payment for ${widget.planName}',
            firstName: widget.userData?['firstName'] ?? '',
            lastName: widget.userData?['lastName'] ?? '',
            phoneNumber: widget.userData?['phone'] ?? '',
            onRequestClose: () => _handlePop().then((conf) { if (conf && mounted) Navigator.of(context).pop(); }),
          )
        : PaymentGatewayPaystackWeb(
            email: widget.email,
            amount: widget.amount,
            planId: widget.planId,
            planName: widget.planName,
            currency: widget.currency,
            onRequestClose: () => _handlePop().then((conf) { if (conf && mounted) Navigator.of(context).pop(); }),
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
  final VoidCallback onRequestClose;

  const PaymentGatewayPaystackWeb({
    super.key,
    required this.email,
    required this.amount,
    required this.planId,
    required this.planName,
    required this.currency,
    required this.onRequestClose,
  });

  @override
  State<PaymentGatewayPaystackWeb> createState() => _PaymentGatewayPaystackWebState();
}

class _PaymentGatewayPaystackWebState extends State<PaymentGatewayPaystackWeb> {
  late String _transactionId;
  String _status = 'INITIAL';
  Timer? _statusTimer;
  int _checkCount = 0;

  @override
  void initState() {
    super.initState();
    _transactionId = 'PSK${DateTime.now().millisecondsSinceEpoch}';
    js.context['onPaystackSuccess'] = js.allowInterop((reference) {
      if (mounted) setState(() => _status = 'SUCCESS');
      Future.delayed(const Duration(seconds: 2), () { if (mounted) Navigator.of(context).pop({'success': true}); });
    });
    js.context['onPaystackCancel'] = js.allowInterop(() { if (mounted) setState(() => _status = 'INITIAL'); });
    
    // Auto-launch Paystack
    WidgetsBinding.instance.addPostFrameCallback((_) { _launchPaystack(); });
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
    if (_checkCount++ > 20) { _statusTimer?.cancel(); return; }
    try {
      final token = await TokenStorage().getAccessToken();
      final response = await Dio().get(
        'https://api.tiknetafrica.com/api/partner/subscription-plans/check/',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.data != null && response.data['is_active'] == true) {
         _statusTimer?.cancel();
         if (mounted) setState(() => _status = 'SUCCESS');
         Future.delayed(const Duration(seconds: 2), () { if (mounted) Navigator.of(context).pop({'success': true}); });
      }
    } catch (_) {}
  }

  void _launchPaystack() {
     if (mounted) setState(() => _status = 'PENDING');
     js.context.callMethod('launchPaystack', [
       js.JsObject.jsify({
         'key': 'pk_live_ba6137ee394e83ff5b0cfec596851545e1dea426',
         'email': widget.email,
         'amount': (widget.amount * 100).toInt(),
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
              Text(widget.planName, style: const TextStyle(fontWeight: FontWeight.bold)),
            ] else if (_status == 'SUCCESS') ...[
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 24),
              const Text('payment_success', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)).tr(),
            ] else if (_status == 'ERROR') ...[
              const Icon(Icons.error_outline, color: Colors.red, size: 80),
              const SizedBox(height: 24),
              const Text('payment_failed_desc', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)).tr(),
              const SizedBox(height: 32),
              ElevatedButton(onPressed: () => _launchPaystack(), child: const Text('retry_payment').tr()),
            ],
            const SizedBox(height: 60),
            const Text('Build v1.1.95 - Seamless Integrated Gateway', style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
