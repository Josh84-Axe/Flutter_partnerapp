import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

class PaymentGatewayCinetPay extends StatefulWidget {
  final String email;
  final double amount;
  final String currency;
  final String description;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String address;
  final String city;
  final String country;
  final VoidCallback onRequestClose;
  final Function(bool, String?, String?) onResult;

  const PaymentGatewayCinetPay({
    super.key,
    required this.email,
    required this.amount,
    required this.currency,
    required this.description,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.address,
    required this.city,
    required this.country,
    required this.onRequestClose,
    required this.onResult,
  });

  @override
  State<PaymentGatewayCinetPay> createState() => _PaymentGatewayCinetPayState();
}

class _PaymentGatewayCinetPayState extends State<PaymentGatewayCinetPay> {
  @override
  void initState() {
    super.initState();
    
    // Set up global callbacks for CinetPay
    globalContext.setProperty('onPaymentSuccess'.toJS, ((JSString transactionId) {
      if (mounted) {
        widget.onResult(true, transactionId.toDart, 'payment_success'.tr());
      }
    }).toJS);
    
    globalContext.setProperty('onPaymentError'.toJS, ((JSAny data) {
      if (mounted) {
        widget.onResult(false, null, 'payment_failed'.tr());
      }
    }).toJS);
    
    _launchCinetPay();
  }

  void _launchCinetPay() {
    try {
      final jsData = JSObject();
      jsData.setProperty('amount'.toJS, widget.amount.toJS);
      jsData.setProperty('currency'.toJS, widget.currency.toJS);
      jsData.setProperty('description'.toJS, widget.description.toJS);
      jsData.setProperty('email'.toJS, widget.email.toJS);
      jsData.setProperty('firstName'.toJS, widget.firstName.toJS);
      jsData.setProperty('lastName'.toJS, widget.lastName.toJS);
      jsData.setProperty('phone'.toJS, widget.phoneNumber.toJS);
      jsData.setProperty('address'.toJS, widget.address.toJS);
      jsData.setProperty('city'.toJS, widget.city.toJS);
      jsData.setProperty('country'.toJS, widget.country.toJS);

      globalContext.callMethod('launchCinetPay'.toJS, jsData);
    } catch (e) {
      debugPrint('Error launching CinetPay: $e');
      widget.onResult(false, null, 'error_launching_payment'.tr());
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
