import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

String randomString({int length = 10}) {
  String alphabet = 'qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM';
  String left = '';
  for (var i = 0; i < length; i++) {
    left = left + alphabet[Random().nextInt(alphabet.length)];
  }
  return left;
}

class ChainConfig {
  String license;
  String coreFile;
  String appid;
  String appkey;

  ChainConfig(this.coreFile, this.license, this.appid, this.appkey);

  Map<String, dynamic> toJson() {
    return {"license": license, "appid": appid, "appkey": appkey};
  }
}

class ChainCore {
  static const MethodChannel _channel = MethodChannel('chaincore');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static ChainCore _instance = ChainCore.create();

  factory ChainCore() => _instance;
  bool _isCreated = false;
  bool _isAndroid = false;
  String coreFileName = "assets/files/core.html";
  WebViewPlusController iosViewController;
  OverlayEntry overlayEntry;
  VoidCallback _callback;
  ChainConfig _config;
  Map<String, JSCallback> _jscallback = {};

  ChainCore.create() {
    _isAndroid = Platform.isAndroid;
  }

  Future<String> loadLicense() async {
    var license = await rootBundle.loadString(this._config.license);
    return Uri.encodeComponent(license);
  }

  ///Load JS
  void installJS(BuildContext context, ChainConfig config) async {
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    _config = config;
    var license = await loadLicense();
    _config.license = license;
    if (_isCreated) {
      return;
    }
    _isCreated = true;

    JavascriptChannel jsBridge(BuildContext context) => JavascriptChannel(
        name: '__JSHOST',
        onMessageReceived: (JavascriptMessage message) async {
          Map<String, dynamic> result = jsonDecode(message.message);
          String id = result['id'];
          String method = result['method'];
          Map<String, dynamic> data = result['data'];
          debugPrint(id);
          debugPrint(method);
          debugPrint(data.toString());
          if (method == 'ScriptBack' && _jscallback[id] != null) {
            _jscallback[id](data);
          }
        });

    String file = _isAndroid ? 'file:///android_asset/flutter_assets/$coreFileName' : coreFileName;
    Widget webview = WebViewPlus(
      initialUrl: file,
      javascriptMode: JavascriptMode.unrestricted,
      javascriptChannels: <JavascriptChannel>[jsBridge(context)].toSet(),
      onWebViewCreated: (WebViewPlusController web) {
        iosViewController = web;
      },
      onWebResourceError: (url) {
        print("Load JS Core Success $url");
      },
      onPageFinished: (url) {
        print("Load JS Core Finish $url");
        callJS('initCore', _config.toJson(), true);
      },
    );

    if (overlayEntry != null) {
      try {
        overlayEntry.remove();
      } catch (e) {
        print(e);
      }
    }
    overlayEntry = new OverlayEntry(builder: (context) {
      return new Positioned(
          top: 0,
          left: 0,
          child: Container(
            color: Colors.red,
            width: 0.1,
            height: 0.1,
            child: webview,
          ));
    });
    Overlay.of(context).insert(overlayEntry);

    if (_callback != null) {
      _callback();
    }
  }

  //Call JS
  Future<String> callJS(String method, Map params, bool keep) async {
    String jsid = randomString();
    if (params == null) {
      params = {};
    }
    Completer<String> completer = Completer();
    params['jsid'] = jsid;
    _jscallback[jsid] = (data) {
      _jscallback.remove(jsid);
      if (data != null) {
        if (data["code"] == 0) {
          if (data["data"] is Map) {
            completer.complete(json.encode(data["data"]));
          } else {
            completer.complete(data["data"].toString());
          }
        } else {
          completer.completeError(data["message"]);
        }
      }
    };
    if (keep) {
      String arg = json.encode(params);
      iosViewController.webViewController.evaluateJavascript("""window.$method('$arg');""");
    } else {
      params['method'] = method;
      String arg = json.encode(params);
      iosViewController.webViewController.evaluateJavascript("""window.CallChain('$arg');""");
    }
    return completer.future;
  }

  static install(BuildContext context, ChainConfig config, {VoidCallback callback}) {
    _instance._callback = callback;
    _instance.installJS(context, config);
  }

  static Future<String> call(String method, Map params, {keep: false}) async {
    return await _instance.callJS(method, params, keep);
  }
}

class Chain {
  String symbol;
  String name;
  String chain;
  String icon;

