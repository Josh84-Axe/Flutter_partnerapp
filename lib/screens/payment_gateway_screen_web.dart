import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'payment_gateway_cinetpay_web.dart';
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;

/// Screen for handling Paystack inline payment popup
class PaymentGatewayScreen extends StatefulWidget {
  final String email;
  final double amount;
  final String planId;
  final String planName;
  final String currency;
  final Map<String, dynamic>? userData;

  const PaymentGatewayScreen({
    super.key,
    required this.email,
    required this.amount,
    required this.planId,
    required this.planName,
    required this.currency,
    this.userData,
  });

  @override
  State<PaymentGatewayScreen> createState() => _PaymentGatewayScreenState();
}

class _PaymentGatewayScreenState extends State<PaymentGatewayScreen> {
  late String _transactionId;

  @override
  void initState() {
    super.initState();
    // Generate a stable transaction ID for the session
    _transactionId = 'txn_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Widget build(BuildContext context) {
    // If currency is CFA (XOF or XAF), use CinetPay
    if (widget.currency == 'XOF' || widget.currency == 'XAF' || widget.currency == 'CFA') {
       final fName = widget.userData?['firstName'] ?? '';
       final lName = widget.userData?['lastName'] ?? '';
       final addr = widget.userData?['address'] ?? '';
       final city = widget.userData?['city'] ?? '';
       final country = widget.userData?['country'] ?? 'CI'; // Default or from userData
       final phone = widget.userData?['phone'] ?? '';

       return PaymentGatewayCinetPayWeb(
          apiKey: '297929662685d35c4021b02.21438964',
          siteId: '105899723',
          transactionId: _transactionId,
          amount: widget.amount,
          currency: widget.currency == 'CFA' ? 'XOF' : widget.currency,
          description: 'Payment for ${widget.planName}',
          email: widget.email,
          firstName: fName,
          lastName: lName,
          address: addr,
          city: city,
          country: country,
          phoneNumber: phone,
       );
    }

    // Default to Paystack
    return PaymentGatewayPaystackWeb(
      email: widget.email,
      amount: widget.amount,
      planId: widget.planId,
      planName: widget.planName,
      currency: widget.currency,
    );
  }
}

class PaymentGatewayPaystackWeb extends StatefulWidget {
  final String email;
  final double amount;
  final String planId;
  final String planName;
  final String currency;

  const PaymentGatewayPaystackWeb({
    super.key,
    required this.email,
    required this.amount,
    required this.planId,
    required this.planName,
    required this.currency,
  });

  @override
  State<PaymentGatewayPaystackWeb> createState() => _PaymentGatewayPaystackWebState();
}

class _PaymentGatewayPaystackWebState extends State<PaymentGatewayPaystackWeb> {
  final String _iframeId = 'paystack-payment-iframe-${DateTime.now().millisecondsSinceEpoch}';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializePaymentView();
  }

  void _initializePaymentView() {
    debugPrint('­ƒÜÇ [PaymentGateway] Initializing payment view for web...');
    debugPrint('   Email: ${widget.email}');
    debugPrint('   Amount: ${widget.amount}');
    debugPrint('   Currency: ${widget.currency}');

    // Create iframe element
    final iframe = html.IFrameElement()
      ..id = _iframeId
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%';

    // Register the iframe view
    ui_web.platformViewRegistry.registerViewFactory(
      _iframeId,
      (int viewId) => iframe,
    );

    // Set up message listener for payment response
    html.window.onMessage.listen((event) {
      debugPrint('­ƒô▒ [PaymentGateway] Message received: ${event.data}');
      
      if (event.data is String) {
        final message = event.data as String;
        if (message.contains('success')) {
          _handlePaymentResponse(message);
        }
      } else if (event.data is Map) {
        final data = event.data as Map;
        if (data['type'] == 'paystack_payment') {
          _handlePaymentResponse(data.toString());
        }
      }
    });

    // Load payment HTML into iframe
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final htmlContent = _buildPaystackHTML();
      iframe.srcdoc = htmlContent;
      
      if (mounted) {
        setState(() => _isLoading = false);
      }
      
      debugPrint('Ô£à [PaymentGateway] Payment view initialized');
    });
  }

  String _buildPaystackHTML() {
    final amountInKobo = (widget.amount * 100).toInt();
    
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment</title>
    <script src="https://js.paystack.co/v1/inline.js"></script>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        .payment-container {
            background: white;
            border-radius: 16px;
            padding: 40px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            max-width: 400px;
            width: 100%;
            text-align: center;
        }
        .plan-name {
            font-size: 24px;
            font-weight: bold;
            color: #1a202c;
            margin-bottom: 8px;
        }
        .amount {
            font-size: 36px;
            font-weight: bold;
            color: #667eea;
            margin: 16px 0;
        }
        .currency {
            font-size: 14px;
            color: #718096;
            margin-bottom: 24px;
        }
        .pay-button {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            padding: 16px 32px;
            font-size: 16px;
            font-weight: 600;
            border-radius: 8px;
            cursor: pointer;
            width: 100%;
            transition: all 0.3s ease;
        }
        .pay-button:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(102, 126, 234, 0.4);
        }
        .pay-button:active {
            transform: translateY(0);
        }
        .info {
            margin-top: 16px;
            font-size: 12px;
            color: #718096;
        }
        .loading {
            display: none;
            margin-top: 16px;
        }
        .loading.active {
            display: block;
        }
        .spinner {
            border: 3px solid #f3f3f3;
            border-top: 3px solid #667eea;
            border-radius: 50%;
            width: 40px;
            height: 40px;
            animation: spin 1s linear infinite;
            margin: 0 auto;
        }
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
    </style>
