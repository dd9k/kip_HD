import 'dart:io';

import 'package:check_in_pro_for_visitor/src/constants/AppColors.dart';
import 'package:check_in_pro_for_visitor/src/constants/AppString.dart';
import 'package:check_in_pro_for_visitor/src/constants/Constants.dart';
import 'package:check_in_pro_for_visitor/src/constants/SizeConfig.dart';
import 'package:check_in_pro_for_visitor/src/constants/Styles.dart';
import 'package:check_in_pro_for_visitor/src/screens/MainScreen.dart';
import 'package:check_in_pro_for_visitor/src/screens/checkOut/CheckOutNotifier.dart';
import 'package:check_in_pro_for_visitor/src/utilities/AppLocalizations.dart';
import 'package:check_in_pro_for_visitor/src/utilities/Utilities.dart';
import 'package:check_in_pro_for_visitor/src/utilities/Validator.dart';
import 'package:check_in_pro_for_visitor/src/widgetUtilities/Background.dart';
import 'package:check_in_pro_for_visitor/src/widgetUtilities/ImageScannerAnimation.dart';
import 'package:check_in_pro_for_visitor/src/widgetUtilities/RaisedGradientButton.dart';
import 'package:check_in_pro_for_visitor/src/widgetUtilities/TextFieldComon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class CheckOutScreen extends MainScreen {
  static const String route_name = '/checkOut';

  @override
  _CheckOutScreenState createState() => _CheckOutScreenState();

  @override
  String getNameScreen() {
    return route_name;
  }
}

