import 'package:cube/core/base_widget.dart';
import 'package:cube/views/web/view_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PageWeb extends StatefulWidget {
  const PageWeb({Key key}) : super(key: key);

  @override
  _PageWebState createState() => _PageWebState();
}

class _PageWebState extends SizeState<PageWeb> {
  String url = "";
  String title = "";

  @override
  void initState() {
    super.initState();
    url = Get.arguments['url'];
    title = Get.arguments['title'];
  }

  @override
  Widget createView(BuildContext context) {
    return Scaffold(
      body: XWebView(
        url,
        dapp: Get.arguments['dapp'],
        title: title,
      ),
    );
  }
}
