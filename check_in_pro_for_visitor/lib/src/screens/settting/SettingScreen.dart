import 'package:auto_size_text/auto_size_text.dart';
import 'package:check_in_pro_for_visitor/src/constants/AppColors.dart';
import 'package:check_in_pro_for_visitor/src/constants/AppDestination.dart';
import 'package:check_in_pro_for_visitor/src/constants/Constants.dart';
import 'package:check_in_pro_for_visitor/src/constants/SizeConfig.dart';
import 'package:check_in_pro_for_visitor/src/constants/Styles.dart';
import 'package:check_in_pro_for_visitor/src/screens/MainScreen.dart';
import 'package:check_in_pro_for_visitor/src/utilities/AppLocalizations.dart';
import 'package:check_in_pro_for_visitor/src/utilities/Utilities.dart';
import 'package:check_in_pro_for_visitor/src/widgetUtilities/Background.dart';
import 'package:check_in_pro_for_visitor/src/widgetUtilities/ProcessWaiting.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'SettingNotifier.dart';

class SettingScreen extends MainScreen {
  static const String route_name = '/setting';

  static SettingScreen of(BuildContext context) {
    return context.findAncestorWidgetOfExactType();
  }

  bool isReload = false;
  List<String> imageLocalPath = List();

  void updateReload(bool value) {
    isReload = value;
  }

  bool getReload() {
    return isReload;
  }

  @override
  SettingScreenState createState() => SettingScreenState();

  @override
  String getNameScreen() {
    return route_name;
  }
}

class SettingScreenState extends MainScreenState<SettingNotifier> with SingleTickerProviderStateMixin {

  @override
  void onKeyboardChange(bool visible) {
    provider.isOpeningKeyboard = visible;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Background(
      isShowBack: true,
      type: BackgroundType.MAIN,
      isShowLogo: false,
      callback: () {
        if (!provider.isLoadingData) {
          var isEventMode = provider.preferences.getBool(Constants.KEY_EVENT) ?? false;
          var isSync = provider.preferences.getBool(Constants.KEY_SYNC_EVENT) ?? false;
          if (provider.isClickEvent && !isSync && isEventMode) {
            Utilities().showErrorPop(context, appLocalizations.needSyncEvent, null, null);
          } else {
            provider.navigationService.navigatePop(context, arguments: {
              "isReload": (widget as SettingScreen).isReload,
              "imageLocalPath": (widget as SettingScreen).imageLocalPath,
            });
          }
        }
      },
      isOpeningKeyboard: provider.isOpeningKeyboard,
      isShowChatBox: false,
      child: FutureBuilder<void>(
          future: provider.getDefaultValue(),
          builder: (widget, snapshot) {
            if (snapshot.hasData) {
              return buildLayout(context);
            }
            return CircularProgressIndicator();
          }),
    );
  }

