import 'dart:convert';
import 'dart:io';

import 'package:cube/chain/chaincore.dart';
import 'package:cube/chain/bnb.dart';
import 'package:cube/chain/chain_exp.dart';
import 'package:cube/chain/eth.dart';
import 'package:cube/chain/matic.dart';
import 'package:cube/chain/tron.dart';
import 'package:cube/chain/true.dart';
import 'package:cube/core/base_widget.dart';
import 'package:cube/core/constant.dart';
import 'package:cube/models/model_base.dart';
import 'package:cube/models/model_dapp.dart';
import 'package:cube/net/cookies.dart';
import 'package:cube/net/manager_api.dart';
import 'package:cube/net/requester.dart';
import 'package:cube/utils/utils_console.dart';
import 'package:cube/utils/utils_math.dart';
import 'package:cube/utils/utils_size.dart';
import 'package:cube/views/appbar/appbar.dart';
import 'package:cube/views/dialog/dialog_dapp_confirm_board.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_extend/share_extend.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:cube/core/core.dart';

class XWebView extends StatefulWidget {
  final String title;
  final String url;
  final Dapp dapp;

  const XWebView(this.url, {Key key, this.title, this.dapp}) : super(key: key);

  @override
  _XWebViewState createState() => _XWebViewState();
}

class _XWebViewState extends SizeState<XWebView> {
  bool _isAndroid = true;

  num progress;
  bool _showProgress = true;
  String ua;
  String url;
  String title;
  JavascriptChannel jhostChannel;

  WebViewController _iosViewController;

  Chain _chainCore;
  Dapp _dapp;

  @override
  void initState() {
    super.initState();
    _dapp = widget.dapp;
    if (_dapp != null) {
      title = _dapp.name;
    } else {
      title = widget.title ?? '';
    }
    url = widget.url;
    if (Platform.isAndroid) {
      _isAndroid = true;
      ua =
          "Mozilla/5.0 (Linux; Android 5.1.1; Nexus 4 Build/KOT49H) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.130 Mobile Safari/537.36";
    } else {
      _isAndroid = false;
      ua = "Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A372 Safari/604.1";
    }
    progress = 0;
    jhostChannel = JavascriptChannel(
        name: "__JSHOST",
        onMessageReceived: (JavascriptMessage data) async {
          Map<String, dynamic> jsonDecode2 = jsonDecode(data.message);
          _handleJSHost(jsonDecode2);
        });
  }

