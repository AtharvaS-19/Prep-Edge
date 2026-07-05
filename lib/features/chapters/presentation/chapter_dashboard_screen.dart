import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/chapter.dart';
import '../../subjects/models/subject_model.dart';
import '../../catalog/providers/catalog_provider.dart';
import '../../learning/models/chapter_progress.dart';
import '../../learning/providers/chapter_progress_provider.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_radius.dart';
import '../../../shared/constants/app_spacing.dart';
import 'widgets/subject_progress_card.dart';
import 'widgets/chapter_card.dart';

/// Filter options for the chapter list.
enum ChapterFilter { all, inProgress, completed, notStarted }

extension ChapterFilterLabel on ChapterFilter {
  String get label => switch (this) {
        ChapterFilter.all => 'All',
        ChapterFilter.inProgress => 'In Progress',
        ChapterFilter.completed => 'Completed',
        ChapterFilter.notStarted => 'Not Started',
      };
}

/// The Chapter Dashboard Screen.
///
/// Displays overall subject progress (live from Learning Engine), a search bar,
/// filter chips, and the full chapter list. Filter logic is driven by live
/// [ChapterProgress] so "In Progress" / "Completed" reflect actual attempts.
class ChapterDashboardScreen extends ConsumerStatefulWidget {
  const ChapterDashboardScreen({super.key, required this.subjectId});

  final String subjectId;

  @override
  ConsumerState<ChapterDashboardScreen> createState() =>
      _ChapterDashboardScreenState();
}

class _ChapterDashboardScreenState
    extends ConsumerState<ChapterDashboardScreen> {
  late final List<Chapter> _allChapters;
  late final SubjectModel? _subject;

  final TextEditingController _searchController = TextEditingController();
  ChapterFilter _activeFilter = ChapterFilter.all;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _allChapters = ref.read(chaptersForSubjectProvider(widget.subjectId));
    _subject = ref.read(subjectByIdProvider(widget.subjectId));
    _searchController.addListener(() {
      setState(
          () => _searchQuery = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Returns live [ChapterProgress] for [chapterId] from the Learning Engine.
  ChapterProgress _progressFor(String chapterId) =>
      ref.watch(chapterProgressProvider(chapterId));

  /// Applies the active search query and live-progress filter to the chapter list.
  List<Chapter> _filteredChapters() {
    Iterable<Chapter> result = _allChapters;

    // Apply search
    if (_searchQuery.isNotEmpty) {
      result = result.where(
        (c) => c.title.toLowerCase().contains(_searchQuery),
      );
    }

    // Apply filter using live ChapterProgress
    result = switch (_activeFilter) {
      ChapterFilter.all => result,
      ChapterFilter.inProgress => result.where((c) {
          final p = _progressFor(c.id);
          return p.hasActivity && !p.isCompleted;
        }),
      ChapterFilter.completed => result.where((c) {
          return _progressFor(c.id).isCompleted;
        }),
      ChapterFilter.notStarted => result.where((c) {
          return !_progressFor(c.id).hasActivity;
        }),
    };

    return result.toList();
  }

  void _onChapterTapped(Chapter chapter) {
    context.push(
      '/subjects/${widget.subjectId}/chapters/${chapter.id}/practice',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_subject == null) {
      return Scaffold(
        appBar: AppBar(backgroundColor: AppColors.background),
        body: const Center(
          child: Text(
            'Subject not found.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final filtered = _filteredChapters();
    final subjectProgress =
        ref.watch(subjectProgressProvider(widget.subjectId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(_subject!.name),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Progress card ────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.md,
                AppSpacing.screenHorizontal,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SubjectIntro(subject: _subject!),
                    const SizedBox(height: AppSpacing.lg),
                    SubjectProgressCard(
                      subjectProgress: subjectProgress,
                      accentColor: _subject!.accentColor,
                      totalChapters: _allChapters.length,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    // ── Search bar ───────────────────────────────────────────
                    _SearchBar(controller: _searchController),
                    const SizedBox(height: AppSpacing.sm),
                    // ── Filter chips ─────────────────────────────────────────
                    _FilterChips(
                      active: _activeFilter,
                      onChanged: (f) => setState(() => _activeFilter = f),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
            ),

            // ── Chapter list ─────────────────────────────────────────────────
            filtered.isEmpty
                ? const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenHorizontal,
                      0,
                      AppSpacing.screenHorizontal,
                      AppSpacing.xxl,
                    ),
                    sliver: SliverList.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.cardGap),
                      itemBuilder: (context, index) {
                        final chapter = filtered[index];
                        // Show original 1-based index for numbering
                        final originalIndex = _allChapters.indexOf(chapter) + 1;
                        final progress = _progressFor(chapter.id);
                        return ChapterCard(
                          key: ValueKey(chapter.id),
                          chapter: chapter,
                          accentColor: _subject!.accentColor,
                          index: originalIndex,
                          progress: progress,
                          onTap: () => _onChapterTapped(chapter),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

// ── Subject intro ─────────────────────────────────────────────────────────────

class _SubjectIntro extends StatelessWidget {
  const _SubjectIntro({required this.subject});
  final SubjectModel subject;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: subject.accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(subject.icon, size: 20, color: subject.accentColor),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subject.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              const Text(
                'Complete chapter-wise previous year questions',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Search bar ────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: 'Search chapters…',
        hintStyle: const TextStyle(
          fontSize: 14,
          color: AppColors.textTertiary,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Icon(Icons.search_rounded,
              size: 18, color: AppColors.iconSecondary),
        ),
        prefixIconConstraints:
            const BoxConstraints(minWidth: 44, minHeight: 44),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (_, value, __) {
            if (value.text.isEmpty) return const SizedBox.shrink();
            return GestureDetector(
              onTap: controller.clear,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Icon(Icons.close_rounded,
                    size: 16, color: AppColors.iconSecondary),
              ),
            );
          },
        ),
        filled: true,
        fillColor: AppColors.cardBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        border: const OutlineInputBorder(
          borderRadius: AppRadius.radiusLg,
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.radiusLg,
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadius.radiusLg,
          borderSide: BorderSide(color: AppColors.borderFocused, width: 2),
        ),
      ),
    );
  }
}

// ── Filter chips ──────────────────────────────────────────────────────────────

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.active, required this.onChanged});

  final ChapterFilter active;
  final ValueChanged<ChapterFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ChapterFilter.values.map((filter) {
          final bool isActive = filter == active;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xs),
            child: GestureDetector(
              onTap: () => onChanged(filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                      isActive ? AppColors.primary : AppColors.cardBackground,
                  borderRadius: AppRadius.radiusFull,
                  border: Border.all(
                    color: isActive ? AppColors.primary : AppColors.border,
                    width: isActive ? 1.5 : 0.75,
                  ),
                ),
                child: Text(
                  filter.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isActive
                        ? AppColors.textOnPrimary
                        : AppColors.textSecondary,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 24,
                color: AppColors.iconSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'No chapters found',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            const Text(
              'Try a different search or filter.',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
