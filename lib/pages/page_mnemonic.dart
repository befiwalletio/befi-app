import 'dart:math';

import 'package:cube/chain/chaincore.dart';
import 'package:cube/core/base_widget.dart';
import 'package:cube/core/constant.dart';
import 'package:cube/core/core.dart';
import 'package:cube/models/model_base.dart';
import 'package:cube/pages/page_landing.dart';
import 'package:cube/utils/utils_console.dart';
import 'package:cube/utils/utils_db.dart';
import 'package:cube/utils/utils_size.dart';
import 'package:cube/utils/utils_sp.dart';
import 'package:cube/views/appbar/appbar.dart';
import 'package:cube/views/dialog/dialog_copy_board.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PageMnemonic extends StatefulWidget {
  const PageMnemonic({Key key}) : super(key: key);

  @override
  _PageMnemonicState createState() => _PageMnemonicState();
}

class _PageMnemonicState extends SizeState<PageMnemonic> {
  int start = 1;
  int step = 1;
  String _buttonText;
  num _mnemonicTextWidget = 0;
  num _mnemonicTextHeight = 0;
  Map<String, Map<String, dynamic>> _waitChecks = {};
  String _mnemonic = '';
  List<String> _mnemonics = [];
  List<String> _mnemonicsTemp = [];
  List<String> _mnemonicsKeep = [];
  List<Coin> _chains = [];

  bool isContinue = true;

  String _type;
  String _pass;

  String _walletId;
  String _name;

  @override
  void initState() {
    super.initState();
    _name = Get.arguments['name'] != null ? Get.arguments['name'] : "";
    _type = Get.arguments['type'] != null ? Get.arguments['type'] : "normal";
    _walletId = Get.arguments['walletId'] != null ? Get.arguments['walletId'] : "";
    _pass = Get.arguments['pass'] != null ? Get.arguments['pass'] : "";
    _chains = Get.arguments['chains'] != null ? Get.arguments['chains'] : [];
    if (_type == "create") {
      start = 1;
      _generateMnemonic();
    } else {
      start = 1;
      if (strIsEmpty(_pass) || strIsEmpty(_walletId)) {
        Get.back();
        return;
      }
      String mnemonic = Get.arguments['mnemonic'];
      _mnemonic = mnemonic;
    }
    step = start;
    int one = Random().nextInt(6);
    int two = Random().nextInt(6) + 6;
    _waitChecks = {
      '$one': {"value": '', "status": false},
      '$two': {"value": '', "status": false},
    };
  }

