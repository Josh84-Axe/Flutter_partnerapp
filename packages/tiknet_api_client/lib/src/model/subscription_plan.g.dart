// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriptionPlan _$SubscriptionPlanFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'SubscriptionPlan',
      json,
      ($checkedConvert) {
        $checkKeys(json, requiredKeys: const ['name', 'price', 'features']);
        final val = SubscriptionPlan(
          id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
          name: $checkedConvert('name', (v) => v as String),
          slug: $checkedConvert('slug', (v) => v as String?),
          price: $checkedConvert('price', (v) => (v as num).toDouble()),
          duration: $checkedConvert(
            'duration',
            (v) =>
                $enumDecodeNullable(_$SubscriptionPlanDurationEnumEnumMap, v),
          ),
          features: $checkedConvert(
            'features',
            (v) => (v as List<dynamic>).map((e) => (e as num).toInt()).toSet(),
          ),
          isActive: $checkedConvert('is_active', (v) => v as bool?),
          createdAt: $checkedConvert(
            'created_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
        );
        return val;
      },
      fieldKeyMap: const {'isActive': 'is_active', 'createdAt': 'created_at'},
    );

Map<String, dynamic> _$SubscriptionPlanToJson(SubscriptionPlan instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'name': instance.name,
      'slug': ?instance.slug,
      'price': instance.price,
      'duration': ?_$SubscriptionPlanDurationEnumEnumMap[instance.duration],
      'features': instance.features.toList(),
      'is_active': ?instance.isActive,
      'created_at': ?instance.createdAt?.toIso8601String(),
    };

const _$SubscriptionPlanDurationEnumEnumMap = {
  SubscriptionPlanDurationEnum.monthly: 'monthly',
  SubscriptionPlanDurationEnum.yearly: 'yearly',
};
