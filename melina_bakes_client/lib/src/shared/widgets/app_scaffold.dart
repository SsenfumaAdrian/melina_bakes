
/// Consistent scaffold wrapper for all screens.
library;

import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool centerTitle;
  final bool extendBodyBehindAppBar;
  final PreferredSizeWidget? bottom;
  final Color? backgroundColor;
  final bool showBackButton;

  const AppScaffold({
    super.key, required this.body, this.title, this.actions, this.leading,
    this.bottomNavigationBar, this.floatingActionButton, this.floatingActionButtonLocation,
    this.centerTitle = false, this.extendBodyBehindAppBar = false, this.bottom,
    this.backgroundColor, this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return Scaffold(
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      appBar: title != null ? AppBar(
        title: Text(title!), centerTitle: centerTitle,
        leading: leading ?? (canPop && showBackButton ? const BackButton() : null),
        actions: actions, bottom: bottom,
      ) : null,
      body: SafeArea(child: body),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}
