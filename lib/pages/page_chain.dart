import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cube/core/base_widget.dart';
import 'package:cube/core/constant.dart';
import 'package:cube/core/core.dart';
import 'package:cube/models/model_base.dart';
import 'package:cube/models/model_home.dart';
import 'package:cube/net/manager_api.dart';
import 'package:cube/net/requester.dart';
import 'package:cube/pages/page_mnemonic.dart';
import 'package:cube/utils/utils_db.dart';
import 'package:cube/utils/utils_event.dart';
import 'package:cube/utils/utils_size.dart';
import 'package:cube/views/appbar/appbar.dart';
import 'package:cube/views/dialog/dialog_pass_board.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:get/get.dart';

class PageChain extends StatefulWidget {
  const PageChain({Key key}) : super(key: key);

  @override
  _PageChainState createState() => _PageChainState();
}

class _PageChainState extends SizeState<PageChain> {
  List<Coin> chains = [];
  String name;
  String pass;
  String wid;
  String type = 'create'; //create import append
  String title = "";
  int selectCount = 0;

  EasyRefreshController _refreshController = EasyRefreshController();

  @override
  void initState() {
    super.initState();
    title = "WalletSelectMainChain".tr;
    name = Get.arguments['name'];
    pass = Get.arguments['pass'];
    wid = Get.arguments['wid'];
    type = Get.arguments['type'];
    if (strIsEmpty(name) || strIsEmpty(type)) {
      type = 'import';
    }
    _getChains();
  }

