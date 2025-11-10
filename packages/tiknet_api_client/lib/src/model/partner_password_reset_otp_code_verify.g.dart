// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'partner_password_reset_otp_code_verify.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PartnerPasswordResetOtpCodeVerify _$PartnerPasswordResetOtpCodeVerifyFromJson(
        Map<String, dynamic> json) =>
    $checkedCreate(
      'PartnerPasswordResetOtpCodeVerify',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const ['code'],
        );
        final val = PartnerPasswordResetOtpCodeVerify(
          code: $checkedConvert('code', (v) => v as String),
        );
        return val;
      },
    );

Map<String, dynamic> _$PartnerPasswordResetOtpCodeVerifyToJson(
        PartnerPasswordResetOtpCodeVerify instance) =>
    <String, dynamic>{
      'code': instance.code,
    };
