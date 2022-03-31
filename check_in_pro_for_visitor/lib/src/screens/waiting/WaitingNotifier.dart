import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:check_in_pro_for_visitor/src/model/Authenticate.dart';
import 'package:check_in_pro_for_visitor/src/model/BaseResponse.dart';
import 'package:async/async.dart';
import 'package:check_in_pro_for_visitor/src/model/CheckInFlowObject.dart';
import 'package:check_in_pro_for_visitor/src/model/CompanyBuilding.dart';
import 'package:check_in_pro_for_visitor/src/model/ConfigKiosk.dart';
import 'package:check_in_pro_for_visitor/src/model/EventDetail.dart';
import 'package:check_in_pro_for_visitor/src/model/EventTicket.dart';
import 'package:check_in_pro_for_visitor/src/model/FormatQRCode.dart';
import 'package:check_in_pro_for_visitor/src/model/FunctionGroup.dart';
import 'package:check_in_pro_for_visitor/src/model/ImageDownloaded.dart';
import 'package:check_in_pro_for_visitor/src/model/KickModel.dart';
import 'package:check_in_pro_for_visitor/src/model/ListCheckInFlow.dart';
import 'package:check_in_pro_for_visitor/src/model/RepoUpload.dart';
import 'package:check_in_pro_for_visitor/src/model/TakePhotoStep.dart';
import 'package:check_in_pro_for_visitor/src/model/UserInfor.dart';
import 'package:check_in_pro_for_visitor/src/model/ValidateEvent.dart';
import 'package:check_in_pro_for_visitor/src/model/VisitorCheckIn.dart';
import 'package:check_in_pro_for_visitor/src/model/VisitorType.dart';
import 'package:check_in_pro_for_visitor/src/screens/checkOut/CheckOutScreen.dart';
import 'package:check_in_pro_for_visitor/src/screens/covidScreen/CovidScreen.dart';
import 'package:check_in_pro_for_visitor/src/screens/inputPhone/InputPhoneScreen.dart';
import 'package:check_in_pro_for_visitor/src/screens/login/LoginScreen.dart';
import 'package:check_in_pro_for_visitor/src/screens/scanQR/ScanQRScreen.dart';
import 'package:check_in_pro_for_visitor/src/screens/settting/SettingScreen.dart';
import 'package:check_in_pro_for_visitor/src/screens/splashScreen/SplashScreen.dart';
import 'package:check_in_pro_for_visitor/src/screens/survey/SurveyScreen.dart';
import 'package:check_in_pro_for_visitor/src/screens/visitorType/VisitorTypeScreen.dart';
import 'package:check_in_pro_for_visitor/src/services/SyncService.dart';
import 'package:check_in_pro_for_visitor/src/services/printService/PrinterModel.dart';
import 'package:check_in_pro_for_visitor/src/widgetUtilities/PopupTakePhoto/PopupTakePhoto.dart';
import 'package:check_in_pro_for_visitor/src/widgetUtilities/PopupTakePhoto/PopupTakePhotoNotifier.dart';
import 'package:check_in_pro_for_visitor/src/widgetUtilities/awesomeDialog/awesome_dialog.dart';
import 'package:check_in_pro_for_visitor/src/constants/AppString.dart';
import 'package:check_in_pro_for_visitor/src/services/ServiceLocator.dart';
import 'package:check_in_pro_for_visitor/src/utilities/UtilityNotifier.dart';
import 'package:check_in_pro_for_visitor/src/constants/Constants.dart';
import 'package:check_in_pro_for_visitor/src/model/BaseListResponse.dart';
import 'package:check_in_pro_for_visitor/src/model/Configuration.dart';
import 'package:check_in_pro_for_visitor/src/model/Errors.dart';
import 'package:check_in_pro_for_visitor/src/services/ApiCallBack.dart';
import 'package:check_in_pro_for_visitor/src/services/RequestApi.dart';
import 'package:check_in_pro_for_visitor/src/utilities/Utilities.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import '../../model/UserInfor.dart';
import '../../utilities/Utilities.dart';
import '../../utilities/Extensions.dart';

class ButtonAction {
  ButtonAction({
    @required this.title,
    @required this.imageString,
    @required this.action,
  });

  final String title;
  final String imageString;
  final Function action;
}

class WaitingNotifier extends UtilityNotifier {
  final GlobalKey repaintBoundary = new GlobalKey();
  GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  int isUpdatedStatus = 0;
  int remainder = 0;
  bool isLoading = true;
  bool isHaveDelivery = false;
  bool isConnection = true;
  Timer timerClock;
  Timer timerSocket;
  Timer timerExpiredTouchless;
  var textWaiting = "";
  bool isLoadCamera = true;

  bool isLoadWelcome = true;
  bool isDoneImage = false;
  bool isDoneLogo = false;
  bool isDoneSubLogo = false;
  bool isDoneConfig = false;
  bool isDoneFlows = false;
  bool isEventMode = false;
  bool isDoneCompany = false;
  bool isDoneFunction = false;
  bool isDoneSurvey = false;
  bool isBuilding = false;

  bool isShowCheckIn = true;
  bool isShowCheckOut = true;

  double branchId = 0.0;
  int countSaveCompany = 0;
  int countSaveWaiting = 0;
  int countBackground = 0;
  bool isHaveEvent = false;
  String backgroundColor = "";
  List<Color> listColor = List();
  String companyName = "";
  String textCheckIn = "";
  String textCheckOut = "";
  Map<String, dynamic> mapLangName;
  Map<String, dynamic> mapLangCheckIn;
  Map<String, dynamic> mapLangCheckOut;
  int textSize = 6;
  String companyNameColor;
  String chkInColor;
  String chkInTextColor;
  String chkOutColor;
  String chkOutTextColor;
  List<String> image = List();
  List<String> imageLocalPath = List();
  List<String> imageEventLocalPath = List();
  List<CompanyBuilding> listCompanyBuilding = List();
  CancelableOperation cancelableOperation;
  CancelableOperation cancelEvent;
  AsyncMemoizer<void> memCache = AsyncMemoizer();
  bool isNext = false;
  bool isWarning = false;
  List<VisitorType> listType = List();
  ConfigKiosk configKios;
  VisitorCheckIn visitorCheckIn;
  var touchlessLink = "";
  int touchlessExpired = 0;
  bool isExpired = false;
  bool isRefresh = false;
  bool isHaveSaver = false;
  bool isEventTicket = false;
  bool isShowVisitorType = true;
  int countRefreshFail = 0;

  QRViewController controller;
  bool isScanned = false;
  bool isProcessing = false;
  double eventId;
  double eventTicketId;
  String qrCodeStr = "";
  String messagePopup = "";
  PrinterModel printer;
  bool isDoneAnyWay = false;
  Timer timerDoneAnyWay;
  Timer timerReset;
  var type = BackgroundType.WAITING_NEW;
  List<ButtonAction> items = List();
  String visitorType = Constants.VT_VISITORS;
  String lastQR = "";
  final assetsAudioPlayer = AssetsAudioPlayer();
  EventDetail eventDetail;
  EventTicket eventTicket = EventTicket.init();
  CancelableOperation cancelableUploadID;
  CancelableOperation cancelableUploadIDBack;
  bool isDoneIdBack = false;
  bool isDoneIdFont = false;
  bool isDoneIdFace = false;

  List<ButtonAction> getList() {
    items = <ButtonAction>[
      if (isShowCheckIn) ButtonAction(
          title: textCheckIn,
          imageString: 'assets/images/checkin.png',
          action: () => moveToNextScreen(HomeNextScreen.CHECK_IN, false)),
      if (isShowCheckOut) ButtonAction(
          title: textCheckOut,
          imageString: 'assets/images/checkout.png',
          action: () => moveToNextScreen(HomeNextScreen.CHECK_OUT, false)),
      if (isHaveDelivery)
        ButtonAction(
            title: appLocalizations.titleDelivery,
            imageString: 'assets/images/delivery.png',
            action: () => moveToNextScreen(HomeNextScreen.CHECK_IN, true)),
    ];
    return items;
  }

  void doneJobAnyWay() {
    Timer(Duration(seconds: 4), () {
      navigationService.navigateTo(SplashScreen.route_name, 3);
    });
  }

  void pingToServer() {
    timerSocket?.cancel();
    timerSocket = Timer.periodic(Duration(seconds: 10), (Timer t) {
      InternetAddress.lookup(Constants.BE_PING_ADD).then((value) {
        value.forEach((element) async {
          Socket.connect(InternetAddress(element.address), 443, timeout: Duration(seconds: 10)).then((socket) {
            if (!parent.isBEAlive) {
              locator<SyncService>().syncAllLog(context);
              locator<SyncService>().syncEventFail(context);
            }
            parent.updateBEStatus(true);
            utilities.printLog("Success");
            socket.destroy();
          }).catchError((error) {
            parent.updateBEStatus(false);
            utilities.printLog("Exception on Socket " + error.toString());
          });
        });
      });
    });
  }

  Future<void> startStream() async {
    controller.scannedDataStream.listen((scanData) async {
      if (this.controller != null && !isScanned && scanData.code != lastQR) {
        lastQR = scanData.code;
        resetLastQR();
        this.isScanned = true;
        qrCodeStr = scanData.code;
        _showPopupWaiting(appLocalizations.waitingTitle);
        getDataFromQR();
      }
    });
  }

