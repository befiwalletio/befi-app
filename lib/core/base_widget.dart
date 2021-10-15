import 'package:cube/core/core.dart';
import 'package:cube/utils/utils_size.dart';
import 'package:cube/views/dialog/dialog_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import 'constant.dart';

abstract class SizeState<T extends StatefulWidget> extends State<T> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  AnimationController loadingController;
  DialogLoading _dialogLoading;

  @override
  void initState() {
    super.initState();
    loadingController = AnimationController(vsync: this)
      // ..value = 0.5
      ..addListener(() {})
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          loadingController.repeat();
        }
      });
    EasyLoading.instance
      ..loadingStyle = EasyLoadingStyle.custom
      ..backgroundColor = Colors.black26
      ..indicatorColor = Colors.yellow
      ..textColor = Colors.yellow
      ..maskColor = Colors.blue.withOpacity(0.5)
      ..userInteractions = true
      ..dismissOnTap = true
      ..indicatorWidget = Container(
        width: SizeUtil.width(80),
        height: SizeUtil.width(80),
        child: createLottie(),
      )
      ..customAnimation = CustomAnimation();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return createView(context);
  }

  @protected
  Widget createView(BuildContext context);

  showLoading({bool show = true}) async {
    return await showLoadingDialog(show: show);
  }

  showLoadingDialog({show: true}) async {
    if (!show) {
      if (_dialogLoading != null) {
        Get.back();
        _dialogLoading = null;
      } else {}
      return Future.value(true);
    }
    if (_dialogLoading != null) {
      return Future.value(true);
    }
    _dialogLoading = DialogLoading();

    return await showDialog(
        barrierDismissible: false,
        useSafeArea: false,
        context: context,
        builder: (context) {
          return _dialogLoading;
        });
  }

  bool get wantKeepAlive => false;

  Widget buildCard(Widget child, {padding, margin}) {
    return Card(
      elevation: 0,
      margin: margin ?? SizeUtil.margin(left: 15, right: 15, top: 7, bottom: 7),
      child: Container(
        padding: padding ?? SizeUtil.padding(all: 10),
        width: SizeUtil.screenWidth(),
        child: child,
      ),
    );
  }

  Widget buildEmpty() {
    return Container(
      width: double.infinity,
      margin: SizeUtil.margin(top: 100),
      child: Column(
        children: [
          SvgPicture.asset(
            'assets/icons/icon_no_data.svg',
            width: SizeUtil.width(80),
          ),
          Text(
            'CommonNoData'.tr,
            style: Theme.of(context).primaryTextTheme.subtitle1,
          )
        ],
      ),
    );
  }

  Widget buildRefresh(Widget child, EasyRefreshController controller, refreshCallback, {noMore: true, loadCallback}) {
    var refreshView = EasyRefresh(
      header: MaterialHeader(),
      onRefresh: () async {
        await refreshCallback();
        controller.finishRefresh(success: true);
      },
      onLoad: loadCallback != null
          ? () async {
              await loadCallback();
              controller.finishLoad(success: true, noMore: noMore);
            }
          : null,
      controller: controller,
      child: child,
    );
    return refreshView;
  }

  @override
  void dispose() {
    showLoading(show: false);
    super.dispose();
  }

  Widget createLottie() {
    return Container(
      child: Lottie.asset(
        'assets/lottie_loading.json',
        controller: loadingController,
        width: SizeUtil.screenWidth() / 3,
        onLoaded: (composition) {
          loadingController
            ..duration = Duration(milliseconds: 1500)
            ..forward();
        },
      ),
    );
  }
}

abstract class ViewState<T extends StatefulWidget> extends SizeState<T> {
  @override
  void initState() {
    super.initState();
  }

