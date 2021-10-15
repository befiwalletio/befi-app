import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:cube/core/constant.dart';
import 'package:cube/core/core.dart';
import 'package:cube/pages/page_splash.dart';

import 'package:cube/utils/utils_language2.dart';
import 'package:cube/utils/utils_size.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

final FirebaseAnalytics analytics = FirebaseAnalytics();
final FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    if (Platform.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    }
    await Firebase.initializeApp();
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    if (window.physicalSize.isEmpty) {
      window.onMetricsChanged = () {
        if (!window.physicalSize.isEmpty) {
          window.onMetricsChanged = null;
          runCustom();
        }
      };
    } else {
      runCustom();
    }
  }, (error, stackTrace) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  });
}

void runCustom() {
  SizeUtil.init();
  Global.RESOLUTION = '${(SizeUtil.screenWidth() as double).toStringAsFixed(0)}x${(SizeUtil.screenHeight() as double).toStringAsFixed(0)}';
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: PageSplash(),
      builder: EasyLoading.init(),
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        if (strIsEmpty(Global.LANGUAGE)) {
          String local = '$deviceLocale'.toLowerCase();
          if (local.contains('ko') || local.contains('kr')) {
            Global.LANGUAGE = 'ko';
          } else {
            Global.LANGUAGE = 'en';
          }
          var local1 = Locale(Global.LANGUAGE);
          Get.updateLocale(local1);
        }
      },
      translations: Language(),
      locale: Locale('zh', 'CN'),
      theme: ThemeData(
          platform: TargetPlatform.iOS,
          brightness: Brightness.light,
          primaryColor: BeeColors.blue,
          primaryTextTheme: TextTheme(
            headline1: StyleUtil.textStyle(size: 33, color: Colors.black, weight: FontWeight.bold),
            headline2: StyleUtil.textStyle(size: 28, color: Colors.black, weight: FontWeight.bold),
            headline3: StyleUtil.textStyle(size: 18, color: Colors.black, weight: FontWeight.bold),
            headline4: StyleUtil.textStyle(size: 12, color: Colors.black),
            headline5: StyleUtil.textStyle(size: 18, color: Colors.black),
            headline6: StyleUtil.textStyle(size: 14, color: Colors.black),
            bodyText1: StyleUtil.textStyle(size: 14, color: Colors.black),
            bodyText2: StyleUtil.textStyle(size: 12, color: Colors.black),
            subtitle1: TextStyle(fontSize: SizeUtil.sp(14), color: Colors.grey, fontWeight: FontWeight.normal),
            subtitle2: TextStyle(fontSize: SizeUtil.sp(12), color: Colors.grey, fontWeight: FontWeight.normal),
          ),
          primaryIconTheme: IconThemeData(color: Colors.black),
          scaffoldBackgroundColor: Colors.white,
          canvasColor: Colors.grey[50],
          textSelectionTheme: TextSelectionThemeData(cursorColor: BeeColors.blue),
          appBarTheme: AppBarTheme(
              brightness: Brightness.light,
              backgroundColor: Colors.white,
              iconTheme: IconThemeData(color: Colors.black),
              titleTextStyle: TextStyle(fontSize: 30, color: Colors.black)),
          tabBarTheme: TabBarTheme(
              labelColor: Colors.black,
              labelStyle: TextStyle(fontWeight: FontWeight.bold),
              unselectedLabelColor: Colors.grey,
              unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal))),
      darkTheme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.white,
          scaffoldBackgroundColor: Colors.black,
          appBarTheme: AppBarTheme(
              brightness: Brightness.dark,
              backgroundColor: Colors.black,
              textTheme: TextTheme(
                headline1: TextStyle(color: Colors.white),
                headline2: TextStyle(color: Colors.white),
                headline3: TextStyle(color: Colors.white),
                headline4: TextStyle(color: Colors.white),
                headline5: TextStyle(color: Colors.white),
                headline6: TextStyle(color: Colors.white),
              ),
              iconTheme: IconThemeData(color: Colors.white),
              titleTextStyle: TextStyle(fontSize: 30, color: Colors.white)),
          tabBarTheme: TabBarTheme(
              labelColor: Colors.white,
              labelStyle: TextStyle(fontWeight: FontWeight.bold),
              unselectedLabelColor: Colors.grey,
              unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal))),
      themeMode: ThemeMode.light,
      navigatorObservers: [observer],
    );
  }
}
