# exam_prep_app — Build Progress

## Project Info
- **App name:** PrepEdge
- **Stack:** Flutter (Stable) · Riverpod · GoRouter · Google Fonts (Inter) · Material 3
- **Architecture:** Feature-first (lib/features/, lib/shared/, lib/app/)
- **Backend:** None yet (Firebase planned for later phase)
- **Primary color:** #2563EB · Background: #FFFFFF · Font: Inter

---

## ✅ Phase 0 — Foundation

### `lib/main.dart`
- Entry point · wraps `App()` in `ProviderScope`

### `lib/app/app.dart`
- `class App extends StatelessWidget`
- `MaterialApp.router` wired to `AppTheme.light` and `appRouter`

### `lib/app/router.dart`
- `final appRouter = GoRouter(...)`
- Routes: `/` → Splash, `/login` → Login, `/signup` → Signup
- `ShellRoute` → `AppShell` wrapping: `/home`, `/subjects`, `/bookmarks`, `/mistakes`, `/progress`
- Nested under `/subjects/:subjectId`: `chapters/:chapterId/practice` → `PracticeScreen`, `chapters/:chapterId/result` → `PracticeResultScreen`
- Result screen receives `extra: {chapterTitle, total, correct}` via GoRouter

### `lib/app/theme.dart`
- `abstract final class AppTheme` · `static ThemeData get light`
- Defines: `_colorScheme`, `_textTheme` (Inter via GoogleFonts), `_appBarTheme`, `_elevatedButtonTheme`, `_outlinedButtonTheme`, `_textButtonTheme`, `_inputDecorationTheme`, `_cardTheme`, `_dividerTheme`, `_progressIndicatorTheme`

### `lib/shared/constants/app_colors.dart`
- `abstract final class AppColors`
- Groups: Brand (primary/primaryLight/primaryDark), Surface (background/cardBackground/cardBackgroundAlt), Text (textPrimary/Secondary/Tertiary/OnPrimary), Border, Status (success/error/warning + light variants), Progress, Divider, Icon, Subject accents (physicsAccent/chemistryAccent/mathAccent/biologyAccent)

### `lib/shared/constants/app_spacing.dart`
- `abstract final class AppSpacing`
- 8pt grid scale: xxs(4) xs(8) sm(12) md(16) lg(20) xl(24) xxl(32) xxxl(40) xxxxl(48)
- Named aliases: `screenHorizontal`(24), `screenVertical`(32), `fieldGap`(16), `cardGap`(12), `cardPadding`(16), `buttonHeight`(56), `buttonHeightSm`(44)

### `lib/shared/constants/app_radius.dart`
- `abstract final class AppRadius`
- Values: xs(6) sm(8) md(12) lg(16) xl(20) xxl(24) full(999)
- `BorderRadius` shortcuts: `radiusXs` through `radiusFull`

### `lib/shared/constants/app_strings.dart`
- `abstract final class AppStrings`
- Groups: App (appName='PrepEdge', appTagline), Splash, Login, Signup, Form fields, Home, Quick access cards, Divider

### `lib/shared/widgets/primary_button.dart`
- `class PrimaryButton extends StatelessWidget`
- Props: `label`, `onPressed`, `isLoading`(bool), `isFullWidth`(bool, default true), `icon`(IconData?)
- Shows spinner when `isLoading`, disables when `onPressed == null`

### `lib/shared/widgets/custom_text_field.dart`
- `class CustomTextField extends StatefulWidget`
- Props: `controller`, `labelText`, `hintText`, `obscureText`, `keyboardType`, `prefixIcon`, `suffixIcon`, `textInputAction`, `onFieldSubmitted`, `focusNode`, `readOnly`, `onTap`
- Private `_PasswordToggle` widget for password visibility toggle

### `lib/shared/widgets/page_heading.dart`
- `class PageHeading extends StatelessWidget`
- Props: `title`(required), `subtitle`(optional)
- Large bold title (28px w700) + secondary subtitle (15px w400)

### `lib/shared/widgets/app_logo.dart`
- `class AppLogo extends StatelessWidget`
- Props: `size`(default 56), `showLabel`, `showTagline`
- Private `_LogoMark` renders blue square with white 'P'

### `lib/shared/widgets/loading_indicator.dart`
- `class LoadingIndicator extends StatelessWidget`
- Props: `size`(default 24)
- Centred `CircularProgressIndicator` in brand primary color

