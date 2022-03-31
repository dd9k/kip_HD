import 'package:check_in_pro_for_visitor/src/constants/AppColors.dart';
import 'package:check_in_pro_for_visitor/src/constants/AppDestination.dart';
import 'package:check_in_pro_for_visitor/src/constants/AppString.dart';
import 'package:check_in_pro_for_visitor/src/constants/Constants.dart';
import 'package:check_in_pro_for_visitor/src/constants/SizeConfig.dart';
import 'package:check_in_pro_for_visitor/src/constants/Styles.dart';
import 'package:check_in_pro_for_visitor/src/model/VisitorCheckIn.dart';
import 'package:check_in_pro_for_visitor/src/screens/MainScreen.dart';
import 'package:check_in_pro_for_visitor/src/screens/feedBack/FeedBackNotifier.dart';
import 'package:check_in_pro_for_visitor/src/utilities/Utilities.dart';
import 'package:check_in_pro_for_visitor/src/widgetUtilities/Background.dart';
import 'package:check_in_pro_for_visitor/src/widgetUtilities/TextFieldComon.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:check_in_pro_for_visitor/src/widgetUtilities/RaisedGradientButton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:check_in_pro_for_visitor/src/constants/AppImage.dart';

class FeedBackScreen extends MainScreen {
  static const String route_name = '/feedBack';

  @override
  _FeedBackScreenState createState() => _FeedBackScreenState();

  @override
  String getNameScreen() {
    return route_name;
  }
}

