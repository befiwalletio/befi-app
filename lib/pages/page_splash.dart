import 'package:cube/chain/chaincore.dart';
import 'package:cube/application.dart';
import 'package:cube/core/base_widget.dart';
import 'package:cube/core/constant.dart';
import 'package:cube/models/model_base.dart';
import 'package:cube/pages/page_landing.dart';
import 'package:cube/pages/page_start.dart';
import 'package:cube/utils/utils_db.dart';
import 'package:cube/utils/utils_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class PageSplash extends StatefulWidget {
  const PageSplash({Key key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends SizeState<PageSplash> {
  AnimationController _beeController;
  bool _animFinish = false;
  bool _coreFinish = false;

  Widget _createLottie() {
    return Container(
      child: Lottie.asset(
        'assets/lottie_bee.json',
        controller: _beeController,
        width: SizeUtil.screenWidth() / 3,
        onLoaded: (composition) {
          _beeController
            ..duration = composition.duration
            ..forward();
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _beeController = AnimationController(vsync: this)
      ..addListener(() {})
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _animFinish = true;
            _next();
          });
        }
      });
  }

  @override
  Widget createView(BuildContext context) {
    return Scaffold(
      body: Container(
        color: BeeColors.blue[600],
        child: Stack(
          children: [
            Positioned(
                top: SizeUtil.height(150),
                left: SizeUtil.width(80),
                right: SizeUtil.width(80),
                child: _createLottie()),
            Positioned(
                left: 0,
                right: 0,
                bottom: SizeUtil.height(20),
                child: Container(
                  alignment: Alignment.center,
                  child: Text('Powered by BeeFinance',style: TextStyle(fontSize: SizeUtil.sp(12),color: Colors.grey[400]),
                ),),
            )
          ],
        ),
      ),
    );
  }

  _next() async {
    if (!_animFinish) {
      return;
    }
    if (!_coreFinish) {
      await Application.install(context);
      ChainCore.install(context,
          ChainConfig(
              'assets/files/core.html',
              'assets/files/license',
              Constant.APPID,
              Constant.APPKEY) ,
          callback: () {
        setState(() {
          _coreFinish = true;
          Future.delayed(Duration(milliseconds: 500), () {
            _next();
          });
        });
      });
      return;
    }
    List<Identity> items = await DBHelper.create().queryIdentities();
    if (items != null && items.length > 0) {
      Get.off(PageLanding(), arguments: {"items": items}, transition: Transition.fadeIn);
    } else {
      Get.off(PageStart(), transition: Transition.fadeIn);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
