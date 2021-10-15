import 'package:cube/views/hoverlist/hover_scroll_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

class SectionList extends StatefulWidget {
  final List<int> itemCounts;
  final HeaderBuilder sectionHeaderBuilder;
  final SectionListItemBuilder itemBuilder;
  final SectionListSeparatorBuilder separatorBuilder;
  final ValueChanged onTopChanged;
  final ValueChanged onEndChanged;
  final SectionListOffsetChanged onOffsetChanged;
  final double initialScrollOffset;
  final bool needSafeArea;

  SectionList(
      {@required this.itemCounts,
      @required this.sectionHeaderBuilder,
      @required this.itemBuilder,
      this.separatorBuilder,
      this.onTopChanged,
      this.onEndChanged,
      this.onOffsetChanged,
      this.initialScrollOffset = 0,
      this.needSafeArea = false,
      Key key})
      : assert(itemCounts != null, "itemCounts must not be null"),
        assert(sectionHeaderBuilder != null, "sectionHeaderBuilder must not be null"),
        assert(itemBuilder != null, "itemBuilder must not be null"),
        super(key: key);

  @override
  SectionListState createState() => SectionListState();
}

class SectionListState extends State<SectionList> {
  bool _top = true;
  bool _end = false;
  ScrollController _controller;

  Map<int, int> _headerIndexMap = {};

  jumpTo(double offset) {
    _controller.jumpTo(offset);
  }

  animateTo(
    double offset, {
    @required Duration duration,
    @required Curve curve,
  }) {
    _controller.animateTo(offset, duration: duration, curve: curve);
  }

  @override
  void initState() {
    super.initState();
    _controller = ScrollController(initialScrollOffset: widget.initialScrollOffset);
    if (widget.initialScrollOffset > 0) {
      _top = false;
    }
    _controller.addListener(() {
      double offset = _controller.offset;
      if (widget.onTopChanged != null) {
        bool top = offset <= _controller.position.minScrollExtent;
        if (_top != top) {
          _top = top;
          widget.onTopChanged(_top);
        }
      }
      if (widget.onEndChanged != null) {
        bool end = offset >= _controller.position.maxScrollExtent;
        if (_end != end) {
          _end = end;
          widget.onEndChanged(_end);
        }
      }
      if (widget.onOffsetChanged != null) {
        widget.onOffsetChanged(offset, _controller.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _headerIndexMap.clear();
    return EasyRefresh(
      child: CustomScrollView(
        controller: _controller,
        physics: AlwaysScrollableScrollPhysics(),
        slivers: _buildSlivers(),
      ),
    );
  }

  List<Widget> _buildSlivers() {
    if (widget.needSafeArea) {
      return [SliverSafeArea(sliver: _buildSliverList())];
    } else {
      return [_buildSliverList()];
    }
  }

  _buildSliverList() {
    return SliverList(
        delegate: SliverChildBuilderDelegate((ctx, index) {
      if (_isHeaderIndex(index)) {
        int section = _headerIndexMap[index];
        return widget.sectionHeaderBuilder(ctx, section);
      } else {
        int headerIndex = _headerIndex(index);
        int section = _headerIndexMap[headerIndex];
        int sectionIndex = index - headerIndex;
        if (_isItemIndex(sectionIndex)) {
          int fixIndex = (sectionIndex - 1) ~/ 2;
          return widget.itemBuilder(ctx, SectionIndexPath(section, fixIndex));
        } else {
          int fixIndex = (sectionIndex - 1) ~/ 2;
          bool isLast = fixIndex == widget.itemCounts[section] - 1;
          return widget.separatorBuilder(ctx, SectionIndexPath(section, fixIndex), isLast);
        }
      }
    }, childCount: _itemCounts()));
  }

  _itemCounts() {
    int ret = 0;
    int sectionIndex = 0;
    _headerIndexMap[0] = sectionIndex;
    widget.itemCounts.forEach((element) {
      ret += element * 2;
      ret++;
      sectionIndex++;
      _headerIndexMap[ret] = sectionIndex;
    });
    return ret;
  }

  bool _isHeaderIndex(int index) {
    return _headerIndexMap[index] != null;
  }

  bool _isItemIndex(int sectionIndex) {
    return sectionIndex % 2 != 0;
  }

  int _headerIndex(int index) {
    int ret = 0;
    while (index > 0) {
      if (_headerIndexMap[index] != null) {
        ret = index;
        break;
      }
      index--;
    }
    return ret;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
