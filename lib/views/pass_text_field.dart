import 'package:cube/core/base_widget.dart';
import 'package:flutter/material.dart';

class PassTextField extends StatefulWidget {
  const PassTextField({Key key}) : super(key: key);

  @override
  _PassTextFieldState createState() => _PassTextFieldState();
}

class _PassTextFieldState extends SizeState<PassTextField> {
  @override
  Widget createView(BuildContext context) {
    return Container(
      child: Text('PassTextField'),
    );
  }
}
