import 'package:cube/views/hoverlist/hover_scroll_config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'section_list.dart';

import 'hover_header.dart';
import 'hover_header_vm.dart';
import 'hover_offset_info.dart';

class HoveringHeaderList extends StatefulWidget {
  final List<int> itemCounts;
  final HeaderBuilder sectionHeaderBuild;
  final HoverHeaderListItemBuilder itemBuilder;
  final HoverHeaderListSeparatorBuilder separatorBuilder;
  final ValueChanged onTopChanged;
  final ValueChanged onEndChanged;
  final SectionListOffsetChanged onOffsetChanged;
  final double initialScrollOffset;
  final ItemHeightForIndexPath itemHeightForIndexPath;
  final SeparatorHeightForIndexPath separatorHeightForIndexPath;
  final HeaderHeightForSection headerHeightForSection;
  final bool hover;
  final bool needSafeArea;

  HoveringHeaderList(
      {@required this.itemCounts,
      @required this.sectionHeaderBuild,
      @required this.itemBuilder,
      @required this.itemHeightForIndexPath,
      @required this.headerHeightForSection,
      this.separatorHeightForIndexPath,
      this.separatorBuilder,
      this.onTopChanged,
      this.onEndChanged,
      this.onOffsetChanged,
      this.initialScrollOffset = 0,
      this.hover = true,
      this.needSafeArea = false,
      Key key})
      : assert((separatorHeightForIndexPath == null && separatorBuilder == null) || (separatorBuilder != null && separatorHeightForIndexPath != null),
            "separatorHeightForIndexPath 和 separatorBuilder必须同时为null或者同时不为null"),
        assert(itemBuilder != null, "itemBuilder must not be null"),
        assert(itemHeightForIndexPath != null, "itemHeightForIndexPath  must not be null"),
        assert(sectionHeaderBuild != null, "sectionHeaderBuild  must not be null"),
        assert(headerHeightForSection != null, "headerHeightForSection  must not be null"),
        super(key: key);

  @override
  HoveringHeaderListState createState() => HoveringHeaderListState();
}

class HoveringHeaderListState extends State<HoveringHeaderList> {
  double _lastOffset = 0;
  int _hoverOffsetInfoIndex = 0;
  GlobalKey<SectionListState> _sectionListKey = GlobalKey();

  HoveringHeaderVM _hoverVM;

  Map<int, HoveringOffsetInfo> _hoverOffsetInfoMap;

  clean() {
    _hoverOffsetInfoMap = {};
  }

  jumpTo(double offset) {
    _sectionListKey.currentState.jumpTo(offset);
  }

  jumpToIndexPath(SectionIndexPath indexPath) {
    if (_isValidIndexPath(indexPath)) {
      double offset = _computeJumpIndexPathOffset(indexPath);
      jumpTo(offset);
    }
  }

  animateTo(
    double offset, {
    @required Duration duration,
    @required Curve curve,
  }) {
    _sectionListKey.currentState.animateTo(offset, duration: duration, curve: curve);
  }

  animateToIndexPath(
    SectionIndexPath indexPath, {
    @required Duration duration,
    @required Curve curve,
  }) {
    if (_isValidIndexPath(indexPath)) {
      double offset = _computeJumpIndexPathOffset(indexPath);
      animateTo(offset, duration: duration, curve: curve);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.hover) {
      _hoverVM = HoveringHeaderVM();
      _hoverOffsetInfoMap = {};
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.hover) {
      return Stack(
        children: <Widget>[
          _buildSectionList(),
          ChangeNotifierProvider(create: (ctx) {
            return _hoverVM;
          }, child: Consumer(
            builder: (ctx, HoveringHeaderVM hoverVM, child) {
              return HoveringHeader(
                child: hoverVM.child,
                offset: hoverVM.offset,
                visible: hoverVM.show,
              );
            },
          ))
        ],
      );
    } else {
      return _buildSectionList();
    }
  }

  _buildSectionList() {
    return SectionList(
      itemCounts: widget.itemCounts,
      sectionHeaderBuilder: _sectionHeaderBuilder,
      itemBuilder: _itemBuilder,
      separatorBuilder: _separatorBuilder,
      onTopChanged: widget.onTopChanged,
      onEndChanged: widget.onEndChanged,
      onOffsetChanged: _handleOffset,
      initialScrollOffset: widget.initialScrollOffset,
      needSafeArea: widget.needSafeArea,
      key: _sectionListKey,
    );
  }

  Widget _sectionHeaderBuilder(ctx, section) {
    double headerH = widget.headerHeightForSection(section);

    Widget ret = Container(
      height: headerH,
      child: widget.sectionHeaderBuild(ctx, section),
    );

    if (widget.hover) {
      HoveringOffsetInfo info = _hoverOffsetInfoFor(section);
      info.headerHeight = headerH;
      info.header = ret;
      if (_hoverVM.child == null && section == 0) {
        _hoverVM.child = info.header;
      }
    }
    return ret;
  }

