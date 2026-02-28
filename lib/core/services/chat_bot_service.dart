import '../../data/models/savings_goal_model.dart';
import '../../core/utils/formatters.dart';

/// Modello di un messaggio chat
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final SavingsPlanSuggestion? suggestion;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.suggestion,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Suggerimento piano di risparmio estratto dal chatbot
class SavingsPlanSuggestion {
  final String name;
  final double targetAmount;
  final DateTime deadline;
  final double dailyAmount;
  final double weeklyAmount;
  final double monthlyAmount;

  SavingsPlanSuggestion({
    required this.name,
    required this.targetAmount,
    required this.deadline,
    required this.dailyAmount,
    required this.weeklyAmount,
    required this.monthlyAmount,
  });
}

class ChatBotService {
  /// Analizza il messaggio dell'utente e genera una risposta
  static ChatMessage processMessage(String userMessage, {
    double? currentBalance,
    double? monthlyIncome,
    double? monthlyExpenses,
    List<SavingsGoalModel>? existingGoals,
  }) {
    final msg = userMessage.toLowerCase().trim();

    // Saluto
    if (_isGreeting(msg)) {
      return ChatMessage(
        text: 'Ciao! 👋 Sono il tuo assistente finanziario.\n\n'
            'Posso aiutarti a:\n'
            '• 💰 Creare piani di risparmio\n'
            '• 📊 Analizzare le tue spese\n'
            '• 🎯 Raggiungere obiettivi finanziari\n\n'
            'Prova a dirmi qualcosa come:\n'
            '"Voglio risparmiare 1000€ entro 6 mesi"',
        isUser: false,
      );
    }

    // Richiesta di risparmio
    final savingsPlan = _parseSavingsRequest(msg);
    if (savingsPlan != null) {
      return ChatMessage(
        text: '🎯 Ottimo obiettivo! Ecco il tuo piano di accumulo:\n\n'
            '📌 **${savingsPlan.name}**\n'
            '💰 Obiettivo: ${Formatters.formatCurrency(savingsPlan.targetAmount)}\n'
            '📅 Scadenza: ${Formatters.formatDate(savingsPlan.deadline)}\n\n'
            '📋 Per raggiungere l\'obiettivo devi risparmiare:\n'
            '• ${Formatters.formatCurrency(savingsPlan.dailyAmount)} al giorno\n'
            '• ${Formatters.formatCurrency(savingsPlan.weeklyAmount)} a settimana\n'
            '• ${Formatters.formatCurrency(savingsPlan.monthlyAmount)} al mese\n\n'
            '${_getSavingsTip(savingsPlan, monthlyIncome, monthlyExpenses)}\n\n'
            'Vuoi che crei questo obiettivo di risparmio nell\'app? 👇',
        isUser: false,
        suggestion: savingsPlan,
      );
    }

    // Analisi spese
    if (_isExpenseAnalysis(msg)) {
      return _generateExpenseAnalysis(monthlyIncome, monthlyExpenses, currentBalance);
    }

    // Consigli generali
    if (_isAdviceRequest(msg)) {
      return _generateFinancialAdvice(monthlyIncome, monthlyExpenses);
    }

    // Stato obiettivi
    if (_isGoalStatus(msg)) {
      return _generateGoalStatus(existingGoals);
    }

    // Help
    if (_isHelp(msg)) {
      return ChatMessage(
        text: '📖 Ecco cosa posso fare per te:\n\n'
            '💰 **Piani di risparmio**\n'
            'Dimmi quanto vuoi risparmiare e entro quando.\n'
            'Es: "Voglio risparmiare 5000€ in 12 mesi"\n\n'
            '📊 **Analisi spese**\n'
            'Chiedi "come vanno le mie spese?" o "analizza le mie finanze"\n\n'
            '💡 **Consigli**\n'
            'Chiedi "dammi dei consigli" per suggerimenti personalizzati\n\n'
            '🎯 **Stato obiettivi**\n'
            'Chiedi "come vanno i miei obiettivi?" per un riepilogo',
        isUser: false,
      );
    }

    // Default
    return ChatMessage(
      text: 'Non ho capito bene 🤔\n\n'
          'Prova a formulare la richiesta in modo diverso. Esempi:\n'
          '• "Voglio risparmiare 2000€ entro dicembre"\n'
          '• "Come vanno le mie spese?"\n'
          '• "Dammi dei consigli finanziari"\n'
          '• "Aiuto" per vedere tutte le funzioni',
      isUser: false,
    );
  }

