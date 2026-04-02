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
    
    // We point return_url to exactly this app's current screen
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
    
    debugPrint('🚀 [CinetPayWeb] Attempting Pay-in-App via Secure Window...');
    
    try {
      // 1. Try a new tab/window first (Best for Desktop & Mobile Browser)
      _popup = html.window.open(url, '_blank');
      
      // 2. Check if popup was blocked by mobile safari/chrome
      if (_popup == null || _popup!.closed!) {
        debugPrint('⚠️ [CinetPayWeb] Popup BLOCKED. Falling back to direct redirection (HARDENER v2)');
        // Last-resort fail-safe for PWA standalone mode and aggressive mobile browsers
        html.window.location.replace(url); 
      }
    } catch (e) {
       debugPrint('⚠️ [CinetPayWeb] Redirection Error: $e. Falling back...');
       html.window.location.assign(url);
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
            const Icon(Icons.verified_user, size: 60, color: Colors.green),
            const SizedBox(height: 24),
            Text('redirecting_to_cinetpay'.tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Build v1.1.75 - Hardened Terminal (Final)', style: TextStyle(fontSize: 10, color: Colors.grey)),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'payment_hardened_instruction'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.blueGrey),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 250,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _startPayment(),
                child: const Text('PAYER MAINTENANT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 32),
            TextButton(
              onPressed: () => Navigator.pop(context, {'success': true, 'reference': _transactionId}),
              child: const Text('Confirmer le retour après paiement'),
            ),
            const SizedBox(height: 16),
            const Text('Compatible: Orange, MTN, Wave, Card, USSD', style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
