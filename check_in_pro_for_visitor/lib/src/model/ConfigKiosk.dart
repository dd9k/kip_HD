import 'package:check_in_pro_for_visitor/src/model/VisitorType.dart';
import 'package:json_annotation/json_annotation.dart';
import 'SaverModel.dart';
import 'TouchlessModel.dart';

part 'ConfigKiosk.g.dart';

@JsonSerializable()
class ConfigKiosk {
  @JsonKey(name: 'visitorType')
  List<VisitorType> visitorType;

  @JsonKey(name: 'visitorTypeLang')
  String visitorTypeLang;

  @JsonKey(name: 'isTakePicture')
  bool isTakePicture;

  @JsonKey(name: 'picCountdownInterval')
  int picCountdownInterval;

  @JsonKey(name: 'isScanIdCard')
  bool isScanIdCard;

  @JsonKey(name: 'isPrintCard')
  bool isPrintCard;

  @JsonKey(name: 'isSurvey')
  bool isSurvey;

//  @JsonKey(name: 'healthDeclarationInfo')
//  CovidModel covidModel;

  @JsonKey(name: 'ratingType')
  String ratingType;

  @JsonKey(name: 'allowToDisplayContactPerson')
  bool allowToDisplayContactPerson;

  @JsonKey(name: 'touchless')
  TouchlessModel touchlessModel;

  @JsonKey(name: 'waiting')
  SaverModel saverModel;

  @JsonKey(name: 'isShowVisitorType')
  int isShowVisitorType;

  ConfigKiosk(this.visitorType, this.visitorTypeLang, this.isTakePicture, this.picCountdownInterval, this.isScanIdCard,
      this.isPrintCard, this.isSurvey, this.ratingType, this.allowToDisplayContactPerson, this.touchlessModel, this.saverModel, this.isShowVisitorType);

  factory ConfigKiosk.fromJson(Map<String, dynamic> json) => _$ConfigKioskFromJson(json);

  Map<String, dynamic> toJson() => _$ConfigKioskToJson(this);
}
