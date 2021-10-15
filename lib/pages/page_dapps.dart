import 'package:cached_network_image/cached_network_image.dart';
import 'package:cube/core/base_widget.dart';
import 'package:cube/core/constant.dart';
import 'package:cube/core/core.dart';
import 'package:cube/models/model_base.dart';
import 'package:cube/models/model_dapp.dart';
import 'package:cube/net/manager_api.dart';
import 'package:cube/net/requester.dart';
import 'package:cube/pages/page_dapps_search.dart';
import 'package:cube/pages/page_web.dart';
import 'package:cube/utils/utils_size.dart';
import 'package:cube/utils/utils_sp.dart';
import 'package:cube/views/CustomBehavior.dart';
import 'package:cube/views/appbar/flex_space_bar.dart';
import 'package:cube/views/dialog/dialog_dapp_auth_board.dart';
import 'package:flutter/material.dart' hide NestedScrollView;
import 'package:flutter_card_swipper/flutter_card_swiper.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import 'package:cube/utils/utils_console.dart';

class PageDapps extends StatefulWidget {
  PageDapps({Key key}) : super(key: key);

  @override
  _PageDappsState createState() => _PageDappsState();
}

class PageDappsController extends GetxController {
  var banners = [].obs;
  var hots = [].obs;
  var groupItems = {}.obs;

  changeHots(data) {
    if (data != null) {
      hots.value = data;
    }
  }

  changeBanners(data) {
    if (data != null) {
      banners.value = data;
    }
  }

  initGroupItems(key) {
    groupItems[key] = [];
  }

  changeGroupItems(key, data, {bool renew = false}) {
    if (groupItems[key] == null) {
      groupItems[key] = [];
    }
    if (data != null) {
      if (renew) {
        groupItems[key] = data;
      } else {
        groupItems[key].addAll(data);
      }
    } else {
      if (renew) {
        groupItems[key].clear();
      }
    }
  }
}

class _PageDappsState extends SizeState<PageDapps> {
  TabController _tabController;
  var tabIndex = 0.obs;
  List<Coin> tabViews = [];
  List<Widget> tabPages = [];
  int _length1 = 50;
  DateTime lastRefreshTime = DateTime.now();
  double maxDragOffset = SizeUtil.width(100);
  PageDappsController _dappsController = PageDappsController();

  @override
  void initState() {
    tabViews = Global.SUPORT_DAPPS;
    _tabController = TabController(length: tabViews.length, vsync: this);
    _tabController.addListener(() {
      if (mounted) {
        setState(() {
          tabIndex = _tabController.index.obs;
        });
      }
    });
    super.initState();
  }

  _requestDapps() async {
    Result<Dapps> result = await requestDapps({});
    if (result.result.groups != null) {
      _dappsController.changeHots(result.result.hots);
      result.result.groups.forEach((key, value) {
        _dappsController.changeGroupItems(key, value, renew: true);
      });
      _dappsController.changeBanners(result.result.banners);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget createView(BuildContext context) {
    return Scaffold(
        backgroundColor: Get.isDarkMode ? Colors.black26 : Colors.grey[50],
        body: GetBuilder<PageDappsController>(
          init: _dappsController,
          initState: (builder) {
            _requestDapps();
          },
          builder: (controller) => _buildScaffoldBody(),
        ),
    );
  }

  Widget _createSwiper() {
    return Obx(() => _dappsController.banners.length == 0
        ? Container(
            width: 0,
            height: 0,
          )
        : Container(
            child: Swiper(
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  height: SizeUtil.width(160),
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: _dappsController.banners[index].image,
                    placeholder: (context, url) => Image.asset(
                      Constant.Assets_Image + "banner_placeholder.png",
                    ),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                );
              },
              autoplay: _dappsController.banners.length > 1,
              autoplayDelay: 5000,
              itemCount: _dappsController.banners.length,
            ),
          ),
    );
  }

  SliverAppBar _appBar;

