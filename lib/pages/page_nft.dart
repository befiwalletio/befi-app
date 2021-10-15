import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cube/core/base_widget.dart';
import 'package:cube/core/constant.dart';
import 'package:cube/core/core.dart';
import 'package:cube/models/model_base.dart';
import 'package:cube/models/model_nft.dart';
import 'package:cube/net/manager_api.dart';
import 'package:cube/net/requester.dart';
import 'package:cube/pages/page_nft_detail.dart';
import 'package:cube/pages/page_nft_search.dart';
import 'package:cube/utils/utils_db.dart';
import 'package:cube/utils/utils_event.dart';
import 'package:cube/utils/utils_size.dart';
import 'package:cube/utils/utils_sp.dart';
import 'package:cube/views/appbar/appbar.dart';
import 'package:cube/views/appbar/beebar.dart';
import 'package:cube/views/dialog/dialog_widget_board.dart';
import 'package:cube/views/point.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swipper/flutter_card_swiper.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:get/get.dart';

class PageNft extends StatefulWidget {
  const PageNft({Key key}) : super(key: key);

  @override
  _PageNftState createState() => _PageNftState();
}

class NftController extends GetxController {
  var wid = "".obs;
  var title = "".obs;
  Rx<Identity> identity = Identity().obs;
  var contract = "".obs;

  var banners = [SchemeModel()].obs;
  var nftItems = [].obs;

  changeWid(data) => wid.value = data;

  changeTitle(data) => title.value = data;

  changeIdentity(data) {
    identity.value = data;
    title.value = data.name;
    wid.value = data.wid;
  }

  changeBanners(data) {
    if (data != null) {
      banners.value = data;
    }
  }

  changeNftItems(data) {
    if (data != null) {
      nftItems.value = data;
    }
  }

  changeNftContract(data) {
    if (data != null) {
      contract.value = data;
    }
  }
}

class _PageNftState extends SizeState<PageNft> {
  NftController _nftController = Get.put(NftController());
  EasyRefreshController _refreshController = EasyRefreshController();

  List<Coin> coinChain = [];
  String _contract = '';

  @override
  void initState() {
    super.initState();
    _nftController.changeWid(SPUtils().getString(Constant.CUSTOM_WID));
    eventBus.on<UpdateNft>().listen((event) async {
      _requestData();
    });
    eventBus.on<UpdateIdentity>().listen((event) async {
      _changeIdentity(event.identity);
      _requestData();
    });
    _initData();
  }

  _initData() async {
    await _queryIdentity();
    var cacheData = SPUtils().getString(Constant.NFT_INDEX);
    if (cacheData is String && !strIsEmpty(cacheData)) {
      NFTIndex data = NFTIndex().parser(jsonDecode(cacheData)['data']);
      _nftController.changeBanners(data.banners);
      _nftController.changeNftItems(data.items);
    }
    _requestData();
  }

  _requestData() async {
    Result<NFTIndex> data = await requestNFTIndex(_nftController.wid.value, contract: _contract);
    SPUtils().put(Constant.NFT_INDEX, jsonEncode(data.origin));
    if (data != null && data.result != null) {
      _nftController.changeBanners(data.result.banners);
      _nftController.changeNftItems(data.result.items);
    }
  }

  _queryIdentity() async {
    var identity = await DBHelper.create().queryIdentity(_nftController.wid.value);
    if (identity != null) {
      _changeIdentity(identity);
    }
  }

  _changeIdentity(identity) {
    _nftController.changeWid(identity.wid);
    _nftController.changeIdentity(identity);
  }

  void selectChain() async {
    List<Coin> items = await DBHelper().queryCoins(_nftController.wid.value);
    if (items != null) {
      coinChain.clear();
      items.forEach((element) {
        if (element.contract == element.symbol) {
          coinChain.add(element);
        }
      });
      if (coinChain.length > 0) {
        selectChainAction();
      }
    }
  }

  void selectChainAction() {
    showDialog(
        useSafeArea: false,
        context: context,
        builder: (context) {
          return DialogWidgetBoard(
            child: Container(
              child: Column(
                children: createChainList(),
              ),
            ),
          );
        });
  }

