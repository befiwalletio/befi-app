import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Point extends StatelessWidget {
  final double size;
  final Color color;

  const Point({Key key, this.color = Colors.red, this.size = 10}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          new BoxDecoration(color: color, borderRadius: BorderRadius.all(Radius.circular(size)), border: new Border.all(width: 1, color: color)),
      height: size,
      width: size,
    );
  }
}
