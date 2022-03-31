import 'package:check_in_pro_for_visitor/src/constants/Constants.dart';
import 'package:check_in_pro_for_visitor/src/database/Database.dart';
import 'package:check_in_pro_for_visitor/src/utilities/AppLocalizations.dart';
import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';

import 'CheckInFlow.dart';
import 'EventLog.dart';

part 'VisitorCheckIn.g.dart';

@JsonSerializable()
class VisitorCheckIn {
  @JsonKey(ignore: true)
  String localId;

  @JsonKey(name: 'id', defaultValue: 0.0)
  double id;

  @JsonKey(name: 'fullName')
  String fullName;

  @JsonKey(name: 'email')
  String email;

  @JsonKey(name: 'phoneNumber')
  String phoneNumber;

  @JsonKey(name: 'idCard')
  String idCard;

  @JsonKey(name: 'purpose')
  String purpose;

  @JsonKey(name: 'visitorId')
  double visitorId;

  @JsonKey(name: 'visitorType')
  String visitorType;

  @JsonKey(name: 'checkOutTimeExpected')
  String checkOutTimeExpected;

  @JsonKey(name: 'fromCompany')
  String fromCompany;

  @JsonKey(name: 'toCompany')
  String toCompany;

  @JsonKey(name: 'contactPersonId')
  double contactPersonId;

  @JsonKey(name: 'faceCaptureRepoId')
  double faceCaptureRepoId;

  @JsonKey(name: 'faceCaptureFile')
  String faceCaptureFile;

  @JsonKey(name: 'signInBy')
  int signInBy;

  @JsonKey(name: 'registerType')
  String signInType = Constants.TYPE_CHECK;

  @JsonKey(ignore: true)
  String floor = "";

  @JsonKey(ignore: true)
  String imagePath = "";

  @JsonKey(ignore: true)
  String imageIdPath;

  @JsonKey(ignore: true)
  String imageIdBackPath;

  @JsonKey(name: 'toCompanyId')
  double toCompanyId;

  @JsonKey(name: 'cardNo')
  String cardNo;

  @JsonKey(name: 'goods')
  String goods;

  @JsonKey(name: 'receiver')
  String receiver;

  @JsonKey(name: 'visitorPosition')
  String visitorPosition;

  @JsonKey(name: 'idCardRepoId')
  double idCardRepoId;

  @JsonKey(name: 'idCardFile')
  String idCardFile;

  @JsonKey(name: 'idCardBackRepoId')
  double idCardBackRepoId;

  @JsonKey(name: 'idCardBackFile')
  String idCardBackFile;

  @JsonKey(name: 'surveyAnswer')
  String survey;

  @JsonKey(name: 'surveyId')
  double surveyId;

  @JsonKey(name: 'gender')
  int gender;

  @JsonKey(name: 'passportNo')
  String passportNo;

  @JsonKey(name: 'nationality')
  String nationality;

  @JsonKey(name: 'birthDay')
  String birthDay;

  @JsonKey(name: 'permanentAddress')
  String permanentAddress;

  @JsonKey(name: 'departmentRoomNo')
  String departmentRoomNo;

  @JsonKey(name: 'isOnline')
  bool isOnline = false;

  @JsonKey(name: 'inviteCode')
  String inviteCode;

  @JsonKey(ignore: true)
  bool isDoneIdBack = false;

  @JsonKey(ignore: true)
  bool isDoneIdFace = false;

  @JsonKey(ignore: true)
  bool isDoneIdFont = false;

  @JsonKey(name: 'groupNumberVisitor')
  int groupNumberVisitor;

  @JsonKey(name: 'qrGroupGuestUrl')
  String qrGroupGuestUrl;

  VisitorCheckIn.inital();

  VisitorCheckIn.copyWithEventLog(EventLog eventLog) {
    this.id = eventLog.guestId;
    this.fullName = eventLog.fullName;
    this.email = eventLog.email;
    this.idCard = eventLog.idCard;
    this.inviteCode = eventLog.inviteCode;
    this.phoneNumber = eventLog.phoneNumber;
    this.signInType = eventLog.signInType;
    this.imagePath = eventLog.imagePath;
    this.imageIdPath = eventLog.imageIdPath;
//    this.imageIdBackPath = eventLog.imageIdBackPath;
    this.visitorType = eventLog.visitorType;
    this.inviteCode = eventLog.inviteCode;
    isOnline = false;
  }

