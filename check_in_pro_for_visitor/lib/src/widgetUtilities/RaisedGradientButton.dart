import 'package:check_in_pro_for_visitor/src/constants/AppColors.dart';
import 'package:check_in_pro_for_visitor/src/constants/AppDestination.dart';
import 'package:check_in_pro_for_visitor/src/constants/Constants.dart';
import 'package:check_in_pro_for_visitor/src/constants/Styles.dart';
import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'dart:math' as math;

class RaisedGradientButton extends StatelessWidget {
  final String btnText;
  final double textSize;
  final VoidCallback onPressed;
  final double height;
  final bool isLoading;
  final bool styleEmpty;
  final double btnTextSize;
  final RoundedLoadingButtonController btnController;

  final disable;

  RaisedGradientButton(
      {this.btnText,
      this.btnTextSize,
      this.textSize,
      @required this.onPressed,
      this.height,
      @required this.disable,
      this.isLoading,
      this.styleEmpty,
      this.btnController});

  @override
  Widget build(BuildContext context) {
    var isLoadingButton = isLoading ?? false;
    if (isLoadingButton) {
      return AbsorbPointer(
        absorbing: disable,
        child: RoundedLoadingButton(
          onPressed: onPressed,
          controller: btnController,
          valueColor: AppColor.RED_TEXT_COLOR,
          color: Color(0xffFFC20E),
          child: buildContent(context),
        ),
      );
    }
    return AbsorbPointer(
      absorbing: disable,
      child: RaisedButton(
        onPressed: onPressed,
        color: Colors.transparent,
        elevation: 0,
        padding: const EdgeInsets.all(0.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDestination.RADIUS_TEXT_INPUT)),
        child: buildContent(context),
      ),
    );
  }

  Ink buildContent(BuildContext context) {
    if (styleEmpty != null && styleEmpty) {
      return buildEmpty(context);
    }
    return buildFull(context);
  }

  Ink buildFull(BuildContext context) {
    return Ink(
      decoration: BoxDecoration(
          gradient: disable
              ? AppColor.linearGradientDisabled
              : LinearGradient(
                  colors: [Color(0xffFFC20E), Color(0xffF7A30A)],
                  begin: Alignment(-1, 0.5),
                  end: Alignment(-1, -1),
                  transform: GradientRotation(math.pi),
                ),
          borderRadius: BorderRadius.circular(AppDestination.RADIUS_TEXT_INPUT)),
      child: Container(
        constraints: BoxConstraints(minHeight: this.height ?? Constants.HEIGHT_BUTTON),
        alignment: Alignment.center,
        child: Text(
          btnText,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: Styles.OpenSans,
            color: AppColor.BUTTON_TEXT_COLOR,
            fontWeight: FontWeight.bold,
            fontSize: (textSize == null) ? Theme.of(context).textTheme.title.fontSize : textSize,
          ),
        ),
      ),
    );
  }

  Ink buildEmpty(BuildContext context) {
    return Ink(
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Theme.of(context).primaryColor, width: 1),
          borderRadius: BorderRadius.circular(AppDestination.RADIUS_TEXT_INPUT)),
      child: Container(
        constraints: BoxConstraints(minHeight: this.height ?? Constants.HEIGHT_BUTTON),
        alignment: Alignment.center,
        child: Text(
          btnText,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: Styles.OpenSans,
            color: Colors.black,
            fontSize: (textSize == null) ? Theme.of(context).textTheme.title.fontSize : textSize,
          ),
        ),
      ),
    );
  }
}
