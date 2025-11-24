//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'partner_collaborators_assign_role_create_request.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PartnerCollaboratorsAssignRoleCreateRequest {
  /// Returns a new [PartnerCollaboratorsAssignRoleCreateRequest] instance.
  PartnerCollaboratorsAssignRoleCreateRequest({

    required  this.roleId,
  });

      /// ID du rôle à assigner au collaborateur
  @JsonKey(
    
    name: r'role_id',
    required: true,
    includeIfNull: false
  )


  final int roleId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PartnerCollaboratorsAssignRoleCreateRequest &&
      other.roleId == roleId;

    @override
    int get hashCode =>
        roleId.hashCode;

  factory PartnerCollaboratorsAssignRoleCreateRequest.fromJson(Map<String, dynamic> json) => _$PartnerCollaboratorsAssignRoleCreateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PartnerCollaboratorsAssignRoleCreateRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

