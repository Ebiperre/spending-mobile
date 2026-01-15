import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:spending_mobile/services/language_service.dart';
import 'package:spending_mobile/services/transaction_service.dart';
import 'package:spending_mobile/models/transaction.dart';
import 'package:spending_mobile/utils/app_strings.dart';
import 'package:spending_mobile/utils/app_theme.dart';

class TransactionsListScreen extends StatefulWidget {
  const TransactionsListScreen({super.key});

  @override
  State<TransactionsListScreen> createState() => _TransactionsListScreenState();
}

class _TransactionsListScreenState extends State<TransactionsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _selectedFilter = 'all';
  String _selectedTimeRange = 'This Month';
  bool _isSearching = false;
  bool _isInitialLoading = true;

  final List<Map<String, String>> _filters = [
    {'value': 'all', 'label': 'All'},
    {'value': 'food', 'label': 'Food'},
    {'value': 'transport', 'label': 'Transport'},
    {'value': 'bills', 'label': 'Bills'},
    {'value': 'entertainment', 'label': 'Entertainment'},
    {'value': 'shopping', 'label': 'Shopping'},
    {'value': 'other', 'label': 'Other'},
  ];
  final List<String> _timeRanges = ['Today', 'This Week', 'This Month', 'Last 3 Months', 'This Year'];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadTransactions({bool refresh = false}) async {
    final transactionService = Provider.of<TransactionService>(context, listen: false);

    await transactionService.fetchTransactions(
      category: _selectedFilter == 'all' ? null : _selectedFilter,
      refresh: refresh,
    );

    if (mounted) {
      setState(() {
        _isInitialLoading = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final transactionService = Provider.of<TransactionService>(context, listen: false);
      final hasMore = transactionService.pagination?.hasNextPage ?? false;
      if (!transactionService.isLoading && hasMore) {
        final nextPage = (transactionService.pagination?.page ?? 0) + 1;
        transactionService.fetchTransactions(
          page: nextPage,
          category: _selectedFilter == 'all' ? null : _selectedFilter,
        );
      }
    }
  }

  List<Transaction> get _filteredTransactions {
    final transactionService = Provider.of<TransactionService>(context);
    var transactions = transactionService.transactions;

    // Apply search filter locally
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      transactions = transactions.where((t) =>
        (t.description?.toLowerCase().contains(query) ?? false) ||
        t.category.toLowerCase().contains(query)
      ).toList();
    }

    return transactions;
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
    _scrollController.dispose();
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
      body: SafeArea(
        top: false,
        child: Column(
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
                      label: Text(filter['label']!),
                      selected: _selectedFilter == filter['value'],
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = selected ? filter['value']! : 'all';
                        });
                        _loadTransactions(refresh: true);
                      },
                      selectedColor: isDark ? AppColors.white : AppColors.black,
                      checkmarkColor: isDark ? AppColors.black : AppColors.white,
                      labelStyle: TextStyle(
                        color: _selectedFilter == filter['value']
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
                    '₦${_formatNumber(_filteredTransactions.fold(0.0, (sum, t) => sum + t.amount.abs()))}',
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
            child: _isInitialLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDark ? AppColors.white : AppColors.black,
                      ),
                    ),
                  )
                : _filteredTransactions.isEmpty
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
                    : RefreshIndicator(
                        onRefresh: () => _loadTransactions(refresh: true),
                        color: isDark ? AppColors.white : AppColors.black,
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredTransactions.length + 1,
                          itemBuilder: (context, index) {
                            if (index == _filteredTransactions.length) {
                              final transactionService = Provider.of<TransactionService>(context);
                              if (transactionService.isLoading) {
                                return Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        isDark ? AppColors.white : AppColors.black,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            }
                            final transaction = _filteredTransactions[index];
                            return FadeInUp(
                              delay: Duration(milliseconds: 50 * (index % 10)),
                              duration: const Duration(milliseconds: 300),
                              child: _buildTransactionItemFromApi(transaction, isDark),
                            );
                          },
                        ),
                      ),
            ),
          ],
        ),
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

  Widget _buildTransactionItemFromApi(Transaction transaction, bool isDark) {
    final isIncome = transaction.isIncome;
    final icon = _getCategoryIcon(transaction.category);

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
              icon,
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
                  transaction.description ?? _getCategoryLabel(transaction.category),
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
                      _getCategoryLabel(transaction.category),
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
                      _formatDate(transaction.transactionDate),
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
            '${isIncome ? '+' : '-'}₦${_formatNumber(transaction.amount)}',
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

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'bills':
        return Icons.receipt;
      case 'entertainment':
        return Icons.celebration;
      case 'shopping':
        return Icons.shopping_bag;
      case 'health':
        return Icons.medical_services;
      case 'education':
        return Icons.school;
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
      default:
        return 'Other';
    }
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
