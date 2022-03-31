import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:check_in_pro_for_visitor/src/constants/Constants.dart';
import 'package:check_in_pro_for_visitor/src/model/BaseResponse.dart';
import 'package:check_in_pro_for_visitor/src/model/Errors.dart';
import 'package:check_in_pro_for_visitor/src/model/EventLog.dart';
import 'package:check_in_pro_for_visitor/src/model/QuestionSurvey.dart';
import 'package:check_in_pro_for_visitor/src/model/RepoUpload.dart';
import 'package:check_in_pro_for_visitor/src/model/SurveyForm.dart';
import 'package:check_in_pro_for_visitor/src/model/VisitorCheckIn.dart';
import 'package:check_in_pro_for_visitor/src/screens/MainNotifier.dart';
import 'package:check_in_pro_for_visitor/src/screens/Thankyou/ThankYouScreen.dart';
import 'package:check_in_pro_for_visitor/src/screens/waiting/WaitingScreen.dart';
import 'package:check_in_pro_for_visitor/src/services/ApiCallBack.dart';
import 'package:check_in_pro_for_visitor/src/services/RequestApi.dart';
import 'package:check_in_pro_for_visitor/src/services/ServiceLocator.dart';
import 'package:check_in_pro_for_visitor/src/services/SyncService.dart';
import 'package:check_in_pro_for_visitor/src/services/printService/PrinterModel.dart';
import 'package:check_in_pro_for_visitor/src/utilities/Validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:uuid/uuid.dart';

class SurveyNotifier extends MainNotifier {
  final GlobalKey repaintBoundary = new GlobalKey();
  String inviteCode;
  VisitorCheckIn visitor;
  var visitorType = Constants.VT_VISITORS;
  bool isBuilding = false;
  bool isDoneAnyWay = false;
  PrinterModel printer;
  bool isCapture = false;
  bool isQRScan = false;
  EventLog eventLog;
  List<QuestionSurvey> listItem = List();
  bool isValidate = false;
  SurveyForm surveyForm;
  String langSaved = Constants.EN_CODE;
  bool isReload = false;
  List<QuestionSurvey> listOld = List();
  AsyncMemoizer<List<QuestionSurvey>> memCache = AsyncMemoizer();
  ScrollController scrollController = ScrollController();
  CancelableOperation cancelEvent;
  Timer timerDoneAnyWay;
  RoundedLoadingButtonController btnController = new RoundedLoadingButtonController();

  CancelableOperation cancelCheckIn;
  bool isDoneIdBack = false;
  bool isDoneIdFont = false;
  bool isDoneIdFace = false;
  bool isEventMode = false;
  bool isDie = false;

  CancelableOperation cancelableOperation;

  CancelableOperation cancelableUploadID;
  CancelableOperation cancelableUploadIDBack;

  Future<List<QuestionSurvey>> getSurvey(BuildContext context) async {
    return memCache.runOnce(() async {
      langSaved = preferences.getString(Constants.KEY_LANGUAGE) ?? Constants.VN_CODE;
      await appLocalizations.initLocalLang();
      surveyForm = await utilities.getSurvey();
      if (surveyForm.customFormData.bodyTemperature == 1) {
        temperatureHardCode();
      }
      listItem.addAll(surveyForm.customFormData.questions);
      listItem?.removeWhere((element) => element.isHidden == 1);
      listItem?.sort((a, b) => a.sort.compareTo(b.sort));
      visitor = arguments["visitor"] as VisitorCheckIn;
      inviteCode = arguments["inviteCode"] as String;
      visitorType = await utilities.getTypeInDb(context, visitor.visitorType);
      isBuilding = await utilities.checkIsBuilding(preferences, db);
      printer = await utilities.getPrinter();
      isCapture = (arguments["isCapture"] as bool) ?? false;
      isQRScan = (arguments["isQRScan"] as bool) ?? false;
      isEventMode = preferences.getBool(Constants.KEY_EVENT) ?? false;
      isDie = arguments["isDie"] as bool ?? false;
      if (isEventMode) {
        eventLog = arguments["eventLog"] as EventLog;
      }
      if (visitor.survey != null && visitor.survey.isNotEmpty) {
        List<dynamic> convert = jsonDecode(visitor.survey);
        listOld = convert.map((e) => QuestionSurvey.fromJson(e)).toList();
      }
      scrollController.addListener(() {
        utilities.moveToWaiting();
      });
      return listItem;
    });
  }

