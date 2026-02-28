import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';

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
      bottomNavigationBar: _PremiumBottomNav(
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

class _PremiumBottomNav extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
  final VoidCallback onAddTapped;
  final VoidCallback onChatTapped;
  final double bottomPadding;

  const _PremiumBottomNav({
    required this.selectedIndex,
    required this.onItemTapped,
    required this.onAddTapped,
    required this.onChatTapped,
    required this.bottomPadding,
  });

  @override
  State<_PremiumBottomNav> createState() => _PremiumBottomNavState();
}

class _PremiumBottomNavState extends State<_PremiumBottomNav>
    with TickerProviderStateMixin {
  late AnimationController _fabController;
  late Animation<double> _fabScale;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fabScale = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navHeight = 68 + widget.bottomPadding;

    return SizedBox(
      height: navHeight + 32,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // Barra con effetto glassmorphism
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                height: navHeight,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark.withValues(alpha: 0.92),
                  border: const Border(
                    top: BorderSide(
                      color: Color(0xFF2A2A3E),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(bottom: widget.bottomPadding),
                  child: Row(
                    children: [
                      // Sinistra: Home, Movimenti
                      Expanded(
                        flex: 2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _NavItem(
                              icon: Icons.home_rounded,
                              outlinedIcon: Icons.home_outlined,
                              label: 'Home',
                              isSelected: widget.selectedIndex == 0,
                              onTap: () => widget.onItemTapped(0),
                            ),
                            _NavItem(
                              icon: Icons.swap_horiz_rounded,
                              outlinedIcon: Icons.swap_horiz_rounded,
                              label: 'Movimenti',
                              isSelected: widget.selectedIndex == 1,
                              onTap: () => widget.onItemTapped(1),
                            ),
                          ],
                        ),
                      ),
                      // Spazio centrale per FAB
                      const SizedBox(width: 80),
                      // Destra: Grafici, Altro
                      Expanded(
                        flex: 2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _NavItem(
                              icon: Icons.insights_rounded,
                              outlinedIcon: Icons.insights_outlined,
                              label: 'Grafici',
                              isSelected: widget.selectedIndex == 2,
                              onTap: () => widget.onItemTapped(2),
                            ),
                            _NavItem(
                              icon: Icons.grid_view_rounded,
                              outlinedIcon: Icons.grid_view_rounded,
                              label: 'Altro',
                              isSelected: widget.selectedIndex == 3,
                              onTap: () => widget.onItemTapped(3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // FAB + Chat
          Positioned(
            bottom: navHeight - 28,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Chat bubble
                _ChatBubbleButton(onTap: widget.onChatTapped),
                const SizedBox(width: 10),
                // FAB principale
                GestureDetector(
                  onTapDown: (_) => _fabController.forward(),
                  onTapUp: (_) {
                    _fabController.reverse();
                    widget.onAddTapped();
                  },
                  onTapCancel: () => _fabController.reverse(),
                  child: ScaleTransition(
                    scale: _fabScale,
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF8B7CF7),
                            AppTheme.primaryColor,
                            Color(0xFF5A4BD1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(alpha: 0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(alpha: 0.2),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
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

class _ChatBubbleButton extends StatefulWidget {
  final VoidCallback onTap;
  const _ChatBubbleButton({required this.onTap});

  @override
  State<_ChatBubbleButton> createState() => _ChatBubbleButtonState();
}

class _ChatBubbleButtonState extends State<_ChatBubbleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (context, child) {
          return Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF00D2D3),
                  Color.lerp(
                    const Color(0xFF00D2D3),
                    const Color(0xFF00B894),
                    _pulseAnim.value,
                  )!,
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00D2D3)
                      .withValues(alpha: 0.3 + (_pulseAnim.value * 0.15)),
                  blurRadius: 10 + (_pulseAnim.value * 4),
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 20,
            ),
          );
        },
      ),
    );
  }
}

/// Wrapper per AnimatedWidget builder pattern
class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required Animation<double> animation,
    required this.builder,
    this.child,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData outlinedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.outlinedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryColor.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isSelected ? icon : outlinedIcon,
                size: 22,
                color: isSelected ? AppTheme.primaryColor : Colors.white38,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppTheme.primaryColor : Colors.white38,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
