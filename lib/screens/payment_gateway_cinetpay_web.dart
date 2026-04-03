import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
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

    // Auto-launch the official SDK Modal
    WidgetsBinding.instance.addPostFrameCallback((_) => _launchOfficialSDK());
  }

  void _launchOfficialSDK() {
    final String siteId = widget.siteId.isEmpty ? '105899723' : widget.siteId;
    final String apiKey = '297929662685d35c4021b02.21438964';
    final String returnUrl = html.window.location.href.split('?').first;
    
    if (mounted) setState(() { _status = 'PENDING'; });

    // Calling the native helper defined in index.html
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
              if (_status == 'PENDING') ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 24),
                const Text(
                  'Finalisation du tunnel de paiement sécurisé...',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Le portail officiel CinetPay va apparaître dans un instant.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ] else if (_status == 'SUCCESS') ...[
                const Icon(Icons.check_circle, color: Colors.green, size: 80),
                const SizedBox(height: 24),
                const Text(
                  'Paiement Réussi !',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
                ),
                const SizedBox(height: 8),
                const Text('Redirection vers votre tableau de bord...'),
              ] else if (_status == 'ERROR') ...[
                const Icon(Icons.error_outline, color: Colors.red, size: 80),
                const SizedBox(height: 24),
                const Text(
                  'Le paiement n\'a pas pu aboutir.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _launchOfficialSDK(),
                  child: const Text('Réessayer le paiement'),
                ),
              ],
              const SizedBox(height: 48),
              const Text('Build v1.1.80 - Documentation Standard (SDK Official)', style: TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
