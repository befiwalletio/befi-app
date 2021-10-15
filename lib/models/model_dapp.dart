import 'package:cube/models/model_base.dart';
import 'package:cube/core/core.dart';

class Dapp extends Model {
  String coin;
  String icon;
  String url;
  String desc;
  String name;
  String chain;

  @override
  parserImpl(Map<String, dynamic> json) {
    coin = json.value2Str('coin');
    url = json.value2Str('url');
    desc = json.value2Str('desc');
    name = json.value2Str('name');
    icon = json.value2Str('icon');
    chain = json.value2Str('chain');
  }
}

class DappGroup extends Model {
  String chain;
  List<Dapp> items;

  @override
  parserImpl(Map<String, dynamic> json) {
    chain = json.value2Str("chain");
    var json2 = json['items'];

    if (json2 is List) {
      items = [];
      json2.forEach((element) {
        items.add(Dapp().parser(element));
      });
    }
  }
}

class Dapps extends Model {
  String condition;
  List<Dapp> items;
  List<Dapp> hots;
  Map<String, List<Dapp>> groups = {};
  List<SchemeModel> banners;

  @override
  parserImpl(Map<String, dynamic> json) {
    condition = json.value2Str("condition");
    Map<String, dynamic> json1 = json['groups'];
    json1?.forEach((key, value) {
      var tempItems = json1.value2List(key);
      if (tempItems is List) {
        List<Dapp> temp = [];
        tempItems.forEach((element) {
          temp.add(Dapp().parser(element));
        });
        groups[key] = temp;
      }
    });

    var json2 = json.value2List('items');
    if (json2 is List) {
      items = [];
      json2.forEach((element) {
        items.add(Dapp().parser(element));
      });
    }
    var json3 = json.value2List('banners');
    if (json3 is List) {
      banners = [];
      json3.forEach((element) {
        banners.add(SchemeModel().parser(element));
      });
    }
    var json4 = json.value2List('hots');
    if (json4 is List) {
      hots = [];
      json4.forEach((element) {
        hots.add(Dapp().parser(element));
      });
    }
  }
}
