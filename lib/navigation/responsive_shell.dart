import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/responsive_layout.dart';
import '../widget/tm_liquid_glass_nav.dart';

/// Shell responsiva: BottomNav su mobile, NavigationRail su tablet, Sidebar su desktop
class ResponsiveShell extends StatelessWidget {
  final Widget child;

  const ResponsiveShell({super.key, required this.child});

  static int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/transactions')) return 1;
    if (location.startsWith('/charts')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    HapticFeedback.lightImpact();
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/transactions');
        break;
      case 2:
        context.go('/charts');
        break;
      case 3:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenType = ResponsiveLayout.getScreenType(context);
    final selectedIndex = _calculateSelectedIndex(context);

    switch (screenType) {
      case ScreenType.mobile:
        return _MobileShell(
          selectedIndex: selectedIndex,
          onItemTapped: (i) => _onItemTapped(context, i),
          onAddTapped: () {
            HapticFeedback.mediumImpact();
            context.push('/add-transaction');
          },
          onChatTapped: () {
            HapticFeedback.mediumImpact();
            context.push('/chat');
          },
          child: child,
        );
      case ScreenType.tablet:
        return _TabletShell(
          selectedIndex: selectedIndex,
          onItemTapped: (i) => _onItemTapped(context, i),
          onAddTapped: () => context.push('/add-transaction'),
          onChatTapped: () => context.push('/chat'),
          child: child,
        );
      case ScreenType.desktop:
        return _DesktopShell(
          selectedIndex: selectedIndex,
          onItemTapped: (i) => _onItemTapped(context, i),
          onAddTapped: () => context.push('/add-transaction'),
          onChatTapped: () => context.push('/chat'),
          child: child,
        );
    }
  }
}

// ═══════════════════════════════════════════════
// DESTINAZIONI DI NAVIGAZIONE CONDIVISE
// ═══════════════════════════════════════════════

class _NavDestination {
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const _NavDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}

const _destinations = [
  _NavDestination(
    label: 'Home',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home_rounded,
  ),
  _NavDestination(
    label: 'Movimenti',
    icon: Icons.swap_horiz_rounded,
    selectedIcon: Icons.swap_horiz_rounded,
  ),
  _NavDestination(
    label: 'Grafici',
    icon: Icons.insights_outlined,
    selectedIcon: Icons.insights_rounded,
  ),
  _NavDestination(
    label: 'Altro',
    icon: Icons.grid_view_rounded,
    selectedIcon: Icons.grid_view_rounded,
  ),
];

// ═══════════════════════════════════════════════
// MOBILE SHELL — Liquid Glass Bottom Nav
// ═══════════════════════════════════════════════

