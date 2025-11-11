// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_token_obtain_pair.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminTokenObtainPair _$AdminTokenObtainPairFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AdminTokenObtainPair', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['email', 'password']);
  final val = AdminTokenObtainPair(
    email: $checkedConvert('email', (v) => v as String),
    password: $checkedConvert('password', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$AdminTokenObtainPairToJson(
  AdminTokenObtainPair instance,
) => <String, dynamic>{'email': instance.email, 'password': instance.password};
