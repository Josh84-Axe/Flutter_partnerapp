// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_radius_plans_list200_response_data_plans_inner.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerRadiusPlansList200ResponseDataPlansInner
_$CustomerRadiusPlansList200ResponseDataPlansInnerFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'CustomerRadiusPlansList200ResponseDataPlansInner',
  json,
  ($checkedConvert) {
    final val = CustomerRadiusPlansList200ResponseDataPlansInner(
      username: $checkedConvert('username', (v) => v as String?),
      planName: $checkedConvert('plan_name', (v) => v as String?),
      purchaseDate: $checkedConvert(
        'purchase_date',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      validityDuration: $checkedConvert(
        'validity_duration',
        (v) => v as String?,
      ),
      status: $checkedConvert('status', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'planName': 'plan_name',
    'purchaseDate': 'purchase_date',
    'validityDuration': 'validity_duration',
  },
);

Map<String, dynamic> _$CustomerRadiusPlansList200ResponseDataPlansInnerToJson(
  CustomerRadiusPlansList200ResponseDataPlansInner instance,
) => <String, dynamic>{
  'username': ?instance.username,
  'plan_name': ?instance.planName,
  'purchase_date': ?instance.purchaseDate?.toIso8601String(),
  'validity_duration': ?instance.validityDuration,
  'status': ?instance.status,
};
