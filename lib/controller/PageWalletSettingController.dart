import 'package:get/get.dart';

class PageWalletSettingController extends GetxController {
  static final String TAG = "PageWalletSettingController";
  var changed = false.obs;

  toChange() => changed.value = !changed.value;
}
