// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'partner_reset_password.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PartnerResetPassword _$PartnerResetPasswordFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PartnerResetPassword', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['token', 'new_password']);
  final val = PartnerResetPassword(
    token: $checkedConvert('token', (v) => v as String),
    newPassword: $checkedConvert('new_password', (v) => v as String),
  );
  return val;
}, fieldKeyMap: const {'newPassword': 'new_password'});

Map<String, dynamic> _$PartnerResetPasswordToJson(
  PartnerResetPassword instance,
) => <String, dynamic>{
  'token': instance.token,
  'new_password': instance.newPassword,
};
