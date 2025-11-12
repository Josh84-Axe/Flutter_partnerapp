// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_radius_plans_list200_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerRadiusPlansList200Response _$CustomerRadiusPlansList200ResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'CustomerRadiusPlansList200Response',
  json,
  ($checkedConvert) {
    final val = CustomerRadiusPlansList200Response(
      statusCode: $checkedConvert('status_code', (v) => (v as num?)?.toInt()),
      error: $checkedConvert('error', (v) => v as bool?),
      message: $checkedConvert('message', (v) => v as String?),
      data: $checkedConvert(
        'data',
        (v) => v == null
            ? null
            : CustomerRadiusPlansList200ResponseData.fromJson(
                v as Map<String, dynamic>,
              ),
      ),
    );
    return val;
  },
  fieldKeyMap: const {'statusCode': 'status_code'},
);

Map<String, dynamic> _$CustomerRadiusPlansList200ResponseToJson(
  CustomerRadiusPlansList200Response instance,
) => <String, dynamic>{
  'status_code': ?instance.statusCode,
  'error': ?instance.error,
  'message': ?instance.message,
  'data': ?instance.data?.toJson(),
};
