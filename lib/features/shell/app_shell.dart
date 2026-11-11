import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_motion.dart';
import '../../shared/constants/app_text.dart';

/// The persistent application shell.
///
/// GoRouter's [ShellRoute] swaps [child] (the active tab's screen) while this
/// scaffold and its bottom navigation stay mounted. The bar hides itself on
/// focused flows (practice / result) so it never stacks with their own
/// bottom action bar.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  /// The currently active tab's screen, injected by GoRouter's ShellRoute.
  final Widget child;

  static const List<_TabDestination> _destinations = [
    _TabDestination(
      path: '/home',
      label: 'Home',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
    ),
    _TabDestination(
      path: '/subjects',
      label: 'Subjects',
      icon: Icons.grid_view_outlined,
      selectedIcon: Icons.grid_view_rounded,
    ),
    _TabDestination(
      path: '/bookmarks',
      label: 'Saved',
      icon: Icons.bookmark_outline_rounded,
      selectedIcon: Icons.bookmark_rounded,
    ),
    _TabDestination(
      path: '/mistakes',
      label: 'Mistakes',
      icon: Icons.highlight_off_outlined,
      selectedIcon: Icons.highlight_off_rounded,
    ),
    _TabDestination(
      path: '/progress',
      label: 'Progress',
      icon: Icons.bar_chart_outlined,
      selectedIcon: Icons.bar_chart_rounded,
    ),
  ];

  /// Derives the selected index from the current router location.
  static int _locationToIndex(String location) {
    for (int i = 0; i < _destinations.length; i++) {
      if (location.startsWith(_destinations[i].path)) return i;
    }
    return 0;
  }

  /// Focused flows own the full screen.
  static bool _isFocusedFlow(String location) =>
      location.contains('/practice') || location.contains('/result');

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    final int activeIndex = _locationToIndex(location);
    final bool showBar = !_isFocusedFlow(location);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: child,
      bottomNavigationBar: showBar
          ? _NavBar(
              selectedIndex: activeIndex,
              destinations: _destinations,
              onDestinationSelected: (index) {
                if (index == activeIndex) return;
                HapticFeedback.selectionClick();
                context.go(_destinations[index].path);
              },
            )
          : null,
    );
  }
}

// ── Navigation bar ─────────────────────────────────────────────────────────────

class _NavBar extends StatelessWidget {
  const _NavBar({
    required this.selectedIndex,
    required this.destinations,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final List<_TabDestination> destinations;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 58,
          child: Row(
            children: [
              for (int i = 0; i < destinations.length; i++)
                _NavItem(
                  destination: destinations[i],
                  isSelected: i == selectedIndex,
                  onTap: () => onDestinationSelected(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.isSelected,
    required this.onTap,
  });

  final _TabDestination destination;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color =
        isSelected ? AppColors.primary : AppColors.textTertiary;

    return Expanded(
      child: Semantics(
        button: true,
        selected: isSelected,
        label: destination.label,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: AppMotion.fast,
                child: Icon(
                  isSelected ? destination.selectedIcon : destination.icon,
                  key: ValueKey<bool>(isSelected),
                  size: 24,
                  color: color,
                ),
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: AppMotion.fast,
                style: AppText.micro.copyWith(
                  color: color,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                child: Text(
                  destination.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabDestination {
  const _TabDestination({
    required this.path,
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String path;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
