import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'data/local/hive_service.dart';
import 'app.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Gestione errori Flutter – non crasha in release
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      if (kDebugMode) {
        debugPrint('FlutterError: ${details.exceptionAsString()}');
      }
    };

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Inizializzazione date locale – non critica
    try {
      await initializeDateFormatting('it_IT', null);
    } catch (e) {
      debugPrint('Date formatting init error: $e');
    }

    // Inizializzazione Hive – critica, riproviamo se fallisce
    bool hiveOk = false;
    for (int attempt = 0; attempt < 2 && !hiveOk; attempt++) {
      try {
        await HiveService.init();
        hiveOk = true;
      } catch (e) {
        debugPrint('Hive init error (attempt $attempt): $e');
        if (attempt == 0) {
          // Primo tentativo fallito: prova a pulire e reinizializzare
          await Future.delayed(const Duration(milliseconds: 200));
        }
      }
    }


    runApp(
      const ProviderScope(
        child: FinanceApp(),
      ),
    );
  }, (error, stackTrace) {
    if (kDebugMode) {
      debugPrint('Uncaught error: $error');
      debugPrint('Stack: $stackTrace');
    }
  });
}
