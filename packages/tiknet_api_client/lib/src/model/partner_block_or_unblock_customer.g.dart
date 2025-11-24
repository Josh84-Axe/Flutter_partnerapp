// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'partner_block_or_unblock_customer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PartnerBlockOrUnblockCustomer _$PartnerBlockOrUnblockCustomerFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PartnerBlockOrUnblockCustomer', json, ($checkedConvert) {
  final val = PartnerBlockOrUnblockCustomer(
    blocked: $checkedConvert('blocked', (v) => v as bool?),
  );
  return val;
});

Map<String, dynamic> _$PartnerBlockOrUnblockCustomerToJson(
  PartnerBlockOrUnblockCustomer instance,
) => <String, dynamic>{'blocked': ?instance.blocked};
