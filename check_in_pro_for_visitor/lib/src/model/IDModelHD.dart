import 'package:json_annotation/json_annotation.dart';

import 'VisitorCheckIn.dart';

part 'IDModelHD.g.dart';

@JsonSerializable()
class IDModelHD {
  @JsonKey(name: 'identityNumber')
  String identityNumber;

  @JsonKey(name: 'nameCard')
  String nameCard;

  @JsonKey(name: 'birthday')
  String birthday;

  @JsonKey(name: 'homeTown')
  String homeTown;

  @JsonKey(name: 'residence')
  String residence;

  @JsonKey(name: 'issueDate')
  String issueDate;

  @JsonKey(name: 'issuePlace')
  String issuePlace;

  IDModelHD._();

  IDModelHD(this.identityNumber, this.nameCard, this.birthday, this.homeTown, this.residence, this.issueDate,
      this.issuePlace);

  factory IDModelHD.fromJson(Map<String, dynamic> json) => _$IDModelHDFromJson(json);

  Map<String, dynamic> toJson() => _$IDModelHDToJson(this);

  VisitorCheckIn createVisitor(VisitorCheckIn convertVisitor, bool isReturn) {
    if ((convertVisitor.idCard == null || convertVisitor.idCard.isEmpty) || !isReturn) {
      convertVisitor.idCard = identityNumber;
    }
    if ((convertVisitor.fullName == null || convertVisitor.fullName.isEmpty) || !isReturn) {
      convertVisitor.fullName = nameCard;
    }
    if ((convertVisitor.permanentAddress == null || convertVisitor.permanentAddress.isEmpty) || !isReturn) {
      convertVisitor.permanentAddress = residence;
    }
    if ((convertVisitor.birthDay == null || convertVisitor.birthDay.isEmpty) || !isReturn) {
      convertVisitor.birthDay = birthday;
    }
    return convertVisitor;
  }
}