class _MobileShell extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
  final VoidCallback onAddTapped;
  final VoidCallback onChatTapped;
  final Widget child;

  const _MobileShell({
    required this.selectedIndex,
    required this.onItemTapped,
    required this.onAddTapped,
    required this.onChatTapped,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Contenuto principale
          Positioned.fill(child: child),

          // Liquid Glass Bottom Bar
          SafeArea(
            top: false,
            bottom: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: TmLiquidGlassBottomBar(
                selectedIndex: selectedIndex,
                onTabSelected: (index) {
                  HapticFeedback.lightImpact();
                  onItemTapped(index);
                },
                bottomPadding: bottomPadding > 0 ? bottomPadding : 12,
                horizontalPadding: 16,
                barHeight: 62,
                spacing: 10,
                glassSettings: LiquidGlassSettings(
                  refractiveIndex: 1.21,
                  thickness: 30,
                  blur: 8,
                  saturation: 1.5,
                  lightIntensity: isDark ? 0.7 : 1.0,
                  ambientStrength: isDark ? 0.2 : 0.5,
                  lightAngle: math.pi / 4,
                  glassColor: isDark
                      ? const Color(0xFF1A1A2E).withValues(alpha: 0.6)
                      : CupertinoTheme.of(context)
                          .barBackgroundColor
                          .withValues(alpha: 0.6),
                ),
                tabs: const [
                  TmLiquidGlassTab(
                    label: 'Home',
                    icon: CupertinoIcons.home,
                    selectedIcon: CupertinoIcons.house_fill,
                    glowColor: AppTheme.primaryColor,
                  ),
                  TmLiquidGlassTab(
                    label: 'Movimenti',
                    icon: CupertinoIcons.arrow_right_arrow_left,
                    selectedIcon: CupertinoIcons.arrow_right_arrow_left,
                    glowColor: AppTheme.secondaryColor,
                  ),
                  TmLiquidGlassTab(
                    label: 'Grafici',
                    icon: CupertinoIcons.chart_bar,
                    selectedIcon: CupertinoIcons.chart_bar_fill,
                    glowColor: AppTheme.incomeColor,
                  ),
                  TmLiquidGlassTab(
                    label: 'Altro',
                    icon: CupertinoIcons.square_grid_2x2,
                    selectedIcon: CupertinoIcons.square_grid_2x2_fill,
                    glowColor: AppTheme.warningColor,
                  ),
                ],
                extraButton: TmLiquidGlassExtraButton(
                  icon: CupertinoIcons.add,
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    onAddTapped();
                  },
                  label: 'Aggiungi',
                  size: 58,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// TABLET SHELL — NavigationRail compatta
// ═══════════════════════════════════════════════

class _TabletShell extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
  final VoidCallback onAddTapped;
  final VoidCallback onChatTapped;
  final Widget child;

  const _TabletShell({
    required this.selectedIndex,
    required this.onItemTapped,
    required this.onAddTapped,
    required this.onChatTapped,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Navigation Rail
          Container(
            width: 80,
            color: AppTheme.surfaceDark,
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Logo
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 24),
                // Add button
                _RailActionButton(
                  icon: Icons.add_rounded,
                  gradient: const [Color(0xFF8B7CF7), AppTheme.primaryColor],
                  onTap: onAddTapped,
                  tooltip: 'Nuovo movimento',
                ),
                const SizedBox(height: 8),
                // Chat button
                _RailActionButton(
                  icon: Icons.auto_awesome_rounded,
                  gradient: const [Color(0xFF00D2D3), Color(0xFF00B894)],
                  onTap: onChatTapped,
                  tooltip: 'FinBot',
                  size: 38,
                ),
                const SizedBox(height: 20),
                const Divider(
                  indent: 16,
                  endIndent: 16,
                  color: AppTheme.borderDark,
                ),
                const SizedBox(height: 8),
                // Nav Items
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: List.generate(_destinations.length, (index) {
                      final d = _destinations[index];
                      final isSelected = index == selectedIndex;
                      return _RailNavItem(
                        icon: isSelected ? d.selectedIcon : d.icon,
                        label: d.label,
                        isSelected: isSelected,
                        onTap: () => onItemTapped(index),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          // Divider
          Container(
            width: 1,
            color: AppTheme.borderDark,
          ),
          // Content
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _RailActionButton extends StatelessWidget {
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;
  final String tooltip;
  final double size;

  const _RailActionButton({
    required this.icon,
    required this.gradient,
    required this.onTap,
    required this.tooltip,
    this.size = 46,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradient),
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: gradient.first.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: AppTheme.textPrimary, size: size * 0.45),
        ),
      ),
    );
  }
}

class _RailNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RailNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Tooltip(
          message: label,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 56,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primaryColor.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isSelected ? AppTheme.primaryColor : AppTheme.textMuted,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? AppTheme.primaryColor : AppTheme.textMuted,
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

// ═══════════════════════════════════════════════
// DESKTOP SHELL — Sidebar espansa
// ═══════════════════════════════════════════════

class _DesktopShell extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
  final VoidCallback onAddTapped;
  final VoidCallback onChatTapped;
  final Widget child;

  const _DesktopShell({
    required this.selectedIndex,
    required this.onItemTapped,
    required this.onAddTapped,
    required this.onChatTapped,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _DesktopSidebar(
            selectedIndex: selectedIndex,
            onItemTapped: onItemTapped,
            onAddTapped: onAddTapped,
            onChatTapped: onChatTapped,
          ),
          Container(width: 1, color: AppTheme.borderDark),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _DesktopSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
  final VoidCallback onAddTapped;
  final VoidCallback onChatTapped;

  const _DesktopSidebar({
    required this.selectedIndex,
    required this.onItemTapped,
    required this.onAddTapped,
    required this.onChatTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: AppTheme.surfaceDark,
      child: SafeArea(
        right: false,
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Logo + App Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: AppTheme.primaryColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'FinanceApp',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                          fontSize: 17,
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Azioni rapide
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                children: [
                  _SidebarActionButton(
                    icon: Icons.add_rounded,
                    label: 'Nuovo Movimento',
                    gradient: const [Color(0xFF8B7CF7), AppTheme.primaryColor, Color(0xFF5A4BD1)],
                    onTap: onAddTapped,
                  ),
                  const SizedBox(height: 8),
                  _SidebarActionButton(
                    icon: Icons.auto_awesome_rounded,
                    label: 'FinBot – AI',
                    gradient: const [Color(0xFF00D2D3), Color(0xFF00B894)],
                    onTap: onChatTapped,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(color: AppTheme.borderDark, height: 1),
            ),
            const SizedBox(height: 8),

            // Label MENU
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'MENU',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.8,
                  ),
                ),
              ),
            ),

            // Nav Items
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: _destinations.length,
                itemBuilder: (context, index) {
                  final d = _destinations[index];
                  final isSelected = index == selectedIndex;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => onItemTapped(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primaryColor.withValues(alpha: 0.12)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? Border.all(
                                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                                    width: 1,
                                  )
                                : null,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected ? d.selectedIcon : d.icon,
                                color: isSelected ? AppTheme.primaryColor : AppTheme.textMuted,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                d.label,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : AppTheme.textTertiary,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  fontSize: 14,
                                ),
                              ),
                              if (isSelected) ...[
                                const Spacer(),
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Footer
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(color: AppTheme.borderDark, height: 1),
            ),
            SafeArea(
              top: false,
              right: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 13, color: AppTheme.textMuted),
                    const SizedBox(width: 8),
                    Text('FinanceApp v1.0.0', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _SidebarActionButton({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.textPrimary, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// (Old _PremiumBottomNav removed — mobile uses LiquidGlassBottomBar)
// ═══════════════════════════════════════════════


