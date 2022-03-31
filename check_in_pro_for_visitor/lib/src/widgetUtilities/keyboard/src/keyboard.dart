part of virtual_keyboard;

const double _virtualKeyboardDefaultHeight = 300;
const int _virtualKeyboardBackspaceEventPerioud = 250;

class VirtualKeyboard extends StatefulWidget {
  final VirtualKeyboardType initType;
  final Function(String, bool) onKeyPress;
  final double height;
  final Color textColor;
  final double fontSize;
  final Widget Function(BuildContext context, VirtualKeyboardKey key) builder;
  final bool alwaysCaps;
  final bool canSwitchType;

  VirtualKeyboard({
    Key key,
    @required this.initType,
    @required this.onKeyPress,
    this.builder,
    this.height = _virtualKeyboardDefaultHeight,
    this.textColor = Colors.black,
    this.fontSize = 14,
    this.alwaysCaps = false,
    this.canSwitchType = true,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _VirtualKeyboardState();
  }
}

/// Holds the state for Virtual Keyboard class.
class _VirtualKeyboardState extends State<VirtualKeyboard> {
  VirtualKeyboardType type;
  Function(String, bool) onKeyPress;
  Widget Function(BuildContext context, VirtualKeyboardKey key) builder;
  double height;
  Color textColor;
  double fontSize;
  bool alwaysCaps;
  TextStyle textStyle;
  bool isNumericMode = true;
  bool shiftEnabled = true;
  // True if shift is enabled.
  bool isShiftEnabled = false;
  String text = '';

  @override
  void didUpdateWidget(Widget oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      type = widget.initType;
      onKeyPress = widget.onKeyPress;
      height = widget.height;
      textColor = widget.textColor;
      fontSize = widget.fontSize;
      alwaysCaps = widget.alwaysCaps;

      // Init the Text Style for keys.
      textStyle = TextStyle(
        fontSize: fontSize,
        color: textColor,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    type = widget.initType;
    onKeyPress = widget.onKeyPress;
    height = widget.height;
    textColor = widget.textColor;
    fontSize = widget.fontSize;
    alwaysCaps = widget.alwaysCaps;

    textStyle = TextStyle(
      fontSize: fontSize,
      color: textColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return type == VirtualKeyboardType.Numeric ? _numeric() : _alphanumeric();
  }

  Widget _alphanumeric() {
    return Container(
      height: height,
      width: MediaQuery
          .of(context)
          .size
          .width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: _rows(),
      ),
    );
  }

  Widget _numeric() {
    return Container(
      height: height,
      width: MediaQuery
          .of(context)
          .size
          .width / 3,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: _rows(),
      ),
    );
  }

  List<Widget> _rows() {
    List<List<VirtualKeyboardKey>> keyboardRows =
    type == VirtualKeyboardType.Numeric
        ? _getKeyboardRowsNumeric()
        : _getKeyboardRows();

    // Generate keyboard row.
    List<Widget> rows = List.generate(keyboardRows.length, (int rowNum) {
      return Material(
        borderRadius: BorderRadius.circular(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(
            keyboardRows[rowNum].length,
                (int keyNum) {
              VirtualKeyboardKey virtualKeyboardKey =
              keyboardRows[rowNum][keyNum];
              Widget keyWidget;
              if (builder == null) {
                switch (virtualKeyboardKey.keyType) {
                  case VirtualKeyboardKeyType.String:
                    keyWidget = _keyboardDefaultKey(virtualKeyboardKey);
                    break;
                  case VirtualKeyboardKeyType.Action:
                    keyWidget = _keyboardDefaultActionKey(
                        virtualKeyboardKey, widget.canSwitchType);
                    break;
                }
              } else {
                keyWidget = builder(context, virtualKeyboardKey);

                if (keyWidget == null) {
                  throw 'builder function must return Widget';
                }
              }

              return keyWidget;
            },
          ),
        ),
      );
    });
    return rows;
  }

  bool longPress;

