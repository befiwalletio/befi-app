import 'dart:convert';

import 'package:cube/chain/chain_exp.dart';
import 'package:cube/core/constant.dart';
import 'package:cube/core/core.dart';
import 'package:cube/models/model_base.dart';
import 'package:cube/net/requester.dart';
import 'package:cube/utils/utils_console.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SPUtils {
  static final SPUtils _instance = SPUtils.create();

  factory SPUtils() {
    return _instance;
  }

  SharedPreferences sp;

  static ConfigModel _configStatic;

  SPUtils.create() {
    checksp();
  }

  checksp() async {
    if (sp == null) {
      sp = await SharedPreferences.getInstance();
    }
    return Future.value(true);
  }

  Object get(String key) {
    return sp.get(key);
  }

  getBool(String key) {
    return sp.getBool(key) ?? false;
  }

  getInt(String key) {
    return sp.getInt(key) ?? 0;
  }

  getDouble(String key) {
    return sp.getDouble(key) ?? 0.0;
  }

  getString(String key) {
    return sp.getString(key) ?? '';
  }

  getList(String key) {
    String string = getString(key);
    console.i(string);
    if (!strIsEmpty(string)) {
      return jsonDecode(string);
    }
    return null;
  }

  void put(String key, dynamic value) {
    if (value is bool) {
      sp?.setBool(key, value);
    } else if (value is int) {
      sp?.setInt(key, value);
    } else if (value is double) {
      sp?.setDouble(key, value);
    } else if (value is String) {
      sp?.setString(key, value);
    } else if (value is List) {
      sp?.setString(key, jsonEncode(value));
    }
  }

  void remove(String key) {
    sp?.remove(key);
  }

  getStaticConfig() async {
    if (_configStatic == null) {
      await asyncStaticConfig();
    }
    return _configStatic;
  }

  _requestStaticConfig({bool justsave = false}) async {
    Result<ConfigModel> result = await Requester.line().path("/config/static").post<ConfigModel>(ConfigModel());
    if (result.code == 0) {
      if (!justsave) {
        _configStatic = result.result;
        _setStaticConfig();
      }
      SPUtils().put(Constant.CONFIG_STATIC, jsonEncode(result.origin['data']));
    } else {
      SPUtils().put(Constant.CONFIG_STATIC, '');
    }
    return Future.value(true);
  }

  _setStaticConfig() {
    Global.PAGE_AGREEMENT = _configStatic.config['agreement'];
    Global.PAGE_VERSION = _configStatic.config['version'];
    Global.CONNECTS = _configStatic.about;
    Global.PAGE_FEEDBACK = _configStatic.config['feedbackEmail'];
    Global.PAGE_INSTRUCTIONS = _configStatic.config['instructions'];
    Global.SUPORT_CHAINS = _configStatic.chains;
    Global.SUPORT_NFTS = _configStatic.nftchains;
    Global.SUPORT_DAPPS = _configStatic.dappGroups;

    var rpc_true = _configStatic.config['TRUE_RPC'];
    if (!strIsEmpty(rpc_true)) {
      var json = jsonDecode(rpc_true);
      Global.E_RPC.TRUE = ChainRPC().parser(json);
    }
    var rpc_eth = _configStatic.config['ETH_RPC'];
    if (!strIsEmpty(rpc_eth)) {
      var json = jsonDecode(rpc_eth);
      Global.E_RPC.ETH = ChainRPC().parser(json);
    }
    var rpc_matic = _configStatic.config['MATIC_RPC'];
    if (!strIsEmpty(rpc_matic)) {
      var json = jsonDecode(rpc_matic);
      Global.E_RPC.MATIC = ChainRPC().parser(json);
    }
    var rpc_bsc = _configStatic.config['BSC_RPC'];
    if (!strIsEmpty(rpc_bsc)) {
      var json = jsonDecode(rpc_bsc);
      Global.E_RPC.BNB = ChainRPC().parser(json);
    }
    var rpc_trx = _configStatic.config['TRX_RPC'];
    if (!strIsEmpty(rpc_trx)) {
      var json = jsonDecode(rpc_trx);
      Global.E_RPC.TRX = ChainRPC().parser(json);
    }
  }

  asyncStaticConfig() async {
    var spStaticConfig = SPUtils().getString(Constant.CONFIG_STATIC);
    if (spStaticConfig is String && !strIsEmpty(spStaticConfig)) {
      _configStatic = ConfigModel().parser(jsonDecode(spStaticConfig));
      _setStaticConfig();
      Future.delayed(Duration(seconds: 5), () {
        _requestStaticConfig(justsave: true);
      });
      return Future.value(true);
    } else {
      return await _requestStaticConfig();
    }
  }
}
