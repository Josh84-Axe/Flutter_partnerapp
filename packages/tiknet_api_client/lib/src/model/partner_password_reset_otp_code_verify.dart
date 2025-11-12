//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'partner_password_reset_otp_code_verify.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PartnerPasswordResetOtpCodeVerify {
  /// Returns a new [PartnerPasswordResetOtpCodeVerify] instance.
  PartnerPasswordResetOtpCodeVerify({

    required  this.code,
  });

  @JsonKey(
    
    name: r'code',
    required: true,
    includeIfNull: false
  )


  final String code;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PartnerPasswordResetOtpCodeVerify &&
      other.code == code;

    @override
    int get hashCode =>
        code.hashCode;

  factory PartnerPasswordResetOtpCodeVerify.fromJson(Map<String, dynamic> json) => _$PartnerPasswordResetOtpCodeVerifyFromJson(json);

  Map<String, dynamic> toJson() => _$PartnerPasswordResetOtpCodeVerifyToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