  Future<void> moveToNext(BuildContext context) async {
    isValidate = false;
    isDoneIdBack = false;
    isDoneIdFont = false;
    isDoneIdFace = false;
    List<QuestionSurvey> listSurvey = List();
    listItem.forEach((QuestionSurvey element) {
      if (checkingValidator(element).isNotEmpty) {
        isValidate = true;
      }
      listSurvey.add(element.createSubmit());
    });
    if (!isValidate) {
      VisitorCheckIn visitorCheckIn = arguments["visitor"] as VisitorCheckIn;
      visitorCheckIn.survey = jsonEncode(listSurvey);
      visitorCheckIn.surveyId = surveyForm.customFormData.surveyId;
      arguments["visitor"] = visitorCheckIn;
      FocusScope.of(context).requestFocus(FocusNode());
      if ((parent.isConnection && parent.isBEAlive) || isEventMode) {
        bool isUpload = visitorCheckIn?.imagePath?.isNotEmpty == true ||
            visitorCheckIn?.imagePath?.isNotEmpty == true ||
            visitorCheckIn?.imagePath?.isNotEmpty == true;
        if (isUpload && !isEventMode) {
          if (visitorCheckIn?.imagePath?.isNotEmpty == true && !isEventMode) {
            uploadFace(visitorCheckIn);
          } else {
            isDoneIdFace = true;
          }
          if (visitorCheckIn?.imageIdPath?.isNotEmpty == true && !isEventMode) {
            uploadIdCardOnline(visitorCheckIn, false);
          } else {
            isDoneIdFont = true;
          }
          if (visitorCheckIn?.imageIdBackPath?.isNotEmpty == true && !isEventMode) {
            uploadIdCardOnline(visitorCheckIn, true);
          } else {
            isDoneIdBack = true;
          }
        } else {
          doCheckInJob(visitorCheckIn);
        }
      } else {
        await actionOffline(visitorCheckIn);
      }
    } else {
      isReload = !isReload;
      notifyListeners();
    }
  }

  Future actionOffline(VisitorCheckIn visitorCheckIn) async {
    String pathFace;
    if (visitorCheckIn?.imagePath?.isNotEmpty == true) {
      String fileName = '${DateTime.now()}.png';
      String folderName = Constants.FOLDER_FACE_OFFLINE;
      pathFace = (await utilities.saveLocalFile(folderName, "", fileName, Constants.PNG_ETX, File(visitorCheckIn.imagePath).readAsBytesSync())).path;
      visitorCheckIn.imagePath = fileName;
    }
    if (visitorCheckIn?.imageIdPath?.isNotEmpty == true) {
      String fileName = '${DateTime.now()}${Constants.SCAN_VISION}.png';
      String folderName = Constants.FOLDER_ID_OFFLINE;
      await utilities.saveLocalFile(folderName, "", fileName, Constants.PNG_ETX, File(visitorCheckIn.imageIdPath).readAsBytesSync());
      visitorCheckIn.imageIdPath = fileName;
    }
    if (visitorCheckIn?.imageIdBackPath?.isNotEmpty == true) {
      String fileName = '${DateTime.now()}${Constants.BACKSIDE_SCAN_VISION}.png';
      String folderName = Constants.FOLDER_ID_BACK_OFFLINE;
      await utilities.saveLocalFile(folderName, "", fileName, Constants.PNG_ETX, File(visitorCheckIn.imageIdBackPath).readAsBytesSync());
      visitorCheckIn.imageIdBackPath = fileName;
    }
    await callApiAC(visitorCheckIn, pathFace);
    await db.visitorCheckInDAO.insert(visitorCheckIn);
    handlerDone(visitorCheckIn);
  }

