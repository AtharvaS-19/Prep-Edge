import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/bookmark_repository.dart';

// ── Repository provider ────────────────────────────────────────────────────────

/// Provides a singleton [BookmarkRepository] for the lifetime of the app.
///
/// The repository is created once per [ProviderScope]. Firebase dependencies
/// ([FirebaseFirestore], [FirebaseAuth]) are resolved inside the repository
/// constructor with singleton fallbacks — no extra injection needed here.
///
/// Consumed by: [BookmarkNotifier] in Sprint 10.5 (replaces in-memory state
/// with Firestore-backed streams).
final bookmarkRepositoryProvider = Provider<BookmarkRepository>((ref) {
  return BookmarkRepository();
});
