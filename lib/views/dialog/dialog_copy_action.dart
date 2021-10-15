import 'package:cube/core/base_widget.dart';
import 'package:cube/core/core.dart';
import 'package:cube/utils/utils_console.dart';
import 'package:cube/utils/utils_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DialogCopyAction extends StatefulWidget {
  final String title;
  final String text;
  final StringCallback callback;

  const DialogCopyAction({Key key, this.title, this.text, this.callback}) : super(key: key);

  @override
  _DialogCopyActionState createState() => _DialogCopyActionState();
}

class _DialogCopyActionState extends SizeState<DialogCopyAction> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget createView(BuildContext context) {
    return GestureDetector(
        child: IntrinsicHeight(
      child: Stack(
        children: [
          Positioned(
              left: SizeUtil.width(15),
              right: SizeUtil.width(15),
              top: 0,
              bottom: 0,
              child: Column(
                children: [
                  Spacer(),
                  Container(
                    padding: SizeUtil.padding(left: 0, right: 0, bottom: 10, top: 10),
                    width: SizeUtil.screenWidth(),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(6.0))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        widget.title != null
                            ? Container(
                                width: SizeUtil.screenWidth(),
                                padding: SizeUtil.padding(top: 10, left: 20, right: 20, bottom: 10),
                                child: Text(
                                  widget.title,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(fontSize: SizeUtil.sp(16)),
                                ),
                              )
                            : SizedBox(
                                height: 0,
                              ),
                        Container(
                          padding: SizeUtil.padding(left: 20, right: 20),
                          child: Text(
                            widget.text,
                            style: Theme.of(context).primaryTextTheme.subtitle1,
                          ),
                        ),
                        Container(
                          margin: SizeUtil.margin(top: 10),
                          padding: SizeUtil.padding(left: 20, right: 20),
                          width: SizeUtil.screenWidth(),
                          child: MaterialButton(
                            height: SizeUtil.height(35),
                            color: Colors.blue,
                            textColor: Colors.white,
                            child: Text(
                              "CommonCopy".tr,
                              style: TextStyle(fontSize: SizeUtil.sp(16)),
                            ),
                            onPressed: () {
                              if (widget.callback != null) {
                                widget.callback(widget.text);
                              }
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                  Spacer(),
                ],
              ))
        ],
      ),
    ));
  }

  @override
  void dispose() {
    super.dispose();
    Console.i("DialogCopyAction dispose");
  }
}