  Future<bool> callApiAC(VisitorCheckIn visitorCheckIn, String imagePath) async {
    Completer completer = Completer<bool>();
    ApiCallBack callBackLogin = ApiCallBack((BaseResponse baseResponse) async {
      var authenticationString = JsonEncoder().convert(baseResponse.data);
      preferences.setString(Constants.KEY_AUTHENTICATE_AC, authenticationString);
      final uuid = Uuid();
      String fileName = uuid.v1();
      ApiRequest().requestLogBackup(context, visitorCheckIn.fullName, visitorCheckIn.phoneNumber, fileName, imagePath,
          ApiCallBack((BaseResponse baseResponse) async {
            completer.complete(true);
          }, (Errors message) async {
            completer.complete(false);
          }));
    }, (Errors message) async {
      completer.complete(false);
    });
    ApiRequest().requestLoginAC(context, callBackLogin);
    return completer.future;
  }

  void doCheckInJob(VisitorCheckIn visitorCheckIn) {
    if (isEventMode) {
      eventLog.signIn = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
      eventLog?.imagePath = visitorCheckIn.imagePath;
      eventLog?.imageIdBackPath = visitorCheckIn.imageIdBackPath;
      eventLog?.imageIdPath = visitorCheckIn.imageIdPath;
      eventLog?.surveyId = visitorCheckIn.surveyId;
      eventLog?.survey = visitorCheckIn.survey;
      locator<SyncService>().syncEventNow(context, eventLog);
      btnController?.success();
      handlerDone(visitorCheckIn);
    } else {
      if (isQRScan) {
        actionEventMode(visitorCheckIn);
      } else {
        registerVisitor(visitorCheckIn);
      }
    }
  }

  Future actionEventMode(VisitorCheckIn visitorCheckIn) async {
    ApiCallBack callBack = ApiCallBack((BaseResponse baseResponse) async {
      btnController?.success();
      handlerDone(VisitorCheckIn.fromJson(baseResponse.data));
    }, (Errors message) async {
      btnController?.stop();
      var contentError = message.description;
      if (message.description.contains("field_name")) {
        contentError = appLocalizations
            .errorInviteCode
            .replaceAll("field_name", appLocalizations.inviteCode);
      }
      if (message.code != -2) {
        utilities.showErrorPop(context, contentError, Constants.AUTO_HIDE_LONG, () {}, callbackDismiss: () {
          utilities.moveToWaiting();
        });
      } else {}
    });
    var userInfor = await utilities.getUserInfor();
    var locationId = userInfor.deviceInfo.branchId ?? 0;
    var eventId = preferences.getDouble(Constants.KEY_EVENT_ID);
    cancelEvent = await ApiRequest().requestRegisterEvent(context, locationId, visitorCheckIn, eventId, callBack);
    await cancelEvent.valueOrCancellation();
  }

//  Future<void> doneCheckIn(BuildContext context, VisitorCheckIn visitorCheckIn, bool isCapture) async {
//    var isPrint = await utilities.checkIsPrint(context, visitor?.visitorType);
//    if (isPrint) {
//      await Future.delayed(new Duration(milliseconds: 500));
//      callPrinter(context, visitorCheckIn);
//    } else {
//      handlerDone();
//    }
//  }

