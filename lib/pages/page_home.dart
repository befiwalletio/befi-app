import 'package:cached_network_image/cached_network_image.dart';
import 'package:cube/controller/PageWalletSettingController.dart';
import 'package:cube/core/constant.dart';
import 'package:cube/core/core.dart';
import 'package:cube/models/model_base.dart';
import 'package:cube/models/model_home.dart';
import 'package:cube/net/manager_api.dart';
import 'package:cube/net/requester.dart';
import 'package:cube/pages/page_detail.dart';
import 'package:cube/pages/page_search.dart';
import 'package:cube/pages/page_start.dart';
import 'package:cube/pages/page_wallet_chains.dart';
import 'package:cube/utils/utils_console.dart';
import 'package:cube/utils/utils_db.dart';
import 'package:cube/utils/utils_event.dart';
import 'package:cube/utils/utils_size.dart';
import 'package:cube/utils/utils_sp.dart';
import 'package:cube/views/appbar/appbar.dart';
import 'package:cube/views/appbar/beebar.dart';
import 'package:cube/views/drawer.dart';
import 'package:cube/views/flutter/expansion_panel.dart';
import 'package:cube/views/point.dart';
import 'package:flutter/material.dart' hide ExpansionPanelList, ExpansionPanel;
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:get/get.dart';

class PageHome extends StatefulWidget {
  const PageHome({Key key}) : super(key: key);

  @override
  _PageHomeState createState() => _PageHomeState();
}

class HomeController extends GetxController {
  var showGroup = false.obs;
  var title = "".obs;
  var wid = "".obs;
  var identities = [].obs;
  Rx<Identity> identity = Identity().obs;
  Rx<HomeIndex> home = HomeIndex().obs;
  var coins = <Coin>[].obs;
  var groups = <HomePanelItem>[].obs;

  changeShowGroup(data) => showGroup.value = data;

  changeGroups(data) {
    groups.value = data;
  }

  changeTitle(data) => title.value = data;

  changeCoins(data) {
    if (data != null) {
      coins.clear();
      coins.addAll(data);
      List<HomePanelItem> temp = [];
      Map<String, HomePanelItem> tempGroups = {};
      coins.forEachWithIndex((index, element) {
        if (tempGroups[element.contract] == null) {
          tempGroups[element.contract] = HomePanelItem();
          tempGroups[element.contract].items = [];
        }
        if (element.contract == element.symbol) {
          tempGroups[element.contract].chain = element;
        } else {
          tempGroups[element.contract].items.add(element);
        }
      });
      tempGroups.values.forEach((element) {
        temp.add(element);
      });
      changeGroups(temp);
    }
  }

  changeWid(data) => wid.value = data;

  changeIdentities(data) {
    identities.value = data;
  }

  changeIdentity(data) {
    identity.value = data;
    title.value = data.name;
    wid.value = data.wid;
  }

  changeHomeData(data) {
    if (data != null) {
      home.value = data;
      changeCoins(data.items);
    }
  }
}

