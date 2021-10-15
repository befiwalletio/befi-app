import 'package:flutter/material.dart';

class HoveringOffsetInfo {
  final double sectionStartOffset;
  Widget _header;
  double _headerH = 0;
  double _totalContentH = 0;
  bool _recordedHeaderH = false;
  bool _copyedHeader = false;
  int _itemIndex = -1;
  int _separatorIndex = -1;

  HoveringOffsetInfo(this.sectionStartOffset);

  Widget get header => _header;

  set header(Widget header) {
    if (_copyedHeader) return;
    _header = header;
    _copyedHeader = true;
  }

  set headerHeight(double headerH) {
    if (_recordedHeaderH) return;
    _headerH = headerH;
    _recordedHeaderH = true;
  }

  bool get recordedHeader => _recordedHeaderH;

  int get itemIndex => _itemIndex;

  int get separatorIndex => _separatorIndex;

  double get startOffset => _totalContentH + sectionStartOffset;

  double get endOffset => startOffset + _headerH;

  addItemHeight(double itemHeight, int index) {
    if (_itemIndex >= index) return;
    _totalContentH += itemHeight;
    _itemIndex = index;
  }

  addSeparatorHeight(double separatorHeight, int index) {
    if (_separatorIndex >= index) return;
    _totalContentH += separatorHeight;
    _separatorIndex = index;
  }
}
