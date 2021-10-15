import 'package:cube/core/base_widget.dart';
import 'package:cube/pages/page_mnemonic.dart';
import 'package:cube/utils/utils_size.dart';
import 'package:cube/views/appbar/appbar.dart';
import 'package:cube/views/dialog/dialog_copy_board.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

///backups
class PageBackups extends StatefulWidget {
  const PageBackups({Key key}) : super(key: key);

  @override
  _PageBackupsState createState() => _PageBackupsState();
}

class _PageBackupsState extends SizeState<PageBackups> {
  CopyBoardController controller = Get.put(CopyBoardController(), tag: "CopyBoard");

  @override
  Widget createView(BuildContext context) {
    return Scaffold(
      appBar: XAppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_outlined),
          onPressed: () {
            Get.back();
          },
        ),
        title: Text("WalletMneBackup".tr),
      ),
      body: Container(
        padding: SizeUtil.padding(left: 30, right: 30, bottom: 50),
        width: SizeUtil.screenWidth(),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: SizeUtil.width(200),
              height: SizeUtil.height(200),
              child: Image.asset('assets/images/logo_bee.png'),
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                "WalletBackupTip".tr,
                style: StyleUtil.textStyle(size: 40, weight: FontWeight.bold),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: SizeUtil.padding(top: 20, bottom: 20),
              child: Text(
                "WalletMneSafeTip2".tr,
                style: StyleUtil.textStyle(size: 30, color: Colors.grey),
              ),
            ),
            Divider(),
            Container(
              alignment: Alignment.centerLeft,
              padding: SizeUtil.padding(top: 20, bottom: 20),
              child: Text(
                "* ${"WalletMneSafeTip3".tr}",
                style: StyleUtil.textStyle(size: 30, color: Colors.black54),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: SizeUtil.padding(top: 20, bottom: 20),
              child: Text(
                "* ${"WalletMneSafeTip4".tr}",
                style: StyleUtil.textStyle(size: 30, color: Colors.black54),
              ),
            ),
            Expanded(flex: 1, child: Container()),
            MaterialButton(
                color: Colors.orange,
                textColor: Colors.white,
                padding: SizeUtil.padding(top: 20, bottom: 20),
                minWidth: SizeUtil.screenWidth() - SizeUtil.width(60),
                child: Text("CommonNext".tr),
                onPressed: () async {
                  await showDialog(
                      useSafeArea: false,
                      context: context,
                      builder: (context) {
                        return DialogCopyBoard();
                      });
                  Get.to(PageMnemonic());
                })
          ],
        ),
      ),
    );
  }
}
