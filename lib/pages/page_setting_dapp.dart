import 'package:cube/core/base_widget.dart';
import 'package:cube/utils/utils_size.dart';
import 'package:cube/views/CustomBehavior.dart';
import 'package:cube/views/appbar/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

class PageSettingDapp extends StatefulWidget {
  const PageSettingDapp({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PageSettingDappState();
  }
}

class _PageSettingDappState extends SizeState<PageSettingDapp> {
  EasyRefreshController settingDappController = EasyRefreshController();

  void currencyAction() {}

  @override
  Widget createView(BuildContext context) {
    return Scaffold(
      appBar: XAppBar(
        title: Text("DApp Settings"),
      ),
      body: Container(
        color: Colors.black12,
        child: Column(
          children: [
            Container(
              height: SizeUtil.width(1),
              color: Colors.black12,
            ),
            Expanded(
              flex: 1,
              child: ScrollConfiguration(
                behavior: CustomBehavior(),
                child: EasyRefresh(
                  controller: settingDappController,
                  child: ListView.builder(
                    itemCount: 8,
                    itemBuilder: (context, index) {
                      return getContentItem(context, index);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getContentItem(BuildContext context, int index) {
    return InkWell(
      onTap: () {},
      child: SettingDappCellWidget(
        index: index,
      ),
    );
  }
}

class SettingDappCellWidget extends StatelessWidget {
  int index;
  bool check = false;

  IconData image = Icons.account_balance_wallet;
  String title = "USD";

  SettingDappCellWidget({this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SizeUtil.width(44),
      color: Colors.white,
      child: Column(
        children: [
          Container(
            height: SizeUtil.width(43),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: SizeUtil.width(10),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: SizeUtil.sp(14),
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ),
                SizedBox(
                  width: SizeUtil.width(20),
                ),
                Container(
                  child: Icon(
                    image,
                    color: Theme.of(context).iconTheme.color,
                  ),
                ),
                SizedBox(
                  width: SizeUtil.width(10),
                ),
              ],
            ),
          ),
          Container(
            height: SizeUtil.width(1),
            color: Colors.black12,
          ),
        ],
      ),
    );
  }
}
