import 'dart:async';
import 'dart:convert';

import 'package:app_settings/app_settings.dart';
import 'package:async/async.dart';
import 'package:check_in_pro_for_visitor/src/constants/AppString.dart';
import 'package:check_in_pro_for_visitor/src/constants/Constants.dart';
import 'package:check_in_pro_for_visitor/src/model/BaseResponse.dart';
import 'package:check_in_pro_for_visitor/src/model/Errors.dart';
import 'package:check_in_pro_for_visitor/src/model/EventDetail.dart';
import 'package:check_in_pro_for_visitor/src/model/EventLog.dart';
import 'package:check_in_pro_for_visitor/src/model/FormatQRCode.dart';
import 'package:check_in_pro_for_visitor/src/model/VisitorCheckIn.dart';
import 'package:check_in_pro_for_visitor/src/model/VisitorLog.dart';
import 'package:check_in_pro_for_visitor/src/screens/feedBack/FeedBackScreen.dart';
import 'package:check_in_pro_for_visitor/src/services/ApiCallBack.dart';
import 'package:check_in_pro_for_visitor/src/services/RequestApi.dart';
import 'package:check_in_pro_for_visitor/src/utilities/Utilities.dart';
import 'package:check_in_pro_for_visitor/src/widgetUtilities/awesomeDialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import '../../model/ValidateEvent.dart';
import '../MainNotifier.dart';
import '../waiting/WaitingScreen.dart';

class CheckOutNotifier extends MainNotifier {
  bool isLoading = false;
  bool isShowLogo = true;
  bool isSyncNow = false;
  String errorText;
  bool isShowQRCode = false;
  CancelableOperation cancelableOperation;
  CancelableOperation cancelableRefresh;
  CancelableOperation cancelEvent;
  CancelableOperation cancelableLogout;
  RoundedLoadingButtonController btnController = new RoundedLoadingButtonController();
  String qrCodeStr = "";
  QRViewController controller;
  bool isScanned = false;
  bool isShowClear = false;
  bool isLoadCamera = false;
  bool isEventMode = false;
  bool isNormal = true;
  EventLog eventLog;

  void showClear(bool isShow) {
    isShowClear = isShow;
    notifyListeners();
  }

