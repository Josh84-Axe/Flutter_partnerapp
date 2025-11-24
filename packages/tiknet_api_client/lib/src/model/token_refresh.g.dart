// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_refresh.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TokenRefresh _$TokenRefreshFromJson(Map<String, dynamic> json) =>
    $checkedCreate('TokenRefresh', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['refresh']);
      final val = TokenRefresh(
        refresh: $checkedConvert('refresh', (v) => v as String),
        access: $checkedConvert('access', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$TokenRefreshToJson(TokenRefresh instance) =>
    <String, dynamic>{'refresh': instance.refresh, 'access': ?instance.access};
