import 'dart:convert';

import 'package:cube/core/base_widget.dart';
import 'package:cube/core/constant.dart';
import 'package:cube/models/model_base.dart';
import 'package:cube/models/model_detail.dart';
import 'package:cube/net/manager_api.dart';
import 'package:cube/net/requester.dart';
import 'package:cube/pages/page_collect.dart';
import 'package:cube/pages/page_pay.dart';
import 'package:cube/pages/page_trans_detail.dart';
import 'package:cube/utils/utils_console.dart';
import 'package:cube/utils/utils_db.dart';
import 'package:cube/utils/utils_event.dart';
import 'package:cube/utils/utils_sp.dart';
import 'package:cube/views/dialog/dialog_widget_board.dart';
import 'package:flutter/material.dart';
import 'package:cube/utils/utils_size.dart';
import 'package:cube/views/appbar/appbar.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:cube/core/core.dart';

class PageCoinDetail extends StatefulWidget {
  const PageCoinDetail({Key key}) : super(key: key);

  @override
  _PageCoinDetailState createState() => _PageCoinDetailState();
}

class _PageCoinDetailState extends SizeState<PageCoinDetail> {
  Color _color = BeeColors.green;
  List<TabModel> tabs = [
    TabModel.create("CommonAll".tr, "all"),
    TabModel.create("CommonTransferOut".tr, "out"),
    TabModel.create("CommonTransferIn".tr, "in"),
    TabModel.create("CommonFailed".tr, "fail")
  ];

  bool isTron = false;

  int pageAll = 1;
  int pageOut = 1;
  int pageIn = 1;
  int pageFailed = 1;
  EasyRefreshController _refreshControllerAll = EasyRefreshController();
  EasyRefreshController _refreshControllerOut = EasyRefreshController();
  EasyRefreshController _refreshControllerIn = EasyRefreshController();
  EasyRefreshController _refreshControllerFailed = EasyRefreshController();
  ScrollController _scrollViewController;
  TabController _tabController;
  Coin _data;

  List<CoinTrans> transAll = [];
  List<CoinTrans> transOut = [];
  List<CoinTrans> transIn = [];
  List<CoinTrans> transFail = [];

  @override
  void initState() {
    super.initState();
    _data = Get.arguments['data'];
    if (_data.privateKey.isEmpty) {
      updateData();
    }
    if (_data.contract.toUpperCase() == "TRX") {
      isTron = true;
    } else {
      isTron = false;
    }
    _color = _data.color.toColor();
    _scrollViewController = ScrollController(initialScrollOffset: 0.0);
    _tabController = TabController(vsync: this, length: tabs.length);

    var all = SPUtils().getString('Trade:${_data.id}_all');
    if (all is String && !strIsEmpty(all)) {
      CoinTransModel data = CoinTransModel().parser(jsonDecode(all)['data']);
      transAll.addAll(data.items);
    }

    _requestAll();
    _requestOut();
    _requestIn();
    _requestFailed();
  }

  void updateData() async {
    Identity identity = await DBHelper().queryIdentity(_data.wid);
    if (identity != null) {
      _data.privateKey = identity.privateKey;
      _data.token = identity.token;
      setState(() {});
    }
  }

