import 'dart:convert';

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:cube/chain/chaincore.dart';
import 'package:cube/chain/chain_exp.dart';
import 'package:cube/core/constant.dart';
import 'package:cube/core/core.dart';
import 'package:cube/models/model_base.dart';
import 'package:cube/net/manager_api.dart';
import 'package:cube/net/requester.dart';
import 'package:cube/pages/page_fee.dart';
import 'package:cube/pages/page_scan.dart';
import 'package:cube/utils/utils_console.dart';
import 'package:cube/core/base_widget.dart';
import 'package:cube/utils/utils_db.dart';
import 'package:cube/utils/utils_event.dart';
import 'package:cube/utils/utils_math.dart';
import 'package:cube/utils/utils_sp.dart';
import 'package:cube/views/dialog/dialog_pass_board.dart';
import 'package:cube/views/dialog/dialog_trans_detail_board.dart';
import 'package:flutter/material.dart';
import 'package:cube/utils/utils_size.dart';
import 'package:cube/views/appbar/appbar.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class PagePay extends StatefulWidget {
  const PagePay({Key key}) : super(key: key);

  @override
  _PagePayState createState() => _PagePayState();
}

class _PagePayState extends SizeState<PagePay> {
  String gwei = '1000000000';
  String amount = '0.0';

  String coin = '';
  String gas_price_str = '0.0000';
  String gas_price = '0.0000';
  String gas_limit = '21000';

  String csUnit = '';

  String value = '0';
  String to = '';
  String from = '';
  String hash = '';

  Coin _data;
  bool isTron = false;
  Fee _fee;
  List<Fee> _fees;
  String nonce;

