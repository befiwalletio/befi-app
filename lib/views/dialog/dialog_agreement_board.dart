import 'dart:convert';
import 'dart:io';

import 'package:cube/core/base_widget.dart';
import 'package:cube/core/constant.dart';
import 'package:cube/core/core.dart';
import 'package:cube/utils/utils_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DialogAgreementBoard extends StatefulWidget {
  final BoolCallback callback;

  const DialogAgreementBoard({Key key, this.callback}) : super(key: key);

  @override
  _DialogAgreementBoardState createState() => _DialogAgreementBoardState();
}

class _DialogAgreementBoardState extends SizeState<DialogAgreementBoard> {
  bool _isX5View;
  String _url;
  bool _checked = false;

  WebViewController _iosViewController;
  JavascriptChannel jhostChannel;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      _isX5View = true;
    } else {
      _isX5View = false;
    }
    _url = !strIsEmpty(Global.PAGE_AGREEMENT) ? Global.PAGE_AGREEMENT : 'https://h5.beefinance.pro/agreement';
  }

  @override
  Widget createView(BuildContext context) {
    return GestureDetector(
        child: IntrinsicHeight(
      child: Stack(
        children: [
          Positioned(
              top: SizeUtil.height(100),
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: SizeUtil.padding(left: 0, right: 0, bottom: 40, top: 20),
                width: SizeUtil.screenWidth(),
                decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(6.0), topRight: Radius.circular(6.0))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: Text(
                        "Mine_Protocol".tr,
                        style: Theme.of(context).primaryTextTheme.subtitle1,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: SizeUtil.screenWidth(),
                        margin: SizeUtil.margin(all: 14, right: 14),
                        padding: SizeUtil.padding(all: 10),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(6.0))),
                        child: _createWebView(),
                      ),
                    ),
                    Container(
                      margin: SizeUtil.margin(left: 30, right: 30),
                      width: SizeUtil.screenWidth(),
                      child: Row(
                        children: [
                          Checkbox(
                              value: _checked,
                              onChanged: (value) {
                                setState(() {
                                  _checked = value;
                                });
                              }),
                          Text("CommonAgreementAgree".tr),
                        ],
                      ),
                    ),
                    Container(
                      margin: SizeUtil.margin(left: 30, right: 30),
                      child: Material(
                        color: BeeColors.blue,
                        borderRadius: BorderRadius.circular(SizeUtil.width(50)),
                        child: InkWell(
                          onTap: () {
                            _commit();
                          },
                          borderRadius: BorderRadius.circular(SizeUtil.width(50)),
                          child: Container(
                            alignment: Alignment.center,
                            width: SizeUtil.screenWidth(),
                            height: SizeUtil.height(35),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(SizeUtil.width(50))),
                            child: Text(
                              'CommonConfirm1'.tr,
                              style: TextStyle(fontSize: SizeUtil.sp(16), color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ))
        ],
      ),
    ));
  }

  Widget _createWebView() {
    Widget webview = WebView(
      initialUrl: _url,
      javascriptMode: JavascriptMode.unrestricted,
      javascriptChannels: <JavascriptChannel>[].toSet(),
      onWebViewCreated: (WebViewController web) {
        _iosViewController = web;
      },
      onPageFinished: (url) {},
    );
    return webview;
  }

  void _commit() {
    if (!_checked) {
      showWarnBar("CommonAgreementTip".tr);
      return;
    }
    if (widget.callback != null) {
      widget.callback(_checked);
    }
  }
}
