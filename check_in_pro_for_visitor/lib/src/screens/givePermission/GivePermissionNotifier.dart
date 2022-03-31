import 'dart:io';
import 'package:app_settings/app_settings.dart';
import 'package:check_in_pro_for_visitor/src/constants/Constants.dart';
import 'package:check_in_pro_for_visitor/src/constants/SizeConfig.dart';
import 'package:check_in_pro_for_visitor/src/screens/domainScreen/DomainScreen.dart';
import 'package:check_in_pro_for_visitor/src/screens/login/LoginScreen.dart';
import 'package:check_in_pro_for_visitor/src/utilities/AppLocalizations.dart';
import 'package:check_in_pro_for_visitor/src/utilities/PermissionCallBack.dart';
import 'package:check_in_pro_for_visitor/src/utilities/Utilities.dart';
import 'package:check_in_pro_for_visitor/src/widgetUtilities/awesomeDialog/awesome_dialog.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:check_in_pro_for_visitor/src/screens/MainNotifier.dart';
import 'package:check_in_pro_for_visitor/src/constants/AppString.dart';

import '../MainNotifier.dart';

class GivePermissionNotifier extends MainNotifier {
  bool isLoading = false;
  PageController controller = PageController(initialPage: 0);

  String lang;
  List<SliderPermission> listPermission = List();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  Future<void> acquiredPermission(SliderPermission item) async {
    isLoading = true;
    notifyListeners();
    await platformPermission(item, true);
    isLoading = false;
    notifyListeners();
  }

