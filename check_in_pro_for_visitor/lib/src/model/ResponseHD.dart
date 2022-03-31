import 'package:json_annotation/json_annotation.dart';

import 'IDModelHD.dart';

part 'ResponseHD.g.dart';

@JsonSerializable()
class ResponseHD {
  @JsonKey(name: 'resultCode')
  String resultCode;

  @JsonKey(name: 'infoOCR')
  IDModelHD infoOCR;

  @JsonKey(name: 'resultMessage')
  String resultMessage;

  ResponseHD._();

  ResponseHD(this.resultCode, this.infoOCR, this.resultMessage);

  factory ResponseHD.fromJson(Map<String, dynamic> json) => _$ResponseHDFromJson(json);
}
