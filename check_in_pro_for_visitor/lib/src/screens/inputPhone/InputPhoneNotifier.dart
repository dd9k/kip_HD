import 'dart:async';
import 'dart:convert';
import 'package:app_settings/app_settings.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:async/async.dart';
import 'package:check_in_pro_for_visitor/src/constants/AppString.dart';
import 'package:check_in_pro_for_visitor/src/constants/Constants.dart';
import 'package:check_in_pro_for_visitor/src/model/BaseResponse.dart';
import 'package:check_in_pro_for_visitor/src/model/CheckInFlow.dart';
import 'package:check_in_pro_for_visitor/src/model/CompanyBuilding.dart';
import 'package:check_in_pro_for_visitor/src/model/Errors.dart';
import 'package:check_in_pro_for_visitor/src/model/EventDetail.dart';
import 'package:check_in_pro_for_visitor/src/model/EventLog.dart';
import 'package:check_in_pro_for_visitor/src/model/FormatQRCode.dart';
import 'package:check_in_pro_for_visitor/src/model/RepoUpload.dart';
import 'package:check_in_pro_for_visitor/src/model/TakePhotoStep.dart';
import 'package:check_in_pro_for_visitor/src/model/ValidateEvent.dart';
import 'package:check_in_pro_for_visitor/src/model/VisitorCheckIn.dart';
import 'package:check_in_pro_for_visitor/src/model/VisitorType.dart';
import 'package:check_in_pro_for_visitor/src/screens/MainNotifier.dart';
import 'package:check_in_pro_for_visitor/src/screens/Thankyou/ThankYouScreen.dart';
import 'package:check_in_pro_for_visitor/src/screens/covidScreen/CovidScreen.dart';
import 'package:check_in_pro_for_visitor/src/screens/inputInformation/InputInformationScreen.dart';
import 'package:check_in_pro_for_visitor/src/screens/survey/SurveyScreen.dart';
import 'package:check_in_pro_for_visitor/src/screens/waiting/WaitingScreen.dart';
import 'package:check_in_pro_for_visitor/src/services/ApiCallBack.dart';
import 'package:check_in_pro_for_visitor/src/services/NavigationService.dart';
import 'package:check_in_pro_for_visitor/src/services/RequestApi.dart';
import 'package:check_in_pro_for_visitor/src/services/ServiceLocator.dart';
import 'package:check_in_pro_for_visitor/src/services/SyncService.dart';
import 'package:check_in_pro_for_visitor/src/utilities/Utilities.dart';
import 'package:check_in_pro_for_visitor/src/widgetUtilities/PopupTakePhoto/PopupTakePhoto.dart';
import 'package:check_in_pro_for_visitor/src/widgetUtilities/PopupTakePhoto/PopupTakePhotoNotifier.dart';
import 'package:check_in_pro_for_visitor/src/widgetUtilities/awesomeDialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class InputPhoneNotifier extends MainNotifier {
  GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool isEventMode = false;
  bool isLoadCamera = true;
  bool isShowClear = false;
  bool isLoading = false;
  bool isShowLogo = true;
  bool isDie = false;
  String inviteCode;
  bool isDelivery = false;
  bool isReturn = false;
  CancelableOperation cancelSearch;
  RoundedLoadingButtonController btnController = new RoundedLoadingButtonController();
  String qrCodeStr;
  VisitorType visitorType;
  int isSelectedType = 0;
  List<VisitorType> listType = List();
  AsyncMemoizer<List<VisitorType>> memCache = AsyncMemoizer();
  QRViewController controller;
  bool isScanned = false;
  var isScanIdCard = false;
  VisitorCheckIn visitorBackup;
  bool isHaveType = false;
  EventLog eventLog;
  EventDetail eventDetail;

  CancelableOperation cancelableUploadID;
  CancelableOperation cancelableUploadIDBack;
  bool isDoneIdBack = false;
  bool isDoneIdFont = false;
  bool isDoneIdFace = false;
  bool isQRScan = false;
  bool isCapture = false;
  bool isSurvey = false;
  bool isAllowContact = false;
  bool isCovid = false;
  String templateCode = TypeVisitor.GUEST;
  CancelableOperation cancelableOperation;
  final assetsAudioPlayer = AssetsAudioPlayer();
  String phone;
  bool isShowQRCode = false;

  CancelableOperation cancelEvent;
  var eventId;

  void showClear(bool isShow) {
    isShowClear = isShow;
    notifyListeners();
  }

  Future showScanQR() async {
    bool checkPermission = await Utilities().checkCameraPermission();
    if (!checkPermission) {
      Utilities().showTwoButtonDialog(
          context,
          DialogType.INFO,
          null,
          appLocalizations.noPermissionTitle,
          appLocalizations.noPermissionCamera,
          appLocalizations.btnSkip,
          appLocalizations.btnOpenSetting,
              () async {}, () {
        AppSettings.openAppSettings();
      });
    } else {
      isShowQRCode = !isShowQRCode;
      notifyListeners();
    }
  }

  Future<void> startStream() async {
    controller.scannedDataStream.listen((scanData) async {
      if (this.controller != null && !isScanned) {
//        utilities.printLog("detect...........", isDebug: true);
        this.isScanned = true;
        this.controller.pauseCamera();
        getDataFromQR(scanData.code);
        await Future.delayed(const Duration(milliseconds: 500));
        this.controller.resumeCamera();
      }
    });
  }

  void getDataFromQR(String scanData) {
    try {
      FormatQRCode formatQRCode = FormatQRCode.fromJson(jsonDecode(scanData));
      qrCodeStr = formatQRCode.data;
      notifyListeners();
      utilities.tryActionLoadingBtn(btnController, BtnLoadingAction.START);
    } catch (e) {
      utilities.showErrorPopNo(context, appLocalizations.invalidQR, Constants.AUTO_HIDE_LESS, callbackDismiss: () {
        actionResetState(false);
      });
    }
  }

  void actionResetState(bool isClearQR) {
    isLoading = false;
    utilities.tryActionLoadingBtn(btnController, BtnLoadingAction.STOP);
//    utilities.printLog("actionResetState...........", isDebug: true);
    this.isScanned = false;
    if (isClearQR) {
      this.qrCodeStr = '';
    }
    utilities.moveToWaiting();
    notifyListeners();
  }

  Future<List<VisitorType>> getInitValue() async {
    return memCache.runOnce(() async {
      listType = await db.visitorTypeDAO.getAlls();
      listType.removeWhere((element) => element.settingKey == TypeVisitor.DELIVERY || element.settingKey == TypeVisitor.VISITOR);
      visitorBackup = arguments["visitor"] as VisitorCheckIn;
      isHaveType = visitorBackup.visitorType != null;
      eventId = preferences.getDouble(Constants.KEY_EVENT_ID);
      isEventMode = preferences.getBool(Constants.KEY_EVENT) ?? false;
      if (isEventMode) {
        eventDetail = arguments["eventDetail"] as EventDetail;
      }
      if (!isDelivery) {
        var isEventMode = preferences.getBool(Constants.KEY_EVENT) ?? false;
        if (isEventMode) {
          templateCode = TemplateCode.VISITOR;
        } else if (visitorBackup.visitorType != null && visitorBackup.visitorType.isNotEmpty) {
          templateCode = visitorBackup.visitorType;
        } else if (listType != null && listType.isNotEmpty) {
          templateCode = listType[0].settingKey;
        } else {
          templateCode = TemplateCode.GUEST;
        }
      } else {
        templateCode = TemplateCode.DELIVERY;
      }
      visitorBackup.visitorType = templateCode;
      await updateConfig(templateCode);
      return listType;
    });
  }

  Future updateConfig(String templateCode) async {
    isScanIdCard = await utilities.checkIsScanId(context, templateCode);
    isCapture = await utilities.checkIsCapture(context, templateCode);
    isSurvey = await utilities.isSurveyCustom(context, templateCode);
    isAllowContact = await utilities.checkAllowContact(context, templateCode);
    isCovid = await utilities.isSurveyCovid(context, templateCode);
  }

  Future<void> reloadCamera() async {
    qrKey = GlobalKey(debugLabel: 'QR');
    isLoadCamera = false;
    notifyListeners();
    await Future.delayed(Duration(milliseconds: 700));
    isLoadCamera = true;
    notifyListeners();
  }

  Future validateInput(String phone, String inviteCode) async {
    this.phone = phone;
    isLoading = true;
    isDoneIdFace = false;
    isDoneIdFont = false;
    isDoneIdBack = false;
    notifyListeners();
    if (!isEventMode) {
      if (isHaveType) {
        if (visitorBackup.visitorType == TemplateCode.VISITOR || inviteCode != null) {
          isQRScan = true;
          validateInvite(inviteCode, phone, false);
        } else {
          isQRScan = false;
          searchVisitor(phone);
        }
      } else {
        await updateConfig(templateCode);
        if (!parent.isConnection && phone != null) {
          searchVisitor(phone);
        } else {
          validateInvite(inviteCode, phone, true);
        }
      }
    } else {
      validateEvent(inviteCode, phone);
    }
  }

  Future validateEvent(String inviteCode, String phoneNumber) async {
    String errorEvent = await db.eventDetailDAO.validateCheckIn(context);
    if (utilities.checkExpiredEvent(isEventMode, eventDetail)) {
      utilities.actionAfterExpired(context, () => navigationService.navigateTo(WaitingScreen.route_name, 3));
    } else if(errorEvent != null){
      showPopError(errorEvent);
    } else {
      eventLog = await this.db.eventLogDAO.validate(inviteCode, phoneNumber);
      VisitorCheckIn visitorCheckIn = VisitorCheckIn.copyWithEventLog(eventLog);
      if (eventLog.status == Constants.VALIDATE_IN) {
        await actionIn(visitorCheckIn, inviteCode, phoneNumber);
      } else if (eventLog.status == Constants.VALIDATE_OUT) {
        actionOut(context, visitorCheckIn, inviteCode, phoneNumber);
      } else if (eventLog.status == Constants.VALIDATE_WRONG) {
        if (parent.isConnection) {
          validateEventOnl(inviteCode, phoneNumber, true);
        } else {
          actionWrong(inviteCode, phoneNumber);
        }
      } else if (eventLog.status == Constants.VALIDATE_ALREADY) {
        showPopError(appLocalizations.alreadyCheckout);
      }
    }
  }

  void showPopError(String message) {
    Utilities().showErrorPop(context, message, Constants.AUTO_HIDE_LONG, () {
      actionResetState(false);
    });
  }

  Future validateEventOnl(String inviteCode, String phoneNumber, bool isWrong) async {
    Utilities().moveToWaiting();
    ApiCallBack callBack = ApiCallBack((BaseResponse baseResponse) async {
      var eventLogNew = EventLog.fromJson(baseResponse.data);
      await db.eventLogDAO.insertNew(eventLogNew);
      validateEvent(inviteCode, phoneNumber);
    }, (Errors message) async {
      if (message.code == -2) {
        showPopError(appLocalizations.translate(AppString.NO_INTERNET));
      } else {
        actionWrong(inviteCode, phoneNumber);
      }
    });
    var userInfor = await Utilities().getUserInfor();
    var locationId = userInfor.deviceInfo.branchId ?? 0;
    var companyId = userInfor.companyInfo.id ?? 0;
    var eventId = preferences.getDouble(Constants.KEY_EVENT_ID);
    cancelEvent = await ApiRequest()
        .requestValidateOff(context, companyId, locationId, inviteCode, phoneNumber, eventId, callBack);
    await cancelEvent.valueOrCancellation();
  }

  void actionWrong(String inviteCode, String phoneNumber) {
    String content;
    if (phoneNumber != null) {
      content = appLocalizations.errorInviteCode.replaceAll("field_name", appLocalizations.phoneNumber);
    } else {
      content = appLocalizations.errorInviteCode.replaceAll("field_name", appLocalizations.inviteCode);
    }
    utilities.showErrorPop(context, content, Constants.AUTO_HIDE_LONG, () {
      actionResetState(false);
    });
  }

  void actionOut(BuildContext context, VisitorCheckIn visitorCheckIn, String inviteCode, String phoneNumber) {
    actionResetState(false);
    utilities.showToast(appLocalizations.alreadyCheckin);
  }

  Future actionIn(VisitorCheckIn visitorCheckIn, String inviteCode, String phoneNumber) async {
    List<TakePhotoStep> takePhotoStep = addTakePhoto(visitorCheckIn);
    if (takePhotoStep.isEmpty) {
      if (!isSurvey) {
        actionEventModeOff(visitorCheckIn);
      } else {
        moveToNextScreen(visitorCheckIn, HomeNextScreen.SURVEY);
      }
    } else {
      showPopupTakePhoto(takePhotoStep, visitorCheckIn);
    }
  }

  Future actionEventModeOff(VisitorCheckIn visitorCheckIn) async {
    eventLog.signIn = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    eventLog.signOut = null;
    var userInfor = await Utilities().getUserInfor();
    eventLog?.signInBy = userInfor?.deviceInfo?.id ?? 0;
    eventLog?.imagePath = visitorCheckIn.imagePath;
    eventLog?.imageIdBackPath = visitorCheckIn.imageIdBackPath;
    eventLog?.imageIdPath = visitorCheckIn.imageIdPath;
    eventLog = await this.db.eventLogDAO.updateRow(eventLog);
    await actionDoneIn(visitorCheckIn);
  }

  Future actionDoneIn(VisitorCheckIn visitorCheckIn) async {
    locator<SyncService>().syncEventNow(context, eventLog);
    successVisitor(visitorCheckIn);
  }

  void showPopupTakePhoto(List<TakePhotoStep> takePhotoStep, VisitorCheckIn visitorCheckIn) {
//    utilities.printLog("showPopupTakePhoto...............................", isDebug: true);
    controller?.dispose();
    showDialog(context: context, barrierDismissible: false, builder: (BuildContext context) {
//      utilities.printLog("showDialog nha...............................", isDebug: true);
      return ChangeNotifierProvider(
        create: (_) => PopupTakePhotoNotifier(),
        child: PopupTakePhoto(takePhotoStep: takePhotoStep),
      );
    }).then((argument) async {
      bool isDone = argument["isDone"] as bool;
      List<TakePhotoStep> takePhotoStep = argument["takePhotoStep"] as List<TakePhotoStep>;
      reloadCamera();
      if (isDone == true) {
        takePhotoStep.forEach((element) {
          switch(element.photoStep) {
            case PhotoStep.FACE_STEP: {
              visitorCheckIn.imagePath = element.pathSavedPhoto;
              if (!isSurvey && !isEventMode) {
                uploadFace(visitorCheckIn);
              }
              break;
            }
            case PhotoStep.ID_FONT_STEP: {
              visitorCheckIn.imageIdPath = element.pathSavedPhoto;
              if (!isSurvey && !isEventMode) {
                uploadIdCardOnline(visitorCheckIn, false);
              }
              break;
            }
            case PhotoStep.ID_BACK_STEP: {
              visitorCheckIn.imageIdBackPath = element.pathSavedPhoto;
              if (!isSurvey && !isEventMode) {
                uploadIdCardOnline(visitorCheckIn, true);
              }
              break;
            }
          }
          if (element.pathSavedPhoto == takePhotoStep.last.pathSavedPhoto && isSurvey) {
            moveToNextScreen(visitorCheckIn, HomeNextScreen.SURVEY);
          }
          if (element.pathSavedPhoto == takePhotoStep.last.pathSavedPhoto && isEventMode) {
            actionEventModeOff(visitorCheckIn);
          }
        });
      } else {
        actionResetState(false);
      }
    });
  }

  void actionWhenUploadDone(VisitorCheckIn visitorCheckIn) {
     if (isDoneIdBack && isDoneIdFace && isDoneIdFont) {
       if (!isEventMode) {
         actionEventMode(visitorCheckIn);
       } else {
         actionEventModeOff(visitorCheckIn);
       }
     }
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
        actionResetState(false);
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
      if (message.code != -2) {
        Utilities().showErrorPop(context, message.description, Constants.AUTO_HIDE_LONG, () {
          actionResetState(false);
        });
      } else {
        actionResetState(false);
      }
    });
    cancelableOperation = await ApiRequest().requestUploadFace(context, visitorCheckIn.imagePath, callBack);
    await cancelableOperation.valueOrCancellation();
  }

  Future validateInvite(String inviteCode, String phoneNumber, bool isNeedValidateMore) async {
    ApiCallBack callBack = ApiCallBack((BaseResponse baseResponse) async {
      isQRScan = true;
      var validate = ValidateEvent.fromJson(baseResponse.data);
      if (validate.status == Constants.VALIDATE_REGISTERED) {
        var visitorCheckIn = validate.visitor;
        visitorCheckIn.phoneNumber = phoneNumber;
        visitorCheckIn.inviteCode = inviteCode;
        visitorCheckIn.visitorType = TypeVisitor.VISITOR;
        await updateConfig(TypeVisitor.VISITOR);
        List<TakePhotoStep> takePhotoStep = addTakePhoto(visitorCheckIn);
        if (takePhotoStep.isEmpty) {
          if (!isSurvey) {
            actionEventMode(visitorCheckIn);
          } else {
            moveToNextScreen(visitorCheckIn, HomeNextScreen.SURVEY);
          }
        } else {
          showPopupTakePhoto(takePhotoStep, visitorCheckIn);
        }
      } else if (validate.status == Constants.VALIDATE_OUT) {
        actionResetState(false);
        utilities.showToast(appLocalizations.alreadyCheckin);
      } else if (validate.status == Constants.VALIDATE_IN) {
        actionResetState(false);
        utilities.showToast(appLocalizations.inviteCodeUsed);
      }
    }, (Errors message) async {
      if (message.code != -2) {
        if (isNeedValidateMore && phoneNumber != null) {
          isQRScan = false;
          searchVisitor(phoneNumber);
        } else {
          var content = message.description;
          if (message.description.contains("field_name")) {
            if (phoneNumber != null) {
              content = appLocalizations.errorInviteCode.replaceAll("field_name", appLocalizations.phoneNumber);
            } else {
              content = appLocalizations.errorInviteCode.replaceAll("field_name", appLocalizations.inviteCode);
            }
          }
          utilities.showErrorPop(context, content, Constants.AUTO_HIDE_LONG, () {
            actionResetState(false);
          });
        }
      } else {
        actionResetState(false);
      }
    });
    var userInfor = await utilities.getUserInfor();
    var locationId = userInfor.deviceInfo.branchId ?? 0;
    var companyId = userInfor.companyInfo.id ?? 0;
    cancelEvent = await ApiRequest()
        .requestValidateActionEvent(context, companyId, locationId, inviteCode, phoneNumber, null, callBack);
    await cancelEvent.valueOrCancellation();
  }

  List<TakePhotoStep> addTakePhoto(VisitorCheckIn visitorCheckIn) {
    List<TakePhotoStep> takePhotoStep = List();
    if (isScanIdCard) {
      takePhotoStep.add(TakePhotoStep.init(PhotoStep.ID_FONT_STEP));
      takePhotoStep.add(TakePhotoStep.init(PhotoStep.ID_BACK_STEP));
    } else {
      isDoneIdFont = true;
      isDoneIdBack = true;
    }
    if (isCapture) {
      takePhotoStep.add(TakePhotoStep.init(PhotoStep.FACE_STEP));
    } else {
      isDoneIdFace = true;
    }
    return takePhotoStep;
  }

  Future actionEventMode(VisitorCheckIn visitorCheckIn) async {
    ApiCallBack callBack = ApiCallBack((BaseResponse baseResponse) async {
      successVisitor(VisitorCheckIn.fromJson(baseResponse.data));
    }, (Errors message) async {
      var contentError = message.description;
      if (message.description.contains("field_name")) {
        contentError = appLocalizations.errorInviteCode.replaceAll("field_name", appLocalizations.inviteCode);
      }
      if (message.code != -2) {
        Utilities().showErrorPop(context, contentError, Constants.AUTO_HIDE_LONG, () {
          actionResetState(false);
        });
      } else {
        actionResetState(false);
      }
    });
    var userInfor = await Utilities().getUserInfor();
    var locationId = userInfor.deviceInfo.branchId ?? 0;
    var eventId = preferences.getDouble(Constants.KEY_EVENT_ID);
    cancelEvent = await ApiRequest()
        .requestRegisterEvent(context, locationId, visitorCheckIn, eventId, callBack);
    await cancelEvent.valueOrCancellation();
  }

  Future<void> successVisitor(VisitorCheckIn visitorCheckIn) async {
    bool isCovid = await Utilities().isSurveyCovid(context, visitorCheckIn.visitorType);
    if (isCovid) {
      moveToNextScreen(visitorCheckIn, HomeNextScreen.COVID);
    } else {
      utilities.tryActionLoadingBtn(btnController, BtnLoadingAction.SUCCESS);
      moveToNextScreen(visitorCheckIn, HomeNextScreen.THANK_YOU);
    }
  }

  Future searchVisitorOffline(String phone) async {
    isDie = true;
    var visitor = await db.visitorDAO.getByPhoneNumber(phone);
    if (visitor == null) {
      isReturn = false;
      await getCheckInFlow(visitorBackup);
    } else {
      isReturn = true;
      initDataBackup(visitor);
      await getCheckInFlow(visitor);
    }
  }

  void initDataBackup(VisitorCheckIn visitor) {
    visitor.toCompany = visitorBackup.toCompany;
    visitor.toCompanyId = visitorBackup.toCompanyId;
    visitor.floor = visitorBackup.floor;
    visitor.visitorType = visitorBackup.visitorType;
  }

  Future searchVisitorOnline(String phone) async {
    ApiCallBack callBack = ApiCallBack((BaseResponse baseResponse) async {
      isDie = false;
      if (baseResponse.data == null) {
        isReturn = false;
        visitorBackup.phoneNumber = phone;
        await getCheckInFlow(visitorBackup);
      } else {
        isReturn = true;
        var visitorDetail = VisitorCheckIn.fromJson(baseResponse.data);
        initDataBackup(visitorDetail);
        visitorDetail.phoneNumber = phone;
        visitorDetail.visitorType = visitorBackup.visitorType;
        await getCheckInFlow(visitorDetail);
      }
    }, (Errors message) async {
      if (message.code == ApiRequest.CODE_DIE) {
        searchVisitorOffline(phone);
      } else {
        if (message.code != -2) {
          utilities.showErrorPop(context, message.description, null, () {
            actionResetState(false);
          });
        } else {
          actionResetState(false);
        }
      }
    });

    cancelSearch = await ApiRequest().requestSearchVisitor(context, phone, null, callBack);
    await cancelSearch.valueOrCancellation();
  }

  void searchVisitor(String phone) {
    if (parent.isConnection && parent.isBEAlive) {
      searchVisitorOnline(phone);
    } else {
      searchVisitorOffline(phone);
    }
  }

  Future<List<CheckInFlow>> getCheckInFlow(VisitorCheckIn visitorCheckIn) async {
    List<CheckInFlow> flows = await db.checkInFlowDAO.getbyTemplateCode(visitorBackup.visitorType);
    doNextFlow(flows, visitorCheckIn);
  }

  Future<void> doNextFlow(List<CheckInFlow> flows, VisitorCheckIn visitorCheckIn) async {
    var convertVisitor = isReturn ? VisitorCheckIn.createVisitorByFlow(flows, visitorCheckIn) : visitorCheckIn;
    var listHaveAllGone = flows.where((element) => element.getRequestType() == RequestType.HIDDEN);
    bool isHaveAllGone = listHaveAllGone.length == flows.length;

    Timer(Duration(milliseconds: Constants.DONE_BUTTON_LOADING), () async {
      if (isHaveAllGone && !isCapture && !isAllowContact && !isSurvey && !isCovid) {
        moveToNextScreen(convertVisitor, HomeNextScreen.THANK_YOU);
      } else {
        moveToNextScreen(convertVisitor, HomeNextScreen.CHECK_IN);
      }
    });
  }

  Future<void> moveToNextScreen(VisitorCheckIn visitorCheckIn, HomeNextScreen type) async {
    visitorCheckIn.phoneNumber = phone;
    parent.updateMode();
    CompanyBuilding companyBuilding =  (arguments["companyBuilding"] as CompanyBuilding);
    utilities.tryActionLoadingBtn(btnController, BtnLoadingAction.SUCCESS);
    controller?.dispose();
    switch (type) {
      case HomeNextScreen.SURVEY:
        {
          locator<NavigationService>().navigateTo(SurveyScreen.route_name, 1, arguments: {
            'visitor': visitorCheckIn,
            'isQRScan': isQRScan,
            'eventLog': eventLog
          }).then((_) {
            handlerBack();
          });
          break;
        }
      case HomeNextScreen.COVID:
        {
          locator<NavigationService>().navigateTo(CovidScreen.route_name, 1, arguments: {
            'visitor': visitorCheckIn
          }).then((_) {
            handlerBack();
          });
          break;
        }
      case HomeNextScreen.CHECK_IN:
        {
          locator<NavigationService>().navigateTo(InputInformationScreen.route_name, 1, arguments: {
            'visitor': visitorCheckIn,
            'isReplace': false,
            'isScanId': false,
            'isDelivery': isDelivery,
            'isReturn': isReturn,
            'isQRScan': isQRScan,
            'companyBuilding': companyBuilding,
            'isDie': isDie,
          }).then((_) {
            handlerBack();
          });
          break;
        }
      case HomeNextScreen.THANK_YOU: {
          locator<NavigationService>()
              .pushNamedAndRemoveUntil(ThankYouScreen.route_name, WaitingScreen.route_name, arguments: {
            'visitor': visitorCheckIn,
          });
          break;
        }
      default:
        {
          break;
        }
    }
  }

  void handlerBack() {
    actionResetState(false);
    reloadCamera();
  }

  @override
  void dispose() {
    controller?.dispose();
    cancelSearch?.cancel();
    cancelableUploadIDBack?.cancel();
    cancelableUploadID?.cancel();
    cancelEvent?.cancel();
    cancelableOperation?.cancel();
    super.dispose();
  }
}
