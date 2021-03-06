//import 'package:check_in_pro_for_visitor/src/constants/AppColors.dart';
//import 'package:check_in_pro_for_visitor/src/utilities/Utilities.dart';
//import 'package:flutter/material.dart';
//import 'dart:math' as math;
//
//class ClockExpired extends StatefulWidget {
//  final int timeOutInit;
//
//  const ClockExpired({Key key, this.timeOutInit}) : super(key: key);
//
//  @override
//  ClockExpiredState createState() => ClockExpiredState();
//}
//
//class ClockExpiredState extends State<ClockExpired> with TickerProviderStateMixin {
//  AnimationController controller;
//
//  String get timerString {
//    Duration duration = controller.duration * controller.value;
//    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
//  }
//
//  @override
//  void initState() {
//    super.initState();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return StreamBuilder<int>(
//      stream: Utilities().getTimeExpired(),
//      builder: (context, snapshot) {
//        int timeExpired = 60;
//        if (!snapshot.hasData) {
//          return Container();
//        }
//        timeExpired = widget.timeOutInit ?? snapshot.data;
//        if (controller != null) {
//          controller?.dispose();
//        }
//        controller = AnimationController(
//          vsync: this,
//          duration: Duration(seconds: timeExpired),
//        );
//        controller.reverse(from: controller.value == 0.0 ? 1.0 : controller.value);
//        return AnimatedBuilder(
//            animation: controller,
//            builder: (context, child) {
//              return Container(
//                width: 64,
//                height: 64,
//                child: Stack(
//                  children: <Widget>[
////                  Align(
////                    alignment: Alignment.centerLeft,
////                    child:
////                    Container(
////                      color: Colors.amber,
////                      width:
////                      controller.value * 100,
////                    ),
////                  ),
//                    Padding(
//                      padding: EdgeInsets.all(8.0),
//                      child: Column(
//                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                        children: <Widget>[
//                          Expanded(
//                            child: Align(
//                              alignment: FractionalOffset.center,
//                              child: AspectRatio(
//                                aspectRatio: 1.0,
//                                child: Stack(
//                                  children: <Widget>[
//                                    Positioned.fill(
//                                      child: CustomPaint(
//                                          painter: CustomTimerPainter(
//                                        animation: controller,
//                                        backgroundColor: Colors.white,
//                                        color: Theme.of(context).primaryColor,
//                                      )),
//                                    ),
////                                    Align(
////                                      alignment: FractionalOffset.center,
////                                      child: Text(
////                                        timerString,
////                                        style: TextStyle(fontSize: 20.0, fontFamily: "Led", color: Colors.black),
////                                      ),
////                                    ),
//                                  ],
//                                ),
//                              ),
//                            ),
//                          ),
//                        ],
//                      ),
//                    ),
//                  ],
//                ),
//              );
//            });
//      },
//    );
//  }
//
//  @override
//  void dispose() {
//    controller?.dispose();
//    super.dispose();
//  }
//}
//
//class CustomTimerPainter extends CustomPainter {
//  CustomTimerPainter({
//    this.animation,
//    this.backgroundColor,
//    this.color,
//  }) : super(repaint: animation);
//
//  final Animation<double> animation;
//  final Color backgroundColor, color;
//
//  @override
//  void paint(Canvas canvas, Size size) {
//    Paint paint = Paint()
//      ..color = backgroundColor
//      ..strokeWidth = 2.5
//      ..strokeCap = StrokeCap.butt
//      ..style = PaintingStyle.stroke;
//
//    canvas.drawCircle(size.center(Offset.zero), size.width / 2.0, paint);
//    paint.color = color;
//    double progress = (0.0 + animation.value) * 2 * math.pi;
//    canvas.drawArc(Offset.zero & size, math.pi * 1.5, -progress, false, paint);
//  }
//
//  @override
//  bool shouldRepaint(CustomTimerPainter old) {
//    return animation.value != old.animation.value || color != old.color || backgroundColor != old.backgroundColor;
//  }
//}
