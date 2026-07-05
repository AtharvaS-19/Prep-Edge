import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../catalog/providers/catalog_provider.dart';
import '../models/subject_model.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_radius.dart';
import '../../../shared/constants/app_spacing.dart';

/// The Subjects screen — Phase 2.
///
/// Allows students to switch between Engineering and Medical streams
/// and tap a subject to enter its chapter list.
///
/// State is local — a single [ExamStream] value drives the filtered list.
/// No Riverpod needed here; the complexity doesn't justify it.
class SubjectsScreen extends ConsumerStatefulWidget {
  const SubjectsScreen({super.key});

  @override
  ConsumerState<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends ConsumerState<SubjectsScreen> {
  ExamStream _selectedStream = ExamStream.engineering;

  void _onStreamChanged(ExamStream stream) {
    if (_selectedStream == stream) return;
    setState(() => _selectedStream = stream);
  }

  void _onSubjectTapped(SubjectModel subject) {
    context.push('/subjects/${subject.id}');
  }

  @override
  Widget build(BuildContext context) {
    final subjects = ref.watch(subjectsForStreamProvider(_selectedStream));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Subjects'),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stream selector — pinned below the AppBar
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.xs,
                AppSpacing.screenHorizontal,
                0,
              ),
              child: _StreamSelector(
                selected: _selectedStream,
                onChanged: _onStreamChanged,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            // Subject list — scrollable
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: _SubjectList(
                  key: ValueKey(_selectedStream),
                  subjects: subjects,
                  onTap: _onSubjectTapped,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stream selector ────────────────────────────────────────────────────────────

class _StreamSelector extends StatelessWidget {
  const _StreamSelector({
    required this.selected,
    required this.onChanged,
  });

  final ExamStream selected;
  final ValueChanged<ExamStream> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundAlt,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: AppColors.border, width: 0.75),
      ),
      child: Row(
        children: ExamStream.values.map((stream) {
          final bool isSelected = stream == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(stream),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.07),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          )
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  stream.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? AppColors.textPrimary
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

// ── Subject list ───────────────────────────────────────────────────────────────

class _SubjectList extends StatelessWidget {
  const _SubjectList({
    super.key,
    required this.subjects,
    required this.onTap,
  });

  final List<SubjectModel> subjects;
  final ValueChanged<SubjectModel> onTap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        0,
        AppSpacing.screenHorizontal,
        AppSpacing.xxl,
      ),
      itemCount: subjects.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.cardGap),
      itemBuilder: (context, index) => _SubjectCard(
        subject: subjects[index],
        onTap: () => onTap(subjects[index]),
      ),
    );
  }
}

// ── Subject card ───────────────────────────────────────────────────────────────

class _SubjectCard extends StatelessWidget {
  const _SubjectCard({
    required this.subject,
    required this.onTap,
  });

  final SubjectModel subject;
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
            // Subject icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: subject.accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(subject.icon, size: 22, color: subject.accentColor),
            ),
            const SizedBox(width: AppSpacing.md),
            // Name + meta
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        subject.formattedQuestions,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      // Exam tags
                      ...subject.examTags.map(
                        (tag) => Padding(
                          padding: const EdgeInsets.only(left: AppSpacing.xxs),
                          child: _ExamTag(label: tag),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.iconSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _ExamTag extends StatelessWidget {
  const _ExamTag({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}