  Future<void> firebaseCloudMessaging_Listeners() async {
    await _firebaseMessaging.getToken().then((token) async {
      preferences.setString(Constants.KEY_FIREBASE_TOKEN, token);
      Utilities().printLog("firebaseId: $token");
    });
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {},
      onResume: (Map<String, dynamic> message) async {},
      onLaunch: (Map<String, dynamic> message) async {},
    );
  }

  Future<void> iOSNotification(SliderPermission item) async {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) async {
          if (settings.alert == true) {
            item.isGranted = true;
            notifyListeners();
            nextPage(item);
          }
    });
  }

  Future platformPermission(SliderPermission item, bool iOSPermission) async {
    var permissionCallBack = PermissionCallBack(() async {
      item.isGranted = true;
      notifyListeners();
      nextPage(item);
    }, () {}, () {
      Utilities().showTwoButtonDialog(
          context,
          DialogType.INFO,
          null,
          appLocalizations.noPermissionTitle,
          appLocalizations.noPermissionCommon,
          appLocalizations.btnSkip,
          appLocalizations.btnOpenSetting,
              () async {}, () {
        AppSettings.openAppSettings();
      });
    });
    List<PermissionGroup> permissions = List();
    permissions.add(item.group);
    await Utilities.requestPermission(
      context,
      permissions,
      permissionCallBack,
      false,
      iOSPermission,
    );
  }

  Future doNextFlow() async {
    preferences.setBool(Constants.KEY_IS_LAUNCH, false);
    navigationService.navigateTo(LoginScreen.route_name, 3);
  }

  Future<void> turnOnKioskMode(SliderPermission item) async {
    if (await utilities.isLauncher()) {
      await utilities.setKioskMode(true);
    } else {
      preferences.setBool(Constants.KEY_ON_LOCK, true);
      await utilities.goHome();
    }
    nextPage(item);
  }

  Future<void> turnOnPermission(SliderPermission item) async {
    if (item.type == PermissionType.NOTIFICATION) {
      await iOSNotification(item);
    } else if (item.type == PermissionType.KIOSK) {
      await turnOnKioskMode(item);
    } else {
      await acquiredPermission(item);
    }
  }

  void nextPage(SliderPermission item) {
    if (item.type == listPermission.last.type) {
      doNextFlow();
    } else {
      controller.animateToPage(controller.page.toInt() + 1,
          duration: Duration(milliseconds: 400), curve: Curves.easeIn);
    }
  }

  Future<void> getDefaultValue() async {
    var isConnection = await Utilities().isConnectInternet(isChangeState: false);
    if (isConnection) {
      await firebaseCloudMessaging_Listeners();
    } else {
      showNoInternet();
    }
    lang = preferences.getString(Constants.KEY_LANGUAGE);
    if (lang?.isEmpty == true || !Constants.LIST_LANG.contains(lang)) {
      lang = Constants.VN_CODE;
    }
    preferences.setString(Constants.KEY_LANGUAGE, lang);
    await appLocalizations.load(Locale(lang));
    if (Platform.isAndroid) {
      listPermission.add(
        SliderPermission(
          PermissionType.CAMERA,
          PermissionGroup.camera,
          Image.asset(
            "assets/images/access_camera.png",
            fit: BoxFit.contain,
            cacheWidth: 358 * SizeConfig.devicePixelRatio,
            cacheHeight: 261 * SizeConfig.devicePixelRatio,
          ),
          appLocalizations.cameraPermissionTitle,
          appLocalizations.cameraPermissionSubtitle,
          appLocalizations.translate(AppString.BTN_GIVE_CAMERA_PERMISSION)
        ),
      );
      listPermission.add(
        SliderPermission(
          PermissionType.STORAGE,
            PermissionGroup.storage,
          Image.asset(
            "assets/images/access_camera.png",
            fit: BoxFit.contain,
            cacheWidth: 358 * SizeConfig.devicePixelRatio,
            cacheHeight: 261 * SizeConfig.devicePixelRatio,
          ),
          appLocalizations.storagePermissionTitle,
          appLocalizations.storagePermissionSubtitle,
            appLocalizations.translate(AppString.BTN_GIVE_CAMERA_PERMISSION)
        ),
      );
      listPermission.add(
        SliderPermission(
          PermissionType.KIOSK,
          null,
          Image.asset(
            (lang == Constants.VN_CODE)
                ? "assets/images/home_vi.jpg"
                : "assets/images/home_en.jpg",
            fit: BoxFit.contain,
            cacheWidth: 522 * SizeConfig.devicePixelRatio,
            cacheHeight: 224 * SizeConfig.devicePixelRatio,
          ),
          appLocalizations.lockTitle,
          appLocalizations.lockSubtitle,
          appLocalizations.lockTitle
        ),
      );
    } else {
      listPermission.add(
        SliderPermission(
          PermissionType.CAMERA,
          PermissionGroup.camera,
          Image.asset(
            "assets/images/access_camera.png",
            fit: BoxFit.contain,
            cacheWidth: 388 * SizeConfig.devicePixelRatio,
            cacheHeight: 291 * SizeConfig.devicePixelRatio,
          ),
          appLocalizations.cameraPermissionTitle,
          appLocalizations.cameraPermissionSubtitle,
          appLocalizations.translate(AppString.BTN_GIVE_CAMERA_PERMISSION),
        ),
      );
      listPermission.add(
        SliderPermission(
          PermissionType.NOTIFICATION,
          PermissionGroup.camera,
          Image.asset(
            "assets/images/access_noti.png",
            fit: BoxFit.contain,
            cacheWidth: 388 * SizeConfig.devicePixelRatio,
            cacheHeight: 291 * SizeConfig.devicePixelRatio,
          ),
          appLocalizations.notificationPermissionTitle,
          appLocalizations.notificationPermissionSubtitle,
          appLocalizations.translate(AppString.BTN_GIVE_CAMERA_PERMISSION),
        ),
      );
    }
  }

  void showNoInternet() {
    Utilities().showOneButtonDialog(
        context,
        DialogType.ERROR,
        null,
        appLocalizations.translate(AppString.TITLE_NOTIFICATION),
        appLocalizations.translate(AppString.NO_INTERNET),
        appLocalizations.translate(AppString.BUTTON_TRY_AGAIN), () async {
      var isConnection = await Utilities().isConnectInternet(isChangeState: false);
      if (isConnection) {
        await firebaseCloudMessaging_Listeners();
      } else {
        showNoInternet();
      }
    });
  }
}

class SliderPermission {
  PermissionType type;
  PermissionGroup group;
  bool isGranted = false;
  Widget image;
  String title;
  String subTitle;
  String titleBtn;

  SliderPermission(this.type, this.group, this.image, this.title, this.subTitle,
      this.titleBtn);
}

enum PermissionType { CAMERA, STORAGE, NOTIFICATION, KIOSK }