  @override
  Widget createView(BuildContext context) {
    Widget webview = WebView(
      initialUrl: url,
      userAgent: ua,
      javascriptMode: JavascriptMode.unrestricted,
      javascriptChannels: <JavascriptChannel>[jhostChannel].toSet(),
      cookieList: [
        {'k': 'abc', 'v': '1234'}
      ],
      onWebViewCreated: (WebViewController web) async {
        _iosViewController = web;
      },
      onPageStarted: (url) {
        _injectAccount();
      },
      onPageFinished: (url) {
        setState(() {
          _showProgress = false;
        });
      },
    );
    return MediaQuery(
        data: MediaQuery.of(context).copyWith(devicePixelRatio: 1.0, textScaleFactor: 1.0),
        child: WillPopScope(
            child: Scaffold(
              appBar: XAppBar(
                title: Text(title ?? ''),
                leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_rounded,
                      size: SizeUtil.width(20),
                    ),
                    onPressed: () {
                      back();
                    }),
                actions: [
                  Builder(builder: (context) {
                    return Container(
                      padding: SizeUtil.padding(top: 10, bottom: 10, right: 10),
                      child: Container(
                        height: SizeUtil.height(30),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey, width: SizeUtil.width(0.5)),
                            borderRadius: BorderRadius.circular(SizeUtil.width(30))),
                        padding: SizeUtil.padding(left: 7, right: 7),
                        alignment: Alignment.center,
                        child: Row(
                          children: [
                            InkWell(
                              child: Icon(
                                Icons.share,
                                size: SizeUtil.width(17),
                              ),
                              onTap: () {
                                shareAction();
                              },
                            ),
                            Container(
                              margin: SizeUtil.padding(left: 5, right: 5),
                              height: SizeUtil.width(15),
                              width: SizeUtil.width(1),
                              color: Colors.grey,
                            ),
                            InkWell(
                              child: Icon(
                                Icons.close,
                                size: SizeUtil.width(20),
                              ),
                              onTap: () {
                                Get.back();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  })
                ],
                bottom: _showProgress
                    ? PreferredSize(
                        preferredSize: Size(SizeUtil.screenWidth(), SizeUtil.height(2)),
                        child: SizedBox(
                          child: LinearProgressIndicator(),
                          height: SizeUtil.height(2),
                          width: SizeUtil.screenWidth(),
                        ),
                      )
                    : PreferredSize(
                        preferredSize: Size(
                          SizeUtil.screenWidth(),
                          0,
                        ),
                        child: SizedBox(
                          height: 0,
                        ),
                      ),
              ),
              body: Container(
                child: Stack(
                  children: [
                    webview,
                  ],
                ),
              ),
            ),
            onWillPop: () async {
              await back();
            }));
  }

  back() async {
    bool canBack = false;
    canBack = await _iosViewController.canGoBack();
    if (canBack) {
      _iosViewController.goBack();
    } else {
      Get.back();
    }
  }

  reload() async {
    _injectAccount();
    await _iosViewController.reload();
  }

  loadHtmlFromAssets() async {
    await _iosViewController.loadUrl(url);
  }

  _jsbcallback(String id, String err, String data) async {
    showLoading(show: false);
    err = err.replaceAll("'", "");
    data = data.replaceAll("'", "");
    await _iosViewController.evaluateJavascript("""window.__jMessage('$id', '$err', '$data');""");
  }

  _injectAccount() async {
    if (_dapp != null && _dapp.chain != null) {
      String account = "";
      String inject = "";
      Chain chain;
      if (_dapp.chain.compareTo("ETH") == 0) {
        chain = ETH();
        var jsonAccount = await chain.buildAccount();
        ChainAccount ethAccount = ChainAccount.fromJson(jsonAccount);
        inject = await rootBundle.loadString("assets/files/inject_eth.js");
        account =
            "window.Bee={'account':{'eth':{'address':'${ethAccount.address}'}}, 'chain':{'eth':{'rpcURL':'${ethAccount.rpcURL}','chainId':'${ethAccount.chainId}'}},'appid':'${Constant.APPID}','appkey':'${Constant.APPKEY}','license':'','version':'${Global.VERSION}'};";
      } else if (_dapp.chain.compareTo(Constant.CHAIN_MATIC) == 0) {
        chain = MATIC();
        var jsonAccount = await chain.buildAccount();
        ChainAccount maticAccount = ChainAccount.fromJson(jsonAccount);
        inject = await rootBundle.loadString("assets/files/inject_matic.js");
        account =
            "window.Bee={'account':{'matic':{'address':'${maticAccount.address}'}}, 'chain':{'matic':{'rpcURL':'${maticAccount.rpcURL}','chainId':'${maticAccount.chainId}'}},'appid':'${Constant.APPID}','appkey':'${Constant.APPKEY}','license':'','version':'${Global.VERSION}'};";
      } else if (_dapp.chain.compareTo(Constant.CHAIN_BNB) == 0) {
        chain = BNB();
        var jsonAccount = await chain.buildAccount();
        ChainAccount bscAccount = ChainAccount.fromJson(jsonAccount);
        inject = await rootBundle.loadString("assets/files/inject_bnb.js");
        account =
            "window.Bee={'account':{'bnb':{'address':'${bscAccount.address}'}}, 'chain':{'bnb':{'rpcURL':'${bscAccount.rpcURL}','chainId':'${bscAccount.chainId}'}},'appid':'${Constant.APPID}','appkey':'${Constant.APPKEY}','license':'','version':'${Global.VERSION}'};";
      } else if (_dapp.chain.compareTo(Constant.CHAIN_TRUE) == 0) {
        chain = TRUE();
        var jsonAccount = await chain.buildAccount();
        ChainAccount trueAccount = ChainAccount.fromJson(jsonAccount);
        inject = await rootBundle.loadString("assets/files/inject_true.js");
        account =
            "window.Bee={'account':{'true':{'address':'${trueAccount.address}'}}, 'chain':{'true':{'rpcURL':'${trueAccount.rpcURL}','chainId':'${trueAccount.chainId}'}},'appid':'${Constant.APPID}','appkey':'${Constant.APPKEY}','license':'','version':'${Global.VERSION}'};";
      } else if (_dapp.chain.compareTo(Constant.CHAIN_TRON) == 0) {
        chain = TRX();
        var jsonAccount = await chain.buildAccount();
        ChainAccount trxAccount = ChainAccount.fromJson(jsonAccount);
        inject = await rootBundle.loadString("assets/files/inject_trx.js");
        account =
            "window.Bee={'account':{'trx':{'address':'${trxAccount.address}'}}, 'chain':{'trx':{'rpcURL':'${trxAccount.rpcURL}','apiKey':'${trxAccount.apiKey}','chainId':'${trxAccount.chainId}'}},'appid':'${Constant.APPID}','appkey':'${Constant.APPKEY}','license':'','version':'${Global.VERSION}'};";
        console.i(account);
      }
      if (chain != null && account.isNotEmpty && inject.isNotEmpty) {
        console.i("开始注入 ${chain.symbol} ${account}");
        final String s = "javascript:(function() {" +
            "console.log('开始注入');" +
            account +
            "var parent = document.getElementsByTagName('head').item(0);" +
            "var script = document.createElement('script');" +
            "script.type = 'text/javascript';" +
            "script.innerHTML = console.log('Inject,开始注入');$inject;console.log('注入,结束注入');" +
            "parent.appendChild(script)" +
            "})()";
        String result = await _iosViewController.evaluateJavascript(s);
      }
    }
  }

  _handleJSHost(params) async {
    console.i(params);
    var temp = params;
    if (params is String) {
      temp = jsonDecode(params);
    }

    if (temp is Map) {
      Map<String, dynamic> params2 = temp;
      String id = params2.value2Str("id");
      String chain = params2.value2Str("chain");
      String symbol = chain;
      String method = params2.value2Str("method");
      dynamic data = params2['data'];
      if (chain != null) {
        chain = chain.toUpperCase();
        _chainCore = getChain(chain, defaultValue: ETH());
      }
      String contractAddress = data['contractAddress'];
      if (data['symbol'] != null) {
        symbol = data['symbol'];
      }
      console.i(data);

      switch (method) {
        case "getAccounts":
        case "injectAccounts":
          break;
        case "sign":
          String privateKey = await getPrivateKey(context, chain);
          data['privateKey'] = privateKey;
          String address = await _chainCore.getAddress(privateKey);
          Result<DefaultModel> nonceResult = await requestNonce({"address": address, "contract": chain});
          data['nonce'] = nonceResult.result.nonce;
          var result = await _chainCore.sign(data);
          _jsbcallback(id, "", result);
          break;
        case "multSend":
          break;
        case "dappsSign":
          showLoading();
          Result<DefaultModel> decimalResult = await requestDecimal({
            "symbol": symbol,
            "contract": chain,
            "contractAddress": contractAddress,
          });
          int decimal = decimalResult.result.decimal.toInt();
          Result<Fees> feesResult = await requestFees({
            "symbol": chain,
            "contract": chain,
            "from": data['from'],
            "to": data['to'],
            "value": MathCalc.startWithInt('${data['value']}'.hexToInt()).divide(decimal.toDecimal()).toNumber(),
            "data": data['data'],
          });
          var dialog = await showDialog(
              useSafeArea: false,
              barrierDismissible: false,
              context: context,
              builder: (context) {
                return DialogDappInfoBoard(
                  icon: _dapp.icon,
                  name: _dapp.name,
                  fees: feesResult.result,
                  fee: '${data['fee']}',
                  coin: symbol,
                  chain: chain,
                  data: {
                    "from": data['from'],
                    "to": data['to'],
                    "value": MathCalc.startWithInt('${data['value']}'.hexToInt()).divide(decimal.toDecimal()).toNumber(),
                    "action": data['action']
                  },
                  callback: (value) async {
                    data['gasPrice'] = value['gas_price'];
                    data['gasLimit'] = value['gas_limit'];
                    Get.back();
                    String privateKey = await getPrivateKey(context, chain);
                    data['privateKey'] = privateKey;
                    String address = await _chainCore.getAddress(privateKey);
                    Result<DefaultModel> nonceResult = await requestNonce({"address": address, "contract": chain});
                    data['nonce'] = nonceResult.result.nonce;

                    var sign = await _chainCore.signDappTransaction(data);
                    _jsbcallback(id, "", sign);
                  },
                  noneback: () {
                    Get.back();
                    _jsbcallback(id, "", "");
                  },
                );
              });
          break;
        case "dappsSignSend":
          showLoading();
          Result<DefaultModel> decimalResult = await requestDecimal({
            "symbol": chain,
            "contract": chain,
          });
          int decimal = decimalResult.result.decimal.toInt();
          Result<Fees> feesResult = await requestFees({
            "symbol": chain,
            "contract": chain,
            "from": data['from'],
            "to": data['to'],
            "value": MathCalc.startWithInt('${data['value']}'.hexToInt()).divide(decimal.toDecimal()).toNumber(),
            "data": data['data'],
          });
          var dataTemp = {
            "from": data['from'],
            "to": data['to'],
            "value": strIsEmpty(data['value']) ? 0 : MathCalc.startWithInt('${data['value']}'.hexToInt()).divide(decimal.toDecimal()).toNumber()
          };
          console.i(dataTemp);
          await showDialog(
              useSafeArea: false,
              barrierDismissible: false,
              context: context,
              builder: (context) {
                return DialogDappInfoBoard(
                  icon: _dapp.icon,
                  name: _dapp.name,
                  fees: feesResult.result,
                  coin: chain,
                  chain: chain,
                  data: dataTemp,
                  callback: (value) async {
                    data['gasPrice'] = value['gas_price'];
                    data['gasLimit'] = value['gas_limit'];
                    Get.back();
                    String privateKey = await getPrivateKey(context, chain);
                    data['privateKey'] = privateKey;
                    String address = await _chainCore.getAddress(privateKey);
                    Result<DefaultModel> nonceResult = await requestNonce({"address": address, "contract": chain});
                    data['nonce'] = nonceResult.result.nonce;

                    var sign = await _chainCore.signDappTransaction(data);
                    data['sign'] = sign;
                    data['privateKey'] = '';
                    data['contract'] = chain;
                    data['value'] = dataTemp['value'] ?? '0';

                    Result<DefaultModel> result = await requestSend(data);
                    _jsbcallback(id, "", result.result.hash);
                  },
                  noneback: () {
                    Get.back();
                    _jsbcallback(id, "", "");
                  },
                );
              });

          break;
        case "dappsSignMessage":
          String privateKey = await getPrivateKey(context, chain);
          data['privateKey'] = privateKey;
          String address = await _chainCore.getAddress(privateKey);
          Result<DefaultModel> nonceResult = await requestNonce({"address": address, "contract": chain});
          data['nonce'] = nonceResult.result.nonce;
          var result = await _chainCore.signDappMessage(privateKey, data);
          _jsbcallback(id, "", result);
          break;
      }
    }
  }

  shareAction() async {
    ShareExtend.share(url, "text");
  }

  _getCookie() {
    String cookies = Cookies().getDeviceCookie(null);
    return cookies;
  }

  @override
  void dispose() {
    super.dispose();
    if (_iosViewController != null) {
      _iosViewController.clearCache();
    }
  }
}
