import 'package:cube/core/base_widget.dart';
import 'package:cube/core/constant.dart';
import 'package:cube/pages/page_create.dart';
import 'package:cube/pages/page_import.dart';
import 'package:cube/pages/page_import_keystore.dart';
import 'package:cube/utils/utils_size.dart';
import 'package:cube/utils/utils_sp.dart';
import 'package:cube/views/dialog/dialog_agreement_board.dart';
import 'package:cube/views/dialog/dialog_widget_board.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swipper/flutter_card_swiper.dart';
import 'package:get/get.dart';

class PageStart extends StatefulWidget {
  const PageStart({Key key}) : super(key: key);

  @override
  _StartState createState() => _StartState();
}

class _StartState extends SizeState<PageStart>{
  List<String> images = [
    "assets/images/swipe_04.png",
  ];


  Widget _createSwiper() {
    return Container(
      height: SizeUtil.height(280),
      width: SizeUtil.screenWidth(),
      child: images.length>1?Swiper(
        containerWidth: SizeUtil.screenWidth(),
        itemBuilder: (BuildContext context, int index) {
          return new Image.asset(
            images[index],
            fit: BoxFit.cover,
            width: SizeUtil.screenWidth(),
          );
        },
        autoplay: true,
        autoplayDelay: 5000,
        itemCount: images.length,
        pagination: new SwiperPagination(builder: DotSwiperPaginationBuilder(
          color: Colors.grey[100],
          activeColor: BeeColors.blue
        )),
      ):Image.asset(
        images[0],
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _createInput() {
    return Positioned(
        bottom: SizeUtil.height(150),
        left: 0,
        right: 0,
        child: Container(
          child: Column(
            children: [
              _createCard(onTap: () {
                bool isFirst = SPUtils().getBool(Constant.ISFIRST);
                if(isFirst){
                  Get.to(PageCreate());
                  return;
                }
                showDialog(
                    useSafeArea:false,
                    context: context, builder: (builder){
                  return DialogAgreementBoard(callback: (value){
                    Get.back();
                    if(value){
                      SPUtils().put(Constant.ISFIRST, true);
                      Get.to(PageCreate());
                    }
                  },);
                });

              }, title: "WalletCreate".tr, desc: "WalletCreateNew".tr),
              SizedBox(
                height: 10,
              ),
              _createCard(onTap: () {
                bool isFirst = SPUtils().getBool(Constant.ISFIRST);
                if(isFirst){
                  selectImportAction();
                  return;
                }
                showDialog(
                    useSafeArea:false,
                    context: context, builder: (builder){
                  return DialogAgreementBoard(callback: (value){
                    Get.back();
                    if(value){
                      SPUtils().put(Constant.ISFIRST, true);
                      selectImportAction();
                    }
                  },);
                });

              }, title: "WalletImport".tr, desc: "WalletImportMnePri".tr),
            ],
          ),
        ));
  }

  void selectImportAction() {
    showDialog(
        useSafeArea:false,
        context: context,
        builder: (context) {
          return DialogWidgetBoard(
            child: Container(
              child: Column(
                children: [
                  InkWell(
                      onTap: () async {
                        Get.back();
                        Get.to(PageImport(),arguments: {});
                      },
                      child: Container(
                        height: SizeUtil.height(40),
                        child: Center(
                          child: Text("WalletMneOrPri".tr,
                              style: Theme.of(context).primaryTextTheme.bodyText1),
                        ),
                      ),
                  ),
                  Divider(height: 1,color: Colors.grey[100],),
                  InkWell(
                      onTap: () async {
                        Get.back();
                        Get.to(PageImportKeyStore(),arguments: {});
                      },
                    child: Container(
                      height: SizeUtil.height(40),
                      child: Center(
                        child: Text("Import_Keystore".tr,
                            style: Theme.of(context).primaryTextTheme.bodyText1),
                      ),
                    ),
                  ),
                  Divider(height: 1,color: Colors.grey[100],),
                  InkWell(
                      onTap: () async {
                        Get.back();
                      },
                    child: Container(
                      height: SizeUtil.height(40),
                      child: Center(
                        child: Text("Common_Cancel".tr,
                            style: Theme.of(context).primaryTextTheme.bodyText1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget _createCard({GestureTapCallback onTap, String title, String desc}) {
    return Container(
      margin: SizeUtil.margin(left: 15, right: 15),
      padding: SizeUtil.padding(all: 2),
      decoration: BoxDecoration(
        border: new Border.all(
          color: Colors.grey[200],
          width: 1,
        ),
        borderRadius: SizeUtil.radius(all: 10),
      ),
      child: InkWell(
        onTap: onTap,
          borderRadius:BorderRadius.all(Radius.circular(SizeUtil.width(10))),
        child: Container(
          padding: SizeUtil.padding(all: 15),
          child: Row(
            children: [
              Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: SizeUtil.padding(bottom: 10),
                        child: Text(
                          title,
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headline3
                              .merge(TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      Padding(
                        padding: SizeUtil.padding(),
                        child: Text(
                          desc,
                          style: Theme.of(context).primaryTextTheme.subtitle2,
                        ),
                      )
                    ],
                  )),
              Icon(Icons.arrow_forward_ios,size: SizeUtil.width(12),)
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget createView(BuildContext context) {
    return Scaffold(
      body: Container(
        height: SizeUtil.screenHeight(),
        child: Stack(
          children: [
            Positioned(
              top: -2,left: -2,right: -2,
                child: _createSwiper()), _createInput()],
        ),
      ),
    );
  }
}
