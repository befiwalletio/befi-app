import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cube/core/base_widget.dart';
import 'package:cube/core/constant.dart';
import 'package:cube/core/core.dart';
import 'package:cube/models/model_base.dart';
import 'package:cube/utils/utils_math.dart';
import 'package:cube/utils/utils_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DialogTransDetailBoard extends StatefulWidget {
  final VoidCallback callback;

  final String amount;
  final String coin;
  final String contract;
  final String from;
  final String to;
  final Fee fee;
  final String contractAddress;
  final Coin nft;

  const DialogTransDetailBoard(
      {Key key,
      this.amount = "0",
      this.contract = "--",
      this.coin = "--",
      this.from = "--",
      this.to = "--",
      this.fee,
      this.contractAddress,
      this.nft,
      this.callback})
      : super(key: key);

  @override
  _DialogTransDetailBoardState createState() => _DialogTransDetailBoardState();
}

class _DialogTransDetailBoardState extends SizeState<DialogTransDetailBoard> {
  String gas_limit = '0';
  String gas_price = '0';
  String gas_price_str = '0';
  String gas = '0';

  @override
  void initState() {
    super.initState();
    gas_limit = widget.fee.gas_limit;
    gas_price = widget.fee.gas_price;
    gas_price_str = widget.fee.gas_price_str;
    gas = MathCalc.startWithStr(gas_limit).multiplyStr(gas_price).toString();
  }

