// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'partner_collaborator_register.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PartnerCollaboratorRegister _$PartnerCollaboratorRegisterFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PartnerCollaboratorRegister', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['first_name', 'email']);
  final val = PartnerCollaboratorRegister(
    firstName: $checkedConvert('first_name', (v) => v as String),
    email: $checkedConvert('email', (v) => v as String),
    phone: $checkedConvert('phone', (v) => v as String?),
    addresse: $checkedConvert('addresse', (v) => v as String?),
    city: $checkedConvert('city', (v) => v as String?),
    country: $checkedConvert('country', (v) => v as String?),
  );
  return val;
}, fieldKeyMap: const {'firstName': 'first_name'});

Map<String, dynamic> _$PartnerCollaboratorRegisterToJson(
  PartnerCollaboratorRegister instance,
) => <String, dynamic>{
  'first_name': instance.firstName,
  'email': instance.email,
  'phone': ?instance.phone,
  'addresse': ?instance.addresse,
  'city': ?instance.city,
  'country': ?instance.country,
};