class _CheckOutScreenState extends MainScreenState<CheckOutNotifier>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  TextEditingController _phoneController = TextEditingController();

  FocusNode phoneFocusNode = FocusNode();

  GlobalKey<FormState> _phoneNumberKey = GlobalKey();

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  AnimationController _animationController;
  bool _animationStopped = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    phoneFocusNode.addListener(() {
      provider.showClear(phoneFocusNode.hasFocus);
    });
    if (_animationController == null) {
      _animationController =
          new AnimationController(duration: new Duration(seconds: Constants.TIME_ANIMATION_SCAN), vsync: this);
      _animationController.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          animateScanAnimation(true);
        } else if (status == AnimationStatus.dismissed) {
          animateScanAnimation(false);
        }
      });
    }
    _phoneController.addListener(() {
      provider.qrCodeStr = _phoneController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    animateScanAnimation(false);
    var percentBox = isPortrait ? 60 : 60;
    double heightComponent = 205;
    return Selector<CheckOutNotifier, bool>(
      builder: (context, data, child) => Background(
        isShowBack: true,
        isAnimation: true,
        isShowClock: true,
        messSnapBar: appLocalizations.messOffline,
        isShowLogo: provider.isShowLogo,
        isShowChatBox: provider.isShowLogo,
        isOpeningKeyboard: !provider.isShowLogo,
        contentChat: AppLocalizations.of(context).messageQRCodeOrPhoneNumber,
        type: BackgroundType.MAIN,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              flex: 11,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(flex: 1, child: Container()),
                  Expanded(
                    flex: 7,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      child: _buildFormUI(provider.isLoading, heightComponent),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Selector<CheckOutNotifier, bool>(
                    selector: (context, provider) => provider.isShowQRCode,
                    builder: (context, data, child) => Visibility(
                      child: firstWidget(heightComponent),
                      visible: !data,
                    ),
                  ),
                  Selector<CheckOutNotifier, bool>(
                    selector: (context, provider) => provider.isShowQRCode,
                    builder: (context, data, child) => Visibility(
                      child: secondWidget(isPortrait, heightComponent),
                      visible: data,
                    ),
                  ),
                  Expanded(flex: 1, child: Container()),
                ],
              ),
            ),
            SizedBox(
              height: 100,
            )
          ],
        ),
      ),
      selector: (context, provider) => provider.isLoading,
    );
  }

  Widget firstWidget(double heightComponent) {
    var _provider = Provider.of<CheckOutNotifier>(context, listen: false);
    return Expanded(
      flex: 2,
      child: InkWell(
        onTap: () {
          _provider.showScanQR(context);
        },
        child: Container(
          height: heightComponent,
          child: Column(
            children: <Widget>[
              Container(
                height: heightComponent,
                width: heightComponent,
                child: Image.asset(
                  'assets/images/qr_hdbank.png',
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget secondWidget(bool isPortrait, double heightComponent) {
    return Expanded(
      flex: 2,
      child: Container(
        height: heightComponent,
        child: Column(
          children: <Widget>[
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: heightComponent,
                  width: heightComponent,
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: Selector<CheckOutNotifier, bool>(
                      builder: (context, visible, child) {
                        return QRView(
                          key: qrKey,
                          onQRViewCreated: _onQRViewCreated,
                          overlay: QrScannerOverlayShape(
                            borderColor: Colors.lightBlue,
                            borderRadius: 10,
                            borderLength: 40,
                            borderWidth: 10,
                            cutOutSize: 150,
                          ),
                        );
                      },
                      selector: (buildContext, provider) => provider.isLoadCamera,
                    ),
                  ),
                ),
                ImageScannerAnimation(
                  _animationStopped,
                  334,
                  animation: _animationController,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    var provider = Provider.of<CheckOutNotifier>(context, listen: false);
    provider.controller = controller;
    provider.startStream(context);
  }

  void animateScanAnimation(bool reverse) {
    if (reverse) {
      _animationController.reverse(from: 1.0);
    } else {
      _animationController.forward(from: 0.0);
    }
  }

  @override
  void onKeyboardChange(bool visible) {
    provider.isShowLogo = !visible;
  }

  Widget _buildFormUI(bool disable, double heightComponent) {
    return Form(
      key: _phoneNumberKey,
      child: Container(
        height: heightComponent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildPhoneNumberTxtField(),
            Expanded(
              flex: 1,
              child: SizedBox(),
            ),
            _buildBtnCheckOut(disable)
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneNumberTxtField() {
    return Selector<CheckOutNotifier, String>(
      builder: (context, data, child) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                child: Selector<CheckOutNotifier, String>(
                    builder: (context, error, child) {
                      return Selector<CheckOutNotifier, bool>(
                          builder: (context, isShowClear, child) {
                            _phoneController.text = data;
                            _phoneController.selection =
                                TextSelection.fromPosition(TextPosition(offset: _phoneController.text.length));
                            return TextFieldCommon(
                                controller: _phoneController,
                                validator: Validator(context).validateQROrPhoneNumber,
                                focusNode: phoneFocusNode,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                decoration: InputDecoration(
                                    hintStyle: Styles.formFieldText.copyWith(fontWeight: FontWeight.bold, fontSize: 28),
                                    contentPadding: EdgeInsets.symmetric(vertical: 29, horizontal: 25),
                                    suffixIcon: isShowClear
                                        ? GestureDetector(
                                            onTap: () {
                                              _phoneController..text = "";
                                              provider.qrCodeStr = '';
                                            },
                                            child: Container(
                                              height: 56,
                                              width: 56,
                                              child: Icon(
                                                Icons.cancel,
                                                size: 34,
                                                color: AppColor.HINT_TEXT_COLOR,
                                              ),
                                            ),
                                          )
                                        : null,
                                    hintText: AppLocalizations.of(context).qrOrPhoneNumber,
                                    errorText: error),
                                onChanged: (_) => Utilities().moveToWaiting(),
                                onTap: () => Utilities().moveToWaiting(),
                                onEditingComplete: () {
                                  Utilities().hideKeyBoard(context);
                                  if (_phoneNumberKey.currentState.validate()) {
                                    provider.btnController.start();
                                  } else {
                                    provider.btnController.stop();
                                  }
                                },
                                style: Styles.formFieldText.copyWith(fontWeight: FontWeight.bold, fontSize: 28));
                          },
                          selector: (buildContext, provider) => provider.isShowClear);
                    },
                    selector: (buildContext, provider) => provider.errorText),
              )
            ],
          )
        ],
      ),
      selector: (context, provider) => provider.qrCodeStr,
    );
  }

  Widget _buildBtnCheckOut(bool disable) {
    return Container(
      height: 75,
      child: RaisedGradientButton(
        isLoading: true,
        btnController: provider.btnController,
        disable: disable,
        textSize: 30,
        btnText: AppLocalizations.of(context).translate(AppString.BTN_CHECK_OUT),
        onPressed: () {
          Utilities().hideKeyBoard(context);
          _phoneController.text = provider.qrCodeStr;
          if (_phoneNumberKey.currentState.validate()) {
            if (_phoneController.text.length <= 8) {
              provider.searchVisitor(null, _phoneController.text);
            } else {
              provider.searchVisitor(_phoneController.text, null);
            }
          } else {
            provider.btnController.stop();
            provider.isScanned = false;
          }
        },
      ),
    );
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        {
          break;
        }
      case AppLifecycleState.inactive:
        {
          break;
        }
      case AppLifecycleState.paused:
        {
          break;
        }
      case AppLifecycleState.detached:
        {
          break;
        }
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _animationController.dispose();
    phoneFocusNode.dispose();
    super.dispose();
  }
}
