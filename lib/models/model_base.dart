import 'package:cube/core/constant.dart';
import 'package:cube/core/core.dart';
import 'package:cube/net/requester.dart';
import 'package:flutter/material.dart';

abstract class Model implements Parser {
  Map<String, dynamic> json;

  Model();

  @mustCallSuper
  Model parser(Map<String, dynamic> json) {
    this.json = json;
    if (this.json != null) {
      parserImpl(this.json);
    }
    return this;
  }

  parserImpl(Map<String, dynamic> json);

  Map<String, dynamic> toJson({bool excludeId = true}) {
    return this.json;
  }
}

class DefaultModel extends Model {
  String hash;
  String nonce;
  String inputData;
  String decimal;

  @override
  parserImpl(Map<String, dynamic> json) {
    hash = json.value2Str("hash");
    nonce = json.value2Str("nonce");
    inputData = json.value2Str("inputData");
    decimal = json.value2Str("decimal");
  }
}

class ConfigModel extends Model {
  Map<String, dynamic> config = {};
  List<NameValue> about = [];
  List<Coin> chains = [];
  List<Coin> nftchains = [];
  List<Coin> dappGroups = [];

  @override
  parserImpl(Map<String, dynamic> json) {
    config = json['config'] ?? {};
    about = [];
    List json2 = json.value2List("about");
    json2.forEach((element) {
      about.add(NameValue().parser(element));
    });
    chains = [];
    var json3 = json.value2List('chains');
    if (json3 is List) {
      json3.forEach((element) {
        chains.add(Coin().parser(element));
      });
    }
    nftchains = [];
    var json5 = json.value2List('nftchains');
    if (json5 is List) {
      json5.forEach((element) {
        nftchains.add(Coin().parser(element));
      });
    }
    dappGroups = [];
    var json4 = json.value2List('dappGroups');
    if (json4 is List) {
      json4.forEach((element) {
        dappGroups.add(Coin().parser(element));
      });
    }
  }
}

class Auth extends Model {
  int id;
  String type;
  String password;
  String touchId;
  String faceId;

  @override
  parserImpl(Map<String, dynamic> json) {
    id = json.value2Int('id');
    type = json.value2Str('type');
    password = json.value2Str('password');
    touchId = json.value2Str('touchId');
    faceId = json.value2Str('faceId');
  }

  @override
  Map<String, dynamic> toJson({bool excludeId = true}) {
    final Map<String, dynamic> data = new Map();
    if (!excludeId) {
      data["id"] = this.id;
    }
    data["type"] = this.type;
    data["password"] = this.password;
    data["touchId"] = this.touchId;
    data["faceId"] = this.faceId;
    return data;
  }
}

class Identity extends Model {
  int id;
  String color;
  String wid;
  String name;
  String type;
  String token;
  String privateKey;
  String tokenType;
  int isImport;
  int isBackup;

  @override
  parserImpl(Map<String, dynamic> json) {
    id = json.value2Int('id');
    isImport = json.value2Int('isImport');
    isBackup = json.value2Int('isBackup');
    color = json.value2Str('color');
    wid = json.value2Str('wid');
    name = json.value2Str('name');
    type = json.value2Str('type');
    token = json.value2Str('token');
    privateKey = json.value2Str('privateKey');
    tokenType = json.value2Str('tokenType');
  }

  @override
  Map<String, dynamic> toJson({bool excludeId = true}) {
    Map<String, dynamic> data = new Map();
    if (!excludeId) {
      data["id"] = this.id;
    }
    data["color"] = this.color;
    data["wid"] = this.wid;
    data["token"] = this.token;
    data["privateKey"] = this.privateKey;
    data["tokenType"] = this.tokenType;
    data["name"] = this.name;
    data["type"] = this.type;
    data["isImport"] = this.isImport;
    data["isBackup"] = this.isBackup;
    return data;
  }
}

class Coin extends Model {
  int id;
  String wid;
  String contract;
  String contractAddress;
  String token = '';
  String tokenType = '';

  String chainName;
  bool showUserAllCoins;
  String name;
  String symbol;
  String color;

  String address;
  String publicKey;
  String privateKey;
  String icon;
  String detail;

  String tokenID;
  String status;
  String csUnit;
  String totalPrice;

  String balance;
  String netUsed;
  String netLimit;
  String energyUsed;
  String energyLimit;

  String mainValue;
  String price;
  String value;
  String extra;
  String note;
  String floorPrice;
  String img;
  String madeby;
  List<NameValue> attributes;

  bool selected;
  bool canAction = true;
  bool isHas;

  String assetName;