  @override
  Widget createView(BuildContext context) {
    return GestureDetector(
        child: IntrinsicHeight(
      child: Stack(
        children: [
          Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: SizeUtil.padding(left: 0, right: 0, bottom: 0, top: 0),
                width: SizeUtil.screenWidth(),
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(6.0), topRight: Radius.circular(6.0))),
                child: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            padding: SizeUtil.padding(top: 10),
                            child: Text(
                              "WalletPayDetail".tr,
                              style: StyleUtil.textStyle(size: 18, color: Colors.black),
                            )),
                        Container(
                          margin: SizeUtil.margin(top: 5, bottom: 5),
                          width: SizeUtil.screenWidth(),
                          color: Colors.blue.shade100,
                          padding: SizeUtil.padding(top: 5, bottom: 5),
                          child: Text(
                            "CommonNetworkCurrent".tr,
                            textAlign: TextAlign.center,
                            style: StyleUtil.textStyle(size: 14, color: Colors.blue.shade900),
                          ),
                        ),
                        Container(
                          padding: SizeUtil.padding(top: 15, bottom: 15),
                          child: widget.nft != null
                              ? createInfo()
                              : Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      widget.amount,
                                      style: Theme.of(context).primaryTextTheme.headline2,
                                    ),
                                    Container(
                                      padding: SizeUtil.padding(left: 3, bottom: 2),
                                      child: Text(
                                        widget.coin,
                                        style: Theme.of(context).primaryTextTheme.bodyText1,
                                      ),
                                    )
                                  ],
                                ),
                        ),

                        _buildItem("WalletPayInfo".tr, right: "${widget.coin} ${"WalletTransfer".tr}"),
                        strIsEmpty(widget.contractAddress)
                            ? SizedBox(
                                width: 0,
                                height: 0,
                              )
                            : _buildItem("WalletContractAddress".tr, right: widget.contractAddress),
                        _buildItem("WalletReceiveAddress".tr, right: widget.to),
                        _buildItem("WalletPayAddress".tr, right: widget.from),
                        widget.contract.toUpperCase() == "TRX"
                            ? _buildItem("WalletGasFee".tr, right: widget.fee.fee + widget.contract)
                            : _buildItem("WalletGasFee".tr,
                                rightWidget: Container(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        child: Text(
                                          "${gas}${widget.contract}",
                                          style: Theme.of(context).primaryTextTheme.bodyText1,
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                      Container(
                                        padding: SizeUtil.padding(top: 0, bottom: 0),
                                        child: Text(
                                          "=Gas Price(${gas_price_str}GWEI) * Gas(${gas_limit})",
                                          style: Theme.of(context).primaryTextTheme.subtitle2,
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                    ],
                                  ),
                                )),

                        Container(
                          margin: SizeUtil.margin(bottom: 30, left: 15, right: 15, top: 15),
                          width: SizeUtil.screenWidth(),
                          child: MaterialButton(
                            shape: RoundedRectangleBorder(
                              side: BorderSide.none,
                              borderRadius: SizeUtil.radius(all: 100),
                            ),
                            height: SizeUtil.height(35),
                            color: Colors.blue,
                            textColor: Colors.white,
                            child: Text("CommonConfirm1".tr),
                            onPressed: () {
                              if (widget.callback != null) {
                                widget.callback();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ))
        ],
      ),
    ));
  }

  Widget createInfo() {
    return Container(
      margin: EdgeInsets.only(left: SizeUtil.width(20), right: SizeUtil.width(20)),
      padding: EdgeInsets.all(SizeUtil.width(14)),
      height: SizeUtil.width(124),
      decoration: new BoxDecoration(
        color: Colors.white,
        borderRadius: new BorderRadius.circular(SizeUtil.width(6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Nft_Transfer_Tip".tr,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: StyleUtil.textStyle(
              size: SizeUtil.sp(16),
              color: BeeColors.FF091C40,
            ),
          ),
          SizedBox(
            height: SizeUtil.width(12),
          ),
          Row(
            children: [
              Container(
                width: SizeUtil.width(60),
                height: SizeUtil.width(60),
                child: CachedNetworkImage(
                  imageUrl: widget.nft != null && widget.nft.img != null ? widget.nft.img : "",
                  placeholder: (context, url) => Image.asset(
                    Constant.Assets_Image + "common_placeholder.png",
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
              SizedBox(
                width: SizeUtil.width(12),
              ),
              Container(
                width: SizeUtil.screenW - SizeUtil.width(140),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.nft != null && widget.nft.name != null ? widget.nft.name : "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: StyleUtil.textStyle(
                        size: SizeUtil.sp(14),
                        color: BeeColors.FF091C40,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: SizeUtil.width(24),
                          height: SizeUtil.width(24),
                          child: CachedNetworkImage(
                            imageUrl: widget.nft != null && widget.nft.icon != null ? widget.nft.icon : "",
                            placeholder: (context, url) => Image.asset(
                              Constant.Assets_Image + "common_placeholder.png",
                            ),
                            errorWidget: (context, url, error) => Icon(Icons.error),
                          ),
                        ),
                        SizedBox(
                          width: SizeUtil.width(6),
                        ),
                        Text(
                          widget.nft != null && widget.nft.chainName != null ? widget.nft.chainName : "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: StyleUtil.textStyle(
                            size: SizeUtil.sp(12),
                            color: BeeColors.FF5A667F,
                          ),
                        ),
                        SizedBox(
                          width: SizeUtil.width(6),
                        ),
                        Container(
                          color: BeeColors.FFE3E3E3,
                          width: 0.5,
                          height: SizeUtil.width(12),
                        ),
                        SizedBox(
                          width: SizeUtil.width(6),
                        ),
                        Text(
                          "Nft_Token_Id".tr + (widget.nft != null && widget.nft.tokenID != null ? widget.nft.tokenID : ""),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: StyleUtil.textStyle(
                            size: SizeUtil.sp(12),
                            color: BeeColors.FF5A667F,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItem(left, {right, rightWidget}) {
    return Container(
      padding: SizeUtil.padding(left: 15, right: 15),
      child: Column(
        children: [
          Container(
            padding: SizeUtil.padding(top: 5, bottom: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: SizeUtil.padding(right: 15, left: 0, bottom: 0),
                  child: Text(
                    left,
                    style: Theme.of(context).primaryTextTheme.subtitle1,
                  ),
                ),
                Expanded(
                    child: rightWidget ??
                        Container(
                          child: Text(
                            right,
                            style: Theme.of(context).primaryTextTheme.bodyText1,
                          ),
                        ))
              ],
            ),
          ),
          Divider()
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
