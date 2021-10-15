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
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';

class DialogDappInfoBoard extends StatefulWidget {
  final String icon;
  final String name;
  final String chain;
  final String coin;
  final MapCallback callback;
  final Callback noneback;
  final Fees fees;
  final String fee;
  final Map<String, dynamic> data;
  final Coin nft;

  const DialogDappInfoBoard(
      {Key key, this.fees, this.fee, this.icon, this.name, this.coin, this.chain, this.callback, this.noneback, this.data, this.nft})
      : super(key: key);

  @override
  _DialogDappInfoBoardState createState() => _DialogDappInfoBoardState();
}

class _DialogDappInfoBoardState extends SizeState<DialogDappInfoBoard> {
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
    String desc = widget.name;
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
                              if (widget.noneback != null) {
                                widget.noneback();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    //内容
                    Container(
                      width: SizeUtil.screenWidth(),
                      margin: SizeUtil.margin(all: 14, right: 14),
                      padding: SizeUtil.padding(all: 10),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(6.0))),
                      child: Column(
                        children: [
                          //icon
                          Container(
                            width: SizeUtil.width(60),
                            height: SizeUtil.width(60),
                            padding: SizeUtil.padding(all: 5),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.grey[100]),
                                borderRadius: BorderRadius.all(Radius.circular(6.0))),
                            child: CachedNetworkImage(
                              imageUrl: widget.icon,
                              placeholder: (context, url) => Image.asset(
                                Constant.Assets_Image + "common_placeholder.png",
                              ),
                              errorWidget: (context, url, error) => Icon(Icons.error),
                            ),
                          ),
                          Container(
                            padding: SizeUtil.padding(left: 10, right: 10, top: 10),
                            child: Text(
                              desc,
                              style: Theme.of(context).primaryTextTheme.bodyText1,
                            ),
                          ),
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${_data['value']}',
                                  style: Theme.of(context).primaryTextTheme.headline3,
                                ),
                                Text('${widget.coin}'),
                              ],
                            ),
                          ),
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

  Widget _buildInfoCard() {
    String gas = MathCalc.startWithStr(gas_limit).multiplyStr(gas_price).toString();
    String gwel = MathCalc.startWithStr(gas_price).multiplyStr(gwei).toString();
    return Column(
      children: [
        _data['action'] != null
            ? Container(
                padding: SizeUtil.padding(top: 10, bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${'Action'.tr}:',
                      style: Theme.of(context).primaryTextTheme.subtitle1,
                    ),
                    Expanded(
                        child: Padding(
                      padding: SizeUtil.padding(left: 20, top: 2),
                      child: Text(
                        '${_data['action']}',
                        style: Theme.of(context).primaryTextTheme.headline6,
                        textAlign: TextAlign.right,
                      ),
                    ))
                  ],
                ),
              )
            : Container(
                width: 0,
                height: 0,
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
        widget.fee != null
            ? Container(
                padding: SizeUtil.padding(top: 10, bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${'FeeLimit'.tr}:',
                      style: Theme.of(context).primaryTextTheme.subtitle1,
                    ),
                    Expanded(
                        child: Padding(
                      padding: SizeUtil.padding(left: 20, top: 2),
                      child: Text(
                        '${widget.fee}${widget.chain}',
                        style: Theme.of(context).primaryTextTheme.headline6,
                        textAlign: TextAlign.right,
                      ),
                    ))
                  ],
                ),
              )
            : InkWell(
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
    Result<Fees> result = await requestFees(
        {"symbol": widget.chain, "address": _data['from'], "contract": _data['contract'], "contractAddress": _data['contractAddress']});
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
