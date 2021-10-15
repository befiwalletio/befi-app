import 'package:cube/core/base_widget.dart';
import 'package:flutter/material.dart';
import 'package:cube/utils/utils_size.dart';

class BeeBar extends StatefulWidget {
  final List<Widget> left;
  final List<Widget> right;
  final Widget title;
  final bool fixPadding;

  const BeeBar({Key key, this.title, this.left, this.right, this.fixPadding = true}) : super(key: key);

  @override
  _BeeBarState createState() => _BeeBarState();
}

class _BeeBarState extends SizeState<BeeBar> {
  @override
  Widget createView(BuildContext context) {
    return Container(
      width: SizeUtil.screenWidth(),
      padding: EdgeInsets.only(top: widget.fixPadding ? SizeUtil.barHeight() : 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: children(),
      ),
    );
  }

  List<Widget> children() {
    List<Widget> items = [];
    if (widget.left != null) {
      items.addAll(widget.left);
    }
    if (widget.title != null) {
      items.add(Expanded(
        flex: 1,
        child: widget.title,
      ));
    }
    if (widget.right != null) {
      items.addAll(widget.right);
    }
    return items;
  }
}
