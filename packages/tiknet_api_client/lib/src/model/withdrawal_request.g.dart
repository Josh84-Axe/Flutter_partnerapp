// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'withdrawal_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WithdrawalRequest _$WithdrawalRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'WithdrawalRequest',
      json,
      ($checkedConvert) {
        $checkKeys(json, requiredKeys: const ['payment_method', 'amount']);
        final val = WithdrawalRequest(
          id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
          paymentMethod: $checkedConvert(
            'payment_method',
            (v) => (v as num).toInt(),
          ),
          amount: $checkedConvert('amount', (v) => (v as num).toDouble()),
          reference: $checkedConvert('reference', (v) => v as String?),
          status: $checkedConvert(
            'status',
            (v) => $enumDecodeNullable(_$WithdrawalRequestStatusEnumEnumMap, v),
          ),
          requestedAt: $checkedConvert(
            'requested_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'paymentMethod': 'payment_method',
        'requestedAt': 'requested_at',
      },
    );

Map<String, dynamic> _$WithdrawalRequestToJson(WithdrawalRequest instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'payment_method': instance.paymentMethod,
      'amount': instance.amount,
      'reference': ?instance.reference,
      'status': ?_$WithdrawalRequestStatusEnumEnumMap[instance.status],
      'requested_at': ?instance.requestedAt?.toIso8601String(),
    };

const _$WithdrawalRequestStatusEnumEnumMap = {
  WithdrawalRequestStatusEnum.pending: 'pending',
  WithdrawalRequestStatusEnum.approved: 'approved',
  WithdrawalRequestStatusEnum.rejected: 'rejected',
  WithdrawalRequestStatusEnum.completed: 'completed',
};