---

## ✅ Phase 1 — Authentication UI

### `lib/features/splash/splash_screen.dart`
- `class SplashScreen extends StatefulWidget`
- `initState` → `_navigateAfterDelay()` → `Future.delayed(2000ms)` → `context.go('/login')`
- Layout: centred `AppLogo(showTagline: false)` + tagline text below

### `lib/features/auth/screens/login_screen.dart`
- `class LoginScreen extends StatefulWidget`
- Controllers: `_emailController`, `_passwordController`
- `_onLogin()` → `context.go('/home')` · `_onSignUp()` → `context.push('/signup')`
- Layout: AppBar with back button, `PageHeading`, email + password `CustomTextField`, forgot password `TextButton`, `PrimaryButton`, `_OrDivider`, `_SignUpPrompt`

### `lib/features/auth/screens/signup_screen.dart`
- `class SignupScreen extends StatefulWidget`
- Controllers: `_nameController`, `_emailController`, `_passwordController`, `_confirmPasswordController`
- `_onCreate()` → `context.go('/home')` · `_onLogin()` → `context.pop()`
- Layout: mirrors login with 4 fields + `_LoginPrompt`

---

## ✅ Phase 1.5 — Navigation Shell

### `lib/features/shell/app_shell.dart`
- `class AppShell extends StatefulWidget` · takes `required Widget child`
- `_destinations`: 5 `_TabDestination` entries — Home(`/home`), Subjects(`/subjects`), Bookmarks(`/bookmarks`), Mistakes(`/mistakes`), Progress(`/progress`)
- `_locationToIndex(String location)` — syncs bar to programmatic navigation
- `_onTabTapped(int index)` — no-op if already active, else `setState + context.go(path)`
- `_AppNavigationBar` — Material 3 `NavigationBar`, height 64, `indicatorColor: primaryLight`, rounded indicator shape

### `lib/features/home/screens/home_screen.dart`
- `class HomeScreen extends StatelessWidget` (no Scaffold — shell provides it)
- `_HomeHeader` — greeting + avatar button
- `_ContinuePracticingCard` — blue card with `_Badge`, chapter title, progress bar, continue button
- `_QuickAccessGrid` — 2-column grid of `_QuickAccessCard` widgets
- Quick access taps: Subjects→`/subjects`, Bookmarks→`/bookmarks`, Mistakes→`/mistakes`, Progress→`/progress`

---

## ✅ Phase 2 — Subject System

### `lib/features/subjects/models/subject_model.dart`
- `enum ExamStream { engineering, medical }` · `.label` getter
- `class SubjectModel` — props: `id`, `name`, `stream`, `icon`, `accentColor`, `totalQuestions`, `examTags`
- Computed: `formattedQuestions` (formats to '1.2k questions')

### `lib/features/subjects/data/subjects_data.dart`
- `abstract final class SubjectsData`
- `static const List<SubjectModel> all` — 6 subjects: eng_physics, eng_chemistry, eng_mathematics, med_physics, med_chemistry, med_biology
- `static List<SubjectModel> forStream(ExamStream)` — filters by stream
- `static SubjectModel? findById(String id)`

### `lib/features/subjects/screens/subjects_screen.dart`
- `class SubjectsScreen extends StatefulWidget`
- State: `ExamStream _selectedStream` (default engineering)
- `_onStreamChanged(ExamStream)` → `setState`
- `_onSubjectTapped(SubjectModel)` → `context.push('/subjects/${subject.id}')`
- `_StreamSelector` — pill toggle with `AnimatedContainer` per option
- `_SubjectList` — `ListView.separated` of `_SubjectCard`
- `_SubjectCard` — icon container + name + question count + exam tags (`_ExamTag`) + chevron
- `AnimatedSwitcher` (180ms) on list when stream changes

---

## ✅ Phase 3 — Chapter Dashboard

### `lib/features/chapters/models/chapter.dart`
- `class Chapter` (immutable, const-constructible)
- Props: `id`, `title`, `totalQuestions`, `completedQuestions`, `isBookmarked`(future-ready)
- Computed: `progress`(double 0–1), `progressPercent`(int), `isStarted`(bool), `isCompleted`(bool), `ctaLabel`('Start'/'Continue'/'Review'), `remainingLabel`

