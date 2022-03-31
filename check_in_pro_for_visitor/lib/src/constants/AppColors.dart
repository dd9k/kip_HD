import 'package:flutter/material.dart';
import 'dart:math' as math;

class AppColor {
  static const BASE_LOADING = Color(0xFFC7CAD1);
  static const HIGHLIGHT_LOADING = Color(0xFFAFB2BB);
  static const BACKGROUND_LOADING = Color(0xFFEDEEF0);
  static const MAIN_CHECK_OUT = Color(0xFFE7970D);
  static const WARNING_COLOR = Color(0xFFffc107);
  static const RED_COLOR = Color(0xFFC32B2B);
  static const RED_SUB_COLOR = Color(0xFFFAE6E7);
  static const HINT_TEXT_COLOR = Color(0xFFB3B1B1);
  static const LINE_COLOR = Color(0xFFD8D8D8);
  static const GREEN = Color(0xFF52C41A);
  static const GRAY_BOLD = Color(0xFFD8D8D8);
  static const GRAY = Color(0xFFEEEEEE);
  static const BLACK_TEXT_COLOR = Color(0xFF000000);
  static const BUTTON_TEXT_COLOR = Color(0xFF454F5B);
  static const RED_TEXT_COLOR = Color(0xFFBE1128);
  static const HDBANK_YELLOW = Color(0xffFFC20E);
  static const HDBANK_YELLOW_MORE = Color(0xffF7A30A);
  static const MAIN_BACKGROUND = Color(0xffefefef);



  static const radialBgGradient = LinearGradient(
    colors: const [Color(0xffEB2629), Color(0xffBE1128)],
    begin: Alignment.topCenter,
    end: Alignment.topCenter,
  );
  static const linearBgButtonGradient = LinearGradient(
    colors: const [Color(0xffFFC20E), Color(0xffF7A30A)],
    begin: Alignment.topCenter,
    end: Alignment.topCenter,
  );
  static const linearGradient = LinearGradient(
    colors: const [Color(0xff046FDA), Color(0xff0359D4)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  static const linearGradientDisabled = LinearGradient(
    colors: const [Color(0xFFB4B4B4), Color(0xFF999999)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  static const linearQR = LinearGradient(
    colors: const [Color(0xFFEEEEEE), Color(0xFFEEEEEE), Color(0xFFEEEEEE), Color(0xFFEEEEEE), Color(0xFFB4B4B4)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Color Theme Red
  ///
  static const MAIN_THEME_COLOR_RED = Color(0xffB52331);
  static const ACCENT_THEME_COLOR_RED = Color(0xFFFFCF00);
  static const TEXT_IN_BACKGROUND_RED = Color(0xFF000000);
  static const BUTTON_COLOR_RED = Color(0xffB52331);
  static const CURSOR_COLOR_RED = Color(0xFF000000);
  static const FOCUS_COLOR_RED = Color(0xFFD3D8DE);
  static const SCAFFOLD_BACKGROUND_COLOR_RED = Color(0xFFFFFFFF);
  static const BOTTOM_APP_BAR_COLOR_RED = Color(0xFFFFFFFF);
  static const CARD_COLOR_RED = Color(0xFFFFFFFF);
  static const DIVIDER_COLOR_RED = Color(0xFFD8D8D8);
  static const BACKGROUND_COLOR_RED = Color(0xFFFFFFFF);
  static const DIALOG_BACKGROUND_COLOR_RED = Color(0xFFFFFFFF);
  static const HINT_COLOR_RED = Color(0xFFB6BEC8);

  static const INPUT_FILL_COLOR_RED = Color(0xFFFFFFFF);
  static const INPUT_BORDER_COLOR_RED = Color(0xffD3D8DE);
  static const INPUT_LABEL_COLOR_RED = Color(0xffB6BEC8);
  static const INPUT_ERROR_COLOR_RED = Color(0xFFE32000);
  static const INPUT_HINT_COLOR_RED = Color(0xFFB6BEC8);

  /// Color Theme Blue
  ///
  static const MAIN_THEME_COLOR_BLUE = Color(0xFF0359D4);
  static const ACCENT_THEME_COLOR_BLUE = Color(0xff0294B4);
  static const TEXT_IN_BACKGROUND_BLUE = Color(0xFF000000);
  static const BUTTON_COLOR_BLUE = Color(0xFF0359D4);
  static const CURSOR_COLOR_BLUE = Color(0xFF0359D4);
  static const FOCUS_COLOR_BLUE = Color(0xFF0359D4);
  static const SCAFFOLD_BACKGROUND_COLOR_BLUE = Color(0xFFFFFFFF);
  static const BOTTOM_APP_BAR_COLOR_BLUE = Color(0xFFFFFFFF);
  static const CARD_COLOR_BLUE = Color(0xFFFFFFFF);
  static const DIVIDER_COLOR_BLUE = Color(0xFFD8D8D8);
  static const BACKGROUND_COLOR_BLUE = Color(0xFFFFFFFF);
  static const DIALOG_BACKGROUND_COLOR_BLUE = Color(0xFFFFFFFF);
  static const HINT_COLOR_BLUE = Color(0xFFB3B1B1);

  static const INPUT_FILL_COLOR_BLUE = Color(0xFFFFFFFF);
  static const INPUT_BORDER_COLOR_BLUE = Color(0xFF0359D4);
  static const INPUT_LABEL_COLOR_BLUE = Color(0xFF0359D4);
  static const INPUT_ERROR_COLOR_BLUE = Color(0xFF0359D4);
  static const INPUT_HINT_COLOR_BLUE = Color(0xFFB3B1B1);
}

extension MyContext on BuildContext {
  Color dynamicColor({int red, int blue}) {
    if (Theme.of(this).primaryColor.value == AppColor.MAIN_THEME_COLOR_RED.value) {
      return Color(red);
    } else if (Theme.of(this).primaryColor.value == AppColor.MAIN_THEME_COLOR_BLUE.value) {
      return Color(blue);
    }
    return Color(blue);
  }

  Color dynamicColour({Color red, Color blue}) {
    if (Theme.of(this).primaryColor.value == AppColor.MAIN_THEME_COLOR_RED.value) {
      return red;
    } else if (Theme.of(this).primaryColor.value == AppColor.MAIN_THEME_COLOR_BLUE.value) {
      return blue;
    }
    return blue;
  }

  /// the white background
  Color get linearColor => dynamicColour(red: Color(0xFFE32000), blue: Color(0xff046FDA));
  Color get textInPrimary => dynamicColour(red: Color(0xFFFFFFFF), blue: Color(0xFFFFFFFF));
  Color get textInTime => dynamicColour(red: Color(0xFFF0908F), blue: Color(0xFFA5BEE9));
  Color get textInName => dynamicColour(red: Color(0xFFEE8080), blue: Color(0xFF81B0E8));
  Color get mainCheckBtn => dynamicColour(red: Color(0xFF52C41A), blue: Color(0xFF0359D4));
}
