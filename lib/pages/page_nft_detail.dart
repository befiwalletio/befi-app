import 'package:cached_network_image/cached_network_image.dart';
import 'package:cube/core/base_widget.dart';
import 'package:cube/core/constant.dart';
import 'package:cube/core/core.dart';
import 'package:cube/models/model_base.dart';
import 'package:cube/models/model_home.dart';
import 'package:cube/net/manager_api.dart';
import 'package:cube/net/requester.dart';
import 'package:cube/pages/page_collect.dart';
import 'package:cube/pages/page_nft_item.dart';
import 'package:cube/utils/utils_event.dart';
import 'package:cube/utils/utils_size.dart';
import 'package:cube/views/dialog/dialog_widget_board.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:get/get.dart';

class PageNftDetail extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PageNftDetailState();
  }
}

class NftDetailController extends GetxController {
  var nftDetailItems = [].obs;

  changeNftDetailItems(data) {
    if (data != null) {
      nftDetailItems.value = data;
    }
  }
}

class PageNftDetailState extends SizeState<PageNftDetail> {
  EasyRefreshController _refreshController = EasyRefreshController();
  NftDetailController _nftDetailController = Get.put(NftDetailController());

  Coin _data;
  String _wid = '';

  Result<Chains> chains;

  @override
  void initState() {
    super.initState();
    _data = Get.arguments['data'];
    _wid = Get.arguments["wid"];
    _requestData();
  }