  Future<void> startStream(BuildContext context) async {
    controller.scannedDataStream.listen((scanData) async {
      if (this.controller != null && !isScanned) {
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
      btnController.start();
    } catch (e) {
      isLoading = false;
      btnController.stop();
      Utilities().showErrorPopNo(context, appLocalizations.invalidQR, Constants.AUTO_HIDE_LESS, callbackDismiss: () {
        this.isScanned = false;
//        this.qrCodeStr = '';
        utilities.moveToWaiting();
      });
    }
  }

  Future searchVisitor(String phone, String inviteCode) async {
    errorText = null;
    isLoading = true;
    notifyListeners();
    isEventMode = preferences.getBool(Constants.KEY_EVENT) ?? false;
    if (isEventMode) {
      isNormal = false;
      validateEvent(inviteCode, phone);
    } else {
      validateActionInvite(inviteCode, phone);
    }
  }

  Future validateEvent(String inviteCode, String phoneNumber) async {
    var eventDetail = arguments["eventDetail"] as EventDetail;
    if (utilities.checkExpiredEvent(isEventMode, eventDetail)) {
      utilities.actionAfterExpired(context, () => navigationService.navigateTo(WaitingScreen.route_name, 3));
    } else {
      eventLog = await this.db.eventLogDAO.validate(inviteCode, phoneNumber);
      VisitorCheckIn visitorCheckIn = VisitorCheckIn.copyWithEventLog(eventLog);
      if (parent.isConnection) {
        if (eventLog.status != Constants.VALIDATE_ALREADY) {
          validateEventOnl(inviteCode, phoneNumber, eventLog.status == Constants.VALIDATE_WRONG);
        } else {
          showPopError(appLocalizations.alreadyCheckout);
        }
      } else {
        if (eventLog.status == Constants.VALIDATE_IN) {
          showPopError(appLocalizations.noVisitor);
        } else if (eventLog.status == Constants.VALIDATE_OUT) {
          moveToNextPage(visitorCheckIn, null, inviteCode, eventLog, phoneNumber);
        } else if (eventLog.status == Constants.VALIDATE_WRONG) {
          actionWrong(inviteCode, phoneNumber);
        } else if (eventLog.status == Constants.VALIDATE_ALREADY) {
          showPopError(appLocalizations.alreadyCheckout);
        }
      }
    }
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

  void showPopError(String message) {
    Utilities().showErrorPop(context, message, Constants.AUTO_HIDE_LONG, () {
      actionResetState(false);
    });
  }

  void actionResetState(bool isClearQR) {
    isLoading = false;
    btnController.stop();
    this.isScanned = false;
    if (isClearQR) {
      qrCodeStr = "";
    }
    utilities.moveToWaiting();
    notifyListeners();
  }

  Future validateActionInvite(String inviteCode, String phoneNumber) async {
    Utilities().cancelWaiting();
    ApiCallBack callBack = ApiCallBack((BaseResponse baseResponse) async {
      isNormal = false;
      var validate = ValidateEvent.fromJson(baseResponse.data);
      if (validate.status == Constants.VALIDATE_IN || validate.status == Constants.VALIDATE_REGISTERED) {
        utilities.showErrorPop(context, appLocalizations.noVisitor, Constants.AUTO_HIDE_LONG, () {
          actionResetState(false);
        });
      } else if (validate.status == Constants.VALIDATE_OUT) {
        var visitorDetail = validate.visitor;
        doNextStep(visitorDetail, null, inviteCode, null, phoneNumber);
      } else if (validate.status == Constants.VALIDATE_WRONG && phoneNumber != null) {
        searchOnline(phoneNumber);
      }
    }, (Errors message) async {
      if (message.code != -2) {
        if (message.description == appLocalizations.errorInviteCode && phoneNumber != null) {
          searchOnline(phoneNumber);
        } else {
          var mess = message.description;
          if (message.description.contains("field_name")) {
            mess = message.description.replaceAll("field_name", appLocalizations.inviteCode);
          }
          Utilities().showErrorPop(context, mess, Constants.AUTO_HIDE_LONG, () {
            actionResetState(false);
          });
        }
      } else {
        actionResetState(false);
      }
    });
    var userInfor = await Utilities().getUserInfor();
    var locationId = userInfor.deviceInfo.branchId ?? 0;
    var companyId = userInfor.companyInfo.id ?? 0;
    cancelEvent = await ApiRequest()
        .requestValidateActionEvent(context, companyId, locationId, inviteCode, phoneNumber, null, callBack);
    await cancelEvent.valueOrCancellation();
  }

  Future validateEventOnl(String inviteCode, String phoneNumber, bool isWrong) async {
    ApiCallBack callBack = ApiCallBack((BaseResponse baseResponse) async {
      var eventLogNew = EventLog.fromJson(baseResponse.data);
      if (isWrong) {
        await db.eventLogDAO.insertNew(eventLogNew);
        validateEvent(inviteCode, phoneNumber);
      } else {
        if (eventLogNew.signIn == null) {
          showPopError(appLocalizations.noVisitor);
        } else {
          eventLog.faceCaptureFile = eventLogNew.faceCaptureFile;
          eventLog = await db.eventLogDAO.updateRow(eventLog);
          VisitorCheckIn visitorCheckIn = VisitorCheckIn.copyWithEventLog(eventLog);
          if (eventLogNew.signOut == null) {
            moveToNextPage(visitorCheckIn, null, inviteCode, eventLog, phoneNumber);
          } else {
            showPopError(appLocalizations.alreadyCheckout);
          }
        }
      }
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

  Future searchOnline(String phone) async {
    ApiCallBack callBack = ApiCallBack((BaseResponse baseResponse) async {
      isNormal = true;
      var visitorDetail = VisitorCheckIn.fromJson(baseResponse.data);
      doNextStep(visitorDetail, null, null, null, phone);
    }, (Errors message) async {
      if (message.code < 0) {
        if (message.code != -2) {
          var mess = message.description;
          if (message.description.contains("field_name")) {
            mess = message.description.replaceAll("field_name", appLocalizations.inviteCode);
          }
          Utilities().showErrorPop(context, mess, null, () {
            actionResetState(false);
          });
        } else {
          actionResetState(false);
        }
      } else {
        noVisitorAlert(message);
      }
    });

    cancelableOperation = await ApiRequest().requestSearchVisitorCheckOut(context, phone, null, callBack);
    await cancelableOperation.valueOrCancellation();
  }

  Future showScanQR(BuildContext context) async {
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

  void doNextStep(VisitorCheckIn visitorDetail, VisitorLog visitorLog, String inviteCode, EventLog eventLog, String phoneNumber) {
    btnController.success();
    Timer(Duration(milliseconds: Constants.DONE_BUTTON_LOADING), () {
      moveToNextPage(visitorDetail, visitorLog, inviteCode, eventLog, phoneNumber);
    });
  }

  void noVisitorAlert(Errors message) {
    errorText = message.description;
    if (message.description == appLocalizations.noData) {
      errorText = appLocalizations.noPhone;
    }
    if (message.description == appLocalizations.errorInviteCode) {
      errorText = appLocalizations.noVisitor;
    }
    actionResetState(false);
  }

  void moveToNextPage(VisitorCheckIn visitorId, VisitorLog visitorLog, String inviteCode, EventLog eventLog, String phoneNumber) {
    controller?.dispose();
    actionResetState(true);
    parent.updateMode();
    navigationService.pushNamedAndRemoveUntil(FeedBackScreen.route_name, WaitingScreen.route_name, arguments: {
      'visitorCheckIn': visitorId,
      'visitorLog': visitorLog,
      'inviteCode': inviteCode,
      'phoneNumber': phoneNumber,
      'eventLog': eventLog,
      'isSyncNow': isSyncNow,
      'isNormal': isNormal
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    cancelEvent?.cancel();
    cancelableRefresh?.cancel();
    cancelableLogout?.cancel();
    cancelableOperation?.cancel();
    super.dispose();
  }
}
