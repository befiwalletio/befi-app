import 'dart:convert';

import 'package:cube/chain/chaincore.dart';
import 'package:cube/core/constant.dart';
import 'package:cube/models/model_base.dart';
import 'package:cube/utils/utils_console.dart';
import 'package:cube/utils/utils_db.dart';
import 'package:cube/utils/utils_sp.dart';

import 'chain_exp.dart';

class MATIC extends Chain {
  String chainId = '';
  String url = '';

  MATIC() : super(symbol: Constant.CHAIN_MATIC, chain: Constant.CHAIN_MATIC) {
    if (Global.E_RPC.MATIC != null) {
      this.chainId = Global.E_RPC.MATIC.chainId;
      this.url = Global.E_RPC.MATIC.url;
    } else {
      this.chainId = '137';
      this.url = 'https://rpc-mainnet.matic.network';
    }
  }

  @override
  Map<String, String> getDappParams(String address) {
    Map<String, String> result = {"address": address, "rpcURL": url};
    return result;
  }

  @override
  Future<String> signTransaction(dynamic params) async {
    String contract = "";
    String contractAddress = "";
    if (params['contract'] != null && params['contract'].toString() != '0x') {
      contract = params['contract'].toString();
    }
    if (params['contract_address'] != null && params['contract_address'].toString() != '0x') {
      contractAddress = params['contract_address'].toString();
    }
    String gasLimit = '100000';
    String gasPrice = '0.0000001';
    if (params['fee'] != null) {
      gasLimit = params['fee']['gas_limit'].toString();
      gasPrice = params['fee']['gas_price'].toString();
    } else {
      if (params['gas_limit'] != null) {
        gasLimit = params['gas_limit'];
        gasPrice = params['gas_price'];
      } else if (params['gasLimit'] != null) {
        gasLimit = params['gasLimit'];
        gasPrice = params['gasPrice'];
      }
    }

    var amount = params["amount"] ?? '0';
    if (contract.isNotEmpty) {
      if (params["amountChecked"] != null) {
        amount = params["amount"];
      } else {
        amount = '0';
      }
    }
    final data = {
      "privateKey": params["privateKey"].toString(),
      "tokenAddress": contractAddress,
      "toAddress": params["to"].toString(),
      "amount": amount,
      "nonce": params['nonce'],
      "gasLimit": gasLimit,
      "gasPrice": gasPrice,
      "data": params['data'],
      "contract": Constant.CHAIN_MATIC,
      "chainId": chainId
    };
    Console.d('Sign Params: ${data}');
    return await super.signTransaction(data);
  }

  @override
  Future<String> signDappTransaction(dynamic params) async {
    console.i(params);
    String gasLimit = '100000';
    String gasPrice = '0.0000001';
    if (params['fee'] != null) {
      gasLimit = params['fee']['gas_limit'].toString();
      gasPrice = params['fee']['gas_price'].toString();
    } else {
      gasLimit = params['gas_limit'] ?? (params['gasLimit'] ?? gasLimit);
      gasPrice = params['gas_price'] ?? (params['gasPrice'] ?? gasPrice);
    }

    final data = {
      "privateKey": params["privateKey"],
      "to": params["to"],
      "from": params["from"],
      "amount": params['amount'] ?? (params['value'] ?? '0'),
      "nonce": params['nonce'],
      "gasLimit": gasLimit,
      "gasPrice": gasPrice,
      "data": params['data'],
      "contract": Constant.CHAIN_MATIC,
      "chainId": chainId
    };
    final sig = await super.signTransaction(data);
    Console.d('Sign Params: ' + json.encode(data) + '  sign:${sig}');
    return sig;
  }

  @override
  Future<Map<String, dynamic>> buildAccount() async {
    ChainAccount account = ChainAccount();
    String wid = SPUtils().getString(Constant.CUSTOM_WID);
    List<Coin> coins = await DBHelper.create().queryCoins(wid, contract: Constant.CHAIN_MATIC, symbol: Constant.CHAIN_MATIC);
    if (coins != null) {
      Coin coin = coins[0];
      account.address = coin.address;
    }
    account.rpcURL = getDappParams(account.address)['rpcURL'];
    account.chainId = chainId;
    return account.toJson();
  }
}
