import 'package:cube/core/base_widget.dart';
import 'package:cube/core/constant.dart';
import 'package:cube/utils/utils_size.dart';
import 'package:cube/utils/utils_sp.dart';
import 'package:cube/views/CustomBehavior.dart';
import 'package:cube/views/appbar/appbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PageSettingLanguage extends StatefulWidget {
  const PageSettingLanguage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PageSettingLanguageState();
  }
}

class _PageSettingLanguageState extends SizeState<PageSettingLanguage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget createView(BuildContext context) {
    return Scaffold(
      backgroundColor: BeeColors.FFF3F4F6,
      appBar: XAppBar(
        title: Text("Languages".tr),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              margin: SizeUtil.margin(left: 15, right: 15, top: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(SizeUtil.width(9))),
                color: Color(0xffffffff),
              ),
              child: ScrollConfiguration(
                behavior: CustomBehavior(),
                child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: Constant.ZLanguages.length,
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

  getContentItem(BuildContext context, int index) {
    Map<String, String> map = Constant.ZLanguages[index];
    return InkWell(
      onTap: () {
        print('$index');
        SPUtils().put(Constant.LANGUAGE, map["name"]);
        var local = Locale(map["name"]);
        Get.updateLocale(local);
        Get.back();
      },
      child: SettingLanguageCellWidget(
        index: index,
        map: map,
      ),
    );
  }
}

class SettingLanguageCellWidget extends StatelessWidget {
  int index;
  Map<String, String> map;

  SettingLanguageCellWidget({this.index, this.map});

  @override
  Widget build(BuildContext context) {
    String current;
    String languageCode = SPUtils().get(Constant.LANGUAGE);
    if (languageCode == null || languageCode.isEmpty) {
      current = 'en';
    } else {
      current = languageCode;
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
                      style: TextStyle(color: Color(0xff060606), fontSize: SizeUtil.sp(14)),
                    ),
                  ),
                ),
                Container(
                  child: Image(
                    image: AssetImage(
                      Comparable.compare(name, current) == 0
                          ? Constant.Assets_Image + "common_select_true.png"
                          : Constant.Assets_Image + "common_select_false.png",
                    ),
                    width: SizeUtil.width(18),
                    height: SizeUtil.width(18),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
              ],
            ),
          ),
          Container(
            margin: SizeUtil.margin(left: 20, right: 20),
            height: 1,
            color: BeeColors.FFF2F2F2,
          ),
        ],
      ),
    );
  }
}
