// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ResponseHD.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResponseHD _$ResponseHDFromJson(Map<String, dynamic> json) {
  return ResponseHD(
    json['resultCode'] as String,
    json['infoOCR'] == null
        ? null
        : IDModelHD.fromJson(json['infoOCR'] as Map<String, dynamic>),
    json['resultMessage'] as String,
  );
}

Map<String, dynamic> _$ResponseHDToJson(ResponseHD instance) =>
    <String, dynamic>{
      'resultCode': instance.resultCode,
      'infoOCR': instance.infoOCR,
      'resultMessage': instance.resultMessage,
    };
