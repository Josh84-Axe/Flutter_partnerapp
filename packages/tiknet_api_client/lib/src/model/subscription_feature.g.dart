// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_feature.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriptionFeature _$SubscriptionFeatureFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SubscriptionFeature', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['name']);
      final val = SubscriptionFeature(
        id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
        name: $checkedConvert('name', (v) => v as String),
        slug: $checkedConvert('slug', (v) => v as String?),
        description: $checkedConvert('description', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$SubscriptionFeatureToJson(
  SubscriptionFeature instance,
) => <String, dynamic>{
  'id': ?instance.id,
  'name': instance.name,
  'slug': ?instance.slug,
  'description': ?instance.description,
};
