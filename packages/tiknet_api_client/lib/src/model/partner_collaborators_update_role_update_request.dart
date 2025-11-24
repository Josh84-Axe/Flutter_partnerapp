//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'partner_collaborators_update_role_update_request.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PartnerCollaboratorsUpdateRoleUpdateRequest {
  /// Returns a new [PartnerCollaboratorsUpdateRoleUpdateRequest] instance.
  PartnerCollaboratorsUpdateRoleUpdateRequest({

    required  this.roleId,
  });

      /// ID du nouveau rôle à assigner
  @JsonKey(
    
    name: r'role_id',
    required: true,
    includeIfNull: false
  )


  final int roleId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PartnerCollaboratorsUpdateRoleUpdateRequest &&
      other.roleId == roleId;

    @override
    int get hashCode =>
        roleId.hashCode;

  factory PartnerCollaboratorsUpdateRoleUpdateRequest.fromJson(Map<String, dynamic> json) => _$PartnerCollaboratorsUpdateRoleUpdateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PartnerCollaboratorsUpdateRoleUpdateRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

