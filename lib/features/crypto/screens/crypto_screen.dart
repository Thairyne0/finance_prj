import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/providers.dart';
import '../../../core/services/crypto_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/responsive_layout.dart';

class CryptoScreen extends ConsumerWidget {
  const CryptoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final priceAsync  = ref.watch(bitcoinPriceProvider);
    final btcAmount   = ref.watch(userBtcAmountProvider);
    final hPad        = ResponsiveLayout.horizontalPadding(context);
    final vSpace      = ResponsiveLayout.sectionSpacing(context);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldDark,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFFF7931A).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('₿', style: TextStyle(color: Color(0xFFF7931A), fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(width: 10),
            const Text('Bitcoin'),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          // Refresh manuale
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.primaryColor),
            onPressed: () {
              CryptoService.clearCache();
              ref.invalidate(bitcoinPriceProvider);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: ResponsiveLayout.modalMaxWidth(context)),
            child: priceAsync.when(
              loading: () => const Center(child: _CryptoLoadingState()),
              error: (e, _) => Center(child: _CryptoErrorState(
                error: e.toString(),
                onRetry: () {
                  CryptoService.clearCache();
                  ref.invalidate(bitcoinPriceProvider);
                },
              )),
                    data: (price) => SingleChildScrollView(
                physics: ResponsiveLayout.scrollPhysics(context),
                padding: EdgeInsets.fromLTRB(hPad, 16, hPad, ResponsiveLayout.bottomContentPadding(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Prezzo principale ──
                    _PriceHeroCard(price: price),
                    SizedBox(height: vSpace * 0.8),

                    // ── Grafico sparkline ──
                    _SparklineCard(price: price),
                    SizedBox(height: vSpace * 0.8),

                    // ── Stats 24h ──
                    _Stats24hRow(price: price),
                    SizedBox(height: vSpace * 0.8),

                    // ── Portafoglio utente ──
                    _PortfolioCard(btcAmount: btcAmount, price: price),
                    SizedBox(height: vSpace * 0.5),

                    // ── Ultimo aggiornamento ──
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            price.isFromCache ? Icons.cached_rounded : Icons.check_circle_outline_rounded,
                            size: 12,
                            color: price.isFromCache ? Colors.orange.withValues(alpha: 0.6) : AppTheme.textMuted,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            price.isFromCache
                                ? 'Dati in cache · ${_timeStr(price.fetchedAt)} · Auto-refresh 90s'
                                : 'Aggiornato alle ${_timeStr(price.fetchedAt)} · Auto-refresh 90s',
                            style: TextStyle(
                              color: price.isFromCache ? Colors.orange.withValues(alpha: 0.5) : AppTheme.textMuted,
                              fontSize: 11,
                            ),
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
      ),
    );
  }

  String _timeStr(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

// ─── Prezzo Hero ─────────────────────────────────────────────

class _PriceHeroCard extends StatelessWidget {
  final CryptoPrice price;
  const _PriceHeroCard({required this.price});

  @override
  Widget build(BuildContext context) {
    final isUp = price.change24h >= 0;
    final color = isUp ? AppTheme.incomeColor : AppTheme.expenseColor;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF7931A).withValues(alpha: 0.12),
            AppTheme.cardDark,
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFF7931A).withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bitcoin (BTC)',
                style: TextStyle(color: AppTheme.textTertiary, fontSize: 13, fontWeight: FontWeight.w500),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(isUp ? Icons.trending_up_rounded : Icons.trending_down_rounded, color: color, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${isUp ? '+' : ''}${price.change24h.toStringAsFixed(2)}%',
                      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              Formatters.formatCurrency(price.priceEur),
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 40,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'per 1 BTC',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ─── Sparkline Chart ─────────────────────────────────────────

class _SparklineCard extends StatelessWidget {
  final CryptoPrice price;
  const _SparklineCard({required this.price});

  @override
  Widget build(BuildContext context) {
    final spots = price.sparkline7d.isEmpty
        ? <FlSpot>[]
        : price.sparkline7d
            .asMap()
            .entries
            .map((e) => FlSpot(e.key.toDouble(), e.value))
            .toList();

    final isUp = price.change24h >= 0;
    final lineColor = isUp ? AppTheme.incomeColor : AppTheme.expenseColor;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Andamento ultime 24 ore',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            child: spots.isEmpty
                ? const Center(child: Text('Dati non disponibili', style: TextStyle(color: AppTheme.textMuted)))
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: _interval(price.sparkline7d),
                        getDrawingHorizontalLine: (_) =>
                            FlLine(color: AppTheme.borderDark, strokeWidth: 1),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 60,
                            getTitlesWidget: (v, _) => Text(
                              Formatters.formatCompact(v),
                              style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
                            ),
                          ),
                        ),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: (spots.length / 4).ceilToDouble(),
                            getTitlesWidget: (v, _) {
                              final idx = v.toInt();
                              if (idx < 0 || idx >= spots.length) return const SizedBox.shrink();
                              // ore fa
                              final hrsAgo = spots.length - 1 - idx;
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  hrsAgo == 0 ? 'Ora' : '-${hrsAgo}h',
                                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: lineColor,
                          barWidth: 2.5,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                lineColor.withValues(alpha: 0.18),
                                lineColor.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (_) => AppTheme.cardDarkAlt,
                          getTooltipItems: (spots) => spots.map((s) => LineTooltipItem(
                            Formatters.formatCurrency(s.y),
                            TextStyle(color: lineColor, fontWeight: FontWeight.w600, fontSize: 12),
                          )).toList(),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  double _interval(List<double> data) {
    if (data.isEmpty) return 1000;
    final max = data.reduce((a, b) => a > b ? a : b);
    final min = data.reduce((a, b) => a < b ? a : b);
    return ((max - min) / 4).ceilToDouble().clamp(100, double.infinity);
  }
}

// ─── Stats 24h ───────────────────────────────────────────────

class _Stats24hRow extends StatelessWidget {
  final CryptoPrice price;
  const _Stats24hRow({required this.price});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatCard(label: 'Max 24h', value: Formatters.formatCurrency(price.high24h), color: AppTheme.incomeColor, icon: Icons.arrow_upward_rounded)),
        const SizedBox(width: 10),
        Expanded(child: _StatCard(label: 'Min 24h', value: Formatters.formatCurrency(price.low24h), color: AppTheme.expenseColor, icon: Icons.arrow_downward_rounded)),
        const SizedBox(width: 10),
        Expanded(child: _StatCard(
          label: 'Market Cap',
          value: '€${_compact(price.marketCapEur)}',
          color: AppTheme.primaryColor,
          icon: Icons.bar_chart_rounded,
        )),
      ],
    );
  }

  String _compact(double v) {
    if (v >= 1e12) return '${(v / 1e12).toStringAsFixed(1)}T';
    if (v >= 1e9) return '${(v / 1e9).toStringAsFixed(1)}B';
    if (v >= 1e6) return '${(v / 1e6).toStringAsFixed(1)}M';
    return v.toStringAsFixed(0);
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _StatCard({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: color, size: 13),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
          ]),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ─── Portafoglio Utente ───────────────────────────────────────

class _PortfolioCard extends ConsumerStatefulWidget {
  final double btcAmount;
  final CryptoPrice price;
  const _PortfolioCard({required this.btcAmount, required this.price});

  @override
  ConsumerState<_PortfolioCard> createState() => _PortfolioCardState();
}

class _PortfolioCardState extends ConsumerState<_PortfolioCard> {
  bool _editing = false;
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: widget.btcAmount > 0 ? widget.btcAmount.toString() : '',
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final btcAmount = widget.btcAmount;
    final valueEur  = btcAmount * widget.price.priceEur;
    final hasAmount = btcAmount > 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.08),
            AppTheme.cardDark,
          ],
        ),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Il mio portafoglio BTC',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              GestureDetector(
                onTap: () {
                  if (_editing) {
                    final val = double.tryParse(_ctrl.text.replaceAll(',', '.')) ?? 0;
                    ref.read(userBtcAmountProvider.notifier).set(val);
                    setState(() => _editing = false);
                  } else {
                    setState(() => _editing = true);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    _editing ? 'Salva' : 'Modifica',
                    style: const TextStyle(color: AppTheme.primaryColor, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_editing) ...[
            TextFormField(
              controller: _ctrl,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+[.,]?\d{0,8}'))],
              decoration: InputDecoration(
                labelText: 'Quantità BTC',
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('₿', style: TextStyle(color: Color(0xFFF7931A), fontSize: 18, fontWeight: FontWeight.w700)),
                ),
                suffixText: 'BTC',
              ),
              onFieldSubmitted: (v) {
                final val = double.tryParse(v.replaceAll(',', '.')) ?? 0;
                ref.read(userBtcAmountProvider.notifier).set(val);
                setState(() => _editing = false);
              },
            ),
            const SizedBox(height: 16),
          ],

          if (!_editing && !hasAmount)
            const Text(
              'Inserisci la quantità di BTC che possiedi per vedere il valore in EUR.',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
            ),

          if (!_editing && hasAmount) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Quantità', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Text('₿ ', style: TextStyle(color: Color(0xFFF7931A), fontSize: 18, fontWeight: FontWeight.w700)),
                        Text(
                          btcAmount.toStringAsFixed(btcAmount < 1 ? 8 : 4),
                          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Valore in EUR', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                    const SizedBox(height: 2),
                    Text(
                      Formatters.formatCurrency(valueEur),
                      style: const TextStyle(
                        color: AppTheme.incomeColor,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.borderDark),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '1 BTC = ${Formatters.formatCurrency(widget.price.priceEur)}',
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('LIVE', style: TextStyle(color: AppTheme.primaryColor, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Loading / Error states ───────────────────────────────────

class _CryptoLoadingState extends StatelessWidget {
  const _CryptoLoadingState();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFF7931A).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Center(
            child: Text('₿', style: TextStyle(color: Color(0xFFF7931A), fontSize: 28, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 16),
        const CircularProgressIndicator(color: Color(0xFFF7931A), strokeWidth: 2.5),
        const SizedBox(height: 12),
        const Text('Recupero prezzo Bitcoin...', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
      ],
    );
  }
}

class _CryptoErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  final String? error;
  const _CryptoErrorState({required this.onRetry, this.error});

  @override
  Widget build(BuildContext context) {
    // Determina il messaggio in base al tipo di errore
    final isRateLimit = error?.contains('Rate limit') ?? false;
    final isTimeout   = error?.contains('Timeout') ?? false;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isRateLimit ? Icons.hourglass_empty_rounded : Icons.wifi_off_rounded,
          color: AppTheme.textMuted,
          size: 48,
        ),
        const SizedBox(height: 12),
        Text(
          isRateLimit
              ? 'Troppe richieste'
              : isTimeout
                  ? 'Connessione lenta'
                  : 'Impossibile recuperare i dati',
          style: const TextStyle(color: AppTheme.textTertiary, fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          isRateLimit
              ? 'CoinGecko ha un limite di richieste. Aspetta qualche secondo.'
              : isTimeout
                  ? 'Il server ha impiegato troppo tempo a rispondere.'
                  : 'Controlla la connessione internet e riprova.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('Riprova'),
        ),
      ],
    );
  }
}