  Future refreshToken(BuildContext context) async {
    if (!isRefresh && parent.isBEAlive) {
      isRefresh = true;
      var firebaseId = preferences.getString(Constants.KEY_FIREBASE_TOKEN) ?? "";
      ApiCallBack listCallBack = ApiCallBack((BaseResponse baseResponse) async {
        countRefreshFail = 0;
        var authenticationString = JsonEncoder().convert(baseResponse.data);
        preferences.setString(Constants.KEY_AUTHENTICATE, authenticationString);
        reloadWaiting(isReloadAll: true);
        updateClock();
      }, (Errors message) async {
        if (countRefreshFail < 6) {
          await Future.delayed(Duration(milliseconds: 1000));
          refreshToken(context);
        } else {
          countRefreshFail = 0;
          if (message.code != ApiRequest.CODE_DIE) {
            if (message.code != -2 && message.code == -401) {
              CancelableOperation cancelableLogout;
              Utilities().popupAndSignOut(context, cancelableLogout, appLocalizations.expiredToken);
            } else {
              await Future.delayed(Duration(milliseconds: 1000));
              refreshToken(context);
            }
          }
        }
        updateClock();
        countRefreshFail++;
      });
      var authorization = await Utilities().getAuthorization();
      var token = (authorization as Authenticate).refreshToken;
      await ApiRequest().requestRefreshTokenApi(context, firebaseId, token, listCallBack);
      utilities.countDownToResetApp(0, context);
      isRefresh = false;
    }
  }

  void resetLastQR() {
    timerReset?.cancel();
    timerReset = Timer(Constants.TIMER_PREVENT_SCAN, () async {
      lastQR = "";
    });
  }

  void preventUpdateStatus() {
    if (isUpdatedStatus == 0) {
      Timer(Duration(minutes: 5), () {
        isUpdatedStatus = 0;
      });
    }
    isUpdatedStatus++;
  }

  void touchScreen() {
    if (isHaveSaver) {
      utilities.moveToSaver(context, configKios.saverModel, imageLocalPath, currentLang, companyNameColor, db, kickWhenBack);
    }
  }

  Future kickWhenBack({isCancel: true, Map<String, dynamic> saverMess}) async {
    isNext = false;
    if (isCancel) {
      reloadCamera();
      Timer(Duration(seconds: 1), () => utilities.cancelWaiting());
    }
    var isKick = preferences.getString(Constants.KEY_IS_KICK) ?? "";
    if (isKick.isNotEmpty) {
      var kickModel = KickModel.fromJson(jsonDecode(isKick));
      kickBySignalR(kickModel.title, kickModel.content);
      preferences.setString(Constants.KEY_IS_KICK, "");
    }
//    getQRCreate(context);
    firebaseCloudMessaging_Listeners();
    if (saverMess != null) {
      handlerMSGFirebase(saverMess);
    } else {
      touchScreen();
    }
  }

  Future<void> reloadCamera() async {
    if (type == BackgroundType.TOUCH_LESS) {
      qrKey = GlobalKey(debugLabel: 'QR');
      isLoadCamera = false;
      notifyListeners();
      await Future.delayed(Duration(milliseconds: 700));
      isLoadCamera = true;
      notifyListeners();
    }
  }

  Future<void> moveToNextScreen(HomeNextScreen type, bool isDelivery) async {
    if (!parent.isBEAlive) {
      utilities.showErrorPop(context, appLocalizations.translate(AppString.NO_INTERNET), 5, () {});
      return;
    }
    isNext = true;
    var isScanIdCard;
    if (listType == null || listType.isEmpty) {
      isScanIdCard = false;
    } else {
      isScanIdCard = await Utilities().checkIsScanId(context, listType[0].settingKey);
    }
    switch (type) {
      case HomeNextScreen.CHECK_IN:
        {
          if (this.type == BackgroundType.TOUCH_LESS) {
            controller?.dispose();
          }
          if (isEventMode) {
            navigationService.navigateTo(InputPhoneScreen.route_name, 1, arguments: {
              'visitor': VisitorCheckIn.inital(),
              'eventDetail': eventDetail
            }).then((value) async {
              await kickWhenBack();
            });
          } else if (isShowVisitorType && !isDelivery && (listType?.length ?? 0) > 1) {
            navigationService.navigateTo(VisitorTypeScreen.route_name, 1, arguments: {
              'visitor': VisitorCheckIn.inital()
            }).then((value) async {
              await kickWhenBack();
            });
          } else {
            navigationService.navigateTo(InputPhoneScreen.route_name, 1, arguments: {
              'isDelivery': isDelivery,
              'visitor': VisitorCheckIn.inital()
            }).then((value) async {
              await kickWhenBack();
            });
          }
          break;
        }
      case HomeNextScreen.CHECK_OUT:
        {
          if (isConnection || isEventMode) {
            if (this.type == BackgroundType.TOUCH_LESS) {
              controller?.dispose();
            }
            navigationService.navigateTo(CheckOutScreen.route_name, 1,
                arguments: {'isDelivery': isDelivery, 'eventDetail': eventDetail}).then((value) async {
              await kickWhenBack();
            });
          } else {
            utilities.showErrorPop(context, appLocalizations.cantOffline, Constants.AUTO_HIDE_LONG, (){

            });
          }
          break;
        }
      case HomeNextScreen.SCAN_QR:
        {
          if (this.type == BackgroundType.TOUCH_LESS) {
            controller?.dispose();
          }
          navigationService.navigateTo(ScanQRScreen.route_name, 1).then((value) async {
            await kickWhenBack();
          });
          break;
        }
      default:
        {
          isNext = false;
          break;
        }
    }
  }

  Future<void> moveToTouchless(VisitorCheckIn visitorCheckIn, HomeNextScreen type) async {
    _dissmissPopupWaiting();
    isDoneAnyWay = false;
    switch (type) {
      case HomeNextScreen.SURVEY:
        {
          if (this.type == BackgroundType.TOUCH_LESS) {
            controller?.dispose();
          }
          navigationService.navigateTo(SurveyScreen.route_name, 1, arguments: {
            'visitor': visitorCheckIn,
            'isQRScan': true,
          }).then((_) {
            resumeScan();
            reloadCamera();
          });
          break;
        }
      case HomeNextScreen.COVID:
        {
          if (this.type == BackgroundType.TOUCH_LESS) {
            controller?.dispose();
          }
          navigationService.navigateTo(CovidScreen.route_name, 1, arguments: {
            'visitor': visitorCheckIn
          }).then((_) {
            resumeScan();
            reloadCamera();
          });
          break;
        }
      case HomeNextScreen.THANK_YOU:
        {
          showMessageSuccess(visitorCheckIn);
          break;
        }
      case HomeNextScreen.FEED_BACK:
        {
          assetsAudioPlayer.play();
          Utilities().showNoButtonDialog(context, true, DialogType.SUCCES, Constants.AUTO_HIDE_LESS,
              appLocalizations.translate(AppString.MESSAGE_THANK_YOU_CHATBOX), visitorCheckIn.fullName, null);
          resumeScan();
          reloadCamera();
          break;
        }
      default:
        {
          isNext = false;
          break;
        }
    }
  }

  Future<void> getConfiguration() async {
    return memCache.runOnce(() async {
      isEventMode = preferences.getBool(Constants.KEY_EVENT) ?? false;
      eventId = preferences.getDouble(Constants.KEY_EVENT_ID);
      eventTicketId = preferences.getDouble(Constants.KEY_EVENT_TICKET_ID);
      isEventTicket = utilities.getUserInforNew(preferences).isEventTicket;
      notifyListeners();
      await Utilities().getDefaultLang(context);
      var langSaved = preferences.getString(Constants.KEY_LANGUAGE) ?? Constants.VN_CODE;
      if (isEventMode) {
        if (isEventTicket) {
          eventTicket = await db.eventTicketDAO.getEventTicketById(eventTicketId);
        } else {
          eventDetail = await this.db.eventDetailDAO.getEventDetail();
          imageEventLocalPath.clear();
          var lastLangString = preferences.getString(Constants.KEY_COVER_EVENT) ?? "";
          if (lastLangString.isNotEmpty) {
            List<String> link = List<String>.from(json.decode(lastLangString));
            for (int i = 0; i < link.length; i++) {
              ImageDownloaded imageDownloaded = await db.imageDownloadedDAO.getByLink(link[i]);
              String localPath = await utilities.getLocalPathFile(Constants.FOLDER_TEMP, Constants.FILE_TYPE_IMAGE_EVENT, imageDownloaded.localPath, null);
              if (localPath != null) {
                imageEventLocalPath.add(localPath);
              }
            }
          }
        }
      }
      var userInfor = await Utilities().getUserInfor();
      listLang = userInfor.companyLanguage;
      textWaiting = appLocalizations.translate(AppString.MESSAGE_TOUCH_START);
      branchId = userInfor?.deviceInfo?.branchId ?? 0.0;
      isWarning = userInfor?.companyInfo?.isWarning() ?? false;
      isLoadWelcome = preferences.getBool(Constants.KEY_LOAD_WELCOME) ?? true;
      printer = await Utilities().getPrinter();
      configKios = utilities.getConfigKios(preferences);
      touchlessLink = configKios?.touchlessModel?.token ?? "";
      touchlessExpired = configKios?.touchlessModel?.expiredTimestamp ?? -1;
      isShowVisitorType = configKios?.isShowVisitorType?.toBool() ?? true;
      type = (configKios?.touchlessModel?.status == true && !isEventMode)
          ? BackgroundType.TOUCH_LESS
          : BackgroundType.WAITING_NEW;
      if (type == BackgroundType.WAITING_NEW) {
        controller?.dispose();
      }
      textCheckIn = appLocalizations.titleCheckIn0;
      textCheckOut = appLocalizations.titleCheckOut;
      assetsAudioPlayer.open(Audio("assets/audios/ding.mp3"), showNotification: false, autoStart: false);
      assetsAudioPlayer.setVolume(1.0);
      isConnection = await Utilities().isConnectInternet(isChangeState: false);
      if (parent.isConnection && parent.isBEAlive && isLoadWelcome) {
        currentLang = langSaved;
        return loadDataOnline(userInfor);
      } else {
        currentLang = langSaved;
        return loadDataOffline(userInfor);
      }
    });
  }

