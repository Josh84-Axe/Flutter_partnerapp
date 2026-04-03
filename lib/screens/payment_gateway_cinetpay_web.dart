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
  late String _viewId;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _transactionId = 'TXW${DateTime.now().millisecondsSinceEpoch}';
    _viewId = 'cinetpay_container_$_transactionId';
  }

  String _getPaymentUrl() {
    final String siteId = widget.siteId.isEmpty ? '105899723' : widget.siteId;
    final String apiKey = '297929662685d35c4021b02.21438964';
    final String amountValue = widget.amount.toInt().toString();
    final String currencyValue = widget.currency == 'CFA' ? 'XOF' : widget.currency;
    final String returnUrl = html.window.location.href.split('?').first;
    
    return 'https://checkout.cinetpay.com/payment/$siteId'
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
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      _injectIframe();
      _initialized = true;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('payment'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () => setState(() { _initialized = false; }),
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.orange.shade50,
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'payment_in_app_hint'.tr(),
                    style: const TextStyle(fontSize: 12, color: Colors.orange),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Center(
                // Use a standard div as an anchor for our JS iframe
                child: SizedBox(
                   width: double.infinity,
                   height: double.infinity,
                   child: HtmlElementView(viewType: _viewId),
                ),
              ),
            ),
          ),
          _buildFooterButtons(),
        ],
      ),
    );
  }

  void _injectIframe() {
     // We will use a safe registration method that doesn't trigger the compiler error
     // By using js.context to register the factory if it exists, or doing a manual DOM tie
     js.context.callMethod('eval', ["""
        (function() {
          var viewId = '$_viewId';
          var url = '${_getPaymentUrl()}';
          
          if (window._flutter_web_set_view_factory) {
            window._flutter_web_set_view_factory(viewId, function() {
              var iframe = document.createElement('iframe');
              iframe.src = url;
              iframe.style.border = 'none';
              iframe.style.width = '100%';
              iframe.style.height = '100%';
              return iframe;
            });
          } else {
             // Fallback to global registry hook if available in index.html
             if (window.registerFlutterView) {
                window.registerFlutterView(viewId, url);
             }
          }
        })();
     """]);
  }

  Widget _buildFooterButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Build v1.1.78 - In-App Mode', style: TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.security, size: 18),
              label: const Text('JE NE REÇOIS PAS LE CODE USSD ?', style: TextStyle(fontSize: 13)),
              onPressed: () {
                html.window.location.assign(_getPaymentUrl());
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue,
                side: const BorderSide(color: Colors.blue),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
