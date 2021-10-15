import 'package:cached_network_image/cached_network_image.dart';
import 'package:cube/chain/chain_exp.dart';
import 'package:cube/chain/chaincore.dart';
import 'package:cube/core/base_widget.dart';
import 'package:cube/core/constant.dart';
import 'package:cube/core/core.dart';
import 'package:cube/models/model_base.dart';
import 'package:cube/net/manager_api.dart';
import 'package:cube/net/requester.dart';
import 'package:cube/pages/page_scan.dart';
import 'package:cube/utils/utils_console.dart';
import 'package:cube/utils/utils_db.dart';
import 'package:cube/utils/utils_event.dart';
import 'package:cube/utils/utils_size.dart';
import 'package:cube/utils/utils_sp.dart';
import 'package:cube/views/appbar/appbar.dart';
import 'package:cube/views/dialog/dialog_nft_confirm_board.dart';
import 'package:cube/views/dialog/dialog_pass_board.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class PageNftTransfer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PageNftTransferState();
  }
}

class PageNftTransferState extends SizeState<PageNftTransfer> {
  TextEditingController _addressController = TextEditingController();
  TextEditingController _remarkController = TextEditingController();
  String to = '';

  String _wid = '';
  Coin _nft;
  Coin _nftdetail;
  Coin _chain;

  String gas_price_str = '0.0000';
  String gas_price = '0.0000';
  String gas_limit = '21000';
  Fee _fee;
  List<Fee> _fees;
  String nonce;

  @override
  void initState() {
    super.initState();
    _wid = Get.arguments["wid"];
    _nft = Get.arguments['nft'];
    _nftdetail = Get.arguments['nftdetail'];

    Global.SUPORT_CHAINS.forEach((element) {
      if (element.contract.compareTo(_nftdetail.contract) == 0) {
        _chain = element;
      }
    });

    if (_chain != null && _chain.icon != null) {
      _nft.chainName = _chain.name;
      _nftdetail.chainName = _chain.name;
    }
  }

  _requestNonce() async {
    Result result = await requestNonce({"address": _nft.address, "contract": _nft.contract});
    if (result != null && result.result != null) {
      setState(() {
        nonce = result.result.nonce;
      });
    }
  }

  _requestInput() async {
    Result<DefaultModel> result = await requestNFTTokenData(
        _nft.address, strIsEmpty(to) ? _addressController.text : to, _nftdetail.tokenID, _nft.contract, _nft.contractAddress);
    if (result != null && result.result != null && !strIsEmpty(result.result.inputData)) {
      return result.result.inputData;
    }
    return null;
  }