  static bool _isGreeting(String msg) {
    final greetings = ['ciao', 'salve', 'buongiorno', 'buonasera', 'hey', 'ehi', 'hello', 'hi'];
    return greetings.any((g) => msg.startsWith(g) || msg == g);
  }

  static bool _isExpenseAnalysis(String msg) {
    return msg.contains('spese') || msg.contains('analiz') ||
        msg.contains('finanz') || msg.contains('bilancio') ||
        msg.contains('andamento') || msg.contains('situazione');
  }

  static bool _isAdviceRequest(String msg) {
    return msg.contains('consiglio') || msg.contains('consigli') ||
        msg.contains('suggerim') || msg.contains('cosa dovrei') ||
        msg.contains('come posso');
  }

  static bool _isGoalStatus(String msg) {
    return msg.contains('obiettiv') || msg.contains('goal') ||
        msg.contains('traguard') || msg.contains('stato risparmio');
  }

  static bool _isHelp(String msg) {
    return msg.contains('aiuto') || msg.contains('help') ||
        msg.contains('cosa puoi') || msg.contains('cosa sai') ||
        msg.contains('funzion');
  }

  static SavingsPlanSuggestion? _parseSavingsRequest(String msg) {
    // Pattern: risparmiare X euro entro Y mesi / in Y mesi / entro data
    double? amount;
    DateTime? deadline;
    String name = 'Piano di risparmio';

    // Estrai importo
    final amountPatterns = [
      RegExp(r'(\d+[.,]?\d*)\s*(?:€|euro|eur)'),
      RegExp(r'(?:€|euro|eur)\s*(\d+[.,]?\d*)'),
      RegExp(r'risparmiare\s+(\d+[.,]?\d*)'),
      RegExp(r'mettere da parte\s+(\d+[.,]?\d*)'),
      RegExp(r'accumulare\s+(\d+[.,]?\d*)'),
      RegExp(r'raccogliere\s+(\d+[.,]?\d*)'),
    ];

    for (final pattern in amountPatterns) {
      final match = pattern.firstMatch(msg);
      if (match != null) {
        amount = double.tryParse(match.group(1)!.replaceAll(',', '.'));
        if (amount != null && amount > 0) break;
      }
    }

    if (amount == null) return null;

    // Estrai periodo
    final monthPattern = RegExp(r'(\d+)\s*mes[ie]');
    final weekPattern = RegExp(r'(\d+)\s*settiman[ae]');
    final yearPattern = RegExp(r'(\d+)\s*ann[oi]');
    final dayPattern = RegExp(r'(\d+)\s*giorn[oi]');

    final now = DateTime.now();

    if (monthPattern.hasMatch(msg)) {
      final months = int.parse(monthPattern.firstMatch(msg)!.group(1)!);
      deadline = DateTime(now.year, now.month + months, now.day);
    } else if (weekPattern.hasMatch(msg)) {
      final weeks = int.parse(weekPattern.firstMatch(msg)!.group(1)!);
      deadline = now.add(Duration(days: weeks * 7));
    } else if (yearPattern.hasMatch(msg)) {
      final years = int.parse(yearPattern.firstMatch(msg)!.group(1)!);
      deadline = DateTime(now.year + years, now.month, now.day);
    } else if (dayPattern.hasMatch(msg)) {
      final days = int.parse(dayPattern.firstMatch(msg)!.group(1)!);
      deadline = now.add(Duration(days: days));
    } else {
      // Cerca mese specifico
      final months = {
        'gennaio': 1, 'febbraio': 2, 'marzo': 3, 'aprile': 4,
        'maggio': 5, 'giugno': 6, 'luglio': 7, 'agosto': 8,
        'settembre': 9, 'ottobre': 10, 'novembre': 11, 'dicembre': 12,
      };
      for (final entry in months.entries) {
        if (msg.contains(entry.key)) {
          int year = now.year;
          if (entry.value <= now.month) year++;
          // Cerca anno esplicito
          final yearExplicit = RegExp(r'20(\d{2})').firstMatch(msg);
          if (yearExplicit != null) {
            year = int.parse('20${yearExplicit.group(1)!}');
          }
          deadline = DateTime(year, entry.value + 1, 0); // ultimo giorno del mese
          break;
        }
      }
    }

    // Se manca la scadenza, proponi 6 mesi
    deadline ??= DateTime(now.year, now.month + 6, now.day);

    final totalDays = deadline.difference(now).inDays;
    if (totalDays <= 0) return null;

    final dailyAmount = amount / totalDays;
    final weeklyAmount = amount / (totalDays / 7);
    final monthlyAmount = amount / (totalDays / 30);

    // Prova a dare un nome specifico
    if (msg.contains('viaggio') || msg.contains('vacanz')) {
      name = 'Viaggio';
    } else if (msg.contains('auto') || msg.contains('macchina')) {
      name = 'Nuova Auto';
    } else if (msg.contains('telefono') || msg.contains('iphone') || msg.contains('smartphone')) {
      name = 'Nuovo Telefono';
    } else if (msg.contains('casa') || msg.contains('appartamento')) {
      name = 'Casa';
    } else if (msg.contains('computer') || msg.contains('pc') || msg.contains('laptop') || msg.contains('mac')) {
      name = 'Nuovo Computer';
    } else if (msg.contains('emergenz')) {
      name = 'Fondo Emergenza';
    } else if (msg.contains('matrimonio') || msg.contains('nozze')) {
      name = 'Matrimonio';
    }

    return SavingsPlanSuggestion(
      name: name,
      targetAmount: amount,
      deadline: deadline,
      dailyAmount: dailyAmount,
      weeklyAmount: weeklyAmount,
      monthlyAmount: monthlyAmount,
    );
  }

