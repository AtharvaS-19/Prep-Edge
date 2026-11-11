import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:exam_prep_app/features/mistakes/providers/mistakes_provider.dart';
import 'package:exam_prep_app/features/catalog/providers/catalog_provider.dart';
import 'package:exam_prep_app/features/practice/models/question.dart';
import 'package:exam_prep_app/shared/constants/app_colors.dart';
import 'package:exam_prep_app/shared/constants/app_spacing.dart';
import 'package:exam_prep_app/shared/constants/app_text.dart';
import 'package:exam_prep_app/shared/widgets/app_card.dart';
import 'package:exam_prep_app/shared/widgets/empty_state.dart';
import 'package:exam_prep_app/shared/widgets/pressable.dart';
import 'package:exam_prep_app/shared/widgets/section_header.dart';

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
Map<String, List<_MistakeEntry>> _groupByChapter(
    List<WrongAnswer> wrongs, WidgetRef ref) {
  final result = <String, List<_MistakeEntry>>{};

  for (final wrong in wrongs) {
    final questions = ref.read(questionsForChapterProvider(wrong.chapterId));

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

/// Mistakes screen.
///
/// Reads [mistakesProvider], resolves full [Question] objects from
/// [questionsForChapterProvider], groups them by chapter, and displays them as
/// tappable rows that navigate back to the relevant practice session.
class MistakesScreen extends ConsumerWidget {
  const MistakesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wrongs = ref.watch(mistakesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: wrongs.isEmpty
                ? const _EmptyState()
                : _MistakeList(wrongs: wrongs),
          ),
        ),
      ),
    );
  }
}

// ── Populated list ────────────────────────────────────────────────────────────

class _MistakeList extends ConsumerWidget {
  const _MistakeList({required this.wrongs});

  final List<WrongAnswer> wrongs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grouped = _groupByChapter(wrongs, ref);

    if (grouped.isEmpty) {
      return const _EmptyState();
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      children: [
        ScreenHeader(
          title: 'Mistakes',
          subtitle:
              '${wrongs.length} question${wrongs.length == 1 ? '' : 's'} to review',
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
                _ChapterHeader(
                    chapterTitle: entry.key, count: entry.value.length),
                AppGroup(
                  children: [
                    for (final e in entry.value)
                      _MistakeRow(
                        entry: e,
                        // The retry session contains every mistake in this
                        // chapter, not just the tapped one.
                        chapterQuestionIds:
                            entry.value.map((x) => x.question.id).toList(),
                      ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ── Chapter section header ────────────────────────────────────────────────────

class _ChapterHeader extends StatelessWidget {
  const _ChapterHeader({required this.chapterTitle, required this.count});

  final String chapterTitle;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              chapterTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.headline,
            ),
          ),
          Text('$count', style: AppText.caption),
        ],
      ),
    );
  }
}

// ── Mistake row ───────────────────────────────────────────────────────────────

class _MistakeRow extends ConsumerWidget {
  const _MistakeRow({required this.entry, required this.chapterQuestionIds});

  final _MistakeEntry entry;

  /// All wrong question IDs for this chapter.
  final List<String> chapterQuestionIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Pressable(
      scale: 1,
      onTap: () {
        // Set retry IDs in the provider BEFORE navigating.
        // PracticeScreen.initState reads and clears this.
        ref.read(retryQuestionIdsProvider.notifier).state = chapterQuestionIds;
        // Open the session at the tapped question, not the first one.
        ref.read(initialQuestionIdProvider.notifier).state =
            entry.question.id;
        context.push(
          '/subjects/${entry.wrong.subjectId}'
          '/chapters/${entry.wrong.chapterId}'
          '/practice',
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
                    '${entry.question.source.label} ${entry.question.year}',
                    style: AppText.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              'Retry',
              style: AppText.callout.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
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
        ScreenHeader(title: 'Mistakes'),
        Expanded(
          child: EmptyState(
            icon: Icons.check_circle_outline_rounded,
            title: 'No mistakes to review',
            message:
                'Questions you get wrong show up here automatically so you can retry them.',
          ),
        ),
      ],
    );
  }
}
