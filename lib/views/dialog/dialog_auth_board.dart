import 'package:cube/core/base_widget.dart';
import 'package:cube/core/core.dart';
import 'package:cube/models/model_base.dart';
import 'package:cube/net/manager_api.dart';
import 'package:cube/utils/utils_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DialogAuthBoard extends StatefulWidget {
  final String address;
  final String contract;
  final String contractAddress;
  final String symbol;

  const DialogAuthBoard({
    Key key,
    this.address,
    this.contract,
    this.contractAddress,
    this.symbol,
  }) : super(key: key);

  @override
  _DialogAuthBoardState createState() => _DialogAuthBoardState();
}

class _DialogAuthBoardState extends SizeState<DialogAuthBoard> {
  num _sliderValue = 0.0;
  String _coin = '';
  num _amount = 0.0;
  String _address = "";

  @override
  void initState() {
    super.initState();
    _requestFees();
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
                padding: SizeUtil.padding(left: 0, right: 0, bottom: 40, top: 20),
                width: SizeUtil.screenWidth(),
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(6.0), topRight: Radius.circular(6.0))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildItems(),
                ),
              ))
        ],
      ),
    ));
  }

  _buildItems() {
    return [
      Container(
          child: Text(
        "WalletTransferInfo".tr,
        style: StyleUtil.textStyle(size: 20, color: Colors.black),
      )),
      Container(
        margin: SizeUtil.margin(top: 20, bottom: 20),
        width: SizeUtil.screenWidth(),
        color: Colors.blue.shade100,
        padding: SizeUtil.padding(top: 10, bottom: 10),
        child: Text(
          "CommonNetworkCurrent".tr,
          textAlign: TextAlign.center,
          style: StyleUtil.textStyle(size: 14, color: Colors.blue.shade900),
        ),
      ),
      Container(
        child: RichText(
            text: TextSpan(
                text: "$_amount",
                style: TextStyle(color: Colors.black, fontSize: SizeUtil.sp(25)),
                children: [TextSpan(text: " $_coin", style: TextStyle(fontSize: SizeUtil.sp(15)))])),
      ),
      Container(
          padding: SizeUtil.padding(left: 30),
          width: SizeUtil.screenWidth(),
          child: Text(
            '${'CommonGas'.tr} $_sliderValue',
            textAlign: TextAlign.start,
            style: StyleUtil.textStyle(size: 14),
          )),
      Container(
        width: SizeUtil.screenWidth(),
        padding: SizeUtil.padding(left: 30, right: 30),
        child: Row(
          children: [
            Container(
              child: Text(
                "CommonSlow".tr,
                style: StyleUtil.textStyle(size: 12, color: Colors.red.shade200),
              ),
            ),
            Expanded(
                child: Card(
              shadowColor: Colors.transparent,
              child: Slider(
                  value: _sliderValue,
                  onChanged: (val) {
                    setState(() {
                      _sliderValue = val;
                    });
                  }),
            )),
            Container(
              child: Text(
                "CommonQuick".tr,
                style: StyleUtil.textStyle(size: 12, color: Colors.green.shade400),
              ),
            ),
          ],
        ),
      ),
      Container(
        padding: SizeUtil.padding(left: 30, right: 30),
        width: SizeUtil.screenWidth(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "WalletReceiveAddress".tr + ": ",
              style: StyleUtil.textStyle(size: 12),
            ),
            Expanded(
                child: Text(
              '$_address',
              style: StyleUtil.textStyle(size: 12),
              softWrap: true,
            ))
          ],
        ),
      ),
      Container(
        margin: SizeUtil.margin(top: 30),
        padding: SizeUtil.padding(left: 30, right: 30),
        width: SizeUtil.screenWidth(),
        child: MaterialButton(
          height: SizeUtil.height(40),
          color: Colors.blue,
          textColor: Colors.white,
          child: Text("CommonConfirm1"),
          onPressed: () {},
        ),
      )
    ];
  }

  _buildFeeItem(Fee data) {
    return Container();
  }

  _requestFees() async {
    if (strIsEmpty(widget.address)) {
      return;
    }
    var result = await requestFees(
        {"symbol": widget.symbol, "address": widget.address, "contract": widget.contract, "contractAddress": widget.contractAddress});
  }

  @override
  void dispose() {
    super.dispose();
  }
}
