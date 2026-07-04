import 'package:go_router/go_router.dart';
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
import '../features/chapters/data/dummy_chapters.dart';
import '../features/chapters/models/chapter.dart';
import '../features/practice/presentation/practice_screen.dart';
import '../features/practice/presentation/practice_result_screen.dart';

/// The application router.
///
/// Route tree:
///
/// ┌─ /                        → SplashScreen        (outside shell)
/// ├─ /login                   → LoginScreen          (outside shell)
/// ├─ /signup                  → SignupScreen         (outside shell)
/// └─ ShellRoute               → AppShell            (persistent nav bar)
///    ├─ /home                 → HomeScreen
///    ├─ /subjects             → SubjectsScreen
///    │   └─ /subjects/:id     → ChaptersScreen
///    ├─ /bookmarks            → BookmarksScreen
///    ├─ /mistakes             → MistakesScreen
///    └─ /progress             → ProgressScreen
final appRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: false,
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
                    final subjectId = state.pathParameters['subjectId'] ?? '';
                    final chapterId = state.pathParameters['chapterId'] ?? '';
                    final chapters = DummyChapters.forSubject(subjectId);
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
                    final subjectId = state.pathParameters['subjectId'] ?? '';
                    final chapterId = state.pathParameters['chapterId'] ?? '';
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
