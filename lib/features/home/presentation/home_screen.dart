import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';
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
import '../../../shared/constants/app_text.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_progress_bar.dart';
import '../../../shared/widgets/pressable.dart';
import '../../../shared/widgets/reveal.dart';
import '../../../shared/widgets/section_header.dart';

/// Home — answers "What should I do next?"
///
/// All data is sourced from existing providers. No business logic here.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(progressStatsProvider);
    final continueAttempt = ref.watch(continueLearningProvider);
    final bookmarks = ref.watch(bookmarkProvider);
    final mistakes = ref.watch(mistakesProvider);
    final hasActivity = stats.hasActivity;
    final hasSnapshotData =
        hasActivity || bookmarks.isNotEmpty || mistakes.isNotEmpty;

    return SafeArea(
      bottom: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              AppSpacing.md,
              AppSpacing.screenHorizontal,
              AppSpacing.xxl,
            ),
            children: [
              const Reveal(child: _Greeting()),
              const SizedBox(height: AppSpacing.xl),
              Reveal(
                index: 1,
                child: _ContinueLearningCard(attempt: continueAttempt, ref: ref),
              ),
              if (hasSnapshotData) ...[
                const SizedBox(height: AppSpacing.xl),
                Reveal(
                  index: 2,
                  child: _Snapshot(
                    attempted: stats.totalAttempts,
                    accuracyPercent: stats.accuracyPercent,
                    bookmarkCount: bookmarks.length,
                    mistakeCount: mistakes.length,
                  ),
                ),
              ],
              if (hasActivity) ...[
                const SizedBox(height: AppSpacing.xxl),
                Reveal(index: 3, child: _Insights(ref: ref)),
              ],
              const SizedBox(height: AppSpacing.xxl),
              Reveal(index: 4, child: _SubjectsSection(ref: ref)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Greeting ──────────────────────────────────────────────────────────────────

class _Greeting extends ConsumerWidget {
  const _Greeting();

  static String _salutation() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = ref.watch(authStateProvider).value?.email;
    final initial = (email != null && email.isNotEmpty)
        ? email.substring(0, 1).toUpperCase()
        : null;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_salutation(), style: AppText.display.copyWith(fontSize: 26)),
              const SizedBox(height: 4),
              Text(
                'Consistency beats intensity.',
                style: AppText.callout.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: initial != null
              ? Text(
                  initial,
                  style: AppText.callout.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                )
              : const Icon(Icons.person_outline_rounded,
                  size: 20, color: AppColors.primary),
        ),
      ],
    );
  }
}

// ── Continue learning ─────────────────────────────────────────────────────────

class _ContinueLearningCard extends StatelessWidget {
  const _ContinueLearningCard({required this.attempt, required this.ref});

  final dynamic attempt; // QuestionAttempt?
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    if (attempt == null) return const _ContinueEmpty();

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
    void open() => context.push(
          '/subjects/${attempt.subjectId}/chapters/${attempt.chapterId}/practice',
        );

