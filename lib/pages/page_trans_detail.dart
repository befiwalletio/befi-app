import 'package:cube/core/base_widget.dart';
import 'package:cube/core/constant.dart';
import 'package:cube/core/core.dart';
import 'package:cube/models/model_detail.dart';
import 'package:cube/pages/page_web.dart';
import 'package:flutter/material.dart';
import 'package:cube/utils/utils_size.dart';
import 'package:cube/views/appbar/appbar.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class PageTransDetail extends StatefulWidget {
  const PageTransDetail({Key key}) : super(key: key);

  @override
  _PageTransDetailState createState() => _PageTransDetailState();
}

class _PageTransDetailState extends SizeState<PageTransDetail> {
  String gwei = '1000000000';

  List<String> icons = ['icon_success.png', 'icon_fail.png', 'icon_pending.png'];
  int type = 2; //0,1,2
  CoinTrans _data;
  Color _color = BeeColors.blue;
  String _symbol;

  @override
  void initState() {
    super.initState();
    _data = CoinTrans().parser(Get.arguments);
    _symbol = Get.arguments['symbol'];
    type = 2;
    if (_data != null) {
      if (_data.status == 'success') {
        type = 0;
      } else if (_data.status == 'failed') {
        type = 1;
      }
    }
  }

  @override
  Widget createView(BuildContext context) {
    return Scaffold(
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
      ),
      body: SingleChildScrollView(
        child: Container(
          width: SizeUtil.screenWidth(),
          child: Column(
            children: [
              _buildCard(_buildTypeCard()),
              _buildCard(_buildAmountCard()),
              _buildCard(_buildInfoCard()),
              _buildCard(_buildDetailCard()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeCard() {
    String text = 'WalletTransfering'.tr;
    String time = _data != null ? _data.time : '--';
    switch (type) {
      case 0:
        text = 'CommonSuccess'.tr;
        break;
      case 1:
        text = 'CommonFailed'.tr;
        break;
      default:
        type = 2;
        break;
    }
    return Column(
      children: [
        Image.asset(
          "assets/icons/${icons[type]}",
          width: SizeUtil.width(33),
        ),
        Padding(
          padding: SizeUtil.padding(top: 10, bottom: 10),
          child: Text(
            text,
            style: Theme.of(context).primaryTextTheme.headline3,
          ),
        ),
        Text(
          time,
          style: Theme.of(context).primaryTextTheme.subtitle2,
        ),
      ],
    );
  }

  Widget _buildAmountCard() {
    return Row(
      children: [
        Text("WalletAmount".tr),
        Spacer(),
        Text(
          "${_data.type == 'in' ? '+' : '-'}${_data.value} ${_symbol}",
          style: Theme.of(context).primaryTextTheme.headline3,
        )
      ],
    );
  }

  Widget _buildInfoCard() {
    String gas = "";
    if (_data.contract.toUpperCase() == "TRX") {
      gas = "0";
    } else {
      gas = _data.gas;
    }

    return Column(
      children: [
        Container(
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
                    '${gas} ${_data.contract ?? ''}',
                    style: Theme.of(context).primaryTextTheme.headline6,
                  ),
                  _data != null && (_data.contract == 'ETH' || _data.contract == 'MATIC' || _data.contract == 'BNB')
                      ? Text(
                          "GasPrice(${_data.gasPrice}GWEI) * Gas(${_data.gasLimit})",
                          style: Theme.of(context).primaryTextTheme.subtitle2,
                        )
                      : Text('')
                ],
              ),
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
                  '${_data.to}',
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
                  '${_data.from}',
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
                '${'WalletTradeHash'.tr}:',
                style: Theme.of(context).primaryTextTheme.subtitle1,
              ),
              Expanded(
                  child: InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: _data.hash));
                  showTipsBar("CommonCopyTip".tr);
                },
                child: Padding(
                  padding: SizeUtil.padding(left: 20, top: 2),
                  child: Text(
                    '${_data.hash}',
                    style: Theme.of(context).primaryTextTheme.headline6,
                    textAlign: TextAlign.right,
                  ),
                ),
              ))
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailCard() {
    return InkWell(
      highlightColor: Colors.transparent, // 透明色
      splashColor: Colors.transparent, // 透明色
      onTap: () {
        Get.to(PageWeb(), arguments: {"url": _data.browser});
      },
      child: Row(
        children: [
          Text("WalletCheckDetail".tr),
          Spacer(),
          Icon(
            Icons.arrow_forward_ios,
            size: SizeUtil.width(13),
          )
        ],
      ),
    );
  }

  Widget _buildCard(Widget child) {
    return Card(
      elevation: 0,
      margin: SizeUtil.margin(left: 15, right: 15, top: 7, bottom: 7),
      child: Container(
        padding: SizeUtil.padding(all: 10),
        width: SizeUtil.screenWidth(),
        child: child,
      ),
    );
  }
}
