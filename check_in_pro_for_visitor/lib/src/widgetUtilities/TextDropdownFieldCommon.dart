import 'dart:async';

import 'package:check_in_pro_for_visitor/src/constants/AppColors.dart';
import 'package:flutter/material.dart';
import 'package:check_in_pro_for_visitor/src/widgetUtilities/TypeHead.dart';

class TextDropdownFieldCommon<T> extends StatefulWidget {
  TextDropdownFieldCommon(
      {Key key,
      @required this.suggestionsCallback,
      @required this.itemBuilder,
      @required this.onSuggestionSelected,
      this.textFieldConfiguration: const TextFieldConfiguration(),
      this.suggestionsBoxDecoration: const SuggestionsBoxDecoration(),
      this.debounceDuration: const Duration(milliseconds: 300),
      this.suggestionsBoxController,
      this.loadingBuilder,
      this.noItemsFoundBuilder,
      this.errorBuilder,
      this.transitionBuilder,
      this.animationStart: 0.25,
      this.animationDuration: const Duration(milliseconds: 500),
      this.getImmediateSuggestions: false,
      this.suggestionsBoxVerticalOffset: 5.0,
      this.direction: AxisDirection.down,
      this.hideOnLoading: false,
      this.hideOnEmpty: false,
      this.hideOnError: false,
      this.hideSuggestionsOnKeyboardHide: true,
      this.keepSuggestionsOnLoading: true,
      this.keepSuggestionsOnSuggestionSelected: false,
      this.autoFlipDirection: false});

  final SuggestionsCallback<T> suggestionsCallback;
  final SuggestionSelectionCallback<T> onSuggestionSelected;
  final ItemBuilder<T> itemBuilder;
  final SuggestionsBoxDecoration suggestionsBoxDecoration;
  final SuggestionsBoxController suggestionsBoxController;
  final Duration debounceDuration;
  final WidgetBuilder loadingBuilder;
  final WidgetBuilder noItemsFoundBuilder;
  final ErrorBuilder errorBuilder;
  final AnimationTransitionBuilder transitionBuilder;
  final Duration animationDuration;
  final AxisDirection direction;
  final double animationStart;
  final TextFieldConfiguration textFieldConfiguration;
  final double suggestionsBoxVerticalOffset;
  final bool getImmediateSuggestions;
  final bool hideOnLoading;
  final bool hideOnEmpty;
  final bool hideOnError;
  final bool hideSuggestionsOnKeyboardHide;
  final bool keepSuggestionsOnLoading;
  final bool keepSuggestionsOnSuggestionSelected;
  final bool autoFlipDirection;

  @override
  _TextDropdownFieldCommonState<T> createState() => _TextDropdownFieldCommonState<T>();
}

class _TextDropdownFieldCommonState<T> extends State<TextDropdownFieldCommon<T>> {
  @override
  bool isInit = false;
  Color labelColor = AppColor.INPUT_LABEL_COLOR_RED;

  @override
  void initState() {
    super.initState();
    if (!isInit) {
      isInit = true;
      widget?.textFieldConfiguration?.focusNode?.addListener(
        () {
          setState(() {
            if (widget.textFieldConfiguration.focusNode.hasFocus || widget?.textFieldConfiguration?.controller?.text?.isNotEmpty == true) {
              labelColor = AppColor.BLACK_TEXT_COLOR;
            } else {
              labelColor = AppColor.INPUT_LABEL_COLOR_RED;
            }
          });
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return TypeAheadField(
      suggestionsCallback: widget.suggestionsCallback,
      onSuggestionSelected: widget.onSuggestionSelected,
      itemBuilder: widget.itemBuilder,
      suggestionsBoxDecoration: widget.suggestionsBoxDecoration,
      textFieldConfiguration: widget.textFieldConfiguration.copyWith(
        focusNode: widget.textFieldConfiguration.focusNode,
        decoration: widget.textFieldConfiguration.decoration.copyWith(
          labelStyle: TextStyle(color: labelColor),
        ),
      ),
      suggestionsBoxController: widget.suggestionsBoxController,
      debounceDuration: widget.debounceDuration,
      loadingBuilder: widget.loadingBuilder,
      noItemsFoundBuilder: widget.noItemsFoundBuilder,
      errorBuilder: widget.errorBuilder,
      transitionBuilder: widget.transitionBuilder,
      animationDuration: widget.animationDuration,
      direction: widget.direction,
      animationStart: widget.animationStart,
      suggestionsBoxVerticalOffset: widget.suggestionsBoxVerticalOffset,
      getImmediateSuggestions: widget.getImmediateSuggestions,
      hideOnLoading: widget.hideOnLoading,
      hideOnEmpty: widget.hideOnEmpty,
      hideOnError: widget.hideOnError,
      hideSuggestionsOnKeyboardHide: widget.hideSuggestionsOnKeyboardHide,
      keepSuggestionsOnLoading: widget.keepSuggestionsOnLoading,
      keepSuggestionsOnSuggestionSelected: widget.keepSuggestionsOnSuggestionSelected,
      autoFlipDirection: widget.autoFlipDirection,
    );
  }
}
