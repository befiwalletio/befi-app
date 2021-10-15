import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class FlexSpaceBar extends StatefulWidget {
  const FlexSpaceBar({
    Key key,
    this.title,
    this.background,
    this.centerTitle,
    this.titlePadding,
    this.collapseMode = CollapseMode.parallax,
    this.stretchModes = const <StretchMode>[StretchMode.zoomBackground],
  })  : assert(collapseMode != null),
        super(key: key);

  final Widget title;

  final Widget background;

  final bool centerTitle;

  final CollapseMode collapseMode;

  final List<StretchMode> stretchModes;

  final EdgeInsetsGeometry titlePadding;

  static Widget createSettings({
    double toolbarOpacity,
    double minExtent,
    double maxExtent,
    double currentExtent,
    Widget child,
  }) {
    assert(currentExtent != null);
    return FlexibleSpaceBarSettings(
      toolbarOpacity: toolbarOpacity ?? 1.0,
      minExtent: minExtent ?? currentExtent,
      maxExtent: maxExtent ?? currentExtent,
      currentExtent: currentExtent,
      child: child,
    );
  }

  @override
  _FlexibleSpaceBarState createState() => _FlexibleSpaceBarState();
}

class _FlexibleSpaceBarState extends State<FlexSpaceBar> {
  bool _getEffectiveCenterTitle(ThemeData theme) {
    if (widget.centerTitle != null) return widget.centerTitle;
    assert(theme.platform != null);
    switch (theme.platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return false;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return true;
    }
  }

  Alignment _getTitleAlignment(bool effectiveCenterTitle) {
    if (effectiveCenterTitle) return Alignment.bottomCenter;
    final TextDirection textDirection = Directionality.of(context);
    assert(textDirection != null);
    switch (textDirection) {
      case TextDirection.rtl:
        return Alignment.bottomRight;
      case TextDirection.ltr:
        return Alignment.bottomLeft;
    }
  }

  double _getCollapsePadding(double t, FlexibleSpaceBarSettings settings) {
    switch (widget.collapseMode) {
      case CollapseMode.pin:
        return -(settings.maxExtent - settings.currentExtent);
      case CollapseMode.none:
        return 0.0;
      case CollapseMode.parallax:
        final double deltaExtent = settings.maxExtent - settings.minExtent;
        return -Tween<double>(begin: 0.0, end: deltaExtent / 4.0).transform(t);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      final FlexibleSpaceBarSettings settings = context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
      assert(
        settings != null,
        'A FlexSpaceBar must be wrapped in the widget returned by FlexSpaceBar.createSettings().',
      );

      final List<Widget> children = <Widget>[];

      final double deltaExtent = settings.maxExtent - settings.minExtent;

      final double t = (1.0 - (settings.currentExtent - settings.minExtent) / deltaExtent).clamp(0.0, 1.0);

      if (widget.background != null) {
        final double fadeStart = math.max(0.0, 1.0 - kToolbarHeight / deltaExtent);
        const double fadeEnd = 1.0;
        assert(fadeStart <= fadeEnd);
        final double opacity = 1.0 - Interval(fadeStart, fadeEnd).transform(t);
        double height = settings.maxExtent;

        if (widget.stretchModes.contains(StretchMode.zoomBackground) && constraints.maxHeight > height) {
          height = constraints.maxHeight;
        }
        children.add(Positioned(
          top: _getCollapsePadding(t, settings),
          left: 0.0,
          right: 0.0,
          height: height,
          child: Opacity(
            alwaysIncludeSemantics: true,
            opacity: opacity,
            child: widget.background,
          ),
        ));

        if (widget.stretchModes.contains(StretchMode.blurBackground) && constraints.maxHeight > settings.maxExtent) {
          final double blurAmount = (constraints.maxHeight - settings.maxExtent) / 10;
          children.add(Positioned.fill(
              child: BackdropFilter(
                  child: Container(
                    color: Colors.transparent,
                  ),
                  filter: ui.ImageFilter.blur(
                    sigmaX: blurAmount,
                    sigmaY: blurAmount,
                  ))));
        }
      }

      if (widget.title != null) {
        final ThemeData theme = Theme.of(context);

        Widget title;
        switch (theme.platform) {
          case TargetPlatform.iOS:
          case TargetPlatform.macOS:
            title = widget.title;
            break;
          case TargetPlatform.android:
          case TargetPlatform.fuchsia:
          case TargetPlatform.linux:
          case TargetPlatform.windows:
            title = Semantics(
              namesRoute: true,
              child: widget.title,
            );
            break;
        }

        if (widget.stretchModes.contains(StretchMode.fadeTitle) && constraints.maxHeight > settings.maxExtent) {
          final double stretchOpacity = 1 - (((constraints.maxHeight - settings.maxExtent) / 100).clamp(0.0, 1.0));
          title = Opacity(
            opacity: stretchOpacity,
            child: title,
          );
        }

        final double opacity = settings.toolbarOpacity;
        if (opacity > 0.0) {
          TextStyle titleStyle = theme.primaryTextTheme.subtitle2;
          final bool effectiveCenterTitle = _getEffectiveCenterTitle(theme);
          final EdgeInsetsGeometry padding = widget.titlePadding ??
              EdgeInsetsDirectional.only(
                start: effectiveCenterTitle ? 0.0 : 72.0,
                bottom: 16.0,
              );
          final double scaleValue = Tween<double>(begin: 1.5, end: 1.2).transform(t);
          final Matrix4 scaleTransform = Matrix4.identity()..scale(1.5, 1.5, 1.5);
          final Alignment titleAlignment = _getTitleAlignment(effectiveCenterTitle);
          children.add(Container(
            padding: padding,
            child: Transform(
              alignment: titleAlignment,
              transform: scaleTransform,
              child: Align(
                alignment: titleAlignment,
                child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                  return Container(
                    width: constraints.maxWidth / 1.5,
                    alignment: titleAlignment,
                    child: title,
                  );
                }),
              ),
            ),
          ));
        }
      }

      return ClipRect(child: Stack(children: children));
    });
  }
}
