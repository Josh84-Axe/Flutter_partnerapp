// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'confirm_register_email_otp.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConfirmRegisterEmailOtp _$ConfirmRegisterEmailOtpFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ConfirmRegisterEmailOtp', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['email', 'code']);
  final val = ConfirmRegisterEmailOtp(
    email: $checkedConvert('email', (v) => v as String),
    code: $checkedConvert('code', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$ConfirmRegisterEmailOtpToJson(
  ConfirmRegisterEmailOtp instance,
) => <String, dynamic>{'email': instance.email, 'code': instance.code};