  Widget buildLayout(BuildContext context) {
    var percentBox = isPortrait ? 80 : 80;
    var percentBoxHeight = isPortrait ? 60 : 65;
    return SingleChildScrollView(
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 70, bottom: 15),
                child: Text(
                  AppLocalizations.of(context).settingTitle,
                  style: TextStyle(fontSize: 25.0, color: Colors.black),
                ),
              ),
              Container(
                height: SizeConfig.blockSizeVertical * percentBoxHeight,
                width: SizeConfig.blockSizeHorizontal * percentBox,
                child: Material(
                  color: Colors.white,
                  elevation: 10,
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  child: Selector<SettingNotifier, bool>(
                    builder: (context, data, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Flexible(
                            flex: 3,
                            child: MediaQuery.removePadding(
                              context: context,
                              removeTop: true,
                              removeBottom: true,
                              child: buildItemListing(context, provider, SizeConfig.blockSizeVertical * percentBoxHeight,
                                  SizeConfig.blockSizeHorizontal * percentBox),
                            ),
                          ),
                          Flexible(
                              flex: 7,
                              child: Container(
//                          decoration: BoxDecoration(
//                              color: Colors.white,
//                              border: Border(
//                                  right: BorderSide(
//                                    color: Theme.of(context).primaryColor,
//                                    width: 1.0,
//                                  ),
//                                  top: BorderSide(
//                                    color: Theme.of(context).primaryColor,
//                                    width: 1.0,
//                                  ),
//                                  bottom: BorderSide(
//                                    color: Theme.of(context).primaryColor,
//                                    width: 1.0,
//                                  ))),
                                child: Padding(padding: EdgeInsets.all(20), child: provider.getItemSelect().widget),
                              )),
                        ],
                      );
                    },
                    selector: (buildContext, provider) => provider.isSwitch,
                  ),
                ),
              )
            ],
          ),
          buildProcessWaiting(),
        ],
      ),
    );
  }

  Widget buildItemListing(BuildContext context, SettingNotifier provider, double heightBox, double widgetBox) {
    return ListView(
      shrinkWrap: true,
      children: provider.items.map((item) {
        var isFirst = false;
        if (item.settingType == provider.items.first.settingType) {
          isFirst = true;
        }
        if (item.settingType == SettingType.VERSION) {
          return buildVersion(item, provider, heightBox, widgetBox);
        }
        return GestureDetector(
            onTap: () => provider.switchItem(context, item.settingType),
            child: Container(
              decoration: BoxDecoration(
                color: item.isSelect ? Colors.white : AppColor.GRAY,
//                  border: Border(
//                      left: BorderSide(
//                        color: Theme.of(context).primaryColor,
//                        width: 1.0,
//                      ),
//                      top: BorderSide(
//                        color: Theme.of(context).primaryColor,
//                        width: isFirst ? 1.0 : 0.0,
//                      ),)
              ),
              padding: EdgeInsets.only(left: 10, right: 10),
              height: heightBox / provider.items.length,
              width: double.maxFinite,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Icon(
                    item.icon,
                    size: 30,
                    color: item.isSelect ? AppColor.HDBANK_YELLOW_MORE : Colors.black,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AutoSizeText(
                      item.title,
                      maxLines: 2,
                      style: TextStyle(
                        color: item.isSelect ? AppColor.HDBANK_YELLOW_MORE : Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ));
      }).toList(),
    );
  }

  Widget buildVersion(ItemSetting item, SettingNotifier provider, double heightBox, double widgetBox) {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10),
      decoration: BoxDecoration(
        color: Colors.white,
//          border: Border(
//            top: BorderSide(
//              color: Theme.of(context).primaryColor,
//              width: 1.0,
//            ),
//            right: BorderSide(
//              color: Theme.of(context).primaryColor,
//              width: 1.0,
//            ),)
      ),
      height: heightBox / provider.items.length,
      width: double.maxFinite,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Icon(
            item.icon,
            size: 30,
            color: Colors.black,
          ),
          SizedBox(
            width: 5,
          ),
          FutureBuilder<String>(
              future: Utilities().getVersion(),
              builder: (widget, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  return SizedBox(
                    width: ((widgetBox / 10) * 3 - 55),
                    child: Text(
                      "${item.title} ${snapshot.data}",
                      style: TextStyle(
                          fontSize: AppDestination.TEXT_NORMAL,
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.none),
                    ),
                  );
                }
                return Text("");
              }),
        ],
      ),
    );
  }

  Widget buildProcessWaiting() {
    var percentBox = isPortrait ? 80 : 80;
    var percentBoxHeight = isPortrait ? 60 : 80;
    return Selector<SettingNotifier, bool>(
        builder: (cx, data, child) {
          return Visibility(
            visible: data,
            child: Container(
              height: heightScreen * percentBoxHeight,
              width: widthScreen * percentBox,
              color: Colors.transparent,
              alignment: Alignment.center,
              child: ProcessWaiting(
                message: appLocalizations.syncEvent,
                isVisible: data,
              ),
            ),
          );
        },
        selector: (buildContext, provider) => provider.isLoadingData);
  }
}
