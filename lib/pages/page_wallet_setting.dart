import 'package:cube/chain/eth.dart';
import 'package:cube/chain/tron.dart';
import 'package:cube/core/base_widget.dart';
import 'package:cube/core/constant.dart';
import 'package:cube/core/core.dart';
import 'package:cube/models/model_base.dart';
import 'package:cube/pages/page_landing.dart';
import 'package:cube/pages/page_mnemonic.dart';
import 'package:cube/utils/utils_console.dart';
import 'package:cube/utils/utils_db.dart';
import 'package:cube/utils/utils_event.dart';
import 'package:cube/utils/utils_sp.dart';
import 'package:cube/views/dialog/dialog_copy_action.dart';
import 'package:cube/views/dialog/dialog_copy_board.dart';
import 'package:cube/views/dialog/dialog_input_board.dart';
import 'package:cube/views/dialog/dialog_pass_board.dart';
import 'package:cube/views/dialog/dialog_widget_board.dart';
import 'package:cube/views/setting_item.dart';
import 'package:flutter/material.dart';
import 'package:cube/utils/utils_size.dart';
import 'package:cube/views/appbar/appbar.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class PageWalletSetting extends StatefulWidget {
  const PageWalletSetting({Key key}) : super(key: key);

  @override
  _PageWalletSettingState createState() => _PageWalletSettingState();
}

class _PageWalletSettingState extends SizeState<PageWalletSetting> {
  Identity identity;
  bool hasMnemonic = true;
  bool hasKeystore = true;

  List<Coin> coinChain = [];

  @override
  void initState() {
    super.initState();
    identity = Get.arguments['identity'];
    hasMnemonic = identity.tokenType == 'mnemonic';
    hasKeystore = identity.tokenType == 'keystore';
  }

  void selectChain(int type) async {
    List<Coin> items = await DBHelper().queryCoins(identity.wid);
    if (items != null) {
      coinChain.clear();
      items.forEach((element) {
        if (element.contract == element.symbol) {
          coinChain.add(element);
        }
      });
      if (coinChain.length > 0) {
        selectChainAction(type);
      }
    }
  }

