import 'package:cube/chain/chaincore.dart';
import 'package:cube/chain/bnb.dart';
import 'package:cube/chain/eth.dart';
import 'package:cube/chain/matic.dart';
import 'package:cube/chain/tron.dart';
import 'package:cube/chain/true.dart';
import 'package:cube/core/core.dart';
import 'package:cube/models/model_base.dart';

class ChaiCoreContent {
  static List<Chain> allChains = [
    ETH(),
    MATIC(),
    BNB(),
    TRUE(),
    TRX(),
  ];

  static List<Chain> recommendChains = [
    ETH(),
  ];

  static List<Chain> defaultChains = [ETH()];

  static List<Chain> tokenChains = [
    ETH(),
  ];

  static List<Chain> dappChains = [
    ETH(),
  ];

  static Future<List<String>> getChainsByAddress(String address) async {
    List<String> chains = [];
    for (var i = 0; i < allChains.length; i++) {
      try {
        if (await allChains[i].validateAddress(address)) {
          chains.add(allChains[i].chain);
        }
      } catch (e) {
        print(e);
      }
    }
    return chains;
  }
}

class ChainAccount {
  String address;
  String rpcURL;
  String chainId;
  String apiKey;

  ChainAccount();

  ChainAccount.fromJson(Map<String, dynamic> json) {
    address = json.value2Str('address');
    rpcURL = json.value2Str('rpcURL');
    chainId = json.value2Str('chainId');
    apiKey = json.value2Str('apiKey');
  }

  toJson() {
    return {
      "address": address,
      "rpcURL": rpcURL,
      "chainId": chainId,
      "apiKey": apiKey,
    };
  }
}

class RPC {
  ChainRPC ETH;
  ChainRPC MATIC;
  ChainRPC BNB;
  ChainRPC TRUE;
  ChainRPC TRX;
}

class ChainRPC extends Model {
  String url;
  String chainId;
  String apiKey;

  @override
  parserImpl(Map<String, dynamic> json) {
    url = json.value2Str("url");
    chainId = json.value2Str("chainId");
    apiKey = json.value2Str("apiKey");
  }
}

Chain getChain(String chain, {Chain defaultValue = null}) {
  if (strIsEmpty(chain)) {
    return defaultValue;
  }
  chain = chain.toUpperCase();
  switch (chain) {
    case "ETH":
      return ETH();
    case "MATIC":
      return MATIC();
    case "BNB":
      return BNB();
    case "TRUE":
      return TRUE();
    case "TRX":
      return TRX();
    default:
      return defaultValue;
  }
}
