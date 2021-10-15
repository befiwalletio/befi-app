import 'dart:convert';
import 'dart:isolate';
import 'dart:math';

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:bee_encryption/uuid.dart';
import 'package:cube/chain/chaincore.dart';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:cube/chain/eth.dart';
import 'package:cube/models/model_base.dart';
import 'package:cube/net/manager_api.dart';
import 'package:cube/utils/utils_console.dart';
import 'package:cube/utils/utils_db.dart';
import 'package:cube/utils/utils_sp.dart';
import 'package:cube/views/dialog/dialog_pass_board.dart';
import 'package:cube/chain/chain_exp.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bee_encryption/bee_encryption.dart';

import 'constant.dart';

Widget createLottie() {}

bool strIsEmpty(String str) {
  if (str == null || str == '') {
    return true;
  }
  return false;
}

String randomString(int length) {
  String alphabet = 'qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM';
  String left = '';
  for (var i = 0; i < length; i++) {
    left = left + alphabet[Random().nextInt(alphabet.length)];
  }
  return left;
}

String formatAddress(String address) {
  if (strIsEmpty(address)) {
    return '';
  }
  if (address.length < 16) {
    return address;
  }
  String start = address.substring(0, 8);
  String end = address.substring(address.length - 8);
  return '$start...$end';
}

showSnackBar(String message, {String title, Duration duration}) {
  if (duration == null) {
    duration = Duration(seconds: 1);
  }
  Get.showSnackbar(
    GetBar(title: title, message: message, snackPosition: SnackPosition.TOP, backgroundColor: Colors.blue, duration: duration),
  );
}

showTipsBar(String message, {String title, Duration duration, Color backgroundColor}) {
  if (duration == null) {
    duration = Duration(seconds: 1);
  }
  Get.showSnackbar(
    GetBar(title: title, message: message, snackPosition: SnackPosition.TOP, backgroundColor: backgroundColor ?? Colors.blue, duration: duration),
  );
}

showWarnBar(String message, {String title, Duration duration, SnackPosition snackPosition = SnackPosition.TOP}) {
  if (duration == null) {
    duration = Duration(seconds: 1);
  }
  Get.showSnackbar(
    GetBar(title: title, message: message, snackPosition: snackPosition ?? SnackPosition.TOP, backgroundColor: Colors.red, duration: duration),
  );
}

String generateUDID() {
  return getMd5(Uuid().v1());
}

String generateId() {
  return getMd5(Uuid().v1() + '${DateTime.now().millisecond}');
}

String getMd5(String data) {
  var content = new Utf8Encoder().convert(data);
  var digest = md5.convert(content);
  return hex.encode(digest.bytes);
}

String formatNum(double num, int location) {
  if ((num.toString().length - num.toString().lastIndexOf(".") - 1) < location) {
    return num.toStringAsFixed(location).substring(0, num.toString().lastIndexOf(".") + location + 1).toString();
  } else {
    return num.toString().substring(0, num.toString().lastIndexOf(".") + location + 1).toString();
  }
}

///@authKey password
String getKey(String authKey) {
  return getMd5(authKey + Constant.SEED_ABC + Global.DEVICE_UDID);
}

String getTokenId(String token) {
  return getMd5(Constant.SEED_ABC + token + Constant.SEED_ABC);
}

///encrypt
///@token private key、mnemonic
///@authKey password
Future<String> encrypt(String token, String authKey) async {
  console.i({"action": "encrypt", "token": token, "pass": authKey});
  var result = await BeeEncryption.encryptString(token, getKey(authKey));
  console.i({"action": "encrypt", "token": token, "pass": authKey, "result": result});
  return result;
}

///decrypt
///@token private key、mnemonic encrypted token
///@authKey password
Future<String> decrypt(String token, String authKey) async {
  console.i({"action": "decrypt", "token": token, "pass": authKey});
  try {
    var result = await BeeEncryption.decryptString(token, getKey(authKey));
    console.i({"action": "decrypt", "token": token, "pass": authKey, "result": result});
    return result;
  } catch (e) {
    console.i(e.toString());
    return null;
  }
}

Future<String> goScan() async {
  var options = ScanOptions(android: AndroidOptions(aspectTolerance: 1));
  ScanResult result = await BarcodeScanner.scan(options: options);
  if (result != null) {
    return result.rawContent;
  }
  return "";
}

Future<String> getPrivateKeyFromKeystoreEth(BuildContext context, chains, keystore, passwordKS) async {
  if (chains != null) {
    String privateKey = await chains.getPrivateKey(keystore: keystore, password: passwordKS);
    return privateKey;
  } else {
    return "";
  }
}

Future<String> getKeystoreFromPrivateKey(BuildContext context, chains, privateKey, passwordKS) async {
  if (chains != null) {
    String keystore = await chains.getKeystore(privateKey: privateKey, password: passwordKS);
    return keystore;
  } else {
    return "";
  }
}

