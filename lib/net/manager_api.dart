import 'package:cube/core/constant.dart';
import 'package:cube/core/core.dart';
import 'package:cube/models/model_base.dart';
import 'package:cube/models/model_dapp.dart';
import 'package:cube/models/model_detail.dart';
import 'package:cube/models/model_home.dart';
import 'package:cube/models/model_nft.dart';
import 'package:cube/net/requester.dart';
import 'package:cube/utils/utils_sp.dart';
import 'package:cube/utils/utils_console.dart';

requestChains(wid) async {
  var requester = Requester.line().path("/chain/chains");
  if (!strIsEmpty(wid)) {
    requester.addParams("wid", wid);
  }
  Result<Chains> result = await requester.post<Chains>(Chains());
  console.i(result.origin);
  return result;
}

requestCreate(wid, List chains) async {
  Result<DefaultModel> result =
      await Requester.line().path("/wallet/create").addParams("wid", wid).addParams("chains", chains.join(",")).post<DefaultModel>(DefaultModel());

  return result;
}

requestHome(wid) async {
  if (strIsEmpty(wid)) {
    wid = SPUtils().getString(Constant.CUSTOM_WID);
  }

  if (strIsEmpty(wid)) {
    return null;
  }
  Result<HomeIndex> result = await Requester.line().path("/wallet/index").addParams("wid", wid).post<HomeIndex>(HomeIndex());
  return result;
}

requestFees(params) async {
  Result<Fees> result = await Requester.line().path("/wallet/fees").addMapParams(params).post<Fees>(Fees());
  console.i(result.origin);
  return result;
}

requestSend(params) async {
  Result<DefaultModel> result = await Requester.line().path("/wallet/send").addMapParams(params).post<DefaultModel>(DefaultModel());
  console.i(result.origin);
  return result;
}

requestNonce(params) async {
  Result<DefaultModel> result = await Requester.line().path("/wallet/nonce").addMapParams(params).post<DefaultModel>(DefaultModel());
  console.i(result.result != null ? result.result.toJson() : "NONE");
  return result;
}

requestInputData(params) async {
  Result<DefaultModel> result = await Requester.line().path("/wallet/tokenData").addMapParams(params).post<DefaultModel>(DefaultModel());
  console.i(result.origin);
  return result;
}

requestHistory(params) async {
  Result<CoinTransModel> result = await Requester.line().path("/coin/transactions").addMapParams(params).post<CoinTransModel>(CoinTransModel());
  console.i(result.origin);
  return result;
}

requestCoins(key, wid) async {
  console.i(key);
  Result<Chains> result = await Requester.line().path("/coin/searchCoin").addParams("condition", key).addParams("wid", wid).post<Chains>(Chains());
  console.i(result.origin);
  return result;
}

requestAddCoin(params) async {
  Result<DefaultModel> result = await Requester.line().path("/wallet/add").addMapParams(params).post<DefaultModel>(DefaultModel());
  console.i(result.origin);
  return result;
}

requestDelChain(params) async {
  Result<DefaultModel> result = await Requester.line().path("/wallet/deleteChain").addMapParams(params).post<DefaultModel>(DefaultModel());
  console.i(result.origin);
  return result;
}

requestHideCoin(params) async {
  Result<DefaultModel> result = await Requester.line().path("/coin/hideCoin").addMapParams(params).post<DefaultModel>(DefaultModel());
  console.i(result.origin);
  return result;
}

requestDapps(params) async {
  Result<Dapps> result = await Requester.line().path("/dapp/dapps").post<Dapps>(Dapps());
  console.i(result.origin);
  return result;
}

requestSearchDapps(key) async {
  Result<Dapps> result = await Requester.line().path("/dapp/search").addParams('condition', key).post<Dapps>(Dapps());
  console.i(result.origin);
  return result;
}

requestCommentDapps(wid) async {
  Result<StringListModel> result = await Requester.line().path("/dapp/comment").addParams('wid', wid).post<StringListModel>(StringListModel());
  console.i(result.origin);
  return result;
}

requestDecimal(params) async {
  Result<DefaultModel> result = await Requester.line().path("/chain/decimal").addMapParams(params).post<DefaultModel>(DefaultModel());
  return result;
}

requestHotList(params) async {
  Result<Chains> result = await Requester.line(tag: params['contract']).path("/coin/hotList").addMapParams(params).post<Chains>(Chains());
  console.i(result.origin);
  return result;
}

requestNFTHotList(params) async {
  Result<Chains> result = await Requester.line(tag: params['contract']).path("/nft/hotList").addMapParams(params).post<Chains>(Chains());
  console.i(result.origin);
  return result;
}

requestNFTAdd(params) async {
  console.i(params);
  Result<DefaultModel> result = await Requester.line().path("/nft/add").addMapParams(params).post<DefaultModel>(DefaultModel());
  console.i(result.origin);
  return result;
}

requestNFTHide(params) async {
  console.i(params);
  Result<DefaultModel> result = await Requester.line().path("/nft/hide").addMapParams(params).post<DefaultModel>(DefaultModel());
  console.i(result.origin);
  return result;
}

requestNFTSearch(key, wid) async {
  console.i(key);
  Result<Chains> result = await Requester.line().path("/nft/search").addParams("condition", key).addParams("wid", wid).post<Chains>(Chains());
  console.i(result.origin);
  return result;
}

requestNFTIndex(wid, {String contract}) async {
  console.i({'wid': wid, 'contract': contract});
  Result<NFTIndex> result =
      await Requester.line().path("/nft/index").addParams("contract", contract ?? "").addParams("wid", wid).post<NFTIndex>(NFTIndex());
  console.i(result.origin);
  return result;
}

requestNFTDetail(wid, contract, contractAddress) async {
  Result<Chains> result = await Requester.line()
      .path("/nft/detail")
      .addParams("contract", contract ?? "")
      .addParams("wid", wid)
      .addParams("contractAddress", contractAddress)
      .post<Chains>(Chains());
  console.i(result.origin);
  return result;
}

requestNFTTokenData(from, to, tokenId, contract, contractAddress) async {
  Result<DefaultModel> result = await Requester.line()
      .path("/nft/tokenData")
      .addParams("contract", contract ?? "")
      .addParams("contractAddress", contractAddress)
      .addParams("from", from)
      .addParams("to", to)
      .addParams("value", tokenId)
      .post<DefaultModel>(DefaultModel());
  console.i(result.origin);
  return result;
}

requestMyTokens(wid) async {
  Result<Chains> result = await Requester.line().path("/coin/allCoins").addParams("wid", wid).post<Chains>(Chains());
  console.i(result.origin);

  return result;
}

requestVersion() async {
  Result<UpdateModel> result = await Requester.line().path("/config/version").post<UpdateModel>(UpdateModel());
  console.i(result.origin);
  return result;
}
