import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/export_service.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../config/providers.dart';
import '../../../data/local/hive_service.dart';
import '../../../widget/tm_widgets.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTransactions = ref.watch(allTransactionsProvider);
    final hPadding = ResponsiveLayout.horizontalPadding(context);
    final topPad = ResponsiveLayout.topPadding(context);
    final vSpacing = ResponsiveLayout.sectionSpacing(context);

    return SafeArea(
      bottom: false,
      child: ResponsiveContent(
        child: TmFadeScroll(
          topFadeHeight: 24,
          bottomFadeHeight: ResponsiveLayout.getScreenType(context) == ScreenType.mobile ? 80 : 40,
          child: SingleChildScrollView(
          physics: ResponsiveLayout.scrollPhysics(context),
          padding: EdgeInsets.fromLTRB(hPadding, topPad, hPadding, ResponsiveLayout.bottomContentPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Impostazioni',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: vSpacing + 8),

            // Quick Actions
            _SettingsGroup(
              title: 'Funzionalità',
              items: [
                _SettingsItem(
                  icon: Icons.pie_chart_rounded,
                  iconColor: AppTheme.warningColor,
                  title: 'Budget',
                  subtitle: 'Gestisci i budget per categoria',
                  onTap: () => context.push('/budget'),
                ),
                _SettingsItem(
                  icon: Icons.repeat_rounded,
                  iconColor: AppTheme.secondaryColor,
                  title: 'Transazioni Ricorrenti',
                  subtitle: 'Bollette, abbonamenti, stipendio',
                  onTap: () => context.push('/recurring'),
                ),
                _SettingsItem(
                  icon: Icons.savings_rounded,
                  iconColor: AppTheme.incomeColor,
                  title: 'Obiettivi di Risparmio',
                  subtitle: 'Crea e monitora i tuoi obiettivi',
                  onTap: () => context.push('/savings'),
                ),
                _SettingsItem(
                  icon: Icons.currency_bitcoin_rounded,
                  iconColor: const Color(0xFFF7931A),
                  title: 'Bitcoin & Crypto',
                  subtitle: 'Prezzo live BTC e portafoglio',
                  onTap: () => context.push('/crypto'),
                ),
                _SettingsItem(
                  icon: Icons.auto_awesome_rounded,
                  iconColor: const Color(0xFF00D2D3),
                  title: 'FinBot – Assistente AI',
                  subtitle: 'Piani di risparmio e consigli',
                  onTap: () => context.push('/chat'),
                ),
              ],
            ),

            SizedBox(height: vSpacing),

            // Valuta
            _SettingsGroup(
              title: 'Generali',
              items: [
                _SettingsItem(
                  icon: Icons.euro_rounded,
                  iconColor: AppTheme.warningColor,
                  title: 'Valuta',
                  subtitle: HiveService.currentCurrency == '€'
                      ? 'EUR (€)'
                      : HiveService.currentCurrency == '\$'
                          ? 'USD (\$)'
                          : HiveService.currentCurrency == '£'
                              ? 'GBP (£)'
                              : HiveService.currentCurrency,
                  onTap: () => _showCurrencyPicker(context, ref),
                ),
                _SettingsItem(
                  icon: Icons.palette_rounded,
                  iconColor: AppTheme.primaryColor,
                  title: 'Tema',
                  subtitle: 'Dark',
                  onTap: () {},
                ),
              ],
            ),


            SizedBox(height: vSpacing),

            // Dati
            _SettingsGroup(
              title: 'Dati',
              items: [
                _SettingsItem(
                  icon: Icons.file_download_outlined,
                  iconColor: Colors.cyan,
                  title: 'Esporta CSV',
                  subtitle: '${allTransactions.length} movimenti',
                  onTap: () async {
                    if (allTransactions.isEmpty) {
                      _showSnack(context, 'Nessun movimento da esportare');
                      return;
                    }
                    try {
                      await ExportService.exportToCsv(allTransactions);
                    } catch (e) {
                      if (context.mounted) {
                        TmTopNotification.error(context, 'Errore durante l\'esportazione');
                      }
                    }
                  },
                ),
                _SettingsItem(
                  icon: Icons.backup_rounded,
                  iconColor: AppTheme.incomeColor,
                  title: 'Backup Completo',
                  subtitle: 'Esporta tutti i dati in JSON',
                  onTap: () async {
                    try {
                      await ExportService.exportBackupJson();
                      if (context.mounted) {
                        TmTopNotification.success(context, 'Backup creato con successo');
                      }
                    } catch (e) {
                      if (context.mounted) {
                        TmTopNotification.error(context, 'Errore durante il backup');
                      }
                    }
                  },
                ),
                _SettingsItem(
                  icon: Icons.delete_outline_rounded,
                  iconColor: AppTheme.expenseColor,
                  title: 'Cancella Tutti i Dati',
                  subtitle: 'Elimina tutti i movimenti',
                  onTap: () => _showDeleteConfirmation(context, ref),
                ),
              ],
            ),

            SizedBox(height: vSpacing),

            _SettingsGroup(
              title: 'Info',
              items: [
                _SettingsItem(
                  icon: Icons.info_outline_rounded,
                  iconColor: Colors.white54,
                  title: 'Versione',
                  subtitle: '1.0.0',
                  onTap: () {},
                ),
              ],
            ),

            SizedBox(height: vSpacing + 8),

            Center(
              child: Text(
                'FinanceApp v1.0.0',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.white24),
              ),
            ),
          ],
          ),
        ),
        ),
      ),
    );
  }

  void _showSnack(BuildContext context, String message) {
    TmTopNotification.warning(context, message);
  }

  void _showCurrencyPicker(BuildContext context, WidgetRef ref) {
    final currencies = [
      ('€', 'EUR – Euro'),
      ('\$', 'USD – Dollaro USA'),
      ('£', 'GBP – Sterlina'),
      ('CHF', 'CHF – Franco Svizzero'),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardDark,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TmBottomSheetHandle(),
            const SizedBox(height: 20),
            Text('Seleziona Valuta',
                style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 16),
            ...currencies.map((c) {
              final isSelected = HiveService.currentCurrency == c.$1;
              return ListTile(
                onTap: () async {
                  final nav = Navigator.of(ctx);
                  await HiveService.setCurrency(c.$1);
                  nav.pop();
                  // Force UI rebuild
                  ref.read(allTransactionsProvider.notifier).refresh();
                },
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryColor.withValues(alpha: 0.2)
                        : AppTheme.surfaceDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : AppTheme.borderDark,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      c.$1,
                      style: TextStyle(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : Colors.white54,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                title: Text(c.$2),
                trailing: isSelected
                    ? const Icon(Icons.check_rounded,
                        color: AppTheme.primaryColor)
                    : null,
              );
            }),
          ],
        ),
      ),
    );
  }


  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancella tutti i dati?'),
        content: const Text(
          'Questa azione è irreversibile. Tutti i movimenti, budget e obiettivi verranno eliminati.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('Annulla', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              ref.read(allTransactionsProvider.notifier).deleteAll();
              Navigator.pop(ctx);
              TmTopNotification.success(context, 'Tutti i dati sono stati eliminati');
            },
            child: const Text('Elimina',
                style: TextStyle(color: AppTheme.expenseColor)),
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<_SettingsItem> items;

  const _SettingsGroup({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white38,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardDark,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.borderDark, width: 0.8),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.03),
                blurRadius: 20,
                spreadRadius: -8,
              ),
            ],
          ),
          child: Column(
            children: List.generate(items.length, (i) {
              final item = items[i];
              return Column(
                children: [
                  if (i > 0)
                    const Divider(
                        height: 1, indent: 60, color: AppTheme.borderDark),
                  item,
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: onTap,
      leading: TmIconBadge(
        icon: icon,
        color: iconColor,
        size: 40,
        iconSize: 20,
        borderRadius: 12,
        opacity: 0.12,
        enableGlow: true,
      ),
      title: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: Colors.white38),
      ),
      trailing:
          const Icon(Icons.chevron_right_rounded, color: Colors.white24),
    );
  }
}

