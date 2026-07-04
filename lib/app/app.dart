import 'package:flutter/material.dart';
import 'router.dart';
import 'theme.dart';
import '../shared/constants/app_strings.dart';

/// The root widget of the application.
///
/// Wires [AppTheme] and [appRouter] together.
/// Riverpod's [ProviderScope] wraps this in [main.dart].
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