  Future getUserInfor() async {
    ApiCallBack callBack = ApiCallBack((BaseResponse baseResponse) async {
      var userInforString = JsonEncoder().convert(baseResponse.data);
      preferences.setString(Constants.KEY_USER_INFOR, userInforString);
      var userInfor = UserInfor.fromJson(baseResponse.data);
      var lang = userInfor?.companyLanguage?.elementAt(0)?.languageCode ?? Constants.VN_CODE;
      if (!Constants.LIST_LANG.contains(lang)) {
        lang = Constants.VN_CODE;
      }
      preferences.setString(Constants.KEY_LANGUAGE, lang);
      await appLocalizations.load(Locale(lang));
      reloadWaiting();
    }, (Errors message) {});

    var deviceInfor = await Utilities().getDeviceInfo();
    await ApiRequest().requestUserInfor(context, deviceInfor.identifier, callBack);
  }

  getFlowOnline() async {
    ApiCallBack listCallBack = ApiCallBack((BaseResponse baseResponse) async {
      //Callback SUCCESS
      var _resp = ListCheckInFlow.fromJson(baseResponse.data);
      List<CheckInFlowObject> flows = _resp.flows;
      var badgeTemplate = _resp.badgeTemplateCode;
      preferences.setString(Constants.KEY_BADGE_PRINTER, badgeTemplate);
      await db.checkInFlowDAO.deleteAlls();
      await Future.forEach(flows, (CheckInFlowObject element) async {
        await db.checkInFlowDAO.insertAlls(element.flow);
      });

      isDoneFlows = true;
      handlerDone();
    }, (Errors message) async {
      //Callback ERROR
      isDoneFlows = true;
      handlerDone();
    });
    ApiRequest().requestGetFlow(context, branchId, listCallBack);
  }

  getFunctionOnline() async {
    var account = await Utilities().getUserInfor();
    ApiCallBack listCallBack = ApiCallBack((BaseListResponse baseListResponse) async {
      //Callback SUCCESS
      var listFunction = baseListResponse.data.map((Map model) => FunctionGroup.fromJson(model)).toList();
      preferences.setBool(Constants.FUNCTION_EVENT, false);
      listFunction.forEach((FunctionGroup element) {
        if (element.functionName == Constants.FUNCTION_EVENT &&
            element.permission != null &&
            element.permission.isNotEmpty) {
          preferences.setBool(Constants.FUNCTION_EVENT, true);
        }
      });

      isDoneFunction = true;
      handlerDone();
//      }
    }, (Errors message) async {
      //Callback ERROR
      isDoneFunction = true;
      handlerDone();
    });
    ApiRequest().requestFunctionGroup(context, account.accountId, listCallBack);
  }

//  getQRCreate(BuildContext context) async {
//    memCacheQR = AsyncMemoizer();
//    memCacheQR.runOnce(() async {
//      isShowQR = false;
//      notifyListeners();
//      ApiCallBack listCallBack = ApiCallBack((BaseResponse baseResponse) async {
//        //Callback SUCCESS
//        if (baseResponse.data != null) {
//          listQR.clear();
//          indexQR = 0;
//          qrCreate = ListQRCreate.fromJson(baseResponse.data);
//          listQR = qrCreate?.qrCodes ?? List();
//          if (listQR.isNotEmpty && qrCreate.status == true) {
//            int now = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
//            int expired = now - (listQR[0].expiredTime - qrCreate.refreshTime);
//            timeReload = qrCreate?.refreshTime ?? Constants.TIME_RELOAD_QR;
//            if (expired > timeReload) {
//              int len = expired ~/ timeReload;
//              int numberExpired = (len > 0) ? len - 1 : len;
//              remainder = timeReload - (expired % timeReload);
//              listQR.removeRange(0, numberExpired);
//            } else {
//              remainder = timeReload - expired;
//            }
//            utilities.printLog("timeReload $timeReload refreshTime ${qrCreate?.refreshTime} remainder $remainder");
//            isShowQR = true;
//            isHaveQRAlready = true;
//            isHaveQRError = false;
//            notifyListeners();
//          } else {
//            isHaveQRAlready = false;
//            isHaveQRError = false;
//            isShowQR = false;
//            notifyListeners();
//          }
//        } else {
//          isHaveQRError = true;
//          isShowQR = false;
//          notifyListeners();
//        }
//      }, (Errors message) async {
//        //Callback ERROR
//        isShowQR = false;
//        isHaveQRError = true;
//        notifyListeners();
//      });
//      ApiRequest().requestQRCreate(context, branchId, listCallBack);
//    });
//  }

//  void reloadQR() {
//    indexQR++;
//    if (indexQR > ((2 * listQR.length) ~/ 3)) {
//      getQRCreate(context);
//    } else {
//      notifyListeners();
//    }
//  }

//  getContactPerson(, double branchId) async {
//    ApiCallBack listCallBack = ApiCallBack((BaseListResponse baseListResponse) async {
//      //Callback SUCCESS
//      if (baseListResponse.data != null) {
//        contactPerson = baseListResponse.data
//            .map((Map model) => ContactPerson.fromJson(model))
//            .toList();
//        if (contactPerson.isNotEmpty) {
//          contactPerson.asMap().forEach((index, it) async {
//            if (it.avatarFileName == null || it.avatarFileName.isEmpty) {
//              try {
//                final byteData =
//                await rootBundle.load('assets/images/default_avatar.png');
//                var path = await Utilities().getLocalPathFile(
//                    Constants.FOLDER_TEMP,
//                    Constants.FILE_TYPE_CONTACT_PERSON,
//                    index.toString(),
//                    null);
//                await Utilities().writeToFile(byteData, path);
//
//                contactPerson[index].logoPathLocal = path;
//                contactPerson[index].index = index;
//                countContactPerson++;
//                if (countContactPerson >= contactPerson.length) {
//                  isDoneContact = true;
//                  if (contactPerson.length > 0) {
//                    await db.contactPersonDAO.deleteAlls();
//                    await db.contactPersonDAO.insertAlls(contactPerson);
//                  }
//                  handlerDone(context);
//                }
//              } catch (e) {
//                countContactPerson++;
//                if (countContactPerson >= contactPerson.length) {
//                  isDoneContact = true;
//                  if (contactPerson.length > 0) {
//                    await db.contactPersonDAO.deleteAlls();
//                    await db.contactPersonDAO.insertAlls(contactPerson);
//                  }
//                  handlerDone(context);
//                }
//              }
//            } else {
//              getImage(context, Constants.FILE_TYPE_CONTACT_PERSON,
//                  it.avatarFileName, index);
//            }
//          });
//        } else {
//          isDoneContact = true;
//          handlerDone(context);
//        }
//      } else {
//        isDoneContact = true;
//        handlerDone(context);
//      }
//    }, (Errors message) async {
//      //Callback ERROR
//      isDoneContact = true;
//      handlerDone(context);
//    });
//    ApiRequest().requestContactPerson(context, branchId, listCallBack);
//  }

  getConfigKios() async {
    ApiCallBack callBack = ApiCallBack((BaseResponse baseResponse) async {
      countSaveWaiting = 0;
      var configKiosString = JsonEncoder().convert(baseResponse.data);
      preferences.setString(Constants.KEY_CONFIG_KIOS, configKiosString);
      configKios = ConfigKiosk.fromJson(baseResponse.data);
      var isTouchless = configKios?.touchlessModel?.status == true;
      touchlessLink = configKios?.touchlessModel?.token ?? "";
      touchlessExpired = configKios?.touchlessModel?.expiredTimestamp ?? -1;
      isShowVisitorType = configKios?.isShowVisitorType?.toBool() ?? true;
      type = (isTouchless && !isEventMode) ? BackgroundType.TOUCH_LESS : BackgroundType.WAITING_NEW;
      if (type == BackgroundType.WAITING_NEW) {
        controller?.dispose();
      }
      await db.visitorTypeDAO.deleteAll();
      await Future.forEach(configKios.visitorType, (VisitorType element) async {
        await db.visitorTypeDAO.insert(element);
      });
      if (configKios?.saverModel != null && configKios?.saverModel?.status == true) {
        isHaveSaver = true;
      if (configKios?.saverModel?.images?.isNotEmpty == true) {
          var listImage = configKios?.saverModel?.images;
          for (var index = 0; index < listImage.length; index++) {
            ImageDownloaded image = await db.imageDownloadedDAO.getByLink(utilities.shortBase64(listImage[index]));
            if (image == null) {
              List<String> list = listImage[index].split("/");
              getImage(Constants.FILE_TYPE_IMAGE_SAVER, listImage[index], index, nameFile: list.last);
            } else {
              countSaveWaiting++;
            }
            if (countSaveWaiting == configKios.saverModel.images.length) {
              isDoneConfig = true;
              handlerDone();
            }
          }
        } else {
          isDoneConfig = true;
          handlerDone();
        }
      } else {
        isHaveSaver = false;
        isDoneConfig = true;
        handlerDone();
      }
    }, (Errors message) async {
      isDoneConfig = true;
      handlerDone();
    });

    await ApiRequest().requestConfigKios(context, branchId, callBack);
  }

