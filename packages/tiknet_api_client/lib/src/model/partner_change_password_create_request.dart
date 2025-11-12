//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'partner_change_password_create_request.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PartnerChangePasswordCreateRequest {
  /// Returns a new [PartnerChangePasswordCreateRequest] instance.
  PartnerChangePasswordCreateRequest({

    required  this.oldPassword,

    required  this.newPassword,
  });

      /// Ancien mot de passe
  @JsonKey(
    
    name: r'old_password',
    required: true,
    includeIfNull: false
  )


  final String oldPassword;



      /// Nouveau mot de passe
  @JsonKey(
    
    name: r'new_password',
    required: true,
    includeIfNull: false
  )


  final String newPassword;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PartnerChangePasswordCreateRequest &&
      other.oldPassword == oldPassword &&
      other.newPassword == newPassword;

    @override
    int get hashCode =>
        oldPassword.hashCode +
        newPassword.hashCode;

  factory PartnerChangePasswordCreateRequest.fromJson(Map<String, dynamic> json) => _$PartnerChangePasswordCreateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PartnerChangePasswordCreateRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

