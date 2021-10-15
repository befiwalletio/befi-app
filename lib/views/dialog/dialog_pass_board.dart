import 'dart:math';

import 'package:cube/core/base_widget.dart';
import 'package:cube/core/core.dart';
import 'package:cube/utils/utils_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DialogPassBoard extends StatefulWidget {
  final StringCallback callback;
  final bool step;

  const DialogPassBoard({Key key, this.callback, this.step = false}) : super(key: key);

  @override
  _DialogPassBoardState createState() => _DialogPassBoardState();
}

class PassBoardController extends GetxController {
  var point = "⦾ ⦾ ⦾ ⦾ ⦾ ⦾".obs;
  var pointSize = 0.obs;

  changePoint(size) {
    pointSize.value = size;
  }
}

class _DialogPassBoardState extends SizeState<DialogPassBoard> {
  List<Widget> passGroups;
  List<String> _numbers = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  String _values = '';
  bool _showLoading = false;
  PassBoardController _passBoardController = Get.put(PassBoardController());

  @override
  void initState() {
    super.initState();
    _passBoardController.changePoint(0);
  }

  @override
  Widget createView(BuildContext context) {
    if (passGroups == null || passGroups.length == 0) {
      passGroups = _createPassGroups();
    }
    return GestureDetector(
        child: IntrinsicHeight(
      child: Stack(
        children: [
          Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: SizeUtil.padding(left: 0, right: 0, bottom: 0, top: 0),
                width: SizeUtil.screenWidth(),
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(6.0), topRight: Radius.circular(6.0))),
                child: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            padding: SizeUtil.padding(top: 10),
                            child: Text(
                              "CommonPassword".tr,
                              style: StyleUtil.textStyle(size: 18, color: Colors.black),
                            )),
                        Container(
                            width: SizeUtil.screenWidth(),
                            child: Stack(
                              children: [
                                Container(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: SizeUtil.screenWidth(),
                                        child: Stack(
                                          children: [
                                            Container(
                                              margin: SizeUtil.margin(top: 10, bottom: 10),
                                              alignment: Alignment.center,
                                              width: double.infinity,
                                              padding: SizeUtil.padding(top: 5, bottom: 5),
                                              child: Obx(() {
                                                List<Widget> items = [];
                                                int size = _passBoardController.pointSize.value;
                                                for (int i = 1; i <= 6; i++) {
                                                  items.add(Container(
                                                    margin: SizeUtil.margin(left: 5, right: 5),
                                                    child: Icon(
                                                      i <= size ? Icons.radio_button_checked : Icons.radio_button_off_outlined,
                                                      color: Colors.black,
                                                      size: SizeUtil.width(12),
                                                    ),
                                                  ));
                                                }
                                                return Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: items,
                                                );
                                              }),
                                            )
                                          ],
                                        ),
                                      ),
                                      passGroups[0],
                                      passGroups[1],
                                      passGroups[2],
                                      passGroups[3],
                                      Container(
                                        height: SizeUtil.height(30),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            )),
                      ],
                    ),
                  ],
                ),
              ))
        ],
      ),
    ));
  }

  String _popnum() {
    if (_numbers.length == 0) {
      _numbers = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    }
    if (_numbers.length == 1) {
      String value = _numbers[0];
      _numbers = [];
      return value;
    }
    var index = Random().nextInt(_numbers.length);
    String value = _numbers[index];
    _numbers.removeAt(index);
    return value;
  }

  List<Widget> _createPassGroups() {
    List<Widget> group1 = [];
    List<Widget> group2 = [];
    List<Widget> group3 = [];
    List<Widget> group4 = [];
    for (int i = 0; i < 10; i++) {
      String popnum = _popnum();
      Widget button = _createPassButton(popnum);
      if (i < 3) {
        group1.add(button);
      } else if (i < 6) {
        group2.add(button);
      } else if (i < 9) {
        group3.add(button);
      } else {
        group4.add(button);
      }
    }
    group4 = [_createPassButton('clean')]
      ..addAll(group4)
      ..add(_createPassButton('del'));
    return [
      Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: group1,
        ),
      ),
      Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: group2,
        ),
      ),
      Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: group3,
        ),
      ),
      Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: group4,
        ),
      ),
    ];
  }

  Widget _createPassButton(numstr) {
    num width = (SizeUtil.screenWidth() - SizeUtil.width(60)) / 3;
    return Container(
      margin: SizeUtil.margin(left: 1.5, right: 1.5, bottom: 0.5, top: 0.5),
      child: numstr == 'temp'
          ? Container(
              height: SizeUtil.height(30),
              width: width,
            )
          : Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (numstr == 'del') {
                    if (_values.length > 0) {
                      _values = _values.substring(0, _values.length - 1);
                      _passBoardController.changePoint(_values.length);
                      if (widget.step && widget.callback != null) {
                        widget.callback(_values);
                      }
                    }
                    return;
                  }
                  if (numstr == 'clean') {
                    _values = "";
                    _passBoardController.changePoint(0);
                    if (widget.step && widget.callback != null) {
                      widget.callback(_values);
                    }
                    return;
                  }
                  if (_values.length == 6) {
                    if (widget.callback != null) {
                      widget.callback(_values);
                    }
                    return;
                  }
                  _values = '$_values$numstr';
                  _passBoardController.changePoint(_values.length);
                  if (widget.callback != null) {
                    if (widget.step) {
                      widget.callback(_values);
                    } else if (_values.length == 6) {
                      if (widget.callback != null) {
                        widget.callback(_values);
                      }
                    }
                  }
                },
                child: Container(
                  alignment: Alignment.center,
                  padding: SizeUtil.padding(top: 15, bottom: 15),
                  width: width,
                  child: numstr == 'del'
                      ? Icon(Icons.backspace_outlined)
                      : Text(
                          "$numstr".tr,
                          style: StyleUtil.textStyle(size: 16, color: Colors.black),
                        ),
                ),
              ),
            ),
    );
  }

  _callback() {
    if (_values.length == 6) {}
  }
}
