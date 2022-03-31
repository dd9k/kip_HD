import 'package:check_in_pro_for_visitor/src/constants/AppColors.dart';
import 'package:check_in_pro_for_visitor/src/constants/AppDestination.dart';
import 'package:check_in_pro_for_visitor/src/constants/AppString.dart';
import 'package:check_in_pro_for_visitor/src/constants/Constants.dart';
import 'package:check_in_pro_for_visitor/src/constants/Styles.dart';
import 'package:check_in_pro_for_visitor/src/model/VisitorType.dart';
import 'package:check_in_pro_for_visitor/src/screens/MainScreen.dart';
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
import 'InputPhoneNotifier.dart';

class InputPhoneScreen extends MainScreen {
  static const String route_name = '/phoneCheckIn';

  @override
  _InputPhoneScreenState createState() => _InputPhoneScreenState();

  @override
  String getNameScreen() {
    return route_name;
  }
}

class _InputPhoneScreenState extends MainScreenState<InputPhoneNotifier>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  TextEditingController _phoneController = TextEditingController();
  final TextEditingController controllerType = TextEditingController();
  FocusNode phoneFocusNode = FocusNode();

  GlobalKey<FormState> _phoneNumberKey = new GlobalKey();

  AnimationController _animationController;
  bool _animationStopped = false;
  bool isInit = false;

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
    provider = Provider.of<InputPhoneNotifier>(context, listen: false);
    var style = Constants.STYLE_1;
    if (!isInit) {
      isInit = true;
      var phoneNumber = provider.arguments["phoneNumber"] as String ?? "";
      _phoneController.text = phoneNumber;
    }

    if (provider.arguments != null) {
      style = provider.arguments["style"] as String ?? "";
    }
    provider.isDelivery = provider.arguments["isDelivery"] as bool ?? false;
    double heightComponent = 205;
    return FutureBuilder<List<VisitorType>>(
      future: provider.getInitValue(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Selector<InputPhoneNotifier, bool>(
            builder: (context, data, child) => Background(
              isShowBack: true,
              isAnimation: true,
              isShowClock: true,
              isOpeningKeyboard: !provider.isShowLogo,
              isShowLogo: provider.isShowLogo,
              messSnapBar: appLocalizations.messOffline,
              isShowChatBox: false,
              contentChat: AppLocalizations.of(context).translate(AppString.MESSAGE_NO_PHONE),
              type: BackgroundType.MAIN,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
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
                            child: _buildFormUI(heightComponent),
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Selector<InputPhoneNotifier, bool>(
                          selector: (context, provider) => provider.isShowQRCode,
                          builder: (context, isShowQRCode, child) => Visibility(
                            child: firstWidget(heightComponent),
                            visible: !isShowQRCode,
                          ),
                        ),
                        Selector<InputPhoneNotifier, bool>(
                          selector: (context, provider) => provider.isShowQRCode,
                          builder: (context, isShowQRCode, child) => Visibility(
                            child: secondWidget(isPortrait, heightComponent),
                            visible: isShowQRCode,
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
        return Background(
          isShowBack: true,
          isShowLogo: false,
          isShowChatBox: false,
          type: BackgroundType.MAIN,
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  @override
  void onKeyboardChange(bool visible) {
    provider.isShowLogo = !visible;
  }

  Widget firstWidget(double heightComponent) {
    return Expanded(
      flex: 2,
      child: InkWell(
        onTap: () {
          provider.showScanQR();
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
                    aspectRatio: 1,
                    child: Selector<InputPhoneNotifier, bool>(
                      builder: (context, data, child) {
                        return data
                            ? QRView(
                                key: provider.qrKey,
                                onQRViewCreated: _onQRViewCreated,
                                overlay: QrScannerOverlayShape(
                                  borderColor: Colors.lightBlue,
                                  borderRadius: 10,
                                  borderLength: 40,
                                  borderWidth: 10,
                                  cutOutSize: 150,
                                ),
                              )
                            : Container(
                                color: Colors.black,
                                child: Center(
                                  child: Text(
                                    appLocalizations.loadingCamera,
                                    style: TextStyle(
                                        color: AppColor.HINT_TEXT_COLOR, fontSize: AppDestination.TEXT_NORMAL),
                                  ),
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
    provider.controller = controller;
    provider.startStream();
  }

  void animateScanAnimation(bool reverse) {
    if (reverse) {
      _animationController.reverse(from: 1.0);
    } else {
      _animationController.forward(from: 0.0);
    }
  }

  Widget _buildFormUI(double heightComponent) {
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
            _buildBtnNext()
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneNumberTxtField() {
    return Selector<InputPhoneNotifier, String>(
      builder: (context, data, child) {
        return Selector<InputPhoneNotifier, bool>(
            builder: (context, isShowClear, child) {
              _phoneController.text = data;
              _phoneController.selection = TextSelection.fromPosition(TextPosition(offset: _phoneController.text.length));
              return TextFieldCommon(
                  controller: _phoneController,
                  validator: (provider.isHaveType && provider.visitorBackup.visitorType != TemplateCode.VISITOR)
                      ? Validator(context).validatePhoneNumber
                      : Validator(context).validateQROrPhoneNumber,
                  focusNode: phoneFocusNode,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: InputDecoration(
                    hintStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
                    contentPadding: EdgeInsets.symmetric(vertical: 29, horizontal: 25),
                    suffixIcon: isShowClear
                        ? GestureDetector(
                      onTap: () {
                        _phoneController.clear();
                        provider.qrCodeStr = '';
                      },
                      child: Container(
                        height: 56,
                        width: 56,
                        child: Icon(
                          Icons.cancel,
                          size: 24,
                          color: AppColor.HINT_TEXT_COLOR,
                        ),
                      ),
                    )
                        : null,
                    hintText: (provider.isHaveType && provider.visitorBackup.visitorType != TemplateCode.VISITOR)
                        ? appLocalizations.phoneNumber
                        : appLocalizations.qrOrPhoneNumber,
                  ),
                  onChanged: (_) => Utilities().moveToWaiting(),
                  onEditingComplete: () {
                    Utilities().hideKeyBoard(context);
                    if (_phoneNumberKey.currentState.validate()) {
                      Utilities().tryActionLoadingBtn(provider?.btnController, BtnLoadingAction.START);
                    } else {
                      Utilities().tryActionLoadingBtn(provider?.btnController, BtnLoadingAction.STOP);
                    }
                  },
                  style: Styles.formFieldText.copyWith(fontWeight: FontWeight.bold, fontSize: 28));
            },
            selector: (buildContext, provider) => provider.isShowClear);
      },
      selector: (buildContext, provider) => provider.qrCodeStr,
    );
  }

  Widget _buildBtnNext() {
    return Container(
      height: 75,
      child: RaisedGradientButton(
        isLoading: true,
        btnController: provider.btnController,
        disable: false,
        textSize: 30,
        btnText: AppLocalizations.of(context).translate(AppString.BTN_CONTINUE),
        onPressed: () {
          Utilities().hideKeyBoard(context);
          Utilities().moveToWaiting();
          provider.qrCodeStr = _phoneController.text;
          if (_phoneNumberKey.currentState.validate()) {
            if (_phoneController.text.length <= 8) {
              provider.validateInput(null, _phoneController.text);
            } else {
              provider.validateInput(_phoneController.text, null);
            }
          } else {
            Utilities().tryActionLoadingBtn(provider?.btnController, BtnLoadingAction.STOP);
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
    phoneFocusNode.dispose();
    _phoneController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