  Widget _buildScaffoldBody() {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double pinnedHeaderHeight = statusBarHeight + kToolbarHeight;

    num expandedHeight = SizeUtil.width(140) + statusBarHeight;

    _appBar = SliverAppBar(
      expandedHeight: expandedHeight,
      floating: true,
      pinned: true,
      snap: true,
      flexibleSpace: FlexSpaceBar(
        titlePadding: SizeUtil.padding(),
        title: Container(
          padding: SizeUtil.padding(left: 10, right: 10, bottom: 3),
          alignment: Alignment.center,
          height: SizeUtil.width(10) + statusBarHeight,
          child: InkWell(
            onTap: () {
              Get.to(PageDappSearch());
            },
            child: Container(
              padding: SizeUtil.padding(left: 10, right: 10),
              width: double.infinity,
              height: SizeUtil.width(25),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey[50]),
                borderRadius: BorderRadius.all(Radius.circular(SizeUtil.width(50))),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      offset: Offset(0, 1.0),
                      blurRadius: 1,
                      spreadRadius: 0
                      )
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search,
                    color: Colors.grey[400],
                    size: SizeUtil.width(12),
                  ),
                  Expanded(
                    child: Padding(
                      padding: SizeUtil.padding(left: 2),
                      child: Text(
                        "DiscoverSearchDapp".tr,
                        style: Theme.of(context).primaryTextTheme.subtitle2.merge(TextStyle(fontSize: SizeUtil.sp(8))),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        background: Container(
          color: Get.isDarkMode ? Colors.black26 : Colors.grey[50],
          alignment: Alignment.center,
          height: expandedHeight,
          child: Column(
            children: [
              Container(
                height: expandedHeight,
                width: double.infinity,
                child: _createSwiper(),
              )
            ],
          ),
        ),
      ),
    );

    return PullToRefreshNotification(
      color: Colors.blue,
      pullBackDuration: Duration(milliseconds: 100),
      onRefresh: () async {
        String chain = tabViews[_tabController.index].symbol;
        await _requestDapps();
        return Future.value(true);
      },
      maxDragOffset: maxDragOffset,
      child: GlowNotificationWidget(
        NestedScrollView(
          headerSliverBuilder: (BuildContext c, bool f) {
            return <Widget>[
              PullToRefreshContainer((PullToRefreshScrollNotificationInfo info) {
                return SliverToBoxAdapter(
                    child: PullHeaderAnimator(
                  info,
                  lastRefreshTime,
                ));
              }),
              _appBar,
            ];
          },
          pinnedHeaderSliverHeightBuilder: () {
            return pinnedHeaderHeight;
          },
          innerScrollPositionKeyBuilder: () {
            String index = 'Tab';
            index += tabViews[_tabController.index].symbol;
            return Key(index);
          },
          body: ScrollConfiguration(
            behavior: CustomBehavior(),
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                Container(
                  height: SizeUtil.width(30),
                  width: SizeUtil.screenW,
                  margin: SizeUtil.margin(left: 20, right: 20, top: 10),
                  child: Text(
                    "DiscoverHotDApp".tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: StyleUtil.textStyle(
                      size: SizeUtil.sp(14),
                      color: BeeColors.FF091C40,
                      weight: FontWeight.bold,
                    ),
                  ),
                ),
                Obx(() => _dappsController.hots != null
                    ? Container(
                        child: createGridview(),
                      )
                    : Container(
                        width: 0,
                        height: 0,
                      )),
                Container(
                  color: Get.isDarkMode ? Colors.black26 : Colors.white,
                  alignment: Alignment.topLeft,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Colors.blue,
                    indicatorColor: Colors.blue,
                    indicatorSize: TabBarIndicatorSize.label,
                    indicatorWeight: SizeUtil.width(2),
                    isScrollable: true,
                    unselectedLabelColor: Colors.grey,
                    tabs: tabViews.map((e) {
                      return Tab(text: e.chainName);
                    }).toList(),
                    onTap: (index) {
                      console.i(index);
                    },
                  ),
                ),
                Obx(() => Container(
                      height: (SizeUtil.width(35) + SizeUtil.height(44)) * _getTabViewCount(tabIndex) + 14,
                      child: TabBarView(
                        controller: _tabController,
                        children: tabViews.map((e) {
                          return Obx(() => NestedScrollViewInnerScrollPositionKeyWidget(
                                Key('Tab${e.symbol}'),
                                _dappsController.groupItems.value[e.symbol] == null || _dappsController.groupItems.value[e.symbol].length == 0
                                    ? buildEmpty()
                                    : ListView.builder(
                                        //store Page state
                                        key: PageStorageKey<String>('Tab${e.symbol}'),
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemBuilder: (BuildContext context, int index) {
                                          return _itemBuildWidget(context, index, e);
                                        },
                                        itemCount: _getListCount(e),
                                        padding: EdgeInsets.all(0.0),
                                      ),
                              ));
                        }).toList(),
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _getTabViewCount(RxInt tabIndex) {
    int itemCount = 0;
    Coin coin = tabViews[tabIndex.value];
    if (_dappsController.groupItems.value[coin.symbol] != null) {
      itemCount = _dappsController.groupItems.value[coin.symbol].length;
    }
    return itemCount;
  }

  int _getListCount(Coin coin) {
    int itemCount = 0;
    if (_dappsController.groupItems.value[coin.symbol] != null) {
      itemCount = _dappsController.groupItems.value[coin.symbol].length;
    }
    return itemCount;
  }

  Widget _itemBuildWidget(BuildContext context, int index, Coin coin) {
    Dapp item = _dappsController.groupItems.value[coin.symbol][index];
    return Card(
      shadowColor: Colors.grey[50],
      elevation: 1,
      margin: SizeUtil.margin(left: 14, right: 14, top: 14),
      child: InkWell(
        onTap: () async {
          bool hasChain = false;
          Global.CURRENT_CONIS.forEach((element) {
            if (element.contract == item.chain) {
              hasChain = true;
              return;
            }
          });
          if (!hasChain) {
            showWarnBar(("WalletAddMainTip".tr).replaceAll('{%s}', item.chain));
            return;
          }
          bool has = SPUtils().getBool('DAPP:${item.name}');
          if (!has) {
            await showDialog(
                useSafeArea: false,
                context: context,
                builder: (builder) {
                  return DialogDappAuthBoard(
                    icon: item.icon,
                    name: item.name,
                    chain: item.chain,
                    callback: (result) async {
                      SPUtils().put('DAPP:${item.name}', result);
                      Get.back();
                      if (result) {
                        Get.to(PageWeb(), arguments: {"url": item.url, "dapp": item});
                      }
                    },
                  );
                });
          } else {
            Get.to(PageWeb(), arguments: {"url": item.url, "dapp": item});
          }
        },
        child: Container(
            padding: SizeUtil.padding(left: 10, right: 10, top: 10, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: SizeUtil.width(35) + SizeUtil.height(10),
                  margin: SizeUtil.margin(right: 12),
                  padding: SizeUtil.padding(all: 5),
                  decoration: BoxDecoration(
                      color: Colors.grey[50], border: Border.all(color: Colors.grey[100]), borderRadius: BorderRadius.all(Radius.circular(6.0))),
                  child: CachedNetworkImage(
                    width: SizeUtil.width(35),
                    height: SizeUtil.width(35),
                    imageUrl: item.icon,
                    placeholder: (context, url) => Image.asset(
                      Constant.Assets_Image + "common_placeholder.png",
                    ),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
                Expanded(
                    child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${item.name}",
                        style: Theme.of(context).primaryTextTheme.headline4,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Container(
                        padding: SizeUtil.padding(top: 5),
                        child: Text(
                          "${item.desc}",
                          style: Theme.of(context).primaryTextTheme.subtitle2,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    ],
                  ),
                )),
              ],
            )),
      ),
    );
  }

  Widget createGridview() {
    return GridView.builder(
        padding: EdgeInsets.all(SizeUtil.width(5)),
        shrinkWrap: true,
        controller: new ScrollController(keepScrollOffset: false),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _dappsController.hots.length > 10 ? 10 : _dappsController.hots.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          mainAxisSpacing: SizeUtil.width(5),
          crossAxisSpacing: SizeUtil.width(5),
          childAspectRatio: 8 / 10,
        ),
        itemBuilder: (BuildContext context, int index) {
          Dapp dapp = _dappsController.hots[index];
          return getItemContainer(dapp);
        });
  }

  Widget getItemContainer(Dapp item) {
    return InkWell(
      onTap: () async {
        bool hasChain = false;
        Global.CURRENT_CONIS.forEach((element) {
          if (element.contract == item.chain) {
            hasChain = true;
            return;
          }
        });
        if (!hasChain) {
          showWarnBar(("WalletAddMainTip".tr).replaceAll('{%s}', item.chain));
          return;
        }
        bool has = SPUtils().getBool('DAPP:${item.name}');
        if (!has) {
          await showDialog(
              useSafeArea: false,
              context: context,
              builder: (builder) {
                return DialogDappAuthBoard(
                  icon: item.icon,
                  name: item.name,
                  chain: item.chain,
                  callback: (result) async {
                    SPUtils().put('DAPP:${item.name}', result);
                    Get.back();
                    if (result) {
                      Get.to(PageWeb(), arguments: {"url": item.url, "dapp": item});
                    }
                  },
                );
              });
        } else {
          Get.to(PageWeb(), arguments: {"url": item.url, "dapp": item});
        }
      },
      child: Container(
        height: SizeUtil.width(92),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: SizeUtil.padding(all: 5),
              decoration: BoxDecoration(
                  color: Colors.grey[50], border: Border.all(color: Colors.grey[100]), borderRadius: BorderRadius.all(Radius.circular(6.0))),
              child: CachedNetworkImage(
                width: SizeUtil.width(35),
                height: SizeUtil.width(35),
                imageUrl: item.icon,
                placeholder: (context, url) => Image.asset(
                  Constant.Assets_Image + "common_placeholder.png",
                ),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
            Container(
              padding: SizeUtil.padding(top: 5),
              alignment: Alignment.center,
              child: Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: StyleUtil.textStyle(
                  size: SizeUtil.sp(12),
                  color: BeeColors.FF091C40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class PullHeaderAnimator extends StatefulWidget {
  final PullToRefreshScrollNotificationInfo info;
  final DateTime lastRefreshTime;
  final Color color;

  const PullHeaderAnimator(this.info, this.lastRefreshTime, {this.color, Key key}) : super(key: key);

  @override
  _PullHeaderAnimatorState createState() => _PullHeaderAnimatorState();
}

class _PullHeaderAnimatorState extends State<PullHeaderAnimator> with SingleTickerProviderStateMixin {
  AnimationController loadingController;

  @override
  void initState() {
    super.initState();
    loadingController = AnimationController(vsync: this)
      ..addListener(() {})
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          loadingController.repeat();
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.info == null) {
      return Container();
    }
    String text = '';
    if (widget.info.mode == RefreshIndicatorMode.armed) {
      loadingController.reset();
      text = 'CommonRefreshTip'.tr;
    } else if (widget.info.mode == RefreshIndicatorMode.refresh || widget.info.mode == RefreshIndicatorMode.snap) {
      text = 'CommonLoading'.tr;
      loadingController.forward();
    } else if (widget.info.mode == RefreshIndicatorMode.done) {
      text = 'CommonLoadFinish'.tr;
    } else if (widget.info.mode == RefreshIndicatorMode.drag) {
      text = 'CommonRefreshDown'.tr;
    } else if (widget.info.mode == RefreshIndicatorMode.canceled) {
      text = 'CommonRefreshDownCancel'.tr;
    }

    final TextStyle ts = TextStyle(
      color: Colors.grey,
    ).copyWith(fontSize: 14);

    final double dragOffset = widget.info?.dragOffset ?? 0.0;
    return Container(
      height: dragOffset,
      color: widget.color ?? Colors.transparent,
      child: Stack(
        children: <Widget>[
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Container(
                    alignment: Alignment.centerRight,
                    child: Container(
                      height: 100,
                    ),
                    margin: EdgeInsets.only(right: 12.0),
                  ),
                ),
                Column(
                  children: <Widget>[
                    createLottie(),
                    Text(
                      text,
                      style: ts,
                    ),
                  ],
                ),
                Expanded(
                  child: Container(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget createLottie() {
    return Container(
      child: Lottie.asset(
        'assets/lottie_loading.json',
        controller: loadingController,
        width: SizeUtil.width(70),
        onLoaded: (composition) {
          loadingController
            ..duration = Duration(milliseconds: 1500);
        },
      ),
    );
  }
}