class _PageHomeState extends State<PageHome> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  bool showDark = true;
  bool showAssets = true;
  bool showDrawer = false;
  List<ExpansionPanelItem> _expansionPanelItems = <ExpansionPanelItem>[];

  num paddingX = 15.0;
  String defaultCSUnit = '';

  HomeController _homeController = Get.put(HomeController());
  EasyRefreshController _refreshController = EasyRefreshController();
  PageWalletSettingController _walletSettingController = Get.put(PageWalletSettingController(), tag: PageWalletSettingController.TAG);

  @override
  void initState() {
    super.initState();
    eventBus.on<UpdateChain>().listen((event) async {
      console.i("更新首页数据");
      await _queryLocalCoins();
      await _requestDate();
    });
    eventBus.on<UpdateWallet>().listen((event) async {
      console.i("更新钱包属性");
      await _queryIdentity();
    });

    eventBus.on<CloseDrawer>().listen((event) async {
      console.i("关闭Drawer ${Scaffold.of(context).isDrawerOpen} | ${Scaffold.of(context).hasDrawer} | ${showDrawer}");
      if (showDrawer) {
        Navigator.pop(context);
      }
    });
    ever(_walletSettingController.changed, (_) {
      //todo 数据更改通知刷新
    });
    ever(_homeController.groups, (_) {
      _expansionPanelItems.clear();
      List<ExpansionPanelItem> tempItems = <ExpansionPanelItem>[];
      _homeController.groups.value.forEachWithIndex((index, homePanelItem) {
        List<Widget> bodyItems = [];
        Color color = homePanelItem.chain.color != null ? '${homePanelItem.chain.color}'.toColor() : BeeColors.blue[400];

        homePanelItem.items.forEach((element) {
          bodyItems.add(createPanelCoin(element, diver: true, main: false, color: color));
        });
        tempItems.add(ExpansionPanelItem(
          chain: homePanelItem.chain,
          body: Container(
            padding: EdgeInsets.all(0),
            margin: EdgeInsets.all(0),
            width: double.infinity,
            child: Column(
              children: bodyItems,
            ),
          ),
          isExpanded: false,
        ));
      });
      _expansionPanelItems = tempItems;
    });
    showDark = Get.isDarkMode;
    _initData();
  }

  _initData() async {
    await _queryIdentity();
    await _queryLocalCoins();
    await _requestDate();
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: XAppBar(
        titleSpacing: 0.0,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [],
        title: BeeBar(
            fixPadding: false,
            left: [
              Builder(
                builder: (context) => IconButton(
                  icon: Icon(
                    Icons.sort,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  onPressed: () {
                    showDrawer = true;
                    Scaffold.of(context).openDrawer();
                  },
                ),
              ),
            ],
            title: Obx(() => Text(
                  "${_homeController.title}",
                  style: StyleUtil.textStyle(size: 16, color: Theme.of(context).appBarTheme.iconTheme.color, weight: FontWeight.bold),
                ))),
      ),
      body: createRefresh(),
      onDrawerChanged: (result) {
        this.showDrawer = result;
      },
      drawer: SmartDrawer(
        widthPercent: 0.9,
        child: createWalletLists(),
      ),
    );
  }

  _queryLocalCoins() async {
    defaultCSUnit = Constant.CS_UNITS[Global.CS];
    List<Coin> items = await DBHelper().queryCoins(_homeController.wid.value);
    Global.CURRENT_CONIS = items;
    _homeController.changeCoins(items);
  }

  _queryIdentity() async {
    _homeController.changeWid(SPUtils().get(Constant.CUSTOM_WID));
    var identity = await DBHelper.create().queryIdentity(_homeController.wid.value);
    var queryIdentities = await DBHelper.create().queryIdentities();
    if (identity != null) {
      String wid = identity.wid;
      _homeController.changeWid(SPUtils().get(Constant.CUSTOM_WID));
      SPUtils().put(Constant.CUSTOM_WID, wid);
      _homeController.changeIdentity(identity);
      _homeController.changeIdentities(queryIdentities);
    } else {
      Get.offAll(PageStart());
    }
  }

  _requestDate() async {
    Result<HomeIndex> requestHome2 = await requestHome(_homeController.wid.value);
    _refreshController.finishRefresh(success: true);
    if (requestHome2 != null && requestHome2.result != null) {
      await DBHelper().updateCoins(requestHome2.result.items);
      List<Coin> coinList = await DBHelper().queryCoins(_homeController.wid.value);
      Global.CURRENT_CONIS = coinList;
      requestHome2.result.items = coinList;
      _homeController.changeHomeData(requestHome2.result);
    }
    return Future.value(true);
  }

  Widget createWalletLists() {
    return Container(
      width: SizeUtil.screenWidth(),
      padding: SizeUtil.padding(top: SizeUtil.barHeight()),
      color: Colors.grey[50],
      child: Column(
        children: [
          Container(
            padding: SizeUtil.padding(left: 10, top: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.toc,
                  size: SizeUtil.width(25),
                ),
                Text(
                  "WalletList".tr,
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: SizeUtil.sp(14)),
                ),
                Spacer(),
              ],
            ),
          ),
          SizedBox(
            height: SizeUtil.height(10),
          ),
          Expanded(
            child: Obx(() => ListView.builder(
                itemCount: _homeController.identities.length,
                itemBuilder: (context, index) {
                  Identity item = _homeController.identities[index];
                  return createWalletItem(item, item.wid == _homeController.identity.value.wid);
                })),
          ),
          Container(
            margin: SizeUtil.margin(left: 15, right: 15, bottom: 7, top: 7),
            child: Material(
              borderRadius: BorderRadius.all(Radius.circular(SizeUtil.width(10))),
              color: Colors.white,
              child: InkWell(
                borderRadius: BorderRadius.all(Radius.circular(SizeUtil.width(10))),
                onTap: () {
                  Get.to(PageStart(), transition: Transition.fadeIn);
                },
                child: Container(
                  padding: SizeUtil.padding(all: 10),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[50]),
                      borderRadius: BorderRadius.all(Radius.circular(SizeUtil.width(17)))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add,
                        color: BeeColors.blue,
                      ),
                      Text(
                        "WalletAdd".tr,
                        style: Theme.of(context).primaryTextTheme.headline3.merge(TextStyle(color: BeeColors.blue, fontSize: SizeUtil.sp(14))),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget createWalletItem(Identity identity, bool checked) {
    if (identity == null) {
      return Container(
        width: SizeUtil.screenWidth(),
        height: SizeUtil.height(80),
        color: Colors.green,
      );
    }
    num itemHeight = SizeUtil.height(50);
    Color backColor = identity.color.toColor();
    return Container(
      margin: SizeUtil.margin(left: 10, right: 10, bottom: 10),
      width: SizeUtil.screenWidth(),
      decoration: new BoxDecoration(
        color: backColor,
        borderRadius: new BorderRadius.all(new Radius.circular(SizeUtil.width(17))),
      ),
      child: Row(
        children: [
          Expanded(
              child: Container(
            width: SizeUtil.screenWidth(),
            margin: SizeUtil.margin(right: 10),
            padding: SizeUtil.padding(left: 10, right: 10),
            alignment: Alignment.centerLeft,
            height: itemHeight,
            child: InkWell(
              onTap: () {
                _changeIdentity(identity);
              },
              child: Container(
                width: SizeUtil.screenWidth(),
                child: Row(
                  children: [
                    Container(
                      // color: Colors.red,
                      width: SizeUtil.width(40),
                      child: checked
                          ? Icon(
                              Icons.check,
                              color: Colors.white,
                            )
                          : SizedBox(
                              width: 0,
                              height: 0,
                            ),
                    ),
                    Expanded(
                        child: Text(
                      identity.name,
                      textAlign: TextAlign.left,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white, fontSize: SizeUtil.sp(14), fontWeight: FontWeight.bold),
                    )),
                  ],
                ),
              ),
            ),
          )),
          Container(
            height: itemHeight,
            width: itemHeight,
            child: IconButton(
              onPressed: () async {
                Get.back();
                var result = await Get.to(PageWalletChains(), arguments: {"identity": identity});
              },
              icon: Icon(
                Icons.settings,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget createRefresh() {
    var refreshView = EasyRefresh(
      header: MaterialHeader(),
      onRefresh: () async {
        await _requestDate();
      },
      controller: _refreshController,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Obx(() => createCard()),
            createLabel(),
            Container(
              child: Obx(() => _homeController.showGroup.value
                  ? Container(
                      child: Column(
                        children: [createGroups()],
                      ),
                    )
                  : _homeController.coins.length > 0
                      ? Column(
                          children: createList(),
                        )
                      : Container(
                          width: 0,
                          height: 0,
                        )),
            ),
            Container(
              height: SizeUtil.width(20),
            )
          ],
        ),
      ),
    );
    return refreshView;
  }

  Widget createCard() {
    return Card(
      margin: SizeUtil.margin(left: paddingX, right: paddingX, top: 10),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      color: _homeController.identity.value.color.toColor(),
      child: Stack(
        children: [
          Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(
                child: Image.asset(
                  'assets/images/img_card_mask.png',
                  width: SizeUtil.screenWidth(),
                  fit: BoxFit.fill,
                ),
              )),
          Container(
            padding: SizeUtil.padding(left: 10, right: 10, top: 7, bottom: 7),
            child: Column(
              children: [
                Container(
                  child: Row(
                    children: [
                      Text(
                        '${"WalletAssetsAll".tr}${_homeController.home.value.totalUnit != null ? '(${_homeController.home.value.totalUnit ?? ''})' : ''}',
                        style: StyleUtil.textStyle(color: Colors.white, size: 16, weight: FontWeight.bold),
                      ),
                      Spacer(),
                      IconButton(
                          icon: Icon(
                            showAssets ? Icons.visibility : Icons.visibility_off,
                            color: Colors.white,
                          ),
                          onPressed: () => {
                                setState(() => {showAssets = !showAssets})
                              })
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.topLeft,
                  child: Text(
                    showAssets ? "${_homeController.home != null ? _homeController.home.value.totalAmount ?? '0.00' : "0.00"}" : "****",
                    style: StyleUtil.textStyle(size: 28, color: Colors.white),
                  ),
                ),
                Container(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    showAssets
                        ? '${_homeController.home.value != null ? '${_homeController.home.value.csUnit ?? defaultCSUnit} ${_homeController.home.value.csAmount ?? '0.00'}' : ""}'
                        : "****",
                    style: StyleUtil.textStyle(size: 14, color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  //Label
  Widget createLabel() {
    return Container(
      padding: SizeUtil.padding(left: 20, right: 7, top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "WalletMyAssets".tr,
            style: StyleUtil.textStyle(size: 14, color: Colors.black, weight: FontWeight.bold),
          ),
          SizedBox(
            width: SizeUtil.width(5),
          ),
          Obx(
            () => IconButton(
                icon: Icon(
                  _homeController.showGroup.value ? Icons.grid_view : Icons.view_list,
                  size: SizeUtil.width(16),
                ),
                onPressed: () => {_homeController.changeShowGroup(!_homeController.showGroup.value)}),
          ),
          Spacer(),
          Container(
            child: Stack(
              children: [
                IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () async {
                      var result = await Get.to(PageSearch(), arguments: {"type": "append", "wid": _homeController.wid.value});
                    }),
                Positioned(top: SizeUtil.height(8), right: SizeUtil.width(8), child: Point(size: SizeUtil.height(5)))
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget createGroups() {
    var list = ExpansionPanelList(
      elevation: 0,
      expandedHeaderPadding: SizeUtil.padding(all: 0),
      expansionCallback: (int panelIndex, bool isExpanded) {
        setState(() {
          _expansionPanelItems[panelIndex].isExpanded = !isExpanded;
        });
      },
      children: _expansionPanelItems.map((ExpansionPanelItem item) {
        return ExpansionPanel(
          isExpanded: item.isExpanded,
          body: item.body,
          headerBuilder: (BuildContext context, bool isExpanded) {
            return Container(
              // padding: EdgeInsets.all(16.0),
              child: createPanelCoin(item.chain),
            );
          },
        );
      }).toList(),
    );

    return list;
  }

  List<Widget> createList() {
    List<Widget> items = [];
    for (int i = 0; i < _homeController.coins.length; i++) {
      Coin item = _homeController.coins[i];
      items.add(InkWell(
        onTap: () async {
          item.csUnit = strIsEmpty(item.csUnit) ? defaultCSUnit : item.csUnit;
          await Get.to(PageCoinDetail(), arguments: {"data": item});
        },
        child: Container(
            child: Column(
          children: [
            Container(
              padding: SizeUtil.padding(left: paddingX, right: paddingX, top: 5, bottom: 5),
              child: Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: SizeUtil.padding(all: 5),
                        width: SizeUtil.width(44),
                        height: SizeUtil.width(44),
                        decoration: new BoxDecoration(
                            border: new Border.all(color: Colors.grey[200], width: 0.5),
                            color: Colors.white,
                            borderRadius: new BorderRadius.circular(SizeUtil.width(44))),
                        child: CachedNetworkImage(
                          imageUrl: item.icon,
                          placeholder: (context, url) => Image.asset(
                            Constant.Assets_Image + "common_placeholder.png",
                          ),
                          errorWidget: (context, url, error) => Icon(Icons.error),
                        ),
                      ),
                      item.contract == item.symbol
                          ? Container(
                              width: 0,
                              height: 0,
                            )
                          : Positioned(
                              bottom: 0,
                              right: SizeUtil.width(1),
                              child: Container(
                                decoration: BoxDecoration(color: item.color.toColor(), borderRadius: BorderRadius.all(Radius.circular(2))),
                                padding: SizeUtil.padding(left: 3, right: 3, top: 1, bottom: 1),
                                child: Text(
                                  '${fixChainName(item.contract)}',
                                  style: TextStyle(fontSize: SizeUtil.sp(6), color: Colors.white),
                                ),
                              ))
                    ],
                  ),
                  Padding(
                    padding: SizeUtil.padding(left: 14),
                    child: Text(
                      item.symbol,
                      style: StyleUtil.textStyle(size: 14, color: Colors.black, weight: FontWeight.bold),
                    ),
                  ),
                  Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(showAssets ? item.balance : "****",
                          style: StyleUtil.textStyle(size: SizeUtil.sp(15), color: Colors.black, weight: FontWeight.bold)),
                      Padding(
                        padding: SizeUtil.padding(top: 5),
                        child: Text(
                            showAssets
                                ? '≈${strIsEmpty(item.csUnit) ? defaultCSUnit : item.csUnit}${strIsEmpty(item.totalPrice) ? '0.00' : item.totalPrice}'
                                : "****",
                            style: StyleUtil.textStyle(size: SizeUtil.sp(10), color: Colors.grey, weight: FontWeight.bold)),
                      )
                    ],
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
            )
          ],
        )),
      ));
    }
    return items;
  }

  Widget createPanelCoin(Coin coin, {bool diver: false, bool main: true, Color color: BeeColors.blue}) {
    if (coin == null) {
      return Container(
        height: 0,
      );
    }
    return InkWell(
      onTap: () async {
        coin.csUnit = strIsEmpty(coin.csUnit) ? defaultCSUnit : coin.csUnit;
        await Get.to(PageCoinDetail(), arguments: {"data": coin});
      },
      child: Stack(
        children: [
          Container(
              color: main ? Colors.white : Colors.grey[50],
              child: Column(
                children: [
                  Container(
                    padding: SizeUtil.padding(left: paddingX, right: main ? 0 : SizeUtil.width(35), top: 5, bottom: 5),
                    child: Row(
                      children: [
                        Container(
                          padding: SizeUtil.padding(all: 5),
                          width: SizeUtil.width(44),
                          height: SizeUtil.width(44),
                          decoration: new BoxDecoration(
                              border: new Border.all(color: Colors.grey[200], width: 0.5),
                              color: Colors.white,
                              borderRadius: new BorderRadius.circular(SizeUtil.width(44))),
                          child: CachedNetworkImage(
                            imageUrl: coin.icon,
                            placeholder: (context, url) => Image.asset(
                              Constant.Assets_Image + "common_placeholder.png",
                            ),
                            errorWidget: (context, url, error) => Icon(Icons.error),
                          ),
                        ),
                        Padding(
                          padding: SizeUtil.padding(left: 14),
                          child: Text(
                            coin.symbol,
                            style: StyleUtil.textStyle(size: 14, color: Colors.black, weight: FontWeight.bold),
                          ),
                        ),
                        Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(showAssets ? coin.balance : "****",
                                style: StyleUtil.textStyle(size: SizeUtil.sp(15), color: Colors.black, weight: FontWeight.bold)),
                            Padding(
                              padding: SizeUtil.padding(top: 5),
                              child: Text(
                                  showAssets
                                      ? '≈${strIsEmpty(coin.csUnit) ? defaultCSUnit : coin.csUnit}${strIsEmpty(coin.totalPrice) ? '0.00' : coin.totalPrice}'
                                      : "****",
                                  style: StyleUtil.textStyle(size: SizeUtil.sp(10), color: Colors.grey, weight: FontWeight.bold)),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  diver
                      ? Divider(
                          height: 1,
                        )
                      : Container(
                          width: 0,
                          height: 0,
                  )
                ],
              )),
          main
              ? Container(
                  height: 0,
                  width: 0,
                )
              : Positioned(
                  bottom: SizeUtil.width(5),
                  left: SizeUtil.width(40),
                  child: Container(
                    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.all(Radius.circular(2))),
                    padding: SizeUtil.padding(left: 3, right: 3, top: 1, bottom: 1),
                    child: Text(
                      '${fixChainName(coin.contract)}',
                      style: TextStyle(fontSize: SizeUtil.sp(6), color: Colors.white),
                    ),
                  ))
        ],
      ),
    );
  }

  Widget createGroup() {}

  _changeIdentity(Identity identity) {
    Get.back();
    if (identity == _homeController.identity.value) {
      return;
    }
    _refreshController?.callRefresh();
    _homeController.changeIdentity(identity);
    SPUtils().put(Constant.CUSTOM_WID, identity.wid);
    eventBus.fire(UpdateIdentity(identity));
  }

  String fixChainName(name) {
    if (name == 'BNB') {
      return 'BSC';
    }
    if (name == 'TRX') {
      return 'TRON';
    }
    return name;
  }

  @override
  bool get wantKeepAlive => true;
}

class HomePanelItem {
  Coin chain;
  List<Coin> items;
  bool isExpanded = false;
}

class ExpansionPanelItem {
  final Coin chain;
  final Widget body;
  bool isExpanded = false;

  ExpansionPanelItem({
    this.chain,
    this.body,
    this.isExpanded,
  });
}
