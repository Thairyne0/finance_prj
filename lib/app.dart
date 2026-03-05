import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'config/router.dart';
import 'config/providers.dart';

class FinanceApp extends ConsumerWidget {
  const FinanceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    // In release mode, errori di rendering mostrano un widget vuoto
    // invece di una schermata rossa / bianca che crasha
    if (!kDebugMode) {
      ErrorWidget.builder = (FlutterErrorDetails details) {
        return const SizedBox.shrink();
      };
    }

    return MaterialApp.router(
      title: 'FinanceApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
