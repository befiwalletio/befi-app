import 'dart:convert';
import 'dart:io';

import 'package:bee_encryption/bee_encryption.dart';
import 'package:cube/core/constant.dart';
import 'package:cube/core/core.dart';
import 'package:cube/net/cookies.dart';
import 'package:cube/utils/utils_console.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;

class Requester {
  static RequestConfig _config;

  static init(RequestConfig config) {
    _config = config;
  }

  static Requester line({baseUrl = "", tag}) {
    if (_config == null) {
      throw Exception("The config isnull, place call init before");
    }
    return Requester(baseUrl, tag);
  }

  static const String CONTENT_TYPE_PRIMARY = "application";
  static const String CONTENT_TYPE_JSON = "json";
  String baseUrl;
  String _method;
  String _path = "";
  Map<String, dynamic> _headers = {};
  Map<String, dynamic> _params = {};

  BaseOptions _baseOptions;
  CancelToken _cancelToken;
  ResponseHandler _responseHandler;
  Dio _dio;
  var _tag;

  Result _RESULT;

  Requester(url, tag) {
    _tag = tag;
    baseUrl = url ?? "";
    if (baseUrl == "") {
      baseUrl = _config.baseUrl;
    }
    _responseHandler = _config.responseHandler;
    if (_responseHandler == null) {
      _responseHandler = ResponseHandler();
    }
    ResponseType responseType = ResponseType.json;
    if (_config.responseType == ResponseType2.stream) {
      responseType = ResponseType.stream;
    } else if (_config.responseType == ResponseType2.bytes) {
      responseType = ResponseType.bytes;
    }
    String contentType = "$CONTENT_TYPE_PRIMARY/$CONTENT_TYPE_JSON";
    if (_config.contentType == ContentType2.text) {
      contentType = "x-www-form-urlencoded/text";
    }
    _baseOptions = BaseOptions(
        connectTimeout: _config.connectTime,
        receiveTimeout: _config.receiveTime,
        responseType: responseType,
        contentType: contentType,
        baseUrl: baseUrl,
        receiveDataWhenStatusError: true,
        validateStatus: (op) {
          return true;
        });
    _dio = Dio(_baseOptions);
    _dio.interceptors.add(MessageInterceptor());
  }

  Requester path(String path) {
    _path = path;
    return this;
  }

  Requester addParams(String key, String value) {
    if (key != null) {
      _params[key] = value;
    }
    return this;
  }

  Requester addMapParams(Map<String, dynamic> map) {
    _params.addAll(map);
    return this;
  }

  Requester addHeader(String key, String value) {
    if (key != null) {
      _headers[key] = value;
    }
    return this;
  }

  cancel() {
    if (_cancelToken != null) {
      _cancelToken.cancel();
    }
  }

  Future<Result<T>> post<T extends Parser>(T d) async {
    _method = 'POST';
    _dio.options.headers = await matchHeaders();
    try {
      Response response = await _dio.post(_path, data: _params, cancelToken: _cancelToken = CancelToken());
      _handleResponse<T>(response, d);
    } catch (e) {
      _handleResponse<T>(null, d);
      print(e);
    }
    if (_RESULT.code != 0) {
      showWarnBar(_RESULT.msg, snackPosition: SnackPosition.BOTTOM);
    }
    return _RESULT;
  }

  Future<Result<T>> get<T extends Parser>(T d) async {
    _method = 'GET';
    _dio.options.headers = await matchHeaders();
    try {
      Response response = await _dio.get(_path,
          queryParameters: _params,
          cancelToken: _cancelToken = CancelToken(),
          options: Options(
              receiveDataWhenStatusError: true,
              validateStatus: (status) {
                return true;
              }));
      _handleResponse<T>(response, d);
    } catch (e) {
      print(e);
    }
    return _RESULT;
  }

  _handleResponse<T extends Parser>(Response response, T d) {
    _RESULT = Result<T>();
    _RESULT.tag = _tag;

    if (response == null) {
      _RESULT.code = 400;
      _RESULT.msg = ('CommonNetworError'.tr).replaceAll("{?}", '400');
    } else if (response.statusCode != 200) {
      _RESULT.code = response.statusCode;
      _RESULT.msg = ('CommonNetworError1'.tr).replaceAll("{?}", '${response.statusCode}');
    } else {
      var decode = response.data;
      if (!(response.data is Map)) {
        decode = json.decode(response.data.toString());
      }
      _RESULT.code = decode['code'];
      _RESULT.msg = decode['msg'];
      _RESULT.origin = decode;
      _responseHandler.parser(decode['data'], d);
      _RESULT.result = d;
    }
  }

  Future<Map<String, dynamic>> getBasicParam() async {
    Map<String, dynamic> basicParam = {};
    return basicParam;
  }

  getHeaders() async {
    if (_headers == null) {
      _headers = {};
    }
    return _headers;
  }

  matchHeaders() async {
    String nonce = '${DateTime.now().millisecondsSinceEpoch}';
    String sign = await BeeEncryption.signForHttp(_params, nonce, Constant.APPKEY);
    String cookies = Cookies().getDeviceCookie({"sign": sign, "nonce": nonce});

    Map<String, dynamic> allHeaders = {
      "Connection": "Keep-Alive",
      "Accept-Language": 'EN',
      "Cookie": cookies,
      "BEE-CC-DEVICE": cookies,
      "BEE-CC-UA": Cookies().getDeviceUA(),
    };
    var headers = await getHeaders();
    allHeaders.addAll(headers);
    return allHeaders;
  }
}

class Result<T> {
  var tag;
  String msg;
  num code = 200;
  Map<String, dynamic> origin;
  T result;
}

class ResponseHandler {
  parser<T extends Parser>(data, T d) {
    d.parser(data);
    return data;
  }
}

class RequestConfig {
  String baseUrl;
  int connectTime;
  int receiveTime;
  ContentType2 contentType;
  ResponseType2 responseType;
  ResponseHandler responseHandler;

  RequestConfig(
      {this.baseUrl,
      this.connectTime = 15000,
      this.receiveTime = 15000,
      this.contentType = ContentType2.text,
      this.responseType = ResponseType2.json,
      this.responseHandler}
  );
}

enum ResponseType2 { json, stream, bytes }

enum ContentType2 { text, json }

class Parser {
  void parser(Map<String, dynamic> data) {}
}

class MessageInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    super.onResponse(response, handler);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    super.onRequest(options, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    super.onError(err, handler);
  }
}

downLoad(File savePath, String uri, String pathName, {ProgressCallback onReceiveProgress}) async {
  try {
    Response response = await Dio().get(
      uri,
      onReceiveProgress: onReceiveProgress,
      options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) {
            return status < 500;
          }),
    );
    print(response.headers);
    var raf = savePath.openSync(mode: FileMode.write);
    raf.writeFromSync(response.data);
    await raf.close();
  } catch (e) {
    print(e);
  }
}
