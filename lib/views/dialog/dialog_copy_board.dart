import 'dart:math';

import 'package:cube/core/base_widget.dart';
import 'package:cube/core/constant.dart';
import 'package:cube/utils/utils_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DialogCopyBoard extends StatefulWidget {
  const DialogCopyBoard({Key key}) : super(key: key);

  @override
  _DialogCopyBoardState createState() => _DialogCopyBoardState();
}

class CopyBoardController extends GetxController {
  var dismiss = true.obs;

  onDismiss() => {dismiss.value = false, dismiss.refresh()};

  onShow() => {dismiss.value = true, dismiss.refresh()};
}

class _DialogCopyBoardState extends SizeState<DialogCopyBoard> {
  CopyBoardController boardController;

  @override
  void initState() {
    super.initState();
    try {
      boardController = Get.find(tag: "CopyBoard");
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget createView(BuildContext context) {
    boardController?.onShow();
    return GestureDetector(
        child: IntrinsicHeight(
      child: Stack(
        children: [
          Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: SizeUtil.padding(left: 0, right: 0, bottom: 20, top: 10),
                width: SizeUtil.screenWidth(),
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(6.0), topRight: Radius.circular(6.0))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      margin: SizeUtil.margin(left: 15, right: 15),
                      padding: SizeUtil.padding(top: 5),
                      child: Card(
                        elevation: 5,
                        color: Colors.white,
                        child: Column(
                          children: [
                            Container(
                              margin: SizeUtil.margin(top: 15, bottom: 10),
                              width: SizeUtil.width(60),
                              height: SizeUtil.width(60),
                              decoration: BoxDecoration(
                                borderRadius: SizeUtil.radius(all: 40),
                                border: Border.all(width: SizeUtil.width(5), style: BorderStyle.solid, color: Colors.orange),
                              ),
                              child: Icon(
                                Icons.no_photography_rounded,
                                size: SizeUtil.width(45),
                                color: Colors.orange,
                              ),
                            ),
                            Container(
                                child: Text(
                              "WalletNoShot".tr,
                              style: StyleUtil.textStyle(size: 18, color: Colors.black),
                            )),
                            Container(
                                margin: SizeUtil.margin(left: 30, right: 30, top: 10, bottom: 10),
                                alignment: Alignment.center,
                                child: Text(
                                  "WalletMneSafeTip5".tr,
                                  textAlign: TextAlign.center,
                                  style: StyleUtil.textStyle(size: 14, color: Colors.black),
                                )),
                          ],
                        ),
                      ),
                    ),
                    Container(width: SizeUtil.screenWidth(), child: Container()),
                    Container(
                      margin: SizeUtil.margin(left: 30, right: 30, top: 30),
                      child: MaterialButton(
                          color: BeeColors.blue,
                          minWidth: SizeUtil.width(300),
                          height: SizeUtil.width(45),
                          shape: RoundedRectangleBorder(
                            side: BorderSide.none,
                            borderRadius: SizeUtil.radius(all: 100),
                          ),
                          child: Text(
                            "WalletIGet".tr,
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            Get.back();
                          }),
                    ),
                  ],
                ),
              ))
        ],
      ),
    ));
  }

  @override
  void dispose() {
    super.dispose();
    boardController?.onDismiss();
  }
}
