import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'config/router.dart';

class FinanceApp extends StatelessWidget {
  const FinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
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
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}
