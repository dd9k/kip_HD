import 'dart:async';
import 'package:async/async.dart';
import 'package:check_in_pro_for_visitor/src/constants/Constants.dart';
import 'package:check_in_pro_for_visitor/src/model/BaseResponse.dart';
import 'package:check_in_pro_for_visitor/src/model/Errors.dart';
import 'package:check_in_pro_for_visitor/src/model/VisitorCheckIn.dart';
import 'package:check_in_pro_for_visitor/src/screens/MainNotifier.dart';
import 'package:check_in_pro_for_visitor/src/screens/inputPhone/InputPhoneScreen.dart';
import 'package:check_in_pro_for_visitor/src/screens/waiting/WaitingScreen.dart';
import 'package:check_in_pro_for_visitor/src/services/ApiCallBack.dart';
import 'package:check_in_pro_for_visitor/src/services/NavigationService.dart';
import 'package:check_in_pro_for_visitor/src/services/RequestApi.dart';
import 'package:check_in_pro_for_visitor/src/services/ServiceLocator.dart';
import 'package:check_in_pro_for_visitor/src/services/printService/PrinterModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class ThankYouNotifier extends MainNotifier {
  final GlobalKey repaintBoundary = new GlobalKey();
  Timer timerNext;
  PrinterModel printer;
  bool isPrint = false;
  Timer timerDoneAnyWay;
  bool isDoneAnyWay = false;
  AsyncMemoizer<VisitorCheckIn> memCache = AsyncMemoizer();
  VisitorCheckIn visitor;
  String visitorType = Constants.VT_VISITORS;
  String qrGroupGuestUrl = "";
  bool isGroupGuest = false;
  RoundedLoadingButtonController btnController = new RoundedLoadingButtonController();
  Timer timerCheck;

  Future<VisitorCheckIn> getType() async {
    return memCache.runOnce(() async {
      visitor = arguments["visitor"] as VisitorCheckIn;
      visitorType = await utilities.getTypeInDb(context, visitor.visitorType);
      qrGroupGuestUrl = arguments["qrGroupGuestUrl"] as String;
      if (qrGroupGuestUrl?.isNotEmpty == true && visitor.visitorType == TemplateCode.GROUP_GUEST) {
        isGroupGuest = true;
        checkPending();
      } else {
        isGroupGuest = false;
        countDownToDone(context);
      }
      isPrint = await utilities.checkIsPrint(context, visitor.visitorType);
      if (isPrint) {
        printer = await utilities.getPrinter();
      }
      return visitor;
    });
  }

  checkPending() async {
    timerCheck?.cancel();
    timerCheck = Timer.periodic(Duration(minutes: 2), (timer) async {
      ApiCallBack callBack = ApiCallBack((BaseResponse baseResponse) async {

      }, (Errors message) async {
        if (timerCheck?.isActive == true) {
          moveToWaitingScreen();
        }
      });
      await ApiRequest().requestCheckPending(context, qrGroupGuestUrl.split("=").last, callBack);
    });
  }

  Future<void> moveToWaitingScreen() async {
    timerNext?.cancel();
    timerCheck?.cancel();
    isDoneAnyWay = true;
    if (isPrint && !isGroupGuest) {
      btnController?.success();
    }
    locator<NavigationService>().navigateTo(WaitingScreen.route_name, 3);
  }

  Future<void> callPrinter() async {
    timerNext?.cancel();
    timerDoneAnyWay = Timer(Duration(seconds: Constants.TIMEOUT_PRINTER), () {
      if (!isDoneAnyWay) {
        moveToWaitingScreen();
      }
    });
    String response = "";
    try {
      if (printer != null) {
        RenderRepaintBoundary boundary = repaintBoundary.currentContext.findRenderObject();
        await utilities.printJob(printer, boundary);
        if (!isDoneAnyWay) {
          timerDoneAnyWay?.cancel();
          moveToWaitingScreen();
        }
      }
    } on PlatformException catch (e) {
      response = "Failed to Invoke: '${e.message}'.";
      utilities.printLog("$response ");
      if (!isDoneAnyWay) {
        timerDoneAnyWay?.cancel();
        moveToWaitingScreen();
      }
    } catch (e) {
      moveToWaitingScreen();
    }
  }

  void countDownToDone(BuildContext context) {
    timerNext?.cancel();
    timerNext = Timer(Duration(seconds: Constants.DONE_THANK_YOU), () {
      moveToWaitingScreen();
    });
  }

  @override
  void dispose() {
    timerCheck?.cancel();
    timerNext?.cancel();
    super.dispose();
  }
}
