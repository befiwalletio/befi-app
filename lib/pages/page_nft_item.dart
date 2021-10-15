import 'package:cached_network_image/cached_network_image.dart';
import 'package:cube/core/base_widget.dart';
import 'package:cube/core/constant.dart';
import 'package:cube/models/model_base.dart';
import 'package:cube/pages/page_nft_transfer.dart';
import 'package:cube/pages/page_web.dart';
import 'package:cube/utils/utils_size.dart';
import 'package:cube/views/appbar/appbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PageNftItem extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PageNftItemState();
  }
}

class PageNftItemState extends SizeState<PageNftItem> {
  String _wid = '';
  Coin _nft;
  Coin _nftdetail;

  @override
  void initState() {
    super.initState();
    _wid = Get.arguments["wid"];
    _nft = Get.arguments['nft'];
    _nftdetail = Get.arguments['nftdetail'];
  }

  @override
  Widget createView(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.isDarkMode ? Colors.black26 : Colors.grey[50],
      appBar: XAppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_outlined),
          onPressed: () {
            Get.back();
          },
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        height: double.infinity,
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(
                    height: SizeUtil.width(10),
                  ),
                  createAvatar(),
                  SizedBox(
                    height: SizeUtil.width(20),
                  ),
                  createInfo(),
                  Container(
                    color: Colors.transparent,
                    height: SizeUtil.width(84),
                    width: SizeUtil.screenW,
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: createButton(),
            )
          ],
        ),
      ),
    );
  }

  Widget createAvatar() {
    if (_nft != null && _nft.name != null) {
      if (_nft.name.toLowerCase().indexOf('punk') >= 0) {
        return createPunkAvatar();
      }
      return createNormalAvatar();
    }
    return Container(
      height: 0,
    );
  }

  Widget createPunkAvatar() {
    return Container(
      margin: SizeUtil.margin(left: 16, right: 16),
      width: SizeUtil.screenW - SizeUtil.width(32),
      height: (SizeUtil.screenW - SizeUtil.width(32)),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(SizeUtil.height(4))),
              child: Image.asset(
                Constant.Assets_Image + "punks_bg.png",
                fit: BoxFit.fill,
              ),
            ),
          ),
          Center(
            child: Container(
              width: SizeUtil.width(130),
              height: SizeUtil.width(130),
              decoration: new BoxDecoration(
                  border: new Border.all(color: Colors.grey[300], width: SizeUtil.width(1)),
                  borderRadius: BorderRadius.all(Radius.circular(SizeUtil.width(80))),
                  color: Colors.blueGrey),
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: _nftdetail != null && _nftdetail.img != null ? _nftdetail.img : "",
                placeholder: (context, url) => Image.asset(
                  Constant.Assets_Image + "nft_item_place.png",
                ),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget createNormalAvatar() {
    return Container(
      margin: SizeUtil.margin(left: 16, right: 16),
      width: SizeUtil.screenW - SizeUtil.width(32),
      height: (SizeUtil.screenW - SizeUtil.width(32)),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(SizeUtil.height(4))),
        child: CachedNetworkImage(
          fit: BoxFit.cover,
          imageUrl: _nftdetail != null && _nftdetail.img != null ? _nftdetail.img : "",
          placeholder: (context, url) => Image.asset(
            Constant.Assets_Image + "nft_item_place.png",
          ),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
      ),
    );
  }

  Widget createInfo() {
    return Container(
      margin: SizeUtil.margin(left: 16, right: 16, bottom: 20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200], width: SizeUtil.width(1)),
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeUtil.width(18)),
      ),
      padding: SizeUtil.padding(all: 0),
      child: Stack(
        children: [
          Positioned(
            left: -SizeUtil.width(5),
            top: -SizeUtil.width(5),
            width: SizeUtil.width(100),
            height: SizeUtil.width(90),
            child: Image.asset(Constant.Assets_Image + "nft_item_back.png"),
          ),
          Column(
            children: [
              Container(
                height: SizeUtil.width(80),
                child: Row(
                  children: [
                    SizedBox(
                      width: SizeUtil.width(20),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _nftdetail != null && _nftdetail.name != null ? _nftdetail.name : "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: StyleUtil.textStyle(
                            size: SizeUtil.sp(24),
                            color: BeeColors.FF091C40,
                          ),
                        ),
                        Text(
                          "Nft_Token_Id".tr + (_nftdetail != null && _nftdetail.tokenID != null ? _nftdetail.tokenID : ""),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: StyleUtil.textStyle(
                            size: SizeUtil.sp(14),
                            color: BeeColors.FFA2A6B0,
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    SizedBox(
                      width: SizeUtil.width(20),
                    ),
                    (_nftdetail != null && _nftdetail.detail != null && _nftdetail.detail != '')
                        ? MaterialButton(
                            onPressed: () {
                              Get.to(PageWeb(), arguments: {
                                'url': _nftdetail != null && _nftdetail.detail != null ? _nftdetail.detail : "",
                                "title": _nftdetail != null && _nftdetail.name != null ? _nftdetail.name : ""
                              });
                            },
                            color: BeeColors.FF2AC6BE,
                            minWidth: SizeUtil.width(80),
                            height: SizeUtil.width(34),
                            shape: RoundedRectangleBorder(
                              side: BorderSide.none,
                              borderRadius: SizeUtil.radius(all: SizeUtil.width(17)),
                            ),
                            child: Text(
                              'Nft_Show'.tr,
                              style: StyleUtil.textStyle(size: 14, color: Colors.white),
                            ),
                          )
                        : Container(
                            width: 0,
                            height: 0,
                          ),
                    SizedBox(
                      width: SizeUtil.width(17),
                    ),
                  ],
                ),
              ),
              Column(
                children: createList(),
              ),
              SizedBox(
                height: SizeUtil.width(15),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> createList() {
    List<Widget> items = [];
    for (int i = 0; i < _nftdetail.attributes.length; i++) {
      NameValue nameValue = _nftdetail.attributes[i];
      items.add(
        Container(
          height: SizeUtil.width(28),
          child: Row(
            children: [
              SizedBox(
                width: SizeUtil.width(20),
              ),
              Container(
                child: Text(
                  nameValue != null && nameValue.name != null ? nameValue.name : "",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: StyleUtil.textStyle(
                    size: SizeUtil.sp(14),
                    color: BeeColors.FF5A667F,
                  ),
                ),
              ),
              Spacer(),
              Container(
                child: Text(
                  nameValue != null && nameValue.value != null ? nameValue.value : "",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: StyleUtil.textStyle(
                    size: SizeUtil.sp(14),
                    color: BeeColors.FF282828,
                  ),
                ),
              ),
              SizedBox(
                width: SizeUtil.width(20),
              ),
            ],
          ),
        ),
      );
    }
    return items;
  }

  Widget createButton() {
    num height = SizeUtil.width(42);
    return Container(
      width: SizeUtil.screenWidth(),
      height: SizeUtil.width(84),
      padding: SizeUtil.padding(left: 20, right: 20, top: 10, bottom: 20),
      color: Colors.white,
      child: MaterialButton(
        onPressed: () {
          Get.to(PageNftTransfer(), arguments: {
            "wid": _wid,
            "nft": _nft,
            "nftdetail": _nftdetail,
          });
        },
        color: BeeColors.FF2AC6BE,
        height: height,
        shape: RoundedRectangleBorder(
          side: BorderSide.none,
          borderRadius: SizeUtil.radius(all: SizeUtil.width(40)),
        ),
        child: Text(
          'Nft_Transfer'.tr,
          style: StyleUtil.textStyle(size: 14, color: Colors.white),
        ),
      ),
    );
  }
}