  _requestData() async {
    Result<Chains> data = await requestNFTDetail(_wid, _data.contract, _data.contractAddress);
    if (data != null && data.result != null) {
      _nftDetailController.changeNftDetailItems(data.result.items);
    }
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

  @override
  Widget createView(BuildContext context) {
    return Scaffold(
        backgroundColor: Get.isDarkMode ? Colors.black26 : '#F8F9FA'.toColor(),
        body: Stack(
          children: [
            Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  child: Image(
                    fit: BoxFit.fitWidth,
                    image: AssetImage(Constant.Assets_Image + "icon_nft_back.png"),
                  ),
                )),
            createRefresh(),
            Positioned(
                top: SizeUtil.barHeight(),
                left: SizeUtil.width(5),
                child: Container(
                  child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_rounded,
                        size: SizeUtil.width(20),
                      ),
                      onPressed: () {
                        Get.back();
                      }),
                )),
            Positioned(
                top: SizeUtil.barHeight(),
                right: SizeUtil.width(5),
                child: Container(
                  child: IconButton(
                      icon: Icon(
                        Icons.more_horiz,
                        size: SizeUtil.width(20),
                      ),
                      onPressed: () {
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
                                            showLoading();
                                            await requestNFTHide({"wid": _wid, "contract": _data.contract, "contractAddress": _data.contractAddress});
                                            showLoading(show: false);
                                            eventBus.fire(UpdateNft());
                                            Get.back();
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
                      }),
                )),
          ],
        ));
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
            createHeader(),
            Obx(
              () => _nftDetailController.nftDetailItems.length == 1
                  ? createOneNft()
                  : _nftDetailController.nftDetailItems.length > 1
                      ? createGridNft()
                      : buildEmpty(),
            ),
            Container(
              height: SizeUtil.width(20),
            ),
          ],
        ),
      ),
    );
    return refreshView;
  }

  Widget createHeader() {
    return Container(
      child: Column(
        children: [
          SizedBox(
            width: 0,
            height: SizeUtil.barHeight() + SizeUtil.height(40),
          ),
          Row(
            children: [
              SizedBox(
                width: SizeUtil.width(20),
              ),
              Container(
                width: SizeUtil.width(48),
                height: SizeUtil.width(48),
                decoration: new BoxDecoration(
                  border: new Border.all(color: Colors.grey[200], width: 0.5),
                  color: Colors.white,
                  borderRadius: new BorderRadius.circular(SizeUtil.width(24)),
                ),
                child: CachedNetworkImage(
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      borderRadius: new BorderRadius.circular(SizeUtil.width(10)),
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  imageUrl: _data != null && _data.icon != null ? _data.icon : "",
                  placeholder: (context, url) => Image.asset(
                    Constant.Assets_Image + "common_placeholder.png",
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
              SizedBox(
                width: SizeUtil.width(9),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _data != null && _data.name != null ? _data.name : "",
                      style: StyleUtil.textStyle(
                        size: SizeUtil.sp(16),
                        color: BeeColors.FF091C40,
                        weight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          "@" + (_data != null && _data.madeby != null ? _data.madeby : ""),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: StyleUtil.textStyle(
                            size: SizeUtil.sp(12),
                            color: BeeColors.FF00A0E8,
                          ),
                        ),
                        SizedBox(
                          width: SizeUtil.width(5),
                        ),
                        Container(
                          color: BeeColors.FFD8DAE0,
                          width: 1,
                          height: 16,
                        ),
                        SizedBox(
                          width: SizeUtil.width(5),
                        ),
                        Text(
                          (_data != null && _data.balance != null ? _data.balance : "0") + "Nft_Num_Pin".tr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: StyleUtil.textStyle(
                            size: SizeUtil.sp(12),
                            color: BeeColors.FFA2A6B0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: SizeUtil.width(10),
              ),
              MaterialButton(
                onPressed: () {
                  if (_data != null) {
                    Get.to(PageCollect(), arguments: _data.toJson());
                  }
                },
                color: BeeColors.FF00A0E8,
                minWidth: SizeUtil.width(70),
                height: SizeUtil.width(34),
                shape: RoundedRectangleBorder(
                  side: BorderSide.none,
                  borderRadius: SizeUtil.radius(all: SizeUtil.width(17)),
                ),
                child: Text(
                  'Nft_Receive'.tr,
                  style: StyleUtil.textStyle(size: 14, color: Colors.white),
                ),
              ),
              SizedBox(
                width: SizeUtil.width(20),
              ),
            ],
          ),
          Container(
            margin: SizeUtil.margin(left: 20, right: 20, top: 10, bottom: 10),
            height: SizeUtil.height(26),
            child: Row(
              children: [
                Container(
                  decoration: new BoxDecoration(
                    border: new Border.all(color: Colors.grey[200], width: 0.5),
                    color: BeeColors.FFD3F1FF,
                    borderRadius: new BorderRadius.circular(SizeUtil.height(13)),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: SizeUtil.width(11),
                      ),
                      Text(
                        "Nft_Contract_Address".tr + _formatAddress(_data != null && _data.contractAddress != null ? _data.contractAddress : "0x"),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: StyleUtil.textStyle(
                          size: SizeUtil.sp(12),
                          color: BeeColors.FF00A0E8,
                        ),
                      ),
                      IconButton(
                          iconSize: SizeUtil.width(12),
                          icon: Icon(
                            Icons.copy,
                            color: BeeColors.FF00A0E8,
                          ),
                          onPressed: () async {
                            Clipboard.setData(ClipboardData(text: _data != null && _data.contractAddress != null ? _data.contractAddress : "0x"));
                            showTipsBar("CommonCopyTip".tr);
                          }),
                    ],
                  ),
                ),
                Spacer(),
              ],
            ),
          ),
          Container(
            width: SizeUtil.screenW,
            margin: SizeUtil.margin(left: 20, right: 20, bottom: 16),
            child: Text(
              _data != null && _data.detail != null ? _data.detail : "",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: StyleUtil.textStyle(
                size: SizeUtil.sp(12),
                color: BeeColors.FF5A667F,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget createOneNft() {
    Coin coin;
    if (_nftDetailController.nftDetailItems != null && _nftDetailController.nftDetailItems.length == 1) {
      coin = _nftDetailController.nftDetailItems[0];
    }
    return InkWell(
      onTap: () {
        Get.to(PageNftItem(), arguments: {
          "wid": _wid,
          "nft": _data,
          "nftdetail": coin,
        });
      },
      child: Container(
        width: SizeUtil.screenW - SizeUtil.width(40),
        height: SizeUtil.screenW - SizeUtil.width(40) + SizeUtil.width(70),
        decoration: new BoxDecoration(
          border: new Border.all(color: Colors.grey[200], width: 0.5),
          color: Colors.white,
          borderRadius: new BorderRadius.circular(SizeUtil.height(16)),
        ),
        child: Column(
          children: [
            Container(
              width: SizeUtil.screenW - SizeUtil.width(40),
              height: SizeUtil.screenW - SizeUtil.width(40),
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: coin != null && coin.img != null ? coin.img : "",
                placeholder: (context, url) => Image.asset(
                  Constant.Assets_Image + "nft_item_place.png",
                ),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
            SizedBox(
              height: SizeUtil.height(14),
            ),
            Container(
              child: Text(
                coin != null && coin.name != null ? coin.name : "",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: StyleUtil.textStyle(
                  size: SizeUtil.sp(14),
                  color: BeeColors.FF091C40,
                ),
              ),
            ),
            Container(
              child: Text(
                "Nft_Token_Id".tr + (coin != null && coin.tokenID != null ? coin.tokenID : ""),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: StyleUtil.textStyle(
                  size: SizeUtil.sp(12),
                  color: BeeColors.FFA2A6B0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget createGridNft() {
    bool isPunk = false;
    if (!strIsEmpty(_data.name)) {
      if (_data.name.toLowerCase().indexOf('punk') >= 0) {
        isPunk = true;
      }
    }
    return Padding(
      padding: SizeUtil.padding(left: 7, right: 7),
      child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _nftDetailController.nftDetailItems.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: SizeUtil.width(10),
            crossAxisSpacing: SizeUtil.width(10),
            childAspectRatio: 8 / 10,
          ),
          itemBuilder: (BuildContext context, int index) {
            if (isPunk) {
              return getPunkContainer(_nftDetailController.nftDetailItems[index]);
            }
            return getItemContainer(_nftDetailController.nftDetailItems[index]);
          }),
    );
  }

  Widget getPunkContainer(Coin item) {
    num height = SizeUtil.height(204);
    return GestureDetector(
      onTap: () {
        Get.to(PageNftItem(), arguments: {
          "wid": _wid,
          "nft": _data,
          "nftdetail": item,
        });
      },
      child: Container(
        height: height,
        decoration: new BoxDecoration(
          color: Colors.white,
          border: new Border.all(color: Colors.grey[200], width: 0.5),
          borderRadius: new BorderRadius.circular(SizeUtil.height(16)),
        ),
        child: Column(
          children: [
            Expanded(
                child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(SizeUtil.height(16)), topRight: Radius.circular(SizeUtil.height(16))),
                    child: Image.asset(
                      Constant.Assets_Image + "punks_bg.png",
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    width: SizeUtil.width(80),
                    height: SizeUtil.width(80),
                    decoration: new BoxDecoration(
                        border: new Border.all(color: Colors.grey[300], width: SizeUtil.width(1)),
                        borderRadius: BorderRadius.all(Radius.circular(SizeUtil.width(80))),
                        color: Colors.blueGrey),
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: item != null && item.img != null ? item.img : "",
                      placeholder: (context, url) => Image.asset(
                        Constant.Assets_Image + "nft_item_place.png",
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                )
              ],
            )),
            Container(
              padding: SizeUtil.padding(top: 5),
              child: Text(
                item != null && item.name != null ? item.name : "123123",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: StyleUtil.textStyle(
                  size: SizeUtil.sp(14),
                  color: BeeColors.FF091C40,
                ),
              ),
            ),
            Container(
              padding: SizeUtil.padding(bottom: 7, top: 2),
              child: Text(
                "Nft_Token_Id".tr + (item != null && item.tokenID != null ? item.tokenID : ""),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: StyleUtil.textStyle(
                  size: SizeUtil.sp(12),
                  color: BeeColors.FFA2A6B0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getItemContainer(Coin item) {
    num height = SizeUtil.height(204);
    return GestureDetector(
      onTap: () {
        Get.to(PageNftItem(), arguments: {
          "wid": _wid,
          "nft": _data,
          "nftdetail": item,
        });
      },
      child: Container(
        height: height,
        decoration: new BoxDecoration(
          color: Colors.white,
          border: new Border.all(color: Colors.grey[200], width: 0.5),
          borderRadius: new BorderRadius.circular(SizeUtil.height(16)),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(SizeUtil.height(16)), topRight: Radius.circular(SizeUtil.height(16))),
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: item != null && item.img != null ? item.img : "",
                    placeholder: (context, url) => Image.asset(
                      Constant.Assets_Image + "nft_item_place.png",
                    ),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
              ),
            ),
            Container(
              padding: SizeUtil.padding(top: 5),
              child: Text(
                item != null && item.name != null ? item.name : "123123",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: StyleUtil.textStyle(
                  size: SizeUtil.sp(14),
                  color: BeeColors.FF091C40,
                ),
              ),
            ),
            Container(
              padding: SizeUtil.padding(bottom: 7, top: 2),
              child: Text(
                "Nft_Token_Id".tr + (item != null && item.tokenID != null ? item.tokenID : ""),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: StyleUtil.textStyle(
                  size: SizeUtil.sp(12),
                  color: BeeColors.FFA2A6B0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
