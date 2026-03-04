import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/animated_builder.dart';

class BottomNavShell extends StatelessWidget {
  final Widget child;

  const BottomNavShell({super.key, required this.child});

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
    final selectedIndex = _calculateSelectedIndex(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: child,
      extendBody: true,
      bottomNavigationBar: _MarathonBottomNav(
        selectedIndex: selectedIndex,
        onItemTapped: (index) => _onItemTapped(context, index),
        onAddTapped: () {
          HapticFeedback.mediumImpact();
          context.push('/add-transaction');
        },
        onChatTapped: () {
          HapticFeedback.mediumImpact();
          context.push('/chat');
        },
        bottomPadding: bottomPadding,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// MARATHON-STYLE BOTTOM NAV — pannello HUD industriale
// ═══════════════════════════════════════════════════════════════

class _MarathonBottomNav extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
  final VoidCallback onAddTapped;
  final VoidCallback onChatTapped;
  final double bottomPadding;

  const _MarathonBottomNav({
    required this.selectedIndex,
    required this.onItemTapped,
    required this.onAddTapped,
    required this.onChatTapped,
    required this.bottomPadding,
  });

  @override
  State<_MarathonBottomNav> createState() => _MarathonBottomNavState();
}

class _MarathonBottomNavState extends State<_MarathonBottomNav>
    with TickerProviderStateMixin {
  late AnimationController _fabCtrl;
  late Animation<double> _fabScale;

  @override
  void initState() {
    super.initState();
    _fabCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _fabScale = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _fabCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() { _fabCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final navH = 64 + widget.bottomPadding;

    return SizedBox(
      height: navH + 32,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // ── Barra HUD ─────────────────────────────────────────
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                height: navH,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark.withValues(alpha: 0.92),
                  border: Border(
                    top: BorderSide(color: AppTheme.primaryColor.withValues(alpha: 0.25), width: 0.5),
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 20, offset: const Offset(0, -4)),
                    BoxShadow(color: AppTheme.primaryColor.withValues(alpha: 0.05), blurRadius: 30, offset: const Offset(0, -2)),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.only(bottom: widget.bottomPadding),
                  child: Row(children: [
                    Expanded(flex: 2, child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _NavItem(icon: Icons.dashboard_rounded, outlinedIcon: Icons.dashboard_outlined,
                          label: 'HQ', isSelected: widget.selectedIndex == 0,
                          onTap: () => widget.onItemTapped(0)),
                        _NavItem(icon: Icons.swap_horiz_rounded, outlinedIcon: Icons.swap_horiz_rounded,
                          label: 'LOG', isSelected: widget.selectedIndex == 1,
                          onTap: () => widget.onItemTapped(1)),
                      ],
                    )),
                    const SizedBox(width: 76),
                    Expanded(flex: 2, child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _NavItem(icon: Icons.insights_rounded, outlinedIcon: Icons.insights_outlined,
                          label: 'DATA', isSelected: widget.selectedIndex == 2,
                          onTap: () => widget.onItemTapped(2)),
                        _NavItem(icon: Icons.tune_rounded, outlinedIcon: Icons.tune_rounded,
                          label: 'SYS', isSelected: widget.selectedIndex == 3,
                          onTap: () => widget.onItemTapped(3)),
                      ],
                    )),
                  ]),
                ),
              ),
            ),
          ),

          // ── FAB + Chat ────────────────────────────────────────
          Positioned(
            bottom: navH - 26,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _ChatBubbleButton(onTap: widget.onChatTapped),
                const SizedBox(width: 8),
                // FAB — rosso ossidato Marathon
                GestureDetector(
                  onTapDown: (_) => _fabCtrl.forward(),
                  onTapUp: (_) { _fabCtrl.reverse(); widget.onAddTapped(); },
                  onTapCancel: () => _fabCtrl.reverse(),
                  child: ScaleTransition(
                    scale: _fabScale,
                    child: Container(
                      width: 54, height: 54,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(6),
                        border: Border(
                          top: BorderSide(color: Colors.white.withValues(alpha: 0.15), width: 0.5),
                          left: BorderSide(color: Colors.white.withValues(alpha: 0.08), width: 0.5),
                          right: BorderSide(color: Colors.black.withValues(alpha: 0.2), width: 0.5),
                          bottom: BorderSide(color: Colors.black.withValues(alpha: 0.3), width: 0.5),
                        ),
                        boxShadow: [
                          BoxShadow(color: AppTheme.primaryColor.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 4)),
                          BoxShadow(color: AppTheme.primaryColor.withValues(alpha: 0.15), blurRadius: 40, offset: const Offset(0, 8)),
                        ],
                      ),
                      child: const Icon(Icons.add_rounded, color: AppTheme.textPrimary, size: 28),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Chat bubble — ciano neon ──────────────────────────────────────
class _ChatBubbleButton extends StatefulWidget {
  final VoidCallback onTap;
  const _ChatBubbleButton({required this.onTap});
  @override
  State<_ChatBubbleButton> createState() => _ChatBubbleButtonState();
}

class _ChatBubbleButtonState extends State<_ChatBubbleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
    Future.delayed(const Duration(seconds: 9), () { if (mounted) _pulse.stop(); });
  }

  @override
  void dispose() { _pulse.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AppAnimatedBuilder(
        animation: _pulseAnim,
        builder: (context, child) {
          return Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppTheme.secondaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
              border: Border(
                top: BorderSide(color: AppTheme.secondaryColor.withValues(alpha: 0.4 + _pulseAnim.value * 0.2), width: 0.5),
                left: BorderSide(color: AppTheme.secondaryColor.withValues(alpha: 0.15), width: 0.5),
                right: BorderSide(color: AppTheme.secondaryColor.withValues(alpha: 0.15), width: 0.5),
                bottom: BorderSide(color: AppTheme.secondaryColor.withValues(alpha: 0.05), width: 0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.secondaryColor.withValues(alpha: 0.2 + _pulseAnim.value * 0.1),
                  blurRadius: 10 + _pulseAnim.value * 4, offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(Icons.auto_awesome_rounded, color: AppTheme.secondaryColor, size: 18),
          );
        },
      ),
    );
  }
}

// ── Nav item — stile HUD label uppercase ──────────────────────────
class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData outlinedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon, required this.outlinedIcon,
    required this.label, required this.isSelected, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: isSelected
                    ? Border(top: BorderSide(color: AppTheme.primaryColor.withValues(alpha: 0.5), width: 0.5))
                    : null,
              ),
              child: Icon(
                isSelected ? icon : outlinedIcon, size: 21,
                color: isSelected ? AppTheme.primaryColor : AppTheme.textTertiary,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 9, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppTheme.primaryColor : AppTheme.textTertiary,
                letterSpacing: 1.2,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
