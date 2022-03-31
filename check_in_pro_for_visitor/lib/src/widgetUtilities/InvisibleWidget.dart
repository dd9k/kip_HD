import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InvisibleWidget extends StatefulWidget {
  const InvisibleWidget({
    Key key,
    this.child,
    this.visible,
  }) : super(key: key);
  final Widget child;
  final bool visible;

  @override
  InvisibleState createState() => InvisibleState();
}

class InvisibleState extends State<InvisibleWidget> {
  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: !widget.visible,
      child: Opacity(
        opacity: widget.visible ? 1 : 0,
        child: widget.child,
      ),
    );
  }
}
