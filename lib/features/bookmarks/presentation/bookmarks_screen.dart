import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:exam_prep_app/features/bookmarks/providers/bookmark_provider.dart';
import 'package:exam_prep_app/features/catalog/providers/catalog_provider.dart';
import 'package:exam_prep_app/features/mistakes/providers/mistakes_provider.dart';
import 'package:exam_prep_app/features/practice/models/question.dart';
import 'package:exam_prep_app/features/subjects/models/subject_model.dart';
import 'package:exam_prep_app/shared/constants/app_colors.dart';
import 'package:exam_prep_app/shared/constants/app_radius.dart';
import 'package:exam_prep_app/shared/constants/app_spacing.dart';

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

/// The Bookmarks screen — Phase 5.
///
/// Reads [bookmarkProvider] to get bookmarked question IDs, resolves full
/// [Question] objects across all subjects/chapters, groups them by subject,
/// and displays them in expandable sections. Empty state when no bookmarks.
class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarkedIds = ref.watch(bookmarkProvider).toSet();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Bookmarks'),
      ),
      body: SafeArea(
        child: bookmarkedIds.isEmpty
            ? const _EmptyState()
            : _BookmarkList(bookmarkedIds: bookmarkedIds),
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

    return CustomScrollView(
      slivers: [
        // ── Header ──────────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              AppSpacing.xl,
              AppSpacing.screenHorizontal,
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bookmarks',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${bookmarkedIds.length} question${bookmarkedIds.length == 1 ? '' : 's'} saved',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Subject groups ────────────────────────────────────────────────
        for (final entry in grouped.entries) ...[
          SliverToBoxAdapter(
            child: _SubjectHeader(subject: entry.key),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => _BookmarkTile(entry: entry.value[i]),
              childCount: entry.value.length,
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.lg),
          ),
        ],

        // ── Bottom padding ───────────────────────────────────────────────
        const SliverToBoxAdapter(
          child: SizedBox(height: AppSpacing.xxl),
        ),
      ],
    );
  }
}

// ── Subject section header ────────────────────────────────────────────────────

class _SubjectHeader extends StatelessWidget {
  const _SubjectHeader({required this.subject});

  final SubjectModel subject;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        0,
        AppSpacing.screenHorizontal,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: subject.accentColor.withValues(alpha: 0.12),
              borderRadius: AppRadius.radiusSm,
            ),
            child: Icon(
              subject.icon,
              size: 14,
              color: subject.accentColor,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            subject.name,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: subject.accentColor,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bookmark tile ─────────────────────────────────────────────────────────────

class _BookmarkTile extends ConsumerWidget {
  const _BookmarkTile({required this.entry});

  final _BookmarkEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        0,
        AppSpacing.screenHorizontal,
        AppSpacing.cardGap,
      ),
      child: GestureDetector(
        onTap: () {
          ref.read(initialQuestionIdProvider.notifier).state =
              entry.question.id;
          context.push(
            '/subjects/${entry.subjectId}/chapters/${entry.chapterId}/practice',
          );
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: AppRadius.radiusXl,
            border: Border.all(color: AppColors.border, width: 0.75),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 10,
                offset: Offset(0, 3),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Chapter label
              Row(
                children: [
                  const Icon(
                    Icons.bookmark_rounded,
                    size: 12,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      entry.chapterTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                  // Source + year tag
                  _SourceTag(entry: entry),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              // Question text (truncated — tap to read in full)
              Text(
                entry.question.text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                  height: 1.5,
                  letterSpacing: -0.1,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              const Row(
                children: [
                  Text(
                    'Tap to practice',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 12,
                    color: AppColors.textTertiary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Source tag chip ───────────────────────────────────────────────────────────

class _SourceTag extends StatelessWidget {
  const _SourceTag({required this.entry});

  final _BookmarkEntry entry;

  @override
  Widget build(BuildContext context) {
    final label = '${entry.question.source.label} · ${entry.question.year}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: const BoxDecoration(
        color: AppColors.cardBackgroundAlt,
        borderRadius: AppRadius.radiusXs,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
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
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: AppSpacing.xl, bottom: AppSpacing.xs),
            child: Text(
              'Bookmarks',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const Text(
            'Questions you save will appear here for quick revision.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const Spacer(),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: AppRadius.radiusLg,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(
                    Icons.bookmark_outline_rounded,
                    size: 24,
                    color: AppColors.iconSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'No bookmarks yet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.25,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'While solving questions, tap the bookmark\nicon to save important ones here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
