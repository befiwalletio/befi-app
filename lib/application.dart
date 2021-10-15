import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cube/core/constant.dart';
import 'package:cube/core/core.dart';
import 'package:cube/net/requester.dart';
import 'package:cube/utils/utils_sp.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jpush_flutter/jpush_flutter.dart';
import 'package:package_info/package_info.dart';
import 'package:permission_handler/permission_handler.dart';

class Application {
  static install(BuildContext context) async {
    await SPUtils().checksp();
    var language = SPUtils().get(Constant.LANGUAGE);
    if (language == null) {
      language = Global.LANGUAGE;
      SPUtils().put(Constant.LANGUAGE, language);
    }
    var local = Locale(language);
    Get.updateLocale(local);
    Global.LANGUAGE = language;
    var cs = SPUtils().get(Constant.CS);
    if (cs == null) {
      cs = 'USD';
      SPUtils().put(Constant.CS, cs);
    }
    Global.CS = cs;

    Global.DEVICE_UDID = SPUtils().getString(Constant.DEVICE_UDID);
    if (strIsEmpty(Global.DEVICE_UDID)) {
      Global.DEVICE_UDID = generateUDID();
      SPUtils().put(Constant.DEVICE_UDID, Global.DEVICE_UDID);
    }
    await initData();
    Requester.init(RequestConfig(baseUrl: Constant.APP_URL, responseHandler: ResponseHandler()));
    await SPUtils().asyncStaticConfig();
    initJPush();
    return Future.value(true);
  }

  static initData() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      Global.VERSION = packageInfo.version;
      Global.CLIENT_C = packageInfo.buildNumber;
      DeviceInfoPlugin deviceInfo = new DeviceInfoPlugin();
      if (Platform.isIOS) {
        IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
        Global.MODEL = iosDeviceInfo.model;
        Global.PLATFORM_V = iosDeviceInfo.systemVersion;
        Global.CLIENT_V = Global.VERSION;
        Global.DEVICE_ID = iosDeviceInfo.identifierForVendor;
      } else if (Platform.isAndroid) {
        AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
        Global.MODEL = androidDeviceInfo.model;
        Global.PLATFORM_V = androidDeviceInfo.version.release;
        Global.CLIENT_V = Global.VERSION;
        Global.DEVICE_ID = androidDeviceInfo.id;
      }
    } catch (e) {}

    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.mobile) {
        Global.NETWORK = 'mobile';
      } else if (connectivityResult == ConnectivityResult.wifi) {
        Global.NETWORK = 'wifi';
      } else {
        Global.NETWORK = 'none';
      }
    } catch (e) {
      Global.NETWORK = 'none';
    }
  }

  static getPlatform() {
    if (Global.isAndroid) {
      return "android";
    }
    if (Global.isIOS) {
      return "iOS";
    }
    if (Global.isLinux) {
      return "Linux";
    }
    if (Global.isMacOS) {
      return "macOS";
    }
    if (Global.isWindows) {
      return "windows";
    }
    if (Global.isFuchsia) {
      return "fuchsia";
    }
    return "";
  }

  static requestPhonePermission() async {
    if (await Permission.phone.isDenied) {
      PermissionStatus status = await Permission.phone.request();
      return status == PermissionStatus.granted;
    }
    return true;
  }

  static initJPush() {
    JPush jpush = new JPush();
    jpush.addEventHandler(
      onReceiveNotification: (Map<String, dynamic> message) async {
        print("flutter onReceiveNotification: $message");
      },
      onOpenNotification: (Map<String, dynamic> message) async {
        print("flutter onOpenNotification: $message");
      },
      onReceiveMessage: (Map<String, dynamic> message) async {
        print("flutter onReceiveMessage: $message");
      },
    );
    jpush.applyPushAuthority(new NotificationSettingsIOS(sound: true, alert: true, badge: true));
    jpush.setup(
      appKey: Constant.JPKEY,
      channel: "beepay",
      production: false,
      debug: false,
    );
    jpush.getRegistrationID().then((rid) {
      Global.RID = rid;
    });
  }
}
