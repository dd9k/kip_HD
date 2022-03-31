import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:check_in_pro_for_visitor/src/constants/AppColors.dart';
import 'package:check_in_pro_for_visitor/src/constants/AppDestination.dart';
import 'package:check_in_pro_for_visitor/src/constants/AppImage.dart';
import 'package:check_in_pro_for_visitor/src/constants/Constants.dart';
import 'package:check_in_pro_for_visitor/src/constants/SizeConfig.dart';
import 'package:check_in_pro_for_visitor/src/screens/waiting/WaitingNotifier.dart';
import 'package:check_in_pro_for_visitor/src/screens/waiting/WaitingScreen.dart';
import 'package:check_in_pro_for_visitor/src/services/NavigationService.dart';
import 'package:check_in_pro_for_visitor/src/services/ServiceLocator.dart';
import 'package:check_in_pro_for_visitor/src/utilities/AppLocalizations.dart';
import 'package:check_in_pro_for_visitor/src/utilities/Utilities.dart';
import 'package:check_in_pro_for_visitor/src/utilities/UtilityNotifier.dart';
import 'package:check_in_pro_for_visitor/src/widgetUtilities/InvisibleWidget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import '../constants/AppColors.dart';
import '../constants/AppString.dart';
import '../constants/SizeConfig.dart';

import '../utilities/AppLocalizations.dart';
import 'MySnackBar.dart';
import 'awesomeDialog/awesome_dialog.dart';

class Background<T extends UtilityNotifier> extends StatelessWidget {
  Background(
      {Key key,
      this.timeOutInit,
      this.type,
      this.child,
      this.isRestoreLang,
      this.isShowLogo,
      this.isShowChatBox,
      this.contentChat,
      this.isUseProvider,
      this.isShowBack,
      this.isShowNext,
      this.isShowFooter,
      this.provider,
      this.isShowClock = false,
      this.isRightBtn = false,
      this.isShowFloatingButton = false,
      this.isOpeningKeyboard = false,
      this.isShowStepper = false,
      this.isShowLogout,
      this.isAnimation,
      this.callback,
      this.callbackRight,
      this.searchBar,
      this.messSnapBar = "",
      this.textFooterColor = Colors.black,
      this.textHeaderColor = AppColor.BUTTON_TEXT_COLOR,
      this.isShowFooterText = true,
        this.isFooterInContent = false,
      this.initState})
      : super(key: key);

  // 0:LoginPortrait 1: LoginLandscape 2: Main
  final BackgroundType type;
  final bool isUseProvider;
  final bool isShowStepper;
  final bool isShowBack;
  final bool isRightBtn;
  final bool isOpeningKeyboard;
  bool isShowNext;
  final bool isShowFooter;
  final bool isFooterInContent;
  final bool isRestoreLang;
  final Widget child;
  final String contentChat;
  final String messSnapBar;
  final bool initState;
  final bool isShowLogo;
  final bool isShowClock;
  final bool isShowChatBox;
  final T provider;
  final bool isShowFloatingButton;
  final bool isShowLogout;
  final bool isAnimation;
  final VoidCallback callback;
  final int timeOutInit;
  bool isReload = false;
  Widget searchBar;
  VoidCallback callbackRight;
  Color textFooterColor;
  Color textHeaderColor;
  bool isShowFooterText;

  void updateReload(bool value) {
    isReload = value;
  }

  bool getReload() {
    return isReload;
  }

  static Background of(BuildContext context) {
    return context.findAncestorWidgetOfExactType();
  }