  Widget createView(BuildContext context) {
    return Scaffold(
        appBar: XAppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_outlined),
            onPressed: () {
              Get.back();
            },
          ),
          backgroundColor: _color,
          centerTitle: true,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            _data != null ? _data.symbol : "",
            style: TextStyle(color: Colors.white, fontSize: SizeUtil.sp(20)),
          ),
          actions: _data != null && _data.symbol != _data.contract
              ? [
                  Builder(
                    builder: (context) {
                      return SizedBox(
                        child: IconButton(
                          icon: Icon(
                            Icons.more_horiz_outlined,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            _showActionDialog();
                          },
                        ),
                      );
                    },
                  )
                ]
              : [],
        ),
        body: Stack(
          children: [
            Container(
              height: double.infinity,
              padding: SizeUtil.padding(bottom: 84),
              child: _buildContent(),
            ),
            Positioned(bottom: 0, left: 0, child: _createButtons()),
          ],
        ),
    );
  }

  Widget _buildRefresh(child, EasyRefreshController controller, refreshCallback, {noMore: true, loadCallback}) {
    var refreshView = EasyRefresh(
      header: MaterialHeader(),
      onRefresh: () async {
        await refreshCallback();
        controller.finishRefresh(success: true);
      },
      onLoad: loadCallback != null
          ? () async {
              await loadCallback();
              controller.finishLoad(success: true, noMore: noMore);
            }
          : null,
      controller: controller,
      child: child,
    );
    return refreshView;
  }

  Widget _buildContent() {
    return NestedScrollView(
        controller: _scrollViewController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              pinned: true,
              floating: true,
              expandedHeight: isTron ? SizeUtil.height(215) : SizeUtil.height(140),
              automaticallyImplyLeading: false,
              flexibleSpace: isTron
                  ? FlexibleSpaceBar(
                      collapseMode: CollapseMode.pin,
                      background: Stack(
                        children: [
                          Container(
                            height: SizeUtil.height(140),
                            width: double.infinity,
                            color: _color,
                            child: Column(
                              children: <Widget>[
                                _buildTop(),
                                Container(
                                  height: SizeUtil.height(40),
                                )
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 7, right: 7, top: SizeUtil.height(105)),
                            height: SizeUtil.height(110),
                            child: Column(
                              children: <Widget>[
                                _buildTron(),
                                Container(
                                  height: SizeUtil.height(2),
                                  color: Colors.transparent,
                                ),
                                _buildTabBarBg()
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  : FlexibleSpaceBar(
                      collapseMode: CollapseMode.pin,
                      background: Container(
                        height: double.infinity,
                        color: _color,
                        child: Column(
                          children: <Widget>[_buildTop(), _buildTabBarBg()],
                        ),
                      ),
                    ),
              bottom: PreferredSize(
                preferredSize: Size(SizeUtil.screenWidth(), SizeUtil.height(40)),
                child: Container(
                  padding: SizeUtil.padding(left: 10, right: 10),
                  child: TabBar(
                      controller: _tabController,
                      indicatorWeight: SizeUtil.height(2),
                      indicatorColor: _color,
                      indicatorPadding: SizeUtil.padding(left: 20, right: 20),
                      tabs: tabs
                          .map((e) => Tab(
                                text: e.name,
                              ))
                          .toList()),
                ),
              ),
            )
          ];
        },
        body: Container(
          child: TabBarView(controller: _tabController, children: [
            _buildTrans("all"),
            _buildTrans("out"),
            _buildTrans("in"),
            _buildTrans("fail"),
          ]),
        ));
  }

  Widget _buildTron() {
    return Container(
      margin: SizeUtil.margin(left: 7, right: 7),
      height: SizeUtil.height(68),
      decoration: new BoxDecoration(
        boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.05), blurRadius: 2)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(SizeUtil.width(13))),
        child: Container(
          color: Theme.of(context).appBarTheme.backgroundColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(left: SizeUtil.width(11)),
                    child: Image(
                      image: AssetImage(
                        Constant.Assets_Image + "common_band.png",
                      ),
                      width: SizeUtil.width(20),
                      height: SizeUtil.width(20),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: SizeUtil.width(6)),
                    child: Text(
                      "WalletTronBand:".tr,
                      style: StyleUtil.textStyle(size: 14, color: BeeColors.FF091C40),
                    ),
                  ),
                  Spacer(),
                  Container(
                    child: Text(
                      (int.parse(_data.netLimit != null && _data.netLimit.isNotEmpty ? _data.netLimit : "0") -
                              int.parse(_data.netUsed != null && _data.netUsed.isNotEmpty ? _data.netUsed : "0"))
                          .toString(),
                      style: StyleUtil.textStyle(size: 14, color: BeeColors.FF091C40),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: SizeUtil.width(15)),
                    child: Text(
                      "/${_data.netLimit != null && _data.netLimit.isNotEmpty ? _data.netLimit : "0"}",
                      style: StyleUtil.textStyle(size: 14, color: BeeColors.FFA2A6B0),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: SizeUtil.height(4),
              ),
              Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(left: SizeUtil.width(11)),
                    child: Image(
                      image: AssetImage(
                        Constant.Assets_Image + "common_energy.png",
                      ),
                      width: SizeUtil.width(20),
                      height: SizeUtil.width(20),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: SizeUtil.width(6)),
                    child: Text(
                      "WalletTronEnergy:".tr,
                      style: StyleUtil.textStyle(size: 14, color: BeeColors.FF091C40),
                    ),
                  ),
                  Spacer(),
                  Container(
                    child: Text(
                      (int.parse(_data.energyLimit != null && _data.energyLimit.isNotEmpty ? _data.energyLimit : "0") -
                              int.parse(_data.energyUsed != null && _data.energyUsed.isNotEmpty ? _data.energyUsed : "0"))
                          .toString(),
                      style: StyleUtil.textStyle(size: 14, color: BeeColors.FF091C40),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: SizeUtil.width(15)),
                    child: Text(
                      ("/${_data.energyLimit != null && _data.energyLimit.isNotEmpty ? _data.energyLimit : "0"}"),
                      style: StyleUtil.textStyle(size: 14, color: BeeColors.FFA2A6B0),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTop() {
    return Expanded(
      flex: 1,
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: SizeUtil.padding(top: 8, bottom: 8),
              child: Text(
                _data != null ? _data.balance : "--",
                style: StyleUtil.textStyle(size: 33, color: Colors.white, weight: FontWeight.bold),
              ),
            ),
            Container(
              child: Text(
                _data != null ? '${_data.csUnit}${_data.totalPrice}' : "--",
                style: StyleUtil.textStyle(size: 14, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBarBg() {
    return Container(
      margin: SizeUtil.margin(left: 7, right: 7),
      height: SizeUtil.height(40),
      child: ClipRRect(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(SizeUtil.width(4)), topRight: Radius.circular(SizeUtil.width(4))),
          child: Container(color: Theme.of(context).appBarTheme.backgroundColor)),
    );
  }

  Widget _buildTrans(type) {
    switch (type) {
      case "all":
        return _buildRefresh(_buildTransList(transAll), _refreshControllerAll, () async {
          pageAll = 1;
          _requestAll();
        });
      case "out":
        return _buildRefresh(_buildTransList(transOut), _refreshControllerOut, () async {
          pageOut = 1;
          _requestOut();
        });
      case "in":
        return _buildRefresh(_buildTransList(transIn), _refreshControllerIn, () async {
          pageIn = 1;
          _requestIn();
        });
      case "fail":
        return _buildRefresh(_buildTransList(transFail), _refreshControllerFailed, () async {
          pageFailed = 1;
          _requestFailed();
        });
      default:
        return Container(
          height: 0,
        );
    }
  }

  Widget _buildTransList(List<CoinTrans> data) {
    if (data == null || data.isEmpty) {
      return Container(
        margin: SizeUtil.margin(top: 100),
        child: Column(
          children: [
            SvgPicture.asset(
              'assets/icons/icon_no_data.svg',
              width: SizeUtil.width(80),
            ),
            Text(
              'CommonNoData'.tr,
              style: Theme.of(context).primaryTextTheme.subtitle1,
            )
          ],
        ),
      );
    }
    return ListView.separated(
        itemCount: data.length,
        separatorBuilder: (BuildContext context, int index) => Divider(
              color: Colors.grey[350],
              height: 1,
            ),
        itemBuilder: (BuildContext context, int index) {
          CoinTrans item = data[index];
          String symbel = "-";
          String iconUrl = "assets/icons/icon_trans_out.png";
          String address = '';
          if (item.type == 'in') {
            iconUrl = "assets/icons/icon_trans_in.png";
            symbel = "+";
            address = item.from;
          } else if (item.type == 'out') {
            iconUrl = "assets/icons/icon_trans_out.png";
            symbel = "-";
            address = item.to;
          }
          if (item.status == 'failed') {
            iconUrl = "assets/icons/icon_trans_pending.png";
          }

          return InkWell(
            onTap: () {
              console.i(item);
              var json = item.toJson();
              console.i(json);
              console.i(_data.toJson());
              json['color'] = _data.color;
              json['symbol'] = _data.symbol;
              Get.to(PageTransDetail(), arguments: json);
            },
            child: Container(
                padding: SizeUtil.padding(left: 10, right: 10, top: 10, bottom: 10),
                child: Row(
                  children: [
                    Container(
                      padding: SizeUtil.padding(left: 10, right: 10),
                      child: Image.asset(
                        iconUrl,
                        width: SizeUtil.width(25),
                        height: SizeUtil.height(25),
                      ),
                    ),
                    Expanded(
                        child: Container(
                      padding: SizeUtil.padding(right: 13),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatAddress(address),
                            style: Theme.of(context).primaryTextTheme.headline4,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Container(
                            padding: SizeUtil.padding(top: 5),
                            child: Text(
                              "${item.time}",
                              style: Theme.of(context).primaryTextTheme.subtitle2,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        ],
                      ),
                    )),
                    Container(
                      padding: SizeUtil.padding(right: 10),
                      child: Text(
                        "$symbel ${item.value}",
                        style: Theme.of(context).primaryTextTheme.headline6.merge(TextStyle(fontWeight: FontWeight.normal)),
                      ),
                    ),
                  ],
                )),
          );
        });
  }

  _requestAll() async {
    Result<CoinTransModel> result = await requestHistory({
      "address": _data.address,
      "contract": _data.contract,
      "contractAddress": _data.contractAddress,
      "condition": "all",
      "page": pageAll,
      "size": 100
    });
    if (pageAll == 1) {
      transAll.clear();
    }
    if (mounted && result != null && result.result != null && result.result.items != null) {
      setState(() {
        transAll.addAll(result.result.items);
        SPUtils().put('Trade:${_data.id}_all', jsonEncode(result.origin));
      });
    }
  }

  _requestOut() async {
    Result<CoinTransModel> result = await requestHistory({
      "address": _data.address,
      "contract": _data.contract,
      "contractAddress": _data.contractAddress,
      "condition": "out",
      "page": pageAll,
      "size": 100
    });
    if (pageOut == 1) {
      transOut.clear();
    }

    if (mounted && result != null && result.result != null && result.result.items != null) {
      setState(() {
        transOut.addAll(result.result.items);
      });
    }
  }

  _requestIn() async {
    Result<CoinTransModel> result = await requestHistory({
      "address": _data.address,
      "contract": _data.contract,
      "contractAddress": _data.contractAddress,
      "condition": "in",
      "page": pageIn,
      "size": 100
    });
    if (pageIn == 1) {
      transIn.clear();
    }
    if (mounted && result != null && result.result != null && result.result.items != null) {
      setState(() {
        transIn.addAll(result.result.items);
      });
    }
  }

  _requestFailed() async {
    Result<CoinTransModel> result = await requestHistory({
      "address": _data.address,
      "contract": _data.contract,
      "contractAddress": _data.contractAddress,
      "condition": "failed",
      "page": pageFailed,
      "size": 100
    });
    if (pageFailed == 1) {
      transFail.clear();
    }
    if (mounted && result != null && result.result != null && result.result.items != null) {
      setState(() {
        transFail.addAll(result.result.items);
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    _scrollViewController.dispose();
  }

  _createButtons() {
    num height = SizeUtil.height(36);
    return Container(
      width: SizeUtil.screenWidth(),
      height: SizeUtil.height(84),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MaterialButton(
            onPressed: () {
              if (_data != null) {
                Get.to(PagePay(), arguments: _data.toJson());
              }
            },
            color: _color,
            minWidth: SizeUtil.width(148),
            height: height,
            shape: RoundedRectangleBorder(
              side: BorderSide.none,
              borderRadius: SizeUtil.radius(all: 100),
            ),
            child: Text(
              'WalletTransfer'.tr,
              style: StyleUtil.textStyle(size: 14, color: Colors.white),
            ),
          ),
          MaterialButton(
            onPressed: () {
              if (_data != null) {
                Get.to(PageCollect(), arguments: _data.toJson());
              }
            },
            color: BeeColors.green,
            minWidth: SizeUtil.width(148),
            height: height,
            shape: RoundedRectangleBorder(
              side: BorderSide.none,
              borderRadius: SizeUtil.radius(all: 100),
            ),
            child: Text(
              'WalletReceive'.tr,
              style: StyleUtil.textStyle(size: 14, color: Colors.white),
            ),
          )
        ],
      ),
    );
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

  _hideCoin(Coin coin) async {
    showLoading();
    await DBHelper().deleteCoin(coin);
    await requestHideCoin({'wid': coin.wid, "tokenID": coin.tokenID});
    showLoading(show: false);
  }

  _showActionDialog() {
    showDialog(
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
                        await _hideCoin(_data);
                        eventBus.fire(UpdateChain());
                        Get.back(result: {"action": Constant.ACTION_REFRESH});
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

class StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar child;

  StickyTabBarDelegate({@required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return this.child;
  }

  @override
  double get maxExtent => this.child.preferredSize.height;

  @override
  double get minExtent => this.child.preferredSize.height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
