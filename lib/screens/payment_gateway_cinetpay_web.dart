import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:html' as html;

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
  html.WindowBase? _popup;

  @override
  void initState() {
    super.initState();
    _transactionId = 'TXW${DateTime.now().millisecondsSinceEpoch}';
    // Auto-launch redirection in a popup
    WidgetsBinding.instance.addPostFrameCallback((_) => _startPayment());
  }

  void _startPayment() {
    final String siteId = widget.siteId.isEmpty ? '105899723' : widget.siteId;
    final String apiKey = '297929662685d35c4021b02.21438964';
    final String amountValue = widget.amount.toInt().toString();
    final String currencyValue = widget.currency == 'CFA' ? 'XOF' : widget.currency;
    
    // We point return_url to a special "success close" handler or just back to app
    final String returnUrl = html.window.location.href.split('?').first;
    
    final url = 'https://checkout.cinetpay.com/payment/$siteId'
                '?apikey=$apiKey'
                '&amount=$amountValue'
                '&currency=$currencyValue'
                '&transaction_id=$_transactionId'
                '&description=${Uri.encodeComponent(widget.description)}'
                '&return_url=${Uri.encodeComponent(returnUrl)}'
                '&notify_url=${Uri.encodeComponent('https://api.tiknetafrica.com/api/payment/notify/')}'
                '&customer_name=${Uri.encodeComponent(widget.firstName)}'
                '&customer_surname=${Uri.encodeComponent(widget.lastName)}'
                '&customer_email=${Uri.encodeComponent(widget.email)}'
                '&customer_phone_number=${Uri.encodeComponent(widget.phoneNumber)}'
                '&customer_address=Abidjan'
                '&customer_city=Abidjan'
                '&customer_country=CI'
                '&customer_state=CI'
                '&customer_zip_code=00225';
    
    // Open in a focused popup window (width 500, height 800) to keep main app active
    _popup = html.window.open(url, 'CinetPayPayment', 'width=500,height=800,scrollbars=yes,resizable=yes');
    
    if (_popup == null) {
      debugPrint('❌ [CinetPayWeb] Popup was blocked!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('payment'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text('redirecting_to_cinetpay'.tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Build v1.1.72 - Popup Mode', style: TextStyle(fontSize: 10, color: Colors.grey)),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'payment_popup_instruction'.tr(fallback: 'Une fenêtre de paiement s\'est ouverte. Veuillez finaliser votre transaction là-bas. Ne fermez pas cette page.'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _startPayment(),
              child: const Text('Ressayer le paiement (Ouvrir Pop-up)'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context, {'success': true, 'reference': _transactionId}),
              child: const Text('J\'ai terminé le paiement'),
            ),
          ],
        ),
      ),
    );
  }
}