</head>
<body>
    <div class="payment-container">
        <div class="plan-name">${widget.planName}</div>
        <div class="amount">${widget.currency} ${widget.amount.toInt()}</div>
        <div class="currency">Subscription Plan</div>
        <button class="pay-button" onclick="payWithPaystack()">
            Pay Now
        </button>
        <div class="info">
            Secure payment powered by Paystack
        </div>
        <div class="loading" id="loading">
            <div class="spinner"></div>
        </div>
    </div>

    <script>
        console.log('­ƒÜÇ Payment page loaded');
        console.log('Email: ${widget.email}');
        console.log('Amount: ${widget.amount}');
        console.log('Currency: ${widget.currency}');
        
        // Check if Paystack loaded
        if (typeof PaystackPop === 'undefined') {
            console.error('ÔØî PaystackPop not loaded!');
            alert('Error: Paystack library failed to load. Please check your internet connection.');
        } else {
            console.log('Ô£à PaystackPop loaded successfully');
        }
        
        function payWithPaystack() {
            console.log('­ƒÆ│ Initiating payment...');
            
            try {
                var handler = PaystackPop.setup({
                    key: 'pk_live_ba6137ee394e83ff5b0cfec596851545e1dea426',
                    email: '${widget.email}',
                    amount: $amountInKobo,
                    currency: '${widget.currency}',
                    ref: 'PSK_' + Math.floor((Math.random() * 1000000000) + 1),
                    metadata: {
                        plan_id: '${widget.planId}',
                        plan_name: '${widget.planName}',
                        custom_fields: [
                            {
                                display_name: "Subscription Plan",
                                variable_name: "subscription_plan",
                                value: "${widget.planName}"
                            }
                        ]
                    },
                    callback: function(response) {
                        console.log('Ô£à Payment successful:', response);
                        document.getElementById('loading').classList.add('active');
                        
                        // Send success message to Flutter via postMessage
                        window.parent.postMessage(JSON.stringify({
                            success: true,
                            reference: response.reference,
                            message: 'Payment successful'
                        }), '*');
                    },
                    onClose: function() {
                        console.log('ÔÜá´©Å Payment popup closed');
                        
                        // Send cancellation message to Flutter
                        window.parent.postMessage(JSON.stringify({
                            success: false,
                            message: 'Payment cancelled'
                        }), '*');
                    }
                });
                
                console.log('­ƒÄ» Opening Paystack iframe...');
                handler.openIframe();
            } catch (error) {
                console.error('ÔØî Error in payWithPaystack:', error);
                alert('Error: ' + error.message);
            }
        }
        
        // Auto-trigger payment on page load
        window.onload = function() {
            console.log('­ƒôä Window loaded, triggering payment in 1 second...');
            setTimeout(function() {
                payWithPaystack();
            }, 1000);
        };
    </script>
</body>
</html>
    ''';
  }

  void _handlePaymentResponse(String message) {
    try {
      debugPrint('­ƒÆ¼ [PaymentGateway] Processing payment response: $message');
      
      // Close the screen and return the result
      if (message.contains('"success":true')) {
        // Extract reference from JSON
        final referenceMatch = RegExp(r'"reference":"([^"]+)"').firstMatch(message);
        final reference = referenceMatch?.group(1);
        
        if (reference != null) {
          debugPrint('Ô£à [PaymentGateway] Payment successful with reference: $reference');
          Navigator.pop(context, {
            'success': true,
            'reference': reference,
          });
        }
      } else {
        debugPrint('ÔÜá´©Å [PaymentGateway] Payment cancelled or failed');
        Navigator.pop(context, {
          'success': false,
          'message': 'Payment cancelled',
        });
      }
    } catch (e) {
      debugPrint('ÔØî [PaymentGateway] Error parsing payment response: $e');
      Navigator.pop(context, {
        'success': false,
        'message': 'Error processing payment',
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('payment'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('cancel_payment'.tr()),
                content: const Text('Are you sure you want to cancel this payment?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('no'.tr()),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(context, {
                        'success': false,
                        'message': 'Payment cancelled by user',
                      });
                    },
                    child: Text('yes'.tr(), style: const TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: Stack(
        children: [
          HtmlElementView(viewType: _iframeId),
          
          if (_isLoading)
            Container(
              color: Colors.white,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
