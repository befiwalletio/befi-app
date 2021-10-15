import 'package:cube/core/constant.dart';
import 'package:cube/core/core.dart';
import 'package:cube/models/model_base.dart';
import 'package:cube/core/base_widget.dart';
import 'package:cube/utils/utils_math.dart';
import 'package:flutter/material.dart';
import 'package:cube/utils/utils_size.dart';
import 'package:cube/views/appbar/appbar.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class PageFee extends StatefulWidget {
  const PageFee({Key key}) : super(key: key);

  @override
  _PageFeeState createState() => _PageFeeState();
}

class _PageFeeState extends SizeState<PageFee> {
  String gwei = '1000000000';

  bool showAdvance = false;
  String contract = '';
  List<Fee> _fees;
  String _coin = '';
  String gas_price = '0';
  String gas_price_str = '0';
  String gas_limit = '0';
  String gasType = 'fast';
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    contract = Get.arguments['contract'];
    _coin = Get.arguments['coin'];
    _fees = Get.arguments['data'];
    _fees.forEach((element) {
      if (element.type == gasType) {
        gas_price_str = element.gas_price_str;
        gas_price = element.gas_price;
        gas_limit = element.gas_limit;
      }
    });
    _controller.text = MathCalc.startWithStr(gas_price).multiplyStr(gwei).toString();
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
      child: Scaffold(
        backgroundColor: Get.isDarkMode ? Colors.black : Colors.grey[100],
        appBar: XAppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_outlined),
            onPressed: () {
              Get.back();
            },
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text(
            "矿工费".tr,
            style: Theme.of(context).primaryTextTheme.headline3,
          ),
        ),
        body: Stack(
          children: [
            Container(
              height: double.infinity,
              child: SingleChildScrollView(
                child: Container(
                  width: SizeUtil.screenWidth(),
                  child: Column(
                    children: _buildItem(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton() {
    return Container(
      margin: SizeUtil.margin(top: 20),
      child: MaterialButton(
        onPressed: () {
          Get.back(result: {"gas_price": gas_price, "gas_price_str": gas_price_str, "gas_limit": gas_limit}, closeOverlays: true);
        },
        color: BeeColors.blue,
        minWidth: SizeUtil.width(300),
        height: SizeUtil.width(45),
        shape: RoundedRectangleBorder(
          side: BorderSide.none,
          borderRadius: SizeUtil.radius(all: 100),
        ),
        child: Text(
          'CommonConfirm'.tr,
          style: StyleUtil.textStyle(size: 14, color: Colors.white),
        ),
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
                  "矿工费".tr,
                  style: Theme.of(context).primaryTextTheme.bodyText1,
                ),
                Spacer(),
                Text(
                  "$gas $_coin",
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
    items.add(_buildButton());

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
                      '${MathCalc.startWithStr(fee.gas_price).multiplyStr(gwei).toString()} GWEI',
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
}
