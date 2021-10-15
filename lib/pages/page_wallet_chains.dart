import 'package:cached_network_image/cached_network_image.dart';
import 'package:cube/core/base_widget.dart';
import 'package:cube/core/constant.dart';
import 'package:cube/models/model_base.dart';
import 'package:cube/net/manager_api.dart';
import 'package:cube/pages/page_chain_one.dart';
import 'package:cube/pages/page_wallet_setting.dart';
import 'package:cube/utils/utils_db.dart';
import 'package:cube/utils/utils_event.dart';
import 'package:cube/utils/utils_size.dart';
import 'package:cube/views/appbar/appbar.dart';
import 'package:cube/views/dialog/dialog_widget_board.dart';
import 'package:cube/views/point.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cube/utils/utils_console.dart';
import 'package:cube/core/core.dart';

class PageWalletChains extends StatefulWidget {
  const PageWalletChains({Key key}) : super(key: key);

  @override
  _PageWalletChainsState createState() => _PageWalletChainsState();
}

class _PageWalletChainsState extends SizeState<PageWalletChains> {
  Identity _identity;
  String _wid;
  List<Coin> _chains = [];

  @override
  void initState() {
    super.initState();
    _identity = Get.arguments['identity'];
    _wid = _identity.wid;
    _getChains();
  }

  _getChains() async {
    List<Coin> chains = [];
    List<Coin> coins = await DBHelper.create().queryCoins(_wid);
    coins.forEach((element) {
      if (element.symbol == element.contract) {
        console.i(element.toJson());
        chains.add(element);
      }
    });
    setState(() {
      _chains = chains;
    });
  }

  @override
  Widget createView(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          backgroundColor: Get.isDarkMode ? Colors.black : Colors.white,
          appBar: XAppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_outlined),
              onPressed: () {
                Get.back();
              },
            ),
            elevation: SizeUtil.width(1),
            shadowColor: Colors.grey[100],
            title: Text("WalletMainManager".tr),
            actions: [
              Builder(
                builder: (context) => IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () async {
                    await Get.to(PageWalletSetting(), arguments: {"identity": _identity});
                    await _getChains();
                  },
                ),
              )
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    _createChainLists(),
                  ],
                ),
              ),
              _createWalletAdd(),
            ],
          ),
        ),
        onWillPop: () {
          Get.back();
        });
  }

  Widget _createChainLists() {
    return Container(
        child: ListView.builder(
      itemBuilder: (context, index) {
        if (index == _chains.length) {
          return SizedBox(
            width: 0,
            height: 0,
          );
        }
        Coin item = _chains[index];
        return Container(
          height: SizeUtil.height(60),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    SizedBox(
                      width: SizeUtil.width(20),
                    ),
                    Container(
                      padding: SizeUtil.padding(all: 5),
                      width: SizeUtil.width(38),
                      height: SizeUtil.width(38),
                      decoration: new BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: new BorderRadius.circular(SizeUtil.width(44)),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: item.icon,
                        placeholder: (context, url) => Image.asset(
                          Constant.Assets_Image + "common_placeholder.png",
                        ),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                    SizedBox(
                      width: SizeUtil.width(18),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: SizeUtil.padding(bottom: 4),
                            child: Text(item.symbol,
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .headline3
                                    .merge(TextStyle(color: BeeColors.FF091C40, fontSize: SizeUtil.sp(14))),
                                overflow: TextOverflow.ellipsis),
                          ),
                          Text(_formatAddress(item.address),
                              style:
                                  Theme.of(context).primaryTextTheme.subtitle2.merge(TextStyle(color: BeeColors.FFA2A6B0, fontSize: SizeUtil.sp(12))),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 50,
                    ),
                    item.symbol.compareTo("ETH") != 0
                        ? Container(
                            child: IconButton(
                            icon: Icon(
                              Icons.more_horiz_outlined,
                              color: Colors.grey,
                            ),
                            onPressed: () async {
                              await _showActionDialog(item);
                            },
                          ))
                        : Container(),
                  ],
                ),
              ),
              Container(
                color: Colors.grey[200],
                height: SizeUtil.height(0.5),
              ),
            ],
          ),
        );
      },
      itemCount: _chains.length + 1,
    ));
  }

  String _formatAddress(String address) {
    if (strIsEmpty(address)) {
      return '';
    }
    if (address.length < 16) {
      return address;
    }
    String start = address.substring(0, 8);
    String end = address.substring(address.length - 8);
    return '$start...$end';
  }

  Widget _createWalletAdd() {
    return InkWell(
      onTap: () async {
        await Get.to(PageChainOne(), arguments: {
          'type': "append",
          "name": _identity.name,
          "wid": _wid,
        });
        _getChains();
      },
      child: Container(
        padding: SizeUtil.padding(top: 10, bottom: 10),
        margin: SizeUtil.margin(left: 20, right: 20, top: 5, bottom: 20),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(SizeUtil.width(10))),
            border: Border.all(color: Colors.grey[200], width: 1),
            color: Colors.white),
        child: Row(
          children: [
            SizedBox(
              width: SizeUtil.width(17),
            ),
            Expanded(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "WalletAddMain".tr,
                      style: Theme.of(context).primaryTextTheme.headline3.merge(TextStyle(color: BeeColors.FF00A0E8, fontSize: SizeUtil.sp(14))),
                    ),
                    SizedBox(
                      height: SizeUtil.height(4),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Point(
                          size: SizeUtil.height(6),
                          color: BeeColors.FFA2A6B0,
                        ),
                        SizedBox(
                          width: SizeUtil.width(6),
                        ),
                        Expanded(
                            child: Text(
                          "WalletSupportChain".tr,
                          style: Theme.of(context).primaryTextTheme.headline3.merge(TextStyle(
                                color: BeeColors.FFA2A6B0,
                                fontSize: SizeUtil.sp(12),
                              )),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ))
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Image.asset(
              Constant.Assets_Image + "common_add.png",
              width: SizeUtil.width(22),
              height: SizeUtil.width(22),
            ),
            SizedBox(
              width: SizeUtil.width(15),
            ),
          ],
        ),
      ),
    );
  }

  _hideCoin(Coin coin) async {
    showLoading();
    await DBHelper().deleteCoin(coin);
    await requestDelChain({'wid': coin.wid, "contract": coin.contract});
    await DBHelper.create().deleteCoin(coin);
    await _getChains();
    eventBus.fire(UpdateChain());
    showLoading(show: false);
  }

  _showActionDialog(Coin coin) async {
    return await showDialog(
        useSafeArea: false,
        context: context,
        builder: (context) {
          return DialogWidgetBoard(
            child: Container(
              child: Column(
                children: [
                  InkWell(
                      onTap: () async {
                        Get.back();
                        await _hideCoin(coin);
                      },
                      child: Container(
                        child: Text(
                          'WalletHide'.tr,
                          style: Theme.of(context).primaryTextTheme.bodyText1,
                        ),
                      )),
                  Divider(
                    height: 1,
                    color: Colors.grey[100],
                  )
                ],
              ),
            ),
          );
        });
  }
}
