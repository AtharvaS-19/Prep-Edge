import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';
import 'theme.dart';
import '../shared/constants/app_strings.dart';

/// The root widget of the application.
///
/// Wires [AppTheme] and [routerProvider] together.
/// Converted to [ConsumerWidget] so it can watch [routerProvider], which
/// internally observes [authStateProvider] for route protection.
/// Riverpod's [ProviderScope] wraps this in [main.dart].
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
