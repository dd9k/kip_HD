import 'package:check_in_pro_for_visitor/src/constants/AppDestination.dart';
import 'package:check_in_pro_for_visitor/src/constants/Styles.dart';
import 'package:flutter/material.dart';

import '../constants/AppColors.dart';

final ThemeData blueLightTheme = _blueLightTheme();

ThemeData _blueLightTheme() {
  var baseTextField = InputDecorationTheme(
    fillColor: AppColor.INPUT_FILL_COLOR_BLUE,
    filled: true,
    contentPadding: const EdgeInsets.only(left: 23.0, top: 18, bottom: 18, right: 20),
    enabledBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          const Radius.circular(AppDestination.RADIUS_TEXT_INPUT),
        ),
        borderSide: new BorderSide(color: AppColor.INPUT_BORDER_COLOR_BLUE)),
    border: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          const Radius.circular(AppDestination.RADIUS_TEXT_INPUT),
        ),
        borderSide: new BorderSide(color: AppColor.INPUT_BORDER_COLOR_BLUE)),
    errorBorder: OutlineInputBorder(
      borderRadius: const BorderRadius.all(
        const Radius.circular(AppDestination.RADIUS_TEXT_INPUT),
      ),
      borderSide: new BorderSide(color: AppColor.INPUT_ERROR_COLOR_BLUE),
    ),
    hintStyle: TextStyle(fontSize: 20, color: AppColor.INPUT_HINT_COLOR_BLUE),
    labelStyle: TextStyle(fontSize: 20, color: AppColor.INPUT_LABEL_COLOR_BLUE),
    errorStyle: TextStyle(fontSize: 16),
  );

  return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColor.MAIN_THEME_COLOR_BLUE,
      accentColor: AppColor.ACCENT_THEME_COLOR_BLUE,
      buttonColor: AppColor.BUTTON_COLOR_BLUE,
      cursorColor: AppColor.CURSOR_COLOR_BLUE,
      focusColor: AppColor.FOCUS_COLOR_BLUE,
      hintColor: AppColor.HINT_COLOR_BLUE,
      dialogBackgroundColor: AppColor.DIALOG_BACKGROUND_COLOR_BLUE,
      backgroundColor: AppColor.BACKGROUND_COLOR_BLUE,
      dividerColor: AppColor.DIVIDER_COLOR_BLUE,
      cardColor: AppColor.CARD_COLOR_BLUE,
      bottomAppBarColor: AppColor.BOTTOM_APP_BAR_COLOR_BLUE,
      scaffoldBackgroundColor: AppColor.SCAFFOLD_BACKGROUND_COLOR_BLUE,
      textTheme: TextTheme(bodyText1: TextStyle(color: Colors.black)),
      fontFamily: Styles.OpenSans,
      inputDecorationTheme: baseTextField);
}
