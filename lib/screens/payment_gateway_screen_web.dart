import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:dio/dio.dart';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'payment_gateway_cinetpay_web.dart';
import '../services/api/token_storage.dart';
import '../services/api/api_config.dart';

/// Sealed Gateway Wrapper with Unified Response Logic (v1.1.103)
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

  /// Unified finalizer ensures consistent results for SubscriptionManagementScreen
  Future<void> _finalize({required bool success, String? reference, String? message, String? provider}) async {
    if (mounted && !_isExiting) {
      setState(() => _isExiting = true);
      await Future.delayed(Duration.zero);
      if (mounted) {
        final rawCountry = (widget.userData?['country']?.toString() ?? '').toLowerCase().trim();
        final defaultProvider = (rawCountry == 'tg' || rawCountry == 'togo') ? 'paygate' : 'paystack';
        Navigator.of(context).pop({
          'success': success, 
          'reference': reference,
          'provider': provider ?? defaultProvider,
          'message': message ?? (success ? 'payment_success'.tr() : 'payment_cancelled'.tr())
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
    final rawCountry = (widget.userData?['country']?.toString() ?? '').toLowerCase().trim();
    final currencyUpper = widget.currency.trim().toUpperCase();

    // Togo (TG) routes directly to PayGate Global (Flooz & T-Money)
    final bool isPayGate = rawCountry == 'tg' || rawCountry == 'togo';

    // Other non-Paystack francophone countries
    final bool isCinetPay = !isPayGate && 
                            (rawCountry == 'cm' || rawCountry == 'ga' || rawCountry == 'cg' || rawCountry == 'td' || rawCountry == 'gn') &&
                            (rawCountry != 'ci' && rawCountry != 'cote d\'ivoire' && rawCountry != 'côte d\'ivoire' && rawCountry != 'ivory coast');
    
    return PopScope(
      canPop: _isExiting,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final confirmed = await _handleManualPop(isPaystack: !isCinetPay && !isPayGate);
        if (confirmed && mounted) context.pop();
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: isPayGate
            ? PaymentGatewayPaygateWeb(
                email: widget.email,
                amount: widget.amount,
                planId: widget.planId,
                planName: widget.planName,
                currency: widget.currency == 'CFA' ? 'XOF' : widget.currency,
                userData: widget.userData,
                onRequestClose: () => _handleManualPop(isPaystack: false).then((confirmed) {
                  if (confirmed && mounted) context.pop();
                }),
                onResult: (success, reference, message) => _finalize(
                  success: success, 
                  reference: reference, 
                  message: message,
                  provider: 'paygate',
                ),
              )
            : isCinetPay 
                ? PaymentGatewayCinetPay(
                    email: widget.email,
                    amount: widget.amount,
                    currency: widget.currency == 'CFA' ? 'XOF' : widget.currency,
                    description: 'Payment for ${widget.planName}',
                    firstName: widget.userData?['firstName'] ?? '',
                    lastName: widget.userData?['lastName'] ?? '',
                    phoneNumber: widget.userData?['phone'] ?? '',
                    address: widget.userData?['address'] ?? 'Main Street',
                    city: widget.userData?['city'] ?? 'Lomé',
                    country: widget.userData?['country'] ?? 'TG',
                    onRequestClose: () => _handleManualPop(isPaystack: false).then((confirmed) {
                     if (confirmed && mounted) context.pop();
                  }),
                  onResult: (success, reference, message) => _finalize(
                    success: success, 
                    reference: reference, 
                    message: message,
                    provider: 'cinetpay',
                  ),
                )
              : PaymentGatewayPaystackWeb(
                  key: _paystackKey,
                  email: widget.email,
                  amount: widget.amount,
                  planId: widget.planId,
                  planName: widget.planName,
                  currency: widget.currency,
                  userData: widget.userData,
                  onRequestClose: () => _handleManualPop(isPaystack: true).then((confirmed) {
                     if (confirmed && mounted) context.pop();
                  }),
                  onResult: (success, reference, message) => _finalize(
                    success: success, 
                    reference: reference, 
                    message: message,
                    provider: 'paystack',
                  ),
                ),
      ),
    );
  }
}

/// Dedicated PayGate Global Web Widget for Togo (Flooz & T-Money)
class PaymentGatewayPaygateWeb extends StatefulWidget {
  final String email;
  final double amount;
  final String planId;
  final String planName;
  final String currency;
  final Map<String, dynamic>? userData;
  final VoidCallback onRequestClose;
  final Function(bool success, String? reference, String? message) onResult;

  const PaymentGatewayPaygateWeb({
    super.key,
    required this.email,
    required this.amount,
    required this.planId,
    required this.planName,
    required this.currency,
    this.userData,
    required this.onRequestClose,
    required this.onResult,
  });

  @override
  State<PaymentGatewayPaygateWeb> createState() => _PaymentGatewayPaygateWebState();
}

class _PaymentGatewayPaygateWebState extends State<PaymentGatewayPaygateWeb> {
  late String _transactionId;
  bool _isProcessing = false;
  late String _paygateUrl;

  @override
  void initState() {
    super.initState();
    _transactionId = 'PG_${DateTime.now().millisecondsSinceEpoch}';
    final authToken = '6c5c6f12-4904-4f0b-a859-15ef4631bc6f';
    final amountInt = widget.amount.toInt();
    final desc = Uri.encodeComponent('Abonnement ${widget.planName}');
    
    _paygateUrl = 'https://paygateglobal.com/v1/page?token=$authToken&amount=$amountInt&description=$desc&identifier=$_transactionId';

    // Auto-open PayGate popup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openPaygateWindow();
    });
  }

  void _openPaygateWindow() {
    try {
      globalContext.callMethod('open'.toJS, _paygateUrl.toJS, 'PayGate_Togo'.toJS, 'width=520,height=720'.toJS);
    } catch (e) {
      debugPrint('Could not open PayGate window: $e');
    }
  }

  void _confirmPaymentDone() {
    setState(() => _isProcessing = true);
    widget.onResult(true, _transactionId, 'payment_success'.tr());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amountFormatted = '${widget.amount.toInt()} F.CFA';

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(28),
        constraints: const BoxConstraints(maxWidth: 440),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // PayGate Header Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF15A24).withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🇹🇬 ', style: TextStyle(fontSize: 18)),
                  const Text(
                    'PAYGATE GLOBAL TOGO',
                    style: TextStyle(
                      color: Color(0xFFF15A24),
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text(
              widget.planName,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A2B49),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              amountFormatted,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: const Color(0xFFF15A24),
              ),
            ),
            const SizedBox(height: 16),

            // Networks Supported Box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Color(0xFF00A859),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'T-Money (Togocom)',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Color(0xFF005BAA),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Flooz (Moov)',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Instructions
            Text(
              'Validez le paiement sur la fenêtre PayGate Global ou saisissez votre numéro Flooz / T-Money.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 24),

            // Open PayGate Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _openPaygateWindow,
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text('Ouvrir la fenêtre PayGate'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1A2B49),
                  side: const BorderSide(color: Color(0xFF1A2B49), width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Confirm Done Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: _isProcessing ? null : _confirmPaymentDone,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFF15A24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text(
                        'J\'ai validé le paiement sur mon téléphone',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
              ),
            ),
            const SizedBox(height: 12),

            TextButton(
              onPressed: widget.onRequestClose,
              child: Text(
                'Annuler le paiement',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ),
          ],
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
  final Map<String, dynamic>? userData;
  final VoidCallback onRequestClose;
  final Function(bool success, String? reference, String? message) onResult;

  const PaymentGatewayPaystackWeb({
    super.key,
    required this.email,
    required this.amount,
    required this.planId,
    required this.planName,
    required this.currency,
    this.userData,
    required this.onRequestClose,
    required this.onResult,
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
    
    globalContext.setProperty('onPaystackSuccess'.toJS, ((JSString reference) {
       if (mounted) setState(() => _status = 'SUCCESS');
       Future.delayed(const Duration(seconds: 1), () { 
          if (mounted) widget.onResult(true, reference.toDart, 'payment_success'.tr());
       });
    }).toJS);
    
    globalContext.setProperty('onPaystackCancel'.toJS, (() {
       if (mounted) widget.onResult(false, null, 'payment_cancelled'.tr()); 
    }).toJS);
    
    WidgetsBinding.instance.addPostFrameCallback((_) { _launchPaystack(); });
  }

  void reLaunch() { _launchPaystack(); }

  @override
  void dispose() { _statusTimer?.cancel(); super.dispose(); }

  void _launchPaystack() {
     if (mounted) setState(() => _status = 'PENDING');
     
     final jsData = JSObject();
     final currencyUpper = widget.currency.trim().toUpperCase();
     final rawCountry = (widget.userData?['country']?.toString() ?? '').toLowerCase().trim();

     // Determine Paystack Gateway Key & Target Currency with strict country mapping
     String paystackKey;
     String targetCurrency;

     final isCI = rawCountry == 'ci' || rawCountry == 'cote d\'ivoire' || rawCountry == 'côte d\'ivoire' || rawCountry == 'ivory coast';
     final isTG = rawCountry == 'tg' || rawCountry == 'togo';
     final isFrancophoneXOF = isCI || isTG || rawCountry == 'bj' || rawCountry == 'sn' || rawCountry == 'bf' || rawCountry == 'ml' || rawCountry == 'ne' || currencyUpper == 'XOF' || currencyUpper == 'CFA' || currencyUpper.contains('CFA');
     final isNG = rawCountry == 'ng' || rawCountry == 'nigeria' || currencyUpper == 'NGN';

     if (isFrancophoneXOF) {
       paystackKey = 'pk_live_0cf935a263256e6a1f8e9d59bb33b6c252691d75'; // Paystack WAEMU XOF Live Key (CI/TG/BJ/SN/BF/ML/NE)
       targetCurrency = 'XOF';
     } else if (isNG) {
       paystackKey = 'pk_live_17ec7671a46b89cb2cc5314eb69e93d21e9afa9e'; // Paystack Nigeria Live Key
       targetCurrency = 'NGN';
     } else {
       paystackKey = 'pk_live_ba6137ee394e83ff5b0cfec596851545e1dea426'; // Paystack Ghana Live Key
       targetCurrency = 'GHS';
     }

     final validEmail = (widget.email.trim().isNotEmpty && widget.email.contains('@')) ? widget.email.trim() : 'dematexperts@gmail.com';
     jsData.setProperty('key'.toJS, paystackKey.toJS);
     jsData.setProperty('email'.toJS, validEmail.toJS);
     jsData.setProperty('amount'.toJS, (widget.amount * 100).toInt().toJS);
     jsData.setProperty('currency'.toJS, targetCurrency.toJS);
     jsData.setProperty('ref'.toJS, _transactionId.toJS);
     jsData.setProperty('planId'.toJS, widget.planId.toJS);
     jsData.setProperty('planName'.toJS, widget.planName.toJS);

     globalContext.callMethod('launchPaystack'.toJS, jsData);
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
