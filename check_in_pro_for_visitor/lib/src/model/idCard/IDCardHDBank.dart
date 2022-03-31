import 'package:check_in_pro_for_visitor/src/model/VisitorCheckIn.dart';
import 'package:json_annotation/json_annotation.dart';

part 'IDCardHDBank.g.dart';

@JsonSerializable()
class IDCardHDBank {
  @JsonKey(name: 'identityNumber')
  String idCard;

  @JsonKey(name: 'nameCard')
  String fullName;

  @JsonKey(name: 'birthday')
  String birthday;

  @JsonKey(name: 'homeTown')
  String homeTown;

  @JsonKey(name: 'residence')
  String permanentAddress;

  IDCardHDBank.init();

  IDCardHDBank(this.idCard, this.fullName, this.birthday, this.homeTown, this.permanentAddress);

  factory IDCardHDBank.fromJson(Map<String, dynamic> json) => _$IDCardHDBankFromJson(json);

  Map<String, dynamic> toJson() => _$IDCardHDBankToJson(this);

  VisitorCheckIn createVisitor(VisitorCheckIn convertVisitor, bool isReturn) {
    if ((convertVisitor.idCard == null || convertVisitor.idCard.isEmpty) || !isReturn) {
      convertVisitor.idCard = idCard;
    }
    if ((convertVisitor.fullName == null || convertVisitor.fullName.isEmpty) || !isReturn) {
      convertVisitor.fullName = fullName;
    }
    if ((convertVisitor.permanentAddress == null || convertVisitor.permanentAddress.isEmpty) || !isReturn) {
      convertVisitor.permanentAddress = permanentAddress;
    }
    if ((convertVisitor.birthDay == null || convertVisitor.birthDay.isEmpty) || !isReturn) {
      convertVisitor.birthDay = birthday;
    }
    return convertVisitor;
  }
}