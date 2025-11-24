// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'partner_register_init.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PartnerRegisterInit _$PartnerRegisterInitFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'PartnerRegisterInit',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'first_name',
            'email',
            'country',
            'password',
            'password2',
          ],
        );
        final val = PartnerRegisterInit(
          firstName: $checkedConvert('first_name', (v) => v as String),
          email: $checkedConvert('email', (v) => v as String),
          phone: $checkedConvert('phone', (v) => v as String?),
          addresse: $checkedConvert('addresse', (v) => v as String?),
          city: $checkedConvert('city', (v) => v as String?),
          country: $checkedConvert('country', (v) => v as String),
          numberOfRouter: $checkedConvert(
            'number_of_router',
            (v) => (v as num?)?.toInt(),
          ),
          password: $checkedConvert('password', (v) => v as String),
          password2: $checkedConvert('password2', (v) => v as String),
        );
        return val;
      },
      fieldKeyMap: const {
        'firstName': 'first_name',
        'numberOfRouter': 'number_of_router',
      },
    );

Map<String, dynamic> _$PartnerRegisterInitToJson(
  PartnerRegisterInit instance,
) => <String, dynamic>{
  'first_name': instance.firstName,
  'email': instance.email,
  'phone': ?instance.phone,
  'addresse': ?instance.addresse,
  'city': ?instance.city,
  'country': instance.country,
  'number_of_router': ?instance.numberOfRouter,
  'password': instance.password,
  'password2': instance.password2,
};
