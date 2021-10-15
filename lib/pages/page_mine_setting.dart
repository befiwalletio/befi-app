import 'package:cube/core/base_widget.dart';
import 'package:cube/core/constant.dart';
import 'package:cube/pages/page_setting_currency.dart';
import 'package:cube/pages/page_setting_language.dart';
import 'package:cube/utils/utils_event.dart';
import 'package:cube/utils/utils_size.dart';
import 'package:cube/utils/utils_sp.dart';
import 'package:cube/views/CustomBehavior.dart';
import 'package:cube/views/appbar/appbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PageUserSetting extends StatefulWidget {
  const PageUserSetting({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PageUserSettingState();
  }
}

class _PageUserSettingState extends SizeState<PageUserSetting> {
  String language = "";
  String currency = "";

  @override
  void initState() {
    super.initState();
    eventBus.on<ECurrency>().listen((event) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void initLanguage() {
    String langcode = SPUtils().get(Constant.LANGUAGE);
    if (langcode == null || langcode.isEmpty) {
      language = "English";
    } else {
      for (int i = 0; i < Constant.ZLanguages.length; i++) {
        Map<String, String> map = Constant.ZLanguages[i];
        if (map["name"].compareTo(langcode) == 0) {
          language = map["content"];
        }
      }
    }
  }

  void initCurrency() {
    currency = SPUtils().get(Constant.CS);
    if (currency == null || currency.isEmpty) {
      currency = "USD";
    } else {
      for (int i = 0; i < Constant.ZCurrencys.length; i++) {
        Map<String, String> map = Constant.ZCurrencys[i];
        if (map["name"].compareTo(currency) == 0) {
          currency = map["name"];
        }
      }
    }
  }

  @override
  Widget createView(BuildContext context) {
    initLanguage();
    initCurrency();

    return Scaffold(
      backgroundColor: BeeColors.FFF3F4F6,
      appBar: XAppBar(
        elevation: 0,
        title: Text("Settings".tr),
      ),
      body: Container(
        child: ScrollConfiguration(
          behavior: CustomBehavior(),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: SizeUtil.height(12),
                ),

                Container(
                  margin: SizeUtil.margin(left: 15, right: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(SizeUtil.width(10))),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          Get.to(PageSettingLanguage());
                        },
                        child: new MineSettingItemWidget(
                          index: 2,
                          title: "Languages".tr,
                          subtitle: language,
                        ),
                      ),
                      Container(
                        margin: SizeUtil.margin(left: 20, right: 20),
                        height: SizeUtil.height(1),
                        color: BeeColors.FFF2F2F2,
                      ),
                      InkWell(
                        onTap: () {
                          Get.to(PageSettingCurrency());
                        },
                        child: MineSettingItemWidget(
                          index: 3,
                          title: "CurrencyUnit".tr,
                          subtitle: currency,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class MineSettingItemWidget extends StatelessWidget {
  int index;
  bool check = false;
  String image = "";
  String title = "";
  String subtitle = "";

  MineSettingItemWidget({this.index, this.image, this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: SizeUtil.padding(top: 13, bottom: 13, right: 10),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: SizeUtil.width(24),
          ),
          Expanded(
            flex: 1,
            child: Container(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: SizeUtil.sp(14),
                  color: BeeColors.FF091C40,
                ),
                textAlign: TextAlign.start,
              ),
            ),
          ),
          SizedBox(
            width: SizeUtil.width(20),
          ),
          Container(
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: SizeUtil.sp(14),
                color: BeeColors.FF717782,
              ),
              textAlign: TextAlign.end,
            ),
          ),
          SizedBox(
            width: SizeUtil.width(5),
          ),
          index == 0
              ? Container(
                  child: Switch(
                    value: this.check,
                    activeColor: Colors.green,
                    onChanged: (bool val) {
                    },
                  ),
                )
              : index == 1
                  ? Container(
                      child: Switch(
                        value: this.check,
                        activeColor: Colors.green,
                        onChanged: (bool val) {
                          // checkAction();
                        },
                      ),
                    )
                  : Container(
                      child: Icon(
                        Icons.chevron_right,
                        color: BeeColors.FF717782,
                      ),
                    ),
        ],
      ),
    );
  }
}
