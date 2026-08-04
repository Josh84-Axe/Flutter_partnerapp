//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'partner_password_reset_otp_request.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PartnerPasswordResetOTPRequest {
  /// Returns a new [PartnerPasswordResetOTPRequest] instance.
  PartnerPasswordResetOTPRequest({

    required  this.email,
  });

  @JsonKey(
    
    name: r'email',
    required: true,
    includeIfNull: false
  )


  final String email;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PartnerPasswordResetOTPRequest &&
      other.email == email;

    @override
    int get hashCode =>
        email.hashCode;

  factory PartnerPasswordResetOTPRequest.fromJson(Map<String, dynamic> json) => _$PartnerPasswordResetOTPRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PartnerPasswordResetOTPRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

