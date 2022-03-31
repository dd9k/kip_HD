import 'dart:async';
import 'dart:convert';

import 'package:async/async.dart';
import 'package:camera/camera.dart';
import 'package:check_in_pro_for_visitor/src/constants/Constants.dart';
import 'package:check_in_pro_for_visitor/src/model/AuthenticateHD.dart';
import 'package:check_in_pro_for_visitor/src/model/BaseResponse.dart';
import 'package:check_in_pro_for_visitor/src/model/Errors.dart';
import 'package:check_in_pro_for_visitor/src/model/IDModelHD.dart';
import 'package:check_in_pro_for_visitor/src/model/ResponseHD.dart';
import 'package:check_in_pro_for_visitor/src/model/TakePhotoStep.dart';
import 'package:check_in_pro_for_visitor/src/screens/MainNotifier.dart';
import 'package:check_in_pro_for_visitor/src/services/ApiCallBack.dart';
import 'package:check_in_pro_for_visitor/src/services/RequestApi.dart';
import 'package:check_in_pro_for_visitor/src/utilities/Utilities.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class CameraProperty {
  Timer timerTakePhoto;
  String path = "";
  String message = "";
  bool reloadCamera = false;
  bool rebuildCamera = false;
  bool isUploaded = false;
  int turnCamera = 0;
  bool isEventMode;
  bool isTakePhoto = false;
  AsyncMemoizer<int> memCache = AsyncMemoizer();
  bool visibleButton = false;
  bool isCountDown = false;
  bool isDisableAction = false;
  TakePhotoStep takePhotoStep;
  CameraProperty(this.takePhotoStep);
}

class PopupTakePhotoNotifier extends MainNotifier {
  CameraController controller;
  Future<void> convertController;
  PageController pageviewController = PageController(initialPage: 0);
  List<CameraProperty> cameraProperty = List();
  bool isLoading = false;
  IDModelHD idCardHDBank;

  void initData(List<TakePhotoStep> steps) {
    for (int i = 0; i < steps.length; i++) {
      CameraProperty camera = CameraProperty(steps[i]);
      cameraProperty.add(camera);
    }
  }

  void showHideLoading(bool isShow) {
    isLoading = isShow;
    notifyListeners();
  }

  void disableAction(int index) {
    cameraProperty[index].isDisableAction = true;
    notifyListeners();
  }


  void enableAction(int index) {
    cameraProperty[index].isDisableAction = false;
    notifyListeners();
  }

  void disableOtherStep(int enableIndex) {
    enableAction(enableIndex);
    for (int i = 0; i< cameraProperty.length; i++) {
      if (i != enableIndex) {
        disableAction(i);
      }
    }
  }

  Future<int> initializeController(int index) async {
//    await utilities.writeLogInBack("initialize function $index...............................");
//    utilities.printLog("initialize function $index...............................", isDebug: true);
    return cameraProperty[index].memCache.runOnce(
      () async {
        disableAction(index);
//        await utilities.writeLogInBack("memCache $index...............................");
//        utilities.printLog("memCache $index...............................", isDebug: true);
        WidgetsFlutterBinding.ensureInitialized();
        cameraProperty[index].timerTakePhoto?.cancel();
        cameraProperty[index].isTakePhoto = false;
        cameraProperty[index].isEventMode = preferences.getBool(Constants.KEY_EVENT) ?? false;
        if (controller == null) {
          final cameras = await availableCameras();
          var useFrontCamera = (preferences.getBool(Constants.KEY_FRONT_CAMERA) ?? true);
          var indexCamera = 0;
          if (useFrontCamera) {
            indexCamera = 1;
          }
          var frontCamera = cameras[indexCamera];
          controller = CameraController(frontCamera, ResolutionPreset.high, enableAudio: false);
          convertController = controller.initialize();
          await convertController;
        }
        await Future.delayed(Duration(milliseconds: 500));
        enableAction(index);
//        await utilities.writeLogInBack("initializeed $index...............................");
//        utilities.printLog("initializeed $index...............................", isDebug: true);
        return 1;
      },
    );
  }

  Future takePhoto(int index) async {
    utilities.moveToWaiting();
    if (!cameraProperty[index].isTakePhoto) {
      await convertController;
      cameraProperty[index].timerTakePhoto?.cancel();
      cameraProperty[index].isTakePhoto = true;
      cameraProperty[index].message = "";
      String fileName = "";
      if (cameraProperty[index].takePhotoStep.photoStep == PhotoStep.FACE_STEP) {
        fileName = '${DateTime.now()}.png';
      } else if (cameraProperty[index].takePhotoStep.photoStep == PhotoStep.ID_FONT_STEP) {
        fileName = '${DateTime.now()}${Constants.SCAN_VISION}.png';
      } else {
        fileName = '${DateTime.now()}${Constants.BACKSIDE_SCAN_VISION}.png';
      }
      try {
        // Ensure that the camera is initialized.
        var cacheDirectory = await getTemporaryDirectory();
        final path = join(
          // Store the picture in the temp directory.
          // Find the temp directory using the `path_provider` plugin.
          cacheDirectory.path,
          fileName,
        );
        this.cameraProperty[index].path = path;
        await Future.delayed(new Duration(milliseconds: 100));
        await controller.takePicture(path);
        cameraProperty[index].takePhotoStep.pathSavedPhoto = path;
      } catch (e) {
        Utilities().printLog(e.toString());
        takePhotoAgain(index);
      }
      cameraProperty[index].visibleButton = true;
      cameraProperty[index].reloadCamera = true;
      cameraProperty[index].isCountDown = true;
      notifyListeners();
    }
  }

