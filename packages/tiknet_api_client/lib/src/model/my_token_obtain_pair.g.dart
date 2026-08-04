// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_token_obtain_pair.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MyTokenObtainPair _$MyTokenObtainPairFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MyTokenObtainPair', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['email', 'password']);
      final val = MyTokenObtainPair(
        email: $checkedConvert('email', (v) => v as String),
        password: $checkedConvert('password', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$MyTokenObtainPairToJson(MyTokenObtainPair instance) =>
    <String, dynamic>{'email': instance.email, 'password': instance.password};