  @override
  parserImpl(Map<String, dynamic> json) {
    id = json.value2Int("id");
    wid = json.value2Str("wid");
    contract = json.value2Str('contract');
    if (strIsEmpty(this.contract)) {
      this.contract = "0x";
    }
    color = json.value2Str('color');
    chainName = json.value2Str('chainName');
    showUserAllCoins = json.value2Bool('showUserAllCoins');
    name = json.value2Str('name');
    symbol = json.value2Str('symbol');
    address = json.value2Str('address');
    contractAddress = json.value2Str('contractAddress');
    publicKey = json.value2Str('publicKey');
    privateKey = json.value2Str('privateKey');
    icon = json.value2Str('icon');
    detail = json.value2Str('detail');
    balance = json.value2Str('balance');
    netUsed = json.value2Str('netUsed');
    netLimit = json.value2Str('netLimit');
    energyUsed = json.value2Str('energyUsed');
    energyLimit = json.value2Str('energyLimit');

    mainValue = json.value2Str('mainValue');
    price = json.value2Str('price');
    value = json.value2Str('value');
    extra = json.value2Str('extra');
    note = json.value2Str('note');
    floorPrice = json.value2Str('floorPrice');
    canAction = json.value2Bool('canAction');
    selected = json.value2Bool('selected');
    img = json.value2Str("img");
    madeby = json.value2Str("madeby");

    tokenID = json.value2Str("tokenID");
    if (strIsEmpty(tokenID)) {
      tokenID = json.value2Str("tokenId");
    }
    price = json.value2Str("price");
    totalPrice = json.value2Str("totalPrice");
    balance = json.value2Str("balance");
    status = json.value2Str("status");
    csUnit = json.value2Str("csUnit");
    String temp = json.value2Str("isHas");
    isHas = temp == '1';
    var json2 = json.value2List('attributes');
    if (json2 is List) {
      attributes = [];
      json2.forEach((element) {
        attributes.add(NameValue().parser(element));
      });
    }

    assetName = json.value2Str("assetName");
  }

  @override
  Map<String, dynamic> toJson({bool excludeId = true}) {
    final Map<String, dynamic> data = new Map();
    if (!excludeId) {
      data["id"] = this.id;
    }
    data["wid"] = this.wid;
    data["color"] = this.color != null ? this.color : BeeColors.blue.toHexString();
    data["address"] = this.address;
    data["publicKey"] = this.publicKey;
    data["privateKey"] = this.privateKey;
    data["token"] = this.token;
    data["tokenType"] = this.tokenType;
    data["tokenID"] = this.tokenID;
    data["assetName"] = this.assetName;

    data["contract"] = this.contract;
    data["contractAddress"] = this.contractAddress;
    data["symbol"] = this.symbol;
    data["name"] = this.name;

    data["icon"] = this.icon;
    data["balance"] = this.balance;
    data["netUsed"] = this.netUsed;
    data["netLimit"] = this.netLimit;
    data["energyUsed"] = this.energyUsed;
    data["energyLimit"] = this.energyLimit;

    data["totalPrice"] = this.totalPrice;
    data["price"] = this.price;
    data["value"] = this.value;
    data["extra"] = this.extra;
    data["note"] = this.note;
    return data;
  }
}

class CoinBase extends Model {
  @override
  Model parser(Map<String, dynamic> json) {
    return super.parser(json);
  }

  @override
  parserImpl(Map<String, dynamic> json) {
    throw UnimplementedError();
  }
}

class Fees extends Model {
  List<Fee> items;

  @override
  parserImpl(Map<String, dynamic> json) {
    items = [];
    List value2list = json.value2List("items");
    value2list.forEach((element) {
      items.add(Fee().parser(element));
    });
  }
}

class Fee extends Model {
  String fee;
  String contract;
  String gas_price_str = '100000';
  String gas_price = '100000';
  String gas_limit = '210000';
  String time;
  String type;

  @override
  parserImpl(Map<String, dynamic> json) {
    fee = json.value2Str("fee");
    contract = json.value2Str("contract");
    gas_price_str = json.value2Str("gas_price_str");
    gas_price = json.value2Str("gas_price");
    gas_limit = json.value2Str("gas_limit");
    time = json.value2Str("time");
    type = json.value2Str("type");
  }
}

class NameValue extends Model {
  String name;
  String value;

  @override
  parserImpl(Map<String, dynamic> json) {
    name = json.value2Str("name");
    value = json.value2Str("value");
  }
}

class SchemeModel extends Model {
  String image;
  String type;
  String title;
  String value;

  @override
  parserImpl(Map<String, dynamic> json) {
    image = json.value2Str("image");
    type = json.value2Str("type");
    title = json.value2Str("title");
    value = json.value2Str("value");
  }
}

class UpdateModel extends Model {
  num vCode;
  String vName;
  String vNote;
  bool force;
  String url;

  @override
  parserImpl(Map<String, dynamic> json) {
    vCode = json.value2Num('vCode');
    vName = json.value2Str('vName');
    vNote = json.value2Str('vNote');
    url = json.value2Str('downUrl');
    force = json.value2Bool('needUpdate');
  }
}

class StringListModel extends Model {
  List<String> items;

  @override
  parserImpl(Map<String, dynamic> json) {
    var temp = json.value2List('items');
    if (temp is List) {
      items = [];
      temp.forEach((el) {
        items.add('$el');
      });
    }
  }
}

class TabModel {
  String name;
  String key;
  String message;

  TabModel.create(name, key, {message}) {
    this.name = name;
    this.key = key;
    this.message = message;
  }
}

class Word extends Model {
  int id;
  String word;
  String language;

  @override
  parserImpl(Map<String, dynamic> json) {
    id = json.value2Int('id');
    word = json.value2Str('word');
    language = json.value2Str('language');
  }
}