  Chain({
    this.icon = "",
    this.name = "",
    this.symbol = '',
    this.chain = '',
  });

  String getName() {
    if (this.name != null && this.name.isNotEmpty) return this.name;
    return this.symbol;
  }

  String getSymbol() {
    if (this.symbol != null && this.symbol.isNotEmpty) return this.symbol;
    return this.chain;
  }

  Future<String> getAccount() async {
    final params = {"contract": this.chain};
    String result = await ChainCore.call("getAccount", params);
    return result;
  }

  Future<String> getMnemonic() async {
    final params = {"contract": this.chain};
    String result = await ChainCore.call("getMnemonic", params);
    return result;
  }

  Future<String> getKeystore({String privateKey: '', String password: ''}) async {
    final params = {"contract": this.chain, "password": password, "privateKey": privateKey};
    String result = await ChainCore.call("getKeystore", params);
    return result;
  }

  Future<String> getPrivateKey({String mnemonic = '', String keystore = '', String password = ''}) async {
    final params = {"contract": this.chain, "mnemonic": mnemonic, "keystore": keystore, 'password': password};
    String result = await ChainCore.call("getPrivateKey", params);
    return result;
  }

  Future<String> getPublicKey(String privateKey) async {
    final params = {"contract": this.chain, "privateKey": privateKey};
    String result = await ChainCore.call("getPublicKey", params);
    return result;
  }

  Future<String> getAddress(String privateKey) async {
    final params = {"contract": this.chain, "privateKey": privateKey};
    try {
      String result = await ChainCore.call("getAddress", params);
      if (result == 'false') throw StateError("Chain getAddress error");
      return result;
    } catch (e) {
      throw e;
    }
  }

  Future<List<String>> getAddresses(String publicKey) async {
    return [];
  }

  Future<bool> validateAddress(String address) async {
    final params = {"contract": this.chain, "address": address};
    try {
      String result = await ChainCore.call("validateAddress", params);
      return result == "true";
    } catch (e) {
      return false;
    }
  }

  bool validateCreateAddress(String address) {
    return true;
  }

  Future<bool> existedCreateAddress(String address) async {
    return false;
  }

  bool validatePublicKey(String publicKey) {
    return true;
  }

  bool isMultiAddress() {
    return false;
  }

  double getMinKeepBalance() {
    return 0.0;
  }

  String getFreeFeeTip() {
    return "";
  }

  String getFeeCoin() {
    return chain;
  }

  Future<bool> validatePrivateKey(String privateKey) async {
    final params = {"contract": this.chain, "privateKey": privateKey};
    String result = await ChainCore.call("validatePrivateKey", params);
    return result == "true";
  }

  Future<bool> validateMnemonic(String mnemonic) async {
    final params = {"mnemonic": mnemonic};
    String result = await ChainCore.call("validateMnemonic", params);
    return result == "true";
  }

  Future<String> signMessage(String privateKey, String message) async {
    final params = {"contract": this.chain, "privateKey": privateKey, "message": message};
    String result = await ChainCore.call("signMessage", params);
    return result;
  }

  Future<String> sign(dynamic params) async {
    params['contract'] = this.chain;
    String result = await ChainCore.call("signTransaction", params);
    return result;
  }

  Future<String> signTransaction(dynamic params) async {
    params['contract'] = this.chain;
    String result = await ChainCore.call("signTransaction", params);
    return result;
  }

  Future<String> getDappFormat(dynamic data) async {
    final params = {"contract": this.chain, "data": data};
    String result = await ChainCore.call("formatDapp", params);
    return result;
  }

  Future<String> signDappTransaction(dynamic params) async {
    params['contract'] = this.chain;
    String result = await ChainCore.call("signTransaction", params);
    return result;
  }

  Future<String> signDappMessage(String privateKey, dynamic message) async {
    final params = {"contract": this.chain, "privateKey": privateKey, "message": message};
    String result = await ChainCore.call("signMessage", params);
    return result;
  }

  Map<String, String> getDappParams(String address) {
    Map<String, String> result = new Map();
    result["address"] = address;
    return result;
  }

  bool checkMemo(String memo) {
    return true;
  }

  Future<Map<String, dynamic>> buildAccount() {
    return Future.value(null);
  }
}

typedef JSCallback = void Function(Map<String, dynamic> data);
