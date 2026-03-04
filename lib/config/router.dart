import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/transactions/screens/transaction_list_screen.dart';
import '../features/transactions/screens/add_transaction_screen.dart';
import '../data/models/transaction_model.dart';
import '../features/charts/screens/charts_screen.dart';
import '../features/budget/screens/budget_screen.dart';
import '../features/recurring/screens/recurring_screen.dart';
import '../features/savings/screens/savings_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/chat/screens/chat_screen.dart';
import '../features/crypto/screens/crypto_screen.dart';
import '../navigation/responsive_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

// ── Transizione fade fluida per tab nella shell ──────────────────
CustomTransitionPage<void> _fadePage(Widget child, GoRouterState state) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 220),
    reverseTransitionDuration: const Duration(milliseconds: 180),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      );
    },
  );
}

// ── Transizione slide-up + fade per pagine full-screen ───────────
CustomTransitionPage<void> _slideUpPage(Widget child, GoRouterState state) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(curved),
        child: FadeTransition(opacity: curved, child: child),
      );
    },
  );
}

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/dashboard',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => ResponsiveShell(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          name: 'dashboard',
          pageBuilder: (context, state) => _fadePage(const DashboardScreen(), state),
        ),
        GoRoute(
          path: '/transactions',
          name: 'transactions',
          pageBuilder: (context, state) => _fadePage(const TransactionListScreen(), state),
        ),
        GoRoute(
          path: '/charts',
          name: 'charts',
          pageBuilder: (context, state) => _fadePage(const ChartsScreen(), state),
        ),
        GoRoute(
          path: '/settings',
          name: 'settings',
          pageBuilder: (context, state) => _fadePage(const SettingsScreen(), state),
        ),
      ],
    ),
    // Full-screen routes (fuori dalla shell)
    GoRoute(
      path: '/add-transaction',
      name: 'addTransaction',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) =>
          _slideUpPage(const AddTransactionScreen(), state),
    ),
    GoRoute(
      path: '/edit-transaction',
      name: 'editTransaction',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => _slideUpPage(
        AddTransactionScreen(existingTransaction: state.extra as TransactionModel?),
        state,
      ),
    ),
    GoRoute(
      path: '/budget',
      name: 'budget',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => _slideUpPage(const BudgetScreen(), state),
    ),
    GoRoute(
      path: '/recurring',
      name: 'recurring',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => _slideUpPage(const RecurringScreen(), state),
    ),
    GoRoute(
      path: '/savings',
      name: 'savings',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => _slideUpPage(const SavingsScreen(), state),
    ),
    GoRoute(
      path: '/chat',
      name: 'chat',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const ChatScreen(),
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: FadeTransition(
              opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
              child: child,
            ),
          );
        },
      ),
    ),
    GoRoute(
      path: '/crypto',
      name: 'crypto',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => _slideUpPage(const CryptoScreen(), state),
    ),
  ],
);