Future<String> getPrivateKeyFromKeystore(BuildContext context, chains, keystore, passwordKS) async {
  if (chains.length > 0) {
    Coin coin = chains[0];
    Chain chain = getChain(coin.contract);
    if (chain != null) {
      String privateKey = await chain.getPrivateKey(keystore: keystore, password: passwordKS);
      return privateKey;
    }
  }
  return "";
}

Future<String> getPrivateKeyFromMnemonic(BuildContext context, chains, mnemonic) async {
  if (chains.length > 0) {
    Coin coin = chains[0];
    Chain chain = getChain(coin.contract);
    if (chain != null) {
      String privateKey = await chain.getPrivateKey(mnemonic: mnemonic);
      return privateKey;
    }
  }
  return "";
}

Future<String> getPrivateKey(BuildContext context, String contract) async {
  contract = contract.toUpperCase();
  String wid = SPUtils().getString(Constant.CUSTOM_WID);
  Identity identity = await DBHelper().queryIdentity(wid);
  List<Coin> items = await DBHelper().queryCoins(wid, contract: contract, symbol: contract);
  Coin coin;
  if (items.isNotEmpty) {
    coin = items[0];
  }
  String privateKey = '';
  await showDialog(
      useSafeArea: false,
      context: context,
      builder: (context) {
        return DialogPassBoard(
          callback: (text) async {
            String pass = getTokenId(text);
            var auth = await DBHelper().queryAuth();
            if (pass != auth.password) {
              showWarnBar("CommonPwdError".tr);
              return;
            }
            String token = await decrypt(identity.token, pass);
            console.i(token);
            if (identity.tokenType == 'private') {
              privateKey = token;
            } else if (identity.tokenType == 'keystore') {
              privateKey = await decrypt(identity.privateKey, pass);
            } else {
              Chain chain = getChain(contract, defaultValue: ETH());
              privateKey = await chain.getPrivateKey(mnemonic: token);
            }
            Get.back();
          },
        );
      });
  return privateKey;
}

Future<List<String>> saveCoins(context, wid, chains,
    {bool needRequest = false,
    String mnemonic,
    String keystore = "",
    String passwordKS = "",
    String privateKey = "",
    String tokenType = 'mnemonic',
    String pass,
    StringCallback callback}) async {
  String token = '';
  if (!strIsEmpty(privateKey) && strIsEmpty(keystore)) {
    tokenType = 'private';
  } else if (strIsEmpty(mnemonic) && strIsEmpty(keystore)) {
    Identity identity = await DBHelper.create().queryIdentity(wid);
    await showDialog(
        useSafeArea: false,
        context: context,
        builder: (builder) {
          return DialogPassBoard(callback: (text) async {
            token = identity.token;
            pass = text;
            pass = getTokenId(text);
            Auth auth = await DBHelper().queryAuth();
            if (auth.password != pass) {
              showWarnBar("CommonPwdError".tr);
              return Future.value(null);
            }

            token = await decrypt(token, pass);
            if (identity.tokenType == 'mnemonic') {
              mnemonic = token;
            } else if (identity.tokenType == 'keystore') {
              tokenType = 'keystore';
              keystore = Uri.encodeComponent(token);
              privateKey = await decrypt(identity.privateKey, pass);
            } else if (identity.tokenType == 'private') {
              privateKey = token;
              tokenType = 'private';
            }
            Get.back();
            if (callback != null) {
              callback(pass);
            }
          });
        });
    console.i("密码版收起");
  }
  List<String> descAddresses = [];
  for (int i = 0; i < chains.length; i++) {
    Coin coin = chains[i];
    Chain chain = getChain(coin.contract);
    if (chain != null) {
      String privateKey2 = privateKey;
      String token2;
      String privateKeyEn;
      if (!strIsEmpty(mnemonic)) {
        privateKey2 = await chain.getPrivateKey(mnemonic: mnemonic);
        token2 = await encrypt(mnemonic, pass);
        privateKeyEn = await encrypt(privateKey2, pass);
      } else if (!strIsEmpty(keystore)) {
        if (strIsEmpty(passwordKS) && !strIsEmpty(privateKey2)) {
          token2 = await encrypt(keystore, pass);
          privateKeyEn = await encrypt(privateKey2, pass);
        } else {
          token2 = await encrypt(keystore, pass);
          privateKeyEn = await encrypt(privateKey2, pass);
        }
      } else {
        token2 = await encrypt(privateKey2, pass);
        privateKeyEn = token2;
      }

      String publicKey = "";
      String address = await chain.getAddress(privateKey2);
      coin.wid = wid;
      coin.token = token2;
      coin.publicKey = publicKey;
      coin.privateKey = privateKeyEn;
      coin.tokenType = tokenType;
      coin.address = address;
      await DBHelper.create().insertCoin(coin);
      descAddresses.add(coin.symbol.toDescAddress(address));
    }
  }
  if (needRequest) {
    await requestCreate(wid, descAddresses);
  }
  return Future.value(descAddresses);
}