  void handlerDone(VisitorCheckIn visitorCheckIn) {
    isDoneAnyWay = true;
    navigationService
        .pushNamedAndRemoveUntil(ThankYouScreen.route_name, WaitingScreen.route_name, arguments: {
      'visitor': visitorCheckIn,
      'isCheckOut' : arguments["isCheckOut"],
      'qrGroupGuestUrl': arguments["qrGroupGuestUrl"]
    });
  }

//  Future<void> callPrinter(BuildContext context, VisitorCheckIn visitorCheckIn) async {
//    timerDoneAnyWay = Timer(Duration(seconds: Constants.TIMEOUT_PRINTER), () {
//      if (!isDoneAnyWay) {
//        handlerDone();
//      }
//    });
//    String response = "";
//    try {
//      if (printer != null) {
//        RenderRepaintBoundary boundary = repaintBoundary.currentContext.findRenderObject();
//        await utilities.printJob(printer, boundary);
//        if (!isDoneAnyWay) {
//          timerDoneAnyWay?.cancel();
//          handlerDone();
//        }
//      }
//    } on PlatformException catch (e) {
//      response = "Failed to Invoke: '${e.message}'.";
//      utilities.printLog("$response ");
//      if (!isDoneAnyWay) {
//        timerDoneAnyWay?.cancel();
//        handlerDone();
//      }
//    } catch (e) {}
//  }

  void temperatureHardCode() {
    Map<String, String> mapTitle = Map();
    Map<String, String> mapValue = Map();
    mapTitle[Constants.VN_CODE] = appLocalizations.titleSurvey0Vi;
    mapTitle[Constants.EN_CODE] = appLocalizations.titleSurvey0En;
    mapValue[Constants.VN_CODE] = appLocalizations.value0Survey2Vi;
    mapValue[Constants.EN_CODE] = appLocalizations.value0Survey2En;
    String title = jsonEncode(mapTitle);
    String value = jsonEncode(mapValue);
    listItem.add(QuestionSurvey(title, -1, [value], List(), "5", "1", 1, 0, -1));
  }

  String checkingValidator(QuestionSurvey questionSurvey) {
    if (questionSurvey.getSurveyType() != QuestionType.EDIT_TEXT) {
      if (questionSurvey.isRequired == 1 && questionSurvey?.getAnswer()?.isEmpty == true) {
        questionSurvey.errorText = appLocalizations.surveyValidate;
      } else {
        questionSurvey.errorText = "";
      }
      return questionSurvey.errorText;
    }
    switch (questionSurvey.getSurveySubType()) {
      case QuestionSubType.PHONE:
        {
          if (questionSurvey.getAnswer().isEmpty || utilities.getStringByLang(questionSurvey.getAnswerByIndex(0), langSaved).isEmpty) {
            if (questionSurvey.isRequired == 1) {
              questionSurvey.errorText = appLocalizations.surveyValidate;
            } else {
              questionSurvey.errorText = "";
            }
          } else {
            RegExp regExp = new RegExp(Validator.patternPhone);
            if (regExp.hasMatch(questionSurvey.getAnswerOptionValue(questionSurvey.getAnswerByIndex(0), langSaved))) {
              questionSurvey.errorText = "";
            } else {
              questionSurvey.errorText = appLocalizations.errorMinPhone;
            }
          }
          return questionSurvey.errorText;
        }

      case QuestionSubType.EMAIL:
        {
          if (questionSurvey.getAnswer().isEmpty || utilities.getStringByLang(questionSurvey.getAnswerByIndex(0), langSaved).isEmpty) {
            if (questionSurvey.isRequired == 1) {
              questionSurvey.errorText = appLocalizations.surveyValidate;
            } else {
              questionSurvey.errorText = "";
            }
          } else {
            RegExp regExp = RegExp(Validator.patternEmail);
            if (regExp.hasMatch(questionSurvey.getAnswerOptionValue(questionSurvey.getAnswerByIndex(0), langSaved))) {
              questionSurvey.errorText = "";
            } else {
              questionSurvey.errorText = appLocalizations.validateEmail;
            }
          }
          return questionSurvey.errorText;
        }

      default:
        {
          if (questionSurvey.isRequired == 1 && (questionSurvey.getAnswer().isEmpty || utilities.getStringByLang(questionSurvey.getAnswerByIndex(0), langSaved).isEmpty)) {
            questionSurvey.errorText = appLocalizations.surveyValidate;
          } else {
            questionSurvey.errorText = "";
          }
          return questionSurvey.errorText;
        }
    }
  }

