// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Role _$RoleFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Role', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['name']);
      final val = Role(
        id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
        name: $checkedConvert('name', (v) => v as String),
        slug: $checkedConvert('slug', (v) => v as String?),
        description: $checkedConvert('description', (v) => v as String?),
        permissions: $checkedConvert(
          'permissions',
          (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toSet(),
        ),
        actif: $checkedConvert('actif', (v) => v as bool?),
      );
      return val;
    });

Map<String, dynamic> _$RoleToJson(Role instance) => <String, dynamic>{
  'id': ?instance.id,
  'name': instance.name,
  'slug': ?instance.slug,
  'description': ?instance.description,
  'permissions': ?instance.permissions?.toList(),
  'actif': ?instance.actif,
};
