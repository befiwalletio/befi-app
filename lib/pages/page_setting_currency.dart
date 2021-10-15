import 'package:cube/core/base_widget.dart';
import 'package:cube/core/constant.dart';
import 'package:cube/utils/utils_event.dart';
import 'package:cube/utils/utils_size.dart';
import 'package:cube/utils/utils_sp.dart';
import 'package:cube/views/CustomBehavior.dart';
import 'package:cube/views/appbar/appbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PageSettingCurrency extends StatefulWidget {
  const PageSettingCurrency({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PageSettingCurrencyState();
  }
}

class _PageSettingCurrencyState extends SizeState<PageSettingCurrency> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget createView(BuildContext context) {
    return Scaffold(
      backgroundColor: BeeColors.FFF3F4F6,
      appBar: XAppBar(
        title: Text("CurrencyUnit".tr),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              margin: SizeUtil.margin(left: 15, right: 15, top: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(SizeUtil.width(9))),
                color: Colors.white,
              ),
              child: ScrollConfiguration(
                behavior: CustomBehavior(),
                child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: Constant.ZCurrencys.length,
                    itemBuilder: (context, index) {
                      return getContentItem(context, index);
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getContentItem(BuildContext context, int index) {
    Map<String, String> map = Constant.ZCurrencys[index];
    return InkWell(
      onTap: () {
        SPUtils().put(Constant.CS, map["name"]);
        eventBus.fire(ECurrency());
        Get.back();
      },
      child: SettingCurrencyCellWidget(index: index, map: map),
    );
  }
}

class SettingCurrencyCellWidget extends StatelessWidget {
  int index;
  Map<String, String> map;

  SettingCurrencyCellWidget({this.index, this.map});

  @override
  Widget build(BuildContext context) {
    String currency = SPUtils().getString(Constant.CS);
    if (currency == null || currency.isEmpty) {
      currency = 'USD';
    }

    String name = map['name'];
    String content = map['content'];

    return Container(
      height: SizeUtil.height(50),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: SizeUtil.width(20),
                ),
                Expanded(
                  child: Container(
                    child: Text(
                      content,
                      style: TextStyle(color: BeeColors.FF091C40, fontSize: SizeUtil.sp(14)),
                    ),
                  ),
                ),
                Container(
                  child: Image(
                    image: AssetImage(
                      Comparable.compare(name, currency) == 0
                          ? Constant.Assets_Image + "common_select_true.png"
                          : Constant.Assets_Image + "common_select_false.png",
                    ),
                    width: SizeUtil.width(18),
                    height: SizeUtil.width(18),
                  ),
                ),
                SizedBox(
                  width: SizeUtil.width(20),
                ),
              ],
            ),
          ),
          Container(
            margin: SizeUtil.margin(left: 20, right: 20),
            height: SizeUtil.height(1),
            color: BeeColors.FFF2F2F2,
          ),
        ],
      ),
    );
  }
}
