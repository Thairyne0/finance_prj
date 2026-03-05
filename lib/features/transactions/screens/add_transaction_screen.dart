import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../config/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/local/hive_service.dart';
import '../../../data/models/category_model.dart';
import '../../../widget/tm_widgets.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final TransactionModel? existingTransaction;

  const AddTransactionScreen({super.key, this.existingTransaction});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _productController = TextEditingController();
  final _accountNameController = TextEditingController();

  TransactionType _type = TransactionType.expense;
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  PaymentMethod _paymentMethod = PaymentMethod.cash;

  List<CategoryModel> get _categories => _type == TransactionType.expense
      ? HiveService.expenseCategories
      : HiveService.incomeCategories;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingTransaction;
    if (existing != null) {
      _amountController.text = existing.amount.toString();
      _descriptionController.text = existing.description;
      _productController.text = existing.productName ?? '';
      _accountNameController.text = existing.accountName ?? '';
      _type = existing.type;
      _selectedDate = existing.date;
      _paymentMethod = existing.paymentMethod;
      _selectedCategoryId = existing.categoryId;
    } else {
      _selectedCategoryId = _categories.first.id;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _productController.dispose();
    _accountNameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: AppTheme.card(context),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  bool get _isEditing => widget.existingTransaction != null;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final transaction = TransactionModel(
      id: _isEditing ? widget.existingTransaction!.id : const Uuid().v4(),
      amount: double.parse(_amountController.text.replaceAll(',', '.')),
      type: _type,
      categoryId: _selectedCategoryId!,
      description: _descriptionController.text.trim(),
      productName: _productController.text.trim().isNotEmpty
          ? _productController.text.trim()
          : null,
      date: _selectedDate,
      createdAt: _isEditing ? widget.existingTransaction!.createdAt : DateTime.now(),
      paymentMethod: _paymentMethod,
      accountName: _accountNameController.text.trim().isNotEmpty
          ? _accountNameController.text.trim()
          : null,
    );

    if (_isEditing) {
      ref.read(allTransactionsProvider.notifier).update(transaction);
    } else {
      ref.read(allTransactionsProvider.notifier).add(transaction);
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffold(context),
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifica Movimento' : 'Nuovo Movimento'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type Toggle
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<TransactionType>(
                    segments: const [
                      ButtonSegment(
                        value: TransactionType.expense,
                        label: Text('Spesa'),
                        icon: Icon(Icons.arrow_upward_rounded),
                      ),
                      ButtonSegment(
                        value: TransactionType.income,
                        label: Text('Entrata'),
                        icon: Icon(Icons.arrow_downward_rounded),
                      ),
                    ],
                    selected: {_type},
                    onSelectionChanged: (selected) {
                      setState(() {
                        _type = selected.first;
                        _selectedCategoryId = _categories.first.id;
                      });
                    },
                    style: SegmentedButton.styleFrom(
                      backgroundColor: AppTheme.card(context),
                      foregroundColor: AppTheme.textSecondary(context),
                      selectedForegroundColor: Colors.white,
                      selectedBackgroundColor: _type == TransactionType.expense
                          ? AppTheme.expenseColor.withValues(alpha: 0.3)
                          : AppTheme.incomeColor.withValues(alpha: 0.3),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Amount Field
                TmAmountField(
                  controller: _amountController,
                  label: 'Importo',
                  amountColor: _type == TransactionType.expense
                      ? AppTheme.expenseColor
                      : AppTheme.incomeColor,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Inserisci un importo';
                    }
                    final parsed =
                        double.tryParse(value.replaceAll(',', '.'));
                    if (parsed == null || parsed <= 0) {
                      return 'Importo non valido';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Category Selector
                Text(
                  'Categoria',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categories.map((category) {
                    final isSelected = category.id == _selectedCategoryId;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedCategoryId = category.id);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Color(category.colorValue)
                                  .withValues(alpha: 0.2)
                              : AppTheme.card(context),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? Color(category.colorValue)
                                : AppTheme.border(context),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              IconData(category.iconCodePoint,
                                  fontFamily: 'MaterialIcons'),
                              size: 18,
                              color: isSelected
                                  ? Color(category.colorValue)
                                  : AppTheme.textTertiary(context),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              category.name,
                              style: TextStyle(
                                color: isSelected
                                    ? Color(category.colorValue)
                                    : AppTheme.textTertiary(context),
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // Description
                Text(
                  'Descrizione',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Es. Spesa al supermercato',
                  ),
                ),

                const SizedBox(height: 24),

                // Product Name (optional)
                if (_type == TransactionType.expense) ...[
                  Row(
                    children: [
                      Text(
                        'Prodotto',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Opzionale',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.primaryColor,
                                    fontSize: 10,
                                  ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _productController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      hintText: 'Es. iPhone 15 Pro',
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Date Picker
                Text(
                  'Metodo di Pagamento',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _paymentMethod = PaymentMethod.cash),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: _paymentMethod == PaymentMethod.cash
                                ? AppTheme.warningColor.withValues(alpha: 0.15)
                                : AppTheme.card(context),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _paymentMethod == PaymentMethod.cash
                                  ? AppTheme.warningColor
                                  : AppTheme.border(context),
                              width: _paymentMethod == PaymentMethod.cash ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.payments_rounded,
                                color: _paymentMethod == PaymentMethod.cash
                                    ? AppTheme.warningColor
                                    : AppTheme.textMutedC(context),
                                size: 24,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Contanti',
                                style: TextStyle(
                                  color: _paymentMethod == PaymentMethod.cash
                                      ? AppTheme.warningColor
                                      : AppTheme.textMutedC(context),
                                  fontWeight: _paymentMethod == PaymentMethod.cash
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _paymentMethod = PaymentMethod.bankAccount),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: _paymentMethod == PaymentMethod.bankAccount
                                ? AppTheme.primaryColor.withValues(alpha: 0.15)
                                : AppTheme.card(context),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _paymentMethod == PaymentMethod.bankAccount
                                  ? AppTheme.primaryColor
                                  : AppTheme.border(context),
                              width: _paymentMethod == PaymentMethod.bankAccount ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.account_balance_rounded,
                                color: _paymentMethod == PaymentMethod.bankAccount
                                    ? AppTheme.primaryColor
                                    : AppTheme.textMutedC(context),
                                size: 24,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Conto',
                                style: TextStyle(
                                  color: _paymentMethod == PaymentMethod.bankAccount
                                      ? AppTheme.primaryColor
                                      : AppTheme.textMutedC(context),
                                  fontWeight: _paymentMethod == PaymentMethod.bankAccount
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Nome conto opzionale
                if (_paymentMethod == PaymentMethod.bankAccount) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        'Nome Conto',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Opzionale',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.primaryColor,
                                fontSize: 10,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _accountNameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      hintText: 'Es. Intesa Sanpaolo, PayPal, N26...',
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Data
                Text(
                  'Data',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _selectDate,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.card(context),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.border(context)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            color: AppTheme.primaryColor, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          style:
                              Theme.of(context).textTheme.titleMedium,
                        ),
                        const Spacer(),
                        Icon(Icons.chevron_right_rounded,
                            color: AppTheme.textMutedC(context)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _type == TransactionType.expense
                          ? AppTheme.expenseColor
                          : AppTheme.incomeColor,
                    ),
                    child: Text(
                      _isEditing
                          ? 'Salva Modifiche'
                          : _type == TransactionType.expense
                              ? 'Aggiungi Spesa'
                              : 'Aggiungi Entrata',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
          ),
        ),
      ),
    );
  }
}

