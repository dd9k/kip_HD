import 'package:check_in_pro_for_visitor/src/model/TakePhotoStep.dart';
import 'package:flutter/material.dart';

import 'package:check_in_pro_for_visitor/src/widgetUtilities/TemplatePrint.dart';
import 'package:check_in_pro_for_visitor/src/constants/AppDestination.dart';

class DemoPopup extends StatefulWidget {
  @override
  _DemoPopupState createState() => _DemoPopupState();
}
class _DemoPopupState extends State<DemoPopup> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          height: AppDestination.CARD_HEIGHT,
          width: AppDestination.CARD_WIGHT,
          color: Colors.white,
          child: TemplatePrint(
            visitorName: "Nguyễn huỳnh giao",
            phoneNumber: "12345678",
            fromCompany:  "Unit",
            toCompany: "UNIT",
            visitorType: 'Khách mời',
            idCard:"12345",
            indexTemplate: 'BADGE3',
            inviteCode: 'inviteCode',
            badgeTemplate: null,
            isBuilding: true,
            floor: 'floor',
          ),
        ),
      ),
    );
  }
}