  Widget _itemBuilder(ctx, indexPath) {
    double itemH = widget.itemHeightForIndexPath(indexPath);
    if (widget.hover) {
      HoveringOffsetInfo info = _hoverOffsetInfoFor(indexPath.section);
      info.addItemHeight(itemH, indexPath.index);
    }
    return Container(
      height: itemH,
      child: widget.itemBuilder(ctx, indexPath, itemH),
    );
  }

  Widget _separatorBuilder(ctx, indexPath, isLast) {
    if (widget.separatorBuilder == null) {
      return Container();
    }
    double separatorH = widget.separatorHeightForIndexPath(indexPath, isLast);
    if (widget.hover) {
      HoveringOffsetInfo info = _hoverOffsetInfoFor(indexPath.section);
      info.addSeparatorHeight(separatorH, indexPath.index);
    }
    return Container(
      height: separatorH,
      child: widget.separatorBuilder(ctx, indexPath, separatorH, isLast),
    );
  }

  _handleOffset(offset, maxOffset) {
    if (widget.onOffsetChanged != null) {
      widget.onOffsetChanged(offset, maxOffset);
    }

    if (widget.hover == false) return;
    bool show = offset >= 0;
    if (_hoverVM.show != show) {
      _hoverVM.show = show;
    }

    bool upward = offset - _lastOffset > 0;
    _lastOffset = offset;

    HoveringOffsetInfo offsetInfo;

    if (_hoverOffsetInfoMap.length > _hoverOffsetInfoIndex) {
      offsetInfo = _hoverOffsetInfoMap[_hoverOffsetInfoIndex];
      if (upward) {
        if (offset < offsetInfo.startOffset) {
          if (_hoverVM.offset != 0) {
            _hoverVM.update(offsetInfo.header, 0);
          }
        } else if (offset > offsetInfo.endOffset) {
          _hoverOffsetInfoIndex++;
          if (_hoverOffsetInfoIndex >= _hoverOffsetInfoMap.length) {
            _hoverOffsetInfoIndex = _hoverOffsetInfoMap.length - 1;
          }
          HoveringOffsetInfo nextInfo = _hoverOffsetInfoMap[_hoverOffsetInfoIndex];
          _hoverVM.update(nextInfo.header, 0);
        } else {
          _hoverVM.update(offsetInfo.header, offsetInfo.startOffset - offset);
        }
      } else {
        if (offset >= offsetInfo.startOffset) {
          _hoverVM.update(offsetInfo.header, offsetInfo.startOffset - offset);
        } else if (offset >= offsetInfo.sectionStartOffset) {
          if (_hoverVM.offset != 0) {
            _hoverVM.update(offsetInfo.header, 0);
          }
        } else {
          _hoverOffsetInfoIndex--;
          if (_hoverOffsetInfoIndex < 0) {
            _hoverOffsetInfoIndex = 0;
          }
          HoveringOffsetInfo prevInfo = _hoverOffsetInfoMap[_hoverOffsetInfoIndex];
          _hoverVM.update(prevInfo.header, prevInfo.startOffset - offset);
        }
      }
    }
  }

  HoveringOffsetInfo _hoverOffsetInfoFor(int section) {
    HoveringOffsetInfo info = _hoverOffsetInfoMap[section];
    if (info == null) {
      HoveringOffsetInfo prevInfo = _hoverOffsetInfoMap[section - 1];
      if (prevInfo != null) {
        info = HoveringOffsetInfo(prevInfo.endOffset);
      } else {
        info = HoveringOffsetInfo(0);
      }
      _hoverOffsetInfoMap[section] = info;
    }
    return info;
  }

  bool _isValidIndexPath(SectionIndexPath indexPath) {
    if (indexPath == null) return false;
    int section = indexPath.section;
    if (section >= widget.itemCounts.length || indexPath.index >= widget.itemCounts[section]) return false;
    return true;
  }

  _computeJumpIndexPathOffset(SectionIndexPath indexPath) {
    int section = indexPath.section;
    double offset = 0;
    for (var i = 0; i <= section; i++) {
      if (widget.hover == false || i != section) {
        double headerH = widget.headerHeightForSection(i);
        offset += headerH;
      }
      int counts = widget.itemCounts[i];
      int itemCount;
      if (i == section) {
        itemCount = indexPath.index + 1;
      } else {
        itemCount = counts;
      }
      for (var j = 0; j < itemCount; j++) {
        if (j == itemCount - 1 && i == section) {
        } else {
          SectionIndexPath tempIndexPath = SectionIndexPath(i, j);
          double itemH = widget.itemHeightForIndexPath(tempIndexPath);
          double separatorH = 0;
          if (widget.separatorHeightForIndexPath != null) {
            separatorH = widget.separatorHeightForIndexPath(tempIndexPath, j == counts - 1);
          }
          offset += itemH + separatorH;
        }
      }
    }
    return offset;
  }
}
