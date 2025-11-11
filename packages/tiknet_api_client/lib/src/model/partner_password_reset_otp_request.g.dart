// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'partner_password_reset_otp_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PartnerPasswordResetOTPRequest _$PartnerPasswordResetOTPRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PartnerPasswordResetOTPRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['email']);
  final val = PartnerPasswordResetOTPRequest(
    email: $checkedConvert('email', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$PartnerPasswordResetOTPRequestToJson(
  PartnerPasswordResetOTPRequest instance,
) => <String, dynamic>{'email': instance.email};
