// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_token_obtain_pair.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerTokenObtainPair _$CustomerTokenObtainPairFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'CustomerTokenObtainPair',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['first_name', 'phone']);
    final val = CustomerTokenObtainPair(
      firstName: $checkedConvert('first_name', (v) => v as String),
      phone: $checkedConvert('phone', (v) => v as String),
      macAddress: $checkedConvert('mac_address', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {'firstName': 'first_name', 'macAddress': 'mac_address'},
);

Map<String, dynamic> _$CustomerTokenObtainPairToJson(
  CustomerTokenObtainPair instance,
) => <String, dynamic>{
  'first_name': instance.firstName,
  'phone': instance.phone,
  'mac_address': ?instance.macAddress,
};