  _getChains() async {
    List<Identity> items = await DBHelper.create().queryIdentities();
    if (items != null && items.length > 0 && type.compareTo("append") == 0) {
      selectCount = 0;
    } else {
      selectCount = 1;
    }

    Result<Chains> result = await requestChains(wid);
    setState(() {
      chains.clear();
      chains.addAll(result.result.items);
    });
    return Future.value(true);
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
        backgroundColor: Colors.transparent,
        title: Text(
          title,
          style: Theme.of(context).primaryTextTheme.headline3,
        ),
      ),
      body: Stack(children: [
        Divider(
          height: 1,
        ),
        buildRefresh(_createCheckList(), _refreshController, () async {
          await _getChains();
          _refreshController.finishRefresh();
        }),
        _buildButton()
      ]),
    );
  }

  Widget _createCheckList() {
    return ListView.builder(
        itemCount: chains.length,
        itemBuilder: (context, index) {
          Coin item = chains[index];
          return Container(
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      margin: SizeUtil.margin(all: 10),
                      padding: SizeUtil.padding(all: 3),
                      decoration: new BoxDecoration(color: Colors.grey[200], borderRadius: new BorderRadius.circular(SizeUtil.width(30))),
                      child: CachedNetworkImage(
                        width: SizeUtil.width(30),
                        height: SizeUtil.width(30),
                        imageUrl: item.icon,
                        placeholder: (context, url) => Image.asset(
                          Constant.Assets_Image + "common_placeholder.png",
                        ),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: SizeUtil.padding(bottom: 4),
                          child: Text(item.symbol,
                              style: Theme.of(context).primaryTextTheme.headline3.merge(TextStyle(color: BeeColors.FF091C40, fontSize: SizeUtil.sp(14))),
                              overflow: TextOverflow.ellipsis),
                        ),
                        Text(item.name,
                            style: Theme.of(context).primaryTextTheme.subtitle2.merge(TextStyle(color: BeeColors.FFA2A6B0, fontSize: SizeUtil.sp(12))),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis),
                      ],
                    )),
                    Checkbox(
                        value: item.selected ?? false,
                        onChanged: !item.canAction
                            ? null
                            : (val) {
                                // console.i(val);
                                if (val) {
                                  selectCount++;
                                } else {
                                  selectCount--;
                                }
                                setState(() {
                                  item.selected = val;
                                });
                              })
                  ],
                ),
                Divider(
                  height: 1,
                )
              ],
            ),
          );
        });
  }

  Widget _buildButton() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: SizeUtil.height(30),
      child: Container(
        padding: SizeUtil.padding(left: 30, right: 30),
        child: MaterialButton(
          onPressed: selectCount > 0
              ? () {
                  _commitChecked();
                }
              : null,
          disabledColor: BeeColors.FFA2A6B0,
          color: BeeColors.blue,
          minWidth: SizeUtil.width(300),
          height: SizeUtil.width(45),
          shape: RoundedRectangleBorder(
            side: BorderSide.none,
            borderRadius: SizeUtil.radius(all: 100),
          ),
          child: Text(
            'CommonConfirm'.tr,
            style: StyleUtil.textStyle(size: 14, color: Colors.white),
          ),
        ),
      ),
    );
  }

  _commitChecked() async {
    List<Coin> checked = [];
    for (var value in chains) {
      if (value.selected) {
        checked.add(value);
      }
    }
    if (checked.isEmpty) {
      showWarnBar("WalletSelectMain".tr);
      return;
    }
    if (type == 'import') {
      Get.back(result: {'chains': checked});
    } else if (type == 'append') {
      await showDialog(
          useSafeArea: false,
          context: context,
          builder: (builder) {
            return DialogPassBoard(callback: (text) async {
              String pass = getTokenId(text);
              var auth = await DBHelper().queryAuth();
              if (pass != auth.password) {
                showWarnBar("CommonPwdError".tr);
                return;
              }
              showLoading();
              await appendAction(pass, checked);
              showLoading(show: false);
              Get.back();
            });
          },
      );

      await _getChains();
      eventBus.fire(UpdateChain());
      Get.back();
    } else {
      Get.to(PageMnemonic(), arguments: {
        "name": name,
        "type": "create",
        "pass": pass,
        "chains": checked
      });
    }
  }

  appendAction(String pass, List<Coin> checked) async {
    List<Coin> allChains = [];
    List<Coin> tronChains = [];
    for (var chain in checked) {
      if (chain.contract.isNotEmpty && chain.contract == "TRX") {
        tronChains.add(chain);
      } else {
        allChains.add(chain);
      }
    }
    if (allChains.length > 0) {
      Identity current = await DBHelper.create().queryIdentity(wid);
      if (current.tokenType == "mnemonic") {
        String mnemonic = await decrypt(current.token, pass);
        if (mnemonic != null) {
          await saveCoins(context, wid, allChains, needRequest: true, mnemonic: mnemonic, pass: pass);
        }
      } else if (current.tokenType == "keystore") {
        String keystore = await decrypt(current.token, pass);
        String privateKey = await decrypt(current.privateKey, pass);
        await saveCoins(context, wid, allChains, needRequest: true, keystore: keystore, passwordKS: pass, privateKey: privateKey, pass: pass);
      } else {
        String privateKey = await decrypt(current.privateKey, pass);
        await saveCoins(context, wid, allChains, needRequest: true, privateKey: privateKey, pass: pass);
      }
    }
    if (tronChains.length > 0) {
      Identity current = await DBHelper.create().queryIdentity(wid);
      if (current.tokenType == "mnemonic") {
        String mnemonic = await decrypt(current.token, pass);
        String privateKey = await getPrivateKeyFromMnemonic(context, tronChains, mnemonic);
        if (privateKey != null) {
          await saveCoins(context, wid, tronChains, needRequest: true, mnemonic: mnemonic, pass: pass);
        } else {
          showWarnBar("WalletTronKeystoreNo".tr);
        }
      } else if (current.tokenType == "keystore") {
        showWarnBar("WalletTronKeystoreNo".tr);
      } else {
        String privateKey = await decrypt(current.privateKey, pass);
        await saveCoins(context, wid, tronChains, needRequest: true, privateKey: privateKey, pass: pass);
      }
    }
  }
}