  transferAction() async {
    var result = await _preCommit();
    if (!result) {
      return;
    }
    showLoading();
    if (_chain != null && _chain.icon != null) {
      _nftdetail.icon = _chain.icon;
      _nftdetail.chainName = _chain.name;
    }
    var inputData = await _requestInput();
    if (inputData == null) {
      showLoading(show: false);
      showWarnBar("CommonFailed".tr);
      return;
    }
    Result<Fees> feesResult = await requestFees({
      "symbol": _nft.symbol,
      "contract": _nft.contract,
      "from": _nft.address,
      "to": _nft.contractAddress,
      "value": "0",
      "data": inputData,
    });
    showLoading(show: false);

    await showDialog(
        useSafeArea: false,
        context: context,
        builder: (cotext) {
          return DialogNftInfoBoard(
            icon: _nftdetail.icon,
            name: _nftdetail.name,
            fees: feesResult.result,
            coin: _nftdetail.contract,
            chain: _nftdetail.contract,
            data: {"from": _nft.address, "to": strIsEmpty(to) ? _addressController.text : to, "value": _nftdetail.tokenID},
            nft: _nftdetail,
            callback: (value) async {
              gas_price = value['gas_price'];
              gas_limit = value['gas_limit'];

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
  }

  Future _preCommit() {
    if (strIsEmpty(_addressController.text)) {
      showWarnBar("WalletInputReceiveTip".tr);
      return Future.value(false);
    }
    return Future.value(true);
  }

  Future _commit(String data) async {
    showLoading();
    String pass = getTokenId(data);
    var auth = await DBHelper().queryAuth();
    var wid = SPUtils().getString(Constant.CUSTOM_WID);
    Identity identity = await DBHelper().queryIdentity(wid);
    String privateKey = await decrypt(identity.token, pass);
    console.i(identity.toJson());
    console.i(privateKey);
    await _requestNonce();
    var contract = _nft.contract != null ? _nft.contract.toLowerCase() : "";
    Chain chain = getChain(contract);
    if (chain == null) {
      showWarnBar("WalletTransferNo".tr);
      return;
    }
    if (identity.tokenType == 'mnemonic') {
      privateKey = await chain.getPrivateKey(mnemonic: privateKey);
    } else if (identity.tokenType == 'keystore') {
      privateKey = await await decrypt(identity.privateKey, pass);
    }
    var signParams = {
      "to": strIsEmpty(to) ? _addressController.text : to,
      "amount": "0",
      "gasPrice": gas_price,
      "gasLimit": gas_limit,
      "privateKey": privateKey,
      "data": '',
      "nonce": nonce.toInt(),
    };
    var params = {
      "from": _nft.address,
      "to": strIsEmpty(to) ? _addressController.text : to,
      "contract": _nft.contract,
      "contractAddress": _nft.contractAddress,
      "value": "0",
      "sign": "",
      "data": ""
    };
    if (!strIsEmpty(_nft.contractAddress)) {
      signParams['to'] = _nft.contractAddress;
      signParams['amount'] = '0';
      var inputData = await _requestInput();
      if (inputData == null) {
        showWarnBar("CommonFailed".tr);
        return;
      }
      signParams['data'] = inputData;
      params['data'] = inputData;
    }
    console.i({"signParams": signParams});
    var sign = await chain.signTransaction(signParams);
    params['sign'] = sign;

    console.i({
      "pass": pass,
      "auth": auth,
      "wid": wid,
      "identity": identity,
      "privateKey": privateKey,
      "sign": sign,
      "params": params,
      "signParams": signParams,
    });
    showLoading(show: false);
    Result<DefaultModel> result = await requestSend(params);
    if (strIsEmpty(result.result.hash)) {
      showWarnBar(result.msg, title: "交易失败");
    } else {
      eventBus.fire(UpdateNft());
      Get.back();
      await showTipsBar("WalletTradeSuccess", backgroundColor: BeeColors.green);
    }
  }

  @override
  Widget createView(BuildContext context) {
    return Scaffold(
      backgroundColor: BeeColors.FFF3F4F6,
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
          "WalletTransfer".tr,
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
        child: Column(
          children: [
            SizedBox(
              height: SizeUtil.width(5),
            ),
            createAddress(),
            SizedBox(
              height: SizeUtil.width(10),
            ),
            createInfo(),
            SizedBox(
              height: SizeUtil.width(15),
            ),
            createButton(),
          ],
        ),
      ),
    );
  }

  Widget createAddress() {
    return Container(
      margin: EdgeInsets.only(left: SizeUtil.width(20), right: SizeUtil.width(20)),
      height: SizeUtil.width(80),
      decoration: new BoxDecoration(
        color: Colors.white,
        borderRadius: new BorderRadius.circular(SizeUtil.width(6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(left: SizeUtil.width(12), right: SizeUtil.width(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("WalletReceiveAddress".tr, style: Theme.of(context).primaryTextTheme.bodyText1),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: SizeUtil.width(12), right: SizeUtil.width(12)),
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
            ),
          ),
        ],
      ),
    );
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
            style: Theme.of(context).primaryTextTheme.bodyText1,
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
                  imageUrl: _nftdetail != null && _nftdetail.img != null ? _nftdetail.img : "",
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
                      _nftdetail != null && _nftdetail.name != null ? _nftdetail.name : "",
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
                            imageUrl: _chain != null && _chain.icon != null ? _chain.icon : "",
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
                          _nft != null && _nft.chainName != null ? _nft.chainName : "",
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
                          "Nft_Token_Id".tr + (_nftdetail != null && _nftdetail.tokenID != null ? _nftdetail.tokenID : ""),
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

  Widget createRemarks() {
    return Container(
      margin: EdgeInsets.only(left: SizeUtil.width(20), right: SizeUtil.width(20)),
      height: SizeUtil.width(80),
      decoration: new BoxDecoration(
        color: Colors.white,
        borderRadius: new BorderRadius.circular(SizeUtil.width(6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(left: SizeUtil.width(12), right: SizeUtil.width(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Nft_Transfer_Remark".tr, style: Theme.of(context).primaryTextTheme.bodyText1),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: SizeUtil.width(12), right: SizeUtil.width(12)),
            padding: SizeUtil.padding(top: 5, bottom: 10),
            child: TextField(
              autofocus: false,
              decoration: InputDecoration.collapsed(
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  fillColor: Colors.transparent,
                  filled: false,
                  hintText: 'Nft_Transfer_Remark_Tip'.tr,
                  hintStyle: StyleUtil.textStyle(size: 14, color: Colors.black26)),
              style: StyleUtil.textStyle(size: 14, weight: FontWeight.bold),
              textAlign: TextAlign.left,
              controller: _remarkController,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget createButton() {
    return Container(
      margin: EdgeInsets.only(left: SizeUtil.width(20), right: SizeUtil.width(20)),
      width: SizeUtil.screenW - SizeUtil.width(40),
      height: SizeUtil.width(48),
      child: MaterialButton(
        onPressed: () {
          FocusScope.of(context).requestFocus(FocusNode());
          transferAction();
        },
        color: BeeColors.FF00A0E8,
        height: SizeUtil.height(48),
        shape: RoundedRectangleBorder(
          side: BorderSide.none,
          borderRadius: SizeUtil.radius(all: SizeUtil.width(24)),
        ),
        child: Text(
          'CommonConfirm1'.tr,
          style: StyleUtil.textStyle(size: 16, color: Colors.white),
        ),
      ),
    );
  }
}