  void actionWhenUploadDone(VisitorCheckIn visitorCheckIn) {
    if (isDoneIdBack && isDoneIdFace && isDoneIdFont) {
      doCheckInJob(visitorCheckIn);
    }
  }

  Future<void> registerVisitor(VisitorCheckIn visitor) async {
    ApiCallBack listCallBack = ApiCallBack((BaseResponse baseResponse) async {
      //Callback SUCCESS
      VisitorCheckIn visitorCheckIn = VisitorCheckIn.fromJson(baseResponse.data);
      db.visitorDAO.insertNewOrUpdateOld(visitor);
      if (visitorCheckIn.fromCompany != null && visitorCheckIn.fromCompany.isNotEmpty) {
        db.visitorCompanyDAO.insertCompanyName(visitorCheckIn.fromCompany.trim());
      }
      handlerDone(visitorCheckIn);
    }, (Errors message) async {
      //Callback ERROR
      if (message.code == ApiRequest.CODE_DIE) {
        actionOffline(visitor);
      } else if (message.code != -2) {
        utilities.showErrorPop(context, message.description, null, null);
      }
    });

    cancelCheckIn = await ApiRequest().requestRegisterVisitor(context, visitor.toJson(), listCallBack);
  }

  Future uploadIdCardOnline(VisitorCheckIn visitorCheckIn, bool isBack) async {
    ApiCallBack callBack = ApiCallBack((BaseResponse baseResponse) async {
      var repoUpload = RepoUpload.fromJson(baseResponse.data);
      if (isBack) {
        visitorCheckIn.idCardBackRepoId = repoUpload.captureFaceRepoId;
        visitorCheckIn.idCardBackFile = repoUpload.captureFaceFile;
        isDoneIdBack = true;
      } else {
        visitorCheckIn.idCardRepoId = repoUpload.captureFaceRepoId;
        visitorCheckIn.idCardFile = repoUpload.captureFaceFile;
        isDoneIdFont = true;
      }
      actionWhenUploadDone(visitorCheckIn);
    }, (Errors message) {
      if (message.code != -2) {
        if (isBack) {
          isDoneIdBack = true;
        } else {
          isDoneIdFont = true;
        }
        actionWhenUploadDone(visitorCheckIn);
      } else {
        btnController?.stop();
      }
    });
    var convertCancel = isBack ? cancelableUploadIDBack : cancelableUploadID;
    convertCancel = await ApiRequest().requestUploadIDCard(context, isBack ? visitorCheckIn.imageIdBackPath : visitorCheckIn.imageIdPath, callBack);
    await convertCancel.valueOrCancellation();
  }

  Future uploadFace(VisitorCheckIn visitorCheckIn) async {
    ApiCallBack callBack = ApiCallBack((BaseResponse baseResponse) async {
      var repoUpload = RepoUpload.fromJson(baseResponse.data);
      visitorCheckIn.faceCaptureRepoId = repoUpload.captureFaceRepoId;
      visitorCheckIn.faceCaptureFile = repoUpload.captureFaceFile;
      isDoneIdFace = true;
      actionWhenUploadDone(visitorCheckIn);
    }, (Errors message) {
      if (message.code == ApiRequest.CODE_DIE) {
        actionOffline(visitorCheckIn);
      } else {
        if (message.code != -2) {
          utilities.showErrorPop(context, message.description, Constants.AUTO_HIDE_LONG, () {
            btnController?.stop();
          });
        } else {
          btnController?.stop();
        } 
      }
    });
    cancelableOperation = await ApiRequest().requestUploadFace(context, visitorCheckIn.imagePath, callBack);
    await cancelableOperation.valueOrCancellation();
  }

  @override
  void dispose() {
    timerDoneAnyWay?.cancel();
    cancelEvent?.cancel();
    cancelableOperation?.cancel();
    cancelCheckIn?.cancel();
    cancelableUploadID?.cancel();
    cancelableUploadIDBack?.cancel();
    super.dispose();
  }
}
