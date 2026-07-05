import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';

// ── Repository provider ────────────────────────────────────────────────────────

/// Provides a singleton [AuthRepository] for the lifetime of the app.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// ── Auth state stream ──────────────────────────────────────────────────────────

/// Exposes the raw Firebase auth state as a [Stream<User?>].
///
/// The router's `redirect` listens to this via [authStateProvider] so that
/// navigation reacts automatically whenever sign-in or sign-out occurs.
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

// ── Auth notifier ──────────────────────────────────────────────────────────────

/// Holds transient sign-in / sign-up UI state: loading flag and error message.
///
/// Business logic (calling the repository) lives here.
/// The widgets only call [signIn], [signUp], [signOut] and read state.
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repository) : super(const AuthState());

  final AuthRepository _repository;

  // ── Sign in ────────────────────────────────────────────────────────────────

  /// Calls [AuthRepository.signIn].
  ///
  /// Sets [isLoading] while awaiting, then either clears state on success
  /// or stores the error message on failure.
  Future<void> signIn({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final error = await _repository.signIn(email: email, password: password);
    state = state.copyWith(isLoading: false, errorMessage: error);
  }

  // ── Sign up ────────────────────────────────────────────────────────────────

  /// Calls [AuthRepository.signUp].
  Future<void> signUp({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final error = await _repository.signUp(email: email, password: password);
    state = state.copyWith(isLoading: false, errorMessage: error);
  }

  // ── Sign out ───────────────────────────────────────────────────────────────

  /// Signs the current user out.
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await _repository.signOut();
    state = const AuthState();
  }

  // ── Error helpers ──────────────────────────────────────────────────────────

  /// Clears any displayed error message (e.g. when the user starts typing).
  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }
}

/// Provider for [AuthNotifier].
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

// ── Auth state value object ────────────────────────────────────────────────────

/// Immutable snapshot of the transient auth form state.
class AuthState {
  const AuthState({
    this.isLoading = false,
    this.errorMessage,
  });

  final bool isLoading;
  final String? errorMessage;

  AuthState copyWith({bool? isLoading, String? errorMessage}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      // Pass null explicitly to clear the error.
      errorMessage: errorMessage,
    );
  }
}
