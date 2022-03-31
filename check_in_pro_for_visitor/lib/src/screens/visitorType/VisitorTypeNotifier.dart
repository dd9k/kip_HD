import 'dart:async';
import 'package:async/async.dart';
import 'package:check_in_pro_for_visitor/src/constants/Constants.dart';
import 'package:check_in_pro_for_visitor/src/model/VisitorCheckIn.dart';
import 'package:check_in_pro_for_visitor/src/model/VisitorType.dart';
import 'package:check_in_pro_for_visitor/src/screens/MainNotifier.dart';
import 'package:check_in_pro_for_visitor/src/screens/inputPhone/InputPhoneScreen.dart';
import 'package:check_in_pro_for_visitor/src/services/ServiceLocator.dart';
import 'package:flutter/cupertino.dart';
import 'package:check_in_pro_for_visitor/src/constants/AppImage.dart';

class VisitorTypeNotifier extends MainNotifier {
  VisitorType visitorType;
  List<VisitorType> listType = List();
  AsyncMemoizer<List<VisitorType>> memCache = AsyncMemoizer();

  Future<void> updateType(BuildContext context, VisitorType visitorType) async {
    this.visitorType = visitorType;
    var visitor = (arguments["visitor"] as VisitorCheckIn)..visitorType = visitorType.settingKey;
    notifyListeners();
    navigationService.navigateTo(InputPhoneScreen.route_name, 1, arguments: {'visitor': visitor});
  }

  Future<List<VisitorType>> getInitValue(BuildContext context) async {
    return memCache.runOnce(() async {
      var langSaved = preferences.getString(Constants.KEY_LANGUAGE) ?? Constants.VN_CODE;
      listType = await db.visitorTypeDAO.getAlls();
      listType.removeWhere((element) => element.settingKey == TypeVisitor.DELIVERY);
      if (!Constants.LIST_LANG.contains(langSaved)) {
        langSaved = Constants.VN_CODE;
      }
      for (VisitorType element in listType) {
        element.description = element.settingValue.getValue(langSaved);
        element.image = getImage(element);
      }
      return listType;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget getImage(VisitorType visitorType) {
    switch (visitorType.settingKey) {
      case TemplateCode.VISITOR:
        return locator<AppImage>().interviewHDBank;
      case TemplateCode.GUEST:
        return locator<AppImage>().visitorImageHDBank;
      case TemplateCode.GROUP_GUEST:
        return locator<AppImage>().visitorImageHDBank;
      default:
        return null;
    }
  }
}
