// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'partner_collaborators_assign_role_create_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PartnerCollaboratorsAssignRoleCreateRequest
_$PartnerCollaboratorsAssignRoleCreateRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'PartnerCollaboratorsAssignRoleCreateRequest',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['role_id']);
    final val = PartnerCollaboratorsAssignRoleCreateRequest(
      roleId: $checkedConvert('role_id', (v) => (v as num).toInt()),
    );
    return val;
  },
  fieldKeyMap: const {'roleId': 'role_id'},
);

Map<String, dynamic> _$PartnerCollaboratorsAssignRoleCreateRequestToJson(
  PartnerCollaboratorsAssignRoleCreateRequest instance,
) => <String, dynamic>{'role_id': instance.roleId};
