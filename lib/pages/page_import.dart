import 'package:cube/core/base_widget.dart';
import 'package:cube/core/constant.dart';
import 'package:cube/core/core.dart';
import 'package:cube/models/model_base.dart';
import 'package:cube/pages/page_chain_one.dart';
import 'package:cube/pages/page_landing.dart';
import 'package:cube/pages/page_scan.dart';
import 'package:cube/utils/utils_console.dart';
import 'package:cube/utils/utils_db.dart';
import 'package:cube/utils/utils_size.dart';
import 'package:cube/utils/utils_sp.dart';
import 'package:cube/views/appbar/appbar.dart';
import 'package:cube/views/dialog/dialog_pass_board.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PageImport extends StatefulWidget {
  const PageImport({Key key}) : super(key: key);

  @override
  _PageImportState createState() => _PageImportState();
}

class _PageImportState extends ViewState<PageImport> {
  int importType = 1;

  bool showCheckPass = false;
  String token = "";
  TextEditingController _nameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _password2Controller = TextEditingController();
  TextEditingController _mnemonicController = TextEditingController();
  bool showMnemonicClear = true;
  bool showNameClear = false;
  bool showPassClear = false;
  bool showPass2Clear = false;

  List<Coin> _chains = [];
  bool _needShowTips = true;
  Auth _auth;

  @override
  void initState() {
    super.initState();
    importType = Get.arguments['importType'];

    _nameController.text = "";
    initToken();
  }

  initToken() async {
    var result = await DBHelper.create().queryAuth();
    console.i(["InitToken", result]);
    setState(() {
      if (result != null) {
        _auth = result;
        showCheckPass = false;
        token = _auth.password;
      } else {
        showCheckPass = true;
      }
    });
  }

