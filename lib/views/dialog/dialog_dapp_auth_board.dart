import 'package:cached_network_image/cached_network_image.dart';
import 'package:cube/core/base_widget.dart';
import 'package:cube/core/constant.dart';
import 'package:cube/core/core.dart';
import 'package:cube/utils/utils_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DialogDappAuthBoard extends StatefulWidget {
  final String icon;
  final String name;
  final String url;
  final String chain;
  final BoolCallback callback;

  const DialogDappAuthBoard({Key key, this.icon, this.name, this.url, this.chain, this.callback}) : super(key: key);

  @override
  _DialogDappAuthBoardState createState() => _DialogDappAuthBoardState();
}

class _DialogDappAuthBoardState extends SizeState<DialogDappAuthBoard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget createView(BuildContext context) {
    String desc = 'DiscoverInTip'.tr.replaceAll("{name}", widget.name);
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
                        "WalletAuthApply".tr,
                        style: Theme.of(context).primaryTextTheme.subtitle1,
                      ),
                    ),
                    //内容
                    Container(
                      width: SizeUtil.screenWidth(),
                      margin: SizeUtil.margin(all: 14, right: 14),
                      padding: SizeUtil.padding(all: 10),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(6.0))),
                      child: Column(
                        children: [
                          Container(
                            width: SizeUtil.width(60),
                            height: SizeUtil.width(60),
                            padding: SizeUtil.padding(all: 5),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.grey[100]),
                                borderRadius: BorderRadius.all(Radius.circular(6.0))),
                            child: CachedNetworkImage(
                              imageUrl: widget.icon ?? '',
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
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding: SizeUtil.padding(left: 20, right: 20),
                      width: SizeUtil.screenWidth(),
                      child: Row(
                        children: [
                          Expanded(
                              child: MaterialButton(
                            shape: RoundedRectangleBorder(
                              side: BorderSide.none,
                              borderRadius: SizeUtil.radius(all: 100),
                            ),
                            elevation: 0,
                            onPressed: () {
                              if (widget.callback != null) {
                                widget.callback(false);
                              }
                            },
                            height: SizeUtil.height(30),
                            textColor: BeeColors.blue,
                            color: BeeColors.blue[50],
                            child: Text('CommonRefuse'.tr),
                          )),
                          SizedBox(
                            width: SizeUtil.width(20),
                          ),
                          Expanded(
                              child: MaterialButton(
                            shape: RoundedRectangleBorder(
                              side: BorderSide.none,
                              borderRadius: SizeUtil.radius(all: 100),
                            ),
                            elevation: 0,
                            height: SizeUtil.height(30),
                            onPressed: () {
                              if (widget.callback != null) {
                                widget.callback(true);
                              }
                            },
                            textColor: Colors.white,
                            color: BeeColors.blue,
                            child: Text('CommonConfirm1'.tr),
                          ))
                        ],
                      ),
                    )
                  ],
                ),
              ))
        ],
      ),
    ));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
