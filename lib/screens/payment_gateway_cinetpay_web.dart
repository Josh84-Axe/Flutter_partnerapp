import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class PaymentGatewayCinetPayWeb extends StatefulWidget {
  final String apiKey;
  final String siteId;
  final String transactionId;
  final double amount;
  final String currency;
  final String description;
  final String email;
  final String address;
  final String city;
  final String country;
  final String firstName;
  final String lastName;
  final String notifyUrl;
  final String postalCode;
  final String phoneNumber;

  const PaymentGatewayCinetPayWeb({
    super.key,
    required this.apiKey,
    required this.siteId,
    required this.transactionId,
    required this.amount,
    required this.currency,
    required this.description,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.address,
    required this.city,
    required this.country,
    this.postalCode = '00000',
    this.phoneNumber = '',
    this.notifyUrl = '',
  });

  @override
  State<PaymentGatewayCinetPayWeb> createState() => _PaymentGatewayCinetPayWebState();
}

class _PaymentGatewayCinetPayWebState extends State<PaymentGatewayCinetPayWeb> {
  late String _transactionId;

  @override
  void initState() {
    super.initState();
    // Use a clean transaction ID immediately
    _transactionId = 'TX1${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';
    // Auto-launch redirection in the next frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _launchRedirection());
  }

  void _launchRedirection() {
    final String siteId = widget.siteId.isEmpty ? '105899723' : widget.siteId;
    final String amountValue = widget.amount.toInt().toString();
    final String currencyValue = widget.currency == 'CFA' ? 'XOF' : widget.currency;
    
    // CinetPay Redirection URL (Most stable for USSD/Wave/Mobile Money)
    final url = 'https://checkout.cinetpay.com/payment/$siteId'
                '?amount=$amountValue'
                '&currency=$currencyValue'
                '&transaction_id=$_transactionId'
                '&description=${Uri.encodeComponent(widget.description)}'
                '&customer_name=${Uri.encodeComponent(widget.firstName)}'
                '&customer_surname=${Uri.encodeComponent(widget.lastName)}'
                '&customer_email=${Uri.encodeComponent(widget.email)}'
                '&customer_phone_number=${Uri.encodeComponent(widget.phoneNumber)}'
                '&customer_address=Abidjan'
                '&customer_city=Abidjan'
                '&customer_country=CI'
                '&customer_state=CI'
                '&customer_zip_code=00225'
                '&notify_url=${Uri.encodeComponent('https://api.tiknetafrica.com/api/payment/notify/')}';
    
    html.window.open(url, '_self'); // Use _self to replace current page for stability
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
            const Text('Build v1.1.60', style: TextStyle(fontSize: 10, color: Colors.grey)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _launchRedirection(),
              child: const Text('Si vous n\'êtes pas redirigé, cliquez ici'),
            ),
          ],
        ),
      ),
    );
  }
}