  VisitorCheckIn.copyWithOther(VisitorCheckIn other) {
    this.localId = other.localId;
    this.id = other.id;
    this.fullName = other.fullName;
    this.email = other.email;
    this.phoneNumber = other.phoneNumber;
    this.idCard = other.idCard;
    this.purpose = other.purpose;
    this.visitorId = other.visitorId;
    this.visitorType = other.visitorType;
    this.checkOutTimeExpected = other.checkOutTimeExpected;
    this.fromCompany = other.fromCompany;
    this.toCompany = other.toCompany;
    this.contactPersonId = other.contactPersonId;
    this.faceCaptureRepoId = other.faceCaptureRepoId;
    this.faceCaptureFile = other.faceCaptureFile;
    this.signInBy = other.signInBy;
    this.signInType = other.signInType;
    this.floor = other.floor;
    this.imagePath = other.imagePath;
    this.imageIdPath = other.imageIdPath;
    this.imageIdBackPath = other.imageIdBackPath;
    this.toCompanyId = other.toCompanyId;
    this.cardNo = other.cardNo;
    this.goods = other.goods;
    this.receiver = other.receiver;
    this.visitorPosition = other.visitorPosition;
    this.idCardRepoId = other.idCardRepoId;
    this.idCardFile = other.idCardFile;
    this.idCardBackRepoId = other.idCardBackRepoId;
    this.idCardBackFile = other.idCardBackFile;
    this.survey = other.survey;
    this.surveyId = other.surveyId;
    this.gender = other.gender;
    this.passportNo = other.passportNo;
    this.nationality = other.nationality;
    this.birthDay = other.birthDay;
    this.permanentAddress = other.permanentAddress;
    this.departmentRoomNo = other.departmentRoomNo;
    this.inviteCode = other.inviteCode;
    this.groupNumberVisitor= other.groupNumberVisitor;
    isOnline = false;
  }

  VisitorCheckIn.copyWithVisitorEntry(VisitorEntry other) {
    this.localId = other.id;
    this.fullName = other.fullName;
    this.email = other.email;
    this.phoneNumber = other.phoneNumber;
    this.idCard = other.idCard;
    this.purpose = other.purpose;
    this.visitorType = other.visitorType;
    this.checkOutTimeExpected = other.checkOutTimeExpected;
    this.fromCompany = other.fromCompany;
    this.toCompany = other.toCompany;
    this.contactPersonId = other.contactPersonId;
    this.faceCaptureRepoId = other.faceCaptureRepoId;
    this.faceCaptureFile = other.faceCaptureFile;
    this.signInBy = other.signInBy;
    this.signInType = other.signInType;
    this.floor = other.floor;
    this.imagePath = other.imagePath;
    this.imageIdPath = other.imageIdPath;
    this.imageIdBackPath = other.imageIdBackPath;
    this.toCompanyId = other.toCompanyId;
    this.cardNo = other.cardNo;
    this.goods = other.goods;
    this.receiver = other.receiver;
    this.visitorPosition = other.visitorPosition;
    this.idCardRepoId = other.idCardRepoId;
    this.idCardFile = other.idCardFile;
    this.idCardBackRepoId = other.idCardBackRepoId;
    this.idCardBackFile = other.idCardBackFile;
    this.survey = other.survey;
    this.surveyId = other.surveyId;
    this.gender = other.gender;
    this.passportNo = other.passportNo;
    this.nationality = other.nationality;
    this.birthDay = other.birthDay;
    this.permanentAddress = other.permanentAddress;
    this.departmentRoomNo = other.departmentRoomNo;
    this.inviteCode = other.inviteCode;
    isOnline = false;
  }

  VisitorCheckIn.copyWithVisitorCheckInEntry(VisitorCheckInEntry other) {
    this.localId = other.id;
    this.fullName = other.fullName;
    this.email = other.email;
    this.phoneNumber = other.phoneNumber;
    this.idCard = other.idCard;
    this.purpose = other.purpose;
    this.visitorType = other.visitorType;
    this.checkOutTimeExpected = other.checkOutTimeExpected;
    this.fromCompany = other.fromCompany;
    this.toCompany = other.toCompany;
    this.contactPersonId = other.contactPersonId;
    this.faceCaptureRepoId = other.faceCaptureRepoId;
    this.faceCaptureFile = other.faceCaptureFile;
    this.signInBy = other.signInBy;
    this.signInType = other.signInType;
    this.floor = other.floor;
    this.imagePath = other.imagePath;
    this.imageIdPath = other.imageIdPath;
    this.imageIdBackPath = other.imageIdBackPath;
    this.toCompanyId = other.toCompanyId;
    this.cardNo = other.cardNo;
    this.goods = other.goods;
    this.receiver = other.receiver;
    this.visitorPosition = other.visitorPosition;
    this.idCardRepoId = other.idCardRepoId;
    this.idCardFile = other.idCardFile;
    this.idCardBackRepoId = other.idCardBackRepoId;
    this.idCardBackFile = other.idCardBackFile;
    this.survey = other.survey;
    this.surveyId = other.surveyId;
    this.gender = other.gender;
    this.passportNo = other.passportNo;
    this.nationality = other.nationality;
    this.birthDay = other.birthDay;
    this.permanentAddress = other.permanentAddress;
    this.departmentRoomNo = other.departmentRoomNo;
    this.inviteCode = other.inviteCode;
    this.groupNumberVisitor = other.groupNumberVisitor;
    isOnline = false;
  }