### `lib/features/chapters/data/dummy_chapters.dart`
- `abstract final class DummyChapters`
- `static const Map<String, List<Chapter>> _bySubject` — 6 keys: eng_physics(13 chapters), med_physics(12), eng_chemistry(12), med_chemistry(10), eng_mathematics(14), med_biology(14)
- `static List<Chapter> forSubject(String subjectId)`

### `lib/features/chapters/presentation/widgets/subject_progress_card.dart`
- `class SubjectProgressCard extends StatelessWidget`
- Props: `chapters`, `accentColor`
- Computed getters: `_totalQuestions`, `_completedQuestions`, `_overallProgress`, `_overallPercent`, `_chaptersCompleted`
- Layout: large percent number (36px) + `_StatBadge` column (questions + chapters done) + `LinearProgressIndicator`

### `lib/features/chapters/presentation/widgets/chapter_card.dart`
- `class ChapterCard extends StatelessWidget`
- Props: `chapter`, `accentColor`, `onTap`, `showNumber`, `index`
- `_ChapterStatusIndicator` — completed=green check, started=accent play icon, not started=number
- `_CtaChip` — pill label ('Start'/'Continue'/'Review') with matching color
- Progress bar only shown when `chapter.isStarted`

### `lib/features/chapters/presentation/chapter_dashboard_screen.dart`
- `class ChapterDashboardScreen extends StatefulWidget` · prop: `subjectId`
- State: `_allChapters`, `_subject`, `_searchController`, `_activeFilter`(ChapterFilter), `_searchQuery`
- `enum ChapterFilter { all, inProgress, completed, notStarted }`
- `List<Chapter> get _filteredChapters` — applies search query + filter enum
- `_onChapterTapped(Chapter)` → `context.push('/subjects/$subjectId/chapters/${chapter.id}/practice')`
- Layout: `_SubjectIntro` + `SubjectProgressCard` + `_SearchBar` + `_FilterChips` + `SliverList` of `ChapterCard` or `_EmptyState`
- `_SearchBar` — `TextField` with live clear button via `ValueListenableBuilder`
- `_FilterChips` — horizontal scroll row of animated pill chips

### `lib/features/chapters/presentation/question_placeholder_screen.dart`
- ⚠️ **ORPHANED** — superseded by `PracticeScreen`. Not imported anywhere. Safe to delete.

### `lib/features/chapters/screens/chapters_screen.dart`
- ⚠️ **ORPHANED** — Phase 2 placeholder superseded by `ChapterDashboardScreen`. Safe to delete.

---

## ✅ Phase 4 — PYQ Practice Engine

### `lib/features/practice/models/question.dart`
- `enum ExamSource { jeeMain, jeeAdvanced, neet }` · `.label` extension getter
- `class Question` (immutable, const-constructible)
- Props: `id`, `text`, `options`(List<String>, exactly 4), `correctOptionIndex`, `explanation`, `source`, `year`, `isBookmarked`(future-ready)
- Computed: `correctOptionText`, `isCorrect(int selectedIndex)`

### `lib/features/practice/data/dummy_questions.dart`
- `abstract final class DummyQuestions`
- `static List<Question> forChapter(String chapterId)` — returns chapter questions or `_fallback`
- Chapters with data: `ep_01`(Kinematics, 8q), `ep_02`(Laws of Motion, 6q), `ep_03`(Work Energy, 5q), `mp_01`(4q), `mp_02`(3q), `ec_01`(5q), `em_01`(5q)
- `_fallback` — 4 generic questions for unmapped chapters

### `lib/features/practice/presentation/widgets/question_progress_bar.dart`
- `class QuestionProgressBar extends StatelessWidget`
- Props: `currentIndex`(0-based), `total`, `sourceLabel`, `year`
- Shows "Q 3 of 20" + `LinearProgressIndicator` + `_SourceTag` pill (e.g. 'JEE Main · 2023')

### `lib/features/practice/presentation/widgets/question_card.dart`
- `class QuestionCard extends StatelessWidget` — purely presentational
- Props: `question`, `selectedIndex`(int?), `isSubmitted`, `onOptionSelected`
- `_OptionTile` — A/B/C/D label badge + text + check/cross icon post-submission
- `_OptionStyle` value class — computes background/border/label colors for 4 states: unselected, selected, correct-after-submit, wrong-after-submit
- Uses `AnimatedContainer` (180ms) for smooth color transitions

