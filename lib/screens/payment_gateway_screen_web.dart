import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:dio/dio.dart';
import 'dart:js' as js;
import 'payment_gateway_cinetpay_web.dart';
import '../services/api/token_storage.dart';

/// Transparent Gateway Wrapper with Direct Exit logic (v1.1.99)
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
  final GlobalKey<PaymentGatewayPaystackWebState> _paystackKey = GlobalKey();

  Future<void> _forceExitApp({bool success = false, String? reference}) async {
    if (mounted && !_isExiting) {
      setState(() => _isExiting = true);
      // Wait for state to apply to satisfy PopScope
      await Future.delayed(Duration.zero);
      if (mounted) {
        Navigator.of(context).pop({
          'success': success, 
          'reference': reference,
          'message': success ? 'payment_success'.tr() : 'payment_cancelled'.tr()
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
          TextButton(
            onPressed: () {
               Navigator.of(dialogContext).pop(false);
               if (isPaystack && _paystackKey.currentState != null) {
                  _paystackKey.currentState!.reLaunch();
               }
            }, 
            child: Text('no'.tr())
          ),
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
                                 rawCountry == 'ga' || rawCountry == 'cg' || rawCountry == 'td' || rawCountry == 'gn';

    final isFrancophoneCurrency = widget.currency == 'XOF' || widget.currency == 'XAF' || widget.currency == 'GNF' || 
                                  widget.currency == 'FG' || widget.currency == 'CFA' || widget.currency.contains('CFA');

    final bool isCinetPay = isFrancophoneCurrency || isFrancophoneCountry || widget.email == 'ketiglo15@gmail.com';
    
    return PopScope(
      canPop: _isExiting,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final confirmed = await _handleManualPop(isPaystack: !isCinetPay);
        if (confirmed && mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: isCinetPay 
          ? PaymentGatewayCinetPay(
              email: widget.email,
              amount: widget.amount,
              currency: widget.currency == 'CFA' ? 'XOF' : widget.currency,
              description: 'Payment for ${widget.planName}',
              firstName: widget.userData?['firstName'] ?? '',
              lastName: widget.userData?['lastName'] ?? '',
              phoneNumber: widget.userData?['phone'] ?? '',
              onRequestClose: () => _handleManualPop(isPaystack: false).then((confirmed) {
                 if (confirmed && mounted) Navigator.of(context).pop();
              }),
              onPortalCancel: () => _forceExitApp(success: false),
            )
          : PaymentGatewayPaystackWeb(
              key: _paystackKey,
              email: widget.email,
              amount: widget.amount,
              planId: widget.planId,
              planName: widget.planName,
              currency: widget.currency,
              onRequestClose: () => _handleManualPop(isPaystack: true).then((confirmed) {
                 if (confirmed && mounted) Navigator.of(context).pop();
              }),
              onPortalCancel: () => _forceExitApp(success: false),
            ),
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
  final VoidCallback onPortalCancel;

  const PaymentGatewayPaystackWeb({
    super.key,
    required this.email,
    required this.amount,
    required this.planId,
    required this.planName,
    required this.currency,
    required this.onRequestClose,
    required this.onPortalCancel,
  });

  @override
  State<PaymentGatewayPaystackWeb> createState() => PaymentGatewayPaystackWebState();
}

class PaymentGatewayPaystackWebState extends State<PaymentGatewayPaystackWeb> {
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
       Future.delayed(const Duration(seconds: 1), () { if (mounted) Navigator.of(context).pop({'success': true, 'reference': reference}); });
    });
    js.context['onPaystackCancel'] = js.allowInterop(() {
       if (mounted) widget.onPortalCancel(); 
    });
    WidgetsBinding.instance.addPostFrameCallback((_) { _launchPaystack(); });
  }

  void reLaunch() { _launchPaystack(); }

  @override
  void dispose() { _statusTimer?.cancel(); super.dispose(); }

  void _startStatusPolling() {
    _statusTimer?.cancel();
    _statusTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (_status == 'PENDING') _checkTransactionStatus();
      else timer.cancel();
    });
  }

  Future<void> _checkTransactionStatus() async {
    if (_checkCount++ > 25) { _statusTimer?.cancel(); return; }
    try {
      final token = await TokenStorage().getAccessToken();
      final response = await Dio().get(
        'https://api.tiknetafrica.com/api/partner/subscription-plans/check/',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.data != null && response.data['is_active'] == true) {
         _statusTimer?.cancel();
         if (mounted) setState(() => _status = 'SUCCESS');
         Future.delayed(const Duration(seconds: 1), () { if (mounted) Navigator.of(context).pop({'success': true}); });
      }
    } catch (_) {}
  }

  void _launchPaystack() {
     if (mounted) setState(() => _status = 'PENDING');
     js.context.callMethod('launchPaystack', [
       js.JsObject.jsify({
         'key': 'pk_live_ba6137ee394e83ff5b0cfec596851545e1dea426',
         'email': widget.email, 'amount': (widget.amount * 100).toInt(), 'currency': widget.currency,
         'ref': _transactionId, 'planId': widget.planId, 'planName': widget.planName,
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
