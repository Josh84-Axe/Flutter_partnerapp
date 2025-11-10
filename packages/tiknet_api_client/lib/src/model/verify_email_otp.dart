//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'verify_email_otp.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class VerifyEmailOtp {
  /// Returns a new [VerifyEmailOtp] instance.
  VerifyEmailOtp({

    required  this.code,
  });

      /// Le code OTP reçu par email pour vérifier le nouvel email.
  @JsonKey(
    
    name: r'code',
    required: true,
    includeIfNull: false
  )


  final String code;





    @override
    bool operator ==(Object other) => identical(this, other) || other is VerifyEmailOtp &&
      other.code == code;

    @override
    int get hashCode =>
        code.hashCode;

  factory VerifyEmailOtp.fromJson(Map<String, dynamic> json) => _$VerifyEmailOtpFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyEmailOtpToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

