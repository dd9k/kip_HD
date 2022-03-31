import 'package:check_in_pro_for_visitor/src/themes/BlueDark.dart';
import 'package:check_in_pro_for_visitor/src/themes/BlueLight.dart';
import 'package:check_in_pro_for_visitor/src/themes/GreenDark.dart';
import 'package:check_in_pro_for_visitor/src/themes/GreenLight.dart';
import 'package:check_in_pro_for_visitor/src/themes/RedLight.dart';

enum AppTheme {
  RedLight,
  BlueLight
}

final appThemeData = {
  AppTheme.RedLight: redLightTheme,
  AppTheme.BlueLight: blueLightTheme,
};
