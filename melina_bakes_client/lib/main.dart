
/// Melina Bakes — Flutter Web Application Entry Point.
///
/// Initializes Riverpod, sets up the router, and mounts
/// the root widget with theme support and localization.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/core/router/app_router.dart';
import 'src/core/theme/app_theme.dart';
import 'src/core/theme/theme_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: MelinaBakesApp(),
    ),
  );
}

/// Root application widget.
///
/// Watches the theme mode provider and router provider
/// to rebuild when either changes.
class MelinaBakesApp extends ConsumerWidget {
  const MelinaBakesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Melina Bakes',
      debugShowCheckedModeBanner: false,
      theme: createLightTheme(),
      darkTheme: createDarkTheme(),
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        // Apply responsive constraints wrapper if needed
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