  TextEditingController _addressController = TextEditingController();
  TextEditingController _transAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _data = Coin().parser(Get.arguments);
    if (_data.contract.toUpperCase() == "TRX") {
      isTron = true;
    } else {
      isTron = false;
    }
    coin = _data.symbol;
    from = _data.address;
    csUnit = _data.csUnit;
    amount = _data.balance;
    console.i(_data.toJson());
    _requestFees();
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
            icon: Icon(
              Icons.arrow_back_ios_outlined,
              size: SizeUtil.width(20),
            ),
            onPressed: () {
              Get.back();
            },
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text(
            "WalletTransfer".tr + " $coin",
            style: Theme.of(context).primaryTextTheme.headline3,
          ),
          actions: [
            Builder(builder: (context) {
              return IconButton(
                  icon: Image.asset(
                    "assets/icons/icon_scan.png",
                    width: SizeUtil.width(20),
                  ),
                  onPressed: () {
                    Get.to(ScanCodePage(
                      callback: (barcode) async {
                        barcode = barcode.trim();
                        if (!strIsEmpty(barcode)) {
                          setState(() {
                            _addressController.text = barcode;
                            _addressController.selection =
                                TextSelection.fromPosition(TextPosition(affinity: TextAffinity.downstream, offset: _addressController.text.length));
                          });
                        }
                      },
                    ));
                  });
            })
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            width: SizeUtil.screenWidth(),
            child: Column(
              children: [
                _buildCard(_buildToAddress()),
                _buildCard(_buildAmount()),
                _buildCard(isTron ? _buildTrxFee() : _buildFee(), padding: SizeUtil.padding(all: 0)),
                _buildButton()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToAddress() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("WalletReceiveAddress".tr, style: Theme.of(context).primaryTextTheme.bodyText1),
              ],
            ),
          ),
          Container(
              padding: SizeUtil.padding(top: 5, bottom: 10),
              child: TextField(
                autofocus: false,
                decoration: InputDecoration.collapsed(
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    fillColor: Colors.transparent,
                    filled: false,
                    hintText: 'WalletInputReceiveTip'.tr,
                    hintStyle: StyleUtil.textStyle(size: 14, color: Colors.black26)),
                style: StyleUtil.textStyle(size: 14, weight: FontWeight.bold),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Za-z]'))],
                textAlign: TextAlign.left,
                controller: _addressController,
                keyboardType: TextInputType.multiline,
                minLines: 1,
                maxLines: 5,
                onChanged: (text) {
                  if (!strIsEmpty(text)) {
                    to = text;
                  } else {
                    to = '';
                  }
                },
              )),
        ],
      ),
    );
  }

  Widget _buildAmount() {
    String cs = MathCalc.startWithStr(value).multiplyStr(_data != null ? _data.price : '0').toString();
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              Text("WalletAmount".tr, style: Theme.of(context).primaryTextTheme.bodyText1),
              Spacer(),
              Text(' $amount ${coin}', style: Theme.of(context).primaryTextTheme.headline6),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: SizeUtil.padding(top: 10, bottom: 10),
                  child: TextField(
                    autofocus: false,
                    decoration: InputDecoration.collapsed(
                        fillColor: Colors.transparent,
                        filled: false,
                        hintText: '0.00',
                        hintStyle: StyleUtil.textStyle(size: 16, color: Colors.black26)),
                    style: StyleUtil.textStyle(size: 16, weight: FontWeight.bold),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Za-z.]'))],
                    textAlign: TextAlign.left,
                    controller: _transAmountController,
                    onChanged: (text) {
                      setState(() {
                        if (!strIsEmpty(text)) {
                          value = text;
                        } else {
                          value = '0';
                        }
                      });
                    },
                  ),
                ),
              ),
              Text('${"≈ $csUnit"} $cs', style: Theme.of(context).primaryTextTheme.subtitle2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMemo() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("WalletMemoRemark".tr, style: Theme.of(context).primaryTextTheme.headline6.merge(TextStyle(fontWeight: FontWeight.bold))),
          Container(
            padding: SizeUtil.padding(top: 10, bottom: 10),
            child: TextField(
              autofocus: false,
              decoration: InputDecoration.collapsed(
                  fillColor: Colors.transparent,
                  filled: false,
                  hintText: 'WalletInputMemoTip'.tr,
                  hintStyle: StyleUtil.textStyle(size: 12, color: Colors.black26)),
              style: StyleUtil.textStyle(size: 12, weight: FontWeight.bold),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Za-z]'))],
              textAlign: TextAlign.left,
              controller: _transAmountController,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFee() {
    String gas = MathCalc.startWithStr(gas_limit).multiplyStr(gas_price).toString();

    return Material(
      color: Colors.white,
      borderRadius: SizeUtil.radius(all: 4),
      child: InkWell(
        onTap: () async {
          var result = await Get.to(PageFee(), arguments: {"data": _fees, "coin": _data.contract});
          console.i(result);
          if (mounted && result != null) {
            setState(() {
              gas_price_str = result['gas_price_str'];
              gas_price = result['gas_price'];
              gas_limit = result['gas_limit'];
              _fee = Fee().parser(result);
            });
          }
        },
        radius: SizeUtil.width(10),
        borderRadius: SizeUtil.radius(all: 4),
        child: Container(
          padding: SizeUtil.padding(all: 10),
          child: Row(
            children: [
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("矿工费".tr, style: Theme.of(context).primaryTextTheme.bodyText1),
                  Container(
                    padding: SizeUtil.padding(top: 10, bottom: 5),
                    child: Text(
                      "${gas} ${_data.contract}",
                      style: StyleUtil.textStyle(size: 12, weight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Container(
                    padding: SizeUtil.padding(top: 0, bottom: 10),
                    child: Text(
                      "Gas Price(${gas_price_str}GWEI) * Gas(${gas_limit})",
                      style: StyleUtil.textStyle(size: 10, weight: FontWeight.normal, color: Colors.grey),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              )),
              Icon(
                Icons.arrow_forward_ios_sharp,
                color: Colors.grey,
                size: SizeUtil.width(15),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrxFee() {
    String gas = _fee != null && _fee.fee != null ? _fee.fee : "1";

    return Material(
      color: Colors.white,
      borderRadius: SizeUtil.radius(all: 4),
      child: InkWell(
        radius: SizeUtil.width(10),
        borderRadius: SizeUtil.radius(all: 4),
        child: Container(
          padding: SizeUtil.padding(all: 10),
          child: Row(
            children: [
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("WalletGasFee1".tr, style: Theme.of(context).primaryTextTheme.bodyText1),
                  Container(
                    padding: SizeUtil.padding(top: 10, bottom: 5),
                    child: Text(
                      "${gas} ${_data.contract}",
                      style: StyleUtil.textStyle(size: 12, weight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton() {
    return Container(
      margin: SizeUtil.margin(top: 20),
      child: MaterialButton(
        onPressed: () async {
          var result = await _preCommit();
          if (!result) {
            return;
          }
          await showDialog(
              useSafeArea: false,
              context: context,
              builder: (cotext) {
                return DialogTransDetailBoard(
                  coin: _data.symbol,
                  from: _data.address,
                  to: strIsEmpty(to) ? _addressController.text : to,
                  amount: _getValue(),
                  contract: _data.contract ?? _data.symbol,
                  contractAddress: _data.contractAddress,
                  fee: _fee,
                  callback: () async {
                    Get.back();
                    await showDialog(
                        useSafeArea: false,
                        context: context,
                        barrierDismissible: false,
                        builder: (cotext) {
                          return DialogPassBoard(
                            callback: (data) async {
                              await _commit(data);
                            },
                          );
                        });
                  },
                );
              });
        },
        color: BeeColors.blue,
        minWidth: SizeUtil.width(300),
        height: SizeUtil.width(45),
        shape: RoundedRectangleBorder(
          side: BorderSide.none,
          borderRadius: SizeUtil.radius(all: 100),
        ),
        child: Text(
          'WalletTransfer'.tr,
          style: StyleUtil.textStyle(size: 14, color: Colors.white),
        ),
      ),
    );
  }

  _getTo() {
    if (!strIsEmpty(_data.contractAddress)) {
      return _data.contractAddress;
    }
    return strIsEmpty(to) ? _addressController.text : to;
  }

  _getValue() {
    return _transAmountController.text;
  }

  Future _preCommit() {
    if (strIsEmpty(_addressController.text)) {
      showWarnBar("WalletInputReceiveTip".tr);
      return Future.value(false);
    }
    if (strIsEmpty(_transAmountController.text)) {
      showWarnBar("WalletInputAmountTip".tr);
      return Future.value(false);
    }
    double fee = 0;
    if (_data.symbol == _data.contract) {
      String gas = MathCalc.startWithStr(gas_limit).multiplyStr(gas_price).toString();
      fee = gas.toDouble();
    }

    double transAmount = _transAmountController.text.toDouble();
    double balance = amount.toDouble();
    if (transAmount + fee > balance) {
      showWarnBar("WalletBalanceInsufficient".tr);
      return Future.value(false);
    }

    return Future.value(true);
  }

  Future _commit(String data) async {
    showLoading();
    String pass = getTokenId(data);
    var auth = await DBHelper().queryAuth();
    var wid = SPUtils().getString(Constant.CUSTOM_WID);
    String privateKey = await decrypt(_data.privateKey, pass);
    await _requestNonce();
    var contract = _data.contract != null ? _data.contract.toLowerCase() : "";
    Chain chain = getChain(contract);
    if (chain == null) {
      showWarnBar("WalletTransferNo".tr);
      return;
    }
    var signParams = {
      "to": strIsEmpty(to) ? _addressController.text : to,
      "amount": _transAmountController.text,
      "gasPrice": gas_price,
      "gasLimit": gas_limit,
      "privateKey": privateKey,
      "data": '',
      "nonce": nonce.toInt(),
      "assetName": _data.assetName != null ? _data.assetName : ""
    };
    var params = {
      "from": from,
      "to": strIsEmpty(to) ? _addressController.text : to,
      "contract": _data.contract,
      "contractAddress": _data.contractAddress,
      "value": _transAmountController.text,
      "sign": "",
      "data": "",
      "assetName": _data.assetName != null ? _data.assetName : ""
    };
    if (!strIsEmpty(_data.assetName)) {
    } else if (!strIsEmpty(_data.contractAddress)) {
      signParams['to'] = _data.contractAddress;
      signParams['amount'] = '0';
      var inputData = await _requestInput(_transAmountController.text);
      if (inputData != null && inputData.indexOf("{") >= 0) {
        inputData = json.decode(inputData);
      }
      signParams['data'] = inputData;
      params['data'] = json.encode(inputData);
    }
    console.i({"signParams": signParams});
    var sign = await chain.signTransaction(signParams);
    params['sign'] = sign;

    showLoading(show: false);
    Result<DefaultModel> result = await requestSend(params);
    if (strIsEmpty(result.result.hash)) {
      showWarnBar("交易失败".tr);
    } else {
      eventBus.fire(UpdateChain());
      Get.back();
      await showTipsBar("WalletTradeSuccess".tr, backgroundColor: BeeColors.green);
    }
  }

  Widget _buildCard(Widget child, {padding}) {
    return Card(
      elevation: 0,
      margin: SizeUtil.margin(left: 15, right: 15, top: 7, bottom: 7),
      child: Container(
        padding: padding ?? SizeUtil.padding(all: 10),
        width: SizeUtil.screenWidth(),
        child: child,
      ),
    );
  }

  goScan() async {
    var options = ScanOptions(
        );
    ScanResult result = await BarcodeScanner.scan(options: options);
    String str = "";
    if (result.rawContent != null) {
      str = result.rawContent;
    }
    setState(() {
      _addressController.text = str;
      _addressController.selection =
          TextSelection.fromPosition(TextPosition(affinity: TextAffinity.downstream, offset: _addressController.text.length));
    });
  }

  _requestFees() async {
    if (strIsEmpty(_data.address)) {
      return;
    }
    Result<Fees> result =
        await requestFees({"symbol": _data.symbol, "address": _data.address, "contract": _data.contract, "contractAddress": _data.contractAddress});
    Fee defaultFee;
    if (result.result != null && result.result.items != null) {
      result.result.items.forEach((element) {
        if (element.type == 'general') {
          defaultFee = element;
        }
      });
    }
    setState(() {
      _fees = result.result.items;
      if (defaultFee != null) {
        gas_price_str = defaultFee.gas_price_str;
        gas_price = defaultFee.gas_price;
        gas_limit = defaultFee.gas_limit;
        _fee = defaultFee;
      }
    });
  }

  _requestNonce() async {
    Result result = await requestNonce({"address": from, "contract": _data.contract});
    if (result != null && result.result != null) {
      setState(() {
        nonce = result.result.nonce;
      });
    }
  }

  _requestInput(value) async {
    Result<DefaultModel> result = await requestInputData({
      "from": from,
      "value": value,
      "to": strIsEmpty(to) ? _addressController.text : to,
      "contract": _data.contract,
      "contractAddress": _data.contractAddress
    });
    if (result != null && result.result != null) {
      return result.result.inputData;
    }
    return "";
  }
}