  getSurvey() async {
    ApiCallBack callBack = ApiCallBack((BaseResponse baseResponse) async {
      var surveyString = JsonEncoder().convert(baseResponse.data);
      preferences.setString(Constants.KEY_SURVEY, surveyString);
      isDoneSurvey = true;
      handlerDone();
    }, (Errors message) async {
      isDoneSurvey = true;
      handlerDone();
    });

    await ApiRequest().requestSurvey(context, branchId, callBack);
  }

  void updateStatus(String status) async {
    if (isUpdatedStatus <= 5) {
      preventUpdateStatus();
      ApiCallBack callBack = ApiCallBack((BaseResponse baseResponse) async {}, (Errors message) async {});

      await ApiRequest().requestUpdateStatus(context, status, callBack);
    }
  }

  getCompanyOnline() async {
    await db.companyBuildingDAO.deleteAlls();
    countSaveCompany = 0;
    ApiCallBack callBack = ApiCallBack((BaseListResponse baseListResponse) async {
      if (baseListResponse.data != null) {
        listCompanyBuilding = baseListResponse.data.map((Map model) => CompanyBuilding.fromJson(model)).toList();
        if (listCompanyBuilding.isNotEmpty) {
          for (var index = 0; index < listCompanyBuilding.length; index++) {
            if (listCompanyBuilding[index].logoPath == null || listCompanyBuilding[index].logoPath.isEmpty) {
              try {
                final byteData = await rootBundle.load('assets/images/temp_company.png');
                var path = await Utilities().getLocalPathFile(
                    Constants.FOLDER_TEMP, Constants.FILE_TYPE_COMPANY_BUILDING, index.toString(), null);
                await Utilities().writeToFile(byteData, path);

                listCompanyBuilding[index].logoPathLocal = path;
                listCompanyBuilding[index].index = index;
                countSaveCompany++;
                if (countSaveCompany >= listCompanyBuilding.length) {
                  isDoneCompany = true;
                  if (listCompanyBuilding.length > 0) {
                    await db.companyBuildingDAO.deleteAlls();
                    await db.companyBuildingDAO.insertAlls(listCompanyBuilding);
                  }
                  handlerDone();
                }
              } catch (e) {
                countSaveCompany++;
                if (countSaveCompany >= listCompanyBuilding.length) {
                  isDoneCompany = true;
                  if (listCompanyBuilding.length > 0) {
                    await db.companyBuildingDAO.deleteAlls();
                    await db.companyBuildingDAO.insertAlls(listCompanyBuilding);
                  }
                  handlerDone();
                }
              }
            } else {
              getImage(Constants.FILE_TYPE_COMPANY_BUILDING, listCompanyBuilding[index].logoPath, index);
            }
          }
        } else {
          isDoneCompany = true;
          handlerDone();
        }
      } else {
        isDoneCompany = true;
        handlerDone();
      }
    }, (Errors message) async {
      isDoneCompany = true;
      handlerDone();
    });

    await ApiRequest().requestAllCompanyBuilding(context, callBack);
  }

