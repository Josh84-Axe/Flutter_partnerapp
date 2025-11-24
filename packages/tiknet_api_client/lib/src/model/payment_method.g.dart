// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_method.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentMethod _$PaymentMethodFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PaymentMethod', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['name']);
      final val = PaymentMethod(
        id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
        name: $checkedConvert('name', (v) => v as String),
        slug: $checkedConvert('slug', (v) => v as String?),
        numbers: $checkedConvert('numbers', (v) => (v as num?)?.toInt()),
        description: $checkedConvert('description', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$PaymentMethodToJson(PaymentMethod instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'name': instance.name,
      'slug': ?instance.slug,
      'numbers': ?instance.numbers,
      'description': ?instance.description,
    };
