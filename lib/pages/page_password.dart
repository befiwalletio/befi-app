import 'package:cube/core/base_widget.dart';
import 'package:cube/core/core.dart';
import 'package:flutter/material.dart';
import 'package:cube/utils/utils_size.dart';
import 'package:cube/views/appbar/appbar.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class PagePassword extends StatefulWidget {
  const PagePassword({Key key}) : super(key: key);

  @override
  _PagePasswordState createState() => _PagePasswordState();
}

class _PagePasswordState extends SizeState<PagePassword> {
  String _mnemonic;
  String _walletId;
  String _name;

  TextEditingController _passController = TextEditingController();
  TextEditingController _passCheckController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _mnemonic = Get.arguments["mnemonic"];
    _walletId = Get.arguments["walletId"];
    _name = Get.arguments["name"];
  }

  @override
  Widget createView(BuildContext context) {
    return Scaffold(
      appBar: XAppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_outlined),
          onPressed: () {
            Get.back();
          },
        ),
        title: Text("WalletPwdSet".tr),
      ),
      body: Stack(
        children: [
          Container(
            padding: SizeUtil.padding(left: 30, right: 30, top: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  child: Text(
                    "$_name",
                    style: StyleUtil.textStyle(size: 50),
                  ),
                ),
                Container(
                  child: TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                        fillColor: Colors.blue.shade100,
                        filled: false,
                        labelText: 'WalletInputPwdTip'.tr,
                        labelStyle: StyleUtil.textStyle(size: 30, color: Colors.black26)),
                    style: StyleUtil.textStyle(size: 40, weight: FontWeight.bold),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                    maxLength: 6,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.left,
                    controller: _passController,
                  ),
                ),
                Container(
                  child: TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                        fillColor: Colors.blue.shade100,
                        filled: false,
                        labelText: 'WalletInputPwdAgain'.tr,
                        labelStyle: StyleUtil.textStyle(size: 30, color: Colors.orange)),
                    style: StyleUtil.textStyle(size: 40, weight: FontWeight.bold),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                    maxLength: 6,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.left,
                    controller: _passCheckController,
                  ),
                )
              ],
            ),
          ),
          Positioned(
              bottom: SizeUtil.height(40),
              left: SizeUtil.width(30),
              right: SizeUtil.width(30),
              child: Container(
                child: MaterialButton(
                    color: Colors.orange,
                    textColor: Colors.white,
                    padding: SizeUtil.padding(top: 20, bottom: 20),
                    minWidth: SizeUtil.screenWidth() - SizeUtil.width(60),
                    child: Text("CommonConfirm".tr),
                    onPressed: () async {
                      setState(() {
                        if (strIsEmpty(_passController.text)) {
                          showWarnBar("CommonPwdNoEmpty".tr);
                        }
                        if (_passController.text != _passCheckController.text) {
                          showWarnBar("CommonPwdErrorTip".tr);
                          return;
                        }
                      });
                    }),
              ))
        ],
      ),
    );
  }
}
