import 'package:common_utils/common_utils.dart';

class MathCalc {
  num _start;
  num current;
  MathCalc({this.current = 0}) {
    _start = current;
  }

  static MathCalc startWithStr(String start) {
    num temp = NumUtil.getNumByValueStr(start);
    return MathCalc(current: temp);
  }

  static MathCalc startWithInt(int start) {
    return MathCalc(current: start);
  }

  static MathCalc startWithDouble(double start) {
    return MathCalc(current: start);
  }

  static MathCalc start(num start) {
    return MathCalc(current: start);
  }

  MathCalc add(num a) {
    current = NumUtil.add(current, a);
    return this;
  }

  MathCalc addStr(String a) {
    num temp = NumUtil.getNumByValueStr(a);
    current = NumUtil.add(current, temp);
    return this;
  }

  MathCalc subtract(num a) {
    current = NumUtil.subtract(current, a);
    return this;
  }

  MathCalc subtractStr(String a) {
    num temp = NumUtil.getNumByValueStr(a);
    current = NumUtil.subtract(current, temp);
    return this;
  }

  MathCalc multiply(num a) {
    current = NumUtil.multiply(current, a);
    return this;
  }

  MathCalc multiplyStr(String a) {
    num temp = NumUtil.getNumByValueStr(a);
    current = NumUtil.multiply(current, temp);
    return this;
  }

  MathCalc divide(num a) {
    current = NumUtil.divide(current, a);
    return this;
  }

  MathCalc divideStr(String a) {
    num temp = NumUtil.getNumByValueStr(a);
    current = NumUtil.divide(current, temp);
    return this;
  }

  MathCalc reset() {
    current = _start;
    return this;
  }

  @override
  String toString() {
    return current.toString();
  }

  num toNumber() {
    return current;
  }
}
