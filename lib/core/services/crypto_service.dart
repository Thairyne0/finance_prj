import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class CryptoPrice {
  final double priceEur;
  final double change24h;
  final double high24h;
  final double low24h;
  final double marketCapEur;
  final List<double> sparkline7d;
  final DateTime fetchedAt;
  final bool isFromCache;

  const CryptoPrice({
    required this.priceEur,
    required this.change24h,
    required this.high24h,
    required this.low24h,
    required this.marketCapEur,
    required this.sparkline7d,
    required this.fetchedAt,
    this.isFromCache = false,
  });
}

class CryptoService {
  static const _baseUrl = 'https://api.coingecko.com/api/v3';

  // Cache in memoria — evita di rifare richieste inutili
  static CryptoPrice? _cachedPrice;
  static DateTime? _lastFetch;
  // Minimo 45s tra una richiesta e l'altra per rispettare il rate limit
  static const _minCacheAge = Duration(seconds: 45);

  /// Fetch prezzo BTC in EUR con sparkline, cache e retry
  static Future<CryptoPrice> fetchBitcoinPrice({bool forceRefresh = false}) async {
    // Ritorna dalla cache se ancora fresca
    if (!forceRefresh &&
        _cachedPrice != null &&
        _lastFetch != null &&
        DateTime.now().difference(_lastFetch!) < _minCacheAge) {
      debugPrint('[Crypto] Usando cache (età: ${DateTime.now().difference(_lastFetch!).inSeconds}s)');
      return _cachedPrice!.copyWith(isFromCache: true);
    }

    // Retry con backoff esponenziale: 1s, 2s, 4s
    Exception? lastError;
    for (int attempt = 0; attempt < 3; attempt++) {
      if (attempt > 0) {
        final delay = Duration(seconds: 1 << attempt); // 2s, 4s
        debugPrint('[Crypto] Retry $attempt dopo ${delay.inSeconds}s...');
        await Future.delayed(delay);
      }

      try {
        final price = await _doFetch();
        _cachedPrice = price;
        _lastFetch = DateTime.now();
        return price;
      } on RateLimitException {
        // 429: aspetta più a lungo prima di riprovare
        debugPrint('[Crypto] Rate limit (429), aspetto 10s...');
        await Future.delayed(const Duration(seconds: 10));
        lastError = Exception('Rate limit raggiunto, riprova tra poco');
      } on TimeoutException {
        debugPrint('[Crypto] Timeout al tentativo $attempt');
        lastError = Exception('Timeout connessione');
      } catch (e) {
        debugPrint('[Crypto] Errore al tentativo $attempt: $e');
        lastError = Exception('Errore di rete: $e');
      }
    }

    // Tutti i tentativi falliti — usa cache se disponibile (anche se vecchia)
    if (_cachedPrice != null) {
      debugPrint('[Crypto] Tutti i tentativi falliti, uso cache vecchia');
      return _cachedPrice!.copyWith(isFromCache: true);
    }

    throw lastError ?? Exception('Impossibile recuperare il prezzo Bitcoin');
  }

  static Future<CryptoPrice> _doFetch() async {
    final uri = Uri.parse(
      '$_baseUrl/coins/markets'
      '?vs_currency=eur'
      '&ids=bitcoin'
      '&sparkline=true'
      '&price_change_percentage=24h',
    );

    final response = await http.get(uri, headers: {
      'Accept': 'application/json',
    }).timeout(const Duration(seconds: 15));

    if (response.statusCode == 429) {
      throw RateLimitException();
    }

    if (response.statusCode != 200) {
      throw Exception('CoinGecko errore HTTP ${response.statusCode}');
    }

    final List data = jsonDecode(response.body);
    if (data.isEmpty) throw Exception('Nessun dato da CoinGecko');

    final coin = data[0] as Map<String, dynamic>;
    final sparkRaw = (coin['sparkline_in_7d']?['price'] as List?) ?? [];
    final sparkline = sparkRaw.cast<num>().map((e) => e.toDouble()).toList();
    final sparkline24 = sparkline.length > 24
        ? sparkline.sublist(sparkline.length - 24)
        : sparkline;

    return CryptoPrice(
      priceEur: (coin['current_price'] as num).toDouble(),
      change24h: (coin['price_change_percentage_24h'] as num?)?.toDouble() ?? 0,
      high24h: (coin['high_24h'] as num).toDouble(),
      low24h: (coin['low_24h'] as num).toDouble(),
      marketCapEur: (coin['market_cap'] as num).toDouble(),
      sparkline7d: sparkline24,
      fetchedAt: DateTime.now(),
      isFromCache: false,
    );
  }

  /// Svuota la cache (utile per il refresh manuale)
  static void clearCache() {
    _cachedPrice = null;
    _lastFetch = null;
  }
}

class RateLimitException implements Exception {}

extension _CryptoPriceCopy on CryptoPrice {
  CryptoPrice copyWith({bool? isFromCache}) => CryptoPrice(
        priceEur: priceEur,
        change24h: change24h,
        high24h: high24h,
        low24h: low24h,
        marketCapEur: marketCapEur,
        sparkline7d: sparkline7d,
        fetchedAt: fetchedAt,
        isFromCache: isFromCache ?? this.isFromCache,
      );
}
