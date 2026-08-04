// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_radius_plans_list200_response_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerRadiusPlansList200ResponseData
_$CustomerRadiusPlansList200ResponseDataFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CustomerRadiusPlansList200ResponseData', json, (
      $checkedConvert,
    ) {
      final val = CustomerRadiusPlansList200ResponseData(
        username: $checkedConvert('username', (v) => v as String?),
        plans: $checkedConvert(
          'plans',
          (v) => (v as List<dynamic>?)
              ?.map(
                (e) =>
                    CustomerRadiusPlansList200ResponseDataPlansInner.fromJson(
                      e as Map<String, dynamic>,
                    ),
              )
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$CustomerRadiusPlansList200ResponseDataToJson(
  CustomerRadiusPlansList200ResponseData instance,
) => <String, dynamic>{
  'username': ?instance.username,
  'plans': ?instance.plans?.map((e) => e.toJson()).toList(),
};
