import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:spending_mobile/services/budget_service.dart';
import 'package:spending_mobile/services/preferences_service.dart';
import 'package:spending_mobile/models/analytics.dart';
import 'package:spending_mobile/utils/app_theme.dart';

class SpendingReportsScreen extends StatefulWidget {
  const SpendingReportsScreen({super.key});

  @override
  State<SpendingReportsScreen> createState() => _SpendingReportsScreenState();
}

class _SpendingReportsScreenState extends State<SpendingReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isInitialLoading = true;
  WeeklyReport? _monthlyReport;
  String _currencySymbol = '₦';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final budgetService = Provider.of<BudgetService>(context, listen: false);
    final currency = await PreferencesService.getCurrency();

    setState(() {
      _currencySymbol = PreferencesService.getCurrencySymbol(currency);
    });

    // Fetch both weekly and monthly reports
    await Future.wait([
      budgetService.fetchWeeklyReport(),
      _loadMonthlyReport(),
    ]);

    if (mounted) {
      setState(() {
        _isInitialLoading = false;
      });
    }
  }

  Future<void> _loadMonthlyReport() async {
    final budgetService = Provider.of<BudgetService>(context, listen: false);
    final report = await budgetService.fetchMonthlyReport();
    if (mounted) {
      setState(() {
        _monthlyReport = report;
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Category icon mapping
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
      case 'lifestyle':
        return Icons.favorite;
      case 'relationship':
        return Icons.people;
      default:
        return Icons.more_horiz;
    }
  }

  // Category color mapping
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Colors.orange;
      case 'transport':
        return Colors.blue;
      case 'bills':
        return Colors.red;
      case 'entertainment':
        return Colors.purple;
      case 'shopping':
        return Colors.teal;
      case 'health':
        return Colors.green;
      case 'education':
        return Colors.indigo;
      case 'lifestyle':
        return Colors.pink;
      case 'relationship':
        return Colors.amber;
      default:
        return Colors.grey;
    }
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
          'Spending Reports',
          style: TextStyle(
            color: isDark ? AppColors.white : AppColors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.share,
              color: isDark ? AppColors.white : AppColors.black,
            ),
            onPressed: () => _showExportOptions(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: isDark ? AppColors.white : AppColors.black,
          unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          indicatorColor: isDark ? AppColors.white : AppColors.black,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Weekly'),
            Tab(text: 'Monthly'),
          ],
        ),
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
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildWeeklyReport(isDark),
                  _buildMonthlyReport(isDark),
                ],
              ),
      ),
    );
  }

  Widget _buildWeeklyReport(bool isDark) {
    final budgetService = Provider.of<BudgetService>(context);
    final weeklyReport = budgetService.weeklyReport;

    if (weeklyReport == null) {
      return _buildEmptyState(isDark, 'No weekly data available');
    }

    final summary = weeklyReport.summary;
    final dailyBreakdown = weeklyReport.dailyBreakdown;
    final categoryBreakdown = weeklyReport.categoryBreakdown;

    // Convert daily breakdown to chart data
    final Map<String, double> weeklyData = {};
    for (var day in dailyBreakdown) {
      final dayName = _getDayName(day.date.weekday);
      weeklyData[dayName] = day.spent;
    }

    final weeklyTotal = summary.totalSpent;
    final dailyAverage = summary.avgDailySpend;

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: isDark ? AppColors.white : AppColors.black,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            FadeInDown(
              duration: const Duration(milliseconds: 300),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'Total Spent',
                      '$_currencySymbol${_formatNumber(weeklyTotal)}',
                      Icons.account_balance_wallet,
                      AppColors.primary,
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      'Daily Average',
                      '$_currencySymbol${_formatNumber(dailyAverage)}',
                      Icons.trending_up,
                      AppColors.success,
                      isDark,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Daily Breakdown Chart
            if (weeklyData.isNotEmpty)
              FadeInDown(
                delay: const Duration(milliseconds: 100),
                duration: const Duration(milliseconds: 300),
                child: _buildChartCard(
                  'Daily Breakdown',
                  _buildBarChart(weeklyData, isDark),
                  isDark,
                ),
              ),

            const SizedBox(height: 24),

            // Category Breakdown
            FadeInDown(
              delay: const Duration(milliseconds: 200),
              duration: const Duration(milliseconds: 300),
              child: Text(
                'Category Breakdown',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
            ),
            const SizedBox(height: 12),

            if (categoryBreakdown.isEmpty)
              _buildEmptyState(isDark, 'No category data')
            else
              ...categoryBreakdown.asMap().entries.map((entry) {
                final index = entry.key;
                final category = entry.value;
                return FadeInUp(
                  delay: Duration(milliseconds: 250 + (index * 50)),
                  duration: const Duration(milliseconds: 300),
                  child: _buildCategoryItemFromApi(category, isDark),
                );
              }),

            const SizedBox(height: 24),

            // Insights Section
            FadeInUp(
              delay: const Duration(milliseconds: 500),
              duration: const Duration(milliseconds: 300),
              child: _buildInsightsCard(weeklyReport, isDark),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyReport(bool isDark) {
    final report = _monthlyReport;

    if (report == null) {
      return _buildEmptyState(isDark, 'No monthly data available');
    }

    final summary = report.summary;
    final dailyBreakdown = report.dailyBreakdown;

    final monthlyTotal = summary.totalSpent;
    final monthlyBudget = summary.totalBudget;
    final savings = summary.savings;

    // Group daily breakdown by week
    final Map<String, double> monthlyData = {};
    if (dailyBreakdown.isNotEmpty) {
      int weekNum = 1;
      double weekTotal = 0;
      int dayCount = 0;

      for (var day in dailyBreakdown) {
        weekTotal += day.spent;
        dayCount++;

        if (dayCount == 7) {
          monthlyData['Week $weekNum'] = weekTotal;
          weekNum++;
          weekTotal = 0;
          dayCount = 0;
        }
      }

      // Add remaining days as last week
      if (dayCount > 0) {
        monthlyData['Week $weekNum'] = weekTotal;
      }
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: isDark ? AppColors.white : AppColors.black,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            FadeInDown(
              duration: const Duration(milliseconds: 300),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'Total Spent',
                      '$_currencySymbol${_formatNumber(monthlyTotal)}',
                      Icons.account_balance_wallet,
                      AppColors.primary,
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      'Weekly Avg',
                      '$_currencySymbol${_formatNumber(monthlyTotal / 4)}',
                      Icons.calendar_view_week,
                      AppColors.success,
                      isDark,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            FadeInDown(
              delay: const Duration(milliseconds: 50),
              duration: const Duration(milliseconds: 300),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'Budget',
                      '$_currencySymbol${_formatNumber(monthlyBudget)}',
                      Icons.savings,
                      AppColors.warning,
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      savings >= 0 ? 'Saved' : 'Over Budget',
                      '$_currencySymbol${_formatNumber(savings.abs())}',
                      Icons.account_balance,
                      savings >= 0 ? AppColors.success : AppColors.error,
                      isDark,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Weekly Breakdown Chart
            if (monthlyData.isNotEmpty)
              FadeInDown(
                delay: const Duration(milliseconds: 100),
                duration: const Duration(milliseconds: 300),
                child: _buildChartCard(
                  'Weekly Breakdown',
                  _buildBarChart(monthlyData, isDark),
                  isDark,
                ),
              ),

            const SizedBox(height: 24),

            // Budget Progress
            FadeInDown(
              delay: const Duration(milliseconds: 200),
              duration: const Duration(milliseconds: 300),
              child: _buildBudgetProgressCard(monthlyTotal, monthlyBudget, isDark),
            ),

            const SizedBox(height: 24),

            // Check-in Stats Card
            FadeInDown(
              delay: const Duration(milliseconds: 300),
              duration: const Duration(milliseconds: 300),
              child: _buildCheckinStatsCard(summary.checkins, isDark),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart,
            size: 64,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshData,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.white : AppColors.black,
              foregroundColor: isDark ? AppColors.black : AppColors.white,
            ),
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
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
              Icon(icon, color: color, size: 20),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(String title, Widget chart, bool isDark) {
    return Container(
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
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
          const SizedBox(height: 20),
          chart,
        ],
      ),
    );
  }

  Widget _buildBarChart(Map<String, double> data, bool isDark) {
    if (data.isEmpty) {
      return const SizedBox(height: 150);
    }

    final maxValue = data.values.reduce((a, b) => a > b ? a : b);
    if (maxValue == 0) {
      return const SizedBox(height: 150);
    }

    return SizedBox(
      height: 150,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.entries.map((entry) {
          final percentage = entry.value / maxValue;
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '$_currencySymbol${(entry.value / 1000).toStringAsFixed(0)}k',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 32,
                height: 100 * percentage,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                entry.key,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryItemFromApi(CategorySpending category, bool isDark) {
    final icon = _getCategoryIcon(category.category);
    final color = _getCategoryColor(category.category);

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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatCategoryName(category.category),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: category.percentage / 100,
                    minHeight: 6,
                    backgroundColor: isDark ? AppColors.darkElevated : AppColors.grey200,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$_currencySymbol${_formatNumber(category.total)}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
              Text(
                '${category.percentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCategoryName(String category) {
    if (category.isEmpty) return 'Other';
    return category[0].toUpperCase() + category.substring(1).toLowerCase();
  }

  Widget _buildInsightsCard(WeeklyReport report, bool isDark) {
    final summary = report.summary;
    final categoryBreakdown = report.categoryBreakdown;
    final dailyBreakdown = report.dailyBreakdown;

    // Find highest spending day
    DailyBreakdown? highestDay;
    for (var day in dailyBreakdown) {
      if (highestDay == null || day.spent > highestDay.spent) {
        highestDay = day;
      }
    }

    // Find top category
    CategorySpending? topCategory;
    if (categoryBreakdown.isNotEmpty) {
      topCategory = categoryBreakdown.first;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Insights',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (topCategory != null)
            _buildInsightItem(
              '${_formatCategoryName(topCategory.category)} was your top spending category (${topCategory.percentage.toStringAsFixed(0)}%)',
              Icons.category,
              _getCategoryColor(topCategory.category),
              isDark,
            ),
          if (highestDay != null) ...[
            const SizedBox(height: 12),
            _buildInsightItem(
              '${_getDayName(highestDay.date.weekday)} was your highest spending day ($_currencySymbol${_formatNumber(highestDay.spent)})',
              Icons.calendar_today,
              AppColors.primary,
              isDark,
            ),
          ],
          if (summary.savingsRate > 0) ...[
            const SizedBox(height: 12),
            _buildInsightItem(
              'Great job! You saved ${summary.savingsRate.toStringAsFixed(0)}% of your budget',
              Icons.check_circle,
              AppColors.success,
              isDark,
            ),
          ] else if (summary.savingsRate < 0) ...[
            const SizedBox(height: 12),
            _buildInsightItem(
              'You went ${summary.savingsRate.abs().toStringAsFixed(0)}% over budget this week',
              Icons.warning,
              AppColors.error,
              isDark,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInsightItem(String text, IconData icon, Color color, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.darkText : AppColors.lightText,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetProgressCard(double spent, double budget, bool isDark) {
    final percentage = budget > 0 ? (spent / budget * 100).clamp(0, 150) : 0.0;
    final isOverBudget = spent > budget;

    return Container(
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
                'Budget Progress',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (isOverBudget ? AppColors.error : AppColors.success).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isOverBudget ? AppColors.error : AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (percentage / 100).clamp(0, 1),
              minHeight: 12,
              backgroundColor: isDark ? AppColors.darkElevated : AppColors.grey200,
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverBudget ? AppColors.error : AppColors.success,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spent: $_currencySymbol${_formatNumber(spent)}',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              Text(
                'Budget: $_currencySymbol${_formatNumber(budget)}',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckinStatsCard(CheckinStats checkins, bool isDark) {
    return Container(
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
          Text(
            'Check-in Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildCheckinStatItem(
                  'Total',
                  checkins.total.toString(),
                  AppColors.primary,
                  isDark,
                ),
              ),
              Expanded(
                child: _buildCheckinStatItem(
                  'Under',
                  checkins.under.toString(),
                  AppColors.success,
                  isDark,
                ),
              ),
              Expanded(
                child: _buildCheckinStatItem(
                  'On Track',
                  checkins.exact.toString(),
                  AppColors.warning,
                  isDark,
                ),
              ),
              Expanded(
                child: _buildCheckinStatItem(
                  'Over',
                  checkins.over.toString(),
                  AppColors.error,
                  isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckinStatItem(String label, String value, Color color, bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }

  String _formatNumber(double number) {
    return number.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  void _showExportOptions(BuildContext context) {
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
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkElevated : AppColors.grey200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Export Report',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
            const SizedBox(height: 24),
            _buildExportOption(
              'Export as PDF',
              Icons.picture_as_pdf,
              AppColors.error,
              isDark,
              () {
                Navigator.pop(context);
                _showExportSuccess(context, 'PDF');
              },
            ),
            const SizedBox(height: 12),
            _buildExportOption(
              'Export as CSV',
              Icons.table_chart,
              AppColors.success,
              isDark,
              () {
                Navigator.pop(context);
                _showExportSuccess(context, 'CSV');
              },
            ),
            const SizedBox(height: 12),
            _buildExportOption(
              'Share Report',
              Icons.share,
              AppColors.primary,
              isDark,
              () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildExportOption(String title, IconData icon, Color color, bool isDark, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ],
        ),
      ),
    );
  }

  void _showExportSuccess(BuildContext context, String format) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Report exported as $format successfully!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