  Widget buildTextArea(label, controller, {bool showClear = false, StringCallback callback}) {
    return Container(
      width: SizeUtil.screenWidth(),
      constraints: BoxConstraints(
        maxHeight: SizeUtil.height(120),
        minHeight: SizeUtil.height(70),
        maxWidth: SizeUtil.screenWidth(),
      ),
      child: buildInput(label, controller, onChanged: (str) {
        if (strIsEmpty(str) && showClear) {
          setState(() {
            showClear = false;
          });
        } else if (!strIsEmpty(str) && !showClear) {
          setState(() {
            showClear = true;
          });
        }
        if (callback != null) {
          callback(str);
        }
      },
          suffixIcon: showClear
              ? IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    controller.clear();
                    setState(() {
                      showClear = false;
                    });
                  },
                )
              : Container(
                  width: 0,
                  height: 0,
                ),
          keyboardType: TextInputType.multiline,
          maxLines: null,
          justInput: true),
    );
  }

  Widget buildTextArea2(label, controller, {StringCallback callback, Widget suffixIcon}) {
    return Container(
        width: double.infinity,
        constraints: BoxConstraints(maxHeight: SizeUtil.height(120), minHeight: SizeUtil.height(70), maxWidth: double.infinity),
        child: buildInput(label, controller, onChanged: (str) {
          if (callback != null) {
            callback(str);
          }
        }, suffixIcon: suffixIcon, keyboardType: TextInputType.multiline, maxLines: null, justInput: true));
  }

  Widget buildTextArea3(label, controller, {StringCallback callback, Widget suffixIcon}) {
    return Container(
        width: SizeUtil.screenWidth(),
        constraints: BoxConstraints(maxHeight: SizeUtil.height(120), minHeight: SizeUtil.height(70), maxWidth: SizeUtil.screenWidth()),
        child: buildInput(label, controller, onChanged: (str) {
          if (callback != null) {
            callback(str);
          }
        }, suffixIcon: suffixIcon, keyboardType: TextInputType.multiline, maxLines: null, justInput: true));
  }

  Widget buildPassword(label, controller, {VoidCallback clicker}) {
    return buildInput(
      label,
      controller,
      obscureText: true,
      keyboardType: TextInputType.number,
      maxLength: 6,
      onTap: clicker,
      inputFormatters: FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
    );
  }

  Widget buildInput(label, controller,
      {TextInputFormatter inputFormatters,
      TextStyle style,
      TextInputType keyboardType,
      bool obscureText = false,
      Function onChanged,
      suffixIcon,
      maxLines = 1,
      bool justInput = false,
      maxLength = TextField.noMaxLength,
      VoidCallback onTap}) {
    Widget input = TextField(
      autofocus: false,
      decoration: InputDecoration(
          border: InputBorder.none,
          fillColor: Colors.transparent,
          filled: false,
          labelText: label,
          counterText: "",
          suffixIcon: suffixIcon != null
              ? suffixIcon
              : Container(
                  width: 0,
                  height: 0,
                )),
      style: style != null ? style : StyleUtil.textStyle(size: 16, weight: FontWeight.bold),
      inputFormatters: inputFormatters != null ? [inputFormatters] : [],
      keyboardType: keyboardType != null ? keyboardType : TextInputType.text,
      obscureText: obscureText,
      textAlign: TextAlign.left,
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      onTap: () {
        if (onTap != null) {
          onTap();
        }
      },
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

  Widget buildButton(VoidCallback onTap, {color, text}) {
    return Container(
      margin: SizeUtil.margin(top: 20),
      child: MaterialButton(
        onPressed: onTap,
        color: color ?? BeeColors.blue,
        minWidth: SizeUtil.width(300),
        height: SizeUtil.width(45),
        shape: RoundedRectangleBorder(
          side: BorderSide.none,
          borderRadius: SizeUtil.radius(all: 100),
        ),
        child: Text(
          '${text}',
          style: StyleUtil.textStyle(size: 14, color: Colors.white),
        ),
      ),
    );
  }

  Widget buildCardX(Widget child) {
    return Card(
      elevation: 0,
      margin: SizeUtil.margin(left: 15, right: 15, top: 7, bottom: 7),
      child: Container(
        padding: SizeUtil.padding(left: 10, right: 10),
        width: SizeUtil.screenWidth(),
        child: child,
      ),
    );
  }
}

class CustomAnimation extends EasyLoadingAnimation {
  CustomAnimation();

  @override
  Widget buildWidget(
    Widget child,
    AnimationController controller,
    AlignmentGeometry alignment,
  ) {
    return Opacity(
      opacity: 0.3,
      child: RotationTransition(
        turns: controller,
        child: child,
      ),
    );
  }
}
