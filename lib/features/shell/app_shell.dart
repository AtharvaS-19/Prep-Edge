import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_radius.dart';
import '../../shared/constants/app_spacing.dart';

/// The persistent application shell.
///
/// Rendered once for the lifetime of the app session. GoRouter's [ShellRoute]
/// swaps the [child] (the active tab's screen) while this scaffold and its
/// bottom navigation remain mounted and never rebuild on tab switch.
///
/// State preservation: each tab's subtree stays alive via [IndexedStack],
/// so scroll positions, form input, and local state survive tab switches.
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.child});

  /// The currently active tab's screen, injected by GoRouter's ShellRoute.
  final Widget child;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  // Maps a tab index to its root route path.
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
      label: 'Bookmarks',
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

  int _activeIndex = 0;

  /// Derives the selected index from the current router location so that
  /// deep-links and programmatic navigation keep the bar in sync.
  int _locationToIndex(String location) {
    for (int i = 0; i < _destinations.length; i++) {
      if (location.startsWith(_destinations[i].path)) return i;
    }
    return 0;
  }

  void _onTabTapped(int index) {
    if (index == _activeIndex) return; // already active — no-op
    setState(() => _activeIndex = index);
    context.go(_destinations[index].path);
  }

  @override
  Widget build(BuildContext context) {
    // Keep the bar in sync when navigating programmatically.
    final String location = GoRouterState.of(context).uri.toString();
    _activeIndex = _locationToIndex(location);

    return Scaffold(
      backgroundColor: AppColors.background,
      // extendBody allows the scroll content to flow behind the floating nav bar.
      extendBody: true,
      body: widget.child,
      bottomNavigationBar: _FloatingNavBar(
        selectedIndex: _activeIndex,
        destinations: _destinations,
        onDestinationSelected: _onTabTapped,
      ),
    );
  }
}

// ── Floating navigation bar ────────────────────────────────────────────────────

class _FloatingNavBar extends StatelessWidget {
  const _FloatingNavBar({
    required this.selectedIndex,
    required this.destinations,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final List<_TabDestination> destinations;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    // Bottom padding respects the system navigation bar / home indicator.
    final double bottomInset = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        (bottomInset > 0 ? bottomInset : AppSpacing.md) + AppSpacing.xs,
      ),
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          color: AppColors.navBarSurface,
          borderRadius: AppRadius.radiusXxl,
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000), // ~8% black
              blurRadius: 24,
              offset: Offset(0, 8),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Color(0x0A000000), // ~4% black — secondary soft layer
              blurRadius: 8,
              offset: Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: AppRadius.radiusXxl,
          child: Row(
            children: List.generate(destinations.length, (index) {
              final dest = destinations[index];
              final bool isSelected = index == selectedIndex;
              return _NavBarItem(
                destination: dest,
                isSelected: isSelected,
                onTap: () => onDestinationSelected(index),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ── Individual nav bar item ────────────────────────────────────────────────────

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.destination,
    required this.isSelected,
    required this.onTap,
  });

  final _TabDestination destination;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color iconColor =
        isSelected ? AppColors.primary : AppColors.textTertiary;
    final Color labelColor =
        isSelected ? AppColors.primary : AppColors.textTertiary;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Selected indicator pill above icon
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              width: isSelected ? 32 : 0,
              height: 3,
              margin: const EdgeInsets.only(bottom: AppSpacing.xxs),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: AppRadius.radiusFull,
              ),
            ),
            Icon(
              isSelected ? destination.selectedIcon : destination.icon,
              size: 22,
              color: iconColor,
            ),
            const SizedBox(height: 3),
            Text(
              destination.label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: labelColor,
                letterSpacing: 0.1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Data model ─────────────────────────────────────────────────────────────────

/// Immutable descriptor for a single bottom-navigation destination.
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