### `lib/features/practice/presentation/widgets/explanation_card.dart`
- `class ExplanationCard extends StatelessWidget`
- Props: `question`, `selectedIndex`
- Shows green card if correct, red card if wrong
- Displays: result header icon + "Correct answer: X" (if wrong) + divider + explanation text

### `lib/features/practice/presentation/practice_screen.dart`
- `class PracticeScreen extends StatefulWidget`
- Props: `subjectId`, `chapterId`, `chapterTitle`
- State: `_questions`, `_currentIndex`, `_selectedOptionIndex`(int?), `_isSubmitted`, `_results`(Map<String, bool>)
- `_onOptionSelected(int)` — no-op if already submitted
- `_onSubmit()` — sets `_isSubmitted=true`, records result in `_results`
- `_onNext()` — advances index or calls `_goToResults()`
- `_goToResults()` → `context.pushReplacement('/result', extra: {chapterTitle, total, correct})`
- `_scrollController` — scrolls to top on question change
- `_BottomActionBar` — "Submit answer" (disabled until option selected) → "Next question" / "See results"
- `_EmptyQuestionsScreen` — fallback if chapter has no questions

### `lib/features/practice/presentation/practice_result_screen.dart`
- `class PracticeResultScreen extends StatelessWidget`
- Props: `chapterTitle`, `total`, `correct`, `subjectId`, `chapterId`
- Computed: `_wrong`, `_accuracyPercent`
- `_ScoreCard` — large accuracy % (56px, color-coded: green≥80%, amber≥50%, red<50%) + progress bar
- `_MiniStatCard` — 3-up row: Correct / Wrong / Accuracy
- Actions: `PrimaryButton('Back to chapters')` → `context.go('/subjects/$subjectId')` · `OutlinedButton('Practice again')` → `pushReplacement` to practice route

---

## ✅ Phase 5 — Bookmarks
- [x] `lib/features/bookmarks/providers/bookmark_provider.dart` — `BookmarkNotifier extends StateNotifier<List<String>>`; methods: `toggle(questionId)`, `isBookmarked(questionId)`; exposed via `bookmarkProvider` (StateNotifierProvider)
- [x] `lib/features/bookmarks/screens/bookmarks_screen.dart` — `ConsumerWidget`; reads `bookmarkProvider`; resolves Questions via `DummyQuestions` + `DummyChapters` + `SubjectsData`; groups by `SubjectModel`; `_BookmarkTile` taps → `context.push('/subjects/$subjectId/chapters/$chapterId/practice')`; empty state when no bookmarks
- [x] Modify `practice_screen.dart` — converted to `ConsumerStatefulWidget`; bookmark `IconButton` in AppBar with `AnimatedSwitcher` (outline ↔ filled); `_toggleBookmark()` calls `ref.read(bookmarkProvider.notifier).toggle(id)`; `isBookmarked` read via `ref.watch(bookmarkProvider.notifier).isBookmarked(id)`
- [x] Modify `question_card.dart` — `isBookmarked` optional bool prop (default `false`) added; no visual change inside the card

## ✅ Phase 6 — Wrong Questions
- [x] `lib/features/mistakes/providers/mistakes_provider.dart` — `WrongAnswer` immutable model (questionId, subjectId, chapterId, chapterTitle, attemptedAt); `MistakesNotifier extends StateNotifier<List<WrongAnswer>>`; methods: `record(WrongAnswer)` (no duplicates), `remove(questionId)`, `isWrong(questionId) → bool`; exposed via `mistakesProvider`; `retryQuestionIdsProvider` + `initialQuestionIdProvider` (`StateProvider<String?>`) for transient session coordination
- [x] `lib/features/mistakes/screens/mistakes_screen.dart` — `ConsumerWidget`; reads `mistakesProvider`; resolves Questions via `DummyQuestions`; groups by chapter title; `_MistakeTile` with 2-line truncated question + chapter label + Retry chip; taps → writes `retryQuestionIdsProvider` + `initialQuestionIdProvider` then pushes practice route; empty state: check icon + 'No mistakes recorded'
- [x] Modify `practice_screen.dart` — `_onSubmit()` Riverpod writes before `setState`; `questionIds` optional param added; `initState` filters `DummyQuestions` to provided IDs in order (retry mode); reads + clears `initialQuestionIdProvider` to set `_currentIndex` after building `_questions`; falls back to index 0 when null or ID not found
- [x] Modify `router.dart` — practice route builder reads `questionIds` from `state.extra`, passes to `PracticeScreen`; normal navigation (no extra) unchanged

