import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:check_in_pro_for_visitor/src/constants/AppColors.dart';
import 'package:check_in_pro_for_visitor/src/constants/Constants.dart';
import 'package:check_in_pro_for_visitor/src/constants/SizeConfig.dart';
import 'package:check_in_pro_for_visitor/src/model/VisitorType.dart';
import 'package:check_in_pro_for_visitor/src/screens/MainScreen.dart';
import 'package:check_in_pro_for_visitor/src/utilities/AppLocalizations.dart';
import 'package:check_in_pro_for_visitor/src/widgetUtilities/Background.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'VisitorTypeNotifier.dart';
import 'package:check_in_pro_for_visitor/src/constants/AppImage.dart';

class VisitorTypeScreen extends MainScreen {
  static const String route_name = '/visitorType';

  @override
  _VisitorTypeScreenState createState() => _VisitorTypeScreenState();

  @override
  String getNameScreen() {
    return route_name;
  }
}

class _VisitorTypeScreenState extends MainScreenState<VisitorTypeNotifier>
    with TickerProviderStateMixin {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<List<VisitorType>>(
      future: provider.getInitValue(context),
      builder: (context, snapshot) {
        if (provider.listType != null) {
          return Background(
            isShowBack: true,
            isAnimation: true,
            isShowLogo: true,
            messSnapBar: appLocalizations.messOffline,
            isShowChatBox: false,
            type: BackgroundType.MAIN,
            child: Container(
                width: SizeConfig.screenWidth,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Selector<VisitorTypeNotifier, VisitorType>(
                      builder: (context, data, child) {
                        var isPortrait = MediaQuery.of(context).orientation ==
                            Orientation.portrait;
                        var textSize = isPortrait
                            ? SizeConfig.safeBlockHorizontal * 2.5
                            : SizeConfig.safeBlockVertical * 2.5;
                        return Text(
                          AppLocalizations.of(context).titleVisitorType,
                          style: TextStyle(
                              fontSize: textSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        );
                      },
                      selector: (context, provider) => provider.visitorType,
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    WrapSuper(
                      spacing: 60.0,
                      lineSpacing: 30.0,
                      alignment: WrapSuperAlignment.center,
                      children: provider.listType
                          .map((item) => visitorTypeItem(context, item))
                          .toList()
                          .cast<Widget>(),
                    ),
                    SizedBox(
                      height: 200,
                    )
                  ],
                )),
          );
        }
        return Background(
          isShowBack: true,
          isShowLogo: false,
          isShowChatBox: false,
          type: BackgroundType.MAIN,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Widget visitorTypeItem(BuildContext context, VisitorType item) {
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    var textInBox = isPortrait
        ? SizeConfig.safeBlockHorizontal * 3
        : SizeConfig.safeBlockVertical * 3;
    var sizeBox = isPortrait
        ? SizeConfig.safeBlockHorizontal * 35
        : SizeConfig.safeBlockVertical * 35;
    var container = GestureDetector(
      onTap: () => provider.updateType(context, item),
      child: Selector<VisitorTypeNotifier, VisitorType>(
        builder: (context, data, child) {
          var isSelected = provider.visitorType == item;
          return Container(
            width: sizeBox,
            height: sizeBox,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                item.image,
                Text(
                  item.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: textInBox,
                    color: isSelected
                        ? AppColor.RED_TEXT_COLOR
                        : Color(0xff454F5B),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            decoration: BoxDecoration(
                color: isSelected ? AppColor.HDBANK_YELLOW : Colors.white,
                border: Border.all(color: Colors.white, width: 1),
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
          );
        },
        selector: (context, provider) => provider.visitorType,
      ),
    );
    return container;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
