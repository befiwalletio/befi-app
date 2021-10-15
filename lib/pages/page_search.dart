import 'package:cached_network_image/cached_network_image.dart';
import 'package:cube/core/base_widget.dart';
import 'package:cube/core/constant.dart';
import 'package:cube/core/core.dart';
import 'package:cube/models/model_base.dart';
import 'package:cube/models/model_home.dart';
import 'package:cube/net/manager_api.dart';
import 'package:cube/net/requester.dart';
import 'package:cube/pages/page_chain.dart';
import 'package:cube/pages/page_mytoken.dart';
import 'package:cube/utils/utils_db.dart';
import 'package:cube/utils/utils_event.dart';
import 'package:cube/utils/utils_size.dart';
import 'package:cube/views/appbar/appbar.dart';
import 'package:cube/views/dialog/dialog_loading.dart';
import 'package:cube/views/point.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:get/get.dart';
import 'package:cube/utils/utils_console.dart';

class PageSearch extends StatefulWidget {
  const PageSearch({Key key}) : super(key: key);

  @override
  _PageSearchState createState() => _PageSearchState();
}

class PageSearchController extends GetxController {
  var showLoading = false.obs;
  var showSearch = false.obs;
  var showClear = false.obs;
  var showSearchLoading = false.obs;
  var searchItems = [].obs;
  var items = [].obs;
  var chains = [].obs;
  var chain = Coin().obs;

  setSearchItems(data) {
    if (data == null) {
      data = [];
    }
    searchItems.value = data;
    showSearchLoading.value = false;
  }

  appendItems(data, {bool renew = false}) {
    if (renew) {
      if (data == null) {
        data = [];
      }
      items.value = data;
      showLoading.value = false;
      return;
    }
    if (data != null && data.length > 0) {
      items.addAll(data);
      showLoading.value = false;
    }
  }

  appendChains(data, {bool renew = false}) {
    if (renew) {
      if (data == null) {
        data = [];
      }
      data.forEach((el) {
        el.selected = false;
      });
      chains.value = data;
      return;
    }
    if (data != null && data.length > 0) {
      chains.value.addAll(data);
    }
  }

  changeChain(Coin data) {
    chain.value = data;
    showLoading.value = true;
    List temp = [];
    chains.value.forEach((element) {
      if (data == element) {
        element.selected = true;
      } else {
        element.selected = false;
      }
      temp.add(element);
    });
    chains.value = temp;
  }

  setSearchLoading() {
    showSearchLoading.value = true;
  }

  changeShowSearch(bool show) {
    if (showSearch.value != show) {
      showSearch.value = show;
    }
  }

  changeShowClear(bool show) {
    if (showClear.value != show) {
      showClear.value = show;
    }
  }
}

class _PageSearchState extends SizeState<PageSearch> {
  String _wid = '';
  Map<String, List<Coin>> tempData = {};

  Color _color = BeeColors.blue;
  TextEditingController _searchController = TextEditingController();
  EasyRefreshController _refreshController = EasyRefreshController();
  PageSearchController _pageController = Get.put(PageSearchController());

