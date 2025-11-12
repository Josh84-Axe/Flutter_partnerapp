//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'partner_reset_password.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PartnerResetPassword {
  /// Returns a new [PartnerResetPassword] instance.
  PartnerResetPassword({

    required  this.token,

    required  this.newPassword,
  });

  @JsonKey(
    
    name: r'token',
    required: true,
    includeIfNull: false
  )


  final String token;



  @JsonKey(
    
    name: r'new_password',
    required: true,
    includeIfNull: false
  )


  final String newPassword;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PartnerResetPassword &&
      other.token == token &&
      other.newPassword == newPassword;

    @override
    int get hashCode =>
        token.hashCode +
        newPassword.hashCode;

  factory PartnerResetPassword.fromJson(Map<String, dynamic> json) => _$PartnerResetPasswordFromJson(json);

  Map<String, dynamic> toJson() => _$PartnerResetPasswordToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

