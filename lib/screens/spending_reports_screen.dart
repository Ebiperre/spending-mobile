import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:spending_mobile/services/language_service.dart';
import 'package:spending_mobile/utils/app_strings.dart';
import 'package:spending_mobile/utils/app_theme.dart';

class SpendingReportsScreen extends StatefulWidget {
  const SpendingReportsScreen({super.key});

  @override
  State<SpendingReportsScreen> createState() => _SpendingReportsScreenState();
}

class _SpendingReportsScreenState extends State<SpendingReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock data for reports
  final Map<String, double> _weeklyData = {
    'Mon': 2500,
    'Tue': 4200,
    'Wed': 1800,
    'Thu': 3500,
    'Fri': 6200,
    'Sat': 8500,
    'Sun': 2100,
  };

  final Map<String, double> _monthlyData = {
    'Week 1': 28000,
    'Week 2': 35000,
    'Week 3': 22000,
    'Week 4': 31000,
  };

  final Map<String, Map<String, dynamic>> _categoryBreakdown = {
    'Food': {'amount': 32000.0, 'percentage': 28, 'icon': Icons.restaurant, 'color': Colors.orange},
    'Transport': {'amount': 18000.0, 'percentage': 16, 'icon': Icons.directions_car, 'color': Colors.blue},
    'Bills': {'amount': 25000.0, 'percentage': 22, 'icon': Icons.receipt, 'color': Colors.red},
    'Lifestyle': {'amount': 22000.0, 'percentage': 19, 'icon': Icons.shopping_bag, 'color': Colors.purple},
    'Relationship': {'amount': 12000.0, 'percentage': 10, 'icon': Icons.favorite, 'color': Colors.pink},
    'Other': {'amount': 6000.0, 'percentage': 5, 'icon': Icons.more_horiz, 'color': Colors.grey},
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  double get _weeklyTotal => _weeklyData.values.fold(0, (sum, val) => sum + val);
  double get _monthlyTotal => _monthlyData.values.fold(0, (sum, val) => sum + val);
  double get _dailyAverage => _weeklyTotal / 7;

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
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWeeklyReport(isDark),
          _buildMonthlyReport(isDark),
        ],
      ),
    );
  }

  Widget _buildWeeklyReport(bool isDark) {
    return SingleChildScrollView(
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
                    '₦${_formatNumber(_weeklyTotal)}',
                    Icons.account_balance_wallet,
                    AppColors.primary,
                    isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Daily Average',
                    '₦${_formatNumber(_dailyAverage)}',
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
          FadeInDown(
            delay: const Duration(milliseconds: 100),
            duration: const Duration(milliseconds: 300),
            child: _buildChartCard(
              'Daily Breakdown',
              _buildBarChart(_weeklyData, isDark),
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

          ..._categoryBreakdown.entries.toList().asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;
            return FadeInUp(
              delay: Duration(milliseconds: 250 + (index * 50)),
              duration: const Duration(milliseconds: 300),
              child: _buildCategoryItem(
                category.key,
                category.value,
                isDark,
              ),
            );
          }),

          const SizedBox(height: 24),

          // Insights Section
          FadeInUp(
            delay: const Duration(milliseconds: 500),
            duration: const Duration(milliseconds: 300),
            child: _buildInsightsCard(isDark),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildMonthlyReport(bool isDark) {
    return SingleChildScrollView(
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
                    '₦${_formatNumber(_monthlyTotal)}',
                    Icons.account_balance_wallet,
                    AppColors.primary,
                    isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Weekly Avg',
                    '₦${_formatNumber(_monthlyTotal / 4)}',
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
                    '₦${_formatNumber(150000)}',
                    Icons.savings,
                    AppColors.warning,
                    isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Remaining',
                    '₦${_formatNumber(150000 - _monthlyTotal)}',
                    Icons.account_balance,
                    _monthlyTotal > 150000 ? AppColors.error : AppColors.success,
                    isDark,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Weekly Breakdown Chart
          FadeInDown(
            delay: const Duration(milliseconds: 100),
            duration: const Duration(milliseconds: 300),
            child: _buildChartCard(
              'Weekly Breakdown',
              _buildBarChart(_monthlyData, isDark),
              isDark,
            ),
          ),

          const SizedBox(height: 24),

          // Budget Progress
          FadeInDown(
            delay: const Duration(milliseconds: 200),
            duration: const Duration(milliseconds: 300),
            child: _buildBudgetProgressCard(isDark),
          ),

          const SizedBox(height: 24),

          // Comparison Card
          FadeInDown(
            delay: const Duration(milliseconds: 300),
            duration: const Duration(milliseconds: 300),
            child: _buildComparisonCard(isDark),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
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
    final maxValue = data.values.reduce((a, b) => a > b ? a : b);

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
                '₦${(entry.value / 1000).toStringAsFixed(0)}k',
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

  Widget _buildCategoryItem(String name, Map<String, dynamic> data, bool isDark) {
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
              color: (data['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              data['icon'] as IconData,
              color: data['color'] as Color,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
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
                    value: (data['percentage'] as int) / 100,
                    minHeight: 6,
                    backgroundColor: isDark ? AppColors.darkElevated : AppColors.grey200,
                    valueColor: AlwaysStoppedAnimation<Color>(data['color'] as Color),
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
                '₦${_formatNumber(data['amount'] as double)}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
              Text(
                '${data['percentage']}%',
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

  Widget _buildInsightsCard(bool isDark) {
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
          _buildInsightItem(
            'You spent 23% more on Food this week compared to last week.',
            Icons.trending_up,
            AppColors.warning,
            isDark,
          ),
          const SizedBox(height: 12),
          _buildInsightItem(
            'Saturday was your highest spending day (₦8,500).',
            Icons.calendar_today,
            AppColors.primary,
            isDark,
          ),
          const SizedBox(height: 12),
          _buildInsightItem(
            'Great job! You stayed under budget for Transport.',
            Icons.check_circle,
            AppColors.success,
            isDark,
          ),
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

  Widget _buildBudgetProgressCard(bool isDark) {
    final percentage = (_monthlyTotal / 150000 * 100).clamp(0, 100);
    final isOverBudget = _monthlyTotal > 150000;

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
              value: percentage / 100,
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
                'Spent: ₦${_formatNumber(_monthlyTotal)}',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              Text(
                'Budget: ₦${_formatNumber(150000)}',
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

  Widget _buildComparisonCard(bool isDark) {
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
            'vs Last Month',
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
                child: _buildComparisonItem(
                  'This Month',
                  '₦${_formatNumber(_monthlyTotal)}',
                  null,
                  isDark,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildComparisonItem(
                  'Last Month',
                  '₦${_formatNumber(128000)}',
                  -9.4,
                  isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonItem(String label, String value, double? change, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
        if (change != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                change > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                size: 14,
                color: change > 0 ? AppColors.error : AppColors.success,
              ),
              Text(
                '${change.abs().toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: change > 0 ? AppColors.error : AppColors.success,
                ),
              ),
            ],
          ),
        ],
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