  @override
  Widget createView(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        int tempStep = step;
        tempStep--;
        if (tempStep < start) {
          Get.back();
          return Future.value(false);
        }
        setState(() {
          step = tempStep;
        });
        return Future.value(false);
      },
      child: Scaffold(
        appBar: XAppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_outlined),
            onPressed: () {
              Get.back();
            },
          ),
          title: Text("WalletMnemonic".tr),
        ),
        body: Container(
          height: SizeUtil.screenHeight(),
          child: Stack(
            children: [
              _checkStep(),
              Positioned(
                  bottom: SizeUtil.height(40),
                  left: SizeUtil.width(30),
                  right: SizeUtil.width(30),
                  child: Container(
                    child: _createButton(),
                  ))
            ],
          ),
        ),
      ),
    );
  }

  _generateMnemonic() async {
    var chain = new Chain(chain: "ETH");
    String _mnemonic01 = await chain.getMnemonic();
    String randomId = generateId();
    showLoading(show: false);
    setState(() {
      _mnemonic = _mnemonic01;
      _walletId = randomId;
    });
    await showDialog(
        context: context,
        useSafeArea: false,
        builder: (BuildContext context) {
          return DialogCopyBoard();
        });
  }

  Widget _createButton() {
    if (step == 2) {
      return Container();
    }
    return MaterialButton(
        color: BeeColors.blue,
        minWidth: SizeUtil.width(300),
        height: SizeUtil.width(45),
        shape: RoundedRectangleBorder(
          side: BorderSide.none,
          borderRadius: SizeUtil.radius(all: 100),
        ),
        child: Text(
          _buttonText,
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () async {
          if (step == 1 && _type != 'create') {
            Get.back();
            return;
          }
          setState(() {
            step++;
          });
        });
  }

  List<Widget> _createMnemonicTexts() {
    if (_mnemonicTextWidget == 0) {
      _mnemonicTextWidget = (SizeUtil.screenWidth() - SizeUtil.width(70)) / 3;
      _mnemonicTextHeight = SizeUtil.height(40);
    }
    List<Widget> widgets = [];
    try {
      _mnemonics = _mnemonic.split(" ");
      _mnemonicsTemp = _mnemonic.split(" ");
      _mnemonicsKeep = [];
      _mnemonics.forEachWithIndex((index, element) {
        var createMnemonicText = _createMnemonicText(index, element);
        if (createMnemonicText is Widget) {
          widgets.add(createMnemonicText);
        }
      });
    } catch (e) {
      console.e(e);
    }
    return widgets;
  }

  Widget _createMnemonicText(index, text) {
    if (text is String) {
      text = text.trim();
      if (text != '') {
        if (_waitChecks.containsKey('$index')) {
          _waitChecks['$index']['value'] = text;
        }
        return Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(width: 1, color: Colors.grey)),
          ),
          margin: SizeUtil.margin(all: 2),
          width: _mnemonicTextWidget,
          height: _mnemonicTextHeight,
          child: Stack(
            children: [
              Center(
                child: Text(
                  text,
                  style: Theme.of(context).primaryTextTheme.headline3,
                  textAlign: TextAlign.center,
                ),
              ),
              Positioned(
                  top: SizeUtil.height(5),
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(color: Colors.grey),
                  ))
            ],
          ),
        );
      }
    }
    return null;
  }

  Widget _checkStep() {
    if (step == 1) {
      _buttonText = "WalletBackupFinish".tr;
      return _createMnemonicContainer(_createMnemonicTexts());
    }
    if (step == 2) {
      _buttonText = "CommonVerfity".tr;
      return _createCheckMnemonic();
    }
    return Container();
  }

  Widget _createCheckMnemonic() {
    String checkIndex = "";
    int checkIndexInt = 0;
    _waitChecks.forEach((key, value) {
      if (!value['status']) {
        checkIndex = key;
        try {
          checkIndexInt = int.parse(key);
        } catch (e) {
          print(e);
        }
        return;
      }
    });

    return Container(
      padding: SizeUtil.padding(left: 30, right: 30, top: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            child: Text(
              "WalletMneVerify".tr,
              style: Theme.of(context).primaryTextTheme.headline3,
            ),
          ),
          Container(
            margin: SizeUtil.margin(top: 30, bottom: 30),
            padding: SizeUtil.padding(all: 30),
            decoration: BoxDecoration(
              border: new Border.all(
                color: Colors.grey[100],
                width: .1,
              ),
              color: Colors.grey[100],
              boxShadow: [
                BoxShadow(
                  offset: Offset(0, 5),
                  blurRadius: 10,
                  spreadRadius: 0.1,
                  color: Colors.grey[350],
                ),
              ],
              borderRadius: SizeUtil.radius(all: 5),
            ),
            child: Text(
              "WalletMneNumber".tr.replaceAll("{%s}", '${checkIndexInt + 1}'),
              style: Theme.of(context).primaryTextTheme.headline3,
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: SizeUtil.padding(top: 10, bottom: 10),
            child: Text(
              "* ${"WalletMneSafeTip1".tr}",
              style: Theme.of(context).primaryTextTheme.subtitle1,
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: SizeUtil.padding(top: 10, bottom: 10),
            child: Text(
              "* ${"WalletMneSafeTip".tr}",
              style: Theme.of(context).primaryTextTheme.subtitle1,
            ),
          ),
          Container(
            child: Wrap(
              children: _createCheckButton(checkIndex),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _createCheckButton(checkIndex) {
    List<Widget> items = [];
    for (int i = 0; i < _mnemonics.length; i++) {
      String value;
      if (_mnemonicsKeep.length != 12) {
        value = _popMnemonics();
        _mnemonicsKeep.add(value);
      } else {
        value = _mnemonicsKeep[i];
      }
      items.add(Padding(
        padding: SizeUtil.padding(all: 5),
        child: MaterialButton(
          height: SizeUtil.height(35),
          minWidth: SizeUtil.width(15),
          color: Colors.white,
          textColor: Colors.grey,
          child: Text(
            "$value",
            style: Theme.of(context).primaryTextTheme.headline4,
          ),
          onPressed: () async {
            if (isContinue) {
              if (_waitChecks[checkIndex]['value'] == value) {
                await _commit(checkIndex);
              } else {
                showWarnBar("WalletSelectCorrentWord".tr);
              }
            }
          },
        ),
      ));
    }
    return items;
  }

  _commit(checkIndex) async {
    _waitChecks[checkIndex]['status'] = true;
    bool isCheckedAll = true;
    _waitChecks.forEach((key, value) {
      if (!value['status']) {
        isCheckedAll = false;
      }
    });
    if (isCheckedAll) {
      isContinue = false;
      if (_type == 'create') {
        showLoading();

        List<Coin> allChains = [];
        List<Coin> tronChains = [];
        for (var chain in _chains) {
          if (chain.contract.isNotEmpty && chain.contract == "TRX") {
            tronChains.add(chain);
          } else {
            allChains.add(chain);
          }
        }
        await _saveIdentity("all");
        if (allChains.length > 0) {
          await saveCoins(context, _walletId, allChains, needRequest: true, mnemonic: _mnemonic, pass: _pass);
        }
        if (tronChains.length > 0) {
          await saveCoins(context, _walletId, tronChains, needRequest: true, mnemonic: _mnemonic, pass: _pass);
        }

        SPUtils().put(Constant.CUSTOM_WID, _walletId);

        Future.delayed(Duration(milliseconds: 2000), () {
          showLoading(show: false);
          Get.offAll(PageLanding(), arguments: {"action": "refresh", "wid": _walletId});
        });
      } else {
        Get.back();
      }
      return;
    }

    setState(() {
      _waitChecks[checkIndex]['status'] = true;
    });
  }

  _saveIdentity(String type) async {
    String mnemonicToken = await encrypt(_mnemonic, _pass);
    String privateKey = await getPrivateKeyFromMnemonic(context, _chains, _mnemonic);
    privateKey = await encrypt(privateKey, _pass);
    Identity identity = Identity().parser({
      "color": "",
      "wid": _walletId,
      "name": _name,
      "type": type,
      "token": mnemonicToken,
      "privateKey": privateKey,
      "tokenType": "mnemonic",
      "isImport": 0,
      "isBackup": 1
    });
    return await DBHelper.create().insertIdentity(identity);
  }

  String _popMnemonics() {
    if (_mnemonicsTemp.length == 0) {
      return "";
    }
    int index = Random().nextInt(_mnemonicsTemp.length);
    return _mnemonicsTemp.removeAt(index);
  }

  Widget _createMnemonicContainer(List<Widget> body) {
    return Container(
      padding: SizeUtil.padding(left: 15, right: 15, top: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            child: Text(
              "WalletBackupMne".tr,
              style: Theme.of(context).primaryTextTheme.headline3,
            ),
          ),
          Container(
            child: Text(
              "WalletMneBuckupTip".tr,
              style: Theme.of(context).primaryTextTheme.headline4,
            ),
          ),
          Container(
            alignment: Alignment.center,
            margin: SizeUtil.margin(top: 15, bottom: 15),
            padding: SizeUtil.padding(all: 10),
            decoration: BoxDecoration(
              border: new Border.all(
                color: Colors.grey[100],
                width: .1,
              ),
              color: Colors.grey[100],
              boxShadow: [
                BoxShadow(
                  offset: Offset(0, 5),
                  blurRadius: 10,
                  spreadRadius: 0.1,
                  color: Colors.grey[350],
                ),
              ],
              borderRadius: SizeUtil.radius(all: 5),
            ),
            child: Wrap(
              children: body,
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: SizeUtil.padding(top: 10, bottom: 10),
            child: Text(
              "* ${"WalletMneSafeTip1".tr}",
              style: Theme.of(context).primaryTextTheme.subtitle1,
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: SizeUtil.padding(top: 10, bottom: 10),
            child: Text(
              "* ${"WalletMneSafeTip".tr}",
              style: Theme.of(context).primaryTextTheme.subtitle1,
            ),
          ),
        ],
      ),
    );
  }
}
