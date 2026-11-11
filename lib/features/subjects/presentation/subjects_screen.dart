import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../catalog/providers/catalog_provider.dart';
import '../models/subject_model.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_motion.dart';
import '../../../shared/constants/app_radius.dart';
import '../../../shared/constants/app_spacing.dart';
import '../../../shared/constants/app_text.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/reveal.dart';
import '../../../shared/widgets/section_header.dart';

/// The Subjects screen.
///
/// Lets students switch between Engineering and Medical streams and tap a
/// subject to enter its chapter list. State is local — a single [ExamStream]
/// value drives the filtered list.
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
      body: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ScreenHeader(
                  title: 'Subjects',
                  subtitle: 'Previous-year questions, chapter by chapter.',
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: _StreamSelector(
                    selected: _selectedStream,
                    onChanged: _onStreamChanged,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: AppMotion.base,
                    switchInCurve: AppMotion.standard,
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
        ),
      ),
    );
  }
}

// ── Stream selector ────────────────────────────────────────────────────────────

class _StreamSelector extends StatelessWidget {
  const _StreamSelector({required this.selected, required this.onChanged});

  final ExamStream selected;
  final ValueChanged<ExamStream> onChanged;

  @override
  Widget build(BuildContext context) {
    const streams = ExamStream.values;
    final selectedIndex = streams.indexOf(selected);

    return Container(
      height: 42,
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(
        color: AppColors.cardBackgroundAlt,
        borderRadius: AppRadius.radiusLg,
      ),
      child: LayoutBuilder(builder: (context, c) {
        final segmentWidth = c.maxWidth / streams.length;
        return Stack(
          children: [
            AnimatedPositioned(
              duration: AppMotion.base,
              curve: AppMotion.standard,
              left: segmentWidth * selectedIndex,
              width: segmentWidth,
              top: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14101828),
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                for (final stream in streams)
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onChanged(stream),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: AppMotion.fast,
                          style: AppText.callout.copyWith(
                            color: stream == selected
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            fontWeight: stream == selected
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                          child: Text(stream.label),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      }),
    );
  }
}

// ── Subject list ───────────────────────────────────────────────────────────────

class _SubjectList extends StatelessWidget {
  const _SubjectList({super.key, required this.subjects, required this.onTap});

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
      itemBuilder: (context, index) => Reveal(
        index: index,
        child: _SubjectCard(
          subject: subjects[index],
          onTap: () => onTap(subjects[index]),
        ),
      ),
    );
  }
}

// ── Subject card ───────────────────────────────────────────────────────────────

class _SubjectCard extends StatelessWidget {
  const _SubjectCard({required this.subject, required this.onTap});

  final SubjectModel subject;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: subject.accentColor.withValues(alpha: 0.1),
              borderRadius: AppRadius.radiusMd,
            ),
            child: Icon(subject.icon, size: 22, color: subject.accentColor),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subject.name, style: AppText.headline),
                const SizedBox(height: 3),
                Text(
                  '${subject.formattedQuestions}  ·  ${subject.examTags.join(', ')}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.caption,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              size: 22, color: AppColors.iconSecondary),
        ],
      ),
    );
  }
}
