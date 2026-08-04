//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'purchase_subscription.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PurchaseSubscription {
  /// Returns a new [PurchaseSubscription] instance.
  PurchaseSubscription({

    required  this.subscriptionPlanId,

    required  this.paymentReference,

     this.paymentProvider,
  });

  @JsonKey(
    
    name: r'subscription_plan_id',
    required: true,
    includeIfNull: false
  )


  final int subscriptionPlanId;



  @JsonKey(
    
    name: r'payment_reference',
    required: true,
    includeIfNull: false
  )


  final String paymentReference;



  @JsonKey(
    defaultValue: 'paystack',
    name: r'payment_provider',
    required: false,
    includeIfNull: false
  )


  final PurchaseSubscriptionPaymentProviderEnum? paymentProvider;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PurchaseSubscription &&
      other.subscriptionPlanId == subscriptionPlanId &&
      other.paymentReference == paymentReference &&
      other.paymentProvider == paymentProvider;

    @override
    int get hashCode =>
        subscriptionPlanId.hashCode +
        paymentReference.hashCode +
        paymentProvider.hashCode;

  factory PurchaseSubscription.fromJson(Map<String, dynamic> json) => _$PurchaseSubscriptionFromJson(json);

  Map<String, dynamic> toJson() => _$PurchaseSubscriptionToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum PurchaseSubscriptionPaymentProviderEnum {
  @JsonValue(r'paystack')
  paystack,
  @JsonValue(r'cinetpay')
  cinetpay,
}


