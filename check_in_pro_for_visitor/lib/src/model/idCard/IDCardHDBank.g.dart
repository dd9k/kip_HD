// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'IDCardHDBank.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IDCardHDBank _$IDCardHDBankFromJson(Map<String, dynamic> json) {
  return IDCardHDBank(
    json['identityNumber'] as String,
    json['nameCard'] as String,
    json['birthday'] as String,
    json['homeTown'] as String,
    json['residence'] as String,
  );
}

Map<String, dynamic> _$IDCardHDBankToJson(IDCardHDBank instance) =>
    <String, dynamic>{
      'identityNumber': instance.idCard,
      'nameCard': instance.fullName,
      'birthday': instance.birthday,
      'homeTown': instance.homeTown,
      'residence': instance.permanentAddress,
    };