## ✅ Phase 7 — Learning Engine
- [x] `lib/features/learning/models/question_attempt.dart` — `QuestionAttempt` immutable model; fields: `questionId`, `subjectId`, `chapterId`, `selectedOption`, `correctOption`, `isCorrect`, `attemptedAt`(DateTime), `timeTaken`(Duration), `attemptNumber`(int); `attemptNumber` is always computed by the notifier, never by callers
- [x] `lib/features/learning/providers/learning_provider.dart` — `LearningNotifier extends StateNotifier<List<QuestionAttempt>>`; methods: `record(QuestionAttempt)`, `attemptsFor(questionId) → List`, `latestAttemptFor(questionId) → QuestionAttempt?`, `countFor(questionId) → int`; exposed via `learningProvider` (StateNotifierProvider); no analytics, no progress calculations
- [x] Modify `practice_screen.dart` — added `_questionStartTime` (DateTime) field; initialised in `initState`, reset in `_onNext`; `_onSubmit` appends a `QuestionAttempt` to `learningProvider` after the existing mistakes logic, before `setState`; `attemptNumber` computed via `countFor` at call site

## ✅ Phase 8 — Derived Learning State
- [x] `lib/features/learning/models/progress_stats.dart` — `ProgressStats` immutable value object; fields: `totalAttempts`, `correctAttempts`, `incorrectAttempts`, `overallAccuracy`(double 0–1), `latestAttempt`(QuestionAttempt?), `completedQuestionIds`(Set<String>); factory `ProgressStats.fromAttempts(List<QuestionAttempt>)` handles all derivation; computed getters: `accuracyPercent`(int), `hasActivity`(bool)
- [x] `lib/features/learning/providers/progress_stats_provider.dart` — all providers are read-only `Provider` / `Provider.family`; `progressStatsProvider` → overall `ProgressStats` from full history; `chapterStatsProvider(chapterId)` → scoped `ProgressStats` filtered by chapterId; `subjectStatsProvider(subjectId)` → scoped `ProgressStats` filtered by subjectId; `completedQuestionsProvider` → `Set<String>` convenience wrapper; `latestAttemptProvider` → `QuestionAttempt?` for Continue Learning
- [x] `lib/features/learning/models/chapter_progress.dart` — `ChapterProgress` immutable value object; fields: `chapterId`, `totalQuestions`, `attemptedQuestions`, `correctQuestions`, `incorrectQuestions`, `completionPercentage`(double 0–1), `accuracyPercentage`(double 0–1); factory `ChapterProgress.fromAttempts({chapterId, totalQuestions, attempts})`; correct/incorrect based on latest attempt per question; computed getters: `completionPercent`, `accuracyPercent`, `hasActivity`, `isCompleted`
- [x] `lib/features/learning/models/subject_progress.dart` — `SubjectProgress` immutable value object; identical structure to `ChapterProgress` but scoped to a subject; fields: `subjectId`, `totalQuestions`, `attemptedQuestions`, `correctQuestions`, `incorrectQuestions`, `completionPercentage`, `accuracyPercentage`; computed getters: `completionPercent`, `accuracyPercent`, `hasActivity`
- [x] `lib/features/learning/providers/chapter_progress_provider.dart` — `chapterProgressProvider(chapterId)` → `ChapterProgress` derived from `learningProvider` + `DummyQuestions.forChapter`; `subjectProgressProvider(subjectId)` → `SubjectProgress` derived from `learningProvider` + `DummyChapters.forSubject`; both are `Provider.family`, fully reactive, zero manual refresh
- [x] `lib/features/learning/providers/learning_insights_provider.dart` — `continueLearningProvider` → `QuestionAttempt?` (delegates to existing `latestAttemptProvider`; extensible); `weakestChapterProvider` → `String?` (chapter ID with lowest latest-attempt accuracy among attempted chapters); `strongestChapterProvider` → `String?` (highest accuracy); `mostPracticedChapterProvider` → `String?` (highest raw attempt count); `recentlyCompletedQuestionsProvider` → `List<String>` (distinct question IDs sorted newest-first by latest attempt); private `_latestAccuracy` helper shared by weak/strong providers

