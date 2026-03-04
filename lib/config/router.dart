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
          pageBuilder: (context, state) => const NoTransitionPage(
            child: DashboardScreen(),
          ),
        ),
        GoRoute(
          path: '/transactions',
          name: 'transactions',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: TransactionListScreen(),
          ),
        ),
        GoRoute(
          path: '/charts',
          name: 'charts',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ChartsScreen(),
          ),
        ),
        GoRoute(
          path: '/settings',
          name: 'settings',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SettingsScreen(),
          ),
        ),
      ],
    ),
    // Full-screen routes (fuori dalla shell)
    GoRoute(
      path: '/add-transaction',
      name: 'addTransaction',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AddTransactionScreen(),
    ),
    GoRoute(
      path: '/edit-transaction',
      name: 'editTransaction',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => AddTransactionScreen(
        existingTransaction: state.extra as TransactionModel?,
      ),
    ),
    GoRoute(
      path: '/budget',
      name: 'budget',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const BudgetScreen(),
    ),
    GoRoute(
      path: '/recurring',
      name: 'recurring',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const RecurringScreen(),
    ),
    GoRoute(
      path: '/savings',
      name: 'savings',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SavingsScreen(),
    ),
    GoRoute(
      path: '/chat',
      name: 'chat',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => CustomTransitionPage(
        child: const ChatScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: '/crypto',
      name: 'crypto',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const CryptoScreen(),
    ),
  ],
);
