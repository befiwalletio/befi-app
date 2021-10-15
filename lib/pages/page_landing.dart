import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cube/core/base_widget.dart';
import 'package:cube/core/constant.dart';
import 'package:cube/core/core.dart';
import 'package:cube/pages/page_dapps.dart';
import 'package:cube/pages/page_home.dart';
import 'package:cube/pages/page_mine.dart';
import 'package:cube/pages/page_nft.dart';
import 'package:cube/utils/utils_console.dart';
import 'package:cube/utils/utils_event.dart';
import 'package:cube/utils/utils_size.dart';
import 'package:cube/views/dialog/dialog_update.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class PageLanding extends StatefulWidget {
  const PageLanding({Key key}) : super(key: key);

  @override
  _PageLandingState createState() => _PageLandingState();
}

class _PageLandingState extends State<PageLanding> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  bool _checkUpdate = true;

  AnimationController _loadingController;
  int _currentIndex = 0;
  List<Widget> _children = [];
  PageController _pageController = PageController(initialPage: 0, keepPage: true);
  int _popStep = 0;

  StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(vsync: this)
      ..addListener(() {})
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _loadingController.repeat();
        }
      });
    EasyLoading.instance
      ..loadingStyle = EasyLoadingStyle.custom
      ..backgroundColor = Colors.black26
      ..indicatorColor = Colors.yellow
      ..textColor = Colors.yellow
      ..maskColor = Colors.blue.withOpacity(0.5)
      ..userInteractions = true
      ..dismissOnTap = true
      ..indicatorWidget = Container(
        width: SizeUtil.width(80),
        height: SizeUtil.width(80),
        child: _createLottie(),
      )
      ..customAnimation = CustomAnimation();
    _subscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult connectivityResult) {
      if (connectivityResult == ConnectivityResult.mobile) {
        Global.NETWORK = 'mobile';
      } else if (connectivityResult == ConnectivityResult.wifi) {
        Global.NETWORK = 'wifi';
      } else {
        Global.NETWORK = 'none';
      }
    });
    _popStep = 0;
    _children = [PageHome(), PageNft(), PageDapps(), PageMine()];
    if (_checkUpdate) {
      Future.delayed(Duration(seconds: 1), () async {
        await checkUpdate(context, (data) {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (_popStep == 0) {
          showTipsBar("CommonLogoutTip".tr);
          _popStep++;
          Future.delayed(Duration(seconds: 2), () {
            _popStep = 0;
          });
          return;
        }
        SystemNavigator.pop();
      },
      child: Scaffold(
        body: createTabBarView(),
        bottomNavigationBar: createNavBarView(),
      ),
    );
  }

  Widget createTabBarView() {
    return PageView.builder(
      controller: _pageController,
      itemBuilder: (context, index) {
        return _children[index];
      },
      itemCount: _children.length,
      onPageChanged: (index) {
        if (_currentIndex != index) {
          setState(() {
            console.i("PageView 被滑动 $index");
            _currentIndex = index;
          });
        }
      },
    );
  }

  Widget createNavBarView() {
    return BottomNavigationBar(
      selectedFontSize: SizeUtil.sp(10),
      unselectedFontSize: SizeUtil.sp(8),
      currentIndex: _currentIndex,
      selectedItemColor: Get.isDarkMode ? Colors.white : BeeColors.blue,
      unselectedItemColor: Get.isDarkMode ? Colors.grey : Colors.grey,
      selectedIconTheme: IconThemeData(size: SizeUtil.width(30)),
      unselectedIconTheme: IconThemeData(size: SizeUtil.width(25)),
      type: BottomNavigationBarType.fixed,
      onTap: (index) => {
        if (_currentIndex != index)
          {
            eventBus.fire(CloseDrawer()),
            setState(() {
              console.i("Tab 被点击 $index");
              _currentIndex = index;
              _pageController.animateToPage(_currentIndex, duration: Duration(milliseconds: 200), curve: Curves.ease);
            })
          }
      },
      items: [
        BottomNavigationBarItem(label: "Wallet".tr, icon: Icon(Icons.account_balance_wallet_outlined)),
        BottomNavigationBarItem(label: "Nft".tr, icon: Icon(Icons.layers_outlined)),
        BottomNavigationBarItem(label: "Discovery".tr, icon: Icon(Icons.explore_outlined)),
        BottomNavigationBarItem(label: "Me".tr, icon: Icon(Icons.perm_identity)),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;

  Widget _createLottie() {
    return Container(
      child: Lottie.asset(
        'assets/lottie_loading.json',
        controller: _loadingController,
        width: SizeUtil.screenWidth() / 3,
        onLoaded: (composition) {
          _loadingController
            ..duration = Duration(milliseconds: 1500)
            ..forward();
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.cancel();
  }
}
