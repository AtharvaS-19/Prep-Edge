import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/user_repository.dart';

// ── Repository provider ────────────────────────────────────────────────────────

/// Provides a singleton [UserRepository] for the lifetime of the app.
///
/// The repository is created once per [ProviderScope]. Firebase dependencies
/// ([FirebaseFirestore], [FirebaseAuth]) are resolved inside the repository
/// constructor with singleton fallbacks — no extra injection needed here.
///
/// Consumed by: future [UserNotifier] in Sprint 10.5.
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});
