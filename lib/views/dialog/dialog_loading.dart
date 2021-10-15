import 'package:cube/core/base_widget.dart';
import 'package:cube/core/constant.dart';
import 'package:cube/utils/utils_size.dart';
import 'package:flutter/material.dart';

class DialogLoading extends StatefulWidget {
  const DialogLoading({Key key}) : super(key: key);

  @override
  _DialogLoadingState createState() => _DialogLoadingState();
}

class _DialogLoadingState extends SizeState<DialogLoading> {
  @override
  Widget createView(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      height: double.infinity,
      padding: SizeUtil.padding(bottom: 100),
      child: Container(
        width: SizeUtil.width(100),
        height: SizeUtil.width(100),
        decoration: new BoxDecoration(
          color: Colors.white70,
          borderRadius: new BorderRadius.circular(SizeUtil.width(5)),
        ),
        child: _Progress(),
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  final Widget child;

  _Progress({
    Key key,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.transparent,
        child: Center(
          child: child ??
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(BeeColors.blue),
              ),
        ));
  }
}

class _PopRoute extends PopupRoute {
  final Duration _duration = Duration(milliseconds: 300);
  Widget child;

  _PopRoute({@required this.child});

  @override
  Color get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  String get barrierLabel => null;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return child;
  }

  @override
  Duration get transitionDuration => _duration;
}
