//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'resend_verify_email_otp.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ResendVerifyEmailOtp {
  /// Returns a new [ResendVerifyEmailOtp] instance.
  ResendVerifyEmailOtp({

    required  this.email,
  });

      /// L'adresse email en attente de vérification.
  @JsonKey(
    
    name: r'email',
    required: true,
    includeIfNull: false
  )


  final String email;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ResendVerifyEmailOtp &&
      other.email == email;

    @override
    int get hashCode =>
        email.hashCode;

  factory ResendVerifyEmailOtp.fromJson(Map<String, dynamic> json) => _$ResendVerifyEmailOtpFromJson(json);

  Map<String, dynamic> toJson() => _$ResendVerifyEmailOtpToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

