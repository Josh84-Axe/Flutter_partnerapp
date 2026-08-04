// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Router _$RouterFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Router',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const ['name', 'ip_address', 'username', 'password'],
    );
    final val = Router(
      id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
      name: $checkedConvert('name', (v) => v as String),
      slug: $checkedConvert('slug', (v) => v as String?),
      ref: $checkedConvert('ref', (v) => v as String?),
      ipAddress: $checkedConvert('ip_address', (v) => v as String),
      username: $checkedConvert('username', (v) => v as String),
      password: $checkedConvert('password', (v) => v as String),
      secret: $checkedConvert('secret', (v) => v as String?),
      dnsName: $checkedConvert('dns_name', (v) => v as String?),
      apiPort: $checkedConvert('api_port', (v) => (v as num?)?.toInt()),
      coaPort: $checkedConvert('coa_port', (v) => (v as num?)?.toInt()),
      isActive: $checkedConvert('is_active', (v) => v as bool?),
    );
    return val;
  },
  fieldKeyMap: const {
    'ipAddress': 'ip_address',
    'dnsName': 'dns_name',
    'apiPort': 'api_port',
    'coaPort': 'coa_port',
    'isActive': 'is_active',
  },
);

Map<String, dynamic> _$RouterToJson(Router instance) => <String, dynamic>{
  'id': ?instance.id,
  'name': instance.name,
  'slug': ?instance.slug,
  'ref': ?instance.ref,
  'ip_address': instance.ipAddress,
  'username': instance.username,
  'password': instance.password,
  'secret': ?instance.secret,
  'dns_name': ?instance.dnsName,
  'api_port': ?instance.apiPort,
  'coa_port': ?instance.coaPort,
  'is_active': ?instance.isActive,
};
