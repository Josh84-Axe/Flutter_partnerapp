// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_activate_or_deactivate_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminActivateOrDeactivateUser _$AdminActivateOrDeactivateUserFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AdminActivateOrDeactivateUser', json, ($checkedConvert) {
  final val = AdminActivateOrDeactivateUser(
    isActive: $checkedConvert('is_active', (v) => v as bool?),
  );
  return val;
}, fieldKeyMap: const {'isActive': 'is_active'});

Map<String, dynamic> _$AdminActivateOrDeactivateUserToJson(
  AdminActivateOrDeactivateUser instance,
) => <String, dynamic>{'is_active': ?instance.isActive};
