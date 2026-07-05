import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/mistakes_repository.dart';

// ── Repository provider ────────────────────────────────────────────────────────

/// Provides a singleton [MistakesRepository] for the lifetime of the app.
///
/// The repository is created once per [ProviderScope]. Firebase dependencies
/// ([FirebaseFirestore], [FirebaseAuth]) are resolved inside the repository
/// constructor with singleton fallbacks — no extra injection needed here.
///
/// Consumed by: [MistakesNotifier] in Sprint 10.5 (replaces in-memory state
/// with Firestore-backed streams).
final mistakesRepositoryProvider = Provider<MistakesRepository>((ref) {
  return MistakesRepository();
});
