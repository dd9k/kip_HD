import 'package:check_in_pro_for_visitor/src/constants/AppColors.dart';
import 'package:check_in_pro_for_visitor/src/constants/AppDestination.dart';
import 'package:check_in_pro_for_visitor/src/constants/AppString.dart';
import 'package:check_in_pro_for_visitor/src/constants/Constants.dart';
import 'package:check_in_pro_for_visitor/src/constants/SizeConfig.dart';
import 'package:check_in_pro_for_visitor/src/constants/Styles.dart';
import 'package:check_in_pro_for_visitor/src/model/VisitorCheckIn.dart';
import 'package:check_in_pro_for_visitor/src/screens/MainScreen.dart';
import 'package:check_in_pro_for_visitor/src/screens/Thankyou/ThankYouNotifier.dart';
import 'package:check_in_pro_for_visitor/src/services/printService/PrinterModel.dart';
import 'package:check_in_pro_for_visitor/src/utilities/AppLocalizations.dart';
import 'package:check_in_pro_for_visitor/src/widgetUtilities/Background.dart';
import 'package:check_in_pro_for_visitor/src/widgetUtilities/InvisibleWidget.dart';
import 'package:check_in_pro_for_visitor/src/widgetUtilities/TemplatePrint.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:check_in_pro_for_visitor/src/constants/AppImage.dart';
import 'package:check_in_pro_for_visitor/src/widgetUtilities/RaisedGradientButton.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ThankYouScreen extends MainScreen {
  static const String route_name = '/thankyou';

  @override
  ThankYouState createState() => ThankYouState();

  @override
  String getNameScreen() {
    return route_name;
  }
}

class ThankYouState extends MainScreenState<ThankYouNotifier> {
  bool isInit = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isInit) {
      isInit = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<VisitorCheckIn>(
      future: provider.getType(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Stack(
            children: <Widget>[
              Scaffold(
                backgroundColor: Colors.transparent,
                body: RepaintBoundary(
                    key: provider.repaintBoundary,
                    child: Container(
                      height: AppDestination.CARD_HEIGHT,
                      width: AppDestination.CARD_WIGHT,
                      color: Colors.white,
                      child: new Center(child: cardTemplate()),
                    )),
              ),
              Background(
                timeOutInit: Constants.DONE_THANK_YOU,
                isShowBack: false,
                isShowClock: true,
                type: BackgroundType.MAIN,
                initState: !provider.parent.isOnlineMode,
                messSnapBar: appLocalizations.messOffMode,
                isShowLogo: true,
                isShowChatBox: true,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '${AppLocalizations.of(context).translate(AppString.TITLE_THANK_YOU)}',
                                style:
                                TextStyle(fontSize: 40, height: 1.25, fontWeight: FontWeight.bold, fontFamily: Styles.OpenSans),
                              ),
                              TextSpan(text: '    '),
                              TextSpan(
                                text: '${provider.visitor?.fullName ?? ""}',
                                style: TextStyle(
                                    fontSize: 40, height: 1.25, color: AppColor.RED_TEXT_COLOR, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20,),
                      Text(
                        provider.isGroupGuest ? appLocalizations.messageThankYouGroup : AppLocalizations.of(context).translate(AppString.MESSAGE_THANK_YOU),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20, height: 1.3),
                      ),
                      if (!provider.isGroupGuest) Stack(
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width / 2.5,
                            height: MediaQuery.of(context).size.height / 3,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: appImage.cardPrintingHDBank.image,
                              ),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 2.5,
                            height: MediaQuery.of(context).size.height / 2.5,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: appImage.logoCardPrintingHDBank.image,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (provider.isGroupGuest) Padding(
                        padding: const EdgeInsets.only(top: 15.0, bottom: 20),
                        child: QrImage(
                          padding: EdgeInsets.zero,
                          size: SizeConfig.safeBlockVertical * 30,
                          data: provider.qrGroupGuestUrl,
                        ),
                      ),
                      InvisibleWidget(
                        visible: provider.isPrint || provider.isGroupGuest,
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width / 2.4,
                              right: MediaQuery.of(context).size.width / 2.4,
                              bottom: 30),
                          child: RaisedGradientButton(
                            disable: false,
                            isLoading: true,
                            btnController: provider.btnController,
                            btnText: provider.isGroupGuest ? appLocalizations.completed : appLocalizations.printBtn,
                            onPressed: () {
                              if (provider.isGroupGuest) {
                                provider.moveToWaitingScreen();
                              } else {
                                provider.callPrinter();
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                contentChat: AppLocalizations.of(context).translate(AppString.MESSAGE_THANK_YOU_CHATBOX),
              ),
            ],
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

  Widget cardTemplate() {
    var visitor = provider.arguments["visitor"] as VisitorCheckIn;
    var inviteCode = provider.arguments["inviteCode"] as String;
    var badgeIndex = provider.preferences.getString(Constants.KEY_BADGE_PRINTER);
    return TemplatePrint(
      visitorName: visitor.fullName ?? "",
      phoneNumber: visitor.phoneNumber ?? "",
      fromCompany: visitor.fromCompany ?? "",
      toCompany: visitor.toCompany ?? "",
      visitorType: provider.visitorType,
      indexTemplate: badgeIndex,
      idCard: visitor.idCard ?? "",
      printerModel: provider.printer,
      inviteCode: inviteCode,
      isBuilding: false,
      floor: visitor.floor,
    );
  }
}
