import 'dart:io';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:check_in_pro_for_visitor/src/constants/AppColors.dart';
import 'package:check_in_pro_for_visitor/src/constants/AppDestination.dart';
import 'package:check_in_pro_for_visitor/src/constants/AppImage.dart';
import 'package:check_in_pro_for_visitor/src/constants/SizeConfig.dart';
import 'package:check_in_pro_for_visitor/src/constants/Styles.dart';
import 'package:check_in_pro_for_visitor/src/model/TakePhotoStep.dart';
import 'package:check_in_pro_for_visitor/src/screens/MainScreen.dart';
import 'package:check_in_pro_for_visitor/src/screens/scanVS/ScannerOverlayShape.dart';
import 'package:check_in_pro_for_visitor/src/utilities/AppLocalizations.dart';
import 'package:check_in_pro_for_visitor/src/widgetUtilities/Loading.dart';
import 'package:flutter/material.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:provider/provider.dart';
import 'PopupTakePhotoNotifier.dart';

class PopupTakePhoto extends MainScreen {
  static const String route_name = '/popupTakePhoto';
  final List<TakePhotoStep> takePhotoStep;
  final bool isOCR;

  PopupTakePhoto({this.takePhotoStep, this.isOCR = false});

  @override
  PopupTakePhotoState createState() => PopupTakePhotoState();

  @override
  String getNameScreen() {
    return route_name;
  }
}

class PopupTakePhotoState extends MainScreenState<PopupTakePhotoNotifier> {
  var countDownText = SizeConfig.safeBlockVertical * 10;

  PopupTakePhoto get popupTakePhoto => widget as PopupTakePhoto;
  bool isInit = false;

  List<TakePhotoStep> get takePhotoStep => popupTakePhoto.takePhotoStep;

  bool get isOCR => popupTakePhoto.isOCR;

  @override
  Widget build(BuildContext context) {
//    provider.utilities.writeLogInBack("build build...............................");
//    provider.utilities.printLog("build build...............................", isDebug: true);
    if (!isInit) {
      isInit = true;
      provider.initData(takePhotoStep);
    }
    return _showDialog();
  }