  Widget _keyboardDefaultKey(VirtualKeyboardKey key) {
    return Expanded(
        child: InkWell(
          highlightColor: Colors.grey,
          splashColor: Colors.grey,
          onTap: () {
            if (key.keyType == VirtualKeyboardKeyType.String) {
              text = text + (shiftEnabled ? key.capsText : key.text);
            } else if (key.keyType == VirtualKeyboardKeyType.Action) {
              switch (key.action) {
                case VirtualKeyboardKeyAction.Backspace:
                  if (text.length == 0) return;
                  text = text.substring(0, text.length - 1);
                  break;
                case VirtualKeyboardKeyAction.Return:
                  //text = text + '\n';
                  break;
                case VirtualKeyboardKeyAction.Shift:
                  isNumericMode = !isNumericMode;
                  break;
                default:
              }
            }
            onKeyPress(text, isNumericMode);
          },
          child: Container(
            margin: EdgeInsets.all(2),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black26),
              borderRadius: BorderRadius.circular(10),
            ),
            height: height / (_keyRows.length + 0.2),
            child: Center(
                child: Text(
                  alwaysCaps
                      ? key.capsText
                      : (isShiftEnabled ? key.capsText : key.text),
                  style: textStyle,
                )),
          ),
        ));
  }

  Widget _keyboardDefaultActionKey(VirtualKeyboardKey key, bool canSwitchType) {
    Widget actionKey;
    switch (key.action) {
      case VirtualKeyboardKeyAction.Backspace:
        actionKey = GestureDetector(
          onLongPress: () {
            longPress = true;
            Timer.periodic(
                Duration(milliseconds: _virtualKeyboardBackspaceEventPerioud),
                    (timer) {
                  if (longPress) {
                    if (key.keyType == VirtualKeyboardKeyType.String) {
                      text = text + (shiftEnabled ? key.capsText : key.text);
                    } else if (key.keyType == VirtualKeyboardKeyType.Action) {
                      switch (key.action) {
                        case VirtualKeyboardKeyAction.Backspace:
                          if (text.length == 0) return;
                          text = text.substring(0, text.length - 1);
                          break;
                        case VirtualKeyboardKeyAction.Return:
                          //text = text + '\n';
                          break;
                        case VirtualKeyboardKeyAction.Shift:
                          isNumericMode = !isNumericMode;
                          break;
                        default:
                      }
                    }
                    onKeyPress(text, isNumericMode);
                  } else {
                    timer.cancel();
                  }
                });
          },
          onLongPressUp: () {
            longPress = false;
          },
          child: Container(
            height: double.infinity,
            width: double.infinity,
            child: Icon(
              Icons.backspace,
              color: textColor,
            ),
          ),
        );
        break;
      case VirtualKeyboardKeyAction.Shift:
        actionKey = Text(
          type == VirtualKeyboardType.Numeric ? 'ABC' : '123',
          style: TextStyle(color: Colors.black, fontSize: 30),
        );
        break;
      case VirtualKeyboardKeyAction.Return:
        actionKey = Text('Done',style: TextStyle(color: Colors.blue, fontSize: 27),);
        break;
    }

    return Expanded(
      child: InkWell(
        onTap: () {
          if (canSwitchType == true) {
            if (key.action == VirtualKeyboardKeyAction.Shift) {
              if (!alwaysCaps) {
                setState(() {
                  isShiftEnabled = !isShiftEnabled;
                });
              }
            }
            if (key.keyType == VirtualKeyboardKeyType.String) {
              text = text + (shiftEnabled ? key.capsText : key.text);
            } else if (key.keyType == VirtualKeyboardKeyType.Action) {
              switch (key.action) {
                case VirtualKeyboardKeyAction.Backspace:
                  if (text.length == 0) return;
                  text = text.substring(0, text.length - 1);
                  break;
                case VirtualKeyboardKeyAction.Return:
                  //text = text + '\n';
                  break;
                case VirtualKeyboardKeyAction.Shift:
                  isNumericMode = !isNumericMode;
                  break;
                default:
              }
            }
            onKeyPress(text, isNumericMode);
          }
        },
        child: Container(
          alignment: Alignment.center,
          margin: EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.grey[350],
            border: Border.all(color: Colors.black26),
            borderRadius: BorderRadius.circular(10),
          ),
          height: height / (_keyRows.length + 0.2),
          child: Center(
            child: actionKey,
          ),
        ),
      ),
    );
  }
}
