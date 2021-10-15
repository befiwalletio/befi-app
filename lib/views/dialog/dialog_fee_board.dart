import 'package:cube/core/base_widget.dart';
import 'package:cube/core/constant.dart';
import 'package:cube/core/core.dart';
import 'package:cube/models/model_base.dart';
import 'package:cube/utils/utils_math.dart';
import 'package:cube/utils/utils_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class DialogFeeBoard extends StatefulWidget {
  final String contract;
  final List<Fee> data;
  final MapCallback callback;

  const DialogFeeBoard({Key key, this.data, this.contract, this.callback}) : super(key: key);

  @override
  _DialogFeeBoardState createState() => _DialogFeeBoardState();
}

class _DialogFeeBoardState extends SizeState<DialogFeeBoard> {
  String gwei = '1000000000';

  bool showAdvance = false;
  String contract = '';
  List<Fee> _fees;
  String _coin = 'ETH';
  String gas_price = '0';
  String gas_limit = '0';
  String gasType = 'fast';
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    contract = widget.contract;
    _fees = widget.data;
    _fees.forEach((element) {
      if (element.type == gasType) {
        gas_price = element.gas_price;
        gas_limit = element.gas_limit;
      }
    });
    _controller.text = MathCalc.startWithStr(gas_price).multiplyStr(gwei).toString();
  }

  @override
  Widget createView(BuildContext context) {
    return Container(
      child: _createContent(),
    );
  }

  Widget _createContent() {
    return GestureDetector(
        child: IntrinsicHeight(
      child: Stack(
        children: [
          Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: SizeUtil.padding(left: 0, right: 0, bottom: 40, top: 20),
                width: SizeUtil.screenWidth(),
                decoration: BoxDecoration(
                    color: Colors.grey[50], borderRadius: BorderRadius.only(topLeft: Radius.circular(6.0), topRight: Radius.circular(6.0))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: Text(
                        "WalletGasFee1".tr,
                        style: Theme.of(context).primaryTextTheme.subtitle1,
                      ),
                    ),
                    Container(
                      width: SizeUtil.screenWidth(),
                      margin: SizeUtil.margin(all: 14, right: 14),
                      padding: SizeUtil.padding(all: 10),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(6.0))),
                      child: Column(
                        children: _buildItem(),
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

  Widget _buildButton() {
    return Container(
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
    );
  }

  Widget _buildTop() {
    String gas = MathCalc.startWithStr(gas_limit).multiplyStr(gas_price).toString();
    String gasPrice = MathCalc.startWithStr(gas_price).multiplyStr(gwei).toString();
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            child: Row(
              children: [
                Text(
                  "WalletGasFee1".tr,
                  style: Theme.of(context).primaryTextTheme.bodyText1,
                ),
                Spacer(),
                Text(
                  "$gas" + widget.contract,
                  style: Theme.of(context).primaryTextTheme.bodyText1,
                ),
              ],
            ),
          ),
          Divider(
            height: SizeUtil.height(15),
            color: Colors.grey[300],
          ),
          Container(
            child: Text(
              "Gas Price(${gasPrice}GWEI) * Gas(${gas_limit})",
              textAlign: TextAlign.right,
              style: Theme.of(context).primaryTextTheme.subtitle2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(left, right) {
    return Container(
      padding: SizeUtil.padding(left: 20, right: 20, top: 20, bottom: 10),
      child: Row(
        children: [
          Text(
            left,
            style: Theme.of(context).primaryTextTheme.bodyText1,
          ),
          Spacer(),
          Text(
            right,
            style: Theme.of(context).primaryTextTheme.bodyText1,
          )
        ],
      ),
    );
  }

  List<Widget> _buildItem() {
    List<Widget> items = [
      buildCard(_buildTop()),
      _buildLabel("Gas Price".tr, "WalletTradeTime".tr),
    ];
    _fees.forEach((element) {
      items.add(buildCard(
          _buildGas(element, () {
            setState(() {
              gasType = element.type;
              gas_limit = element.gas_limit;
              gas_price = element.gas_price;
              _controller.text = MathCalc.startWithStr(gas_price).multiplyStr(gwei).toString();
            });
          }),
          margin: SizeUtil.margin(left: 15, right: 15, top: 4),
          padding: SizeUtil.padding(all: 0)));
    });
    items.add(buildCard(_buildAdvance(), margin: SizeUtil.margin(left: 15, right: 15, top: 10), padding: SizeUtil.padding(all: 0)));

    return items;
  }

  Widget _buildAdvance() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: Colors.white,
            child: InkWell(
              onTap: () {
                setState(() {
                  showAdvance = !showAdvance;
                });
              },
              child: Container(
                padding: SizeUtil.padding(all: 10),
                width: double.infinity,
                child: Text(
                  "advance".tr,
                  style: Theme.of(context).primaryTextTheme.bodyText1,
                ),
              ),
            ),
          ),
          Divider(
            height: 1,
            color: Colors.grey[300],
          ),
          showAdvance
              ? Container(
                  padding: SizeUtil.padding(left: 15, right: 15),
                  child: TextField(
                    decoration: InputDecoration(border: InputBorder.none, fillColor: Colors.transparent, filled: false, suffixText: "GWEI"),
                    textAlign: TextAlign.left,
                    style: Theme.of(context).primaryTextTheme.subtitle2,
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                    onChanged: (text) {
                      if (strIsEmpty(text)) {
                        text = '0';
                      }
                      setState(() {
                        gas_price = MathCalc.startWithStr(text).divideStr(gwei).toString();
                      });
                    },
                  ),
                )
              : SizedBox(
                  width: 0,
                  height: 0,
                ),
        ],
      ),
    );
  }

  Widget _buildGas(Fee fee, callback) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () {
          if (callback != null) {
            callback();
          }
        },
        child: Container(
          padding: SizeUtil.padding(all: 5),
          child: Row(
            children: [
              Container(
                width: SizeUtil.width(40),
                height: SizeUtil.width(40),
                child: fee.type == gasType
                    ? Icon(
                        Icons.done,
                        color: BeeColors.blue,
                      )
                    : Container(),
              ),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fee.type.tr,
                      style: Theme.of(context).primaryTextTheme.bodyText1,
                    ),
                    Text(
                      MathCalc.startWithStr(fee.gas_price).multiplyStr(gwei).toString() + "GWEI",
                      style: Theme.of(context).primaryTextTheme.subtitle2,
                    ),
                  ],
                ),
              ),
              Spacer(),
              Container(
                padding: SizeUtil.padding(right: 10),
                child: Text(
                  "< ${fee.time}${"min".tr}",
                  style: Theme.of(context).primaryTextTheme.subtitle2,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
