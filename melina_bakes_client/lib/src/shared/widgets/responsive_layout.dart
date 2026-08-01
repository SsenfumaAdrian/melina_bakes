
/// Responsive layout builder adapting to screen size.
library;

import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

typedef ResponsiveWidgetBuilder = Widget Function(BuildContext context);

class ResponsiveLayout extends StatelessWidget {
  final ResponsiveWidgetBuilder mobile;
  final ResponsiveWidgetBuilder? tablet;
  final ResponsiveWidgetBuilder? desktop;

  const ResponsiveLayout({super.key, required this.mobile, this.tablet, this.desktop});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        if (w >= UIConstants.desktopBreakpoint && desktop != null) return desktop!(context);
        if (w >= UIConstants.tabletBreakpoint && tablet != null) return tablet!(context);
        return mobile(context);
      },
    );
  }
}

class ConstrainedContent extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  const ConstrainedContent({super.key, required this.child, this.maxWidth});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth ?? UIConstants.maxContentWidth),
        child: child,
      ),
    );
  }
}

extension ResponsiveValue<T> on BuildContext {
  T responsiveValue<T>({required T mobile, T? tablet, T? desktop}) {
    final w = MediaQuery.of(this).size.width;
    if (w >= UIConstants.desktopBreakpoint && desktop != null) return desktop;
    if (w >= UIConstants.tabletBreakpoint && tablet != null) return tablet;
    return mobile;
  }
}
