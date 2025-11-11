// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'partner_change_password_create_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PartnerChangePasswordCreateRequest _$PartnerChangePasswordCreateRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'PartnerChangePasswordCreateRequest',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['old_password', 'new_password']);
    final val = PartnerChangePasswordCreateRequest(
      oldPassword: $checkedConvert('old_password', (v) => v as String),
      newPassword: $checkedConvert('new_password', (v) => v as String),
    );
    return val;
  },
  fieldKeyMap: const {
    'oldPassword': 'old_password',
    'newPassword': 'new_password',
  },
);

Map<String, dynamic> _$PartnerChangePasswordCreateRequestToJson(
  PartnerChangePasswordCreateRequest instance,
) => <String, dynamic>{
  'old_password': instance.oldPassword,
  'new_password': instance.newPassword,
};
