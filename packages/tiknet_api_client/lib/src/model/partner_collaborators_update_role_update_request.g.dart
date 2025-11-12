// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'partner_collaborators_update_role_update_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PartnerCollaboratorsUpdateRoleUpdateRequest
_$PartnerCollaboratorsUpdateRoleUpdateRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'PartnerCollaboratorsUpdateRoleUpdateRequest',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['role_id']);
    final val = PartnerCollaboratorsUpdateRoleUpdateRequest(
      roleId: $checkedConvert('role_id', (v) => (v as num).toInt()),
    );
    return val;
  },
  fieldKeyMap: const {'roleId': 'role_id'},
);

Map<String, dynamic> _$PartnerCollaboratorsUpdateRoleUpdateRequestToJson(
  PartnerCollaboratorsUpdateRoleUpdateRequest instance,
) => <String, dynamic>{'role_id': instance.roleId};
