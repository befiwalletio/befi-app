import 'package:cube/application.dart';
import 'package:cube/core/constant.dart';
import 'package:cube/utils/utils_sp.dart';

class Cookies {
  static final _instance = Cookies._internal();

  factory Cookies() => _instance;

  Cookies._internal();

  getDeviceCookie(extra) {
    var language = SPUtils().getString(Constant.LANGUAGE);
    var cs = SPUtils().getString(Constant.CS);
    var wid = SPUtils().getString(Constant.CUSTOM_WID) ?? '';
    String platform = "platform=${Application.getPlatform()};";
    String client_v = "client_v=${Global.CLIENT_V};";
    String client_c = "client_c=${Global.CLIENT_C};";
    String model = "model=${Global.MODEL};";
    String imei = "imei=${Global.IMEI};";
    String resolution = "resolution=${Global.RESOLUTION};";
    String network = "network=${Global.NETWORK};";
    String mac = 'mac=${Global.MAC};';
    String platfom_v = "platfom_v=${Global.PLATFORM_V};";
    String source = 'source=${Global.SOURCE}';
    String appid = 'appid=${Constant.APPID};';
    String cs2 = 'cs=${cs ?? 'USD'};';
    String language2 = 'language=${language ?? 'en'};';
    String nonce = 'nonce=${extra != null ? extra['nonce'] : ''};';
    String sign = 'net_sign=${extra != null ? extra['sign'] : ''};';
    String wid2 = 'wid=${wid};';

    return "$language2$cs2$platform$client_v$client_c$model$imei$resolution$network$mac$platfom_v$source$appid$nonce$sign";
  }

  getDeviceUA() {
    String product = "BeePay";
    String version = Global.CLIENT_V;
    String device = Application.getPlatform();
    String os = Application.getPlatform();
    String OSVersion = Global.PLATFORM_V;
    String lang = SPUtils().getString(Constant.LANGUAGE) ?? 'en';
    String platform = Application.getPlatform();
    String client_v = Global.CLIENT_V;
    String client_c = Global.CLIENT_C;
    String site = Global.SITE;
    String source = Global.SOURCE;
    String deviceId = Global.DEVICE_ID;
    String resolution = Global.RESOLUTION;
    String renderingEngine = "native";
    String renderingEngineVersion = "1.0";
    var cs = SPUtils().getString(Constant.CS) ?? 'USD';
    var wid = SPUtils().getString(Constant.CUSTOM_WID) ?? '';

    return "$product/$version ($device;$os;$OSVersion;$lang;$cs;$platform;$client_v;$client_c;$site;$source;$deviceId;$resolution;${Global.NETWORK};) $renderingEngine/$renderingEngineVersion";
  }

  getUserCookie(Map<String, dynamic> data) {}
}