    return Pressable(
      onTap: open,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: AppRadius.radiusXxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Continue · ${subjectName.isNotEmpty ? subjectName : attempt.subjectId}',
              style: AppText.captionStrong
                  .copyWith(color: Colors.white.withValues(alpha: 0.72)),
            ),
            const SizedBox(height: 6),
            Text(
              chapterTitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppText.title.copyWith(color: Colors.white, fontSize: 22),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppProgressBar(
              value: progress.completionPercentage,
              color: Colors.white,
              trackColor: Colors.white.withValues(alpha: 0.22),
              height: 5,
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: Text(
                    progress.hasActivity
                        ? '${progress.attemptedQuestions} of ${progress.totalQuestions} attempted'
                        : '${progress.totalQuestions} questions',
                    style: AppText.caption
                        .copyWith(color: Colors.white.withValues(alpha: 0.78)),
                  ),
                ),
                if (progress.hasActivity)
                  Text(
                    '${progress.accuracyPercent}% accuracy',
                    style: AppText.caption
                        .copyWith(color: Colors.white.withValues(alpha: 0.78)),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              height: 46,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.radiusLg,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Resume',
                    style: AppText.button.copyWith(color: AppColors.primary),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward_rounded,
                      size: 18, color: AppColors.primary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContinueEmpty extends StatelessWidget {
  const _ContinueEmpty();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      radius: AppRadius.radiusXxl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Start your first session', style: AppText.title),
          const SizedBox(height: 6),
          Text(
            'Pick a chapter from Subjects and solve a few previous-year questions.',
            style: AppText.callout.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Pressable(
            onTap: () => context.go('/subjects'),
            child: Container(
              height: 46,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: AppRadius.radiusLg,
              ),
              child: Text('Browse subjects',
                  style: AppText.button.copyWith(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Snapshot ──────────────────────────────────────────────────────────────────
//
// One card, four numbers. Each cell is a shortcut to its screen.

class _Snapshot extends StatelessWidget {
  const _Snapshot({
    required this.attempted,
    required this.accuracyPercent,
    required this.bookmarkCount,
    required this.mistakeCount,
  });

  final int attempted;
  final int accuracyPercent;
  final int bookmarkCount;
  final int mistakeCount;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _StatCell(
              value: '$attempted',
              label: 'Attempted',
              onTap: () => context.go('/progress'),
            ),
            const _VDivider(),
            _StatCell(
              value: attempted > 0 ? '$accuracyPercent%' : '–',
              label: 'Accuracy',
              onTap: () => context.go('/progress'),
            ),
            const _VDivider(),
            _StatCell(
              value: '$bookmarkCount',
              label: 'Saved',
              onTap: () => context.go('/bookmarks'),
            ),
            const _VDivider(),
            _StatCell(
              value: '$mistakeCount',
              label: 'Mistakes',
              onTap: () => context.go('/mistakes'),
            ),
          ],
        ),
      ),
    );
  }
}

class _VDivider extends StatelessWidget {
  const _VDivider();

  @override
  Widget build(BuildContext context) =>
      const VerticalDivider(width: 1, thickness: 1, color: AppColors.divider);
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.value,
    required this.label,
    required this.onTap,
  });

  final String value;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Pressable(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: AppText.stat.copyWith(fontSize: 20)),
            const SizedBox(height: 4),
            Text(label, style: AppText.micro),
          ],
        ),
      ),
    );
  }
}

// ── Insights ──────────────────────────────────────────────────────────────────

class _Insights extends StatelessWidget {
  const _Insights({required this.ref});

  final WidgetRef ref;

  String _chapterTitle(String chapterId) {
    for (final subject in ref.watch(allSubjectsProvider)) {
      for (final ch in ref.watch(chaptersForSubjectProvider(subject.id))) {
        if (ch.id == chapterId) return ch.title;
      }
    }
    return chapterId;
  }

  @override
  Widget build(BuildContext context) {
    final weakestId = ref.watch(weakestChapterProvider);
    final mostPracticedId = ref.watch(mostPracticedChapterProvider);

    if (weakestId == null && mostPracticedId == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('Insights'),
        AppGroup(
          children: [
            if (weakestId != null)
              _InsightRow(
                label: 'Needs work',
                value: _chapterTitle(weakestId),
                color: AppColors.error,
              ),
            if (mostPracticedId != null)
              _InsightRow(
                label: 'Most practiced',
                value: _chapterTitle(mostPracticedId),
                color: AppColors.primary,
              ),
          ],
        ),
      ],
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

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

// ── Subjects ──────────────────────────────────────────────────────────────────

class _SubjectsSection extends StatelessWidget {
  const _SubjectsSection({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final subjects = ref.watch(allSubjectsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          'Subjects',
          action: 'See all',
          onAction: () => context.go('/subjects'),
        ),
        AppGroup(
          children: [
            for (final subject in subjects)
              _SubjectRow(
                subject: subject,
                progress: ref.watch(subjectProgressProvider(subject.id)),
                onTap: () => context.go('/subjects'),
              ),
          ],
        ),
      ],
    );
  }
}

class _SubjectRow extends StatelessWidget {
  const _SubjectRow({
    required this.subject,
    required this.progress,
    required this.onTap,
  });

  final SubjectModel subject;
  final dynamic progress; // SubjectProgress
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.md),
        child: Row(
          children: [
            Icon(subject.icon, size: 20, color: subject.accentColor),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
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
                      Text(
                        '${progress.completionPercent}%',
                        style: AppText.caption,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  AppProgressBar(
                    value: progress.completionPercentage,
                    color: subject.accentColor,
                    height: 4,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