  @override
  Widget build(BuildContext context) {
    Utilities().printLog("build BackgroundState");
    var provider;
    var colorComponent = context.textInTime;
    if (isUseProvider == true) {
      provider = Provider.of<WaitingNotifier>(context, listen: false);
      if (provider is WaitingNotifier && provider != null) {
        var haveColor = provider.companyNameColor != null && provider.companyNameColor.isNotEmpty;
        colorComponent = haveColor ? Color(int.parse(provider.companyNameColor)) : context.textInTime;
      }
    }
    switch (type) {
      case BackgroundType.MAIN:
        {
          return _BackgroundMain(context);
        }
      case BackgroundType.TOUCH_LESS:
        {
          return _BackgroundTouchLess(context);
        }
      case BackgroundType.WAITING_NEW:
        {
          return _BackgroundWaitingNew(context, colorComponent);
        }
      case BackgroundType.SCAN_ID:
        {
          return _BackgroundMainScanID(context);
        }
    }
    return _BackgroundWaitingNew(context, colorComponent);
  }

  var tempFocus = FocusNode();

  Widget _BackgroundMain(BuildContext context) {
    SizeConfig().init(context);
    var media = MediaQuery.of(context);
    var isPortrait = media.orientation == Orientation.portrait;
    var widthLogo = isPortrait ? SizeConfig.safeBlockHorizontal * 25 : SizeConfig.safeBlockVertical * 26;
    var heightLogo = isPortrait ? SizeConfig.safeBlockHorizontal * 10 : SizeConfig.safeBlockVertical * 11;
    var paddingTop = SizeConfig.blockSizeVertical * 2;
    return Stack(
      children: <Widget>[
        buildMainBg(),
        if (!isFooterInContent) createHDFooter(context),
        WillPopScope(
          onWillPop: () async => false,
          child: GestureDetector(
            onTap: () {
              if (isOpeningKeyboard) {
                FocusScope.of(context).requestFocus(tempFocus);
              }
            },
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Column(
                children: [
                  buildOfflineSnack(initState),
                  Expanded(
                    flex: 1,
                    child: Stack(
                      children: <Widget>[
                        LayoutBuilder(
                          builder: (BuildContext context, BoxConstraints viewportConstraints) {
                            return ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: viewportConstraints.maxHeight,
                                ),
                                child: Container(
                                  width: double.infinity,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      if (isRightBtn)
                                        SizedBox(
                                          height: 80,
                                        ),
                                      buildLogo(paddingTop, context, heightLogo, widthLogo),
                                      Expanded(
                                        flex: 1,
                                        child: child,
                                      ),
                                    ],
                                  ),
                                ));
                          },
                        ),
                        btnBack(context, textHeaderColor),
                        btnRight(context),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        if (isFooterInContent) createHDFooter(context),
      ],
    );
  }

  Container buildMainBg() {
    return Container(
      color: AppColor.MAIN_BACKGROUND,
      child: Stack(
        children: <Widget>[
          Container(width: SizeConfig.screenWidth, height: SizeConfig.screenHeight, child: locator<AppImage>().bgMain),
          Container(width: SizeConfig.screenWidth, child: locator<AppImage>().bgMainHeader)
        ],
      ),
    );
  }

  Container buildTouchlessBg() {
    return Container(
      color: AppColor.MAIN_BACKGROUND,
      child: Stack(
        children: <Widget>[
          Container(width: SizeConfig.screenWidth, height: SizeConfig.screenHeight, child: locator<AppImage>().bgMain),
          Container(width: SizeConfig.screenWidth, child: locator<AppImage>().bgMainHeaderTouchless)
        ],
      ),
    );
  }

  Visibility btnRight(BuildContext context) {
    return Visibility(
      visible: isRightBtn,
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
            padding: EdgeInsets.only(
                top: locator<AppDestination>().getPadding(
                    context, AppDestination.PADDING_EXTRAS_BIG, AppDestination.PADDING_EXTRAS_BIG_HORIZONTAL, false),
                right: locator<AppDestination>().getPadding(
                    context, AppDestination.PADDING_EXTRAS_BIG, AppDestination.PADDING_EXTRAS_BIG_HORIZONTAL, false)),
            child: searchBar ??
                GestureDetector(
                  child: Container(
                    alignment: Alignment.centerRight,
                    height: 35,
                    width: 100,
                    child: Text(
                      AppLocalizations.of(context).btnSkip,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w400,
                        fontSize: 23,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  onTap: () => callbackRight(),
                )),
      ),
    );
  }

  Visibility btnBack(BuildContext context, Color textColor) {
    return Visibility(
      visible: isShowBack,
      child: Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: EdgeInsets.only(
                top: locator<AppDestination>().getPadding(
                    context, AppDestination.PADDING_EXTRAS_BIG, AppDestination.PADDING_EXTRAS_BIG_HORIZONTAL, false),
                left: locator<AppDestination>().getPadding(
                    context, AppDestination.PADDING_EXTRAS_BIG, AppDestination.PADDING_EXTRAS_BIG_HORIZONTAL, false)),
            child: isShowBack
                ? InkWell(
                    onTap: () {
                      if (callback != null) {
                        this.callback();
                      } else {
                        if (isRestoreLang != null && isRestoreLang) {
                          locator<NavigationService>().navigateTo(WaitingScreen.route_name, 3);
                        } else {
                          locator<NavigationService>().navigatePop(context, arguments: isReload);
                        }
                      }
                    },
                    child: Container(
                      width: 150,
                      height: 60,
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.arrow_back_ios,
                            color: textColor,
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Text(
                            AppLocalizations.of(context).btnBack,
                            style: TextStyle(
                                color: textColor, fontSize: AppDestination.TEXT_BIG, fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                  )
                : Container(),
          )),
    );
  }

  Widget createHDFooter(BuildContext context) {
    var textColor = textFooterColor ?? Colors.black;
    var footerText = AppLocalizations.of(context).translate(AppString.MESSAGE_BOTTOM_MAIN).split("_");
    return IgnorePointer(
      ignoring: true,
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.bottomCenter,
              width: SizeConfig.screenWidth,
              decoration: BoxDecoration(
                image: DecorationImage(image: locator<AppImage>().footerHDBank.image, alignment: Alignment.bottomCenter),
              ),
              child: Visibility(
                visible: isShowFooterText,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 70.0),
                  child: (provider is WaitingNotifier)
                      ? Selector<WaitingNotifier, String>(
                          selector: (_, provider) => provider.textWaiting,
                          builder: (context, data, child) {
                            var footerText = AppLocalizations.of(context).translate(AppString.MESSAGE_BOTTOM_MAIN).split("_");
                            return RichText(
                                maxLines: 2,
                                text: TextSpan(
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: footerText.first,
                                        style: TextStyle(
                                            fontSize: AppDestination.TEXT_NORMAL,
                                            wordSpacing: 1.3,
                                            fontWeight: FontWeight.w300,
                                            color: textColor,
                                            decoration: TextDecoration.none)),
                                    TextSpan(
                                        text: " ",
                                        style: TextStyle(
                                            fontSize: AppDestination.TEXT_NORMAL,
                                            wordSpacing: 1.3,
                                            fontWeight: FontWeight.w300,
                                            color: textColor,
                                            decoration: TextDecoration.none)),
                                    TextSpan(
                                        text: footerText.last,
                                        style: TextStyle(
                                            fontSize: AppDestination.TEXT_NORMAL,
                                            wordSpacing: 1.3,
                                            fontWeight: FontWeight.bold,
                                            color: textColor,
                                            decoration: TextDecoration.none)),
                                  ],
                                ));
                          },
                        )
                      : RichText(
                      maxLines: 2,
                      text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                              text: footerText.first,
                              style: TextStyle(
                                  fontSize: AppDestination.TEXT_NORMAL,
                                  wordSpacing: 1.3,
                                  fontWeight: FontWeight.w300,
                                  color: textColor,
                                  decoration: TextDecoration.none)),
                          TextSpan(
                              text: " ",
                              style: TextStyle(
                                  fontSize: AppDestination.TEXT_NORMAL,
                                  wordSpacing: 1.3,
                                  fontWeight: FontWeight.w300,
                                  color: textColor,
                                  decoration: TextDecoration.none)),
                          TextSpan(
                              text: footerText.last,
                              style: TextStyle(
                                  fontSize: AppDestination.TEXT_NORMAL,
                                  wordSpacing: 1.3,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                  decoration: TextDecoration.none)),
                        ],
                      )),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  MySnackBar buildOfflineSnack(bool initState) {
    return MySnackBar(
      message: messSnapBar,
      initState: initState,
      icon: Icon(
        Icons.signal_wifi_off,
        size: 35.0,
        color: AppColor.HINT_TEXT_COLOR,
      ),
      backgroundColor: Colors.black,
      textColor: AppColor.HINT_TEXT_COLOR,
      size: 20,
    );
  }

  MySnackBar buildStorageSnack(bool initState) {
    return MySnackBar(
      message: (provider as WaitingNotifier).appLocalizations.storageLimit,
      initState: initState,
      icon: Icon(
        Icons.cloud_off,
        size: 30.0,
        color: Colors.white,
      ),
      backgroundColor: AppColor.WARNING_COLOR,
      textColor: Colors.white,
      size: 15,
    );
  }

  Widget _BackgroundTouchLess(BuildContext context) {
    var media = MediaQuery.of(context);
    var isPortrait = media.orientation == Orientation.portrait;
    var widthLogo = isPortrait ? SizeConfig.safeBlockHorizontal * 32 : SizeConfig.safeBlockVertical * 32;
    var heightLogo = isPortrait ? SizeConfig.safeBlockHorizontal * 15 : SizeConfig.safeBlockVertical * 15;
    var timeSize = isPortrait ? SizeConfig.safeBlockHorizontal * 6.2 : SizeConfig.safeBlockVertical * 6.2;
    var dateSize = isPortrait ? SizeConfig.safeBlockHorizontal * 2 : SizeConfig.safeBlockVertical * 2;
    return GestureDetector(
      onTap: () {
        (provider as WaitingNotifier).touchScreen();
//        myFabState.currentState.animate();
      },
      child: Stack(
        children: <Widget>[
          buildTouchlessBg(),
          Scaffold(
              backgroundColor: Colors.transparent,
              body: Column(
                children: [
                  Selector<WaitingNotifier, String>(
                    builder: (context, data, child) => buildOfflineSnack(null),
                    selector: (buildContext, provider) => provider.textWaiting,
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                        height: double.infinity,
                        width: double.infinity,
                        child: buildMainContent(
                            heightLogo, widthLogo, Theme.of(context).primaryColor, timeSize, dateSize)),
                  )
                ],
              )),
//          _buildLogout(context, Theme.of(context).primaryColor),
          createHDFooter(context),
        ],
      ),
    );
  }

