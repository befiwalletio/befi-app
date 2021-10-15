import 'package:cached_network_image/cached_network_image.dart';
import 'package:cube/core/base_widget.dart';
import 'package:cube/core/constant.dart';
import 'package:cube/core/core.dart';
import 'package:cube/models/model_base.dart';
import 'package:cube/models/model_dapp.dart';
import 'package:cube/net/manager_api.dart';
import 'package:cube/net/requester.dart';
import 'package:cube/pages/page_web.dart';
import 'package:cube/utils/utils_size.dart';
import 'package:cube/utils/utils_sp.dart';
import 'package:cube/views/appbar/appbar.dart';
import 'package:cube/views/dialog/dialog_dapp_auth_board.dart';
import 'package:cube/views/dialog/dialog_loading.dart';
import 'package:cube/views/dialog/dialog_widget_board.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:get/get.dart';
import 'package:cube/utils/utils_console.dart';
import 'package:sticky_headers/sticky_headers.dart';

class PageDappSearch extends StatefulWidget {
  const PageDappSearch({Key key}) : super(key: key);

  @override
  _PageSearchState createState() => _PageSearchState();
}

class PageDappSearchController extends GetxController {
  var showEmpty = false.obs;
  var showLoading = false.obs;
  var showClear = false.obs;
  var showSearchLoading = false.obs;
  var searchItems = [].obs;
  var items = <Dapp>[].obs;

  var showHistLabel = false.obs;
  var showHistList = <String>[].obs;

  var showCommentLabel = false.obs;
  var showCommentList = <String>[].obs;

  setHistList(data) {
    if (data == null) {
      data = [];
    }
    List<String> temp = [];
    data.forEach((el) {
      temp.add('$el');
    });
    showHistList.clear();
    showHistList.addAll(temp);
    showHistLabel.value = data.length > 0;
  }

  setCommentList(data) {
    if (data == null) {
      data = <String>[];
    }
    showCommentList.clear();
    showCommentList.addAll(data);
    showCommentLabel.value = data.length > 0;
  }

  setSearchItems(data) {
    if (data == null) {
      data = [];
    }
    searchItems.clear();
    searchItems.addAll(data);
    showSearchLoading.value = false;
    changeShowEmpty(show: data.length == 0);
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

  setSearchLoading({show: true}) {
    showSearchLoading.value = show;
  }

  changeShowClear(bool show) {
    if (showClear.value != show) {
      showClear.value = show;
    }
  }

  changeShowEmpty({bool show = true}) {
    showEmpty.value = show;
  }
}

class _PageSearchState extends SizeState<PageDappSearch> {
  String _wid = '';
  Color _color = BeeColors.blue;
  TextEditingController _searchController = TextEditingController();
  EasyRefreshController _refreshController = EasyRefreshController();
  PageDappSearchController _pageController = Get.put(PageDappSearchController());
  ScrollController _scrollController = ScrollController();

  bool _needRefresh = false;

