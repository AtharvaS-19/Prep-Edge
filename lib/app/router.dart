import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/shell/app_shell.dart';
import '../features/splash/splash_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/signup_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/subjects/presentation/subjects_screen.dart';
import '../features/chapters/presentation/chapter_dashboard_screen.dart';
import '../features/bookmarks/presentation/bookmarks_screen.dart';
import '../features/mistakes/presentation/mistakes_screen.dart';
import '../features/progress/presentation/progress_screen.dart';
import '../features/chapters/models/chapter.dart';
import '../features/catalog/providers/catalog_provider.dart';
import '../features/practice/presentation/practice_screen.dart';
import '../features/practice/presentation/practice_result_screen.dart';

/// Route tree:
///
/// ┌─ /                        → SplashScreen        (outside shell)
/// ├─ /login                   → LoginScreen          (outside shell)
/// ├─ /signup                  → SignupScreen         (outside shell)
/// └─ ShellRoute               → AppShell            (persistent nav bar)
///    ├─ /home                 → HomeScreen
///    ├─ /subjects             → SubjectsScreen
///    │   └─ /subjects/:id     → ChapterDashboardScreen
///    ├─ /bookmarks            → BookmarksScreen
///    ├─ /mistakes             → MistakesScreen
///    └─ /progress             → ProgressScreen
///
/// Route protection:
/// • Authenticated users who land on `/`, `/login`, or `/signup` are
///   redirected to `/home`.
/// • Unauthenticated users who reach any shell route are redirected to `/login`.
/// • While auth state is still loading the redirect returns null (no change),
///   keeping the user on `/` (splash) until Firebase has responded.

// ── Router provider ────────────────────────────────────────────────────────────

/// Provides the singleton [GoRouter] for the lifetime of the app.
///
/// The router is created once per [ProviderScope] and is disposed alongside it.
/// [_RouterRefreshNotifier] bridges Riverpod's [authStateProvider] stream into
/// a [ChangeNotifier] that GoRouter uses to re-evaluate its redirect.
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterRefreshNotifier(ref);

  final router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    refreshListenable: notifier,
    redirect: (context, state) {
      final authAsync = ref.read(authStateProvider);
      final location = state.uri.toString();

      // While the auth stream hasn't emitted its first value, stay put.
      if (authAsync.isLoading || authAsync.hasError) return null;

      final isAuthenticated = authAsync.value != null;
      final isOnAuthScreen =
          location == '/' || location == '/login' || location == '/signup';

      if (isAuthenticated && isOnAuthScreen) {
        // Signed-in user → send to home.
        return '/home';
      }
      if (!isAuthenticated && !isOnAuthScreen) {
        // Unauthenticated user hitting a protected route → login.
        return '/login';
      }
      return null; // no redirect needed
    },
    routes: [
      // ── Unauthenticated / one-time screens ─────────────────────────────────
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),

      // ── Main application shell ─────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/subjects',
            builder: (context, state) => const SubjectsScreen(),
            routes: [
              // Nested under /subjects so the shell persists during navigation.
              GoRoute(
                path: ':subjectId',
                builder: (context, state) => ChapterDashboardScreen(
                  subjectId: state.pathParameters['subjectId'] ?? '',
                ),
                routes: [
                  GoRoute(
                    path: 'chapters/:chapterId/practice',
                    builder: (context, state) {
                      final subjectId =
                          state.pathParameters['subjectId'] ?? '';
                      final chapterId =
                          state.pathParameters['chapterId'] ?? '';
                      final chapters = ref.read(chaptersForSubjectProvider(subjectId));
                      final chapter = chapters.firstWhere(
                        (c) => c.id == chapterId,
                        orElse: () => const Chapter(
                          id: '',
                          title: '',
                          totalQuestions: 0,
                          completedQuestions: 0,
                        ),
                      );
                      return PracticeScreen(
                        subjectId: subjectId,
                        chapterId: chapterId,
                        chapterTitle: chapter.title,
                      );
                    },
                  ),
                  GoRoute(
                    path: 'chapters/:chapterId/result',
                    builder: (context, state) {
                      final subjectId =
                          state.pathParameters['subjectId'] ?? '';
                      final chapterId =
                          state.pathParameters['chapterId'] ?? '';
                      final extra = state.extra as Map<String, dynamic>?;
                      final chapterTitle =
                          extra?['chapterTitle'] as String? ?? '';
                      final total = extra?['total'] as int? ?? 0;
                      final correct = extra?['correct'] as int? ?? 0;
                      return PracticeResultScreen(
                        subjectId: subjectId,
                        chapterId: chapterId,
                        chapterTitle: chapterTitle,
                        total: total,
                        correct: correct,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/bookmarks',
            builder: (context, state) => const BookmarksScreen(),
          ),
          GoRoute(
            path: '/mistakes',
            builder: (context, state) => const MistakesScreen(),
          ),
          GoRoute(
            path: '/progress',
            builder: (context, state) => const ProgressScreen(),
          ),
        ],
      ),
    ],
  );

  // Dispose the notifier (and its subscription) when the provider is disposed.
  ref.onDispose(() {
    notifier.dispose();
    router.dispose();
  });

  return router;
});

// ── Router refresh notifier ────────────────────────────────────────────────────

/// Bridges [authStateProvider] (a Riverpod stream) into a [ChangeNotifier]
/// that GoRouter's [GoRouter.refreshListenable] can observe.
///
/// Every time Firebase auth state changes, [notifyListeners] is called, causing
/// GoRouter to re-evaluate its redirect callback.
class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Ref ref) {
    // Listen to the auth state stream using Riverpod's own listen mechanism.
    _subscription = ref.listen<AsyncValue<dynamic>>(
      authStateProvider,
      (_, __) => notifyListeners(),
    );
  }

  late final ProviderSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}
