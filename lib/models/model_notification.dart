import 'package:cube/models/model_base.dart';

class NotificationModel extends Model {
  String title;
  String desc;
  String time;
  bool checked;
  String type;
  String address;

  @override
  parserImpl(Map<String, dynamic> json) {
    throw UnimplementedError();
  }
}
