// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_email_otp.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerifyEmailOtp _$VerifyEmailOtpFromJson(Map<String, dynamic> json) =>
    $checkedCreate('VerifyEmailOtp', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['code']);
      final val = VerifyEmailOtp(
        code: $checkedConvert('code', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$VerifyEmailOtpToJson(VerifyEmailOtp instance) =>
    <String, dynamic>{'code': instance.code};
