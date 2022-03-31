import 'package:check_in_pro_for_visitor/src/utilities/AppLocalizations.dart';
import 'package:check_in_pro_for_visitor/src/widgetUtilities/TextFieldComon.dart';
import 'package:flutter/material.dart';
import 'package:check_in_pro_for_visitor/src/constants/AppColors.dart';
import 'package:check_in_pro_for_visitor/src/utilities/Utilities.dart';
import 'package:check_in_pro_for_visitor/src/constants/Styles.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ReviewScreen extends StatefulWidget {
  static const String route_name = '/ReviewScreen';
  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  Color color = Colors.red;
  Color gradientColor1 = Colors.lightBlueAccent;
  Color gradientColor2 = Colors.blue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back),
        ),
      ),
      body: Row(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Color',
                        style: Theme.of(context)
                            .textTheme
                            .headline5
                            .copyWith(fontSize: 18),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                        onTap: () => pickColor(context),
                        child: Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: color),
                          width: 30,
                          height: 30,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Gradient Color',
                        style: Theme.of(context)
                            .textTheme
                            .headline5
                            .copyWith(fontSize: 18),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                        onTap: () => pickGradientColor1(context),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: gradientColor1,
                          ),
                          width: 30,
                          height: 30,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                        onTap: () => pickGradientColor2(context),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: gradientColor2,
                          ),
                          width: 30,
                          height: 30,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: _buildFormUI(),
          ),
        ],
      ),
    );
  }

  void pickColor(BuildContext context) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Select Color',
            textAlign: TextAlign.center,
          ),
          content: buildColorPicker(),
        ),
      );

  Widget buildColorPicker() => ColorPicker(
        pickerColor: color,
        enableAlpha: false,
        showLabel: false,
        onColorChanged: (color) => setState(() => this.color = color),
      );

  void pickGradientColor1(BuildContext context) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Select Gradient Color1',
            textAlign: TextAlign.center,
          ),
          content: buildGradientColorPicker1(),
        ),
      );

  Widget buildGradientColorPicker1() => ColorPicker(
        pickerColor: gradientColor1,
        enableAlpha: false,
        showLabel: false,
        onColorChanged: (color) => setState(() => this.gradientColor1 = color),
      );

  void pickGradientColor2(BuildContext context) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Select Gradient Color2',
            textAlign: TextAlign.center,
          ),
          content: buildGradientColorPicker2(),
        ),
      );

  Widget buildGradientColorPicker2() => ColorPicker(
        pickerColor: gradientColor1,
        enableAlpha: true,
        showLabel: true,
        onColorChanged: (color) => setState(() => this.gradientColor2 = color),
      );

  Widget _buildFormUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: _buildPhoneNumberTxtField(),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: _buildBtn(),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: color,
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Container(
              height: 100,
              width: 100,
              alignment: Alignment.center,
              child: Text(
                'Phỏng vấn',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneNumberTxtField() {
    return Padding(
      padding: const EdgeInsets.only(top: 0.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                  child: Padding(
                padding: EdgeInsets.only(top: 10),
                child: TextFieldCommon(
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: color,
                        ),
                      ),
                      suffixIcon: GestureDetector(
                        onTap: () {},
                        child: Container(
                          height: 56,
                          width: 56,
                          child: Icon(
                            Icons.cancel,
                            size: 24,
                            color: AppColor.HINT_TEXT_COLOR,
                          ),
                        ),
                      ),
                      labelStyle: TextStyle(color: color),
                      labelText: AppLocalizations.of(context).phoneNumber,
                    ),
                    onChanged: (_) => Utilities().moveToWaiting(),
                    onTap: () => Utilities().moveToWaiting(),
                    onEditingComplete: () {},
                    style: Styles.formFieldText),
              ))
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBtn() {
    return Container(
      padding: const EdgeInsets.only(top: 20),
      child: RaisedGradientButton(
          child: Text(
            'Button',
            style: TextStyle(color: Colors.white),
          ),
          gradient: LinearGradient(
            colors: <Color>[gradientColor1, gradientColor2],
          ),
          onPressed: () {
            print('button clicked');
          }),
    );
  }
}

class RaisedGradientButton extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  final double width;
  final double height;
  final Function onPressed;

  const RaisedGradientButton({
    Key key,
    @required this.child,
    this.gradient,
    this.width = double.infinity,
    this.height = 50.0,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 50.0,
      decoration: BoxDecoration(gradient: gradient, boxShadow: [
        BoxShadow(
          color: Colors.grey[500],
          offset: Offset(0.0, 1.5),
          blurRadius: 1.5,
        ),
      ]),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
            onTap: onPressed,
            child: Center(
              child: child,
            )),
      ),
    );
  }
}