  Future loadDataOffline(UserInfor userInfor) async {
    isLoading = true;
    notifyListeners();
    isDoneImage = false;
    isDoneLogo = false;
    isDoneSubLogo = false;
    isDoneFlows = true;
    isDoneFunction = true;
    isDoneSurvey = true;
    isDoneConfig = true;
    isDoneCompany = true;

    if (configKios?.saverModel != null && configKios?.saverModel?.status == true) {
      isHaveSaver = true;
    } else {
      isHaveSaver = false;
    }
    List<Configuration> configuration = await db.configurationDAO.getAllConfigurations();
    if (configuration != null && configuration.isNotEmpty) {
      await renderToUI(configuration, userInfor);

      handlerDone();
    } else {
      if (companyName.isEmpty) {
        companyName = userInfor.companyInfo.name;
      }
      isDoneImage = true;
      isDoneLogo = true;
      isDoneSubLogo = true;
      handlerDone();
    }
  }

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  Future<void> firebaseCloudMessaging_Listeners() async {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        utilities.printLog("_firebaseMessaging: $message");
        await handlerMSGFirebase(message);
      },
      onResume: (Map<String, dynamic> message) async {
      },
      onLaunch: (Map<String, dynamic> message) async {
//        await handlerMSGFirebase(message, context);
      },
    );
  }

  Future handlerMSGFirebase(Map<String, dynamic> message) async {
    var data = message['data'] ?? message;
    String mess = data['value'];
    if (mess == Constants.TYPE_BRANDING) {
      reloadWaiting();
    } else if (mess.contains(Constants.TYPE_DEVICE_CONFIGURATION)) {
      await kickBySignalR(appLocalizations.changedConfiguration, appLocalizations.deletedDevice);
    } else if (mess.contains(Constants.TYPE_PASSWORD_CONFIGURATION)) {
      await kickBySignalR(appLocalizations.changedConfiguration, appLocalizations.changedAccount);
    } else if (mess.contains(Constants.TYPE_ACCOUNT_CONFIGURATION)) {
      await kickBySignalR(appLocalizations.changedConfiguration, appLocalizations.deletedAccount);
    } else if (mess.contains(Constants.TYPE_CHANGE_LANGUAGE)) {
      isDoneFlows = false;
      getFlowOnline();
      getUserInfor();
    } else if (mess.contains(Constants.TYPE_DELETE_BRANCH)) {
      await kickBySignalR(appLocalizations.changedConfiguration, appLocalizations.deletedBranch);
    } else if (mess.contains(Constants.TYPE_LOCK_ACCOUNT)) {
      await kickBySignalR(appLocalizations.changedConfiguration, appLocalizations.accountLocked);
    } else if (mess.contains(Constants.TYPE_TEMPLATE)) {
      isLoading = true;
      isDoneFlows = false;
      notifyListeners();
      await getFlowOnline();
    } else if (mess.contains(Constants.TYPE_DEACTIVATE_ACCOUNT)) {
      await kickBySignalR(appLocalizations.changedConfiguration, appLocalizations.accountDeactivated);
    } else if (mess.contains(Constants.TYPE_BRANCH_CONFIG)) {
      isDoneConfig = false;
      isDoneSurvey = false;
      getConfigKios();
      getSurvey();
    } else if (mess.contains(Constants.TYPE_TOUCH_LESS)) {
      isDoneConfig = false;
      isLoading = true;
      notifyListeners();
      getConfigKios();
    } else if (mess.contains(Constants.TYPE_HR)) {
//      getQRCreate(context);
    } else if (mess.contains(Constants.TYPE_WAITING)) {
      isDoneConfig = false;
      getConfigKios();
    } else if (mess.contains(Constants.TYPE_SURVEY_HEALTH_DECLARATION)) {
      isDoneSurvey = false;
      getSurvey();
    }
  }

  bool checkIsDone() {
    return isDoneImage &&
        isDoneLogo &&
        isDoneFlows &&
        isDoneCompany &&
        isDoneConfig &&
        isDoneFunction &&
        isDoneSubLogo &&
        isDoneSurvey;
  }

  Future loadDataOnline(UserInfor userInfor) async {
    isLoading = true;
    notifyListeners();
    isDoneImage = false;
    isDoneLogo = false;
    isDoneSubLogo = false;
    preferences.setBool(Constants.KEY_LOAD_WELCOME, false);
    updateStatus(Constants.STATUS_ONLINE);
    ApiCallBack callBack = ApiCallBack((BaseListResponse baseListResponse) async {
      List<Configuration> configuration =
          baseListResponse.data.map((Map model) => Configuration.fromJson(model)).toList();
      await db.configurationDAO.deleteAll();
      await Future.forEach(configuration, (element) async {
        await db.configurationDAO.insert(element);
      });
      await renderToUI(configuration, userInfor);
      var firstStart = preferences.getBool(Constants.KEY_FIRST_START) ?? true;
      if (firstStart) {
        isDoneSurvey = false;
        isDoneFunction = false;
        isDoneConfig = false;
        isDoneCompany = false;
        isDoneFlows = false;
        getFlowOnline();
        getConfigKios();
        getSurvey();
        getFunctionOnline();
        var printer = await Utilities().getPrinter();
        if (printer != null) {
          printer.connectPrinter();
        }
        if (userInfor.isBuilding) {
          getCompanyOnline();
        } else {
          isDoneCompany = true;
        }
        preferences.setBool(Constants.KEY_FIRST_START, false);
      } else {
        isDoneFlows = true;
        isDoneConfig = true;
        isDoneCompany = true;
        isDoneFunction = true;
        isDoneSurvey = true;
      }
      handlerDone();
    }, (Errors message) {
      loadDataOffline(userInfor);
    });

    return await ApiRequest().requestConfiguration(context, Constants.TYPE_BRANDING, callBack);
  }

  Future renderToUI(List<Configuration> configuration, UserInfor userInfor) async {
    await Future.forEach(configuration, (element) async {
      switch (element.code) {
        case Constants.CONFIGURATION_BACKGROUND_COLOR:
          {
            try {
              listColor.clear();
              backgroundColor = "";
              if (element.value != null && element.value.isNotEmpty && element.value[0].isNotEmpty) {
                backgroundColor = Constants.PREFIX_COLOR + (element.value[0] as String).replaceAll('"', "");
                element.value.forEach((color) {
                  var colorValue = Constants.PREFIX_COLOR +
                      (color as String).replaceAll(RegExp("[^0-9a-zA-Z]+"), "").replaceAll('"', "");
                  try {
                    listColor.add(Color(int.parse(colorValue)));
                  } catch (e) {
                    listColor.add(Theme.of(context).primaryColor);
                  }
                });
              }
            } catch (e) {
              listColor.add(Theme.of(context).primaryColor);
              backgroundColor = Constants.PREFIX_COLOR + "ffffff";
            }
            break;
          }
        case Constants.CONFIGURATION_LAYOUTS:
          {
            if (element.value != null && element.value.isNotEmpty && element.value[0].isNotEmpty) {
//              layoutStyle = element.value[0] as String;
//              preferences.setString(Constants.KEY_STYLE_LAYOUT, layoutStyle);
            } else {
//              layoutStyle = Constants.STYLE_2;
//              preferences.setString(Constants.KEY_STYLE_LAYOUT, layoutStyle);
            }
            break;
          }
        case Constants.CONFIGURATION_COMPANY_LOGO:
          {
            if (element.value != null &&
                element.value.isNotEmpty &&
                element.value[0].isNotEmpty &&
                parent.isConnection &&
                isLoadWelcome) {
              var savedCompanyLogo = preferences.getString(Constants.KEY_COMPANY_LOGO) ?? "";
              if (savedCompanyLogo != element.value[0]) {
                preferences.setString(Constants.KEY_COMPANY_LOGO, element.value[0]);
                await getImage(Constants.FILE_TYPE_LOGO_COMPANY, element.value[0], 0);
              } else {
                isDoneLogo = true;
              }
            } else {
              if (parent.isConnection && isLoadWelcome) {
                var file =
                    await Utilities().getLocalFile(Constants.FOLDER_TEMP, Constants.FILE_TYPE_LOGO_COMPANY, "0", null);
                Utilities().deleteFile(file);
              }
              isDoneLogo = true;
            }
            break;
          }
        case Constants.CONFIGURATION_SUB_COMPANY_LOGO:
          {
            if (element.value != null &&
                element.value.isNotEmpty &&
                element.value[0].isNotEmpty &&
                parent.isConnection &&
                isLoadWelcome) {
              var savedCompanyLogo = preferences.getString(Constants.KEY_COMPANY_SUB_LOGO) ?? "";
              if (savedCompanyLogo != element.value[0]) {
                preferences.setString(Constants.KEY_COMPANY_SUB_LOGO, element.value[0]);
                await getImage(Constants.FILE_TYPE_LOGO_SUB_COMPANY, element.value[0], 0);
              } else {
                isDoneSubLogo = true;
              }
            } else {
              if (parent.isConnection && isLoadWelcome) {
                var file = await Utilities()
                    .getLocalFile(Constants.FOLDER_TEMP, Constants.FILE_TYPE_LOGO_SUB_COMPANY, "0", null);
                Utilities().deleteFile(file);
              }
              isDoneSubLogo = true;
            }
            break;
          }
        case Constants.CONFIGURATION_COMPANY_NAME:
          {
            if (element.value != null && element.value.isNotEmpty && element.value[0].isNotEmpty) {
              var langSaved = preferences.getString(Constants.KEY_LANGUAGE) ?? Constants.VN_CODE;
              mapLangName = json.decode(element.value[0]);
              if (!Constants.LIST_LANG.contains(langSaved)) {
                langSaved = Constants.VN_CODE;
              }
              companyName = mapLangName[langSaved];
            } else {
              companyName = userInfor.companyInfo.name;
            }
            break;
          }
        case Constants.CONFIGURATION_CHECKIN_BUTTON_TEXT:
          {
            if (element.value != null && element.value.isNotEmpty && element.value[0].isNotEmpty) {
              var langSaved = preferences.getString(Constants.KEY_LANGUAGE) ?? Constants.VN_CODE;
              mapLangCheckIn = json.decode(element.value[0]);
              if (!Constants.LIST_LANG.contains(langSaved)) {
                langSaved = Constants.VN_CODE;
              }
              textCheckIn = mapLangCheckIn[langSaved];
            } else {
              textCheckIn = appLocalizations.titleCheckIn;
            }
            break;
          }
        case Constants.CONFIGURATION_CHECKOUT_BUTTON_TEXT:
          {
            if (element.value != null && element.value.isNotEmpty && element.value[0].isNotEmpty) {
              var langSaved = preferences.getString(Constants.KEY_LANGUAGE) ?? Constants.VN_CODE;
              mapLangCheckOut = json.decode(element.value[0]);
              if (!Constants.LIST_LANG.contains(langSaved)) {
                langSaved = Constants.VN_CODE;
              }
              textCheckOut = mapLangCheckOut[langSaved];
            } else {
              textCheckOut = appLocalizations.titleCheckOut;
            }
            break;
          }
        case Constants.CONFIGURATION_IMAGES:
          {
            image.clear();
            imageLocalPath.clear();
            countBackground = 0;
            if (element.value != null && element.value.isNotEmpty && element.value[0].isNotEmpty) {
              image = element.value;
              if (parent.isConnection && isLoadWelcome) {
                var savedImage = preferences.getString(Constants.KEY_IMAGE_WAITING) ?? "";
                for (var index = 0; index < image.length; index++) {
                  ImageDownloaded imageSaved = await db.imageDownloadedDAO.getByLink(utilities.shortBase64(image[index]));
                  if (imageSaved == null) {
                    getImage(Constants.FILE_TYPE_IMAGE_WAITING, image[index], index);
                  } else {
                    countBackground++;
                    var fileSaved = await Utilities().getLocalPathFile(Constants.FOLDER_TEMP, Constants.FILE_TYPE_IMAGE_WAITING, index.toString(), null);
                    imageLocalPath.add(fileSaved);
                    if (countBackground == image.length) {
                      isDoneImage = true;
                    }
                  }
                }
              } else {
                for (var index = 0; index < image.length; index++) {
                  var fileSaved = await Utilities().getLocalPathFile(Constants.FOLDER_TEMP, Constants.FILE_TYPE_IMAGE_WAITING, index.toString(), null);
                  imageLocalPath.add(fileSaved);
                }
                isDoneImage = true;
              }
            } else {
              isDoneImage = true;
            }
            break;
          }
        case Constants.CONFIGURATION_COMPANY_NAME_COLOR:
          {
            companyNameColor = null;
            if (element.value != null && element.value.isNotEmpty && element.value[0].isNotEmpty) {
              companyNameColor =
                  Constants.PREFIX_COLOR + element.value[0].replaceAll(RegExp("[^0-9a-zA-Z]+"), "").replaceAll('"', "");
            }
            break;
          }

        case Constants.CONFIGURATION_COMPANY_TEXT_SIZE:
          {
            textSize = 6;
            if (element.value != null && element.value.isNotEmpty && element.value[0].isNotEmpty) {
              textSize = int.tryParse(element.value[0]) ?? 6;
            }
            break;
          }

        case Constants.CONFIGURATION_CHECKOUT_BUTTON_BG_COLOR:
          {
            chkOutColor = null;
            if (element.value != null && element.value.isNotEmpty && element.value[0].isNotEmpty) {
              chkOutColor =
                  Constants.PREFIX_COLOR + element.value[0].replaceAll(RegExp("[^0-9a-zA-Z]+"), "").replaceAll('"', "");
            }
            break;
          }
        case Constants.CONFIGURATION_CHECKIN_BUTTON_TEXT_COLOR:
          {
            chkInTextColor = null;
            if (element.value != null && element.value.isNotEmpty && element.value[0].isNotEmpty) {
              chkInTextColor =
                  Constants.PREFIX_COLOR + element.value[0].replaceAll(RegExp("[^0-9a-zA-Z]+"), "").replaceAll('"', "");
            }
            break;
          }
        case Constants.CONFIGURATION_CHECKIN_BUTTON_BG_COLOR:
          {
            chkInColor = null;
            if (element.value != null && element.value.isNotEmpty && element.value[0].isNotEmpty) {
              chkInColor =
                  Constants.PREFIX_COLOR + element.value[0].replaceAll(RegExp("[^0-9a-zA-Z]+"), "").replaceAll('"', "");
            }
            break;
          }
        case Constants.CONFIGURATION_CHECKOUT_BUTTON_TEXT_COLOR:
          {
            chkOutTextColor = null;
            if (element.value != null && element.value.isNotEmpty && element.value[0].isNotEmpty) {
              chkOutTextColor =
                  Constants.PREFIX_COLOR + element.value[0].replaceAll(RegExp("[^0-9a-zA-Z]+"), "").replaceAll('"', "");
            }
            break;
          }
        case Constants.CONFIGURATION_BUTTON_IN_STATUS:
          {
            isShowCheckIn = true;
            if (element.value != null && element.value.isNotEmpty && element.value[0].isNotEmpty) {
              isShowCheckIn = (element.value[0] == "0") ? false : true;
            }
            break;
          }
        case Constants.CONFIGURATION_BUTTON_OUT_STATUS:
          {
            isShowCheckOut = true;
            if (element.value != null && element.value.isNotEmpty && element.value[0].isNotEmpty) {
              isShowCheckOut = (element.value[0] == "0") ? false : true;
            }
            break;
          }
      }
    });
  }

