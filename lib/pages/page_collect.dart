import 'package:cube/core/base_widget.dart';
import 'package:cube/core/constant.dart';
import 'package:cube/core/core.dart';
import 'package:cube/models/model_base.dart';
import 'package:cube/utils/utils_console.dart';
import 'package:cube/utils/utils_size.dart';
import 'package:cube/views/appbar/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_extend/share_extend.dart';

class PageCollect extends StatefulWidget {
  const PageCollect({Key key}) : super(key: key);

  @override
  _PageCollectState createState() => _PageCollectState();
}

class _PageCollectState extends SizeState<PageCollect> {
  Color _backgroundColor = BeeColors.blue;
  Coin _data;
  GlobalKey previewContainer = GlobalKey();

  @override
  void initState() {
    super.initState();
    _data = Coin().parser(Get.arguments);
    if (_data.color != null && _data.color.isNotEmpty) {
      _backgroundColor = _data.color.toColor();
    }
    console.i(_data.json);
  }

  @override
  Widget createView(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: XAppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_outlined),
          onPressed: () {
            Get.back();
          },
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "WalletReceive".tr,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: RepaintBoundary(
        key: previewContainer,
        child: SingleChildScrollView(
          child: Container(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                Container(
                  alignment: Alignment.center,
                  padding: SizeUtil.padding(top: 10, bottom: 10, left: 14, right: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/icons/icon_warning_1.png",
                        width: SizeUtil.width(14),
                      ),
                      Expanded(
                        child: Container(
                          padding: SizeUtil.padding(bottom: 2, left: 8),
                          child: Text(
                            'WalletTransferInTip'.tr.replaceAll("{##}", _data.contract),
                            style: TextStyle(color: Colors.white, fontSize: SizeUtil.sp(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: SizeUtil.margin(top: 10),
                  width: SizeUtil.screenWidth() - SizeUtil.width(28),
                  decoration: new BoxDecoration(
                    color: Colors.white,
                    borderRadius: new BorderRadius.all(new Radius.circular(SizeUtil.width(10))),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Container(
                        padding: SizeUtil.padding(top: 30, bottom: 20, left: 14, right: 14),
                        child: Text(
                          '${"WalletScanTransferIn".tr.replaceAll("{coin}", _data.symbol)}',
                          style: Theme.of(context).primaryTextTheme.subtitle1.copyWith(fontSize: SizeUtil.sp(12)),
                        ),
                      ),
                      _buildQR(),
                      Padding(
                        padding: SizeUtil.padding(bottom: 10),
                        child: Text(
                          "WalletAddress".tr,
                          style: Theme.of(context).primaryTextTheme.subtitle2,
                        ),
                      ),
                      Padding(
                        padding: SizeUtil.padding(top: 5, left: 10, right: 10),
                        child: Text(
                          "${_data != null ? _data.address : ''}",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).primaryTextTheme.headline6.merge(TextStyle(fontSize: SizeUtil.sp(12))),
                        ),
                      ),
                      Container(
                        padding: SizeUtil.padding(bottom: 25, left: 20, right: 20, top: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildButton("CommonShare".tr, Icons.share, shareAction),
                            _buildButton("CommonCopy".tr, Icons.copy, () {
                              if (_data != null) {
                                Clipboard.setData(ClipboardData(text: _data.address));
                                showTipsBar("CommonCopyTip".tr);
                              }
                            }),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQR() {
    return Container(
      height: SizeUtil.height(226),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            Constant.Assets_Image + "qrcode_back.png",
            width: SizeUtil.width(226),
            height: SizeUtil.width(226),
          ),

          QrImage(
            data: _data.address,
            version: QrVersions.auto,
            size: SizeUtil.width(184),
            gapless: false,
          )
        ],
      ),
    );
  }

  Widget _buildButton(String title, IconData icon, GestureTapCallback callback) {
    return InkWell(
      onTap: () {
        if (callback != null) {
          callback();
        }
      },
      child: SizedBox(
        width: SizeUtil.width(50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.grey,
              size: SizeUtil.width(25),
            ),
            Text(
              title,
              style: TextStyle(color: Colors.grey, fontSize: SizeUtil.sp(12)),
            )
          ],
        ),
      ),
    );
  }

  shareAction() async {
    ShareExtend.share(_data.address, "text");
  }
}