## ✅ Phase 9 — Progress Experience
- [x] `lib/features/progress/presentation/progress_screen.dart` — replaced static placeholder; `ConsumerWidget`; reads `progressStatsProvider`, `subjectProgressProvider(id)`, `continueLearningProvider`, `weakestChapterProvider`, `strongestChapterProvider`, `mostPracticedChapterProvider`, `recentlyCompletedQuestionsProvider`; sections: Header (adaptive subtitle), Overview (`_StatCard` row: attempts + accuracy), Subjects (`_SubjectProgressTile` with linear bar + completion% + accuracy%), Insights (`_InsightTile` row: continue / needs work / strongest / most practiced), Recently Solved (up to 8 question IDs newest-first); Insights + Recently Solved sections hidden when `!hasActivity`; zero business logic in UI

## ✅ Phase 9.2 — Chapter Progress Experience
- [x] `lib/features/chapters/presentation/chapter_dashboard_screen.dart` — converted to `ConsumerStatefulWidget`; filter logic (`inProgress`, `completed`, `notStarted`) now driven by live `chapterProgressProvider` instead of static `Chapter` fields; passes `ChapterProgress` into every `ChapterCard`; `SubjectProgressCard` receives live `subjectProgressProvider` data; no business logic added
- [x] `lib/features/chapters/presentation/widgets/chapter_card.dart` — accepts `ChapterProgress progress` (required); derives `isStarted`, `isCompleted`, `ctaLabel` from live progress; `_StatusIndicator` shows green check on completed chapters; `_SubLabel` shows total questions / remaining / "Completed · N% accuracy" based on state; `_ProgressRow` shows linear bar + "N of M attempted · X% accuracy" — visible only when `isStarted`; no static `chapter.*` computed fields used for progress
- [x] `lib/features/chapters/presentation/widgets/subject_progress_card.dart` — refactored to accept `SubjectProgress subjectProgress` + `totalChapters`; derives all display values from live attempt history; accuracy stat badge shown when `hasActivity`, chapter count shown otherwise; progress bar driven by `subjectProgress.completionPercentage`

## ✅ Phase 9.3 — Personalized Home Experience
- [x] `lib/features/home/presentation/home_screen.dart` — converted `StatelessWidget` to `ConsumerWidget` to integrate Learning Engine providers; refactored layout into 6 cohesive sections: Welcome (personalized header), Continue Learning (hero card reading `continueLearningProvider` and `chapterProgressProvider`), Quick Learning Stats (visually lightweight attempted/accuracy metrics), Quick Actions (navigation to bookmarks, mistakes, progress), Learning Insights (Weakest and Most Practiced chapters), and Subject Progress (compact completion percentage row + linear bar for all subjects); completely removed all dummy data placeholders. Optimized layout order to surface high-frequency Quick Actions right below stats.

## ✅ Phase 9.4 — Premium UX Polish
- [x] `lib/features/mistakes/presentation/mistakes_screen.dart` — AppBar and headers renamed to "Mistakes"; empty state container radius converted to `AppRadius.radiusLg`; spelling fixed ("practising" -> "practicing").
- [x] `lib/features/bookmarks/presentation/bookmarks_screen.dart` — empty state container radius updated to `AppRadius.radiusLg` for consistent visual tokens.
- [x] `lib/features/practice/presentation/practice_result_screen.dart` — progress bar radius converted to `AppRadius.radiusFull` instead of raw circular value.
- [x] `lib/features/progress/presentation/progress_screen.dart` — recently solved section refactored to look up and show truncated question text via `DummyQuestions` instead of raw ID strings, layout tweaked to align numbers and multi-line text nicely.

