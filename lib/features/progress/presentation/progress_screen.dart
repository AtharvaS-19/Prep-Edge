import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:exam_prep_app/features/catalog/providers/catalog_provider.dart';
import 'package:exam_prep_app/features/learning/providers/chapter_progress_provider.dart';
import 'package:exam_prep_app/features/learning/providers/learning_insights_provider.dart';
import 'package:exam_prep_app/features/learning/providers/progress_stats_provider.dart';
import 'package:exam_prep_app/features/subjects/models/subject_model.dart';
import 'package:exam_prep_app/shared/constants/app_colors.dart';
import 'package:exam_prep_app/shared/constants/app_radius.dart';
import 'package:exam_prep_app/shared/constants/app_spacing.dart';
import 'package:exam_prep_app/shared/constants/app_text.dart';
import 'package:exam_prep_app/shared/widgets/app_card.dart';
import 'package:exam_prep_app/shared/widgets/app_progress_bar.dart';
import 'package:exam_prep_app/shared/widgets/reveal.dart';
import 'package:exam_prep_app/shared/widgets/section_header.dart';

/// Progress screen.
///
/// Reads only from existing derived providers — no business logic in the UI.
/// Layout: header, overview, subjects, insights, recently solved.
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(progressStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
              children: [
                ScreenHeader(
                  title: 'Progress',
                  subtitle: stats.hasActivity
                      ? 'Keep showing up. Progress compounds.'
                      : 'Solve questions to start tracking your progress.',
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Reveal(
                        child: _Overview(
                          attempted: stats.totalAttempts,
                          accuracyPercent:
                              stats.hasActivity ? stats.accuracyPercent : null,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      Reveal(
                        index: 1,
                        child: _SubjectProgressList(ref: ref),
                      ),
                      if (stats.hasActivity) ...[
                        const SizedBox(height: AppSpacing.xxl),
                        Reveal(index: 2, child: _InsightsPanel(ref: ref)),
                        const SizedBox(height: AppSpacing.xxl),
                        Reveal(index: 3, child: _RecentlySolvedList(ref: ref)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Overview ──────────────────────────────────────────────────────────────────

class _Overview extends StatelessWidget {
  const _Overview({required this.attempted, required this.accuracyPercent});

  final int attempted;
  final int? accuracyPercent;

  static Color _accuracyColor(int percent) {
    if (percent >= 80) return AppColors.success;
    if (percent >= 50) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      radius: AppRadius.radiusXxl,
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _Metric(
                label: 'Questions attempted',
                value: attempted > 0 ? '$attempted' : '–',
              ),
            ),
            const VerticalDivider(
                width: AppSpacing.xl, thickness: 1, color: AppColors.divider),
            Expanded(
              child: _Metric(
                label: 'Accuracy',
                value: accuracyPercent != null ? '$accuracyPercent%' : '–',
                color: accuracyPercent != null
                    ? _accuracyColor(accuracyPercent!)
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    this.color = AppColors.textPrimary,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: AppText.numeral.copyWith(fontSize: 34, color: color)),
        const SizedBox(height: 6),
        Text(label, style: AppText.caption),
      ],
    );
  }
}

// ── Subject progress ──────────────────────────────────────────────────────────

class _SubjectProgressList extends StatelessWidget {
  const _SubjectProgressList({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('Subjects'),
        AppGroup(
          children: [
            for (final subject in ref.watch(allSubjectsProvider))
              _SubjectProgressRow(subject: subject, ref: ref),
          ],
        ),
      ],
    );
  }
}

class _SubjectProgressRow extends StatelessWidget {
  const _SubjectProgressRow({required this.subject, required this.ref});

  final SubjectModel subject;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(subjectProgressProvider(subject.id));

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(subject.icon, size: 18, color: subject.accentColor),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: subject.name,
                    style: AppText.callout,
                    children: [
                      TextSpan(
                        text: '  ${subject.stream.label}',
                        style: AppText.caption
                            .copyWith(color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                ),
              ),
              Text('${progress.completionPercent}%', style: AppText.captionStrong),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          AppProgressBar(
            value: progress.completionPercentage,
            color: subject.accentColor,
            height: 4,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            progress.hasActivity
                ? '${progress.accuracyPercent}% accuracy'
                : 'Not started',
            style: AppText.micro,
          ),
        ],
      ),
    );
  }
}

// ── Insights ──────────────────────────────────────────────────────────────────

class _InsightsPanel extends StatelessWidget {
  const _InsightsPanel({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final continueAttempt = ref.watch(continueLearningProvider);
    final weakestId = ref.watch(weakestChapterProvider);
    final strongestId = ref.watch(strongestChapterProvider);
    final mostPracticedId = ref.watch(mostPracticedChapterProvider);

    String? chapterTitle(String? chapterId) {
      if (chapterId == null) return null;
      for (final subject in ref.watch(allSubjectsProvider)) {
        final chapters = ref.read(chaptersForSubjectProvider(subject.id));
        for (final ch in chapters) {
          if (ch.id == chapterId) return ch.title;
        }
      }
      return chapterId;
    }

    final rows = <Widget>[
      if (continueAttempt != null)
        _InsightRow(
          color: AppColors.primary,
          label: 'Continue learning',
          value: chapterTitle(continueAttempt.chapterId) ??
              continueAttempt.chapterId,
        ),
      if (weakestId != null)
        _InsightRow(
          color: AppColors.error,
          label: 'Needs work',
          value: chapterTitle(weakestId) ?? weakestId,
        ),
      if (strongestId != null && strongestId != weakestId)
        _InsightRow(
          color: AppColors.success,
          label: 'Strongest chapter',
          value: chapterTitle(strongestId) ?? strongestId,
        ),
      if (mostPracticedId != null)
        _InsightRow(
          color: AppColors.warning,
          label: 'Most practiced',
          value: chapterTitle(mostPracticedId) ?? mostPracticedId,
        ),
    ];

    if (rows.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('Insights'),
        AppGroup(children: rows),
      ],
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 28,
            decoration: BoxDecoration(
              color: color,
              borderRadius: AppRadius.radiusFull,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppText.micro),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.callout,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Recently solved ───────────────────────────────────────────────────────────

class _RecentlySolvedList extends StatelessWidget {
  const _RecentlySolvedList({required this.ref});

  final WidgetRef ref;

  static const int _maxVisible = 8;

  @override
  Widget build(BuildContext context) {
    final ids = ref.watch(recentlyCompletedQuestionsProvider);
    final visible = ids.take(_maxVisible).toList();

    if (visible.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('Recently solved'),
        AppGroup(
          children: [
            for (final id in visible) _RecentQuestionRow(questionId: id),
          ],
        ),
      ],
    );
  }
}

class _RecentQuestionRow extends ConsumerWidget {
  const _RecentQuestionRow({required this.questionId});

  final String questionId;

  /// Resolves question text from [questionId] by scanning all chapters.
  /// Falls back to the raw ID if the question cannot be found.
  String _resolveText(String questionId, WidgetRef ref) {
    for (final subject in ref.read(allSubjectsProvider)) {
      for (final chapter in ref.read(chaptersForSubjectProvider(subject.id))) {
        for (final q in ref.read(questionsForChapterProvider(chapter.id))) {
          if (q.id == questionId) return q.text;
        }
      }
    }
    return questionId;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = _resolveText(questionId, ref);
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppText.callout
                  .copyWith(fontWeight: FontWeight.w400, height: 1.45),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.check_rounded, size: 16, color: AppColors.success),
          ),
        ],
      ),
    );
  }
}
