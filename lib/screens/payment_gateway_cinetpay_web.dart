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
    
    // Crucial: Ensure the app returns to exactly this dashboard after payment
    final String currentUrl = html.window.location.href;
    final String returnUrl = currentUrl.contains('?') ? currentUrl.split('?').first : currentUrl;
    
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
    
    debugPrint('🛡️ [CinetPayWeb] Full-Page Redirection for Crucial Visibility (v1.1.76)...');
    
    try {
      // Direct same-tab navigation to guarantee USSD/OTP screen delivery
      html.window.location.assign(url);
    } catch (e) {
       debugPrint('⚠️ [CinetPayWeb] Redirection Error: $e. Using fallback...');
       html.window.location.href = url;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('payment'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_problem),
            tooltip: 'Hard Reset Cache',
            onPressed: () {
              html.window.localStorage.clear();
              html.window.location.reload();
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_person, size: 80, color: Colors.blue),
            const SizedBox(height: 32),
            Text('redirecting_to_cinetpay'.tr(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('Build v1.1.76 - Crucial Visibility Mode', style: TextStyle(fontSize: 10, color: Colors.grey)),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'payment_crucial_instruction'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.blueGrey, fontSize: 16),
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: 280,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => _startPayment(),
                child: const Text('VOIR LA PAGE DE VALIDATION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Redirection sécurisée (Même onglet)', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 40),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('cancel'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
