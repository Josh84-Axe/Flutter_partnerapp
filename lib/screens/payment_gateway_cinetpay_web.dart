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
  late String _paymentUrl;

  @override
  void initState() {
    super.initState();
    _transactionId = 'TXW${DateTime.now().millisecondsSinceEpoch}';
    _viewId = 'cinetpay-view-$_transactionId';
    _paymentUrl = _getPaymentUrl();
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
    // Ensuring our JS registry hook is ready
    js.context.callMethod('eval', ["""
      (function() {
        var viewId = '$_viewId';
        if (!window._flutter_web_set_view_factory) return;
        
        window._flutter_web_set_view_factory(viewId, function() {
          var iframe = document.createElement('iframe');
          iframe.src = '$_paymentUrl';
          iframe.style.width = '100%';
          iframe.style.height = '100%';
          iframe.style.border = 'none';
          iframe.id = '$_viewId-frame';
          return iframe;
        });
      })();
    """]);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('payment'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser le paiement',
            onPressed: () => setState(() { 
              _transactionId = 'TXW${DateTime.now().millisecondsSinceEpoch}';
              _viewId = 'cinetpay-view-$_transactionId';
              _paymentUrl = _getPaymentUrl();
            }),
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                const Icon(Icons.shield, color: Colors.blue, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'payment_in_app_instruction'.tr(),
                    style: TextStyle(fontSize: 11, color: Colors.blue.shade800),
                  ),
                ),
                Text('Build v1.1.79', style: TextStyle(fontSize: 9, color: Colors.blue.shade300)),
              ],
            ),
          ),
          Expanded(
            child: HtmlElementView(viewType: _viewId),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200))
            ),
            child: Center(
              child: Text(
                'Entrez votre numéro et validez la confirmation USSD sur votre téléphone.',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
