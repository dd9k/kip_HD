import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'TextFieldComon.dart';
import 'keyboard/virtual_keyboard.dart';

class KeyboardDemo extends StatefulWidget {
  @override
  _KeyboardDemoState createState() => _KeyboardDemoState();
}

class _KeyboardDemoState extends State<KeyboardDemo> {
  TextEditingController _controller = TextEditingController();
  bool isNumericMode = true;
  bool shiftEnabled = true;
  String text = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          SizedBox(height: 50),
          Text(
            text,
            style: Theme.of(context).textTheme.headline5,
          ),
          Padding(
            padding: const EdgeInsets.only(left:20.0,right:20),
            child: TextFieldCommon(
              controller: _controller,
              showCursor: true,
              readOnly: true,
              onTap:(){
                showModalBottomSheet<void>(
                    context: context,
                    builder: (context){
                      return Container(
                        color: Colors.white,
                        child: VirtualKeyboard(
                          height: 350,
                          textColor: Colors.black,
                          fontSize: 30,
                          canSwitchType: false,
                          initType: !isNumericMode
                              ? VirtualKeyboardType.Numeric
                              : VirtualKeyboardType.Alphanumeric,
                          onKeyPress: (index,bool) {
                            setState(() {
                              _controller.text=index;
                              isNumericMode = bool;
                            });
                          },
                        ),
                      );
                    }
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
