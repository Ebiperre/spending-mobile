import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:spending_mobile/models/transaction.dart';
import 'package:spending_mobile/services/transaction_service.dart';
import 'package:spending_mobile/utils/app_theme.dart';

class RecurringTransactionsScreen extends StatefulWidget {
  const RecurringTransactionsScreen({super.key});

  @override
  State<RecurringTransactionsScreen> createState() => _RecurringTransactionsScreenState();
}

class _RecurringTransactionsScreenState extends State<RecurringTransactionsScreen> {
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final transactionService = Provider.of<TransactionService>(context, listen: false);
    await transactionService.fetchRecurringTransactions();

    if (mounted) {
      setState(() {
        _isInitialLoading = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]}';
  }

  int _getDaysUntil(DateTime date) {
    return date.difference(DateTime.now()).inDays;
  }

  double _getTotalMonthly(List<RecurringTransaction> transactions) {
    return transactions
        .where((t) => t.isActive)
        .fold(0.0, (sum, t) {
          final amount = t.amount;
          final frequency = t.frequency;
          if (frequency == 'weekly') return sum + (amount * 4);
          if (frequency == 'biweekly') return sum + (amount * 2);
          return sum + amount;
        });
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'bills':
        return Icons.receipt_long;
      case 'entertainment':
        return Icons.movie;
      case 'shopping':
        return Icons.shopping_bag;
      case 'health':
        return Icons.medical_services;
      case 'education':
        return Icons.school;
      case 'lifestyle':
        return Icons.favorite;
      default:
        return Icons.attach_money;
    }
  }

  String _getCategoryLabel(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return 'Food';
      case 'transport':
        return 'Transport';
      case 'bills':
        return 'Bills';
      case 'entertainment':
        return 'Entertainment';
      case 'shopping':
        return 'Shopping';
      case 'health':
        return 'Health';
      case 'education':
        return 'Education';
      case 'lifestyle':
        return 'Lifestyle';
      default:
        return 'Other';
    }
  }

  String _getFrequencyLabel(String frequency) {
    switch (frequency.toLowerCase()) {
      case 'daily':
        return 'Daily';
      case 'weekly':
        return 'Weekly';
      case 'biweekly':
        return 'Bi-weekly';
      case 'monthly':
        return 'Monthly';
      default:
        return frequency;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final transactionService = Provider.of<TransactionService>(context);
    final recurringTransactions = transactionService.recurringTransactions;
    final totalMonthly = _getTotalMonthly(recurringTransactions);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppColors.white : AppColors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Recurring Transactions',
          style: TextStyle(
            color: isDark ? AppColors.white : AppColors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
              color: isDark ? AppColors.white : AppColors.black,
            ),
            onPressed: () => _showAddRecurringDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: _isInitialLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? AppColors.white : AppColors.black,
                  ),
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadData,
                color: isDark ? AppColors.white : AppColors.black,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary Card
                      FadeInDown(
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark ? AppColors.darkElevated : AppColors.grey200,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Monthly',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${recurringTransactions.where((t) => t.isActive).length} active',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '₦${_formatNumber(totalMonthly)}',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.white : AppColors.black,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _buildSummaryChip(
                                    '${recurringTransactions.where((t) => t.frequency == 'monthly').length} Monthly',
                                    AppColors.primary,
                                    isDark,
                                  ),
                                  _buildSummaryChip(
                                    '${recurringTransactions.where((t) => t.frequency == 'weekly').length} Weekly',
                                    AppColors.accent,
                                    isDark,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Upcoming Section
                      if (recurringTransactions.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Upcoming',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.white : AppColors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...recurringTransactions
                            .where((t) => t.isActive && t.nextOccurrence != null)
                            .take(3)
                            .map((t) => FadeInUp(
                                  duration: const Duration(milliseconds: 300),
                                  child: _buildUpcomingCard(t, isDark),
                                )),
                      ],

                      const SizedBox(height: 24),

                      // All Recurring Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'All Recurring',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.white : AppColors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (recurringTransactions.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.repeat,
                                  size: 64,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No recurring transactions',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? AppColors.darkText : AppColors.lightText,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Add your first recurring expense',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...recurringTransactions.asMap().entries.map((entry) => FadeInUp(
                              delay: Duration(milliseconds: 50 * entry.key),
                              duration: const Duration(milliseconds: 300),
                              child: _buildRecurringItem(entry.value, isDark),
                            )),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddRecurringDialog(context),
        backgroundColor: isDark ? AppColors.white : AppColors.black,
        foregroundColor: isDark ? AppColors.black : AppColors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Recurring'),
      ),
    );
  }

  String _formatNumber(double number) {
    return number.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  Widget _buildSummaryChip(String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildUpcomingCard(RecurringTransaction transaction, bool isDark) {
    final daysUntil = transaction.nextOccurrence != null
        ? _getDaysUntil(transaction.nextOccurrence!)
        : 0;
    final isUrgent = daysUntil <= 3;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUrgent
              ? AppColors.warning.withOpacity(0.5)
              : (isDark ? AppColors.darkElevated : AppColors.grey200),
          width: isUrgent ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isUrgent
                  ? AppColors.warning.withOpacity(0.1)
                  : (isDark ? AppColors.darkElevated : AppColors.grey100),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getCategoryIcon(transaction.category),
              color: isUrgent
                  ? AppColors.warning
                  : (isDark ? AppColors.darkText : AppColors.lightText),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description ?? _getCategoryLabel(transaction.category),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.nextOccurrence != null
                      ? 'Due ${_formatDate(transaction.nextOccurrence!)}'
                      : _getFrequencyLabel(transaction.frequency),
                  style: TextStyle(
                    fontSize: 13,
                    color: isUrgent
                        ? AppColors.warning
                        : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₦${_formatNumber(transaction.amount)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isUrgent
                      ? AppColors.warning.withOpacity(0.1)
                      : (isDark ? AppColors.darkElevated : AppColors.grey100),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  daysUntil == 0
                      ? 'Today'
                      : daysUntil == 1
                          ? 'Tomorrow'
                          : '$daysUntil days',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isUrgent
                        ? AppColors.warning
                        : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecurringItem(RecurringTransaction transaction, bool isDark) {
    final isActive = transaction.isActive;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkElevated : AppColors.grey200,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary.withOpacity(0.1)
                : (isDark ? AppColors.darkElevated : AppColors.grey100),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            _getCategoryIcon(transaction.category),
            color: isActive
                ? AppColors.primary
                : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            size: 22,
          ),
        ),
        title: Text(
          transaction.description ?? _getCategoryLabel(transaction.category),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isActive
                ? (isDark ? AppColors.darkText : AppColors.lightText)
                : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
          ),
        ),
        subtitle: Text(
          '${_getFrequencyLabel(transaction.frequency)}${transaction.nextOccurrence != null ? ' • Next: ${_formatDate(transaction.nextOccurrence!)}' : ''}',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: SizedBox(
          width: 120,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  '₦${_formatNumber(transaction.amount)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isActive
                        ? (isDark ? AppColors.darkText : AppColors.lightText)
                        : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: isActive,
                  onChanged: (value) async {
                    final transactionService = Provider.of<TransactionService>(context, listen: false);
                    await transactionService.toggleRecurring(transaction.id);
                  },
                  activeColor: isDark ? AppColors.white : AppColors.black,
                  activeTrackColor: isDark ? AppColors.white.withOpacity(0.3) : AppColors.black.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
        onLongPress: () => _showDeleteDialog(transaction),
      ),
    );
  }

  void _showDeleteDialog(RecurringTransaction transaction) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Recurring',
          style: TextStyle(
            color: isDark ? AppColors.darkText : AppColors.lightText,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${transaction.description ?? _getCategoryLabel(transaction.category)}"?',
          style: TextStyle(
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final transactionService = Provider.of<TransactionService>(context, listen: false);
              final success = await transactionService.deleteRecurring(transaction.id);

              if (mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Recurring transaction deleted'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddRecurringDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCategory = 'bills';
    String selectedFrequency = 'monthly';
    int selectedDayOfMonth = DateTime.now().day;

    final categories = [
      {'value': 'food', 'label': 'Food', 'icon': Icons.restaurant},
      {'value': 'transport', 'label': 'Transport', 'icon': Icons.directions_car},
      {'value': 'bills', 'label': 'Bills', 'icon': Icons.receipt_long},
      {'value': 'entertainment', 'label': 'Entertainment', 'icon': Icons.movie},
      {'value': 'shopping', 'label': 'Shopping', 'icon': Icons.shopping_bag},
      {'value': 'lifestyle', 'label': 'Lifestyle', 'icon': Icons.favorite},
      {'value': 'other', 'label': 'Other', 'icon': Icons.attach_money},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkElevated : AppColors.grey200,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Add Recurring Transaction',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Amount
                  TextFormField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: TextStyle(
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      prefixText: '₦ ',
                      prefixIcon: const Icon(Icons.attach_money),
                      filled: true,
                      fillColor: isDark ? AppColors.darkElevated : AppColors.grey100,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? AppColors.darkElevated : AppColors.grey200,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextFormField(
                    controller: descriptionController,
                    style: TextStyle(
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Description (optional)',
                      prefixIcon: const Icon(Icons.description),
                      filled: true,
                      fillColor: isDark ? AppColors.darkElevated : AppColors.grey100,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? AppColors.darkElevated : AppColors.grey200,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category
                  Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories.map((cat) {
                      final isSelected = selectedCategory == cat['value'];
                      return GestureDetector(
                        onTap: () => setModalState(() => selectedCategory = cat['value'] as String),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withOpacity(0.1)
                                : (isDark ? AppColors.darkElevated : AppColors.grey100),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : Colors.transparent,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                cat['icon'] as IconData,
                                size: 16,
                                color: isSelected
                                    ? AppColors.primary
                                    : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                cat['label'] as String,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  color: isSelected
                                      ? AppColors.primary
                                      : (isDark ? AppColors.darkText : AppColors.lightText),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Frequency
                  Text(
                    'Frequency',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: ['weekly', 'biweekly', 'monthly'].map((freq) {
                      final isSelected = selectedFrequency == freq;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setModalState(() => selectedFrequency = freq),
                          child: Container(
                            margin: EdgeInsets.only(right: freq != 'monthly' ? 8 : 0),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withOpacity(0.1)
                                  : (isDark ? AppColors.darkElevated : AppColors.grey100),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : Colors.transparent,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                _getFrequencyLabel(freq),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  color: isSelected
                                      ? AppColors.primary
                                      : (isDark ? AppColors.darkText : AppColors.lightText),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          Navigator.pop(context);

                          final transactionService = Provider.of<TransactionService>(context, listen: false);
                          final result = await transactionService.createRecurring(
                            amount: double.parse(amountController.text),
                            category: selectedCategory,
                            description: descriptionController.text.isNotEmpty ? descriptionController.text : null,
                            frequency: selectedFrequency,
                            dayOfMonth: selectedFrequency == 'monthly' ? selectedDayOfMonth : null,
                          );

                          if (mounted) {
                            if (result != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Recurring transaction added!'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(transactionService.error ?? 'Failed to add recurring transaction'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppColors.white : AppColors.black,
                        foregroundColor: isDark ? AppColors.black : AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Add Recurring',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
