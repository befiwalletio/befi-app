import 'package:cube/core/base_widget.dart';
import 'package:cube/core/constant.dart';
import 'package:cube/core/core.dart';
import 'package:cube/models/model_base.dart';
import 'package:cube/pages/page_mine_about.dart';
import 'package:cube/pages/page_mine_setting.dart';
import 'package:cube/pages/page_web.dart';
import 'package:cube/utils/utils_console.dart';
import 'package:cube/utils/utils_db.dart';
import 'package:cube/utils/utils_size.dart';
import 'package:cube/views/CustomBehavior.dart';
import 'package:cube/views/appbar/appbar.dart';
import 'package:cube/views/appbar/beebar.dart';
import 'package:cube/views/dialog/dialog_copy_action.dart';
import 'package:cube/views/dialog/dialog_pass_board.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class PageMine extends StatefulWidget {
  const PageMine({Key key}) : super(key: key);

  @override
  _PageMineState createState() => _PageMineState();
}

class _PageMineState extends SizeState<PageMine> {
  EasyRefreshController userController = EasyRefreshController();

  Future<String> goNatification() async {
    return "";
  }

  static Future<Null> launchFeedback() async {
    String url = "mailto:" + (!strIsEmpty(Global.PAGE_FEEDBACK) ? Global.PAGE_FEEDBACK : 'business@beefinance.pro');
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      showTipsBar("Mine_Email_Uninstall".tr);
    }
  }

  @override
  Widget createView(BuildContext context) {
    return Scaffold(
      backgroundColor: BeeColors.FFF3F4F6,
      appBar: XAppBar(
        titleSpacing: 0.0,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [],
        title: BeeBar(
          fixPadding: false,
          left: [
            Container(
              width: 15,
            ),
          ],
          title: Text(
            "Me".tr,
            style: TextStyle(color: Colors.black, fontSize: SizeUtil.sp(14), fontWeight: FontWeight.bold),
          ),
        ),
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
                  // height: SizeUtil.height(60),//183
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(SizeUtil.width(10))),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          Get.to(PageUserSetting());
                        },
                        child: MineItemWidget(
                          image: "mine_settings.png",
                          title: "Settings".tr,
                        ),
                      ),
                    ],
                  ),
                ),

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
                          _exportPrivateKeys();
                        },
                        child: MineItemWidget(
                          image: "mine_wallet.png",
                          title: "WalletExportPri".tr,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: SizeUtil.height(12),
                ),
                _buildInfoGroup()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoGroup() {
    List<Widget> items = [];

    if (!strIsEmpty(Global.PAGE_FEEDBACK)) {
      items.addAll([
        InkWell(
          onTap: () {
            launchFeedback();
          },
          child: MineItemWidget(
            image: "mine_help.png",
            title: "Mine_Help",
          ),
        ),
        Container(
          margin: SizeUtil.margin(left: 20, right: 20),
          height: SizeUtil.height(1),
          color: BeeColors.FFF2F2F2,
        ),
      ]);
    }
    if (!strIsEmpty(Global.PAGE_INSTRUCTIONS)) {
      items.addAll([
        InkWell(
          onTap: () {
            Get.to(PageWeb(), arguments: {"url": Global.PAGE_INSTRUCTIONS});
          },
          child: MineItemWidget(
            image: "mine_terms.png",
            title: "Mine_Terms",
          ),
        ),
        Container(
          margin: SizeUtil.margin(left: 20, right: 20),
          height: SizeUtil.height(1),
          color: BeeColors.FFF2F2F2,
        ),
      ]);
    }

    if (!strIsEmpty(Global.PAGE_AGREEMENT)) {
      items.addAll([
        InkWell(
          onTap: () {
            Get.to(PageWeb(), arguments: {"url": Global.PAGE_AGREEMENT});
          },
          child: MineItemWidget(
            image: "mine_protocol.png",
            title: "Mine_Protocol",
          ),
        ),
        Container(
          margin: SizeUtil.margin(left: 20, right: 20),
          height: SizeUtil.height(1),
          color: BeeColors.FFF2F2F2,
        ),
      ]);
    }

    items.add(InkWell(
      onTap: () {
        Get.to(PageMineAbout());
      },
      child: MineItemWidget(
        image: "mine_about.png",
        title: "Mine_About",
      ),
    ));

    return Container(
      margin: SizeUtil.margin(left: 15, right: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(SizeUtil.width(10))),
        color: Colors.white,
      ),
      child: Column(
        children: items,
      ),
    );
  }

  _exportPrivateKeys() {
    showDialog(
        useSafeArea: false,
        context: context,
        builder: (context) {
          return DialogPassBoard(callback: (text) async {
            String pass = getTokenId(text);
            var auth = await DBHelper().queryAuth();
            if (pass != auth.password) {
              showWarnBar("CommonPwdError".tr);
              return;
            }
            String result = '';
            List<Identity> identities = await DBHelper().queryIdentities();
            for (int i = 0; i < identities.length; i++) {
              Identity element = identities[i];
              String name = element.name;
              String pk = element.privateKey;
              pk = await decrypt(pk, pass);
              result = '$result${name}:${pk}\n\n';
            }
            console.i(result);
            Get.back();
            showDialog(
                useSafeArea: false,
                context: context,
                builder: (context) {
                  return DialogCopyAction(
                    title: "WalletExportPri".tr,
                    text: result,
                    callback: (text) {
                      Get.back();
                      Clipboard.setData(ClipboardData(text: text));
                      showTipsBar("CommonCopyTip".tr);
                    },
                  );
                });
          });
        });
  }

  @override
  void dispose() {
    super.dispose();
    userController.dispose();
  }
}

class MineItemWidget extends StatelessWidget {
  int index;

  String image = "";
  String title = "";

  MineItemWidget({this.index, this.image, this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: SizeUtil.padding(top: 13, bottom: 13),
      child: Row(
        children: [
          SizedBox(
            width: SizeUtil.width(24),
          ),
          Image.asset(
            Constant.Assets_Image + image,
            width: SizeUtil.width(22),
            height: SizeUtil.width(22),
          ),
          SizedBox(
            width: SizeUtil.width(14),
          ),
          Expanded(
            flex: 1,
            child: Container(
              child: Text(
                title.tr,
                style: TextStyle(
                  fontSize: SizeUtil.sp(14),
                  color: BeeColors.FF091C40,
                ),
              ),
            ),
          ),
          SizedBox(
            width: SizeUtil.width(20),
          ),
          Container(
            child: Icon(
              Icons.chevron_right,
              color: BeeColors.FF717782,
            ),
          ),
          SizedBox(
            width: SizeUtil.width(10),
          ),
        ],
      ),
    );
  }
}
