// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_partner.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdatePartner _$UpdatePartnerFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'UpdatePartner',
      json,
      ($checkedConvert) {
        $checkKeys(json, requiredKeys: const ['phone', 'country']);
        final val = UpdatePartner(
          firstName: $checkedConvert('first_name', (v) => v as String?),
          lastName: $checkedConvert('last_name', (v) => v as String?),
          email: $checkedConvert('email', (v) => v as String?),
          phone: $checkedConvert('phone', (v) => v as String?),
          country: $checkedConvert('country', (v) => v as String?),
          state: $checkedConvert('state', (v) => v as String?),
          city: $checkedConvert('city', (v) => v as String?),
          addresse: $checkedConvert('addresse', (v) => v as String?),
          numberOfRouter: $checkedConvert(
            'number_of_router',
            (v) => (v as num?)?.toInt(),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'firstName': 'first_name',
        'lastName': 'last_name',
        'numberOfRouter': 'number_of_router',
      },
    );

Map<String, dynamic> _$UpdatePartnerToJson(UpdatePartner instance) =>
    <String, dynamic>{
      'first_name': ?instance.firstName,
      'last_name': ?instance.lastName,
      'email': ?instance.email,
      'phone': instance.phone,
      'country': instance.country,
      'state': ?instance.state,
      'city': ?instance.city,
      'addresse': ?instance.addresse,
      'number_of_router': ?instance.numberOfRouter,
    };
