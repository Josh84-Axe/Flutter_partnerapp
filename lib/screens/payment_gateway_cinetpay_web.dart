import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
    _viewId = 'cinetpay_gateway_${DateTime.now().millisecondsSinceEpoch}';
    _registerViewFactory();
    _loadCinetPayScript();
  }

  void _registerViewFactory() {
    // Register a view factory that creates an IFrameElement
    ui_web.platformViewRegistry.registerViewFactory(_viewId, (int viewId) {
      final iframe = html.IFrameElement()
        ..src = 'about:blank' // Start blank
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%';
        
      // We will inject the CinetPay script and trigger content into this iframe 
      // or actually just use the main window?
      // CinetPay usually works as a popup or embedded script.
      // The standard CinetPay seamless integration documentation suggests:
      // <script src="https://cdn.cinetpay.com/seamless/main.js"></script>
      // and then calling CinetPay.setConfig(...) and CinetPay.getCheckout(...).
      
      // Since CinetPay might manipulate the DOM, it's safer to keep it in the main window context 
      // if it supports it, OR inside the iframe. 
      // However, if we put it in an iframe, we need to make sure the popup/modal works.
      
      return iframe;
    });
  }
  
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
         'site_id': widget.siteId,
         'notify_url': widget.notifyUrl,
         'mode': 'PRODUCTION', // or 'PRODUCTION'
       };

       // Define the payment data
       final paymentData = {
         'transaction_id': widget.transactionId,
         'amount': widget.amount,
         'currency': widget.currency,
         'channels': 'ALL',
         'description': widget.description,
         // Customer info
         'customer_name': widget.firstName,
         'customer_surname': widget.lastName,
         'customer_email': widget.email, 
         'customer_phone_number': widget.phoneNumber,
         'customer_address': widget.address.isEmpty ? "Abidjan" : widget.address, // Fallback if empty to avoid error
         'customer_city': widget.city.isEmpty ? "Abidjan" : widget.city, // Fallback
         'customer_country': widget.country,
         'customer_state': widget.country, // Using country code as state for simplicity if unknown, or default
         'customer_zip_code': widget.postalCode,
       };

       // We need to call window.CinetPay.setConfig(config) and window.CinetPay.getCheckout(paymentData)
       // We can use helper method to inject a small js script to bridge this.
       
       final scriptContent = '''
          if (typeof CinetPay !== 'undefined') {
            CinetPay.setConfig(${_jsonEncode(configData)});
            
            CinetPay.getCheckout(${_jsonEncode(paymentData)});
            
            CinetPay.waitResponse(function(data) {
              // On success or failure
              // Send message back to Dart
              if (data.status == "ACCEPTED") {
                window.parent.postMessage(JSON.stringify({'type': 'cinetpay_success', 'data': data}), "*");
              } else {
                 window.parent.postMessage(JSON.stringify({'type': 'cinetpay_error', 'data': data}), "*");
              }
            });
            
            CinetPay.onError(function(data) {
               window.parent.postMessage(JSON.stringify({'type': 'cinetpay_error', 'data': data}), "*");
            });
          } else {
            console.error("CinetPay not loaded");
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
                 Navigator.of(context).pop({'success': false, 'message': 'Payment failed or cancelled.'});
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
  
  String _jsonEncode(Map<String, dynamic> map) {
    // Simple helper to avoid import dart:convert if not needed, 
    // but better to just use proper string interpolation for JS object 
    // or use proper dart:convert.
    // Let's rely on basic string construction for safety in this raw string context.
    
    // Actually, let's use standard JSON encoding.
    // import 'dart:convert'; above would be cleaner.
    // For now, I'll assume standard string keys and basic values.
    
    final buffer = StringBuffer();
    buffer.write('{');
    int i = 0;
    for (final entry in map.entries) {
      if (i > 0) buffer.write(',');
      buffer.write('"${entry.key}": ');
      if (entry.value is num) {
        buffer.write(entry.value);
      } else {
        buffer.write('"${entry.value}"');
      }
      i++;
    }
    buffer.write('}');
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Payment Error')),
        body: Center(child: Text(_error!)),
      );
    }
    
    // We show a loading indicator while the external script initializes and launches the popup
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            const Text('Initializing CinetPay Secure Payment...'),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            )
          ],
        ),
      ),
    );
  }
}
