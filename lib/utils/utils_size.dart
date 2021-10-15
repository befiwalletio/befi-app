import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:ui' as ui show window;

double _designW = 360.0;
double _designH = 640.0;
double _designD = 3.0;

class SizeUtil {
  static SizeUtil _util = new SizeUtil();

  SizeUtil();

  static num screenW = 0.0;
  static num screenH = 0.0;
  static num barH = 0;

  double _screenWidth = 0.0;
  double _screenHeight = 0.0;
  double _screenDensity = 0.0;
  double _statusBarHeight = 0.0;
  double _bottomBarHeight = 0.0;
  double _appBarHeight = 0.0;
  MediaQueryData _mediaQueryData;

  _init() {
    MediaQueryData mediaQuery = MediaQueryData.fromWindow(ui.window);
    if (_mediaQueryData != mediaQuery) {
      _mediaQueryData = mediaQuery;
      _screenWidth = mediaQuery.size.width;
      _screenHeight = mediaQuery.size.height;
      _screenDensity = mediaQuery.devicePixelRatio;
      _statusBarHeight = mediaQuery.padding.top;
      _bottomBarHeight = mediaQuery.padding.bottom;
      _appBarHeight = kToolbarHeight;
    }
  }

  static init() {
    if (_util == null) {
      _util = new SizeUtil();
    }
    _util._init();
  }

  static padding({double left = 0, double top = 0, double right = 0, double bottom = 0, double all = -1}) {
    return margin(left: left, right: right, top: top, bottom: bottom, all: all);
  }

  static margin({double left = 0, double top = 0, double right = 0, double bottom = 0, double all = -1}) {
    if (all > -1) {
      return EdgeInsets.only(left: width(all), right: width(all), top: height(all), bottom: height(all));
    }
    return EdgeInsets.only(left: width(left), right: width(right), top: height(top), bottom: height(bottom));
  }

  static width(double value, {bool isPx = false}) {
    if (isPx) {
      return _util._screenWidth == 0.0 ? (value / _designD) : (value * _util._screenWidth / (_designW * _designD));
    }
    return _util._screenWidth == 0.0 ? value : (value * _util._screenWidth / _designW);
  }

  static height(double value, {bool isPx = false}) {
    if (isPx) {
      return _util._screenHeight == 0.0 ? (value / _designD) : (value * _util._screenHeight / (_designH * _designD));
    }

    return _util._screenHeight == 0.0 ? value : (value * _util._screenHeight / _designH);
  }

  static sp(double value) {
    if (_util._screenDensity == 0.0) return value;
    return value * _util._screenWidth / _designW;
  }

  static screenWidth() {
    if (screenW > 0) {
      return screenW;
    }
    screenW = _util._screenWidth;
    return screenW;
  }

  static screenHeight() {
    if (screenH > 0) {
      return screenH;
    }
    screenH = _util._screenHeight;
    return screenH;
  }

  static barHeight() {
    if (barH > 0) {
      return barH;
    }
    barH = _util._statusBarHeight;
    return barH;
  }

  static radius({double topLeft = 0, double topRight = 0, double bottomLeft = 0, double bottomRight = 0, double all = 0}) {
    if (all > 0) {
      return BorderRadius.all(Radius.circular(width(all)));
    }
    return BorderRadius.only(
        topLeft: Radius.circular(width(topLeft)),
        topRight: Radius.circular(width(topRight)),
        bottomLeft: Radius.circular(width(bottomLeft)),
        bottomRight: Radius.circular(width(bottomRight)));
  }
}

class StyleUtil {
  static textStyle({double size = 30, Color color = Colors.black, FontWeight weight = FontWeight.normal}) {
    return TextStyle(fontSize: SizeUtil.sp(size), color: color, fontWeight: weight, decoration: TextDecoration.none);
  }
}
