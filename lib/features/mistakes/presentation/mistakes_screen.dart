import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:exam_prep_app/features/mistakes/providers/mistakes_provider.dart';
import 'package:exam_prep_app/features/practice/data/dummy_questions.dart';
import 'package:exam_prep_app/features/practice/models/question.dart';
import 'package:exam_prep_app/shared/constants/app_colors.dart';
import 'package:exam_prep_app/shared/constants/app_radius.dart';
import 'package:exam_prep_app/shared/constants/app_spacing.dart';

// ── Data shape ────────────────────────────────────────────────────────────────

/// A resolved wrong-answer entry — full [Question] + routing metadata.
class _MistakeEntry {
  const _MistakeEntry({
    required this.question,
    required this.wrong,
  });

  final Question question;
  final WrongAnswer wrong;
}

// ── Helpers ───────────────────────────────────────────────────────────────────

/// Resolves full [Question] objects for each [WrongAnswer] and groups them
/// by [WrongAnswer.chapterId] → chapter title.
///
/// Entries whose question cannot be resolved (data gap) are silently dropped.
Map<String, List<_MistakeEntry>> _groupByChapter(List<WrongAnswer> wrongs) {
  final result = <String, List<_MistakeEntry>>{};

  for (final wrong in wrongs) {
    final questions = DummyQuestions.forChapter(wrong.chapterId);

    // Direct nullable loop — avoids the cast<Question?>() pattern which can
    // silently swallow type errors on web.
    Question? found;
    for (final q in questions) {
      if (q.id == wrong.questionId) {
        found = q;
        break;
      }
    }
    if (found == null) continue;

    result
        .putIfAbsent(wrong.chapterTitle, () => [])
        .add(_MistakeEntry(question: found, wrong: wrong));
  }

  return result;
}

// ── Screen ────────────────────────────────────────────────────────────────────

/// Mistakes screen — Phase 6.
///
/// Reads [mistakesProvider], resolves full [Question] objects from
/// [DummyQuestions], groups them by chapter, and displays them as tappable
/// tiles that navigate back to the relevant practice session.
class MistakesScreen extends ConsumerWidget {
  const MistakesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wrongs = ref.watch(mistakesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Mistakes'),
      ),
      body: SafeArea(
        child:
            wrongs.isEmpty ? const _EmptyState() : _MistakeList(wrongs: wrongs),
      ),
    );
  }
}

// ── Populated list ────────────────────────────────────────────────────────────

class _MistakeList extends StatelessWidget {
  const _MistakeList({required this.wrongs});

  final List<WrongAnswer> wrongs;

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByChapter(wrongs);

    if (grouped.isEmpty) {
      return const _EmptyState();
    }

    return CustomScrollView(
      slivers: [
        // ── Header ───────────────────────────────────────────────────────────
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
                  'Mistakes',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${wrongs.length} question${wrongs.length == 1 ? '' : 's'} to review',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Chapter groups ────────────────────────────────────────────────────
        for (final entry in grouped.entries) ...[
          SliverToBoxAdapter(
            child: _ChapterHeader(chapterTitle: entry.key),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                // Collect all wrong question IDs for this chapter so the
                // retry session contains every mistake, not just the tapped one.
                final chapterIds =
                    entry.value.map((e) => e.question.id).toList();
                return _MistakeTile(
                  entry: entry.value[i],
                  chapterQuestionIds: chapterIds,
                );
              },
              childCount: entry.value.length,
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.lg),
          ),
        ],

        // ── Bottom padding ────────────────────────────────────────────────────
        const SliverToBoxAdapter(
          child: SizedBox(height: AppSpacing.xxl),
        ),
      ],
    );
  }
}

// ── Chapter section header ────────────────────────────────────────────────────

class _ChapterHeader extends StatelessWidget {
  const _ChapterHeader({required this.chapterTitle});

  final String chapterTitle;

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
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              chapterTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mistake tile ──────────────────────────────────────────────────────────────

class _MistakeTile extends ConsumerWidget {
  const _MistakeTile({
    required this.entry,
    required this.chapterQuestionIds,
  });

  final _MistakeEntry entry;

  /// All wrong question IDs for this chapter.
  final List<String> chapterQuestionIds;

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
          // Set retry IDs in the provider BEFORE navigating.
          // PracticeScreen.initState reads and clears this.
          ref.read(retryQuestionIdsProvider.notifier).state =
              chapterQuestionIds;
          // Open the session at the tapped question, not the first one.
          ref.read(initialQuestionIdProvider.notifier).state =
              entry.question.id;
          context.push(
            '/subjects/${entry.wrong.subjectId}'
            '/chapters/${entry.wrong.chapterId}'
            '/practice',
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
              // Question text — 2-line truncate
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
              const SizedBox(height: AppSpacing.sm),
              // Footer row: chapter name + retry chip
              Row(
                children: [
                  const Icon(
                    Icons.cancel_outlined,
                    size: 12,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      entry.wrong.chapterTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  // Retry chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: AppRadius.radiusFull,
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.refresh_rounded,
                          size: 11,
                          color: AppColors.error,
                        ),
                        SizedBox(width: 3),
                        Text(
                          'Retry',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
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

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: AppSpacing.xl, bottom: AppSpacing.xs),
            child: Text(
              'Mistakes',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const Text(
            'Questions you answer incorrectly will appear here for targeted revision.',
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
                    Icons.check_circle_outline_rounded,
                    size: 24,
                    color: AppColors.iconSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'No mistakes recorded',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.25,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'Keep practicing — wrong answers will\nshow up here automatically.',
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
