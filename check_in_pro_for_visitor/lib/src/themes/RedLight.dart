import 'package:check_in_pro_for_visitor/src/constants/AppDestination.dart';
import 'package:check_in_pro_for_visitor/src/constants/Styles.dart';
import 'package:flutter/material.dart';

import '../constants/AppColors.dart';

final ThemeData redLightTheme = _redLightTheme();

ThemeData _redLightTheme() {
  var baseTextField = InputDecorationTheme(
    fillColor: AppColor.INPUT_FILL_COLOR_RED,
    filled: true,
    contentPadding: const EdgeInsets.only(left: 20.0, top: 15, bottom: 15, right: 18),
    enabledBorder: OutlineInputBorder(
      borderRadius: const BorderRadius.all(
        const Radius.circular(AppDestination.RADIUS_TEXT_INPUT),
      ),
      borderSide: new BorderSide(color: AppColor.INPUT_BORDER_COLOR_RED),
    ),
    border: OutlineInputBorder(
      borderRadius: const BorderRadius.all(
        const Radius.circular(AppDestination.RADIUS_TEXT_INPUT),
      ),
      borderSide: new BorderSide(color: AppColor.INPUT_BORDER_COLOR_RED),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: const BorderRadius.all(
        const Radius.circular(AppDestination.RADIUS_TEXT_INPUT),
      ),
      borderSide: new BorderSide(color: AppColor.INPUT_ERROR_COLOR_RED),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: const BorderRadius.all(
        const Radius.circular(AppDestination.RADIUS_TEXT_INPUT),
      ),
      borderSide: new BorderSide(color: Colors.black),
    ),
    hintStyle: TextStyle(fontSize: 16, color: AppColor.INPUT_HINT_COLOR_RED),
    labelStyle: TextStyle(fontSize: 20, color: AppColor.INPUT_LABEL_COLOR_RED),
    errorStyle: TextStyle(fontSize: 14),

  );

  return ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColor.HDBANK_YELLOW_MORE,
    accentColor: AppColor.HDBANK_YELLOW_MORE,
    buttonColor: AppColor.BUTTON_COLOR_RED,
    cursorColor: AppColor.CURSOR_COLOR_RED,
    focusColor: AppColor.HDBANK_YELLOW_MORE,
    hintColor: AppColor.HINT_COLOR_RED,
    dialogBackgroundColor: AppColor.DIALOG_BACKGROUND_COLOR_RED,
    backgroundColor: AppColor.BACKGROUND_COLOR_RED,
    dividerColor: AppColor.DIVIDER_COLOR_RED,
    textTheme: TextTheme(bodyText1: TextStyle(color: Colors.black, fontFamily: Styles.OpenSans)),
    fontFamily: Styles.OpenSans,
    inputDecorationTheme: baseTextField,
  );
}
