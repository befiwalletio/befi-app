import 'package:cached_network_image/cached_network_image.dart';
import 'package:cube/core/base_widget.dart';
import 'package:cube/core/constant.dart';
import 'package:cube/core/core.dart';
import 'package:cube/models/model_base.dart';
import 'package:cube/net/manager_api.dart';
import 'package:cube/net/requester.dart';
import 'package:cube/utils/utils_console.dart';
import 'package:cube/utils/utils_math.dart';
import 'package:cube/utils/utils_size.dart';
import 'package:cube/views/dialog/dialog_fee_board.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DialogNftInfoBoard extends StatefulWidget {
  final String icon;
  final String name;
  final String chain;
  final String coin;
  final MapCallback callback;
  final Fees fees;
  final Map<String, dynamic> data;
  final Coin nft;

  const DialogNftInfoBoard({Key key, this.fees, this.icon, this.name, this.coin, this.chain, this.callback, this.data, this.nft}) : super(key: key);

  @override
  _DialogNftInfoBoardState createState() => _DialogNftInfoBoardState();
}

class _DialogNftInfoBoardState extends SizeState<DialogNftInfoBoard> {
  Map<String, dynamic> _data = {};
  String gwei = '1000000000';

  List<Fee> _fees;
  String gas_price = '0.0000';
  String gas_limit = '21000';

  @override
  void initState() {
    super.initState();
    _data = widget.data;
    console.i(_data);
    if (_data == null) {
      _data = {};
    }
    if (widget.fees != null) {
      _fees = widget.fees.items;
      _matchDefaultFee(_fees);
    } else {
      _requestFees();
    }
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
                padding: SizeUtil.padding(left: 0, right: 0, bottom: 40, top: 10),
                width: SizeUtil.screenWidth(),
                decoration: BoxDecoration(
                    color: Colors.grey[50], borderRadius: BorderRadius.only(topLeft: Radius.circular(6.0), topRight: Radius.circular(6.0))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: SizeUtil.width(40),
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              "WalletTransferInfo".tr,
                              style: Theme.of(context).primaryTextTheme.subtitle1,
                            ),
                          ),
                        ),
                        Container(
                          width: SizeUtil.width(40),
                          child: IconButton(
                            icon: Icon(
                              Icons.close,
                            ),
                            onPressed: () {
                              Get.back();
                            },
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: SizeUtil.screenWidth(),
                      margin: SizeUtil.margin(all: 14, right: 14),
                      padding: SizeUtil.padding(all: 10),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(6.0))),
                      child: Column(
                        children: [
                          createInfo(),
                          _buildInfoCard()
                        ],
                      ),
                    ),
                    Container(
                      padding: SizeUtil.padding(left: 20, right: 20),
                      width: SizeUtil.screenWidth(),
                      child: MaterialButton(
                        elevation: 0,
                        height: SizeUtil.height(30),
                        onPressed: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                          if (widget.callback != null) {
                            widget.callback({"gas_price": gas_price, "gas_limit": gas_limit});
                          }
                        },
                        textColor: Colors.white,
                        color: BeeColors.blue,
                        child: Text('CommonConfirm1'.tr),
                      ),
                    )
                  ],
                ),
              ))
        ],
      ),
    ));
  }

  Widget createInfo() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Nft_Transfer_Tip".tr,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).primaryTextTheme.subtitle1,
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
                  fit: BoxFit.fitWidth,
                  imageUrl: widget.nft != null && widget.nft.img != null ? widget.nft.img : "",
                  placeholder: (context, url) => Image.asset(
                    Constant.Assets_Image + "nft_item_place.png",
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
                          width: SizeUtil.width(18),
                          height: SizeUtil.width(18),
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

  Widget _buildInfoCard() {
    String gas = MathCalc.startWithStr(gas_limit).multiplyStr(gas_price).toString();
    gas = Decimal.parse(gas).toString();
    String gwel = MathCalc.startWithStr(gas_price).multiplyStr(gwei).toString();
    return Column(
      children: [
        Container(
          padding: SizeUtil.padding(top: 10, bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${'WalletContractAddress'.tr}:',
                style: Theme.of(context).primaryTextTheme.subtitle1,
              ),
              Expanded(
                  child: Padding(
                padding: SizeUtil.padding(left: 20, top: 2),
                child: Text(
                  '${widget.nft.contractAddress}',
                  style: Theme.of(context).primaryTextTheme.headline6,
                  textAlign: TextAlign.right,
                ),
              ))
            ],
          ),
        ),
        Container(
          padding: SizeUtil.padding(top: 10, bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${'WalletReceiveAddress'.tr}:',
                style: Theme.of(context).primaryTextTheme.subtitle1,
              ),
              Expanded(
                  child: Padding(
                padding: SizeUtil.padding(left: 20, top: 2),
                child: Text(
                  '${_data['to']}',
                  style: Theme.of(context).primaryTextTheme.headline6,
                  textAlign: TextAlign.right,
                ),
              ))
            ],
          ),
        ),
        Container(
          padding: SizeUtil.padding(top: 10, bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${'WalletPayAddress'.tr}:',
                style: Theme.of(context).primaryTextTheme.subtitle1,
              ),
              Expanded(
                  child: Padding(
                padding: SizeUtil.padding(left: 20, top: 2),
                child: Text(
                  '${_data['from']}',
                  style: Theme.of(context).primaryTextTheme.headline6,
                  textAlign: TextAlign.right,
                ),
              ))
            ],
          ),
        ),
        InkWell(
          onTap: () {
            _goFee();
          },
          child: Container(
            padding: SizeUtil.padding(top: 10, bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${'WalletGasFee'.tr}:',
                  style: Theme.of(context).primaryTextTheme.subtitle1,
                ),
                Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${gas}',
                      style: Theme.of(context).primaryTextTheme.headline6,
                    ),
                    Text(
                      'Gas Price(${gwel}GWEI) * Gas(${gas_limit})',
                      style: Theme.of(context).primaryTextTheme.subtitle2,
                    )
                  ],
                ),
                Container(
                  margin: SizeUtil.margin(left: 10, top: 4),
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
      ],
    );
  }

  _goFee() async {
    await showDialog(
        useSafeArea: false,
        context: context,
        builder: (context) {
          return DialogFeeBoard(
            data: _fees,
            contract: widget.chain,
            callback: (value) {
              setState(() {
                gas_price = value['gas_price'];
                gas_limit = value['gas_limit'];
                Get.back();
              });
            },
          );
        });
  }

  _requestFees() async {
    if (strIsEmpty(_data['from'])) {
      return;
    }
    Result<Fees> result = await requestFees({
      "symbol": widget.chain,
      "address": _data['from'],
      "contract": _data['contract'],
      "contractAddress": _data['contractAddress'],
    });
    Fee defaultFee;
    if (result.result != null && result.result.items != null) {
      _matchDefaultFee(result.result.items);
    }
  }

  _matchDefaultFee(List<Fee> items) {
    Fee defaultFee;
    items.forEach((element) {
      if (element.type == 'general') {
        defaultFee = element;
      }
    });
    setState(() {
      _fees = items;
      if (defaultFee != null) {
        gas_price = defaultFee.gas_price;
        gas_limit = defaultFee.gas_limit;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
