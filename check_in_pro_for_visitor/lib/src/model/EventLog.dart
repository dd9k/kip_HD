import 'package:check_in_pro_for_visitor/src/constants/Constants.dart';
import 'package:check_in_pro_for_visitor/src/database/Database.dart';
import 'package:check_in_pro_for_visitor/src/model/VisitorCheckIn.dart';
import 'package:json_annotation/json_annotation.dart';

part 'EventLog.g.dart';

@JsonSerializable()
class EventLog {
  @JsonKey(ignore: true)
  String id;

  @JsonKey(name: 'guestId', defaultValue: 0.0)
  double guestId;

  @JsonKey(name: 'fullName')
  String fullName;

  @JsonKey(name: 'email')
  String email;

  @JsonKey(name: 'idCard')
  String idCard;

  @JsonKey(name: 'branchId')
  int branchId;

  @JsonKey(name: 'visitorType')
  String visitorType;

  @JsonKey(name: 'inviteCode')
  String inviteCode;

  @JsonKey(name: 'timeZone')
  String timeZone;

  @JsonKey(name: 'phoneNumber')
  String phoneNumber;

  @JsonKey(name: 'signInType')
  String signInType = Constants.TYPE_CHECK;

  @JsonKey(name: 'signOutType')
  String signOutType = Constants.TYPE_CHECK;

  @JsonKey(name: 'registerType')
  String registerType = Constants.TYPE_CHECK;

  @JsonKey(name: 'signInBy')
  int signInBy;

  @JsonKey(ignore: true)
  String imagePath = "";

  @JsonKey(ignore: true)
  String imageIdPath = "";

  @JsonKey(ignore: true)
  String imageIdBackPath = "";

  @JsonKey(name: 'eventId')
  double eventId;

  @JsonKey(ignore: true)
  String status;

  @JsonKey(ignore: true)
  bool syncFail = false;

  @JsonKey(name: 'signIn')
  int signIn;

  @JsonKey(name: 'signOut')
  int signOut;

  @JsonKey(name: 'feedback')
  String feedback;

  @JsonKey(name: 'rating')
  int rating;

  @JsonKey(name: 'isNew')
  bool isNew;

  @JsonKey(name: 'faceCaptureFile')
  String faceCaptureFile;

  @JsonKey(name: 'surveyAnswer')
  String survey;

  @JsonKey(name: 'isOnline')
  bool isOnline = false;

  @JsonKey(name: 'surveyId')
  double surveyId;

  @JsonKey(ignore: true)
  int lastUpdate;

  @JsonKey(name: 'visitorLogId')
  double visitorLogId;

  EventLog.copyWithEntry(EventLogEntry eventLog) {
    this.id = eventLog.id;
    this.guestId = eventLog.guestId;
    this.fullName = eventLog.fullName;
    this.email = eventLog.email;
    this.idCard = eventLog.idCard;
    this.branchId = eventLog.branchId;
    this.inviteCode = eventLog.inviteCode;
    this.phoneNumber = eventLog.phoneNumber;
    this.signInType = Constants.TYPE_CHECK;
    this.signOutType = Constants.TYPE_CHECK;
    this.registerType = Constants.TYPE_CHECK;
    this.signInBy = eventLog.signInBy;
    this.imagePath = eventLog.imagePath;
    this.imageIdPath = eventLog.imageIdPath;
    this.imageIdBackPath = eventLog.imageIdBackPath;
    this.eventId = eventLog.eventId;
    this.signIn = eventLog.signIn;
    this.signOut = eventLog.signOut;
    this.feedback = eventLog.feedback;
    this.rating = eventLog.rating;
    this.status = eventLog.status;
    this.visitorType = eventLog.visitorType;
    this.timeZone = eventLog.timeZone;
    this.syncFail = eventLog.syncFail;
    this.isNew = eventLog.isNew;
    this.faceCaptureFile = eventLog.faceCaptureFile;
    this.lastUpdate = eventLog.lastUpdate;
    this.visitorLogId = eventLog.visitorLogId;
    isOnline = false;
  }

  EventLog.copyWithPreEntry(EventPreRegisterEntry eventLog) {
    this.id = eventLog.id;
    this.guestId = eventLog.guestId;
    this.fullName = eventLog.fullName;
    this.email = eventLog.email;
    this.idCard = eventLog.idCard;
    this.branchId = eventLog.branchId;
    this.inviteCode = eventLog.inviteCode;
    this.phoneNumber = eventLog.phoneNumber;
    this.signInType = Constants.TYPE_CHECK;
    this.signOutType = Constants.TYPE_CHECK;
    this.registerType = Constants.TYPE_CHECK;
    this.signInBy = eventLog.signInBy;
    this.imagePath = eventLog.imagePath;
    this.imageIdPath = eventLog.imageIdPath;
    this.imageIdBackPath = eventLog.imageIdBackPath;
    this.eventId = eventLog.eventId;
    this.signIn = eventLog.signIn;
    this.signOut = eventLog.signOut;
    this.feedback = eventLog.feedback;
    this.rating = eventLog.rating;
    this.status = eventLog.status;
    this.visitorType = eventLog.visitorType;
    this.timeZone = eventLog.timeZone;
    this.syncFail = eventLog.syncFail;
    this.isNew = eventLog.isNew;
    this.faceCaptureFile = eventLog.faceCaptureFile;
    isOnline = false;
  }

  EventLog.copyWithVisitor(VisitorCheckIn visitor, EventLog other) {
    this.fullName = visitor.fullName;
    this.email = visitor.email;
    this.idCard = visitor.idCard;
    this.inviteCode = visitor.inviteCode;
    this.phoneNumber = visitor.phoneNumber;
    this.signInType = Constants.TYPE_CHECK;
    this.signOutType = Constants.TYPE_CHECK;
    this.registerType = Constants.TYPE_CHECK;
    this.signInBy = visitor.signInBy;
    this.imagePath = visitor.imagePath;
    this.imageIdPath = visitor.imageIdPath;
    this.imageIdBackPath = visitor.imageIdBackPath;
    this.branchId = other.branchId;
    this.eventId = other.eventId;
    this.visitorType = other.visitorType;
    this.timeZone = other.timeZone;
    this.syncFail = other.syncFail;
    isOnline = false;
  }

  EventLog(
      this.guestId,
      this.fullName,
      this.email,
      this.idCard,
      this.branchId,
      this.visitorType,
      this.inviteCode,
      this.timeZone,
      this.phoneNumber,
      this.signInType,
      this.signOutType,
      this.signInBy,
      this.eventId,
      this.signIn,
      this.signOut,
      this.feedback,
      this.rating,
      this.isNew,
      this.isOnline,
      this.visitorLogId);

  EventLog.init();

  factory EventLog.fromJson(Map<String, dynamic> json) => _$EventLogFromJson(json);

  Map<String, dynamic> toJson() => _$EventLogToJson(this);
}
