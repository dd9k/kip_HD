// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'IDModelHD.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IDModelHD _$IDModelHDFromJson(Map<String, dynamic> json) {
  return IDModelHD(
    json['identityNumber'] as String,
    json['nameCard'] as String,
    json['birthday'] as String,
    json['homeTown'] as String,
    json['residence'] as String,
    json['issueDate'] as String,
    json['issuePlace'] as String,
  );
}

Map<String, dynamic> _$IDModelHDToJson(IDModelHD instance) => <String, dynamic>{
      'identityNumber': instance.identityNumber,
      'nameCard': instance.nameCard,
      'birthday': instance.birthday,
      'homeTown': instance.homeTown,
      'residence': instance.residence,
      'issueDate': instance.issueDate,
      'issuePlace': instance.issuePlace,
    };
