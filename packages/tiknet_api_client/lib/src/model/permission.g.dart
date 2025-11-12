// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'permission.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Permission _$PermissionFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Permission', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['name', 'slug']);
      final val = Permission(
        id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
        name: $checkedConvert('name', (v) => v as String),
        slug: $checkedConvert('slug', (v) => v as String),
        description: $checkedConvert('description', (v) => v as String?),
        isActif: $checkedConvert('is_actif', (v) => v as bool?),
      );
      return val;
    }, fieldKeyMap: const {'isActif': 'is_actif'});

Map<String, dynamic> _$PermissionToJson(Permission instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'description': ?instance.description,
      'is_actif': ?instance.isActif,
    };