extension custom_int on int {
  toDecimal() {
    int temp = 1;
    for (int i = 0; i < this; i++) {
      temp = temp * 10;
    }
    return temp;
  }
}

extension custom_str on String {
  toColor() {
    try {
      if (this.indexOf("0x") >= 0) {
        return Color(int.parse(this));
      }
    } catch (e) {
      return BeeColors.blue;
    }
    var hexColor = this.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    if (hexColor.length == 8) {
      return Color(int.parse("0x$hexColor"));
    }
  }

  toDescAddress(address) {
    return '${this.toUpperCase()}:$address';
  }

  toInt({defaultValue: 0}) {
    try {
      return int.parse(this);
    } catch (e) {
      return defaultValue;
    }
  }

  toDouble({defaultValue: 0.0}) {
    try {
      return double.parse(this);
    } catch (e) {
      return defaultValue;
    }
  }

  double hexToDouble() {
    return '${this.hexToInt()}'.toDouble();
  }

  int hexToInt() {
    if (!this.startsWith("0x")) {
      return this.toInt();
    }
    try {
      String temp = this.substring(
        2,
      );
      var result = int.parse(temp, radix: 16);
      console.i(result);
      return result;
    } catch (e) {}
    return 0;
  }

  String urlAppendParams(String key, String value) {
    if (strIsEmpty(key)) {
      return this;
    }

    String params = '$key=${Uri.encodeComponent(value)}';

    if (this.indexOf('?') >= 0) {
      if (this.indexOf('&') >= 0) {
        return '$this&$params';
      } else {
        return '${this}$params';
      }
    } else {
      return '$this?$params';
    }
  }
}

extension custom_list on List {
  void forEachWithIndex(void f(int index, element)) {
    int index = 0;
    for (var element in this) {
      f(index, element);
      index++;
    }
  }
}

extension custom_mapstr on Map<String, dynamic> {
  value2Str(String key) {
    var value = this[key];
    try {
      if (value is String) {
        return value;
      }
      if (value == null) {
        return '';
      }
      if (value == 'null') {
        return '';
      }
      return value.toString();
    } catch (e) {
      return '';
    }
  }

  value2Num(String key) {
    var value = this[key];
    if (value == null) {
      return 0;
    }
    try {
      if (value is String) {
        return num.parse(value);
      }
      if (value is num) {
        return value;
      }
    } catch (e) {
      return 0;
    }
    return 0;
  }

  value2Int(key) {
    var value = this[key];
    if (value == null) {
      return 0;
    }
    try {
      if (value is String) {
        return int.parse(value);
      }
      if (value is int) {
        return value;
      }
    } catch (e) {
      return 0;
    }
    return 0;
  }

  value2Bool(key) {
    var value = this[key];
    if (value == null) {
      return false;
    }
    try {
      if (value is bool) {
        return value;
      }
      if (value is String) {
        return value == 'true';
      }
      if (value is num) {
        return value > 0;
      }
    } catch (e) {}
    return false;
  }

  value2List(key) {
    var value = this[key];
    if (value == null) {
      return [];
    }
    try {
      if (value is List) {
        return value;
      }
    } catch (e) {}
    return [];
  }
}

extension custom_color on Color {
  String toHexString() => '0x${value.toRadixString(16).padLeft(8, '0')}';
}

class WorkHelper {
  Future isolateMainRequest(request) async {
    var receivePort = new ReceivePort();
    await Isolate.spawn(isolateWorkRequest, receivePort.sendPort);
    var sendPort = await receivePort.first;
    var result = await isolateSender(sendPort, request);
    isolateSender(sendPort, "close");
    return result;
  }

  static isolateWorkRequest(SendPort sendPort) async {
    var port = new ReceivePort();
    sendPort.send(port.sendPort);
    await for (var msg in port) {
      var data = msg[0];
      SendPort replyTo = msg[1];
      replyTo.send(data);
      if (data == "close") {
        port.close();
      }
    }
  }

  Future isolateSender(SendPort port, data) async {
    ReceivePort response = new ReceivePort();
    if (data == 'close') {
      port.send([data, response.sendPort]);
    } else {
      var result = await data;
      port.send([result, response.sendPort]);
    }
    return response.first;
  }
}

enum ConferenceItem { DEL }

typedef StringCallback = void Function(String data);
typedef NumberCallback = void Function(num data);
typedef BoolCallback = void Function(bool data);
typedef MapCallback = void Function(Map data);
