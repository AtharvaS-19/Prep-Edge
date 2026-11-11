import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:exam_prep_app/features/bookmarks/providers/bookmark_provider.dart';
import 'package:exam_prep_app/features/catalog/providers/catalog_provider.dart';
import 'package:exam_prep_app/features/mistakes/providers/mistakes_provider.dart';
import 'package:exam_prep_app/features/practice/models/question.dart';
import 'package:exam_prep_app/features/subjects/models/subject_model.dart';
import 'package:exam_prep_app/shared/constants/app_colors.dart';
import 'package:exam_prep_app/shared/constants/app_spacing.dart';
import 'package:exam_prep_app/shared/constants/app_text.dart';
import 'package:exam_prep_app/shared/widgets/app_card.dart';
import 'package:exam_prep_app/shared/widgets/empty_state.dart';
import 'package:exam_prep_app/shared/widgets/pressable.dart';
import 'package:exam_prep_app/shared/widgets/section_header.dart';

// ── Data shape ────────────────────────────────────────────────────────────────

/// A resolved bookmark entry — question + its owning subject + chapter IDs.
class _BookmarkEntry {
  const _BookmarkEntry({
    required this.question,
    required this.subjectId,
    required this.chapterId,
    required this.chapterTitle,
  });

  final Question question;
  final String subjectId;
  final String chapterId;
  final String chapterTitle;
}

// ── Helpers ───────────────────────────────────────────────────────────────────

/// Walks every chapter in every subject and resolves Question objects for the
/// given set of [bookmarkedIds]. Returns a map of SubjectModel → entries, with
/// only subjects that have at least one match.
Map<SubjectModel, List<_BookmarkEntry>> _resolveBookmarks(
  Set<String> bookmarkedIds,
  WidgetRef ref,
) {
  final result = <SubjectModel, List<_BookmarkEntry>>{};

  for (final subject in ref.read(allSubjectsProvider)) {
    final chapters = ref.read(chaptersForSubjectProvider(subject.id));
    for (final chapter in chapters) {
      final questions = ref.read(questionsForChapterProvider(chapter.id));
      for (final question in questions) {
        if (bookmarkedIds.contains(question.id)) {
          result.putIfAbsent(subject, () => []).add(
                _BookmarkEntry(
                  question: question,
                  subjectId: subject.id,
                  chapterId: chapter.id,
                  chapterTitle: chapter.title,
                ),
              );
        }
      }
    }
  }

  return result;
}

// ── Screen ────────────────────────────────────────────────────────────────────

/// The Bookmarks screen.
///
/// Reads [bookmarkProvider] to get bookmarked question IDs, resolves full
/// [Question] objects across all subjects/chapters, groups them by subject and
/// shows them in grouped lists. Empty state when no bookmarks.
class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarkedIds = ref.watch(bookmarkProvider).toSet();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: bookmarkedIds.isEmpty
                ? const _EmptyState()
                : _BookmarkList(bookmarkedIds: bookmarkedIds),
          ),
        ),
      ),
    );
  }
}

// ── Populated list ────────────────────────────────────────────────────────────

class _BookmarkList extends ConsumerWidget {
  const _BookmarkList({required this.bookmarkedIds});

  final Set<String> bookmarkedIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grouped = _resolveBookmarks(bookmarkedIds, ref);

    if (grouped.isEmpty) {
      // All bookmarked IDs resolved to nothing — data edge case.
      return const _EmptyState();
    }

    final count = bookmarkedIds.length;
    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      children: [
        ScreenHeader(
          title: 'Saved',
          subtitle: '$count question${count == 1 ? '' : 's'} saved for revision',
        ),
        for (final entry in grouped.entries)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              0,
              AppSpacing.screenHorizontal,
              AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SubjectHeader(subject: entry.key, count: entry.value.length),
                AppGroup(
                  children: [
                    for (final e in entry.value) _BookmarkRow(entry: e),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ── Subject section header ────────────────────────────────────────────────────

class _SubjectHeader extends StatelessWidget {
  const _SubjectHeader({required this.subject, required this.count});

  final SubjectModel subject;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(subject.icon, size: 18, color: subject.accentColor),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              '${subject.name} · ${subject.stream.label}',
              style: AppText.headline,
            ),
          ),
          Text('$count', style: AppText.caption),
        ],
      ),
    );
  }
}

// ── Bookmark row ──────────────────────────────────────────────────────────────

class _BookmarkRow extends ConsumerWidget {
  const _BookmarkRow({required this.entry});

  final _BookmarkEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Pressable(
      scale: 1,
      onTap: () {
        ref.read(initialQuestionIdProvider.notifier).state = entry.question.id;
        context.push(
          '/subjects/${entry.subjectId}/chapters/${entry.chapterId}/practice',
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.question.text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.callout.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${entry.chapterTitle}  ·  ${entry.question.source.label} ${entry.question.year}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Padding(
              padding: EdgeInsets.only(top: 1),
              child: Icon(Icons.chevron_right_rounded,
                  size: 20, color: AppColors.iconSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ScreenHeader(title: 'Saved'),
        Expanded(
          child: EmptyState(
            icon: Icons.bookmark_outline_rounded,
            title: 'Nothing saved yet',
            message:
                'Tap the bookmark while solving a question to keep it here for revision.',
          ),
        ),
      ],
    );
  }
}