//  Future<CancelableOperation<dynamic>> getImage(String type, String path, int index, {String nameFile}) async {
//    ApiCallBack callBack = ApiCallBack((Uint8List file, String contentType) async {
//      var nameSaved = index.toString();
//      if (nameFile != null) {
//        nameSaved= nameFile;
//      }
//      var fileSaved = await Utilities().saveLocalFile(Constants.FOLDER_TEMP, type, nameSaved, null, file);
//      if (type == Constants.FILE_TYPE_COMPANY_BUILDING) {
//        countSaveCompany++;
//        var file = await Utilities().getLocalFile(Constants.FOLDER_TEMP, type, index.toString(), null);
//        listCompanyBuilding[index].logoPathLocal = file.path;
//        listCompanyBuilding[index].index = index;
//        if (countSaveCompany >= listCompanyBuilding.length) {
//          isDoneCompany = true;
//          if (listCompanyBuilding.length > 0) {
//            await db.companyBuildingDAO.deleteAlls();
//            await db.companyBuildingDAO.insertAlls(listCompanyBuilding);
//          }
//        }
//      }
//
//      if (type == Constants.FILE_TYPE_LOGO_COMPANY) {
//        isDoneLogo = true;
//      }
//      if (type == Constants.FILE_TYPE_LOGO_SUB_COMPANY) {
//        isDoneSubLogo = true;
//      }
//      if (type == Constants.FILE_TYPE_IMAGE_WAITING) {
//        countBackground++;
//        if (countBackground == image.length) {
//          isDoneImage = true;
//        }
//        imageLocalPath.add(fileSaved.path);
//      }
//      if (type == Constants.FILE_TYPE_IMAGE_SAVER) {
//        List<String> paths = fileSaved.path.split(Constants.FILE_TYPE_IMAGE_SAVER);
//        await db.imageDownloadedDAO.insert(ImageDownloaded(path, paths.last));
//        countSaveWaiting++;
//        if (countSaveWaiting == configKios.saverModel.images.length) {
//          isDoneConfig = true;
//        }
//      }
//      handlerDone();
//    }, (Errors message) async {
//      if (type == Constants.FILE_TYPE_IMAGE_SAVER) {
//        countSaveWaiting++;
//        if (countSaveWaiting == configKios.saverModel.images.length) {
//          isDoneConfig = true;
//        }
//      }
//      if (type == Constants.FILE_TYPE_LOGO_COMPANY) {
//        isDoneLogo = true;
//      }
//      if (type == Constants.FILE_TYPE_LOGO_SUB_COMPANY) {
//        isDoneSubLogo = true;
//      }
//      if (type == Constants.FILE_TYPE_IMAGE_WAITING) {
//        countBackground++;
//        if (countBackground == image.length) {
//          isDoneImage = true;
//        }
//      }
//      if (type == Constants.FILE_TYPE_COMPANY_BUILDING) {
//        try {
//          final byteData = await rootBundle.load('assets/images/temp_company.png');
//          var path = await Utilities().getLocalPathFile(Constants.FOLDER_TEMP, type, index.toString(), null);
//          await Utilities().writeToFile(byteData, path);
//
//          listCompanyBuilding[index].logoPathLocal = path;
//          listCompanyBuilding[index].index = index;
//          countSaveCompany++;
//          if (countSaveCompany >= listCompanyBuilding.length) {
//            isDoneCompany = true;
//            if (listCompanyBuilding.length > 0) {
//              await db.companyBuildingDAO.deleteAlls();
//              await db.companyBuildingDAO.insertAlls(listCompanyBuilding);
//            }
//          }
//        } catch (e) {
//          countSaveCompany++;
//          if (countSaveCompany >= listCompanyBuilding.length) {
//            isDoneCompany = true;
//            if (listCompanyBuilding.length > 0) {
//              await db.companyBuildingDAO.deleteAlls();
//              await db.companyBuildingDAO.insertAlls(listCompanyBuilding);
//            }
//          }
//        }
//      }
//      handlerDone();
//    });
//
//    return ApiRequest().requestImage(context, path, callBack);
//  }

  Future<CancelableOperation<dynamic>> getImage(String type, String base64, int index, {String nameFile}) async {
    try {
      var nameSaved = index.toString();
      if (nameFile != null) {
        nameSaved= nameFile;
      }
      var base64Decoded = Base64Decoder().convert(base64.split(',').last).toList();
      var fileSaved = await Utilities().saveLocalFile(Constants.FOLDER_TEMP, type, nameSaved, null, base64Decoded);
      if (type == Constants.FILE_TYPE_COMPANY_BUILDING) {
        countSaveCompany++;
        var file = await Utilities().getLocalFile(Constants.FOLDER_TEMP, type, index.toString(), null);
        listCompanyBuilding[index].logoPathLocal = file.path;
        listCompanyBuilding[index].index = index;
        if (countSaveCompany >= listCompanyBuilding.length) {
          isDoneCompany = true;
          if (listCompanyBuilding.length > 0) {
            await db.companyBuildingDAO.deleteAlls();
            await db.companyBuildingDAO.insertAlls(listCompanyBuilding);
          }
        }
      }

      if (type == Constants.FILE_TYPE_LOGO_COMPANY) {
        isDoneLogo = true;
      }
      if (type == Constants.FILE_TYPE_LOGO_SUB_COMPANY) {
        isDoneSubLogo = true;
      }
      if (type == Constants.FILE_TYPE_IMAGE_WAITING) {
        List<String> paths = fileSaved.path.split(Constants.FILE_TYPE_IMAGE_WAITING);
        await db.imageDownloadedDAO.insert(ImageDownloaded(utilities.shortBase64(base64), paths.last));
        countBackground++;
        if (countBackground == image.length) {
          isDoneImage = true;
        }
        imageLocalPath.add(fileSaved.path);
      }
      if (type == Constants.FILE_TYPE_IMAGE_SAVER) {
        List<String> paths = fileSaved.path.split(Constants.FILE_TYPE_IMAGE_SAVER);
        await db.imageDownloadedDAO.insert(ImageDownloaded(utilities.shortBase64(base64), paths.last));
        countSaveWaiting++;
        if (countSaveWaiting == configKios.saverModel.images.length) {
          isDoneConfig = true;
        }
      }
      handlerDone();
    } catch(e) {
      if (type == Constants.FILE_TYPE_IMAGE_SAVER) {
        countSaveWaiting++;
        if (countSaveWaiting == configKios.saverModel.images.length) {
          isDoneConfig = true;
        }
      }
      if (type == Constants.FILE_TYPE_LOGO_COMPANY) {
        isDoneLogo = true;
      }
      if (type == Constants.FILE_TYPE_LOGO_SUB_COMPANY) {
        isDoneSubLogo = true;
      }
      if (type == Constants.FILE_TYPE_IMAGE_WAITING) {
        countBackground++;
        if (countBackground == image.length) {
          isDoneImage = true;
        }
      }
      if (type == Constants.FILE_TYPE_COMPANY_BUILDING) {
        try {
          final byteData = await rootBundle.load('assets/images/temp_company.png');
          var path = await Utilities().getLocalPathFile(Constants.FOLDER_TEMP, type, index.toString(), null);
          await Utilities().writeToFile(byteData, path);

          listCompanyBuilding[index].logoPathLocal = path;
          listCompanyBuilding[index].index = index;
          countSaveCompany++;
          if (countSaveCompany >= listCompanyBuilding.length) {
            isDoneCompany = true;
            if (listCompanyBuilding.length > 0) {
              await db.companyBuildingDAO.deleteAlls();
              await db.companyBuildingDAO.insertAlls(listCompanyBuilding);
            }
          }
        } catch (e) {
          countSaveCompany++;
          if (countSaveCompany >= listCompanyBuilding.length) {
            isDoneCompany = true;
            if (listCompanyBuilding.length > 0) {
              await db.companyBuildingDAO.deleteAlls();
              await db.companyBuildingDAO.insertAlls(listCompanyBuilding);
            }
          }
        }
      }
      handlerDone();
    }
  }

  Future<void> handlerDone() async {
    if (checkIsDone()) {
      pingToServer();
      isLoading = false;
      isHaveDelivery = false;
      listType = await db.visitorTypeDAO.getAlls();
      VisitorType tempItem;
      await Future.forEach(listType, (VisitorType element) async {
        if (element.settingKey == TypeVisitor.DELIVERY) {
          isHaveDelivery = true;
          tempItem = element;
        }
      });
      if (tempItem != null) listType.remove(tempItem);
      isHaveEvent = preferences.getBool(Constants.FUNCTION_EVENT) ?? false;
      isBuilding = await utilities.checkIsBuilding(preferences, db);
      getList();
      if (touchlessExpired < 0) {
        isExpired = false;
      } else {
        var now = DateTime.now().millisecondsSinceEpoch / 1000;
        var remain = touchlessExpired - now;
        if (remain <= 0) {
          isExpired = true;
        } else {
          isExpired = false;
          timerExpiredTouchless?.cancel();
          timerExpiredTouchless = Timer(Duration(seconds: remain.round()), () {
            isExpired = true;
            notifyListeners();
          });
        }
      }
      notifyListeners();
      kickWhenBack(isCancel: false);
    }
  }

  Future reloadWaiting({isReloadAll: false}) async {
    memCache = AsyncMemoizer();
    image.clear();
    imageLocalPath.clear();
    preferences.setBool(Constants.KEY_FIRST_START, isReloadAll);
    preferences.setBool(Constants.KEY_LOAD_WELCOME, true);
    await getConfiguration();
  }

  Future kickBySignalR(String title, String content) async {
    if (!isNext) {
      isLoading = true;
      notifyListeners();
      await doLogout();
      Utilities().showNoButtonDialog(context, false, DialogType.INFO, Constants.AUTO_HIDE_LESS, title, content, null);
      isLoading = false;
    } else {
      var kickModel = KickModel(title, content);
      preferences.setString(Constants.KEY_IS_KICK, jsonEncode(kickModel.toJson()));
    }
  }

  void runClock() {
    timerClock?.cancel();
    timerClock = Timer.periodic(Duration(minutes: 1), (Timer t) {
      Utilities().isConnectInternet(isChangeState: true);
      notifyListeners();
      if (isEventMode) {
        if (!isEventTicket) {
          if (utilities.checkExpiredEvent(isEventMode, eventDetail)) {
            isEventMode = false;
            utilities.actionAfterExpired(context, () => reloadWaiting());
          }
        } else {
          if (utilities.checkExpiredEventTicket(isEventMode, eventTicket)) {
            isEventMode = false;
            utilities.actionAfterExpired(context, () => reloadWaiting());
          }
        }
      }
      if (t.tick != 0 && ((t.tick % 10) == 0) && parent.isConnection) {
        updateStatus(Constants.STATUS_ONLINE);
      }
//      if (isHaveQRAlready && isHaveQRError) {
//        getQRCreate(context);
//      }
    });
  }

  void updateClock() {
    notifyListeners();
  }

  void openSetting() {
    TextEditingController controller = TextEditingController();
    GlobalKey<FormState> passwordKey = GlobalKey<FormState>();
    RoundedLoadingButtonController btnController = RoundedLoadingButtonController();
    if (utilities.checkExpiredEvent(isEventMode, eventDetail) &&
        utilities.checkExpiredEventTicket(isEventMode, eventTicket)) {
      utilities.actionAfterExpired(context, () => reloadWaiting());
    } else {
      if (parent.isConnection) {
        Utilities().showConfirmPassWord(
            context,
            appLocalizations.titleConfirmPassword,
            appLocalizations.password,
            appLocalizations.password,
            appLocalizations.confirm,
            passwordKey,
            controller,
            btnController,
            () => moveToSetting(passwordKey, btnController),
            () => touchScreen());
      } else {
        Utilities().showOneButtonDialog(
            context,
            DialogType.INFO,
            null,
            appLocalizations.translate(AppString.TITLE_NOTIFICATION),
            appLocalizations.noInternetSetting,
            appLocalizations.btnClose, () {
          touchScreen();
        });
      }
    }
  }

  Future<void> updateLanguage() async {
    if (currentLang == Constants.EN_CODE) {
      currentLang = Constants.VN_CODE;
    } else {
      currentLang = Constants.EN_CODE;
    }
    await appLocalizations.load(Locale(currentLang));
    textWaiting = appLocalizations.translate(AppString.MESSAGE_TOUCH_START);
    preferences.setString(Constants.KEY_LANGUAGE, currentLang);
    var userInfor = await Utilities().getUserInfor();
    companyName = (mapLangName != null) ? mapLangName[currentLang] ?? userInfor.companyInfo.name : userInfor.companyInfo.name;
    textCheckIn = (mapLangCheckIn != null)
        ? mapLangCheckIn[currentLang] ?? appLocalizations.titleCheckIn
        : appLocalizations.titleCheckIn;
    textCheckOut = (mapLangCheckOut != null)
        ? mapLangCheckOut[currentLang] ?? appLocalizations.titleCheckOut
        : appLocalizations.titleCheckOut;
    getList();
    notifyListeners();
  }

  Future<void> moveToSetting(GlobalKey<FormState> passwordKey, RoundedLoadingButtonController btnController) async {
    touchScreen();
    if (passwordKey == null || passwordKey.currentState.validate()) {
      isNext = true;
      btnController.stop();
      navigationService.navigatePop(context);
      navigationService.navigateTo(SettingScreen.route_name, 1).then((value) async {
        bool isReload = value["isReload"] as bool;
        await kickWhenBack(isCancel: false);
        isEventMode = preferences.getBool(Constants.KEY_EVENT) ?? false;
        eventTicketId = preferences.getDouble(Constants.KEY_EVENT_TICKET_ID);
        eventId = preferences.getDouble(Constants.KEY_EVENT_ID);
        if (eventTicketId != null) {
          eventTicket = await db.eventTicketDAO.getEventTicketById(eventTicketId);
        }
        if (isReload == true) {
          isDoneFlows = false;
          isDoneConfig = false;
          isDoneSurvey = false;
          await reloadWaiting();
          await getFlowOnline();
          await getConfigKios();
          await getSurvey();
        } else if (touchlessLink.isNotEmpty) {
          if (isEventMode) {
            type = BackgroundType.WAITING_NEW;
            controller?.dispose();
          } else {
            type = BackgroundType.TOUCH_LESS;
          }
          await reloadWaiting();
        }
        notifyListeners();
//        if (isEventMode) {
//          navigationService.navigateTo<WaitingNotifier>(ScanQRScreen.route_name, 1).then((value) async {
//            await kickWhenBack();
//          });
//        }
      });
    } else {
      btnController.stop();
    }
  }

  Future<void> doLogout() async {
    var authorization = await Utilities().getAuthorization();
    var refreshToken = (authorization as Authenticate).refreshToken;
    var deviceInfor = await Utilities().getDeviceInfo();
    var firebase = preferences.getString(Constants.KEY_FIREBASE_TOKEN) ?? "";
    ApiRequest().requestUpdateStatus(context, Constants.STATUS_OFFLINE, null);
    ApiCallBack callBack = ApiCallBack((BaseResponse baseResponse) async {
//      await locator<SignalRService>().stopSignalR();
      await handlerLogout();
    }, (Errors message) async {
//      await locator<SignalRService>().stopSignalR();
      if (message.code != -2) {
        await handlerLogout();
      }
    });

    cancelableOperation =
        await ApiRequest().requestLogout(context, deviceInfor.identifier, refreshToken, firebase, callBack);
    await cancelableOperation.valueOrCancellation();
  }

  void getDataFromQR() {
    try {
      FormatQRCode formatQRCode = FormatQRCode.fromJson(jsonDecode(qrCodeStr));
      switch (formatQRCode.type) {
        case FormatQRCode.CHECK_OUT_PHONE:
          {
            searchOnline(formatQRCode.data, null);
            break;
          }
        case FormatQRCode.CHECK_OUT_ID:
          {
            searchOnline(null, formatQRCode.data);
            break;
          }
        default:
          {
            validateEventOnl(formatQRCode.data, null);
          }
      }
    } catch (e) {
      errorJob(appLocalizations.invalidQR);
    }
  }

  void errorJob(String message) {
    _dissmissPopupWaiting();
    Utilities().showErrorPopNo(context, message, Constants.AUTO_HIDE_LESS, callbackDismiss: () {
      resumeScan();
    });
  }

  Future searchOnline(String phone, String idCard) async {
    ApiCallBack callBack = ApiCallBack((BaseResponse baseResponse) async {
      var visitorDetail = VisitorCheckIn.fromJson(baseResponse.data);
      checkOutOnline(visitorDetail);
    }, (Errors message) async {
      if (message.code < 0) {
        if (message.code != -2) {
          var mess = message.description;
          if (message.description.contains("field_name")) {
            mess = message.description.replaceAll("field_name", appLocalizations.inviteCode);
          }
          errorJob(mess);
        } else {
          _dissmissPopupWaiting();
          resumeScan();
        }
      } else {
        var errorText = message.description;
        if (message.description == appLocalizations.noData) {
          errorText = appLocalizations.noPhone;
        }
        if (message.description == appLocalizations.errorInviteCode) {
          errorText = appLocalizations.noVisitor;
        }
        errorJob(errorText);
      }
    });

    cancelableOperation = await ApiRequest().requestSearchVisitorCheckOut(context, phone, idCard, callBack);
    await cancelableOperation.valueOrCancellation();
  }

  Future checkOutOnline(VisitorCheckIn visitorCheckIn) async {
    ApiCallBack callBack = ApiCallBack((BaseResponse baseResponse) async {
      showMessageSuccess(visitorCheckIn);
    }, (Errors message) async {
      if (message.code != -2) {
        errorJob(message.description);
      } else {
        _dissmissPopupWaiting();
        resumeScan();
      }
    });
    var userInfor = await Utilities().getUserInfor();
    var signOutBy = userInfor?.deviceInfo?.id ?? 0;
    var branchId = userInfor?.deviceInfo?.branchId ?? 0;
    await ApiRequest().requestCheckOut(context, visitorCheckIn.id, "", 5, signOutBy, branchId, callBack);
  }

  Future<List<TakePhotoStep>> addTakePhoto(VisitorCheckIn visitorCheckIn) async {
    List<TakePhotoStep> takePhotoStep = List();
    var isScanIdCard = await utilities.checkIsScanId(context, visitorCheckIn.visitorType);
    var isCapture = await utilities.checkIsCapture(context, visitorCheckIn.visitorType);
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

  Future validateEventOnl(String inviteCode, String phoneNumber) async {
    ApiCallBack callBack = ApiCallBack((BaseResponse baseResponse) async {
      var validate = ValidateEvent.fromJson(baseResponse.data);
      visitorCheckIn = validate.visitor;
      if (validate.status == Constants.VALIDATE_REGISTERED) {
        visitorCheckIn.phoneNumber = phoneNumber;
        visitorCheckIn.inviteCode = inviteCode;
        List<TakePhotoStep> takePhotoStep = await addTakePhoto(visitorCheckIn);
        bool isSurvey = await Utilities().isSurveyCustom(context, visitorCheckIn?.visitorType);
        if (takePhotoStep.isEmpty) {
          if (!isSurvey) {
            actionEventMode(visitorCheckIn);
          } else {
            moveToTouchless(visitorCheckIn, HomeNextScreen.SURVEY);
          }
        } else {
          showPopupTakePhoto(takePhotoStep, visitorCheckIn);
        }
      } else if (validate.status == Constants.VALIDATE_OUT) {
        checkOutEvent(visitorCheckIn, inviteCode, phoneNumber);
      } else if (validate.status == Constants.VALIDATE_IN) {
        errorJob(appLocalizations.noVisitor);
      }
    }, (Errors message) async {
      if (message.code != -2) {
        var content;
        if (message.description == appLocalizations.errorInviteCode) {
          if (inviteCode != null) {
            content = appLocalizations.errorInviteCode.replaceAll("field_name", appLocalizations.inviteCode);
          } else {
            content = appLocalizations.errorInviteCode.replaceAll("field_name", appLocalizations.phoneNumber);
          }
        } else {
          content = message.description;
        }
        errorJob(content);
      } else {
        _dissmissPopupWaiting();
        resumeScan();
      }
    });
    var userInfor = await Utilities().getUserInfor();
    var locationId = userInfor.deviceInfo.branchId ?? 0;
    var companyId = userInfor.companyInfo.id ?? 0;
    var eventId = preferences.getDouble(Constants.KEY_EVENT_ID);
    cancelEvent = await ApiRequest()
        .requestValidateActionEvent(context, companyId, locationId, inviteCode, phoneNumber, eventId, callBack);
    await cancelEvent.valueOrCancellation();
  }

  void resumeScan() {
    this.isScanned = false;
    this.lastQR = '';
    this.qrCodeStr = '';
  }

  void showPopupTakePhoto(List<TakePhotoStep> takePhotoStep, VisitorCheckIn visitorCheckIn) {
    if (this.type == BackgroundType.TOUCH_LESS) {
      controller?.dispose();
    }
    showDialog(context: context, barrierDismissible: false, builder: (BuildContext context) {
      return ChangeNotifierProvider(
        create: (_) => PopupTakePhotoNotifier(),
        child: PopupTakePhoto(takePhotoStep: takePhotoStep),
      );
    }).then((argument) async {
      reloadCamera();
      bool isDone = argument["isDone"] as bool;
      List<TakePhotoStep> takePhotoStep = argument["takePhotoStep"] as List<TakePhotoStep>;
      if (isDone == true) {
        var isSurvey = await utilities.isSurveyCustom(context, visitorCheckIn?.visitorType);
        takePhotoStep.forEach((element) {
          switch(element.photoStep) {
            case PhotoStep.FACE_STEP: {
              visitorCheckIn.imagePath = element.pathSavedPhoto;
              if (!isSurvey) {
                uploadFace(visitorCheckIn);
              }
              break;
            }
            case PhotoStep.ID_FONT_STEP: {
              visitorCheckIn.imageIdPath = element.pathSavedPhoto;
              if (!isSurvey) {
                uploadIdCardOnline(visitorCheckIn, false);
              }
              break;
            }
            case PhotoStep.ID_BACK_STEP: {
              visitorCheckIn.imageIdBackPath = element.pathSavedPhoto;
              if (!isSurvey) {
                uploadIdCardOnline(visitorCheckIn, true);
              }
              break;
            }
          }
          if (element.pathSavedPhoto == takePhotoStep.last.pathSavedPhoto && isSurvey) {
            moveToTouchless(visitorCheckIn, HomeNextScreen.SURVEY);
          }
        });
      } else {
        _dissmissPopupWaiting();
        resumeScan();
      }
    });
  }

  void actionWhenUploadDone(VisitorCheckIn visitorCheckIn) {
    if (isDoneIdBack && isDoneIdFace && isDoneIdFont) {
      actionEventMode(visitorCheckIn);
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
        _dissmissPopupWaiting();
        resumeScan();
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
        errorJob(message.description);
      } else {
        _dissmissPopupWaiting();
        resumeScan();
      }
    });
    cancelableOperation = await ApiRequest().requestUploadFace(context, visitorCheckIn.imagePath, callBack);
    await cancelableOperation.valueOrCancellation();
  }

  Future actionEventMode(VisitorCheckIn visitorCheckIn) async {
    ApiCallBack callBack = ApiCallBack((BaseResponse baseResponse) async {
      visitorCheckIn = VisitorCheckIn.fromJson(baseResponse.data);
      notifyListeners();
      var isPrint = await Utilities().checkIsPrint(context, visitorCheckIn?.visitorType);
      if (isPrint) {
        changeMessagePopup(appLocalizations.waitPrinter);
        visitorType = await Utilities().getTypeInDb(context, visitorCheckIn.visitorType);
        await Future.delayed(new Duration(milliseconds: 500));
        printTemplate(visitorCheckIn, isPrint);
      } else {
        isDoneAnyWay = true;
        showMessageSuccess(visitorCheckIn);
      }
    }, (Errors message) async {
      var contentError = message.description;
      if (message.description.contains("field_name")) {
        contentError = appLocalizations.errorInviteCode.replaceAll("field_name", appLocalizations.inviteCode);
      }
      if (message.code != -2) {
        errorJob(contentError);
      } else {
        _dissmissPopupWaiting();
        resumeScan();
      }
    });
    var userInfor = await Utilities().getUserInfor();
    var locationId = userInfor.deviceInfo.branchId ?? 0;
    var eventId = preferences.getDouble(Constants.KEY_EVENT_ID);
    cancelEvent = await ApiRequest()
        .requestRegisterEvent(context, locationId, visitorCheckIn, eventId, callBack);
    await cancelEvent.valueOrCancellation();
  }

  Future checkOutEvent(VisitorCheckIn visitorCheckIn, String inviteCode, String phoneNumber) async {
    ApiCallBack callBack = ApiCallBack((BaseResponse baseResponse) async {
      showMessageSuccess(visitorCheckIn);
    }, (Errors message) async {
      if (message.code != -2) {
        errorJob(message.description);
      } else {
        _dissmissPopupWaiting();
        resumeScan();
      }
    });
    var userInfor = await Utilities().getUserInfor();
    var signOutBy = userInfor?.deviceInfo?.id ?? 0;
    await ApiRequest().requestCheckOutEvent(context, inviteCode, phoneNumber, "", 5, signOutBy, branchId, callBack);
  }

  Future<void> printTemplate(VisitorCheckIn visitorCheckIn, bool isPrint) async {
    timerDoneAnyWay = Timer(Duration(seconds: Constants.TIMEOUT_PRINTER), () {
      if (!isDoneAnyWay) {
        isDoneAnyWay = true;
        showMessageSuccess(visitorCheckIn);
      }
    });
    String response = "";
    try {
      if (printer != null) {
        RenderRepaintBoundary boundary = repaintBoundary.currentContext.findRenderObject();
        Utilities().printJob(printer, boundary);
        if (!isDoneAnyWay) {
          timerDoneAnyWay?.cancel();
          isDoneAnyWay = true;
          showMessageSuccess(visitorCheckIn);
        }
      }
    } on PlatformException catch (e) {
      response = "Failed to Invoke: '${e.message}'.";
      Utilities().printLog("$response ");
      if (!isDoneAnyWay) {
        timerDoneAnyWay?.cancel();
        isDoneAnyWay = true;
        showMessageSuccess(visitorCheckIn);
      }
    } catch (e) {
      response = "Failed to Invoke: '${e.toString()}'.";
      Utilities().printLog("$response ");
      if (!isDoneAnyWay) {
        timerDoneAnyWay?.cancel();
        isDoneAnyWay = true;
        showMessageSuccess(visitorCheckIn);
      }
    }
  }

  void showMessageSuccess(VisitorCheckIn visitorCheckIn) {
    _dissmissPopupWaiting();
    assetsAudioPlayer.play();
    Utilities().showNoButtonDialog(context, true, DialogType.SUCCES, Constants.AUTO_HIDE_LESS,
        appLocalizations.hi, visitorCheckIn.fullName, null);
    resumeScan();
  }

  void _showPopupWaiting(String message) {
    isProcessing = true;
    messagePopup = message;
    notifyListeners();
  }

  void changeMessagePopup(String message) {
    messagePopup = message;
    notifyListeners();
  }

  void _dissmissPopupWaiting() {
    isProcessing = false;
    notifyListeners();
  }

  Future handlerLogout() async {
    var langSaved = preferences.getString(Constants.KEY_LANGUAGE) ?? Constants.VN_CODE;
    var firebase = preferences.getString(Constants.KEY_FIREBASE_TOKEN) ?? "";
    var index = preferences.getInt(Constants.KEY_DEV_MODE) ?? 0;
    var savedIdentifier = preferences.getString(Constants.KEY_IDENTIFIER) ?? "";
    var savedCompanyId = preferences.getDouble(Constants.KEY_COMPANY_ID);
    var user = preferences.getString(Constants.KEY_USER) ?? "";
    var domain = preferences.getString(Constants.KEY_DOMAIN) ?? "";
    preferences.clear();
    preferences.setString(Constants.KEY_LANGUAGE, langSaved);
    preferences.setBool(Constants.KEY_IS_LAUNCH, false);
    preferences.setInt(Constants.KEY_DEV_MODE, index);
    preferences.setString(Constants.KEY_FIREBASE_TOKEN, firebase);
    preferences.setString(Constants.KEY_IDENTIFIER, savedIdentifier);
    preferences.setDouble(Constants.KEY_COMPANY_ID, savedCompanyId);
    preferences.setString(Constants.KEY_USER, user);
    preferences.setString(Constants.KEY_DOMAIN, domain);
    navigationService.navigateTo(LoginScreen.route_name, 3);
    Utilities().cancelWaiting();
  }

  @override
  void dispose() {
    assetsAudioPlayer?.dispose();
    timerReset?.cancel();
//    timerReloadQR?.cancel();
    timerExpiredTouchless?.cancel();
    timerSocket?.cancel();
    controller?.dispose();
    timerClock?.cancel();
    cancelableOperation?.cancel();
    cancelEvent?.cancel();
    cancelableUploadID?.cancel();
    cancelableUploadIDBack?.cancel();
    super.dispose();
  }
}