## ✅ UI Redesign Sprint 1 — Foundation
- [x] Refined the entire color palette in `app_colors.dart` with soft off-white `background` (#F7F8FA), `surface` (#FCFCFD), and softer neutrals.
- [x] Updated spacing tokens in `app_spacing.dart` (increased `cardGap` to 16, `cardPadding` to 24, button heights to 58/46).
- [x] Restyled `AppTheme` with `radiusXxl` cards, refined `InputDecoration` padding/radii, and adjusted typography line-heights/weights.
- [x] Redesigned `app_shell.dart` to use a custom floating, pill-shaped `_FloatingNavBar` with soft shadows, an animated indicator pill, and enabled `extendBody: true`.
- [x] Updated critical UI elements (`PageHeading`, `PrimaryButton`, `CustomTextField`, `ChapterCard`, `SubjectProgressCard`) to inherit design tokens.
- [x] Updated card styles and layout elements in all screens (`HomeScreen`, `ProgressScreen`, `SubjectsScreen`, `BookmarksScreen`, `MistakesScreen`, `ChapterDashboardScreen`, `PracticeResultScreen`) to use the new premium card system.

## ✅ UI Redesign Sprint 2 — Authentication Experience
- [x] Redesigned Login and Signup screens with a premium, vertically balanced layout.
- [x] Added a subtle background gradient to the off-white surface to build atmospheric depth.
- [x] Wrapped the forms inside a floating premium card with `radiusXxl` (24dp), soft elevation, and 0.75px borders.
- [x] Replaced the generic appbar with a custom overlay back button.
- [x] Improved text field spacing and primary/secondary button layout and styling.

## ✅ Brand Integration
- [x] Nested `assets/branding/` asset path correctly inside `pubspec.yaml` under `flutter:`.
- [x] Swapped out the placeholder `_LogoMark` inside `AppLogo` for the official brand logo icon (`logo_icon.png`).
- [x] Set up an automated error fallback `_LogoMarkFallback` in `AppLogo` to support robust tests and developer environments.
- [x] Center-aligned and scaled the new PrepEdge logo icon consistently inside Splash, Login, and Signup screens.

## ✅ Brand Identity Review Pass
- [x] Splash Screen: Increased logo size to 72dp, unified logo/app name/tagline in a single visual group via AppLogo, and removed the manual tagline text widget.
- [x] Login & Signup Screens: Kept clean hierarchy, ensured logo and app name are visually connected (8dp spacing), and updated login subtitle copy to "Pick up where you left off."
- [x] Home Screen: Introduced a compact 32dp icon-only logo next to the welcome greeting section as a subtle branding touch.
- [x] Page Headers & Bottom Navigation: Ensured no logos are placed on Subjects, Practice, Progress, Bookmarks, and Mistakes screens to remain focused on learning.

## ✅ UI Review Pass — Home Experience
- [x] Reorganized Home Screen layout hierarchy: Greeting → Continue Learning → Today's Snapshot → Quick Actions → Insights → Subjects.
- [x] Greeting: Strengthened typography, added motivational subtitle ("Consistency beats intensity.") next to the compact 32dp logo.
- [x] Today's Snapshot: Created a 2x2 grid displaying Questions Attempted, Accuracy, Bookmarks, and Mistakes counts using real existing providers.
- [x] Quick Actions & Subjects: Restructured positioning, adjusted margins/spacing, and elevated visual hierarchy of key elements.

---

## Current Task
**Status:** UI Review Pass — Home Experience completed. Home screen restructured into a high-utility productivity dashboard.
**Next file:** TBD
**Last completed file:** `build_progress.md` — Updated progress documentation to include UI Review Pass — Home Experience.

---

## Orphaned Files (delete before shipping)
- `lib/features/chapters/screens/chapters_screen.dart`
- `lib/features/chapters/presentation/question_placeholder_screen.dart`

---

## Rules for New Conversations
1. Read this file first — it is the single source of truth
2. Do NOT recreate any ✅ file
3. Generate one file at a time, update this file after each
4. Follow existing patterns: const constructors, AppColors/AppSpacing/AppRadius tokens, no inline styles
5. Riverpod `StateNotifier` pattern for all providers from Phase 5 onward

---

## Engineering Principles

### Navigation

- PracticeScreen is always the single destination for solving questions.
- Navigation should target Question IDs, not question indexes.
- Never use indexes for persistent navigation.
- Normal chapter navigation starts at Question 1.
- Bookmarks, Mistakes, Continue Learning and future Search should all open PracticeScreen using a Question ID.

---

### Data

- Question.id is the permanent identifier.
- DummyQuestions is the current source of truth.
- Firestore will later replace DummyQuestions.
- Question model should remain stable after Firebase migration whenever possible.

---

### State

- Riverpod StateNotifier pattern for application state.
- Avoid duplicate sources of truth.
- Providers should store IDs rather than duplicate Question objects where possible.

---

### UI

- Material 3 only.
- Premium minimal design.
- No unnecessary animations.
- No flashy gradients.
- Reuse existing widgets before creating new ones.

---

### Coding Rules

- Generate one file at a time.
- Never modify unrelated files.
- Prefer extending existing architecture.
- Never rewrite working features.
- Keep implementations production-ready.