  List<Widget> createChainList() {
    List<Widget> items = [];
    for (int i = 0; i < coinChain.length + 1; i++) {
      if (i == 0) {
        items.add(InkWell(
          onTap: () async {
            Get.back();
            changNftChain("");
          },
          child: Container(
            height: SizeUtil.height(40),
            child: Center(
              child: Text("Nft_All".tr, style: Theme.of(context).primaryTextTheme.bodyText1),
            ),
          ),
        ));
        items.add(Divider(
          height: 1,
          color: Colors.grey[100],
        ));
      } else {
        Coin item = coinChain[i - 1];
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
            changNftChain(item.contract);
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

  void changNftChain(String contract) {
    _contract = contract;
    _nftController.changeNftContract(contract);
    _requestData();
  }

  @override
  Widget createView(BuildContext context) {
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
            Container(
              width: 15,
            ),
          ],
          title: Obx(
            () => Text(
              "${_nftController.title}",
              style: StyleUtil.textStyle(size: 16, color: Theme.of(context).appBarTheme.iconTheme.color, weight: FontWeight.bold),
            ),
          ),
        ),
      ),
      body: createRefresh(),
    );
  }

  Widget createRefresh() {
    var refreshView = EasyRefresh(
      header: MaterialHeader(),
      onRefresh: () async {
        await _requestData();
        _refreshController.finishRefresh(success: true);
      },
      controller: _refreshController,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Obx(() => _nftController.banners != null && _nftController.banners.length > 0
                ? createSwiper()
                : Container(
                    width: 0,
                    height: 0,
                  )),
            Obx(() => createLabel()),
            Obx(() => _nftController.nftItems.length > 0
                ? Column(
                    children: createList(),
                  )
                : buildEmpty()),
            Container(
              height: SizeUtil.width(20),
            )
          ],
        ),
      ),
    );
    return refreshView;
  }

  Widget createSwiper() {
    return Container(
      margin: SizeUtil.margin(left: 20, right: 20),
      height: (SizeUtil.screenW - SizeUtil.width(40)) / 335 * 130,
      child: Swiper(
        itemBuilder: (BuildContext context, int index) {
          return Container(
            child: CachedNetworkImage(
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  borderRadius: new BorderRadius.circular(SizeUtil.width(13)),
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              imageUrl: _nftController.banners[index].image,
              placeholder: (context, url) => Image.asset(
                Constant.Assets_Image + "nft_banner_place.png",
              ),
              errorWidget: (context, url, error) => Image.asset(
                Constant.Assets_Image + "nft_banner_place.png",
              ),
            ),
          );
        },
        autoplay: _nftController.banners.length > 1,
        autoplayDelay: 5000,
        itemCount: _nftController.banners.length,
        pagination: new SwiperPagination(
          builder: DotSwiperPaginationBuilder(size: 6, activeSize: 6, color: Colors.grey[100], activeColor: BeeColors.blue),
        ),
      ),
    );
  }

  Widget createLabel() {
    String str = "Nft_All".tr;
    if (_nftController.contract.value == "ETH") {
      str = "Ethereum";
    } else if (_nftController.contract.value == "BNB") {
      str = "BSC";
    } else if (_nftController.contract.value == "MATIC") {
      str = "Polygon";
    } else if (_nftController.contract.value == "TRUE") {
      str = "TrueChain";
    } else if (_nftController.contract.value == "TRX") {
      str = "Tron";
    }
    return Container(
      padding: SizeUtil.padding(left: 20, right: 7, top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: () {
              selectChain();
            },
            child: Text(
              str,
              style: StyleUtil.textStyle(size: 14, color: Colors.black, weight: FontWeight.bold),
            ),
          ),
          SizedBox(
            width: SizeUtil.width(5),
          ),
          IconButton(
              icon: Icon(
                Icons.expand_more,
                size: SizeUtil.width(16),
              ),
              onPressed: () => {selectChain()}),
          Spacer(),
          Container(
            child: Stack(
              children: [
                IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () async {
                      var wid = SPUtils().getString(Constant.CUSTOM_WID);

                      Get.to(PageSearchNfts(), arguments: {'wid': wid});
                    }),
                Positioned(
                  top: SizeUtil.height(8),
                  right: SizeUtil.width(8),
                  child: Point(size: SizeUtil.height(5)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  List<Widget> createList() {
    List<Widget> items = [];
    for (int i = 0; i < _nftController.nftItems.length; i++) {
      Coin item = _nftController.nftItems[i];
      items.add(InkWell(
        onTap: () async {
          await Get.to(PageNftDetail(), arguments: {"data": item, "wid": _nftController.wid.value});
        },
        child: Container(
            child: Column(
          children: [
            Container(
              child: Row(
                children: [
                  SizedBox(
                    width: SizeUtil.width(20),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: SizeUtil.width(14), bottom: SizeUtil.width(14)),
                    width: SizeUtil.width(58),
                    height: SizeUtil.width(58),
                    child: CachedNetworkImage(
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          border: new Border.all(color: Colors.grey[200], width: 0.5),
                          color: Colors.white,
                          borderRadius: new BorderRadius.circular(SizeUtil.width(10)),
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      imageUrl: item.icon,
                      placeholder: (context, url) => Image.asset(
                        Constant.Assets_Image + "common_placeholder.png",
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                  SizedBox(
                    width: SizeUtil.width(16),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: StyleUtil.textStyle(
                            size: SizeUtil.sp(14),
                            color: BeeColors.FF091C40,
                            weight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          item.detail,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: StyleUtil.textStyle(
                            size: SizeUtil.sp(12),
                            color: BeeColors.FFA2A6B0,
                          ),
                        ),
                        item.floorPrice != null && item.floorPrice.isNotEmpty
                            ? Text(
                                "Nft_Price_Floor".tr + item.floorPrice,
                                style: StyleUtil.textStyle(
                                  size: SizeUtil.sp(12),
                                  color: BeeColors.FF5A667F,
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: SizeUtil.width(10),
                  ),
                  Container(
                    margin: EdgeInsets.only(),
                    child: Text(
                      item.balance + "Nft_Num_Unit".tr,
                      style: StyleUtil.textStyle(
                        size: SizeUtil.sp(14),
                        color: BeeColors.FF00A0E8,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: SizeUtil.width(20),
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

  @override
  bool get wantKeepAlive => true;
}
