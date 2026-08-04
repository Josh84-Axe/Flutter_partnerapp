//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'confirm_register_email_otp.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ConfirmRegisterEmailOtp {
  /// Returns a new [ConfirmRegisterEmailOtp] instance.
  ConfirmRegisterEmailOtp({

    required  this.email,

    required  this.code,
  });

  @JsonKey(
    
    name: r'email',
    required: true,
    includeIfNull: false
  )


  final String email;



      /// Le code OTP reçu par email pour vérifier votre email.
  @JsonKey(
    
    name: r'code',
    required: true,
    includeIfNull: false
  )


  final String code;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ConfirmRegisterEmailOtp &&
      other.email == email &&
      other.code == code;

    @override
    int get hashCode =>
        email.hashCode +
        code.hashCode;

  factory ConfirmRegisterEmailOtp.fromJson(Map<String, dynamic> json) => _$ConfirmRegisterEmailOtpFromJson(json);

  Map<String, dynamic> toJson() => _$ConfirmRegisterEmailOtpToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