  VisitorCheckIn(
      this.id,
      this.fullName,
      this.email,
      this.phoneNumber,
      this.idCard,
      this.purpose,
      this.visitorId,
      this.visitorType,
      this.checkOutTimeExpected,
      this.fromCompany,
      this.toCompany,
      this.contactPersonId,
      this.faceCaptureRepoId,
      this.faceCaptureFile,
      this.signInBy,
      this.signInType,
      this.toCompanyId,
      this.cardNo,
      this.goods,
      this.receiver,
      this.visitorPosition,
      this.idCardRepoId,
      this.idCardFile,
      this.idCardBackRepoId,
      this.idCardBackFile,
      this.survey,
      this.surveyId,
      this.gender,
      this.passportNo,
      this.nationality,
      this.birthDay,
      this.permanentAddress,
      this.departmentRoomNo,
      this.inviteCode,
      this.groupNumberVisitor,
      this.isOnline,
      this.qrGroupGuestUrl);

  VisitorCheckIn.initPhone(String phone) {
    this.phoneNumber = phone;
  }

  void removeDelivery() {
    this.goods = "";
    this.receiver = "";
  }

  String getGender(BuildContext context) {
    if (gender == 1) {
      return AppLocalizations.of(context).female;
    }
    if (gender == 0) {
      return AppLocalizations.of(context).male;
    }
    return "";
  }

  factory VisitorCheckIn.fromJson(Map<String, dynamic> json) => _$VisitorCheckInFromJson(json);

  Map<String, dynamic> toJson() => _$VisitorCheckInToJson(this);

