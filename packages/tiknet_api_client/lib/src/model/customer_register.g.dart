// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_register.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerRegister _$CustomerRegisterFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'CustomerRegister',
      json,
      ($checkedConvert) {
        $checkKeys(json, requiredKeys: const ['first_name', 'phone']);
        final val = CustomerRegister(
          firstName: $checkedConvert('first_name', (v) => v as String),
          phone: $checkedConvert('phone', (v) => v as String),
          macAddress: $checkedConvert('mac_address', (v) => v as String?),
          routerDnsName: $checkedConvert(
            'router_dns_name',
            (v) => v as String?,
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'firstName': 'first_name',
        'macAddress': 'mac_address',
        'routerDnsName': 'router_dns_name',
      },
    );

Map<String, dynamic> _$CustomerRegisterToJson(CustomerRegister instance) =>
    <String, dynamic>{
      'first_name': instance.firstName,
      'phone': instance.phone,
      'mac_address': ?instance.macAddress,
      'router_dns_name': ?instance.routerDnsName,
    };