  @override
  void initState() {
    super.initState();
    _wid = Get.arguments['wid'];
    _pageController.appendChains(Global.SUPORT_CHAINS, renew: true);
    _pageController.changeChain(Global.SUPORT_CHAINS[0]);
    _requestChainCoins(Global.SUPORT_CHAINS[0].contract);
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
      child: WillPopScope(
        child: Scaffold(
            appBar: XAppBar(
              leading: Container(
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_outlined,
                    size: SizeUtil.width(20),
                  ),
                  onPressed: () {
                    Get.back();
                  },
                ),
              ),
              backgroundColor: _color,
              centerTitle: true,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.white),
              titleSpacing: 0,
              title: Container(
                width: SizeUtil.screenWidth(),
                child: TextField(
                  autofocus: false,
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                      contentPadding: SizeUtil.padding(all: 0),
                      border: InputBorder.none,
                      filled: false,
                      hintText: '${'CommonSearchInput'.tr}',
                      hintStyle: StyleUtil.textStyle(size: 12, color: Colors.grey[350])),
                  style: StyleUtil.textStyle(size: 12, weight: FontWeight.bold, color: Colors.white),
                  obscureText: false,
                  keyboardType: TextInputType.text,
                  textAlign: TextAlign.left,
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (text) {
                    FocusScope.of(context).requestFocus(FocusNode());
                    _requestSearchCoins();
                  },
                  onChanged: (text) {
                    if (strIsEmpty(text)) {
                      _pageController.changeShowClear(false);
                      _pageController.changeShowSearch(false);
                    } else {
                      _pageController.changeShowClear(true);
                    }
                  },
                ),
              ),
              actions: [
                Builder(builder: (context) {
                  return Container(
                    padding: SizeUtil.padding(top: 10, bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Obx(() => _pageController.showClear.value
                            ? Container(
                                width: SizeUtil.width(25),
                                height: SizeUtil.width(25),
                                alignment: Alignment.center,
                                child: IconButton(
                                    icon: Icon(Icons.clear, size: SizeUtil.width(20)),
                                    padding: SizeUtil.padding(),
                                    onPressed: () {
                                      _searchController.text = '';
                                      _pageController.changeShowClear(false);
                                      _pageController.changeShowSearch(false);
                                    }),
                              )
                            : SizedBox(
                                width: 0,
                                height: 0,
                              )),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              await _requestSearchCoins();
                            },
                            child: Container(
                              padding: SizeUtil.padding(left: 10, right: 10),
                              alignment: Alignment.center,
                              color: Colors.transparent,
                              child: Text(
                                'CommonSearch'.tr,
                                style: TextStyle(color: Colors.white, backgroundColor: Colors.transparent),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
            body: Stack(
              children: [
                Container(
                  height: double.infinity,
                  child: Row(
                    children: [
                      Container(
                        color: Colors.redAccent,
                        height: double.infinity,
                        width: SizeUtil.width(65),
                        child: _createChains(),
                      ),
                      Container(
                        height: double.infinity,
                        width: 1,
                        color: Colors.grey[100],
                      ),
                      Expanded(
                          child: Container(
                        height: double.infinity,
                        child: Column(
                          children: [
                            Obx(
                              () => !_pageController.chain.value.showUserAllCoins
                                  ? Container(
                                      height: 0,
                                    )
                                  : Material(
                                      child: InkWell(
                                        onTap: () async {
                                          await Get.to(PageMyToken(), arguments: {'wid': _wid, 'contract': _pageController.chain.value.contract});
                                        },
                                        child: Container(
                                          padding: SizeUtil.padding(top: 15, bottom: 15, left: 14, right: 7),
                                          color: Colors.white,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "WalletAllToken".tr,
                                                style: Theme.of(context).primaryTextTheme.subtitle2,
                                              ),
                                              SizedBox(
                                                child: Icon(
                                                  Icons.arrow_forward_ios,
                                                  size: SizeUtil.width(14),
                                                  color: Colors.grey[400],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                            Divider(
                              height: 1,
                            ),
                            Expanded(child: _createItems()),
                            _createChainAdd()
                          ],
                        ),
                      ))
                    ],
                  ),
                ),
                _createSearch()
              ],
            )
            ),
      ),
    );
  }

  Widget _createChainAdd() {
    return Container(
      margin: SizeUtil.margin(left: 15, right: 25, top: 5, bottom: 20),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide.none,
          borderRadius: SizeUtil.radius(all: 10),
        ),
        child: InkWell(
          borderRadius: BorderRadius.all(Radius.circular(SizeUtil.width(10))),
          onTap: () async {
            Identity _identity = await DBHelper().queryIdentity(_wid);
            await Get.to(PageChain(), arguments: {
              'type': "append",
              "name": _identity.name,
              "wid": _wid,
            });
          },
          child: Container(
            padding: SizeUtil.padding(top: 10, bottom: 10),
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
                            )),
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
        ),
      ),
    );
  }

  Widget _createChains() {
    return Obx(() {
      return Container(
        padding: SizeUtil.padding(top: 10, bottom: 10),
        color: Colors.white,
        width: double.infinity,
        child: ListView.builder(
          itemBuilder: (context, index) {
            Coin item = _pageController.chains[index];
            return CellOne(item, () {
              _pageController.changeChain(item);
              _requestChainCoins(item.contract);
            });
          },
          itemCount: _pageController.chains.length,
        ),
      );
    });
  }

  Widget _createItems() {
    return Obx(() {
      return Container(
        padding: SizeUtil.padding(bottom: 10),
        width: double.infinity,
        height: double.infinity,
        child: _pageController.showLoading.value
            ? DialogLoading()
            : _pageController.items.length > 0
                ? ListView.builder(
                    itemBuilder: (context, index) {
                      Coin item = _pageController.items[index];
                      return _createItem(item, index, 'normal');
                    },
                    itemCount: _pageController.items.length,
                  )
                : buildEmpty(),
      );
    });
  }

  Widget _createSearch() {
    return Obx(() {
      return _pageController.showSearch.value
          ? Container(
              height: double.infinity,
              width: double.infinity,
              color: Colors.white,
              child: _pageController.showSearchLoading.value
                  ? DialogLoading()
                  : _pageController.searchItems.length > 0
                      ? ListView.builder(
                          itemBuilder: (context, index) {
                            Coin item = _pageController.searchItems[index];
                            return _createItem(item, index, 'search');
                          },
                          itemCount: _pageController.searchItems.length,
                        )
                      : buildEmpty(),
            )
          : Container(
              width: 0,
              height: 0,
            );
    });
  }

  Widget _createItem(Coin coin, index, type) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () async {},
        child: Container(
          padding: SizeUtil.padding(top: 6, bottom: 6, left: 15, right: 15),
          child: Row(
            children: [
              CachedNetworkImage(
                width: SizeUtil.width(25),
                height: SizeUtil.width(25),
                imageUrl: coin.icon,
                placeholder: (context, url) => Image.asset(
                  Constant.Assets_Image + "common_placeholder.png",
                ),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
              Expanded(
                child: Container(
                  margin: SizeUtil.margin(left: 10, right: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${coin.symbol}',
                            style:
                            Theme.of(context).primaryTextTheme.headline6.merge(TextStyle(fontWeight: FontWeight.bold, fontSize: SizeUtil.sp(14))),
                          ),
                          Text(
                            type == 'search' ? ' (${coin.name} - ${coin.contract} Token)' : ' (${coin.name})',
                            style: Theme.of(context).primaryTextTheme.subtitle2.merge(TextStyle(fontSize: SizeUtil.sp(10))),
                          ),
                        ],
                      ),
                      Text(
                        _formatAddress(coin.contractAddress),
                        style: Theme.of(context).primaryTextTheme.subtitle2.merge(TextStyle(fontSize: SizeUtil.sp(10))),
                      ),
                    ],
                  ),
                ),
              ),
              !coin.isHas
                  ? IconButton(
                      icon: Icon(
                        Icons.add,
                        color: Colors.grey,
                      ),
                      onPressed: () async {
                        console.i(coin.json);
                        await _requestAddCoin(coin);
                      })
                  : IconButton(
                      icon: Icon(
                      Icons.done,
                      color: BeeColors.blue,
                    ))
            ],
          ),
        ),
      ),
    );
  }

  _requestChainCoins(chain) async {
    if (tempData[chain] != null) {
      _pageController.appendItems(tempData[chain], renew: true);
    }
    Result<Chains> result = await requestHotList({'wid': _wid, "contract": chain});
    tempData[chain] = result.result.items;
    if (result.tag == _pageController.chain.value.contract) {
      _pageController.appendItems(result.result.items, renew: true);
    }
  }

  _requestSearchCoins() async {
    if (strIsEmpty(_searchController.text)) {
      return;
    }
    _pageController.changeShowSearch(true);
    _pageController.setSearchLoading();
    Result<Chains> result = await requestCoins(_searchController.text != null ? _searchController.text : "", _wid);
    if (result.result != null && result.result.items != null) {
      _pageController.setSearchItems(result.result.items);
    }
  }

  _requestAddCoin(Coin coin) async {
    if (!_checkContract(coin)) {
      showWarnBar(("WalletAddMainTip".tr).replaceAll('{%s}', coin.contract));
      return;
    }
    List<String> descAddresses = await saveCoins(context, _wid, [coin]);
    if (descAddresses == null) {
      return;
    }
    showLoadingDialog();
    Result<DefaultModel> result = await requestAddCoin({
      "wid": _wid,
      "symbol": coin.symbol,
      "contract": coin.contract,
      "contractAddress": coin.contractAddress,
      "assetName": coin.assetName != null ? coin.assetName : "",
    });
    showLoadingDialog(show: false);
    showTipsBar("WalletAddSuccess".tr);
    if (_pageController.showSearch.value) {
      _requestSearchCoins();
    }
    _requestChainCoins(_pageController.chain.value.contract);
    eventBus.fire(UpdateChain());
  }

  bool _checkContract(Coin coin) {
    for (int i = 0; i < Global.CURRENT_CONIS.length; i++) {
      Coin item = Global.CURRENT_CONIS[i];
      if (item.symbol == coin.contract) {
        return true;
      }
    }
    return false;
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
}

class CellOne extends StatelessWidget {
  static final height = 44.0;
  final Coin chain;
  final VoidCallback onPressed;

  CellOne(this.chain, this.onPressed);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        margin: SizeUtil.margin(left: 5, right: 5),
        padding: SizeUtil.padding(top: 5, bottom: 5),
        decoration: new BoxDecoration(
            color: chain.selected ? Colors.blue : Colors.white,
            borderRadius: new BorderRadius.circular(SizeUtil.width(5))),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: SizeUtil.margin(bottom: 2),
              padding: SizeUtil.padding(all: 5),
              width: SizeUtil.width(30),
              height: SizeUtil.width(30),
              decoration: new BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: new BorderRadius.circular(SizeUtil.width(44))),
              child: CachedNetworkImage(
                imageUrl: chain.icon,
                placeholder: (context, url) => Image.asset(
                  Constant.Assets_Image + "common_placeholder.png",
                ),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
            Text(strIsEmpty(chain.chainName) ? chain.contract : chain.chainName,
                style: TextStyle(color: chain.selected ? Colors.white : Colors.blue, fontSize: SizeUtil.sp(10)))
          ],
        ),
      ),
    );
  }
}
