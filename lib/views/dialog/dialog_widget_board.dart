import 'package:cube/core/base_widget.dart';
import 'package:cube/utils/utils_size.dart';
import 'package:flutter/material.dart';

class DialogWidgetBoard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const DialogWidgetBoard({Key key, this.child, this.padding}) : super(key: key);

  @override
  _DialogWidgetBoardState createState() => _DialogWidgetBoardState();
}

class _DialogWidgetBoardState extends SizeState<DialogWidgetBoard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget createView(BuildContext context) {
    return Container(
      child: _createContent(),
    );
  }

  Widget _createContent() {
    return GestureDetector(
        child: IntrinsicHeight(
      child: Stack(
        children: [
          Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: widget.padding ?? SizeUtil.padding(left: 0, right: 0, bottom: 40, top: 20),
                width: SizeUtil.screenWidth(),
                decoration: BoxDecoration(
                    color: Colors.grey[50], borderRadius: BorderRadius.only(topLeft: Radius.circular(6.0), topRight: Radius.circular(6.0))),
                child: widget.child ?? Container(),
              ))
        ],
      ),
    ));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
