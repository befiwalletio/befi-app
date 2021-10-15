import 'package:cube/models/model_base.dart';
import 'package:cube/core/core.dart';

class CoinGroup extends Model {
  Coin coin;
  List<Coin> items;

  @override
  parserImpl(Map<String, dynamic> json) {}
}

class Chains extends Model {
  List<Coin> items;

  @override
  parserImpl(Map<String, dynamic> json) {
    var json2 = json['items'];
    if (json2 is List) {
      items = [];
      json2.forEach((element) {
        items.add(Coin().parser(element));
      });
    }
  }
}

class HomeIndex extends Model {
  String wid;
  String totalAmount;
  String totalUnit;
  String csAmount;
  String csUnit;
  List<Coin> items;

  @override
  parserImpl(Map<String, dynamic> json) {
    wid = json.value2Str("wid");
    totalAmount = json.value2Str("totalAmount");
    totalUnit = json.value2Str("totalUnit");
    csAmount = json.value2Str("allTotalPrice");
    csUnit = json.value2Str("csUnit");
    List value2list = json.value2List('items');
    items = [];
    value2list.forEach((element) {
      items.add(Coin().parser(element));
    });
  }
}
