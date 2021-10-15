import 'package:cube/core/base_widget.dart';
import 'package:cube/core/core.dart';
import 'package:cube/utils/utils_console.dart';
import 'package:cube/utils/utils_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class DialogInputBoard extends StatefulWidget {
  final String title;
  final String text;
  final StringCallback callback;

  const DialogInputBoard({Key key, this.title, this.text, this.callback}) : super(key: key);

  @override
  _DialogInputBoardState createState() => _DialogInputBoardState();
}

class InputBoardController extends GetxController {
  var text = "".obs;

  increment(text) => this.text.value = text;
}

class _DialogInputBoardState extends SizeState<DialogInputBoard> {
  TextEditingController _textController = TextEditingController();

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
                          child: _buildInput(widget.text ?? '请输入。。。'.tr, _textController, onChanged: (value) {}),
                        ),
                        Container(
                          margin: SizeUtil.margin(top: 10),
                          padding: SizeUtil.padding(left: 30, right: 30),
                          width: SizeUtil.screenWidth(),
                          child: MaterialButton(
                            height: SizeUtil.height(40),
                            color: Colors.blue,
                            textColor: Colors.white,
                            child: Text(
                              "CommonConfirm1".tr,
                              style: TextStyle(fontSize: SizeUtil.sp(16)),
                            ),
                            onPressed: () {
                              if (widget.callback != null) {
                                widget.callback(_textController.text);
                              }
                              Get.back();
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

  Widget _buildInput(label, controller,
      {TextInputFormatter inputFormatters,
      TextStyle style,
      TextInputType keyboardType,
      bool obscureText = false,
      Function onChanged,
      suffixIcon,
      maxLines = 1,
      bool justInput = false}) {
    Widget input = TextField(
      decoration: InputDecoration(
          fillColor: Colors.transparent,
          filled: false,
          hintText: label,
          suffixIcon: suffixIcon != null
              ? suffixIcon
              : Container(
                  width: 0,
                  height: 0,
                )),
      style: style != null ? style : StyleUtil.textStyle(size: 16, weight: FontWeight.normal),
      inputFormatters: inputFormatters != null ? [inputFormatters] : [],
      keyboardType: keyboardType != null ? keyboardType : TextInputType.text,
      obscureText: obscureText,
      textAlign: TextAlign.left,
      controller: controller,
      maxLines: maxLines,

      onChanged: (str) {
        if (onChanged != null) {
          onChanged(str);
        }
      },
    );
    if (justInput) {
      return input;
    }
    return Container(
      child: input,
    );
  }

  @override
  void dispose() {
    super.dispose();
    Console.i("DialogInputBoard dispose");
  }
}
