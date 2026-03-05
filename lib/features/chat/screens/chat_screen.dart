import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../config/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/chat_bot_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/animated_builder.dart';
import '../../../data/models/savings_goal_model.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with TickerProviderStateMixin {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <ChatMessage>[];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _messages.add(ChatMessage(
      text: 'Ciao! 👋 Sono **FinBot**, il tuo assistente finanziario.\n\n'
          'Posso aiutarti a creare piani di risparmio, '
          'analizzare le spese e darti consigli!\n\n'
          '💡 Prova: "Voglio risparmiare 2000€ in 6 mesi"',
      isUser: false,
    ));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isTyping) return;

    HapticFeedback.lightImpact();

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isTyping = true;
    });
    _messageController.clear();
    _scrollToBottom();

    // Ottieni dati finanziari per il contesto
    final report = ref.read(monthlyReportProvider);
    final goals = ref.read(allSavingsProvider);

    final response = await ChatBotService.sendMessage(
      text,
      currentBalance: report.totalIncome - report.totalExpense,
      monthlyIncome: report.totalIncome,
      monthlyExpenses: report.totalExpense,
      existingGoals: goals,
    );

    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add(response);
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _createSavingsGoal(SavingsPlanSuggestion suggestion) {
    HapticFeedback.mediumImpact();

    final goal = SavingsGoalModel(
      id: const Uuid().v4(),
      name: suggestion.name,
      targetAmount: suggestion.targetAmount,
      currentAmount: 0,
      deadline: suggestion.deadline,
      iconCodePoint: Icons.savings_rounded.codePoint,
      colorValue: AppTheme.secondaryColor.toARGB32(),
      createdAt: DateTime.now(),
    );

    ref.read(allSavingsProvider.notifier).add(goal);

    setState(() {
      _messages.add(ChatMessage(
        text: '✅ Obiettivo "${suggestion.name}" creato con successo!\n\n'
            '${Formatters.formatCurrency(suggestion.targetAmount)} da raggiungere entro '
            '${Formatters.formatDate(suggestion.deadline)}.\n\n'
            'Puoi monitorare il progresso nella sezione Risparmi. '
            'In bocca al lupo! 🍀',
        isUser: false,
      ));
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final bottomSafe = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppTheme.scaffold(context),
      resizeToAvoidBottomInset: true,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Stack(
        children: [
          // Background gradient
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.secondaryColor.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -80,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primaryColor.withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Main content
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: GestureDetector(
                    onTap: () => FocusScope.of(context).unfocus(),
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: _messages.length + (_isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _messages.length && _isTyping) {
                          return _TypingIndicator();
                        }
                        return _MessageBubble(
                          message: _messages[index],
                          onCreateGoal: _messages[index].suggestion != null
                              ? () => _createSavingsGoal(_messages[index].suggestion!)
                              : null,
                        );
                      },
                    ),
                  ),
                ),
                // Quick actions - nascosti quando la tastiera è aperta
                if (!keyboardOpen)
                  _QuickActions(
                    onTap: (text) {
                      _messageController.text = text;
                      _sendMessage();
                    },
                  ),
                // Input
                _buildInput(keyboardOpen ? 0 : bottomSafe),
              ],
            ),
          ),
        ],
      ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.only(
            top: 8,
            left: 16,
            right: 16,
            bottom: 12,
          ),
          decoration: BoxDecoration(
            color: AppTheme.scaffold(context).withValues(alpha: 0.85),
            border: Border(
              bottom: BorderSide(color: AppTheme.border(context), width: 0.5),
            ),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppTheme.card(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border(context)),
                  ),
                  child: Icon(Icons.arrow_back_rounded, size: 20, color: AppTheme.textSecondary(context)),
                ),
              ),
              const SizedBox(width: 14),
              // Bot avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00D2D3), Color(0xFF00B894)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'FinBot',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppTheme.incomeColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Online',
                          style: const TextStyle(
                            color: AppTheme.incomeColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(double bottomPadding) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, bottomPadding + 10),
      decoration: BoxDecoration(
        color: AppTheme.surface(context).withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(color: AppTheme.border(context), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: AppTheme.card(context),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.border(context)),
              ),
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                textCapitalization: TextCapitalization.sentences,
                maxLines: null,
                textInputAction: TextInputAction.send,
                decoration: const InputDecoration(
                  hintText: 'Scrivi un messaggio...',
                  hintStyle: TextStyle(color: Colors.white30, fontSize: 15),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  isDense: true,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00D2D3), Color(0xFF00B894)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00D2D3).withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onCreateGoal;

  const _MessageBubble({required this.message, this.onCreateGoal});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 10,
          left: message.isUser ? 50 : 0,
          right: message.isUser ? 0 : 50,
        ),
        child: Column(
          crossAxisAlignment:
              message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? AppTheme.primaryColor.withValues(alpha: 0.2)
                    : AppTheme.card(context),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(message.isUser ? 20 : 4),
                  bottomRight: Radius.circular(message.isUser ? 4 : 20),
                ),
                border: Border.all(
                  color: message.isUser
                      ? AppTheme.primaryColor.withValues(alpha: 0.3)
                      : AppTheme.border(context),
                  width: 0.5,
                ),
              ),
              child: _buildRichText(message.text),
            ),
            if (message.suggestion != null && onCreateGoal != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: GestureDetector(
                  onTap: onCreateGoal,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00D2D3), Color(0xFF00B894)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00D2D3).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Crea Obiettivo',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _formatTime(message.timestamp),
                style: TextStyle(color: AppTheme.textMutedC(context), fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRichText(String text) {
    // Semplice parsing del testo con bold (**)
    final spans = <TextSpan>[];
    final parts = text.split('**');
    for (int i = 0; i < parts.length; i++) {
      spans.add(TextSpan(
        text: parts[i],
        style: TextStyle(
          color: Colors.white.withValues(alpha: i % 2 == 0 ? 0.85 : 1.0),
          fontWeight: i % 2 == 0 ? FontWeight.w400 : FontWeight.w700,
          fontSize: 14,
          height: 1.5,
        ),
      ));
    }
    return RichText(text: TextSpan(children: spans));
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _dotAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _dotAnimations = List.generate(3, (index) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(index * 0.2, 0.4 + index * 0.2, curve: Curves.easeInOut),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10, right: 50),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(20),
          ),
          border: Border.all(color: AppTheme.border(context), width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            return AppAnimatedBuilder(
              animation: _dotAnimations[index],
              builder: (context, child) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Color.lerp(
                      AppTheme.textMutedC(context),
                      const Color(0xFF00D2D3),
                      _dotAnimations[index].value,
                    ),
                    shape: BoxShape.circle,
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}


class _QuickActions extends StatelessWidget {
  final ValueChanged<String> onTap;

  const _QuickActions({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final actions = [
      ('💰 Piano risparmio', 'Voglio risparmiare'),
      ('📊 Le mie spese', 'Come vanno le mie spese?'),
      ('💡 Consigli', 'Dammi dei consigli finanziari'),
      ('🎯 Obiettivi', 'Come vanno i miei obiettivi?'),
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemCount: actions.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => onTap(actions[index].$2),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppTheme.card(context),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.border(context)),
              ),
              alignment: Alignment.center,
              child: Text(
                actions[index].$1,
                style: TextStyle(
                  color: AppTheme.textTertiary(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}