  factory VisitorCheckIn.createVisitorByInput(BuildContext context, List<CheckInFlow> flows,
      Map<String, TextEditingController> textEditingControllers, VisitorCheckIn visitorBackup) {
    VisitorCheckIn visitorResult = VisitorCheckIn.inital();
    visitorResult.id = visitorBackup.id;
    visitorResult.visitorId = visitorBackup.visitorId;
    visitorResult.toCompany = visitorBackup.toCompany;
    visitorResult.toCompanyId = visitorBackup.toCompanyId;
    visitorResult.floor = visitorBackup.floor;
    visitorResult.visitorType = visitorBackup.visitorType;
    visitorResult.imageIdPath = visitorBackup.imageIdPath;
    visitorResult.imageIdBackPath = visitorBackup.imageIdBackPath;
    visitorResult.imagePath = visitorBackup.imagePath;
    visitorResult.contactPersonId = visitorBackup.contactPersonId;
    visitorResult.birthDay = visitorBackup.birthDay;
    visitorResult.survey = visitorBackup.survey;
    visitorResult.surveyId = visitorBackup.surveyId;
    for (var item in flows) {
      switch (item.stepCode) {
        case StepCode.FULL_NAME:
          {
            visitorResult.fullName = textEditingControllers[StepCode.FULL_NAME]?.text;
            break;
          }
        case StepCode.PHONE_NUMBER:
          {
            visitorResult.phoneNumber = textEditingControllers[StepCode.PHONE_NUMBER]?.text;
            break;
          }
        case StepCode.FROM_COMPANY:
          {
            visitorResult.fromCompany = textEditingControllers[StepCode.FROM_COMPANY]?.text;
            break;
          }
        case StepCode.TO_COMPANY:
          {
            visitorResult.toCompany = textEditingControllers[StepCode.TO_COMPANY]?.text;
            break;
          }
        case StepCode.PURPOSE:
          {
            visitorResult.purpose = textEditingControllers[StepCode.PURPOSE]?.text;
            break;
          }
        case StepCode.ID_CARD:
          {
            visitorResult.idCard = textEditingControllers[StepCode.ID_CARD]?.text;
            break;
          }
        case StepCode.EMAIL:
          {
            visitorResult.email = textEditingControllers[StepCode.EMAIL]?.text;
            break;
          }
        case StepCode.CARD_NO:
          {
            visitorResult.cardNo = textEditingControllers[StepCode.CARD_NO]?.text;
            break;
          }
        case StepCode.VISITOR_POSITION:
          {
            visitorResult.visitorPosition = textEditingControllers[StepCode.VISITOR_POSITION]?.text;
            break;
          }
        case StepCode.GOODS:
          {
            visitorResult.goods = textEditingControllers[StepCode.GOODS]?.text;
            break;
          }
        case StepCode.RECEIVER:
          {
            visitorResult.receiver = textEditingControllers[StepCode.RECEIVER]?.text;
            break;
          }

        case StepCode.GENDER:
          {
            int gender;
            if (textEditingControllers[StepCode.GENDER]?.text == AppLocalizations.of(context).female) {
              gender = 1;
            } else if (textEditingControllers[StepCode.GENDER]?.text == AppLocalizations.of(context).male) {
              gender = 0;
            }
            visitorResult.gender = gender;
            break;
          }
        case StepCode.PASSPORT_NO:
          {
            visitorResult.passportNo = textEditingControllers[StepCode.PASSPORT_NO]?.text;
            break;
          }
        case StepCode.NATIONALITY:
          {
            visitorResult.nationality = textEditingControllers[StepCode.NATIONALITY]?.text;
            break;
          }
        case StepCode.BIRTH_DAY:
          {
            visitorResult.birthDay = textEditingControllers[StepCode.BIRTH_DAY]?.text;
            break;
          }
        case StepCode.PERMANENT_ADDRESS:
          {
            visitorResult.permanentAddress = textEditingControllers[StepCode.PERMANENT_ADDRESS]?.text;
            break;
          }
        case StepCode.ROOM_NO:
          {
            visitorResult.departmentRoomNo = textEditingControllers[StepCode.ROOM_NO]?.text;
            break;
          }
        case StepCode.CHECKOUT_TIME_EXPECTED:
          {
            visitorResult.checkOutTimeExpected = textEditingControllers[StepCode.CHECKOUT_TIME_EXPECTED]?.text;
            break;
          }
        case StepCode.GROUP_NUMBER_VISITOR:
          {
            visitorResult.groupNumberVisitor = int.tryParse(textEditingControllers[StepCode.GROUP_NUMBER_VISITOR]?.text) ?? 2;
            break;
          }
      }
    }
    return visitorResult;
  }

