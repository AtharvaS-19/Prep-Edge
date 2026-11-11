import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/chapter.dart';
import '../../subjects/models/subject_model.dart';
import '../../catalog/providers/catalog_provider.dart';
import '../../learning/models/chapter_progress.dart';
import '../../learning/providers/chapter_progress_provider.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_motion.dart';
import '../../../shared/constants/app_radius.dart';
import '../../../shared/constants/app_spacing.dart';
import '../../../shared/constants/app_text.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/pressable.dart';
import 'widgets/subject_progress_card.dart';
import 'widgets/chapter_card.dart';

/// Filter options for the chapter list.
enum ChapterFilter { all, inProgress, completed, notStarted }

extension ChapterFilterLabel on ChapterFilter {
  String get label => switch (this) {
        ChapterFilter.all => 'All',
        ChapterFilter.inProgress => 'In progress',
        ChapterFilter.completed => 'Completed',
        ChapterFilter.notStarted => 'Not started',
      };
}

/// The Chapter Dashboard Screen.
///
/// Displays overall subject progress (live from Learning Engine), a search bar,
/// filter chips, and the full chapter list. Filter logic is driven by live
/// [ChapterProgress] so "In progress" / "Completed" reflect actual attempts.
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

    if (_searchQuery.isNotEmpty) {
      result = result.where(
        (c) => c.title.toLowerCase().contains(_searchQuery),
      );
    }

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
        body: const EmptyState(
          icon: Icons.search_off_rounded,
          title: 'Subject not found',
          message: 'This subject is no longer available.',
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
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenHorizontal,
                    AppSpacing.xs,
                    AppSpacing.screenHorizontal,
                    0,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SubjectProgressCard(
                          subjectProgress: subjectProgress,
                          accentColor: _subject!.accentColor,
                          totalChapters: _allChapters.length,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _SearchBar(controller: _searchController),
                        const SizedBox(height: AppSpacing.sm),
                        _FilterChips(
                          active: _activeFilter,
                          onChanged: (f) => setState(() => _activeFilter = f),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                    ),
                  ),
                ),
                if (filtered.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'No chapters found',
                      message: 'Try a different search or filter.',
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenHorizontal,
                      0,
                      AppSpacing.screenHorizontal,
                      AppSpacing.xxl,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: AppGroup(
                        dividerInset: AppSpacing.md + 28,
                        children: [
                          for (final chapter in filtered)
                            ChapterCard(
                              key: ValueKey(chapter.id),
                              chapter: chapter,
                              accentColor: _subject!.accentColor,
                              // Original 1-based index keeps numbering stable
                              // while filtering.
                              index: _allChapters.indexOf(chapter) + 1,
                              progress: _progressFor(chapter.id),
                              onTap: () => _onChapterTapped(chapter),
                            ),
                        ],
                      ),
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

// ── Search bar ────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      cursorColor: AppColors.primary,
      style: AppText.callout.copyWith(fontWeight: FontWeight.w400),
      decoration: InputDecoration(
        hintText: 'Search chapters',
        hintStyle: AppText.callout
            .copyWith(color: AppColors.textTertiary, fontWeight: FontWeight.w400),
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: AppSpacing.md, right: AppSpacing.sm),
          child: Icon(Icons.search_rounded,
              size: 20, color: AppColors.iconSecondary),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (_, value, __) {
            if (value.text.isEmpty) return const SizedBox.shrink();
            return Pressable(
              onTap: controller.clear,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Icon(Icons.close_rounded,
                    size: 18, color: AppColors.iconSecondary),
              ),
            );
          },
        ),
        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        filled: true,
        fillColor: AppColors.cardBackground,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 13,
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
          borderSide: BorderSide(color: AppColors.borderFocused, width: 1.5),
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
            child: Pressable(
              onTap: () => onChanged(filter),
              child: AnimatedContainer(
                duration: AppMotion.fast,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color:
                      isActive ? AppColors.textPrimary : AppColors.cardBackground,
                  borderRadius: AppRadius.radiusFull,
                  border: Border.all(
                    color: isActive ? AppColors.textPrimary : AppColors.border,
                  ),
                ),
                child: Text(
                  filter.label,
                  style: AppText.captionStrong.copyWith(
                    color: isActive ? Colors.white : AppColors.textSecondary,
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
