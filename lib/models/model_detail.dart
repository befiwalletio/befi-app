import 'package:cube/models/model_base.dart';
import 'package:cube/core/core.dart';

class CoinTransModel extends Model {
  List<CoinTrans> items;

  @override
  parserImpl(Map<String, dynamic> json) {
    List value2list = json.value2List("items");
    value2list.forEach((element) {
      if (items == null) {
        items = [];
      }
      items.add(CoinTrans().parser(element));
    });
  }
}

class CoinTrans extends Model {
  String id;
  String time;
  String contract;
  String type; //out in failed
  String status;
  String value;
  String from;
  String to;
  String hash;
  String input;
  String nonce;
  String block;
  String gas;
  String gasPrice;
  String gasLimit;
  String browser;
  List<TransAction> actions;

  @override
  parserImpl(Map<String, dynamic> json) {
    id = json.value2Str('_id');
    time = json.value2Str('timeStr');
    type = json.value2Str('type');
    status = json.value2Str('status');
    value = json.value2Str('value');
    browser = json.value2Str('scanUrl');
    contract = json.value2Str('contract');

    from = json.value2Str('from');
    to = json.value2Str('to');
    hash = json.value2Str('hash');
    input = json.value2Str('input');
    nonce = json.value2Str('nonce');
    block = json.value2Str('blockNumber');
    gas = json.value2Str('gas');
    gasPrice = json.value2Str('gasPrice');
    gasLimit = json.value2Str('gasLimit');
    List value2list = json.value2List("actions");

    value2list.forEach((element) {
      if (actions == null) {
        actions = [];
      }
      actions.add(TransAction().parser(element));
    });
  }
}

class TransAction extends Model {
  @override
  parserImpl(Map<String, dynamic> json) {}
}