  Visibility buildLogo(double paddingTop, BuildContext context, double heightLogo, double widthLogo) {
    return Visibility(
      visible: (isAnimation != null && isAnimation) ? true : isShowLogo,
      child: AnimatedContainer(
          duration: Duration(milliseconds: 500),
          padding: EdgeInsets.only(
              top: isShowLogo
                  ? paddingTop
                  : locator<AppDestination>().getPadding(
                      context, AppDestination.PADDING_EXTRAS_BIG, AppDestination.PADDING_EXTRAS_BIG_HORIZONTAL, true),
              right: isShowLogo
                  ? 0
                  : locator<AppDestination>().getPadding(
                      context, AppDestination.PADDING_EXTRAS_BIG, AppDestination.PADDING_EXTRAS_BIG_HORIZONTAL, false)),
          alignment: isShowLogo ? Alignment.center : Alignment.topRight,
          child: FutureBuilder<File>(
            future: Utilities().getLocalFile(Constants.FOLDER_TEMP, Constants.FILE_TYPE_LOGO_SUB_COMPANY, "0", null),
            builder: (context, snapshotSub) {
              if (snapshotSub.hasData && snapshotSub.data.existsSync()) {
                return AnimatedContainer(
                  duration: Duration(milliseconds: 700),
                  height: isShowLogo ? heightLogo : (heightLogo / 2),
                  width: isShowLogo ? widthLogo : (widthLogo / 2),
                  child: Image.file(
                    snapshotSub.data,
                    scale: 2.0,
                  ),
                );
              }
              return FutureBuilder<File>(
                future: Utilities().getLocalFile(Constants.FOLDER_TEMP, Constants.FILE_TYPE_LOGO_COMPANY, "0", null),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data.existsSync()) {
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 700),
                      height: isShowLogo ? heightLogo : (heightLogo / 2),
                      width: isShowLogo ? widthLogo : (widthLogo / 2),
                      child: Image.file(
                        snapshot.data,
                        scale: 2.0,
                      ),
                    );
                  }
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 700),
                    height: isShowLogo ? heightLogo : (heightLogo / 2),
                    width: isShowLogo ? widthLogo : (widthLogo / 2),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: locator<AppImage>().logoHDBank.image,
                      ),
                    ),
                  );
                },
              );
            },
          )),
    );
  }

  Visibility _buildLogout(BuildContext context, Color colorComponent) {
    AppLocalizations localizations = AppLocalizations.of(context);
    TextEditingController controller = TextEditingController();
    GlobalKey<FormState> passwordKey = GlobalKey<FormState>();
    RoundedLoadingButtonController btnController = RoundedLoadingButtonController();
    return Visibility(
      visible: isShowLogout,
      child: Align(
        alignment: Alignment.bottomLeft,
        child: GestureDetector(
          onTap: () {
            var waitingNotifier = (provider as WaitingNotifier);
            if (waitingNotifier.utilities.checkExpiredEvent(waitingNotifier.isEventMode, waitingNotifier.eventDetail) &&
                waitingNotifier.utilities
                    .checkExpiredEventTicket(waitingNotifier.isEventMode, waitingNotifier.eventTicket)) {
              waitingNotifier.utilities.actionAfterExpired(context, () => waitingNotifier.reloadWaiting());
            } else {
              if (waitingNotifier.parent.isConnection) {
                Utilities().showConfirmPassWord(
                    context,
                    localizations.titleConfirmPassword,
                    localizations.password,
                    localizations.password,
                    localizations.confirm,
                    passwordKey,
                    controller,
                    btnController,
                    () => waitingNotifier?.moveToSetting(passwordKey, btnController),
                    () => waitingNotifier.touchScreen());
              } else {
                Utilities().showOneButtonDialog(
                    context,
                    DialogType.INFO,
                    null,
                    AppLocalizations.of(context).translate(AppString.TITLE_NOTIFICATION),
                    AppLocalizations.of(context).noInternetSetting,
                    AppLocalizations.of(context).btnClose, () {
                  waitingNotifier.touchScreen();
                });
              }
            }
          },
          child: Container(
            height: 100,
            width: AppDestination.PADDING_WAITING * 4 + 23,
            alignment: Alignment.center,
            child: Image.asset(
              "assets/images/setting.png",
              cacheHeight: 46 * SizeConfig.devicePixelRatio,
              cacheWidth: 46 * SizeConfig.devicePixelRatio,
              color: colorComponent,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildImageItem(bool isDefault, String index) {
    var image;
    if (isDefault) {
      image = AssetImage("assets/images/waiting$index.png");
      return buildImageContainer(image);
    } else {
      if (isShowLogo) {
        try {
          image = Image.memory(
            File(index).readAsBytesSync(),
            fit: BoxFit.cover,
          ).image;
        } catch (e) {
          image = AssetImage("assets/images/waiting$index.png");
        }
        return buildImageContainer(image);
      }
      image = AssetImage("assets/images/waiting$index.png");
      return buildImageContainer(image);
    }
  }

  Container buildImageContainer(image) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: image,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget buildAutoPlayDemo(BuildContext context, bool isPortrait) {
    List<String> listImage;
    bool isDefault;
    WaitingNotifier provider = (this.provider as WaitingNotifier);
    if (provider.isEventMode && provider.imageEventLocalPath.isNotEmpty) {
      listImage = provider.imageEventLocalPath;
      isDefault = false;
    } else if (provider.imageLocalPath.isNotEmpty) {
      listImage = provider.imageLocalPath;
      isDefault = false;
    } else {
      listImage = ["0"];
      isDefault = true;
    }

    return Container(
      height: double.infinity,
      width: double.infinity,
      child: CarouselSlider(
        reverse: false,
//        scrollDirection: isPortrait ? Axis.vertical : Axis.horizontal,
        scrollDirection: Axis.horizontal,
        viewportFraction: 1.0,
        aspectRatio: MediaQuery.of(context).size.aspectRatio,
        autoPlay: listImage.length > 1,
        enlargeCenterPage: true,
        autoPlayInterval: Duration(milliseconds: Constants.WAITING_AUTO_PLAY),
        autoPlayCurve: Curves.ease,
        items: listImage.asMap().entries.map(
          (entry) {
            return buildImageItem(isDefault, entry.value);
          },
        ).toList(),
      ),
    );
  }

  Widget _Footer(BuildContext context, Color colorComponent) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: locator<AppDestination>()
              .getPadding(context, AppDestination.PADDING_SMALL, AppDestination.PADDING_SMALL_HORIZONTAL, true)),
      child: Container(
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                  right: locator<AppDestination>().getPadding(
                      context, AppDestination.PADDING_SMALL, AppDestination.PADDING_SMALL_HORIZONTAL, true)),
              child: Image.asset(
                'assets/images/logo_unitcorp.png',
                cacheWidth: 46,
                cacheHeight: 46,
                scale: 2,
                color: colorComponent,
              ),
            ),
            Text(
              AppLocalizations.of(context).translate(AppString.MESSAGE_BOTTOM_MAIN),
              style: TextStyle(
                  fontSize: AppDestination.TEXT_NORMAL,
                  fontWeight: FontWeight.w300,
                  color: colorComponent,
                  decoration: TextDecoration.none),
            ),
          ],
        ),
      ),
    );
  }

  Widget _BackgroundWaitingNew(BuildContext context, Color colorComponent) {
    var media = MediaQuery.of(context);
    var isPortrait = media.orientation == Orientation.portrait;
    var widthLogo = isPortrait ? SizeConfig.safeBlockHorizontal * 32 : SizeConfig.safeBlockVertical * 32;
    var heightLogo = isPortrait ? SizeConfig.safeBlockHorizontal * 15 : SizeConfig.safeBlockVertical * 15;
    var timeSize = isPortrait ? SizeConfig.safeBlockHorizontal * 6.2 : SizeConfig.safeBlockVertical * 6.2;
    var dateSize = isPortrait ? SizeConfig.safeBlockHorizontal * 2 : SizeConfig.safeBlockVertical * 2;
    return GestureDetector(
      onTap: () {
        (provider as WaitingNotifier).touchScreen();
//        myFabState.currentState.animate();
      },
      child: WillPopScope(
        onWillPop: () async => false,
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: <Widget>[
                  Scaffold(
                      body: Stack(
                    children: [
                      Column(
                        children: [
                          Selector<WaitingNotifier, String>(
                            builder: (context, data, child) => buildOfflineSnack(null),
                            selector: (buildContext, provider) => provider.textWaiting,
                          ),
                          Expanded(
                            flex: 1,
                            child: LayoutBuilder(
                              builder: (context, snapshot) {
                                var linearGradient = AppColor.linearGradient;
                                var box = BoxDecoration(gradient: linearGradient);
                                if (provider is WaitingNotifier &&
                                    provider != null &&
                                    (provider as WaitingNotifier).image.isNotEmpty) {
                                  return Container(
                                      height: double.infinity,
                                      width: double.infinity,
                                      child: Stack(
                                        children: [
                                          buildAutoPlayDemo(context, isPortrait),
                                          buildMainContent(heightLogo, widthLogo, colorComponent, timeSize, dateSize),
                                        ],
                                      ));
                                } else if (provider is WaitingNotifier &&
                                    provider != null &&
                                    (provider as WaitingNotifier).listColor.isNotEmpty) {
                                  if (((provider as WaitingNotifier)).listColor.length == 1) {
                                    box = BoxDecoration(color: (provider as WaitingNotifier).listColor[0]);
                                  } else {
                                    linearGradient = LinearGradient(
                                      colors: (provider as WaitingNotifier).listColor,
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    );
                                    box = BoxDecoration(gradient: linearGradient);
                                  }
                                }
                                return Container(
                                    height: double.infinity,
                                    width: double.infinity,
                                    decoration: box,
                                    child: buildMainContent(heightLogo, widthLogo, colorComponent, timeSize, dateSize));
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  )),
                  createHDFooter(context)
                ],
              ),
            ),
            Selector<WaitingNotifier, String>(
              builder: (context, data, child) => buildStorageSnack((provider as WaitingNotifier).isWarning),
              selector: (buildContext, provider) => provider.textWaiting,
            ),
          ],
        ),
      ),
    );
  }

  LayoutBuilder buildMainContent(
      double heightLogo, double widthLogo, Color colorComponent, double timeSize, double dateSize) {
    return LayoutBuilder(
      builder: (context, constraint) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraint.maxHeight),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Container(
//                    color: Colors.red,
                    padding: EdgeInsets.only(
//                        top: 15,
//                        bottom: 50,
                        left: 100,
                        right: 100),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            SizedBox(height: 35,),
                            FutureBuilder<File>(
                              future: Utilities()
                                  .getLocalFile(Constants.FOLDER_TEMP, Constants.FILE_TYPE_LOGO_COMPANY, "0", null),
                              builder: (context, snapshot) {
                                if (snapshot.hasData && isShowLogo && snapshot.data.existsSync()) {
                                  return Visibility(
                                    visible: isShowLogo,
                                    child: Container(
                                      height: heightLogo,
                                      width: widthLogo,
                                      alignment: Alignment.centerLeft,
                                      child: Image.memory(
                                        snapshot.data.readAsBytesSync(),
                                        scale: 2.0,
                                      ),
                                    ),
                                  );
                                }
                                return Visibility(
                                  visible: isShowLogo,
                                  child: locator<AppImage>().logoHDBank,
                                );
                              },
                            ),
                          ],
                        ),
                        Consumer<T>(
                          builder: (context, data, child) {
                            return buildClock(context, colorComponent, timeSize, dateSize);
                          },
                        )
                      ],
                    ),
                  ),
                  child
                ]),
          ),
        );
      },
    );
  }

  Widget buildClock(BuildContext context, Color colorComponent, double timeSize, double dateSize) {
    return Container(
//      color: Colors.blue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          InvisibleWidget(
            visible: false,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  '28' + '°C',
                  style: TextStyle(color: Color(0xff464646), fontSize: timeSize / 2, fontWeight: FontWeight.w700),
                ),
                SizedBox(width: 5),
//                Image.asset(
//                  'assets/images/cloud_hdbank.png',
//                  fit: BoxFit.cover,
//                  height: 80,
//                  width: 80,
//                ),
              ],
            ),
          ),
          Selector<WaitingNotifier, String>(
            builder: (context, data, child) {
              return Text(
                DateFormat.yMMMEd((provider as WaitingNotifier).currentLang).format(DateTime.now()),
                style: TextStyle(color: Color(0xff464646), fontSize: dateSize),
              );
            },
            selector: (buildContext, provider) => provider.textWaiting,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            mainAxisSize: MainAxisSize.max,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              Text(
                Utilities().getTimeFormat(context, ((provider as WaitingNotifier).currentLang))[0],
                style: TextStyle(color: Color(0xff464646), fontWeight: FontWeight.w400, fontSize: timeSize),
              ),
              SizedBox(
                width: 5,
              ),
              if (!MediaQuery.of(context).alwaysUse24HourFormat)
                Text(
                  Utilities().getTimeFormat(context, ((provider as WaitingNotifier).currentLang))[1],
                  style: TextStyle(color: Color(0xff464646), fontWeight: FontWeight.w300, fontSize: timeSize / 2),
                )
            ],
          ),
        ],
      ),
    );
  }

  Widget _BackgroundMainScanID(BuildContext context) {
    SizeConfig().init(context);
    return Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
          ),
        ),
        WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: <Widget>[
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints viewportConstraints) {
                    return ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: viewportConstraints.maxHeight,
                        ),
                        child: Container(
                          width: double.infinity,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Expanded(
                                flex: 1,
                                child: Center(child: child),
                              ),
                            ],
                          ),
                        ));
                  },
                ),