  @override
  Widget createView(BuildContext context) {
    var scanIcon = AssetImage("assets/icons/icon_scan.png");

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
            "WalletImport".tr,
            style: Theme.of(context).primaryTextTheme.headline3,
          ),
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: ImageIcon(scanIcon),
                onPressed: () async {
                  Get.to(ScanCodePage(
                    callback: (barcode) async {
                      barcode = barcode.trim();
                      if (!strIsEmpty(barcode)) {
                        if (barcode.indexOf(" ") <= 0) {
                          if (!barcode.startsWith("0x")) {
                            barcode = '0x$barcode';
                          }
                        }
                        _mnemonicController.text = barcode;
                      }
                    },
                  ));
                },
              ),
            ),
          ],
        ),
        body: Container(
          height: SizeUtil.screenHeight(),
          width: SizeUtil.screenWidth(),
          child: Column(
            children: [
              buildCardX(buildTextArea2('WalletMneOrPri'.tr, _mnemonicController, callback: (text) {},
                  suffixIcon: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      _mnemonicController.clear();
                    },
                  ))),
              buildCardX(buildInput('WalletName'.tr, _nameController)),
              _auth == null
                  ? buildCardX(buildPassword('CommonPassword'.tr, _passwordController, clicker: () {
                      if (_needShowTips) {
                        _needShowTips = false;
                        showTipsBar("WalletPwdKeepTip".tr, duration: Duration(seconds: 5));
                      }
                    }))
                  : SizedBox(
                      width: 0,
                      height: 0,
                    ),
              showCheckPass
                  ? Container(
                      margin: SizeUtil.margin(left: 20),
                      width: SizeUtil.screenWidth(),
                      child: Text(
                        'CommonPwdInputTip'.tr,
                        style: TextStyle(color: BeeColors.blue),
                        textAlign: TextAlign.start,
                      ),
                    )
                  : Container(
                      width: 0,
                      height: 0,
                    ),
              showCheckPass
                  ? buildCardX(buildPassword('CommonCheckPwd'.tr, _password2Controller))
                  : SizedBox(
                      width: 0,
                      height: 0,
                    ),
              Spacer(),
              Container(
                padding: SizeUtil.padding(left: 30, right: 30, bottom: 30),
                child: buildButton(() {
                  if (_auth == null) {
                    if (strIsEmpty(_nameController.text)) {
                      showWarnBar('WalletNameInputTip'.tr);
                      return;
                    }
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
                        });
                  }
                }, text: 'CommonImport'.tr),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _commit(bool check, {String pass}) async {
    String content = _mnemonicController.text;
    if (strIsEmpty(_mnemonicController.text)) {
      showWarnBar("WalletInputMnePriTip".tr);
      return;
    }
    if (strIsEmpty(_nameController.text)) {
      showWarnBar("WalletNameInputTip".tr);
      return;
    }
    if (!check) {
      if (strIsEmpty(_passwordController.text) || _passwordController.text.length != 6) {
        showWarnBar("CommonPwdInputTip".tr);
        return;
      }
      pass = getTokenId(_passwordController.text);
      if (showCheckPass) {
        if (_passwordController.text != _password2Controller.text) {
          showWarnBar("CommonPwdErrorTip".tr);
          return;
        }
        showLoading();
        DBHelper.create().insertAuth(Auth().parser({"type": "pass", "password": pass}));
      } else {
        if (pass != token) {
          showWarnBar("CommonPwdError".tr);
          return;
        }
      }
    } else {
      if (strIsEmpty(pass)) {
        showWarnBar('CommonPwdInputTip'.tr);
        return;
      }
    }

    showLoading(show: false);

    var result = await Get.to(PageChainOne(), arguments: {'type': "import"});
    if (result == null) {
      showWarnBar("WalletSelectImportMain".tr);
      return;
    }
    showLoading();
    _chains = result['chains'];
    List<Coin> allChains = [];
    List<Coin> tronChains = [];
    for (var chain in _chains) {
      if (chain.contract.isNotEmpty && chain.contract == "TRX") {
        tronChains.add(chain);
      } else {
        allChains.add(chain);
      }
    }

    String wid = generateId();
    String tokenType = 'private';
    content = content.trim();
    String identityToken = content;

    if (content.length == 64) {
      content = '0x${content}';
    }
    String privateKey = "";
    try {
      if (content.startsWith("0x")) {
        privateKey = content;
        if (allChains.length > 0) {
          if (privateKey.isNotEmpty) {
            await saveCoins(context, wid, allChains, needRequest: true, privateKey: content, pass: pass);
          }
        }
        if (tronChains.length > 0) {
          if (privateKey.isNotEmpty) {
            await saveCoins(context, wid, tronChains, needRequest: true, privateKey: content, pass: pass);
          }
        }
      } else {
        tokenType = 'mnemonic';
        if (allChains.length > 0) {
          privateKey = await getPrivateKeyFromMnemonic(context, allChains, identityToken);
          await saveCoins(context, wid, allChains, needRequest: true, mnemonic: content, pass: pass);
        }
        if (tronChains.length > 0) {
          privateKey = await getPrivateKeyFromMnemonic(context, tronChains, identityToken);
          await saveCoins(context, wid, tronChains, needRequest: true, mnemonic: content, pass: pass);
        }
      }

      await _saveIdentity("all", wid, identityToken, privateKey, pass, tokenType, allChains);
      SPUtils().put(Constant.CUSTOM_WID, wid);
      Get.offAll(PageLanding(), arguments: {"action": "refresh"});
    } catch (e) {
      showLoading(show: false);
    }
  }

  _saveIdentity(String type, String wid, String token, String privateKey, String pass, String tokenType, List<Coin> chains) async {
    String mnemonicToken = await encrypt(token, pass);
    privateKey = await encrypt(privateKey, pass);
    Identity identity = Identity().parser({
      "color": "",
      "wid": wid,
      "name": _nameController.text,
      "type": type,
      "token": mnemonicToken,
      "privateKey": privateKey,
      "tokenType": tokenType,
      "isImport": 0,
      "isBackup": 1
    });
    return await DBHelper.create().insertIdentity(identity);
  }
}
