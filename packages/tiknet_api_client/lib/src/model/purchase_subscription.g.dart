// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_subscription.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PurchaseSubscription _$PurchaseSubscriptionFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'PurchaseSubscription',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const ['subscription_plan_id', 'payment_reference'],
    );
    final val = PurchaseSubscription(
      subscriptionPlanId: $checkedConvert(
        'subscription_plan_id',
        (v) => (v as num).toInt(),
      ),
      paymentReference: $checkedConvert(
        'payment_reference',
        (v) => v as String,
      ),
      paymentProvider: $checkedConvert(
        'payment_provider',
        (v) =>
            $enumDecodeNullable(
              _$PurchaseSubscriptionPaymentProviderEnumEnumMap,
              v,
            ) ??
            'paystack',
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'subscriptionPlanId': 'subscription_plan_id',
    'paymentReference': 'payment_reference',
    'paymentProvider': 'payment_provider',
  },
);

Map<String, dynamic> _$PurchaseSubscriptionToJson(
  PurchaseSubscription instance,
) => <String, dynamic>{
  'subscription_plan_id': instance.subscriptionPlanId,
  'payment_reference': instance.paymentReference,
  'payment_provider':
      ?_$PurchaseSubscriptionPaymentProviderEnumEnumMap[instance
          .paymentProvider],
};

const _$PurchaseSubscriptionPaymentProviderEnumEnumMap = {
  PurchaseSubscriptionPaymentProviderEnum.paystack: 'paystack',
  PurchaseSubscriptionPaymentProviderEnum.cinetpay: 'cinetpay',
};
