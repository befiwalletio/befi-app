class JSBridge {
  String id;
  String method;
  Map data;
  Function success;
  Function error;

  JSBridge(this.method, this.data, this.success, this.error);

  static JSBridge fromMap(Map<String, dynamic> map) {
    JSBridge jsonModel = new JSBridge(map['method'], map['data'], map['success'], map['error']);
    return jsonModel;
  }

  @override
  String toString() {
    return "JsBridge: {method: $method, data: $data, success: $success, error: $error}";
  }
}