  Future<void> doneTakePhoto(List<TakePhotoStep> takePhotoStep) async {
    for (int i = 0; i < takePhotoStep.length; i++) {
      takePhotoStep[i] = cameraProperty[i].takePhotoStep;
    }
    await controller?.dispose();
    navigationService.navigatePop(this.context,
        arguments: {"isDone": true, "takePhotoStep": takePhotoStep, "idCardHDBank": idCardHDBank});
  }

  void takePhotoAgain(int index) {
    cameraProperty[index].isCountDown = false;
    cameraProperty[index].reloadCamera = !cameraProperty[index].reloadCamera;
    cameraProperty[index].visibleButton = false;
    cameraProperty[index].isTakePhoto = false;
    cameraProperty[index].isUploaded = false;
    notifyListeners();
  }

  Future countDownTakePhoto(int index) async {
    cameraProperty[index].timerTakePhoto?.cancel();
    var timeToTakePhoto = utilities.getConfigKios(preferences).picCountdownInterval + 1;
//    var timeToTakePhoto = 5;
    cameraProperty[index].timerTakePhoto = Timer.periodic(Duration(seconds: 1), (timer) async {
      if (timer.tick < timeToTakePhoto) {
        cameraProperty[index].message = (timeToTakePhoto - timer.tick).toString();
        notifyListeners();
      } else {
        await takePhoto(index);
        doNext(true);
      }
    });
  }

  Future doNext(bool isOCR) async {
    utilities.moveToWaiting();
    int currentIndex = pageviewController.page.toInt();
    int nextIndex = pageviewController.page.toInt() + 1;
    disableOtherStep(nextIndex);
    if (isOCR && parent.isConnection && cameraProperty[currentIndex].takePhotoStep.photoStep == PhotoStep.ID_FONT_STEP && !cameraProperty[currentIndex].isUploaded) {
      showHideLoading(true);
//      int lastTime = preferences.getInt(Constants.KEY_LAST_AUTHEN_HD) ?? 0;
//      int now = DateTime.now().millisecondsSinceEpoch;
//      int expired = utilities?.getAuthenHD(preferences)?.expired ?? 0;
//      if (((now - lastTime) / 1000) >= expired) {
//        requestAuthenHDBank(currentIndex);
//      } else {
//        requestORCHDBank(currentIndex);
//      }
      requestORCFinal(currentIndex);
    } else {
      pageviewController.animateToPage(nextIndex,
          duration: Duration(milliseconds: 400), curve: Curves.easeIn);
    }
    notifyListeners();
  }

  Future requestORCFinal(int index) async {
    CameraProperty property = cameraProperty[index];
    ApiCallBack callBack = ApiCallBack((BaseResponse baseResponse) async {
      idCardHDBank = IDModelHD.fromJson(baseResponse.data);
      property.isUploaded = true;
      showHideLoading(false);
      pageviewController.animateToPage(pageviewController.page.toInt() + 1,
          duration: Duration(milliseconds: 400), curve: Curves.easeIn);
    }, (Errors message) {
      property.isUploaded = true;
      showHideLoading(false);
      pageviewController.animateToPage(pageviewController.page.toInt() + 1,
          duration: Duration(milliseconds: 400), curve: Curves.easeIn);
    });
    await ApiRequest().requestOCRFinal(this.context, cameraProperty[index].path, callBack);
  }

  Future requestORCHDBank(int index) async {
    CameraProperty property = cameraProperty[index];
    ApiCallBack callBack = ApiCallBack((ResponseHD responseHD) async {
      idCardHDBank = responseHD.infoOCR;
      property.isUploaded = true;
      showHideLoading(false);
      pageviewController.animateToPage(pageviewController.page.toInt() + 1,
          duration: Duration(milliseconds: 400), curve: Curves.easeIn);
    }, (Errors message) {
      property.isUploaded = true;
      showHideLoading(false);
      pageviewController.animateToPage(pageviewController.page.toInt() + 1,
          duration: Duration(milliseconds: 400), curve: Curves.easeIn);
    });
    await ApiRequest().requestORCHDBank(this.context, cameraProperty[index].path, callBack);
  }

  Future requestAuthenHDBank(int index) async {
    CameraProperty property = cameraProperty[index];
    ApiCallBack callBack = ApiCallBack((AuthenticateHD authenticateHD) async {
      var authenticationString = JsonEncoder().convert(authenticateHD.toJson());
      preferences.setString(Constants.KEY_AUTHENTICATE_HD, authenticationString);
      preferences.setInt(Constants.KEY_LAST_AUTHEN_HD, DateTime.now().millisecondsSinceEpoch);
      requestORCHDBank(index);
    }, (Errors message) {
      property.isUploaded = true;
      showHideLoading(false);
      pageviewController.animateToPage(pageviewController.page.toInt() + 1,
          duration: Duration(milliseconds: 400), curve: Curves.easeIn);
    });
    await ApiRequest().requestLoginHD(this.context, callBack);
  }

  Future doBack() async {
    utilities.moveToWaiting();
    int backIndex = pageviewController.page.toInt() - 1;
    disableOtherStep(backIndex);
    pageviewController.animateToPage(backIndex,
        duration: Duration(milliseconds: 400), curve: Curves.easeIn);
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
