import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../catalog/providers/catalog_provider.dart';
import '../../subjects/models/subject_model.dart';
import '../../bookmarks/providers/bookmark_provider.dart';
import '../../mistakes/providers/mistakes_provider.dart';
import '../../learning/providers/progress_stats_provider.dart';
import '../../learning/providers/chapter_progress_provider.dart';
import '../../learning/providers/learning_insights_provider.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_radius.dart';
import '../../../shared/constants/app_spacing.dart';
import '../../../shared/widgets/app_logo.dart';

/// Home Screen — UI Review Pass.
///
/// Answers: "What should I do next?"
/// All data sourced from existing providers. No business logic here.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(progressStatsProvider);
    final continueAttempt = ref.watch(continueLearningProvider);
    final bookmarks = ref.watch(bookmarkProvider);
    final mistakes = ref.watch(mistakesProvider);
    final hasActivity = stats.hasActivity;
    final hasSnapshotData = hasActivity ||
        bookmarks.isNotEmpty ||
        mistakes.isNotEmpty;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              AppSpacing.xl,
              AppSpacing.screenHorizontal,
              AppSpacing.xxxl,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── 1. Greeting ───────────────────────────────────────────────
                const _WelcomeHeader(),
                const SizedBox(height: AppSpacing.xxl),

                // ── 2. Continue Learning (primary card) ───────────────────────
                _ContinueLearningCard(attempt: continueAttempt, ref: ref),
                const SizedBox(height: AppSpacing.xxl),

                // ── 3. Today's Snapshot ───────────────────────────────────────
                if (hasSnapshotData) ...[
                  const _SectionLabel("Today's snapshot"),
                  const SizedBox(height: AppSpacing.sm),
                  _TodaysSnapshot(
                    attempted: stats.totalAttempts,
                    accuracyPercent: stats.accuracyPercent,
                    bookmarkCount: bookmarks.length,
                    mistakeCount: mistakes.length,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],

                // ── 4. Quick Actions ──────────────────────────────────────────
                const _SectionLabel('Quick actions'),
                const SizedBox(height: AppSpacing.sm),
                const _QuickActionsRow(),
                const SizedBox(height: AppSpacing.xxl),

                // ── 5. Insights (only when enough activity) ───────────────────
                if (hasActivity) ...[
                  const _SectionLabel('Insights'),
                  const SizedBox(height: AppSpacing.sm),
                  _InsightsRow(ref: ref),
                  const SizedBox(height: AppSpacing.xxl),
                ],

                // ── 6. Subjects ───────────────────────────────────────────────
                const _SectionLabel('Subjects'),
                const SizedBox(height: AppSpacing.sm),
                _SubjectProgressColumn(ref: ref),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 1. Greeting ───────────────────────────────────────────────────────────────

const String _motivationalSubtitle = 'Consistency beats intensity.';

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Compact PrepEdge icon — subtle brand anchor
        AppLogo(size: 32, showLabel: false, showTagline: false),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hey, Arjun 👋',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 3),
              Text(
                _motivationalSubtitle,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: AppSpacing.md),
        _Avatar(initial: 'A'),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initial});
  final String initial;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(11),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
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

// ── 2. Continue Learning ──────────────────────────────────────────────────────

class _ContinueLearningCard extends StatelessWidget {
  const _ContinueLearningCard({
    required this.attempt,
    required this.ref,
  });

  final dynamic attempt; // QuestionAttempt?
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    if (attempt == null) {
      return const _ContinueLearningEmpty();
    }

    // Resolve chapter title from chapterId
    String chapterTitle = attempt.chapterId;
    String subjectName = '';
    for (final subject in ref.watch(allSubjectsProvider)) {
      final chapters = ref.watch(chaptersForSubjectProvider(subject.id));
      for (final ch in chapters) {
        if (ch.id == attempt.chapterId) {
          chapterTitle = ch.title;
          subjectName = subject.name;
          break;
        }
      }
      if (subjectName.isNotEmpty) break;
    }

    final progress = ref.watch(chapterProgressProvider(attempt.chapterId));

