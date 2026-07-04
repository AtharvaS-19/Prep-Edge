/// All user-facing string literals in one place.
/// Makes future localization (l10n) a file-swap, not a search-and-replace.
abstract final class AppStrings {
  // ── App ───────────────────────────────────────────────────────────────────
  static const String appName = 'PrepEdge';
  static const String appTagline = 'Chapter-wise PYQs for JEE & NEET';

  // ── Splash ────────────────────────────────────────────────────────────────
  static const String splashTagline = 'Practice First. Results Follow.';

  // ── Login ─────────────────────────────────────────────────────────────────
  static const String loginTitle = 'Welcome back';
  static const String loginSubtitle = 'Pick up right where you left off.';
  static const String loginButton = 'Log in';
  static const String forgotPassword = 'Forgot password?';
  static const String noAccount = "Don't have an account?";
  static const String signUpLink = 'Sign up';

  // ── Signup ────────────────────────────────────────────────────────────────
  static const String signupTitle = 'Create account';
  static const String signupSubtitle = 'Start solving in under a minute.';
  static const String signupButton = 'Create account';
  static const String alreadyHaveAccount = 'Already have an account?';
  static const String logInLink = 'Log in';

  // ── Form fields ───────────────────────────────────────────────────────────
  static const String fullNameLabel = 'Full name';
  static const String fullNameHint = 'Arjun Sharma';
  static const String emailLabel = 'Email';
  static const String emailHint = 'arjun@gmail.com';
  static const String passwordLabel = 'Password';
  static const String passwordHint = '••••••••';
  static const String confirmPasswordLabel = 'Confirm password';
  static const String confirmPasswordHint = '••••••••';

  // ── Home ──────────────────────────────────────────────────────────────────
  static const String homeGreetingPrefix = 'Good morning';
  static const String homeSubtitle = 'Ready to solve some questions?';
  static const String continuePracticing = 'Continue practicing';
  static const String continueButton = 'Continue';
  static const String quickAccess = 'Quick access';

  // ── Quick access cards ────────────────────────────────────────────────────
  static const String subjects = 'Subjects';
  static const String bookmarks = 'Bookmarks';
  static const String wrongQuestions = 'Wrong questions';
  static const String progress = 'Progress';
  static const String books = 'Books';

  static const String subjectsSubtitle = 'Browse by stream';
  static const String bookmarksSubtitle = 'Saved for revision';
  static const String wrongQuestionsSubtitle = 'Your mistake notebook';
  static const String progressSubtitle = 'Track your accuracy';
  static const String booksSubtitle = 'Reference material';

  // ── Divider ───────────────────────────────────────────────────────────────
  static const String orDivider = 'or';

  // Prevent instantiation
  AppStrings._();
}