  @override
  Widget createView(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.isDarkMode ? Colors.black : Colors.grey[100],
      appBar: XAppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_outlined),
          onPressed: () {
            Get.back();
          },
        ),
        elevation: 0,
        title: Text("${identity != null ? identity.name : ''}"),
      ),
      body: Stack(
        children: [
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Divider(
                  height: 1,
                ),
                SettingItem(
                  left: Text(
                    "WalletNameFix".tr,
                    style: TextStyle(fontSize: SizeUtil.sp(14)),
                  ),
                  right: Icon(
                    Icons.arrow_forward_ios_sharp,
                    size: SizeUtil.width(15),
                  ),
                  onPressed: () {
                    showDialog(
                        useSafeArea: false,
                        context: context,
                        builder: (context) {
                          return DialogInputBoard(
                            title: "WalletNameFix".tr,
                            text: identity != null ? identity.name : "",
                            callback: (text) async {
                              if (strIsEmpty(text) || text == identity.name) {
                                return;
                              }
                              showLoading();
                              identity.name = text;
                              await DBHelper().updateIdentity(identity);
                              showLoading(show: false);
                              eventBus.fire(UpdateWallet());
                              Get.back(result: {"action": 'refresh'});
                            },
                          );
                        });
                  },
                ),
                Divider(
                  height: 1,
                ),
                SettingItem(
                  left: Text("WalletCheckPrivate".tr, style: TextStyle(fontSize: SizeUtil.sp(14))),
                  right: Icon(Icons.arrow_forward_ios_sharp, size: SizeUtil.width(15)),
                  onPressed: () async {
                    selectChain(1);
                  },
                ),
                Divider(
                  height: 1,
                ),
                SettingItem(
                  left: Text("Keystore_File_See".tr, style: TextStyle(fontSize: SizeUtil.sp(14))),
                  right: Icon(Icons.arrow_forward_ios_sharp, size: SizeUtil.width(15)),
                  onPressed: () async {
                    selectChain(2);
                  },
                ),
                !hasMnemonic
                    ? Container(
                        height: 0,
                      )
                    : Divider(
                        height: 1,
                      ),
                !hasMnemonic
                    ? Container(
                        height: 0,
                      )
                    : SettingItem(
                        left: Text("WalletMneCheck".tr, style: TextStyle(fontSize: SizeUtil.sp(14))),
                        right: Icon(Icons.arrow_forward_ios_sharp, size: SizeUtil.width(15)),
                        onPressed: () async {
                          showDialog(
                              useSafeArea: false,
                              context: context,
                              builder: (context) {
                                return DialogPassBoard(callback: (text) async {
                                  String pass = getTokenId(text);
                                  var auth = await DBHelper().queryAuth();
                                  if (pass != auth.password) {
                                    showWarnBar("CommonPwdError".tr);
                                    return;
                                  }
                                  String result = await decrypt(identity.token, pass);
                                  Get.back();
                                  await showDialog(
                                      useSafeArea: false,
                                      context: context,
                                      builder: (context) {
                                        return DialogCopyBoard();
                                      });
                                  Get.to(PageMnemonic(), arguments: {"walletId": identity.wid, "pass": pass, "mnemonic": result, "type": "check"});
                                });
                              });
                        },
                      ),
                SizedBox(
                  height: SizeUtil.height(10),
                ),
                SettingItem(
                  left: Text("WalletDelete".tr, style: TextStyle(fontSize: SizeUtil.sp(14), color: Colors.red)),
                  right: Icon(Icons.arrow_forward_ios_sharp, size: SizeUtil.width(15)),
                  onPressed: () async {
                    showDialog(
                        useSafeArea: false,
                        context: context,
                        builder: (context) {
                          return DialogPassBoard(
                            callback: (text) async {
                              String pass = getTokenId(text);
                              var auth = await DBHelper().queryAuth();
                              if (pass != auth.password) {
                                showWarnBar("CommonPwdError".tr);
                                return;
                              }
                              Get.back();
                              showLoading();
                              await DBHelper().deleteIdentity(identity);
                              String wid = SPUtils().get(Constant.CUSTOM_WID);
                              if (wid == identity.wid) {
                                wid = "";
                                var item = await DBHelper().queryIdentity("0");
                                if (item != null) {
                                  wid = item.wid;
                                }
                                SPUtils().put(Constant.CUSTOM_WID, wid);
                              }
                              showLoading(show: false);
                              Get.offAll(PageLanding());
                            },
                          );
                        });
                  },
                ),
                Container(
                  padding: SizeUtil.padding(all: 20),
                  alignment: Alignment.center,
                  child: InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: identity.wid ?? ''));
                      showTipsBar("CommonCopyTip".tr);
                    },
                    child: Text("id:${identity != null ? identity.wid : ''}", style: TextStyle(fontSize: SizeUtil.sp(14), color: Colors.grey)),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  void selectChainAction(int type) {
    showDialog(
        useSafeArea: false,
        context: context,
        builder: (context) {
          return DialogWidgetBoard(
            child: Container(
              child: Column(
                children: createChainList(type),
              ),
            ),
          );
        });
  }

  List<Widget> createChainList(int type) {
    List<Widget> items = [];
    for (int i = 0; i < coinChain.length; i++) {
      Coin item = coinChain[i];
      String chainName = "";
      if (item.contract == "ETH") {
        chainName = "Ethereum";
      } else if (item.contract == "BNB") {
        chainName = "BSC";
      } else if (item.contract == "MATIC") {
        chainName = "Polygon";
      } else if (item.contract == "TRUE") {
        chainName = "TrueChain";
      } else if (item.contract == "TRX") {
        chainName = "Tron";
      }
      items.add(InkWell(
        onTap: () async {
          Get.back();
          if (type == 1) {
            showPrivateAction(item.contract);
          } else if (type == 2) {
            showKeystoreAction(item.contract);
          } else if (type == 3) {
            showMnemonicAction();
          }
        },
        child: Container(
          height: SizeUtil.height(40),
          child: Center(
            child: Text(chainName, style: Theme.of(context).primaryTextTheme.bodyText1),
          ),
        ),
      ));
      items.add(Divider(
        height: 1,
        color: Colors.grey[100],
      ));
    }
    items.add(
      InkWell(
        onTap: () async {
          Get.back();
        },
        child: Container(
          height: SizeUtil.height(40),
          child: Center(
            child: Text("Common_Cancel".tr, style: Theme.of(context).primaryTextTheme.bodyText1),
          ),
        ),
      ),
    );
    return items;
  }

  showPrivateAction(String contract) {
    showDialog(
        useSafeArea: false,
        context: context,
        builder: (context) {
          return DialogPassBoard(callback: (text) async {
            String pass = getTokenId(text);
            var auth = await DBHelper().queryAuth();
            if (pass != auth.password) {
              showWarnBar("CommonPwdError".tr);
              return;
            }
            String result = await decrypt(identity.token, pass);
            if (contract.toUpperCase() == "TRX") {
              if (hasMnemonic) {
                TRX tron = TRX();
                result = await tron.getPrivateKey(mnemonic: result);
              } else if (hasKeystore) {
                showWarnBar("WalletTronPrivateNo".tr);
                Get.back();
                return;
              } else {
                Coin tron = await DBHelper().queryChainCoin(identity.wid, "TRX", "TRX");
                if (tron != null) {
                  result = await decrypt(tron.privateKey, pass);
                  if (result == null) {
                    showWarnBar("WalletTronPrivateNo".tr);
                    Get.back();
                    return;
                  }
                } else {
                  showWarnBar("WalletTronPrivateNo".tr);
                  Get.back();
                  return;
                }
              }
            } else {
              if (hasMnemonic) {
                ETH eth = ETH();
                result = await eth.getPrivateKey(mnemonic: result);
              } else if (hasKeystore) {
                result = await decrypt(identity.privateKey, pass);
              } else {}
            }

            console.i(result);
            Get.back();
            showDialog(
                useSafeArea: false,
                context: context,
                builder: (context) {
                  return DialogCopyAction(
                    title: "WalletPrivate".tr,
                    text: result,
                    callback: (text) {
                      Get.back();
                      Clipboard.setData(ClipboardData(text: text));
                      showTipsBar("CommonCopyTip".tr);
                    },
                  );
                });
          });
        });
  }

  showKeystoreAction(String contract) {
    showDialog(
        useSafeArea: false,
        context: context,
        builder: (context) {
          return DialogPassBoard(callback: (text) async {
            String pass = getTokenId(text);
            var auth = await DBHelper().queryAuth();
            if (pass != auth.password) {
              showWarnBar("CommonPwdError".tr);
              return;
            }
            if (contract.toUpperCase() == "TRX") {
              showWarnBar("WalletTronKeystoreNo1".tr);
              Get.back();
              return;
            }

            showLoading();
            String privatekey = await decrypt(identity.privateKey, pass);
            String result = await getKeystoreFromPrivateKey(context, ETH(), privatekey, text);
            console.i(result);
            showLoading(show: false);
            Get.back();
            showDialog(
                useSafeArea: false,
                context: context,
                builder: (context) {
                  return DialogCopyAction(
                    title: "Import_Keystore".tr,
                    text: result,
                    callback: (text) {
                      Get.back();
                      Clipboard.setData(ClipboardData(text: text));
                      showTipsBar("CommonCopyTip".tr);
                    },
                  );
                });
          });
        });
  }

  showMnemonicAction() {
    showDialog(
        useSafeArea: false,
        context: context,
        builder: (context) {
          return DialogPassBoard(callback: (text) async {
            String pass = getTokenId(text);
            var auth = await DBHelper().queryAuth();
            if (pass != auth.password) {
              showWarnBar("CommonPwdError".tr);
              return;
            }
            String result = await decrypt(identity.token, pass);
            Get.back();
            await showDialog(
                useSafeArea: false,
                context: context,
                builder: (context) {
                  return DialogCopyBoard();
                });
            Get.to(PageMnemonic(), arguments: {"walletId": identity.wid, "pass": pass, "mnemonic": result, "type": "check"});
          });
        });
  }
}
