import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:spending_mobile/services/language_service.dart';
import 'package:spending_mobile/utils/app_strings.dart';
import 'package:spending_mobile/utils/app_theme.dart';

class RecurringTransactionsScreen extends StatefulWidget {
  const RecurringTransactionsScreen({super.key});

  @override
  State<RecurringTransactionsScreen> createState() => _RecurringTransactionsScreenState();
}

class _RecurringTransactionsScreenState extends State<RecurringTransactionsScreen> {
  // Mock recurring transactions
  final List<Map<String, dynamic>> _recurringTransactions = [
    {
      'title': 'Netflix Subscription',
      'amount': 4500.0,
      'category': 'Lifestyle',
      'icon': Icons.tv,
      'frequency': 'Monthly',
      'nextDate': DateTime.now().add(const Duration(days: 15)),
      'isActive': true,
    },
    {
      'title': 'Spotify Premium',
      'amount': 1500.0,
      'category': 'Lifestyle',
      'icon': Icons.music_note,
      'frequency': 'Monthly',
      'nextDate': DateTime.now().add(const Duration(days: 8)),
      'isActive': true,
    },
    {
      'title': 'Gym Membership',
      'amount': 15000.0,
      'category': 'Lifestyle',
      'icon': Icons.fitness_center,
      'frequency': 'Monthly',
      'nextDate': DateTime.now().add(const Duration(days: 22)),
      'isActive': true,
    },
    {
      'title': 'Electricity Bill',
      'amount': 8000.0,
      'category': 'Bills',
      'icon': Icons.bolt,
      'frequency': 'Monthly',
      'nextDate': DateTime.now().add(const Duration(days: 5)),
      'isActive': true,
    },
    {
      'title': 'Internet (Starlink)',
      'amount': 38000.0,
      'category': 'Bills',
      'icon': Icons.wifi,
      'frequency': 'Monthly',
      'nextDate': DateTime.now().add(const Duration(days: 12)),
      'isActive': false,
    },
    {
      'title': 'Weekly Groceries',
      'amount': 15000.0,
      'category': 'Food',
      'icon': Icons.shopping_cart,
      'frequency': 'Weekly',
      'nextDate': DateTime.now().add(const Duration(days: 3)),
      'isActive': true,
    },
  ];

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]}';
  }

  int _getDaysUntil(DateTime date) {
    return date.difference(DateTime.now()).inDays;
  }

  double get _totalMonthly {
    return _recurringTransactions
        .where((t) => t['isActive'] == true)
        .fold(0.0, (sum, t) {
          final amount = t['amount'] as double;
          final frequency = t['frequency'] as String;
          if (frequency == 'Weekly') return sum + (amount * 4);
          return sum + amount;
        });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
      body: SingleChildScrollView(
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
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Monthly Recurring',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₦${_formatNumber(_totalMonthly)}',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.darkText : AppColors.lightText,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.repeat,
                            color: AppColors.primary,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildSummaryChip(
                          '${_recurringTransactions.where((t) => t['isActive'] == true).length} Active',
                          AppColors.success,
                          isDark,
                        ),
                        const SizedBox(width: 8),
                        _buildSummaryChip(
                          '${_recurringTransactions.where((t) => t['isActive'] == false).length} Paused',
                          AppColors.warning,
                          isDark,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Upcoming Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FadeInDown(
                delay: const Duration(milliseconds: 100),
                duration: const Duration(milliseconds: 300),
                child: Text(
                  'Upcoming',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Upcoming transactions (within 7 days)
            ..._recurringTransactions
                .where((t) => t['isActive'] == true && _getDaysUntil(t['nextDate']) <= 7)
                .toList()
                .asMap()
                .entries
                .map((entry) => FadeInUp(
                      delay: Duration(milliseconds: 150 + (entry.key * 50)),
                      duration: const Duration(milliseconds: 300),
                      child: _buildUpcomingCard(entry.value, isDark),
                    )),

            const SizedBox(height: 24),

            // All Recurring Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FadeInDown(
                delay: const Duration(milliseconds: 300),
                duration: const Duration(milliseconds: 300),
                child: Text(
                  'All Recurring',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // All transactions list
            ..._recurringTransactions.asMap().entries.map((entry) => FadeInUp(
                  delay: Duration(milliseconds: 350 + (entry.key * 50)),
                  duration: const Duration(milliseconds: 300),
                  child: _buildRecurringItem(entry.value, isDark),
                )),

            const SizedBox(height: 100),
          ],
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
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildUpcomingCard(Map<String, dynamic> transaction, bool isDark) {
    final daysUntil = _getDaysUntil(transaction['nextDate'] as DateTime);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: daysUntil <= 3
            ? AppColors.warning.withOpacity(0.1)
            : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: daysUntil <= 3
              ? AppColors.warning.withOpacity(0.3)
              : (isDark ? AppColors.darkElevated : AppColors.grey200),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: daysUntil <= 3
                  ? AppColors.warning.withOpacity(0.2)
                  : AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              transaction['icon'] as IconData,
              color: daysUntil <= 3 ? AppColors.warning : AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction['title'] as String,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  daysUntil == 0
                      ? 'Due today!'
                      : daysUntil == 1
                          ? 'Due tomorrow'
                          : 'Due in $daysUntil days',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: daysUntil <= 3 ? FontWeight.w600 : FontWeight.w400,
                    color: daysUntil <= 3 ? AppColors.warning : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₦${_formatNumber(transaction['amount'] as double)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecurringItem(Map<String, dynamic> transaction, bool isDark) {
    final isActive = transaction['isActive'] as bool;

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
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary.withOpacity(0.1)
                : (isDark ? AppColors.darkElevated : AppColors.grey100),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            transaction['icon'] as IconData,
            color: isActive
                ? AppColors.primary
                : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            size: 22,
          ),
        ),
        title: Text(
          transaction['title'] as String,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isActive
                ? (isDark ? AppColors.darkText : AppColors.lightText)
                : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
          ),
        ),
        subtitle: Row(
          children: [
            Text(
              transaction['frequency'] as String,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            Text(
              ' • ',
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            Text(
              'Next: ${_formatDate(transaction['nextDate'] as DateTime)}',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
        trailing: SizedBox(
          width: 120,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  '₦${_formatNumber(transaction['amount'] as double)}',
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
                  onChanged: (value) {
                    setState(() {
                      transaction['isActive'] = value;
                    });
                  },
                  activeColor: isDark ? AppColors.white : AppColors.black,
                  activeTrackColor: isDark ? AppColors.white.withOpacity(0.3) : AppColors.black.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatNumber(double number) {
    return number.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  void _showAddRecurringDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String selectedFrequency = 'Monthly';
    String selectedCategory = 'Bills';

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
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixText: '₦ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Frequency',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['Daily', 'Weekly', 'Monthly', 'Yearly'].map((freq) => ChoiceChip(
                  label: Text(freq),
                  selected: selectedFrequency == freq,
                  onSelected: (selected) {
                    setModalState(() {
                      selectedFrequency = freq;
                    });
                  },
                  selectedColor: isDark ? AppColors.white : AppColors.black,
                  labelStyle: TextStyle(
                    color: selectedFrequency == freq
                        ? (isDark ? AppColors.black : AppColors.white)
                        : (isDark ? AppColors.darkText : AppColors.lightText),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty && amountController.text.isNotEmpty) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Recurring transaction added!'),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppColors.white : AppColors.black,
                    foregroundColor: isDark ? AppColors.black : AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Add Recurring',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