  static String _getSavingsTip(SavingsPlanSuggestion plan, double? income, double? expenses) {
    if (income != null && expenses != null && income > 0) {
      final savings = income - expenses;
      if (savings <= 0) {
        return '⚠️ Attenzione: le tue spese superano le entrate. '
            'Cerca di ridurre le spese prima di iniziare a risparmiare.';
      }
      final feasibility = plan.monthlyAmount / savings * 100;
      if (feasibility > 80) {
        return '⚠️ Questo piano richiede il ${feasibility.toStringAsFixed(0)}% del tuo risparmio mensile. '
            'Potrebbe essere impegnativo, considera una scadenza più lunga.';
      } else if (feasibility > 50) {
        return '💪 Questo piano è sfidante ma fattibile! Richiede circa il ${feasibility.toStringAsFixed(0)}% '
            'del tuo risparmio mensile disponibile.';
      } else {
        return '✅ Ottima notizia! Questo piano è molto fattibile, richiede solo il ${feasibility.toStringAsFixed(0)}% '
            'del tuo risparmio mensile.';
      }
    }
    return '💡 Consiglio: imposta dei promemoria per ricordarti di risparmiare regolarmente!';
  }

  static ChatMessage _generateExpenseAnalysis(double? income, double? expenses, double? balance) {
    if (income == null || expenses == null) {
      return ChatMessage(
        text: '📊 Non ho abbastanza dati per analizzare le tue finanze.\n\n'
            'Inizia ad inserire le tue entrate e spese dalla schermata principale '
            'per avere un\'analisi completa!',
        isUser: false,
      );
    }

    final savings = income - expenses;
    final savingsRate = income > 0 ? (savings / income * 100) : 0.0;

    String emoji;
    String status;
    if (savingsRate >= 30) {
      emoji = '🏆';
      status = 'Eccellente! Stai risparmiando più del 30%.';
    } else if (savingsRate >= 20) {
      emoji = '✅';
      status = 'Ottimo lavoro! La regola del 50/30/20 è rispettata.';
    } else if (savingsRate >= 10) {
      emoji = '👍';
      status = 'Buono, ma potresti migliorare. Punta al 20%.';
    } else if (savingsRate > 0) {
      emoji = '⚠️';
      status = 'Risparmi poco. Prova a tagliare qualche spesa non necessaria.';
    } else {
      emoji = '🚨';
      status = 'Le spese superano le entrate! Rivedi urgentemente il tuo budget.';
    }

    return ChatMessage(
      text: '$emoji **Analisi finanziaria del mese**\n\n'
          '📥 Entrate: ${Formatters.formatCurrency(income)}\n'
          '📤 Spese: ${Formatters.formatCurrency(expenses)}\n'
          '💰 Risparmio: ${Formatters.formatCurrency(savings)}\n'
          '📈 Tasso di risparmio: ${savingsRate.toStringAsFixed(1)}%\n\n'
          '$status',
      isUser: false,
    );
  }

