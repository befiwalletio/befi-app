import 'package:cube/utils/utils_size.dart';
import 'package:cube/views/flutter/expansion_panel.dart';
import 'package:flutter/material.dart' hide ExpansionPanelList, ExpansionPanel;

class ExpansionPanelItem {
  final String headerText;
  final Widget body;
  bool isExpanded;

  ExpansionPanelItem({
    this.headerText,
    this.body,
    this.isExpanded,
  });
}