class _FeedBackScreenState extends MainScreenState<FeedBackNotifier> {
  TextEditingController feedBackController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    provider.countDownToDone(context, feedBackController);
    provider.getValue();
    var visitorCheckIn = provider.arguments["visitorCheckIn"] as VisitorCheckIn;
    return Selector<FeedBackNotifier, bool>(
      builder: (context, data, child) {
        return Background(
          timeOutInit: Constants.TIMEOUT_CHECK_OUT,
          isShowBack: false,
          isAnimation: true,
          isShowClock: true,
          isFooterInContent: true,
          textFooterColor: Colors.white,
          isOpeningKeyboard: !provider.isShowLogo,
          isShowLogo: provider.isShowLogo,
          initState: !provider.parent.isOnlineMode,
          messSnapBar: appLocalizations.messOffMode,
          isShowChatBox: Utilities().isShowForChatBox(context, provider.isShowLogo),
          contentChat: appLocalizations.translate(AppString.MESSAGE_FEEDBACK_CHATBOX),
          type: BackgroundType.MAIN,
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                WidgetsBinding.instance.window.viewInsets.bottom > 0.0
                    ? SizedBox(
                        height: 0,
                      )
                    : SizedBox(
                        height: heightScreen * 10,
                      ),
                Text(
                  "${appLocalizations.translate(AppString.TITLE_THANK_YOU)} ${visitorCheckIn?.fullName ?? ""}!",
                  style: Styles.fbTitle.copyWith(fontFamily: Styles.OpenSans),
                  textAlign: TextAlign.center,
                ),
                Text(
                  appLocalizations.translate(AppString.SUB_TITLE_FEEDBACK),
                  style: Styles.fbSubTitle.copyWith(fontWeight: FontWeight.bold, fontFamily: Styles.OpenSans),
                  textAlign: TextAlign.center,
                ),
                buildStarRating(),
                Expanded(
                  child: Container(
                      padding:WidgetsBinding.instance.window.viewInsets.bottom > 0.0 ?EdgeInsets.only(top: 30) : EdgeInsets.only(top: 60),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: appImage.bgFeedBackHDBank.image,
                          fit: BoxFit.fill,
                        ),
                      ),
                      child: Column(
                        children: <Widget>[
                          buildInputFeedBack(provider),
                          buildBtnSave(context, provider),
                        ],
                      )),
                ),
              ],
            ),
          ),
        );
      },
      selector: (buildContext, provider) => provider.isCountDownAgain,
    );
  }

  @override
  void onKeyboardChange(bool visible) {
    provider.isShowLogo = !visible;
  }

  Widget buildStarRating() {
    return Padding(
      padding: WidgetsBinding.instance.window.viewInsets.bottom > 0.0?EdgeInsets.all(5.0):  EdgeInsets.all(15.0),
      child: Selector<FeedBackNotifier, double>(
        builder: (context, data, child) {
          return RatingBar(
            initialRating: 0,
            direction: Axis.horizontal,
            itemCount: 5,
            itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
            unratedColor: Color(0XFFB6BEC8),
            itemBuilder: (context, index) {
              if (provider.configKiosk.ratingType == TypeRating.TYPE2) {
                return Icon(
                  Icons.star,
                  color: Colors.amber,
                );
              }
              return faceRating(index);
            },
            onRatingUpdate: (rating) {
              provider.updateRatingChange(rating);
              provider.countDownToDone(this.context, feedBackController);
            },
          );
        },
        selector: (buildContext, provider) => provider.starRating,
      ),
    );
  }

  StatelessWidget faceRating(int index) {
    switch (index) {
      case 0:
        return Icon(
          Icons.sentiment_very_dissatisfied,
          color: Colors.red,
        );
      case 1:
        return Icon(
          Icons.sentiment_dissatisfied,
          color: Colors.redAccent,
        );
      case 2:
        return Icon(
          Icons.sentiment_neutral,
          color: Colors.amber,
        );
      case 3:
        return Icon(
          Icons.sentiment_satisfied,
          color: Colors.lightGreen,
        );
      case 4:
        return Icon(
          Icons.sentiment_very_satisfied,
          color: Colors.green,
        );
      default:
        return Container();
    }
  }

  Widget buildInputFeedBack(FeedBackNotifier notifier) {
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    var percentBox = isPortrait ? 70 : 50;
    return Padding(
      padding: EdgeInsets.only(
        left: (SizeConfig.blockSizeHorizontal * percentBox) / 2,
        right: (SizeConfig.blockSizeHorizontal * percentBox) / 2,
      ),
      //width: SizeConfig.blockSizeHorizontal * percentBox,
      child: TextFieldCommon(
        onChanged: (text) {
          notifier.countDownToDone(this.context, feedBackController);
        },
        maxLines: WidgetsBinding.instance.window.viewInsets.bottom > 0.0 ? 3 : 4,
        controller: feedBackController,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.done,
        onEditingComplete: () {
          Utilities().hideKeyBoard(context);
          notifier.checkOut(context, feedBackController.text);
        },
        inputFormatters: <TextInputFormatter>[
          LengthLimitingTextInputFormatter(200),
        ],
        decoration: InputDecoration(
          hintText: appLocalizations.translate(AppString.HINT_FEED_BACK),
          enabledBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(
                const Radius.circular(AppDestination.RADIUS_TEXT_INPUT_BIG),
              ),
              borderSide: new BorderSide(color: Theme.of(context).primaryColor)),
          border: OutlineInputBorder(
              borderRadius: const BorderRadius.all(
                const Radius.circular(AppDestination.RADIUS_TEXT_INPUT_BIG),
              ),
              borderSide: new BorderSide(color: Theme.of(context).primaryColor)),
          errorBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              const Radius.circular(AppDestination.RADIUS_TEXT_INPUT_BIG),
            ),
            borderSide: new BorderSide(color: AppColor.RED_COLOR),
          ),
        ),
      ),
    );
  }

  Widget buildBtnSave(BuildContext context, FeedBackNotifier notifier) {
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    var percentBox = isPortrait ? 70 : 50;
    var provider = Provider.of<FeedBackNotifier>(context, listen: false);
    return Padding(
      padding: EdgeInsets.only(
        left: (SizeConfig.blockSizeHorizontal * percentBox) / 2,
        right: (SizeConfig.blockSizeHorizontal * percentBox) / 2,
        top: 20,
      ),
      //width: SizeConfig.blockSizeHorizontal * percentBox,
      child: Selector<FeedBackNotifier, bool>(
        builder: (context, data, child) {
          return RaisedGradientButton(
            isLoading: true,
            btnController: provider.btnController,
            disable: data,
            btnText: appLocalizations.translate(AppString.BTN_THANK_YOU),
            onPressed: () {
              Utilities().hideKeyBoard(context);
              notifier.checkOut(this.context, feedBackController.text);
            },
          );
        },
        selector: (buildContext, provider) => provider.isLoading,
      ),
    );
  }
}