    return GestureDetector(
      onTap: () => context.push(
        '/subjects/${attempt.subjectId}/chapters/${attempt.chapterId}/practice',
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: AppRadius.radiusXxl,
        ),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subject badge
            _WhiteBadge(
              label: subjectName.isNotEmpty ? subjectName : attempt.subjectId,
            ),
            const SizedBox(height: AppSpacing.sm),
            // Chapter title
            Text(
              chapterTitle,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              progress.hasActivity
                  ? '${progress.attemptedQuestions} of ${progress.totalQuestions} attempted'
                  : '${progress.totalQuestions} questions',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white70,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Progress bar
            ClipRRect(
              borderRadius: AppRadius.radiusFull,
              child: LinearProgressIndicator(
                value: progress.completionPercentage,
                minHeight: 5,
                backgroundColor: Colors.white.withValues(alpha: 0.22),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${progress.completionPercent}% complete',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white60,
                  ),
                ),
                if (progress.hasActivity)
                  Text(
                    '${progress.accuracyPercent}% accuracy',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white60,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            // Resume button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () => context.push(
                  '/subjects/${attempt.subjectId}/chapters/${attempt.chapterId}/practice',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.radiusLg,
                  ),
                ),
                child: const Text(
                  'Resume',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown when no learning history exists yet.
class _ContinueLearningEmpty extends StatelessWidget {
  const _ContinueLearningEmpty();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppRadius.radiusXxl,
        border: Border.all(color: AppColors.border, width: 0.75),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 16,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.play_circle_outline_rounded,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Start your first session',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          const Text(
            'Pick any chapter from Subjects and start solving questions.',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () => context.go('/subjects'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.radiusLg,
                ),
              ),
              child: const Text(
                'Browse subjects',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WhiteBadge extends StatelessWidget {
  const _WhiteBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

// ── 3. Today's Snapshot ───────────────────────────────────────────────────────
//
// 2×2 grid showing all four real stats from existing providers.

class _TodaysSnapshot extends StatelessWidget {
  const _TodaysSnapshot({
    required this.attempted,
    required this.accuracyPercent,
    required this.bookmarkCount,
    required this.mistakeCount,
  });

  final int attempted;
  final int accuracyPercent;
  final int bookmarkCount;
  final int mistakeCount;

  static Color _accuracyColor(int percent) {
    if (percent >= 80) return AppColors.success;
    if (percent >= 50) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatChip(
                icon: Icons.check_circle_outline_rounded,
                value: '$attempted',
                label: 'Attempted',
                accentColor: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.cardGap),
            Expanded(
              child: _StatChip(
                icon: Icons.track_changes_outlined,
                value: attempted > 0 ? '$accuracyPercent%' : '—',
                label: 'Accuracy',
                accentColor: attempted > 0
                    ? _accuracyColor(accuracyPercent)
                    : AppColors.textTertiary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.cardGap),
        Row(
          children: [
            Expanded(
              child: _StatChip(
                icon: Icons.bookmark_outline_rounded,
                value: '$bookmarkCount',
                label: 'Bookmarks',
                accentColor: AppColors.mathAccent,
              ),
            ),
            const SizedBox(width: AppSpacing.cardGap),
            Expanded(
              child: _StatChip(
                icon: Icons.highlight_off_outlined,
                value: '$mistakeCount',
                label: 'Mistakes',
                accentColor: mistakeCount > 0
                    ? AppColors.error
                    : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.accentColor,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color accentColor;

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
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 3),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: accentColor),
          const SizedBox(width: AppSpacing.xs),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
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

// ── 4. Quick Actions ──────────────────────────────────────────────────────────

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            icon: Icons.bookmark_outline_rounded,
            label: 'Bookmarks',
            accentColor: AppColors.mathAccent,
            onTap: () => context.go('/bookmarks'),
          ),
        ),
        const SizedBox(width: AppSpacing.cardGap),
        Expanded(
          child: _ActionCard(
            icon: Icons.highlight_off_outlined,
            label: 'Mistakes',
            accentColor: AppColors.error,
            onTap: () => context.go('/mistakes'),
          ),
        ),
        const SizedBox(width: AppSpacing.cardGap),
        Expanded(
          child: _ActionCard(
            icon: Icons.bar_chart_outlined,
            label: 'Progress',
            accentColor: AppColors.chemistryAccent,
            onTap: () => context.go('/progress'),
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.accentColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.sm,
        ),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 17, color: accentColor),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 5. Insights ───────────────────────────────────────────────────────────────

class _InsightsRow extends StatelessWidget {
  const _InsightsRow({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final weakestId = ref.watch(weakestChapterProvider);
    final mostPracticedId = ref.watch(mostPracticedChapterProvider);

    if (weakestId == null && mostPracticedId == null) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        if (weakestId != null)
          Expanded(
            child: _InsightChip(
              icon: Icons.trending_down_rounded,
              accentColor: AppColors.error,
              label: 'Needs work',
              value: _chapterTitle(weakestId),
            ),
          ),
        if (weakestId != null && mostPracticedId != null)
          const SizedBox(width: AppSpacing.cardGap),
        if (mostPracticedId != null)
          Expanded(
            child: _InsightChip(
              icon: Icons.repeat_rounded,
              accentColor: AppColors.warning,
              label: 'Most practiced',
              value: _chapterTitle(mostPracticedId),
            ),
          ),
      ],
    );
  }

  String _chapterTitle(String chapterId) {
    for (final subject in ref.watch(allSubjectsProvider)) {
      for (final ch in ref.watch(chaptersForSubjectProvider(subject.id))) {
        if (ch.id == chapterId) return ch.title;
      }
    }
    return chapterId;
  }
}

class _InsightChip extends StatelessWidget {
  const _InsightChip({
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
          Icon(icon, size: 16, color: accentColor),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── 6. Subjects ───────────────────────────────────────────────────────────────

class _SubjectProgressColumn extends StatelessWidget {
  const _SubjectProgressColumn({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: ref.watch(allSubjectsProvider).map((subject) {
        final progress = ref.watch(subjectProgressProvider(subject.id));
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.cardGap),
          child: _SubjectProgressRow(
            subject: subject,
            completionPercent: progress.completionPercent,
            completionFraction: progress.completionPercentage,
            onTap: () => context.go('/subjects'),
          ),
        );
      }).toList(),
    );
  }
}

class _SubjectProgressRow extends StatelessWidget {
  const _SubjectProgressRow({
    required this.subject,
    required this.completionPercent,
    required this.completionFraction,
    required this.onTap,
  });

  final SubjectModel subject;
  final int completionPercent;
  final double completionFraction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: AppRadius.radiusLg,
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
            // Accent dot
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: subject.accentColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          subject.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        '$completionPercent%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  ClipRRect(
                    borderRadius: AppRadius.radiusFull,
                    child: LinearProgressIndicator(
                      value: completionFraction,
                      minHeight: 3,
                      backgroundColor: AppColors.progressTrack,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        subject.accentColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: AppColors.iconSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
