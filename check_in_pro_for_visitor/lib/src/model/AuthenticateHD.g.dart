// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'AuthenticateHD.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthenticateHD _$AuthenticateHDFromJson(Map<String, dynamic> json) {
  return AuthenticateHD(
    json['access_token'] as String,
    json['expires_in'] as int,
    json['token_type'] as String,
    json['scope'] as String,
  );
}

Map<String, dynamic> _$AuthenticateHDToJson(AuthenticateHD instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'expires_in': instance.expired,
      'token_type': instance.tokenType,
      'scope': instance.scope,
    };