  factory VisitorCheckIn.createVisitorByFlow(List<CheckInFlow> flows, VisitorCheckIn visitorBackup) {
    VisitorCheckIn visitorResult = VisitorCheckIn.inital();
    visitorResult.id = 0.0;
    visitorResult.toCompany = visitorBackup.toCompany;
    visitorResult.toCompanyId = visitorBackup.toCompanyId;
    visitorResult.floor = visitorBackup.floor;
    visitorResult.visitorType = visitorBackup.visitorType;
    visitorResult.birthDay = visitorBackup.birthDay;
    visitorResult.survey = visitorBackup.survey;
    visitorResult.surveyId = visitorBackup.surveyId;
    for (var element in flows) {
      switch (element.stepCode) {
        case StepCode.FULL_NAME:
          {
            if (element.getRequestType() != RequestType.ALWAYS && element.getRequestType() != RequestType.ALWAYS_NO) {
              visitorResult.fullName = visitorBackup.fullName;
            }
            break;
          }
        case StepCode.PHONE_NUMBER:
          {
            if (element.getRequestType() != RequestType.ALWAYS && element.getRequestType() != RequestType.ALWAYS_NO) {
              visitorResult.phoneNumber = visitorBackup.phoneNumber;
            }
            break;
          }
        case StepCode.FROM_COMPANY:
          {
            if (element.getRequestType() != RequestType.ALWAYS && element.getRequestType() != RequestType.ALWAYS_NO) {
              visitorResult.fromCompany = visitorBackup.fromCompany;
            }
            break;
          }
        case StepCode.TO_COMPANY:
          {
            if (element.getRequestType() != RequestType.ALWAYS && element.getRequestType() != RequestType.ALWAYS_NO) {
              visitorResult.toCompany = visitorBackup.toCompany;
            }
            break;
          }
        case StepCode.PURPOSE:
          {
            if (element.getRequestType() != RequestType.ALWAYS && element.getRequestType() != RequestType.ALWAYS_NO) {
              visitorResult.purpose = visitorBackup.purpose;
            }
            break;
          }
        case StepCode.ID_CARD:
          {
//            if (element.getRequestType() != RequestType.ALWAYS &&
//                element.getRequestType() != RequestType.ALWAYS_NO) {
            visitorResult.idCard = visitorBackup.idCard;
//            }
            break;
          }
        case StepCode.EMAIL:
          {
            if (element.getRequestType() != RequestType.ALWAYS && element.getRequestType() != RequestType.ALWAYS_NO) {
              visitorResult.email = visitorBackup.email;
            }
            break;
          }
        case StepCode.CARD_NO:
          {
            if (element.getRequestType() != RequestType.ALWAYS && element.getRequestType() != RequestType.ALWAYS_NO) {
              visitorResult.cardNo = visitorBackup.cardNo;
            }
            break;
          }
        case StepCode.VISITOR_POSITION:
          {
            if (element.getRequestType() != RequestType.ALWAYS && element.getRequestType() != RequestType.ALWAYS_NO) {
              visitorResult.visitorPosition = visitorBackup.visitorPosition;
            }
            break;
          }
        case StepCode.GOODS:
          {
            if (element.getRequestType() != RequestType.ALWAYS && element.getRequestType() != RequestType.ALWAYS_NO) {
              visitorResult.goods = visitorBackup.goods;
            }
            break;
          }
        case StepCode.RECEIVER:
          {
            if (element.getRequestType() != RequestType.ALWAYS && element.getRequestType() != RequestType.ALWAYS_NO) {
              visitorResult.receiver = visitorBackup.receiver;
            }
            break;
          }

        case StepCode.GENDER:
          {
//            if (element.getRequestType() != RequestType.ALWAYS &&
//                element.getRequestType() != RequestType.ALWAYS_NO) {
            visitorResult.gender = visitorBackup.gender;
//            }
            break;
          }
        case StepCode.PASSPORT_NO:
          {
//            if (element.getRequestType() != RequestType.ALWAYS &&
//                element.getRequestType() != RequestType.ALWAYS_NO) {
            visitorResult.passportNo = visitorBackup.passportNo;
//            }
            break;
          }
        case StepCode.NATIONALITY:
          {
//            if (element.getRequestType() != RequestType.ALWAYS &&
//                element.getRequestType() != RequestType.ALWAYS_NO) {
            visitorResult.nationality = visitorBackup.nationality;
//            }
            break;
          }
        case StepCode.BIRTH_DAY:
          {
//            if (element.getRequestType() != RequestType.ALWAYS &&
//                element.getRequestType() != RequestType.ALWAYS_NO) {
            visitorResult.birthDay = visitorBackup.birthDay;
//            }
            break;
          }
        case StepCode.PERMANENT_ADDRESS:
          {
//            if (element.getRequestType() != RequestType.ALWAYS &&
//                element.getRequestType() != RequestType.ALWAYS_NO) {
            visitorResult.permanentAddress = visitorBackup.permanentAddress;
//            }
            break;
          }
        case StepCode.ROOM_NO:
          {
            if (element.getRequestType() != RequestType.ALWAYS && element.getRequestType() != RequestType.ALWAYS_NO) {
              visitorResult.departmentRoomNo = visitorBackup.departmentRoomNo;
            }
            break;
          }
        case StepCode.CHECKOUT_TIME_EXPECTED:
          {
            if (element.getRequestType() != RequestType.ALWAYS && element.getRequestType() != RequestType.ALWAYS_NO) {
              visitorResult.checkOutTimeExpected = visitorBackup.checkOutTimeExpected;
            }
            break;
          }
        case StepCode.GROUP_NUMBER_VISITOR:
          {
            if (element.getRequestType() != RequestType.ALWAYS && element.getRequestType() != RequestType.ALWAYS_NO) {
              visitorResult.groupNumberVisitor = visitorBackup.groupNumberVisitor ?? 2;
            }
            break;
          }
      }
    }
    return visitorResult;
  }

  @override
  String toString() {
    return 'VisitorCheckIn{id: $id, fullName: $fullName, email: $email, phoneNumber: $phoneNumber, idCard: $idCard, purpose: $purpose, visitorId: $visitorId, visitorType: $visitorType, fromCompany: $fromCompany, toCompany: $toCompany, contactPersonId: $contactPersonId, faceCaptureRepoId: $faceCaptureRepoId, signInBy: $signInBy, signInType: $signInType, imagePath: $imagePath, toCompanyId: $toCompanyId, cardNo: $cardNo, goods: $goods, receiver: $receiver, visitorPosition: $visitorPosition}';
  }
}
