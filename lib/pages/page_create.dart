import 'package:cube/core/base_widget.dart';
import 'package:cube/core/constant.dart';
import 'package:cube/core/core.dart';
import 'package:cube/models/model_base.dart';
import 'package:cube/pages/page_chain.dart';
import 'package:cube/utils/utils_db.dart';
import 'package:cube/utils/utils_size.dart';
import 'package:cube/views/appbar/appbar.dart';
import 'package:cube/views/dialog/dialog_pass_board.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PageCreate extends StatefulWidget {
  const PageCreate({Key key}) : super(key: key);

  @override
  _PageCreateState createState() => _PageCreateState();
}

class _PageCreateState extends ViewState<PageCreate> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _password2Controller = TextEditingController();

  bool _needShowTips = true;
  Auth _auth;

  @override
  void initState() {
    super.initState();
    _nameController.text = "";
    _passwordController.text = "";
    _password2Controller.text = "";

    _initData();
  }

  _initData() async {
    var data = await DBHelper().queryAuth();
    if (data is Auth) {
      setState(() {
        _auth = data;
      });
    }
  }

  @override
  Widget createView(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus.unfocus();
        }
      },
      onPanDown: (_) {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus.unfocus();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Get.isDarkMode ? Colors.black : Colors.grey[100],
        appBar: XAppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_outlined),
            onPressed: () {
              Get.back();
            },
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text(
            "WalletCreate".tr,
            style: Theme.of(context).primaryTextTheme.headline3,
          ),
        ),
        body: Stack(
          children: [
            Container(
              width: SizeUtil.screenWidth(),
              child: Column(
                children: _buildContent(),
              ),
            ),
            Positioned(
                left: SizeUtil.width(30),
                right: SizeUtil.width(30),
                bottom: SizeUtil.height(50),
                child: buildButton(() async {
                  if (strIsEmpty(_nameController.text)) {
                    showWarnBar('WalletNameInputTip'.tr);
                    return;
                  }
                  if (_auth == null) {
                    _commit(false);
                  } else {
                    showDialog(
                        useSafeArea: false,
                        context: context,
                        builder: (context) {
                          return DialogPassBoard(
                            callback: (text) {
                              String pass = getTokenId(text);
                              if (_auth.password != pass) {
                                showWarnBar("CommonPwdError".tr);
                                return;
                              }
                              Get.back();
                              _commit(true, pass: pass);
                            },
                          );
                        },
                    );
                  }
                }, text: '创建'.tr))
          ],
        ),
      ),
    );
  }

  List<Widget> _buildContent() {
    List<Widget> views = [buildCardX(buildInput('WalletName'.tr, _nameController))];
    if (_auth == null) {
      views.addAll([
        buildCardX(buildPassword('CommonPassword'.tr, _passwordController, clicker: () {
          if (_needShowTips) {
            _needShowTips = false;
            showTipsBar("WalletPwdKeepTip".tr, duration: Duration(seconds: 5));
          }
        })),
        Container(
          margin: SizeUtil.margin(left: 20),
          width: SizeUtil.screenWidth(),
          child: Text(
            'CommonPwdInputTip'.tr,
            style: TextStyle(color: BeeColors.blue),
            textAlign: TextAlign.start,
          ),
        ),
        buildCardX(buildPassword('CommonConfirmPwd'.tr, _password2Controller)),
      ]);
    }
    return views;
  }

  _commit(bool check, {String pass}) {
    if (!check) {
      if (strIsEmpty(_passwordController.text)) {
        showWarnBar('CommonPwdInputTip'.tr);
        return;
      }
      if (_passwordController.text != _password2Controller.text) {
        showWarnBar('CommonPwdErrorTip'.tr);
        return;
      }
      pass = getTokenId(_passwordController.text);
      DBHelper.create().insertAuth(Auth().parser({"type": "pass", "password": pass}));
    } else {
      if (strIsEmpty(pass)) {
        showWarnBar('CommonPwdInputTip'.tr);
        return;
      }
    }
    Get.off(PageChain(), arguments: {"name": _nameController.text, "type": "create", "pass": pass});
  }
}
