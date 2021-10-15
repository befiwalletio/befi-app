import 'dart:io';

import 'package:cube/chain/chain_exp.dart';
import 'package:cube/core/core.dart';
import 'package:cube/models/model_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

///Global Constant
class Constant {
  static const String Assets_Image = 'assets/images/';
  static const String Dapp_Search_His = 'Dapp_Search_His';

  static final String APP_URL = '';

  static final String APPID = "";
  static final String APPKEY = "";
  static final String JPKEY = "";
  static final String SEED_ABC = "";
  static final String SEED_MINI = "";

  static final String DEVICE_UDID = "DEVICE_UDID";
  static final String ISFIRST = "ISFIRST";
  static final String CS = "CS";
  static final String LANGUAGE = "LANGUAGE";
  static final String CUSTOM_WID = "CUSTOM_WID";

  static final String CONFIG_STATIC = "CONFIG_STATIC";

  static final String ACTION_REFRESH = "REFRESH";
  static final String ACTION_REQUEST = "REQUEST";
  static final String ACTION_REMOVE = "REMOVE";
  static final String ACTION_APPEND = "APPEND";
  static final String ACTION_CALL = "CALL";

  static final String NFT_INDEX = "NFT_INDEX";

  static final String CHAIN_MATIC = "MATIC";
  static final String CHAIN_BNB = "BNB";
  static final String CHAIN_TRUE = "TRUE";
  static final String CHAIN_TRON = "TRX";

  static const Map<String, String> CS_UNITS = {
    "USD": "\$",
    "KRW": "₩",
  };

  static const List<Map<String, String>> ZLanguages = [
    {
      'name': 'en',
      'content': 'English',
    },
    {
      'name': 'ko',
      'content': '한국어',
    },
  ];

  static const List<Map<String, String>> ZCurrencys = [
    {
      'name': 'USD',
      'content': 'USD',
    },
    {
      'name': 'KRW',
      'content': 'KRW',
    },
  ];

  static const List<Map<String, String>> ZAboutUs = [
    {
      'name': '微信',
      'content': '微信content',
    },
    {
      'name': 'QQ',
      'content': 'QQcontent',
    },
    {
      'name': '微博',
      'content': '微博content',
    },
  ];
}

///Global
class Global {
  static String DEVICE_UDID = "";
  static String VERSION = '';
  static String IMEI = '';
  static String MAC = '';
  static String MODEL = '';
  static String NETWORK = '';
  static String PLATFORM_V = '';
  static String CLIENT_V = '';
  static String CLIENT_C = '';
  static String SOURCE = '';
  static String RESOLUTION = '';
  static String DEVICE_ID = '';
  static String SITE = '';
  static String LANGUAGE = '';
  static String CS = '';

  static bool isDebug = !bool.fromEnvironment("dart.vm.product");
  static bool isAndroid = Platform.isAndroid;
  static bool isIOS = Platform.isIOS;
  static bool isLinux = Platform.isLinux;
  static bool isMacOS = Platform.isMacOS;
  static bool isWindows = Platform.isWindows;
  static bool isFuchsia = Platform.isFuchsia;

  static String PAGE_AGREEMENT = '';
  static String PAGE_VERSION = '';
  static List<NameValue> CONNECTS = [];
  static String PAGE_FEEDBACK = "";
  static String PAGE_INSTRUCTIONS = "";
  static List<Coin> SUPORT_CHAINS = [];
  static List<Coin> SUPORT_NFTS = [];
  static List<Coin> SUPORT_DAPPS = [];

  static RPC E_RPC = RPC();
  static String RID = '';

  static List<Coin> CURRENT_CONIS = [];
}

class BeeColors {
  BeeColors._();

  static const MaterialColor blue = MaterialColor(
    0xFF1D80D3,
    <int, Color>{
      50: Color(0xFFCCE4F6),
      100: Color(0xFF95CCF6),
      200: Color(0xFF6AC2F5),
      300: Color(0xFF2DB7E8),
      400: Color(0xFF1296db),
      500: Color(0xFF1D80D3),
      600: Color(0xFF1F5AA3),
      700: Color(0xFF0B366A),
      800: Color(0xFF00008B),
      900: Color(0xFF08172F),
    },
  );
  static const MaterialColor green = MaterialColor(
    0xFF5CADAD,
    <int, Color>{
      500: Color(0xFF5CADAD),
    },
  );
  static const MaterialColor orange = MaterialColor(
    0xFFF2A412,
    <int, Color>{
      500: Color(0xFFF2A412),
    },
  );
  static const MaterialColor dark = MaterialColor(
    0xFF313346,
    <int, Color>{
      500: Color(0xFF313346),
    },
  );
  static const MaterialColor red = MaterialColor(
    0xFFD36454,
    <int, Color>{
      500: Color(0xFFD36454),
    },
  );
  static const MaterialColor pink = MaterialColor(
    0xFFCF9E9E,
    <int, Color>{
      500: Color(0xFFCF9E9E),
    },
  );

  static const MaterialColor FFF3F4F6 = MaterialColor(
    0xFFF3F4F6,
    <int, Color>{
      500: Color(0xFFF3F4F6),
    },
  );

  static const MaterialColor FF091C40 = MaterialColor(
    0xFF091C40,
    <int, Color>{
      500: Color(0xFF091C40),
    },
  );

  static const MaterialColor FFF2F2F2 = MaterialColor(
    0xFFF2F2F2,
    <int, Color>{
      500: Color(0xFFF2F2F2),
    },
  );

  static const MaterialColor FF717782 = MaterialColor(
    0xFF717782,
    <int, Color>{
      500: Color(0xFF717782),
    },
  );

  static const MaterialColor FFF5F5F5 = MaterialColor(
    0xFFF5F5F5,
    <int, Color>{
      500: Color(0xFFF5F5F5),
    },
  );

  static const MaterialColor FF00A0E8 = MaterialColor(
    0xFF00A0E8,
    <int, Color>{
      500: Color(0xFF00A0E8),
    },
  );

  static const MaterialColor FFA2A6B0 = MaterialColor(
    0xFFA2A6B0,
    <int, Color>{
      500: Color(0xFFA2A6B0),
    },
  );

  static const MaterialColor FF5A667F = MaterialColor(
    0xFF5A667F,
    <int, Color>{
      500: Color(0xFF5A667F),
    },
  );

  static const MaterialColor FFD8DAE0 = MaterialColor(
    0xFFD8DAE0,
    <int, Color>{
      500: Color(0xFFD8DAE0),
    },
  );

  static const MaterialColor FFD3F1FF = MaterialColor(
    0xFFD3F1FF,
    <int, Color>{
      500: Color(0xFFD3F1FF),
    },
  );

  static const MaterialColor FF2AC6BE = MaterialColor(
    0xFF2AC6BE,
    <int, Color>{
      500: Color(0xFF2AC6BE),
    },
  );

  static const MaterialColor FF282828 = MaterialColor(
    0xFF282828,
    <int, Color>{
      500: Color(0xFF282828),
    },
  );

  static const MaterialColor FFE3E3E3 = MaterialColor(
    0xFFE3E3E3,
    <int, Color>{
      500: Color(0xFFE3E3E3),
    },
  );
}