  @override
  void initState() {
    super.initState();
    _wid = SPUtils().getString(Constant.CUSTOM_WID);
    _querySearchHistory();
    _requestCommentDapps();
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
        onWillPop: () {},
        child: Scaffold(
            backgroundColor: Get.isDarkMode ? Colors.black : Colors.grey[100],
            appBar: XAppBar(
              leading: Container(
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_outlined,
                    size: SizeUtil.width(20),
                  ),
                  onPressed: () {
                    if (_needRefresh) {
                      Get.back(result: {"action": Constant.ACTION_REFRESH});
                    } else {
                      Get.back();
                    }
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
                      hintText: '${'DiscoverSearchDapp'.tr}',
                      hintStyle: StyleUtil.textStyle(size: 12, color: Colors.grey[350])),
                  style: StyleUtil.textStyle(size: 12, weight: FontWeight.bold, color: Colors.white),
                  obscureText: false,
                  keyboardType: TextInputType.text,
                  textAlign: TextAlign.left,
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (text) {
                    FocusScope.of(context).requestFocus(FocusNode());
                    _actionSearch();
                  },
                  onChanged: (text) {
                    _pageController.changeShowClear(!strIsEmpty(text));
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
                        Obx(() => !_pageController.showClear.value
                            ? SizedBox(
                                width: 0,
                                height: 0,
                              )
                            : Container(
                                width: SizeUtil.width(25),
                                height: SizeUtil.width(25),
                                alignment: Alignment.center,
                                child: IconButton(
                                    icon: Icon(Icons.clear, size: SizeUtil.width(20)),
                                    padding: SizeUtil.padding(),
                                    onPressed: () {
                                      _searchController.text = '';
                                      _pageController.changeShowClear(false);
                                    }),
                              )),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              await _actionSearch();
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
            body: buildRefresh(
                ListView(controller: _scrollController, children: [
                  Obx(() => _pageController.showCommentLabel.value
                      ? StickyHeader(
                          header: _createLabel("大家都在搜".tr),
                          content: Container(
                            // color: Colors.green,
                            width: double.infinity,
                            padding: SizeUtil.padding(bottom: 5, top: 5, left: 5, right: 5),
                            child: Wrap(
                              children: _createComment(),
                            ),
                          ),
                        )
                      : Container(
                          width: 0,
                          height: 0,
                        )),
                  Obx(() => _pageController.showHistLabel.value
                      ? StickyHeader(
                          header: _createLabel("搜索历史".tr, delete: () {
                            SPUtils().put(Constant.Dapp_Search_His, <String>[]);
                            _pageController.setHistList(<String>[]);
                          }),
                          content: Container(
                            width: double.infinity,
                            padding: SizeUtil.padding(bottom: 5, top: 5, left: 5, right: 5),
                            child: Wrap(
                              children: _createSearchHistory(),
                            ),
                          ),
                        )
                      : Container(
                          width: 0,
                          height: 0,
                        )),
                  Obx(() => _pageController.showEmpty.value
                      ? StickyHeader(
                          header: _createLabel("CommonSearchResult".tr),
                          content: buildEmpty(),
                        )
                      : _pageController.searchItems.length > 0
                          ? StickyHeader(
                              header: _createLabel("CommonSearchResult".tr),
                              content: _createItems(),
                            )
                          : Container(
                              width: 0,
                              height: 0,
                            )),
                ]),
                _refreshController, () async {
              if (strIsEmpty(_searchController.text)) {
                _refreshController.finishRefresh();
                return;
              }
              await _actionSearch();
              _refreshController.finishRefresh();
            })
            ),
      ),
    );
  }

