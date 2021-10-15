import 'package:cached_network_image/cached_network_image.dart';
import 'package:cube/core/base_widget.dart';
import 'package:cube/core/constant.dart';
import 'package:cube/core/core.dart';
import 'package:cube/models/model_base.dart';
import 'package:cube/models/model_home.dart';
import 'package:cube/net/requester.dart';
import 'package:cube/utils/utils_size.dart';
import 'package:cube/views/appbar/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:get/get.dart';
import 'package:cube/net/manager_api.dart';

class PageMyToken extends StatefulWidget {
  const PageMyToken({Key key}) : super(key: key);

  @override
  _PageMyTokenState createState() => _PageMyTokenState();
}

class PageMyTokenController extends GetxController {
  var items = [].obs;

  changeItems(data) {
    if (data == null) {
      data = [];
    }
    items.value = data;
  }
}

class _PageMyTokenState extends SizeState<PageMyToken> {
  String _wid = '';
  Color _color = BeeColors.blue;
  EasyRefreshController _refreshController = EasyRefreshController();
  final PageMyTokenController _obsController = Get.put(PageMyTokenController());

  @override
  void initState() {
    super.initState();
    _wid = Get.arguments['wid'];
    Future.delayed(Duration(seconds: 1), () {
      _requestCoins();
    });
  }

  @override
  Widget createView(BuildContext context) {
    return Scaffold(
        appBar: XAppBar(
          leading: Container(
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_outlined,
                size: SizeUtil.width(20),
              ),
              onPressed: () {
                Get.back();
              },
            ),
          ),
          backgroundColor: _color,
          centerTitle: true,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleSpacing: 0,
          title: Text(
            "WalletAllToken".tr,
            style: Theme.of(context).primaryTextTheme.headline6.merge(TextStyle(color: Colors.white)),
          ),
          actions: [],
        ),
        body: Container(
          child: Column(
            children: [
              Obx(() => _obsController.items.isEmpty
                  ? buildEmpty()
                  : Expanded(
                      child: _buildRefresh(_createList(), _refreshController, () async {
                      _requestCoins();
                      _refreshController.finishRefresh();
                    })))
            ],
          ),
        ));
  }

  Widget _buildRefresh(child, EasyRefreshController controller, refreshCallback, {noMore: true, loadCallback}) {
    var refreshView = EasyRefresh(
      header: MaterialHeader(),
      onRefresh: () async {
        await refreshCallback();
        controller.finishRefresh(success: true);
      },
      onLoad: loadCallback != null
          ? () async {
              await loadCallback();
              controller.finishLoad(success: true, noMore: noMore);
            }
          : null,
      controller: controller,
      child: child,
    );
    return refreshView;
  }

  Widget _createList() {
    return ListView.separated(
      separatorBuilder: (BuildContext context, int index) => Divider(height: 1.0, color: Colors.grey),
      itemBuilder: (context, index) {
        Coin item = _obsController.items[index];
        return _createItem(item, index);
      },
      itemCount: _obsController.items.length,
    );
  }

  Widget _createItem(Coin coin, index) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () async {

        },
        child: Container(
          padding: SizeUtil.padding(top: 10, bottom: 10, left: 15, right: 4),
          child: Row(
            children: [
              CachedNetworkImage(
                width: SizeUtil.width(35),
                height: SizeUtil.width(35),
                imageUrl: coin.icon,
                placeholder: (context, url) => Image.asset(
                  Constant.Assets_Image + "common_placeholder.png",
                ),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
              Expanded(
                  child: Container(
                margin: SizeUtil.margin(left: 10, right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${coin.symbol}',
                          style: Theme.of(context).primaryTextTheme.headline6.merge(TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Text(
                          ' (${coin.name})',
                          style: Theme.of(context).primaryTextTheme.subtitle2.merge(TextStyle(fontSize: SizeUtil.sp(10))),
                        ),
                      ],
                    ),
                    Text(
                      _formatAddress(coin.contractAddress),
                      style: Theme.of(context).primaryTextTheme.subtitle2,
                    ),
                  ],
                ),
              )),
              Container(
                margin: SizeUtil.margin(left: 10, right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${coin.balance}',
                          style: Theme.of(context).primaryTextTheme.bodyText2.merge(TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    Text(
                      '≈${coin.mainValue} ${coin.contract}',
                      style: Theme.of(context).primaryTextTheme.subtitle2.merge(TextStyle(fontSize: SizeUtil.sp(10))),
                    ),
                  ],
                ),
              ),
              !coin.isHas
                  ? IconButton(
                      // iconSize: SizeUtil.width(20),
                      icon: Icon(
                        Icons.add,
                        color: Colors.grey,
                        size: SizeUtil.width(20),
                      ),
                      onPressed: () async {
                        await _requestAddCoin(coin);
                      })
                  : IconButton(
                      // iconSize: SizeUtil.width(20),
                      icon: Icon(
                        Icons.done,
                        color: BeeColors.blue,
                      ),
                      onPressed: () async {})
            ],
          ),
        ),
      ),
    );
  }

  _requestCoins() async {
    Result<Chains> result = await requestMyTokens(_wid);
    if (result.result != null) {
      _obsController.changeItems(result.result.items);
    }
  }

  _requestAddCoin(Coin coin) async {
    List<String> descAddresses = await saveCoins(context, _wid, [coin]);
    showLoading();
    Result<DefaultModel> result = await requestAddCoin({
      "wid": _wid,
      "symbol": coin.symbol,
      "contract": coin.contract,
      "contractAddress": coin.contractAddress,
    });
    showLoading(show: false);
    showTipsBar("WalletAddSuccess".tr);
    await _requestCoins();
  }

  String _formatAddress(String address) {
    if (strIsEmpty(address)) {
      return '';
    }
    if (address.length < 16) {
      return address;
    }
    String start = address.substring(0, 6);
    String end = address.substring(address.length - 4);
    return '$start...$end';
  }

  @override
  void dispose() {
    super.dispose();
    _obsController.dispose();
  }
}
