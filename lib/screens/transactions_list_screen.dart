import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:spending_mobile/services/language_service.dart';
import 'package:spending_mobile/utils/app_strings.dart';
import 'package:spending_mobile/utils/app_theme.dart';

class TransactionsListScreen extends StatefulWidget {
  const TransactionsListScreen({super.key});

  @override
  State<TransactionsListScreen> createState() => _TransactionsListScreenState();
}

class _TransactionsListScreenState extends State<TransactionsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  String _selectedTimeRange = 'This Month';
  bool _isSearching = false;

  final List<String> _filters = ['All', 'Food', 'Transport', 'Bills', 'Lifestyle', 'Relationship', 'Other'];
  final List<String> _timeRanges = ['Today', 'This Week', 'This Month', 'Last 3 Months', 'This Year'];

  // Mock transactions data
  final List<Map<String, dynamic>> _allTransactions = [
    {'title': 'Okada to work', 'amount': -500.0, 'category': 'Transport', 'icon': Icons.local_taxi, 'date': DateTime.now()},
    {'title': 'Lunch (Rice & Stew)', 'amount': -800.0, 'category': 'Food', 'icon': Icons.restaurant, 'date': DateTime.now()},
    {'title': 'MTN Data', 'amount': -1000.0, 'category': 'Bills', 'icon': Icons.wifi, 'date': DateTime.now().subtract(const Duration(days: 1))},
    {'title': 'Babe Birthday Gift', 'amount': -5000.0, 'category': 'Relationship', 'icon': Icons.card_giftcard, 'date': DateTime.now().subtract(const Duration(days: 1))},
    {'title': 'Netflix Subscription', 'amount': -4500.0, 'category': 'Lifestyle', 'icon': Icons.tv, 'date': DateTime.now().subtract(const Duration(days: 2))},
    {'title': 'Suya & Drinks', 'amount': -2500.0, 'category': 'Food', 'icon': Icons.fastfood, 'date': DateTime.now().subtract(const Duration(days: 3))},
    {'title': 'Uber to Island', 'amount': -3500.0, 'category': 'Transport', 'icon': Icons.directions_car, 'date': DateTime.now().subtract(const Duration(days: 4))},
    {'title': 'Electricity Bill', 'amount': -8000.0, 'category': 'Bills', 'icon': Icons.bolt, 'date': DateTime.now().subtract(const Duration(days: 5))},
    {'title': 'Gym Membership', 'amount': -15000.0, 'category': 'Lifestyle', 'icon': Icons.fitness_center, 'date': DateTime.now().subtract(const Duration(days: 7))},
    {'title': 'Groceries', 'amount': -12000.0, 'category': 'Food', 'icon': Icons.shopping_cart, 'date': DateTime.now().subtract(const Duration(days: 10))},
  ];

  List<Map<String, dynamic>> get _filteredTransactions {
    var filtered = _allTransactions;

    // Apply category filter
    if (_selectedFilter != 'All') {
      filtered = filtered.where((t) => t['category'] == _selectedFilter).toList();
    }

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((t) =>
        t['title'].toString().toLowerCase().contains(query) ||
        t['category'].toString().toLowerCase().contains(query)
      ).toList();
    }

    return filtered;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '$diff days ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final langService = Provider.of<LanguageService>(context);
    final strings = AppStrings(langService.currentLanguage);

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
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: TextStyle(
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
                decoration: InputDecoration(
                  hintText: 'Search transactions...',
                  hintStyle: TextStyle(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                  border: InputBorder.none,
                ),
                onChanged: (_) => setState(() {}),
              )
            : Text(
                strings.recentActivity,
                style: TextStyle(
                  color: isDark ? AppColors.white : AppColors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: isDark ? AppColors.white : AppColors.black,
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) _searchController.clear();
              });
            },
          ),
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: isDark ? AppColors.white : AppColors.black,
            ),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          FadeInDown(
            duration: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: _filters.map((filter) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: _selectedFilter == filter,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = selected ? filter : 'All';
                        });
                      },
                      selectedColor: isDark ? AppColors.white : AppColors.black,
                      checkmarkColor: isDark ? AppColors.black : AppColors.white,
                      labelStyle: TextStyle(
                        color: _selectedFilter == filter
                            ? (isDark ? AppColors.black : AppColors.white)
                            : (isDark ? AppColors.darkText : AppColors.lightText),
                        fontWeight: FontWeight.w500,
                      ),
                      backgroundColor: isDark ? AppColors.darkElevated : AppColors.grey100,
                    ),
                  )).toList(),
                ),
              ),
            ),
          ),

          // Summary card
          FadeInDown(
            delay: const Duration(milliseconds: 100),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem(
                    'Total Spent',
                    '₦${_formatNumber(_filteredTransactions.fold(0.0, (sum, t) => sum + (t['amount'] as double).abs()))}',
                    AppColors.error,
                    isDark,
                  ),
                  Container(
                    height: 40,
                    width: 1,
                    color: isDark ? AppColors.darkElevated : AppColors.grey200,
                  ),
                  _buildSummaryItem(
                    'Transactions',
                    '${_filteredTransactions.length}',
                    AppColors.primary,
                    isDark,
                  ),
                ],
              ),
            ),
          ),

          // Transactions list
          Expanded(
            child: _filteredTransactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No transactions found',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = _filteredTransactions[index];
                      return FadeInUp(
                        delay: Duration(milliseconds: 50 * index),
                        duration: const Duration(milliseconds: 300),
                        child: _buildTransactionItem(transaction, isDark),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color, bool isDark) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction, bool isDark) {
    final isIncome = (transaction['amount'] as double) > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkElevated : AppColors.grey200,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isIncome
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              transaction['icon'] as IconData,
              color: isIncome ? AppColors.success : AppColors.error,
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
                Row(
                  children: [
                    Text(
                      transaction['category'] as String,
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
                      _formatDate(transaction['date'] as DateTime),
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'}₦${_formatNumber((transaction['amount'] as double).abs())}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isIncome ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(double number) {
    return number.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  void _showFilterSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
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
              'Time Range',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _timeRanges.map((range) => ChoiceChip(
                label: Text(range),
                selected: _selectedTimeRange == range,
                onSelected: (selected) {
                  setState(() {
                    _selectedTimeRange = range;
                  });
                  Navigator.pop(context);
                },
                selectedColor: isDark ? AppColors.white : AppColors.black,
                labelStyle: TextStyle(
                  color: _selectedTimeRange == range
                      ? (isDark ? AppColors.black : AppColors.white)
                      : (isDark ? AppColors.darkText : AppColors.lightText),
                ),
                backgroundColor: isDark ? AppColors.darkElevated : AppColors.grey100,
              )).toList(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
