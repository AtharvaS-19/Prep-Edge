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

/// Progress Screen — Phase 9.
///
/// Reads only from existing derived providers — no business logic in the UI.
/// Layout: Header → Overall stats → Subject progress → Insights → Recently solved.
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(progressStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Progress'),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.lg,
                AppSpacing.screenHorizontal,
                AppSpacing.xxxl,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Header ────────────────────────────────────────────────
                  _Header(hasActivity: stats.hasActivity),
                  const SizedBox(height: AppSpacing.xxl),

                  // ── Overall statistics ────────────────────────────────────
                  const _SectionLabel(label: 'Overview'),
                  const SizedBox(height: AppSpacing.sm),
                  _OverviewRow(
                    attempted: stats.totalAttempts,
                    accuracyPercent:
                        stats.hasActivity ? stats.accuracyPercent : null,
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // ── Subject progress ──────────────────────────────────────
                  const _SectionLabel(label: 'Subjects'),
                  const SizedBox(height: AppSpacing.sm),
                  _SubjectProgressList(ref: ref),
                  const SizedBox(height: AppSpacing.xxl),

                  // ── Insights ──────────────────────────────────────────────
                  if (stats.hasActivity) ...[
                    const _SectionLabel(label: 'Insights'),
                    const SizedBox(height: AppSpacing.sm),
                    _InsightsPanel(ref: ref),
                    const SizedBox(height: AppSpacing.xxl),
                  ],

                  // ── Recently solved ───────────────────────────────────────
                  if (stats.hasActivity) ...[
                    const _SectionLabel(label: 'Recently solved'),
                    const SizedBox(height: AppSpacing.sm),
                    _RecentlySolvedList(ref: ref),
                  ],
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.hasActivity});

  final bool hasActivity;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Learning Progress',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          hasActivity
              ? 'Keep showing up. Progress compounds.'
              : 'Solve questions to start tracking your progress.',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textTertiary,
        letterSpacing: 0.8,
      ),
    );
  }
}

// ── Overview row ──────────────────────────────────────────────────────────────

class _OverviewRow extends StatelessWidget {
  const _OverviewRow({
    required this.attempted,
    required this.accuracyPercent,
  });

  final int attempted;
  final int? accuracyPercent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Questions attempted',
            value: attempted > 0 ? '$attempted' : '—',
            icon: Icons.check_circle_outline_rounded,
            accentColor: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.cardGap),
        Expanded(
          child: _StatCard(
            label: 'Accuracy',
            value: accuracyPercent != null ? '$accuracyPercent%' : '—',
            icon: Icons.track_changes_outlined,
            accentColor: accuracyPercent != null
                ? _accuracyColor(accuracyPercent!)
                : AppColors.iconSecondary,
          ),
        ),
      ],
    );
  }

  static Color _accuracyColor(int percent) {
    if (percent >= 80) return AppColors.success;
    if (percent >= 50) return AppColors.warning;
    return AppColors.error;
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
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
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: accentColor),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
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
      children: ref
          .watch(allSubjectsProvider)
          .map(
            (subject) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.cardGap),
              child: _SubjectProgressTile(subject: subject, ref: ref),
            ),
          )
          .toList(),
    );
  }
}

class _SubjectProgressTile extends StatelessWidget {
  const _SubjectProgressTile({
    required this.subject,
    required this.ref,
  });

  final SubjectModel subject;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(subjectProgressProvider(subject.id));

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: AppColors.border, width: 0.75),
        boxShadow: const [
          BoxShadow(
            color: Color(0x07000000),
            blurRadius: 8,
            offset: Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Name + stream tag ─────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: subject.accentColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  subject.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                subject.stream.label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textTertiary,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // ── Progress bar ──────────────────────────────────────────────
          ClipRRect(
            borderRadius: AppRadius.radiusFull,
            child: LinearProgressIndicator(
              value: progress.completionPercentage,
              minHeight: 4,
              backgroundColor: AppColors.progressTrack,
              valueColor: AlwaysStoppedAnimation<Color>(subject.accentColor),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),

          // ── Stats row ─────────────────────────────────────────────────
          Row(
            children: [
              Text(
                '${progress.completionPercent}% complete',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              if (progress.hasActivity)
                Text(
                  '${progress.accuracyPercent}% accuracy',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                  ),
                )
              else
                const Text(
                  'Not started',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textTertiary,
                  ),
                ),
            ],
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

    return Column(
      children: [
        if (continueAttempt != null)
          _InsightTile(
            icon: Icons.play_circle_outline_rounded,
            accentColor: AppColors.primary,
            label: 'Continue learning',
            value: chapterTitle(continueAttempt.chapterId) ??
                continueAttempt.chapterId,
          ),
        if (weakestId != null) ...[
          const SizedBox(height: AppSpacing.cardGap),
          _InsightTile(
            icon: Icons.trending_down_rounded,
            accentColor: AppColors.error,
            label: 'Needs work',
            value: chapterTitle(weakestId) ?? weakestId,
          ),
        ],
        if (strongestId != null && strongestId != weakestId) ...[
          const SizedBox(height: AppSpacing.cardGap),
          _InsightTile(
            icon: Icons.trending_up_rounded,
            accentColor: AppColors.success,
            label: 'Strongest chapter',
            value: chapterTitle(strongestId) ?? strongestId,
          ),
        ],
        if (mostPracticedId != null) ...[
          const SizedBox(height: AppSpacing.cardGap),
          _InsightTile(
            icon: Icons.repeat_rounded,
            accentColor: AppColors.warning,
            label: 'Most practiced',
            value: chapterTitle(mostPracticedId) ?? mostPracticedId,
          ),
        ],
      ],
    );
  }
}

class _InsightTile extends StatelessWidget {
  const _InsightTile({
    required this.icon,
    required this.accentColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color accentColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: AppColors.border, width: 0.75),
        boxShadow: const [
          BoxShadow(
            color: Color(0x07000000),
            blurRadius: 8,
            offset: Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: accentColor),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
      children: [
        for (int i = 0; i < visible.length; i++) ...[
          if (i > 0) const Divider(height: 1, color: AppColors.divider),
          _RecentQuestionRow(questionId: visible[i], index: i + 1),
        ],
      ],
    );
  }
}

class _RecentQuestionRow extends ConsumerWidget {
  const _RecentQuestionRow({
    required this.questionId,
    required this.index,
  });

  final String questionId;
  final int index;

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
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
            child: Text(
              '$index',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          const Icon(
            Icons.check_rounded,
            size: 14,
            color: AppColors.success,
          ),
        ],
      ),
    );
  }
}
