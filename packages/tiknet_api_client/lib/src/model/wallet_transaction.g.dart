// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WalletTransaction _$WalletTransactionFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'WalletTransaction',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const ['payment_reference', 'amount_paid', 'model_id'],
        );
        final val = WalletTransaction(
          id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
          user: $checkedConvert('user', (v) => (v as num?)?.toInt()),
          customer: $checkedConvert('customer', (v) => (v as num?)?.toInt()),
          paymentReference: $checkedConvert(
            'payment_reference',
            (v) => v as String,
          ),
          amountPaid: $checkedConvert(
            'amount_paid',
            (v) => (v as num).toDouble(),
          ),
          status: $checkedConvert(
            'status',
            (v) => $enumDecodeNullable(_$WalletTransactionStatusEnumEnumMap, v),
          ),
          type: $checkedConvert(
            'type',
            (v) => $enumDecodeNullable(_$WalletTransactionTypeEnumEnumMap, v),
          ),
          modelType: $checkedConvert('model_type', (v) => (v as num?)?.toInt()),
          modelId: $checkedConvert('model_id', (v) => (v as num).toInt()),
          relatedModel: $checkedConvert('related_model', (v) => v as String?),
          createdAt: $checkedConvert(
            'created_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'paymentReference': 'payment_reference',
        'amountPaid': 'amount_paid',
        'modelType': 'model_type',
        'modelId': 'model_id',
        'relatedModel': 'related_model',
        'createdAt': 'created_at',
      },
    );

Map<String, dynamic> _$WalletTransactionToJson(WalletTransaction instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'user': ?instance.user,
      'customer': ?instance.customer,
      'payment_reference': instance.paymentReference,
      'amount_paid': instance.amountPaid,
      'status': ?_$WalletTransactionStatusEnumEnumMap[instance.status],
      'type': ?_$WalletTransactionTypeEnumEnumMap[instance.type],
      'model_type': ?instance.modelType,
      'model_id': instance.modelId,
      'related_model': ?instance.relatedModel,
      'created_at': ?instance.createdAt?.toIso8601String(),
    };

const _$WalletTransactionStatusEnumEnumMap = {
  WalletTransactionStatusEnum.pending: 'pending',
  WalletTransactionStatusEnum.success: 'success',
  WalletTransactionStatusEnum.failed: 'failed',
};

const _$WalletTransactionTypeEnumEnumMap = {
  WalletTransactionTypeEnum.revenue: 'revenue',
  WalletTransactionTypeEnum.payout: 'payout',
};
