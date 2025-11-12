// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_sign_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerSignIn _$CustomerSignInFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CustomerSignIn', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['first_name', 'phone']);
      final val = CustomerSignIn(
        firstName: $checkedConvert('first_name', (v) => v as String),
        phone: $checkedConvert('phone', (v) => v as String),
      );
      return val;
    }, fieldKeyMap: const {'firstName': 'first_name'});

Map<String, dynamic> _$CustomerSignInToJson(CustomerSignIn instance) =>
    <String, dynamic>{
      'first_name': instance.firstName,
      'phone': instance.phone,
    };
