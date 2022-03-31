import 'package:check_in_pro_for_visitor/src/constants/Styles.dart';
import 'package:check_in_pro_for_visitor/src/screens/MainScreen.dart';
import 'package:check_in_pro_for_visitor/src/screens/givePermission/GivePermissionNotifier.dart';
import 'package:check_in_pro_for_visitor/src/widgetUtilities/Background.dart';
import 'package:check_in_pro_for_visitor/src/widgetUtilities/RaisedGradientButton.dart';
import 'package:check_in_pro_for_visitor/src/widgetUtilities/introductionScreen/introduction_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:check_in_pro_for_visitor/src/constants/SizeConfig.dart';
import 'package:check_in_pro_for_visitor/src/constants/Constants.dart';

class GivePermissionScreen extends MainScreen {
  static const String route_name = '/givePermission';

  @override
  _GivePermissionScreenState createState() => _GivePermissionScreenState();

  @override
  String getNameScreen() {
    return route_name;
  }
}

class _GivePermissionScreenState
    extends MainScreenState<GivePermissionNotifier> {
  bool enable = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Background(
      isShowBack: false,
      isShowLogout: false,
      type: BackgroundType.MAIN,
      isShowLogo: false,
      isUseProvider: false,
      child: _buildPageContain(),
    );
  }

  Widget _buildPageContain() {
    return FutureBuilder<void>(
      future: provider.getDefaultValue(),
      builder: (widget, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Center(
            child: SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              child: Container(
                height: heightScreen * 80,
                width: widthScreen * 60,
                child: Selector<GivePermissionNotifier, PageController>(
                  builder: (context, data, child) {
                    return Selector<GivePermissionNotifier, List<SliderPermission>>(
                        builder: (context, data, child) {
                    return IntroductionScreen(
                      pageController: provider.controller,
                      globalBackgroundColor: Colors.transparent,
                      onDone: () {},
                      done: const Text(''),
                      skipFlex: 0,
                      nextFlex: 0,
                      next: Text(''),
                      showNextButton: false,
                      showSkipButton: false,
                      dotsDecorator: const DotsDecorator(
                        size: Size(10.0, 10.0),
                        color: Color(0xFFBDBDBD),
                        activeSize: Size(22.0, 10.0),
                        activeColor: Color(0xffF7A30A),
                        activeShape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(25.0)),
                        ),
                      ),
                      pages: List.generate(
                        provider.listPermission.length,
                        (index) => PageViewModel(
                          title: "",
                          bodyWidget: middleSection(data[index]),
                        ),
                      ),
                    );
                        },
                        selector: (cx, provider) => provider.listPermission,
                      );
                  },
                  selector: (buildContext, provider) => provider.controller,
                ),
              ),
            ),
          );
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget middleSection(SliderPermission item) {
    var percentBox = isPortrait ? 40 : 30;
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(child: item.image),
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: Column(
                children: <Widget>[
                  Text(
                    item.title,
                    style: Styles.gpTextBold
                        .copyWith(color: Colors.black, fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    item.subTitle,
                    style: Styles.gpText
                        .copyWith(color: Colors.black, fontSize: 16),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
            Selector<GivePermissionNotifier, bool>(
              builder: (context, isGranted, child) {
                if (!isGranted) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Container(
                      width: SizeConfig.blockSizeHorizontal * percentBox,
                      child: Selector<GivePermissionNotifier, bool>(
                        builder: (widget, data, child) => RaisedGradientButton(
                          height: 41.0,
                          disable: data,
                          btnText: item.titleBtn,
                          onPressed: () => provider.turnOnPermission(item),
                        ),
                        selector: (buildContext, provider) =>
                            provider.isLoading,
                      ),
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    appLocalizations.grantSuccess,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF0B642E),
                      fontWeight: FontWeight.bold,
                      fontSize: Theme.of(context).textTheme.title.fontSize,
                    ),
                  ),
                );
              },
              selector: (context, provider) => item.isGranted,
            ),
            Padding(
              padding: EdgeInsets.only(top: 5),
              child: GestureDetector(
                  child: Text(
                    appLocalizations.btnSkip,
                    style: Styles.gpTextItalic,
                    textAlign: TextAlign.center,
                  ),
                  onTap: () {
                    provider.nextPage(item);
                  }),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
