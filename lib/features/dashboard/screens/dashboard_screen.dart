import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/widgets/transaction_tile.dart';
import '../../../data/local/hive_service.dart';
import '../../../widget/tm_widgets.dart';
import '../widgets/mini_chart_widget.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report          = ref.watch(monthlyReportProvider);
    final recentTx        = ref.watch(recentTransactionsProvider);
    final selectedDate    = ref.watch(selectedDateProvider);
    final patrimonio      = ref.watch(totalPatrimonioProvider);
    final totalIncomeAll  = ref.watch(totalIncomeAllTimeProvider);
    final totalExpenseAll = ref.watch(totalExpenseAllTimeProvider);

    final st        = ResponsiveLayout.getScreenType(context);
    final hPad      = ResponsiveLayout.horizontalPadding(context);
    final vSpace    = ResponsiveLayout.sectionSpacing(context);
    final gap       = ResponsiveLayout.columnGap(context);
    final topPad    = ResponsiveLayout.topPadding(context);
    final isDesktop = st == ScreenType.desktop;
    final isMobile  = st == ScreenType.mobile;

    void prevMonth() => ref.read(selectedDateProvider.notifier).state =
        DateTime(selectedDate.year, selectedDate.month - 1);
    void nextMonth() => ref.read(selectedDateProvider.notifier).state =
        DateTime(selectedDate.year, selectedDate.month + 1);

    return SafeArea(
      bottom: false,
      child: ResponsiveContent(
        child: TmFadeScroll(
          topFadeHeight: 0,
          bottomFadeHeight: isDesktop ? 32 : 80,
          child: CustomScrollView(
            physics: ResponsiveLayout.scrollPhysics(context),
            slivers: [

              // ─── HERO PATRIMONIO ─────────────────────────────────────
              SliverToBoxAdapter(
                child: _HeroPatrimonioCard(
                  patrimonio: patrimonio,
                  totalIncome: totalIncomeAll,
                  totalExpense: totalExpenseAll,
                  topPad: topPad,
                  hPad: hPad,
                  isDesktop: isDesktop,
                  onAdd: isMobile ? () => context.push('/add-transaction') : null,
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: vSpace * 0.75)),

              // ─── DESKTOP / TABLET ────────────────────────────────────
              if (!isMobile) ...[
                // Row: mese + balance | budget + obiettivi
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: hPad),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Column(
                            children: [
                              _MonthBalanceCard(
                                selectedDate: selectedDate,
                                report: report,
                                onPrev: prevMonth,
                                onNext: nextMonth,
                              ),
                              SizedBox(height: gap),
                              const MiniChartWidget(),
                            ],
                          ),
                        ),
                        SizedBox(width: gap),
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _BudgetAlerts(),
                              _SavingsGoalsMini(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: vSpace)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: hPad),
                    child: TmSectionHeader(
                      title: 'Ultimi Movimenti',
                      actionLabel: 'Vedi tutti',
                      onAction: () => context.go('/transactions'),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 10)),
              ],

              // ─── MOBILE ──────────────────────────────────────────────
              if (isMobile) ...[
                // Mese + Balance unificato
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: hPad),
                    child: _MonthBalanceCard(
                      selectedDate: selectedDate,
                      report: report,
                      onPrev: prevMonth,
                      onNext: nextMonth,
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: vSpace * 0.7)),

                // Mini chart full width
                const SliverToBoxAdapter(child: MiniChartWidget()),
                SliverToBoxAdapter(child: SizedBox(height: vSpace * 0.7)),

                // Budget
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: hPad),
                    child: _BudgetAlerts(),
                  ),
                ),
                // Obiettivi
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: hPad),
                    child: _SavingsGoalsMini(),
                  ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: vSpace * 0.8)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: hPad),
                    child: TmSectionHeader(
                      title: 'Ultimi Movimenti',
                      actionLabel: 'Vedi tutti',
                      onAction: () => context.go('/transactions'),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 10)),
              ],

              // ─── TRANSACTIONS LIST ────────────────────────────────────
              if (recentTx.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 40),
                    child: const TmEmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: 'Nessun movimento ancora',
                      subtitle: 'Tocca + per aggiungere il primo',
                      iconSize: 56,
                    ),
                  ),
                )
              else
                SliverFillRemaining(
                  hasScrollBody: true,
                  child: _FadingTransactionList(
                    transactions: recentTx,
                    hPad: hPad,
                    gap: gap,
                    isMobile: isMobile,
                    bottomPadding: ResponsiveLayout.bottomContentPadding(context),
                    gridColumns: ResponsiveLayout.gridColumns(context),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// FADING TRANSACTION LIST
// ═══════════════════════════════════════════════════════════════

class _FadingTransactionList extends StatefulWidget {
  final List<dynamic> transactions;
  final double hPad;
  final double gap;
  final bool isMobile;
  final double bottomPadding;
  final int gridColumns;

  const _FadingTransactionList({
    required this.transactions,
    required this.hPad,
    required this.gap,
    required this.isMobile,
    required this.bottomPadding,
    required this.gridColumns,
  });

  @override
  State<_FadingTransactionList> createState() => _FadingTransactionListState();
}

class _FadingTransactionListState extends State<_FadingTransactionList> {
  final ScrollController _scrollController = ScrollController();
  bool _showTopFade = false;
  bool _showBottomFade = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Controlla dopo il primo frame se c'è overflow
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkFades());
  }

  void _onScroll() {
    final pos = _scrollController.position;
    final atTop    = pos.pixels <= 0;
    final atBottom = pos.pixels >= pos.maxScrollExtent - 1;
    setState(() {
      _showTopFade    = !atTop;
      _showBottomFade = !atBottom && pos.maxScrollExtent > 0;
    });
  }

  void _checkFades() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    setState(() {
      _showBottomFade = pos.maxScrollExtent > 0;
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    Widget list;
    if (widget.isMobile) {
      list = ListView.builder(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          widget.hPad, 4, widget.hPad, widget.bottomPadding,
        ),
        itemCount: widget.transactions.length,
        itemBuilder: (ctx, i) =>
            TransactionTile(transaction: widget.transactions[i]),
      );
    } else {
      // Griglia per tablet/desktop
      list = GridView.builder(
        controller: _scrollController,
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          widget.hPad, 4, widget.hPad, widget.bottomPadding,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.gridColumns,
          mainAxisSpacing: 8,
          crossAxisSpacing: widget.gap,
          mainAxisExtent: 90,
        ),
        itemCount: widget.transactions.length,
        itemBuilder: (ctx, i) =>
            TransactionTile(transaction: widget.transactions[i]),
      );
    }

    return Stack(
      children: [
        list,

        // Fade TOP — visibile quando si scrolla verso il basso
        if (_showTopFade)
          Positioned(
            top: 0, left: 0, right: 0,
            height: 36,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      bgColor,
                      bgColor.withValues(alpha: 0),
                    ],
                  ),
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),

        // Fade BOTTOM — sempre visibile finché ci sono elementi fuori schermo
        if (_showBottomFade)
          Positioned(
            bottom: 0, left: 0, right: 0,
            height: widget.bottomPadding + 28,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      bgColor,
                      bgColor.withValues(alpha: 0),
                    ],
                  ),
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// HERO PATRIMONIO CARD
// ═══════════════════════════════════════════════════════════════

