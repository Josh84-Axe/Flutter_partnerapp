// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resend_verify_email_otp.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResendVerifyEmailOtp _$ResendVerifyEmailOtpFromJson(
        Map<String, dynamic> json) =>
    $checkedCreate(
      'ResendVerifyEmailOtp',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const ['email'],
        );
        final val = ResendVerifyEmailOtp(
          email: $checkedConvert('email', (v) => v as String),
        );
        return val;
      },
    );

Map<String, dynamic> _$ResendVerifyEmailOtpToJson(
        ResendVerifyEmailOtp instance) =>
    <String, dynamic>{
      'email': instance.email,
    };
