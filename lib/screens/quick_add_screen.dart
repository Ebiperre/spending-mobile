import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:spending_mobile/services/preferences_service.dart';
import 'package:spending_mobile/services/transaction_service.dart';
import 'package:spending_mobile/services/budget_service.dart';
import 'package:spending_mobile/utils/app_theme.dart';

class QuickAddScreen extends StatefulWidget {
  const QuickAddScreen({super.key});

  @override
  State<QuickAddScreen> createState() => _QuickAddScreenState();
}

class _QuickAddScreenState extends State<QuickAddScreen> {
  String _selectedType = 'Expense';
  String _selectedCategory = 'food';
  String _selectedAmount = '';
  String _currency = 'NGN';
  String _currencySymbol = '₦';
  bool _isLoading = false;

  // Categories with API values
  final List<Map<String, String>> _categories = [
    {'value': 'food', 'label': 'Food'},
    {'value': 'transport', 'label': 'Transport'},
    {'value': 'entertainment', 'label': 'Entertainment'},
    {'value': 'shopping', 'label': 'Shopping'},
    {'value': 'bills', 'label': 'Bills'},
    {'value': 'health', 'label': 'Health'},
    {'value': 'education', 'label': 'Education'},
    {'value': 'other', 'label': 'Other'},
  ];

  // Estimated amounts based on category (in NGN)
  final Map<String, List<String>> _estimatedAmounts = {
    'food': ['500', '1,000', '1,500', '2,500', '5,000'],
    'transport': ['200', '500', '1,000', '2,000', '5,000'],
    'entertainment': ['1,000', '2,500', '5,000', '10,000', '20,000'],
    'shopping': ['2,000', '5,000', '10,000', '20,000', '50,000'],
    'bills': ['5,000', '10,000', '15,000', '25,000', '50,000'],
    'health': ['1,000', '3,000', '5,000', '10,000', '20,000'],
    'education': ['2,000', '5,000', '10,000', '25,000', '50,000'],
    'other': ['500', '1,000', '2,500', '5,000', '10,000'],
  };

  @override
  void initState() {
    super.initState();
    _loadCurrency();
  }

  Future<void> _loadCurrency() async {
    final currency = await PreferencesService.getCurrency();
    setState(() {
      _currency = currency;
      _currencySymbol = PreferencesService.getCurrencySymbol(currency);
    });
  }

  Future<void> _handleSubmit() async {
    if (_selectedAmount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an estimated amount'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Remove commas from amount for parsing
    final amount = double.tryParse(_selectedAmount.replaceAll(',', '')) ?? 0.0;
    final type = _selectedType == 'Income' ? 'income' : 'expense';

    final transactionService = Provider.of<TransactionService>(context, listen: false);
    final budgetService = Provider.of<BudgetService>(context, listen: false);

    final success = await transactionService.createTransaction(
      amount: amount,
      category: _selectedCategory,
      date: DateTime.now(),
      type: type,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success != null) {
      // Refresh budget data
      budgetService.fetchDailyBudget();
      budgetService.fetchMonthlyBudget();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction added successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(transactionService.error ?? 'Failed to add transaction'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  String _getCategoryLabel(String value) {
    final category = _categories.firstWhere(
      (c) => c['value'] == value,
      orElse: () => {'value': value, 'label': value},
    );
    return category['label'] ?? value;
  }

  @override
  Widget build(BuildContext context) {
    final amounts = _estimatedAmounts[_selectedCategory] ?? _estimatedAmounts['other']!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Add'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.black,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Type Selection
            FadeInDown(
              duration: const Duration(milliseconds: 400),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTypeButton(
                      label: 'Expense',
                      icon: Icons.arrow_upward,
                      color: AppColors.error,
                      isSelected: _selectedType == 'Expense',
                      onTap: () {
                        setState(() {
                          _selectedType = 'Expense';
                          _selectedAmount = '';
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTypeButton(
                      label: 'Income',
                      icon: Icons.arrow_downward,
                      color: AppColors.success,
                      isSelected: _selectedType == 'Income',
                      onTap: () {
                        setState(() {
                          _selectedType = 'Income';
                          _selectedAmount = '';
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Category Selection
            FadeInUp(
              delay: const Duration(milliseconds: 133),
              duration: const Duration(milliseconds: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories.map((category) {
                      final isSelected = _selectedCategory == category['value'];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = category['value']!;
                            _selectedAmount = '';
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.black
                                : AppColors.grey100,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.black
                                  : AppColors.grey200,
                            ),
                          ),
                          child: Text(
                            category['label']!,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.lightText,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Estimated Amount Selection
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              duration: const Duration(milliseconds: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Estimated Amount',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to select an estimated amount',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: amounts.map((amount) {
                      final isSelected = _selectedAmount == amount;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedAmount = amount;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (_selectedType == 'Expense'
                                    ? AppColors.error
                                    : AppColors.success)
                                : AppColors.grey100,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? (_selectedType == 'Expense'
                                      ? AppColors.error
                                      : AppColors.success)
                                  : AppColors.grey200,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Text(
                            '$_currencySymbol$amount',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white : AppColors.lightText,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            if (_selectedAmount.isNotEmpty) ...[
              const SizedBox(height: 32),
              FadeInUp(
                delay: const Duration(milliseconds: 267),
                duration: const Duration(milliseconds: 400),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: (_selectedType == 'Expense'
                            ? AppColors.error
                            : AppColors.success)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: (_selectedType == 'Expense'
                              ? AppColors.error
                              : AppColors.success)
                          .withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Selected Amount',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.grey600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$_currencySymbol$_selectedAmount',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                          color: _selectedType == 'Expense'
                              ? AppColors.error
                              : AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Submit Button
            FadeInUp(
              delay: const Duration(milliseconds: 333),
              duration: const Duration(milliseconds: 400),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedType == 'Expense'
                      ? AppColors.error
                      : AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Add ${_selectedType}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Quick Tip
            FadeIn(
              delay: const Duration(milliseconds: 400),
              duration: const Duration(milliseconds: 400),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb, color: AppColors.primary),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Select an estimated amount based on your category. You can always edit it later!',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : AppColors.grey100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : AppColors.grey200,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : AppColors.grey600,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isSelected ? color : AppColors.grey600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

