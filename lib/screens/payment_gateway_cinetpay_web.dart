import 'dart:convert';
import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
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
  // final String phone; // Removed as we use phoneNumber
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
  late String _viewId;
  bool _scriptLoaded = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Unique ID for the IFrame view factory
    _viewId = 'TXN${DateTime.now().millisecondsSinceEpoch}';
    _loadCinetPayScript();
  }

      // View factory code removed as we use seamless integration via script injection
      // ui_web.platformViewRegistry.registerViewFactory(_viewId, (int viewId) => html.IFrameElement()); // Method removed

  
  // Actually, for Flutter Web integrations of 3rd party JS libs that open modals,
  // it's often better to inject the script into the main document head 
  // and call the JS functions using dart:js_util.
  
  Future<void> _loadCinetPayScript() async {
    try {
      if (html.document.getElementById('cinetpay-script') != null) {
        _initializePayment();
        return;
      }

      final script = html.ScriptElement()
        ..id = 'cinetpay-script'
        ..src = 'https://cdn.cinetpay.com/seamless/main.js'
        ..type = 'text/javascript'
        ..async = true;

      final completer = Completer<void>();
      script.onLoad.listen((_) => completer.complete());
      script.onError.listen((e) => completer.completeError(e));

      html.document.head!.append(script);
      
      await completer.future;
      if (mounted) {
        setState(() {
          _scriptLoaded = true;
        });
        _initializePayment();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load payment gateway: $e';
        });
      }
    }
  }

  void _initializePayment() {
    // We'll use a delayed call to ensure the script is fully parsed
    Future.delayed(const Duration(milliseconds: 500), () {
      _triggerCheckout();
    });
  }

  void _triggerCheckout() {
    try {
      // Access the global CinetPay object
       // We use js_interop or older dart:js. Let's use basic dart:html window property for simplicity here
       // assuming CinetPay attaches to window.
              // Define the config object
        final configData = {
          'apikey': widget.apiKey,
          'site_id': int.tryParse(widget.siteId) ?? 105899723,
          'notify_url': widget.notifyUrl.isNotEmpty ? widget.notifyUrl : 'https://api.tiknetafrica.com/api/payment/notify/', // Updated to real notify if possible
          'mode': 'PRODUCTION',
        };

        // Define the payment data - Minimalist approach to let the portal handle validation
        final paymentData = {
          'transaction_id': 'T${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}', 
          'amount': widget.amount.toInt(), 
          'currency': widget.currency == 'CFA' ? 'XOF' : widget.currency,
          'channels': 'ALL',
          'description': widget.description.trim(),
          'customer_name': widget.firstName.trim().replaceAll('\'', ' '),
          'customer_surname': widget.lastName.trim().replaceAll('\'', ' '),
          'customer_email': widget.email.trim(),
          // Removing pre-filled phone/country/address/city to avoid conflict in the modal
          // Let the user choose these in the UI which is more reliable for USSD triggering
          'customer_address': "Abidjan",
          'customer_city': "Abidjan",
          'customer_country': "CI",
          'customer_state': "CI",
          'customer_zip_code': "00225",
        };

        final scriptContent = '''
          if (typeof CinetPay !== 'undefined') {
            const paymentData = ${jsonEncode(paymentData)};
            console.log("🚀 Initializing CinetPay v2...");
            console.log("📦 CinetPay Payment Data:", paymentData);
            
            CinetPay.setConfig(${jsonEncode(configData)});
            CinetPay.getCheckout(paymentData);
            
            CinetPay.waitResponse(function(data) {
              console.log("ℹ️ CinetPay Response Received:", data);
              if (data.status == "ACCEPTED") {
                window.postMessage(JSON.stringify({'type': 'cinetpay_success', 'data': data}), "*");
              } else if (data.status == "REFUSED") {
                window.postMessage(JSON.stringify({'type': 'cinetpay_error', 'data': data}), "*");
              }
            });

            // Fallback for close/cancel if detected
            window.addEventListener('message', function(event) {
               // Internal CinetPay modal might send messages we can intercept
            });
          } else {
            console.error("⚠️ CinetPay SDK not found in window");
          }
        ''';
       
       final script = html.ScriptElement()..text = scriptContent;
       html.document.body!.append(script);
       
       // Listen for messages
       html.window.onMessage.listen((event) {
          try {
            if (event.data is String) {
              // Parse basic logic checks
              if (event.data.contains('cinetpay_success')) {
                // Return success
                 Navigator.of(context).pop({'success': true, 'reference': widget.transactionId});
              } else if (event.data.contains('cinetpay_error')) {
                 Navigator.of(context).pop({'success': false, 'message': 'payment_failed_or_cancelled'.tr()});
              }
            }
          } catch (e) {
            if (kDebugMode) print('Error parsing message: $e');
          }
       });

    } catch (e) {
      if (kDebugMode) print('Error triggering checkout: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text('payment_error'.tr())),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              Text(
                'payment_error'.tr(),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(_error ?? 'Something went wrong'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('close'.tr()),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text('initializing_payment_gateway'.tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Build v1.1.59', style: TextStyle(fontSize: 10, color: Colors.grey.shade400)), // VERSION LABEL
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _launchRedirection(),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade700, foregroundColor: Colors.white),
              child: const Text('Si le portail ne s\'ouvre pas, Cliquez ici'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('cancel'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  void _launchRedirection() {
     // Trigger manual redirection as fallback if seamless hangs
     final String siteId = widget.siteId.isEmpty ? '105899723' : widget.siteId;
     final String amount = widget.amount.toInt().toString();
     final String currency = widget.currency == 'CFA' ? 'XOF' : widget.currency;
     final String transId = 'TXN${DateTime.now().millisecondsSinceEpoch}';
     
     // CinetPay payment URL (V2)
     final url = 'https://checkout.cinetpay.com/payment/$siteId?amount=$amount&currency=$currency&transaction_id=$transId&description=${Uri.encodeComponent(widget.description)}&customer_name=${Uri.encodeComponent(widget.firstName)}&customer_surname=${Uri.encodeComponent(widget.lastName)}&customer_email=${Uri.encodeComponent(widget.email)}&notify_url=${Uri.encodeComponent('https://api.tiknetafrica.com/api/payment/notify/')}';
     
     html.window.open(url, '_blank');
  }

  String _sanitizePhone(String phone, String country) {
    // Standardize to digits only
    String clean = phone.replaceAll(RegExp(r'\D'), '');
    
    // For Ivory Coast (CI), keep it as 225XXXXXXXXXX (12 chars total)
    // Most CinetPay seamless implementations expect prefix WITHOUT the '+'
    if (country.toUpperCase() == 'CI' && !clean.startsWith('225') && clean.length == 10) {
      return '225$clean';
    }
    
    return clean;
  }
}
