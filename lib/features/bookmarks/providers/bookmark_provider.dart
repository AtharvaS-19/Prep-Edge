import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the in-memory list of bookmarked question IDs.
///
/// Uses a simple [StateNotifier<List<String>>] — no persistence yet.
/// The list stores unique question IDs only; toggling an already-bookmarked
/// ID removes it, toggling an absent ID adds it.
class BookmarkNotifier extends StateNotifier<List<String>> {
  BookmarkNotifier() : super(const []);

  /// Adds [questionId] if not already bookmarked; removes it if it is.
  void toggle(String questionId) {
    if (state.contains(questionId)) {
      state = state.where((id) => id != questionId).toList();
    } else {
      state = [...state, questionId];
    }
  }

  /// Returns true when [questionId] is currently in the bookmark list.
  bool isBookmarked(String questionId) => state.contains(questionId);
}

/// The global provider for [BookmarkNotifier].
///
/// Consumed by:
///  - [PracticeScreen] — to toggle + read bookmark state per question
///  - [BookmarksScreen] — to resolve and display all bookmarked questions
final bookmarkProvider = StateNotifierProvider<BookmarkNotifier, List<String>>(
  (_) => BookmarkNotifier(),
);
