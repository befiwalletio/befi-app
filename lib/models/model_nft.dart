import 'package:cube/models/model_base.dart';
import 'package:cube/core/core.dart';

class NFTIndex extends Model {
  List<SchemeModel> banners;
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
    var json3 = json.value2List('banners');
    if (json3 is List) {
      banners = [];
      json3.forEach((element) {
        banners.add(SchemeModel().parser(element));
      });
    }
  }
}