  List<Widget> _createSearchHistory() {
    List<Widget> items = [];
    List<String> urls = _pageController.showHistList.value;
    urls.forEach((el) {
      items.add(Padding(
        padding: SizeUtil.padding(all: 5),
        child: Material(
          shape: RoundedRectangleBorder(
            side: BorderSide.none,
            borderRadius: SizeUtil.radius(all: 30),
          ),
          child: InkWell(
            borderRadius: SizeUtil.radius(all: 30),
            child: Container(
              padding: SizeUtil.padding(top: 5, bottom: 5, left: 10, right: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: SizeUtil.radius(all: 30),
                border: Border.all(color: Colors.grey[50]),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      offset: Offset(0, 1.0),
                      blurRadius: 1,
                      spreadRadius: 0
                      )
                ],
              ),
              child: Text(
                "$el",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: Theme.of(context).primaryTextTheme.headline4,
              ),
            ),
            onTap: () async {
              _searchController.text = el;
              _pageController.changeShowClear(true);
              _actionSearch();
            },
          ),
        ),
      ));
    });
    return items;
  }

  List<Widget> _createComment() {
    List<Widget> items = [];
    List<String> urls = _pageController.showCommentList != null ? _pageController.showCommentList : ['ETH'];
    urls.forEach((el) {
      items.add(Padding(
        padding: SizeUtil.padding(all: 5),
        child: Material(
          shape: RoundedRectangleBorder(
            side: BorderSide.none,
            borderRadius: SizeUtil.radius(all: 30),
          ),
          child: InkWell(
            borderRadius: SizeUtil.radius(all: 30),
            child: Container(
              padding: SizeUtil.padding(top: 5, bottom: 5, left: 10, right: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: SizeUtil.radius(all: 30),
                border: Border.all(color: Colors.grey[50]),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      offset: Offset(0, 1.0),
                      blurRadius: 1,
                      spreadRadius: 0
                      )
                ],
              ),
              child: Text(
                "$el",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: Theme.of(context).primaryTextTheme.headline4,
              ),
            ),
            onTap: () async {
              _searchController.text = "$el";
              _pageController.changeShowClear(true);
              await _actionSearch();
            },
          ),
        ),
      ));
    });
    return items;
  }

  Widget _createLabel(label, {VoidCallback delete}) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            height: SizeUtil.height(30),
            padding: SizeUtil.padding(left: 14, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(label),
                Spacer(),
                delete != null
                    ? Material(
                        color: Colors.white,
                        child: InkWell(
                          child: Container(
                            width: SizeUtil.width(30),
                            height: SizeUtil.width(30),
                            padding: SizeUtil.padding(all: 5),
                            child: Icon(
                              Icons.delete_forever,
                              size: SizeUtil.width(15),
                              color: Colors.grey,
                            ),
                          ),
                          onTap: delete,
                        ),
                      )
                    : Container(
                        height: 0,
                        width: 0,
                      )
              ],
            ),
          ),
          Divider(
            height: 1,
          )
        ],
      ),
    );
  }

  Widget _createItems() {
    return _pageController.showLoading.value
        ? DialogLoading()
        : ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            controller: _scrollController,
            itemBuilder: (context, index) {
              Dapp item = _pageController.searchItems[index];
              return _createItem(item, index, 'normal');
            },
            itemCount: _pageController.searchItems.length,
          );
  }

  Widget _createItem(Dapp item, index, type) {
    return Material(
      color: Colors.white,
      shadowColor: Colors.grey[50],
      elevation: 1,
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
              children: [
                Container(
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "${item.name}",
                            style: Theme.of(context).primaryTextTheme.headline4,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            " (${item.chain})",
                            style: Theme.of(context).primaryTextTheme.subtitle2,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
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

  _actionSearch() async {
    if (strIsEmpty(_searchController.text)) {
      showWarnBar('CommonSearchInput'.tr);
      return;
    }
    _appendSearchHistory();
    if (_searchController.text.startsWith("http")) {
      _showChoiceChainDialog();
      return true;
    }
    _pageController.setSearchLoading();
    Result<Dapps> result = await requestSearchDapps(
      _searchController.text != null ? _searchController.text : "eth",
    );
    if (result.result != null && result.result.items != null) {
      _pageController.setSearchItems(result.result.items);
    } else {
      _pageController.changeShowEmpty();
    }
  }

  _querySearchHistory() {
    List history = SPUtils().getList(Constant.Dapp_Search_His);
    _pageController.setHistList(history);
  }

  _appendSearchHistory() {
    List history = SPUtils().getList(Constant.Dapp_Search_His);
    bool changed = false;
    if (history == null) {
      history = [_searchController.text];
      changed = true;
    } else if (!history.contains(_searchController.text)) {
      history.add(_searchController.text);
      changed = true;
    }
    if (changed) {
      if (history.length > 10) {
        history = []..addAll(history.getRange(history.length - 11, history.length - 1));
      }
      SPUtils().put(Constant.Dapp_Search_His, history);
      _pageController.setHistList(history);
    }
  }

  _requestCommentDapps() async {
    Result<StringListModel> result = await requestCommentDapps(_wid);
    if (result.result != null && result.result.items != null) {
      _pageController.setCommentList(result.result.items);
    }
  }

  _showChoiceChainDialog() async {
    List<Coin> chains = Global.SUPORT_CHAINS;
    console.i(chains);
    List<Widget> items = [];
    chains.forEach((item) {
      items.add(Material(
        child: InkWell(
          onTap: () async {
            Get.back();
            await showDialog(
                useSafeArea: false,
                context: context,
                builder: (builder) {
                  return DialogDappAuthBoard(
                    icon: item.icon,
                    name: _searchController.text,
                    chain: item.contract,
                    callback: (result) async {
                      Get.back();
                      if (result) {
                        Get.to(PageWeb(), arguments: {
                          "url": _searchController.text,
                          "dapp": Dapp().parser({
                            "icon": item.icon,
                            "coin": item.contract,
                            "chain": item.contract,
                            "name": _searchController.text,
                            "url": _searchController.text,
                          })
                        });
                      }
                    },
                  );
                });
          },
          child: Container(
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: SizeUtil.padding(all: 5),
                      margin: SizeUtil.margin(left: 14, right: 14, top: 10, bottom: 10),
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
                      child: CachedNetworkImage(
                        width: SizeUtil.width(38),
                        height: SizeUtil.width(38),
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
                        Text(
                          item.symbol,
                          style: Theme.of(context).primaryTextTheme.headline3,
                        ),
                        Text(item.name),
                      ],
                    ))
                  ],
                ),
                Divider(
                  height: 1,
                )
              ],
            ),
          ),
        ),
      ));
    });

    return await showDialog(
        useSafeArea: false,
        context: context,
        builder: (context) {
          return DialogWidgetBoard(
            padding: SizeUtil.padding(top: 10, bottom: 40),
            child: Container(
              child: Column(
                children: <Widget>[
                  Container(
                    child: Text(
                      'WalletSelectMain'.tr,
                      style: Theme.of(context).primaryTextTheme.headline6,
                    ),
                  )
                ]..addAll(items),
              ),
            ),
          );
        },
    );
  }
}
