// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_partner_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdatePartnerStatus _$UpdatePartnerStatusFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'UpdatePartnerStatus',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const ['status'],
        );
        final val = UpdatePartnerStatus(
          status: $checkedConvert('status',
              (v) => $enumDecode(_$UpdatePartnerStatusStatusEnumEnumMap, v)),
        );
        return val;
      },
    );

Map<String, dynamic> _$UpdatePartnerStatusToJson(
        UpdatePartnerStatus instance) =>
    <String, dynamic>{
      'status': _$UpdatePartnerStatusStatusEnumEnumMap[instance.status]!,
    };

const _$UpdatePartnerStatusStatusEnumEnumMap = {
  UpdatePartnerStatusStatusEnum.pending: 'pending',
  UpdatePartnerStatusStatusEnum.onProcess: 'on_process',
  UpdatePartnerStatusStatusEnum.validated: 'validated',
};