  Widget _showDialog() {
    return Dialog(
      child: Selector<PopupTakePhotoNotifier, bool>(
        builder: (context, data, child) {
          return Loading(
            visible: data,
            child: PageView.builder(
                controller: provider.pageviewController,
                itemCount: provider.cameraProperty.length,
                reverse: false,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, i) {
                  return Column(
                    children: <Widget>[
                      buildHeader(context, i),
                      Selector<PopupTakePhotoNotifier, bool>(
                          selector: (buildContext, provider) => provider.cameraProperty[i].rebuildCamera,
                          builder: (context, data, child) => buildCamera(i, heightScreen * 60)),
                      buildButtonBottom(i),
                    ],
                  );
                }),
          );
        },
        selector: (buildContext, provider) => provider.isLoading,
      ),
    );
  }

  Widget buildCamera(int i, double height) {
//    provider.utilities.writeLogInBack("buildCamera $i...............................");
//    provider.utilities.printLog("buildCamera $i...............................", isDebug: true);
    return Selector<PopupTakePhotoNotifier, bool>(
      builder: (context, data, child) {
        if (!data) {
          return FutureBuilder<int>(
            future: provider.initializeController(i),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return NativeDeviceOrientationReader(
                  builder: (context1) {
                    NativeDeviceOrientation orientation = NativeDeviceOrientationReader.orientation(context1);
                    switch (orientation) {
                      case NativeDeviceOrientation.landscapeLeft:
                        provider.cameraProperty[i].turnCamera = -1;
                        break;
                      case NativeDeviceOrientation.landscapeRight:
                        provider.cameraProperty[i].turnCamera = 1;
                        break;
                      case NativeDeviceOrientation.portraitDown:
                        provider.cameraProperty[i].turnCamera = 2;
                        break;
                      case NativeDeviceOrientation.portraitUp:
                        provider.cameraProperty[i].turnCamera = 0;
                        break;
                      default:
                        provider.cameraProperty[i].turnCamera = 0;
                        break;
                    }
                    return Stack(
                      fit: StackFit.passthrough,
                      children: <Widget>[
                        Align(
                          alignment: Alignment.center,
                          child: _buildCameraPreview(
                            CameraPreview(provider.controller),
                            height,
                            i,
                          ),
                        ),
                        if (provider.cameraProperty[i].takePhotoStep.photoStep != PhotoStep.FACE_STEP)
                          Align(alignment: Alignment.center, child: _buildOverlayPreview(height, i)),
                      ],
                    );
                  },
                );
              } else {
                return Align(alignment: Alignment.center, child: _buildCameraPreview(null, height, i));
              }
            },
          );
        }
        return _buildPicturePreview(height, i);
      },
      selector: (buildContext, provider) => provider.cameraProperty[i].reloadCamera,
    );
  }

  Widget _buildOverlayPreview(double size, int index) {
    var width = isPortrait ? widthScreen * 30 : heightScreen * 40;
    var height = width * 0.6;
    return Container(
      height: size,
      child: buildCircleLayout(
          size,
          FittedBox(
            fit: BoxFit.cover,
            child: Container(
              width: size,
              height: size,
              child: null,
              decoration: ShapeDecoration(
                shape: ScannerOverlayShape(
                    borderColor: AppColor.HDBANK_YELLOW_MORE,
                    borderWidth: 3.0,
                    cutOutSizeWidth: isPortrait ? width : height,
                    cutOutSizeHeight: isPortrait ? height : width),
              ),
            ),
          ),
          true,
          index),
    );
  }

  Widget buildButtonBottom(int i) {
    return Selector<PopupTakePhotoNotifier, bool>(
      builder: (context, data, child) {
        return Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              if (provider.cameraProperty[i].visibleButton) buildSnapAgain(i),
              SizedBox(
                width: 20,
              ),
              if (!provider.cameraProperty[i].visibleButton) buildTakePhoto(i),
              SizedBox(
                width: 20,
              ),
              if (provider.cameraProperty[i].visibleButton)
                (provider.cameraProperty.length > 1 && i < provider.cameraProperty.length - 1)
                    ? buidNext(i)
                    : buildDone(i),
            ],
          ),
        );
      },
      selector: (buildContext, provider) => provider.cameraProperty[i].visibleButton,
    );
  }

  Widget buildSnapAgain(int i) {
    return Selector<PopupTakePhotoNotifier, bool>(
      builder: (context, data, child) {
        return Padding(
          padding: const EdgeInsets.only(top: 40.0, left: 27),
          child: RaisedButton.icon(
            onPressed: data == true
                ? null
                : () {
                    provider.takePhotoAgain(i);
                  },
            color: Color(0XFFEAEEF2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            icon: Padding(
              padding: const EdgeInsets.only(top: 7.0, bottom: 7),
              child: appImage.cameraHDBank,
            ),
            label: Padding(
              padding: const EdgeInsets.only(top: 5.0, bottom: 5),
              child: Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Text(
                  AppLocalizations.of(context).takeNewPicture,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        );
      },
      selector: (buildContext, provider) => provider.cameraProperty[i].isDisableAction,
    );
  }

  Widget buildTakePhoto(int i) {
    return Selector<PopupTakePhotoNotifier, bool>(
      builder: (context, data, chilld) {
        return Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            children: <Widget>[
              GestureDetector(
                onTap: data == true
                    ? null
                    : () {
                        provider.takePhoto(i);
                      },
                child: appImage.screenShotHDBank,
              ),
              Text(
                appLocalizations.takePicture,
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
      selector: (buildContext, provider) => provider.cameraProperty[i].isDisableAction,
    );
  }

  Widget buidNext(int i) {
    return Selector<PopupTakePhotoNotifier, bool>(
      builder: (context, data, child) {
        return Padding(
          padding: const EdgeInsets.only(top: 40.0, right: 27),
          child: SizedBox(
            width: 200,
            height: 60,
            child: RaisedButton(
              onPressed: data == true
                  ? null
                  : () {
                      provider.doNext(isOCR);
                    },
              color: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              padding: EdgeInsets.zero,
              child: Container(
                padding: const EdgeInsets.only(top: 5.0, bottom: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  gradient: LinearGradient(
                    colors: [
                      Color(0xffFFC20E),
                      Color(0xffF7A30A),
                    ],
                    stops: [0.0, 1.0],
                    begin: FractionalOffset.topCenter,
                    end: FractionalOffset.bottomCenter,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Text(
                        appLocalizations.btnContinue,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: appImage.okeHDBank,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      selector: (buildContext, provider) => provider.cameraProperty[i].isDisableAction,
    );
  }

  Widget buildDone(int i) {
    return Padding(
      padding: const EdgeInsets.only(top: 40.0, right: 27),
      child: SizedBox(
        width: 200,
        height: 60,
        child: RaisedButton(
          onPressed: () {
            provider.doneTakePhoto(takePhotoStep);
          },
          color: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          padding: EdgeInsets.zero,
          child: Container(
            padding: const EdgeInsets.only(top: 5.0, bottom: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              gradient: LinearGradient(
                colors: [
                  Color(0xffFFC20E),
                  Color(0xffF7A30A),
                ],
                stops: [0.0, 1.0],
                begin: FractionalOffset.topCenter,
                end: FractionalOffset.bottomCenter,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Text(
                    appLocalizations.completed,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: appImage.okeHDBank,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Padding buildHeader(BuildContext context, int i) {
    String title = '';
    String subTitle = '';

    if (provider.cameraProperty[i].takePhotoStep.photoStep == PhotoStep.FACE_STEP) {
      title = appLocalizations.portraitPictures;
      subTitle = appLocalizations.frontOfTheCamera;
    } else if (provider.cameraProperty[i].takePhotoStep.photoStep == PhotoStep.ID_FONT_STEP) {
      title = appLocalizations.identification;
      subTitle = appLocalizations.showIdInFont;
    } else {
      title = appLocalizations.identification;
      subTitle = appLocalizations.showIdInBack;
    }
    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Selector<PopupTakePhotoNotifier, bool>(
            builder: (context, data, child) {
              return Expanded(
                child: i == 0
                    ? SizedBox()
                    : GestureDetector(
                        onTap: data == true
                            ? null
                            : () {
                                provider.doBack();
                              },
                        child: Container(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.arrow_back,
                                size: 30,
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              Text(
                                appLocalizations.comeBack,
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
              );
            },
            selector: (buildContext, provider) => provider.cameraProperty[i].isDisableAction,
          ),
          Expanded(
            flex: 3,
            child: Container(
              child: Column(
                children: <Widget>[
                  Text(
                    title,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: Styles.OpenSans),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    subTitle,
                    maxLines: 1,
                    style: TextStyle(fontSize: 16, fontFamily: Styles.OpenSans),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                await provider.controller?.dispose();
                provider.navigationService.navigatePop(this.context,
                    arguments: {"isDone": false, "takePhotoStep": null, "idCardHDBank": null});
              },
              child: Container(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.clear,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview(CameraPreview cameraPreview, double height, int index) {
    return Container(
      height: height,
      child: buildCircleLayout(
          height,
          FittedBox(
            fit: BoxFit.cover,
            child: Container(
              width: (cameraPreview == null || provider.controller == null || !provider.controller.value.isInitialized)
                  ? height
                  : height * provider.controller.value.aspectRatio,
              height: height,
              child: (cameraPreview == null || provider.controller == null)
                  ? Container(
                      color: Colors.black,
                      child: Center(
                        child: Text(
                          appLocalizations.loadingCamera,
                          style: TextStyle(color: AppColor.HINT_TEXT_COLOR, fontSize: AppDestination.TEXT_NORMAL),
                        ),
                      ),
                    )
                  : cameraPreview, // this is my CameraPreview
            ),
          ),
          true,
          index),
    );
  }

  Widget buildCircleLayout(double height, Widget child, bool isTurn, int index) {
    return Container(
        width: widthScreen * 80,
        height: height,
        decoration: BoxDecoration(
          color: Colors.transparent,
        ),
        child: RotatedBox(
          quarterTurns: isTurn ? provider.cameraProperty[index].turnCamera : 0,
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            child: OverflowBox(
              alignment: Alignment.center,
              child: child,
            ),
          ),
        ));
  }

  Widget _buildPicturePreview(double size, int index) {
    return buildCircleLayout(
      size,
      Container(
        width: size,
        height: size,
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationY(math.pi),
          child: Image.file(
            File(provider.cameraProperty[index].path),
            fit: BoxFit.cover,
          ),
        ), // this is my CameraPreview
      ),
      false,
      index,
    );
  }
}
