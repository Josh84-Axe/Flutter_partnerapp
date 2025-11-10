// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_withdrawal_request_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateWithdrawalRequestStatus _$UpdateWithdrawalRequestStatusFromJson(
        Map<String, dynamic> json) =>
    $checkedCreate(
      'UpdateWithdrawalRequestStatus',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const ['status'],
        );
        final val = UpdateWithdrawalRequestStatus(
          status: $checkedConvert(
              'status',
              (v) => $enumDecode(
                  _$UpdateWithdrawalRequestStatusStatusEnumEnumMap, v)),
        );
        return val;
      },
    );

Map<String, dynamic> _$UpdateWithdrawalRequestStatusToJson(
        UpdateWithdrawalRequestStatus instance) =>
    <String, dynamic>{
      'status':
          _$UpdateWithdrawalRequestStatusStatusEnumEnumMap[instance.status]!,
    };

const _$UpdateWithdrawalRequestStatusStatusEnumEnumMap = {
  UpdateWithdrawalRequestStatusStatusEnum.pending: 'pending',
  UpdateWithdrawalRequestStatusStatusEnum.approved: 'approved',
  UpdateWithdrawalRequestStatusStatusEnum.completed: 'completed',
  UpdateWithdrawalRequestStatusStatusEnum.rejected: 'rejected',
};
