import 'package:cube/core/base_widget.dart';
import 'package:cube/core/constant.dart';
import 'package:cube/core/core.dart';
import 'package:cube/models/model_base.dart';
import 'package:cube/pages/page_web.dart';
import 'package:cube/utils/utils_size.dart';
import 'package:cube/views/appbar/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class PageMineAbout extends StatefulWidget {
  const PageMineAbout({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PageMineAboutState();
  }
}

class _PageMineAboutState extends SizeState<PageMineAbout> {
  int _developStep = 0;
  int _startTime = 0;

  @override
  Widget createView(BuildContext context) {
    return Scaffold(
      backgroundColor: BeeColors.FFF3F4F6,
      appBar: XAppBar(
        elevation: 0,
        title: Text("Mine_About".tr),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: SizeUtil.height(30),
            ),
            Image.asset(
              Constant.Assets_Image + "common_logo.png",
              width: SizeUtil.width(72),
              height: SizeUtil.width(72),
            ),
            SizedBox(
              height: SizeUtil.height(15),
            ),
            Container(
              child: Text(
                Global.VERSION,
                style: TextStyle(
                  fontSize: SizeUtil.sp(18),
                  color: BeeColors.FF091C40,
                ),
              ),
            ),
            SizedBox(
              height: SizeUtil.width(10),
            ),
            Container(
              margin: SizeUtil.margin(left: 15, right: 15, top: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(SizeUtil.width(9))),
                color: Color(0xffffffff),
              ),
              child: getContentNormal("CommonVersionHistory".tr, Global.PAGE_VERSION),
            ),
            SizedBox(
              height: SizeUtil.width(10),
            ),
            Container(
              margin: SizeUtil.margin(left: 15, right: 15, top: 12),
              padding: SizeUtil.padding(all: 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(SizeUtil.width(9))),
                color: Color(0xffffffff),
              ),
              child: ListView.builder(
                  padding: SizeUtil.padding(all: 0),
                  shrinkWrap: true,
                  itemCount: Global.CONNECTS.length,
                  itemBuilder: (context, index) {
                    return getContentItem(context, index);
                  }),
            ),
            Spacer(),
            Container(
                margin: SizeUtil.margin(bottom: 20),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      splashColor: Colors.transparent,
                      child: Container(
                        padding: SizeUtil.padding(top: 10, bottom: 10),
                        child: Text(
                          'Powered by BeeFinance',
                          style: TextStyle(fontSize: SizeUtil.sp(12), color: Colors.grey[400]),
                        ),
                      ),
                      onTap: () {
                        _developStep++;
                        var now = DateTime.now().millisecondsSinceEpoch;
                        if (_startTime == 0) {
                          _startTime = now;
                        } else {
                          if ((now - _startTime) > 500) {
                            _startTime = 0;
                            _developStep = 0;
                          } else {
                            _startTime = now;
                          }
                        }
                        print('$_developStep $_startTime');
                      },
                    )
                  ],
                ))
          ],
        ),
      ),
    );
  }

  getContentNormal(String label, String url) {
    url = url.urlAppendParams('language', Global.LANGUAGE);
    return InkWell(
      onTap: () {
        Get.to(PageWeb(), arguments: {'url': url, "title": label});
      },
      child: Container(
        height: SizeUtil.height(45),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: SizeUtil.width(20),
            ),
            Container(
              child: Text(
                label,
                style: TextStyle(color: Color(0xff060606), fontSize: SizeUtil.sp(14)),
              ),
            ),
            Spacer(),
            Container(
              margin: SizeUtil.margin(left: 10, right: 14),
              child: Icon(
                Icons.arrow_forward_ios,
                size: SizeUtil.width(14),
                color: Colors.grey[400],
              ),
            )
          ],
        ),
      ),
    );
  }

  getContentItem(BuildContext context, int index) {
    NameValue nameValue = Global.CONNECTS[index];
    return InkWell(
      borderRadius: BorderRadius.all(Radius.circular(SizeUtil.width(10))),
      onTap: () {
        print('$index');
        Clipboard.setData(ClipboardData(text: nameValue.value));
        showTipsBar("CommonCopyTip".tr);
      },
      child: MineAboutCellWidget(
        index: index,
        nameValue: nameValue,
        showLine: index < Global.CONNECTS.length - 1,
      ),
    );
  }
}

class MineAboutCellWidget extends StatelessWidget {
  int index;
  NameValue nameValue;
  bool showLine;

  MineAboutCellWidget({this.index, this.nameValue, this.showLine});

  @override
  Widget build(BuildContext context) {
    String name = nameValue.name;
    String content = nameValue.value;

    return Container(
      height: SizeUtil.height(45),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: SizeUtil.width(20),
                ),
                Container(
                  child: Text(
                    name,
                    style: TextStyle(color: Color(0xff060606), fontSize: SizeUtil.sp(14)),
                  ),
                ),
                SizedBox(
                  width: SizeUtil.width(20),
                ),
                Expanded(
                  child: Container(
                    child: Text(
                      content,
                      style: TextStyle(color: BeeColors.blue, fontSize: SizeUtil.sp(12)),
                      textAlign: TextAlign.end,
                    ),
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
            color: showLine ? BeeColors.FFF2F2F2 : Colors.transparent,
          ),
        ],
      ),
    );
  }
}