//                Positioned(
//                  child: Container(
//                    color: Colors.black,
//                    width: MediaQuery.of(context).size.width,
//                    height: 80,
//                  ),
//                  top: 0,
//                ),
                btnBack(context, Colors.white),
                Padding(
                  padding: EdgeInsets.only(
                    top: locator<AppDestination>().getPadding(context, AppDestination.PADDING_EXTRAS_BIG,
                        AppDestination.PADDING_EXTRAS_BIG_HORIZONTAL, false),
                  ),
                  child: Container(
                      height: 60,
                      alignment: Alignment.center,
                      child: Text(
                        AppLocalizations.of(context).scanTitle,
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      )),
                ),
                createHDFooter(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

//  Widget buildQRHR(BuildContext context) {
//    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
//    var widthQR = isPortrait ? SizeConfig.safeBlockVertical * 15 : SizeConfig.safeBlockHorizontal * 15;
//    return Selector<WaitingNotifier, bool>(
//      builder: (context, data, child) {
//        if (data != true) {
//          return Container();
//        }
//        return Positioned(
//          child: ProcessQR(
//            timeOutInit: (provider as WaitingNotifier).timeReload,
//            sizeChild: widthQR,
//            remainder: (provider as WaitingNotifier)?.remainder,
//            functionCallBack: (provider as WaitingNotifier)?.reloadQR,
//            child: Selector<WaitingNotifier, int>(
//              builder: (context, index, child) {
//                return Container(
//                  decoration: BoxDecoration(
//                      color: Colors.white,
//                      border: Border.all(
//                        color: Colors.transparent,
//                        width: 0,
//                      ),
//                      borderRadius: BorderRadius.all(Radius.circular(12))),
//                  child: QrImage(
//                    size: widthQR,
//                    data:
//                        Utilities().createDataQR((provider as WaitingNotifier).listQR[index].content, FormatQRCode.HR),
//                  ),
//                );
//              },
//              selector: (buildContext, provider) => provider.indexQR,
//            ),
//          ),
//          bottom: widthQR / 3.5,
//          right: AppDestination.PADDING_WAITING_HORIZONTAL,
//        );
//      },
//      selector: (buildContext, provider) => provider.isShowQR,
//    );
//  }

  Future<List<Post>> search(String search) async {
    await Future.delayed(Duration(seconds: 2));
    return List.generate(search.length, (int index) {
      return Post(
        "Title : $search $index",
        "Description :$search $index",
      );
    });
  }
}

class Post {
  final String title;
  final String description;

  Post(this.title, this.description);
}
