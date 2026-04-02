import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
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
  bool _isInit = false;
  late String _transactionId;

  @override
  void initState() {
    super.initState();
    _transactionId = 'TXW${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      _loadCinetPayScript();
      _isInit = true;
    }
  }

  void _loadCinetPayScript() {
    // Check if script already exists
    if (html.document.getElementById('cinetpay-js') != null) {
       _startCheckout();
       return;
    }

    final script = html.ScriptElement()
      ..id = 'cinetpay-js'
      ..src = 'https://cdn.cinetpay.com/seamless/main.js'
      ..type = 'text/javascript';

    script.onLoad.listen((_) {
      _startCheckout();
    });

    html.document.head!.append(script);
  }

  void _startCheckout() {
    try {
      final String apiKey = '297929662685d35c4021b02.21438964';
      final String siteId = widget.siteId.isEmpty ? '105899723' : widget.siteId;
      
      // Ensure JS side is configured
      js.context.callMethod('eval', ["""
        window.startCinetPayCheckout = function(config, checkoutData) {
          try {
            CinetPay.setConfig({
              apikey: config.apiKey,
              site_id: config.siteId,
              notify_url: 'https://api.tiknetafrica.com/api/payment/notify/',
              mode: 'PRODUCTION'
            });
            
            CinetPay.getCheckout({
              transaction_id: checkoutData.transId,
              amount: checkoutData.amount,
              currency: checkoutData.currency,
              channels: 'ALL',
              description: checkoutData.description,
              customer_name: checkoutData.firstName,
              customer_surname: checkoutData.lastName,
              customer_email: checkoutData.email,
              customer_phone_number: checkoutData.phone,
              customer_address: 'Abidjan',
              customer_city: 'Abidjan',
              customer_country: 'CI',
              customer_state: 'CI',
              customer_zip_code: '00225'
            });
            
            CinetPay.waitResponse(function(data) {
              if (data.status == "ACCEPTED") {
                window.parent.postMessage({type: 'CINETPAY_SUCCESS', data: data}, '*');
              } else {
                window.parent.postMessage({type: 'CINETPAY_ERROR', data: data}, '*');
              }
            });
            
            CinetPay.onError(function(data) {
              window.parent.postMessage({type: 'CINETPAY_ERROR', data: data}, '*');
            });
          } catch (e) {
            console.error('CinetPay JS Error:', e);
          }
        }
      """]);

      // Call the JS function
      js.context.callMethod('startCinetPayCheckout', [
        js.JsObject.jsify({
          'apiKey': apiKey,
          'siteId': siteId,
        }),
        js.JsObject.jsify({
          'transId': _transactionId,
          'amount': widget.amount.toInt(),
          'currency': widget.currency == 'CFA' ? 'XOF' : widget.currency,
          'description': widget.description,
          'firstName': widget.firstName,
          'lastName': widget.lastName,
          'email': widget.email,
          'phone': widget.phoneNumber,
        })
      ]);

      // Listen for the cross-window message from the JS SDK
      html.window.onMessage.listen((event) {
        if (event.data is Map) {
          final type = event.data['type'];
          if (type == 'CINETPAY_SUCCESS') {
            if (mounted) Navigator.pop(context, {'success': true, 'reference': _transactionId});
          } else if (type == 'CINETPAY_ERROR') {
            if (mounted) Navigator.pop(context, {'success': false, 'message': 'Payment failed'});
          }
        }
      });

    } catch (e) {
      debugPrint('❌ [CinetPayWeb] SDK Error: $e');
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
            const Text('Build v1.1.70 - Seamless Mode', style: TextStyle(fontSize: 10, color: Colors.grey)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _startCheckout(),
              child: const Text('Ressayer le paiement'),
            ),
          ],
        ),
      ),
    );
  }
}