class _HeroPatrimonioCard extends StatefulWidget {
  final double patrimonio;
  final double totalIncome;
  final double totalExpense;
  final double topPad;
  final double hPad;
  final bool isDesktop;
  final VoidCallback? onAdd;

  const _HeroPatrimonioCard({
    required this.patrimonio,
    required this.totalIncome,
    required this.totalExpense,
    required this.topPad,
    required this.hPad,
    required this.isDesktop,
    this.onAdd,
  });

  @override
  State<_HeroPatrimonioCard> createState() => _HeroPatrimonioCardState();
}

class _HeroPatrimonioCardState extends State<_HeroPatrimonioCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;
  late final Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _shimmer = CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPositive = widget.patrimonio >= 0;
    final accent = isPositive ? AppTheme.incomeColor : AppTheme.expenseColor;
    final hPad = widget.hPad;
    final topPad = widget.topPad;

    return AnimatedBuilder(
      animation: _shimmer,
      builder: (context, _) {
        // value va 0→1→0 con easeInOut: nessun salto, transizione fluida
        final t = _shimmer.value;
        return Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(hPad, topPad + 8, hPad, 28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.surfaceDark,
                accent.withValues(alpha: 0.08 + t * 0.16),
                accent.withValues(alpha: 0.18 + t * 0.10),
                AppTheme.cardDarkAlt,
              ],
              stops: [
                0.0,
                0.2 + t * 0.15,
                0.55 + t * 0.15,
                1.0,
              ],
            ),
            border: Border(
              bottom: BorderSide(
                color: accent.withValues(alpha: 0.12 + t * 0.08),
                width: 1,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Patrimonio totale',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: widget.isDesktop ? 14 : 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        Formatters.formatMonthYear(DateTime.now()),
                        style: TextStyle(
                          color: Colors.white24,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Indicatore positivo/negativo
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: accent.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                              color: accent,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isPositive ? 'Positivo' : 'Negativo',
                              style: TextStyle(
                                color: accent,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.onAdd != null) ...[
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: widget.onAdd,
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppTheme.cardDark,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.borderDark),
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              color: AppTheme.primaryColor,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Importo principale
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  Formatters.formatCurrency(widget.patrimonio),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: widget.isDesktop ? 44 : 38,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                    height: 1.1,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Quick stats row
              Row(
                children: [
                  _QuickStat(
                    label: 'Entrate totali',
                    amount: widget.totalIncome,
                    icon: Icons.south_west_rounded,
                    color: AppTheme.incomeColor,
                  ),
                  const SizedBox(width: 10),
                  _QuickStat(
                    label: 'Uscite totali',
                    amount: widget.totalExpense,
                    icon: Icons.north_east_rounded,
                    color: AppTheme.expenseColor,
                  ),
                  const SizedBox(width: 10),
                  // Tasso risparmio
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.savings_rounded,
                                  color: AppTheme.warningColor, size: 14),
                              const SizedBox(width: 5),
                              Text(
                                'Risparmio',
                                style: TextStyle(
                                    color: Colors.white38,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.totalIncome > 0
                                ? '${((1 - widget.totalExpense / widget.totalIncome).clamp(0, 1) * 100).toStringAsFixed(0)}%'
                                : '—',
                            style: const TextStyle(
                              color: AppTheme.warningColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QuickStat extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;

  const _QuickStat({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 13),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                Formatters.formatCurrency(amount),
                style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// MONTH + BALANCE CARD (selettore mese + bilancio mensile unificati)
// ═══════════════════════════════════════════════════════════════

class _MonthBalanceCard extends StatelessWidget {
  final DateTime selectedDate;
  final dynamic report;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _MonthBalanceCard({
    required this.selectedDate,
    required this.report,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final balance = (report.totalIncome as double) - (report.totalExpense as double);
    final isPositive = balance >= 0;
    final accentBalance = isPositive ? AppTheme.incomeColor : AppTheme.expenseColor;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: Column(
        children: [
          // Selettore mese
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 6, 6, 0),
            child: Row(
              children: [
                IconButton(
                  onPressed: onPrev,
                  icon: const Icon(Icons.chevron_left_rounded,
                      color: Colors.white54, size: 22),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                ),
                Expanded(
                  child: Text(
                    Formatters.formatMonthYear(selectedDate).toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onNext,
                  icon: const Icon(Icons.chevron_right_rounded,
                      color: Colors.white54, size: 22),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppTheme.borderDark),

          // Bilancio + dettagli
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Bilancio netto
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bilancio mensile',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          Formatters.formatCurrency(balance),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: accentBalance.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isPositive ? 'In attivo' : 'In passivo',
                          style: TextStyle(
                            color: accentBalance,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Barra visiva entrate/uscite
                Expanded(
                  flex: 4,
                  child: _BalanceBar(
                    income: report.totalIncome as double,
                    expense: report.totalExpense as double,
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

class _BalanceBar extends StatelessWidget {
  final double income;
  final double expense;

  const _BalanceBar({required this.income, required this.expense});

  @override
  Widget build(BuildContext context) {
    final total = income + expense;
    final incomeRatio = total > 0 ? income / total : 0.5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Entrate
        _BarRow(
          label: 'Entrate',
          amount: income,
          color: AppTheme.incomeColor,
          icon: Icons.arrow_downward_rounded,
        ),
        const SizedBox(height: 8),
        // Barra proporzionale
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 6,
            child: Row(
              children: [
                Expanded(
                  flex: (incomeRatio * 100).round(),
                  child: ColoredBox(color: AppTheme.incomeColor),
                ),
                Expanded(
                  flex: ((1 - incomeRatio) * 100).round().clamp(1, 100),
                  child: ColoredBox(color: AppTheme.expenseColor),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Uscite
        _BarRow(
          label: 'Uscite',
          amount: expense,
          color: AppTheme.expenseColor,
          icon: Icons.arrow_upward_rounded,
        ),
      ],
    );
  }
}

class _BarRow extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;

  const _BarRow({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(icon, color: color, size: 12),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(color: Colors.white38, fontSize: 10)),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  Formatters.formatCurrency(amount),
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// BUDGET ALERTS
// ═══════════════════════════════════════════════════════════════

class _BudgetAlerts extends ConsumerWidget {
  const _BudgetAlerts();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetStatus = ref.watch(budgetStatusProvider);
    if (budgetStatus.isEmpty) return const SizedBox.shrink();

    final alerts = budgetStatus.entries.where((e) {
      final pct = e.value.budget.limit > 0
          ? e.value.spent / e.value.budget.limit
          : 0.0;
      return pct > 0.7;
    }).toList()
      ..sort((a, b) => (b.value.spent / b.value.budget.limit)
          .compareTo(a.value.spent / a.value.budget.limit));

    if (alerts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TmSectionHeader(
          title: '⚠️ Budget',
          actionLabel: 'Gestisci',
          onAction: () => context.push('/budget'),
        ),
        const SizedBox(height: 10),
        ...alerts.take(3).map((entry) {
          final cat   = HiveService.getCategoryById(entry.key);
          final pct   = entry.value.spent / entry.value.budget.limit;
          final isOver = pct >= 1.0;
          final color = isOver ? AppTheme.expenseColor : AppTheme.warningColor;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withValues(alpha: 0.22)),
            ),
            child: Row(
              children: [
                Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    color: Color(cat.colorValue).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    IconData(cat.iconCodePoint, fontFamily: 'MaterialIcons'),
                    color: Color(cat.colorValue), size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(cat.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13)),
                          Text(
                            '${Formatters.formatCurrency(entry.value.spent)} / '
                            '${Formatters.formatCurrency(entry.value.budget.limit)}',
                            style: TextStyle(color: color, fontSize: 11,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      TmProgressBar(
                          value: pct.clamp(0, 1),
                          color: color,
                          height: 5,
                          borderRadius: 4),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SAVINGS GOALS MINI
// ═══════════════════════════════════════════════════════════════

class _SavingsGoalsMini extends ConsumerWidget {
  const _SavingsGoalsMini();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals       = ref.watch(allSavingsProvider);
    final activeGoals = goals.where((g) => !g.isCompleted).take(2).toList();
    if (activeGoals.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TmSectionHeader(
          title: '🎯 Obiettivi',
          actionLabel: 'Vedi tutti',
          onAction: () => context.push('/savings'),
        ),
        const SizedBox(height: 10),
        ...activeGoals.map((goal) {
          final color = Color(goal.colorValue);
          final remaining = goal.targetAmount - goal.currentAmount;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.borderDark),
            ),
            child: Row(
              children: [
                TmIconBadge.fromCodePoint(
                  iconCodePoint: goal.iconCodePoint,
                  colorValue: goal.colorValue,
                  size: 36,
                  iconSize: 17,
                  borderRadius: 10,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(goal.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 13),
                                overflow: TextOverflow.ellipsis),
                          ),
                          Text(
                            '${(goal.progress * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.w700,
                                fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      TmProgressBar(
                          value: goal.progress,
                          color: color,
                          height: 5,
                          borderRadius: 4),
                      const SizedBox(height: 4),
                      Text(
                        'Mancano ${Formatters.formatCurrency(remaining)} · ${goal.daysLeft}gg',
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 16),
      ],
    );
  }
}