  static ChatMessage _generateFinancialAdvice(double? income, double? expenses) {
    final tips = <String>[];

    if (income != null && expenses != null) {
      final ratio = expenses / (income > 0 ? income : 1);
      if (ratio > 0.9) {
        tips.add('🔴 Riduci le spese del ${((ratio - 0.7) * 100).toStringAsFixed(0)}% per avere un margine sicuro');
      }
      if (ratio > 0.5) {
        tips.add('🏠 Le spese essenziali non dovrebbero superare il 50% delle entrate');
      }
    }

    tips.addAll([
      '💡 Crea un fondo emergenza di 3-6 mesi di spese',
      '🔄 Automatizza i risparmi: metti da parte appena ricevi lo stipendio',
      '📝 Traccia tutte le spese, anche le più piccole',
      '🎯 Usa la regola 50/30/20: 50% necessità, 30% desideri, 20% risparmi',
      '☕ Piccole spese quotidiane si accumulano: un caffè al giorno = €1000/anno',
      '📱 Rivedi gli abbonamenti: elimina quelli che non usi',
      '🛒 Fai una lista della spesa e rispettala',
      '💳 Evita acquisti d\'impulso: aspetta 48h prima di comprare',
    ]);

    // Prendi 5 consigli casuali/rilevanti
    final selectedTips = tips.take(5).join('\n');

    return ChatMessage(
      text: '💡 **Consigli finanziari per te**\n\n$selectedTips\n\n'
          'Hai bisogno di aiuto con qualcosa in particolare? 😊',
      isUser: false,
    );
  }

  static ChatMessage _generateGoalStatus(List<SavingsGoalModel>? goals) {
    if (goals == null || goals.isEmpty) {
      return ChatMessage(
        text: '🎯 Non hai ancora creato obiettivi di risparmio.\n\n'
            'Dimmi quanto vuoi risparmiare e ti creerò un piano personalizzato!\n'
            'Es: "Voglio risparmiare 3000€ per un viaggio in 8 mesi"',
        isUser: false,
      );
    }

    final buffer = StringBuffer('🎯 **I tuoi obiettivi di risparmio**\n\n');

    for (final goal in goals) {
      final progressPercent = (goal.progress * 100).toStringAsFixed(0);
      final emoji = goal.isCompleted
          ? '✅'
          : goal.progress > 0.5
              ? '🟡'
              : '🔵';

      buffer.writeln('$emoji **${goal.name}**');
      buffer.writeln('   ${Formatters.formatCurrency(goal.currentAmount)} / '
          '${Formatters.formatCurrency(goal.targetAmount)} ($progressPercent%)');
      if (!goal.isCompleted) {
        buffer.writeln('   ⏰ ${goal.daysLeft} giorni rimanenti');
      }
      buffer.writeln();
    }

    final completed = goals.where((g) => g.isCompleted).length;
    if (completed > 0) {
      buffer.writeln('🏆 Hai completato $completed obiettiv${completed == 1 ? 'o' : 'i'}!');
    }

    return ChatMessage(
      text: buffer.toString(),
      isUser: false,
    );
  }
}


