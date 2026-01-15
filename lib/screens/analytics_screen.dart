import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:spending_mobile/services/auth_service.dart';
import 'package:spending_mobile/services/budget_service.dart';
import 'package:spending_mobile/services/preferences_service.dart';
import 'package:spending_mobile/models/analytics.dart';
import 'package:spending_mobile/utils/app_theme.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _currencySymbol = '₦';
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final currency = await PreferencesService.getCurrency();
    final budgetService = Provider.of<BudgetService>(context, listen: false);

    await Future.wait([
      budgetService.fetchOverview(),
      budgetService.fetchByCategory(),
    ]);

    if (mounted) {
      setState(() {
        _currencySymbol = PreferencesService.getCurrencySymbol(currency);
        _isInitialLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final budgetService = Provider.of<BudgetService>(context);
    final authService = Provider.of<AuthService>(context);

    final overview = budgetService.overview;
    final categories = budgetService.categorySpending;
    final cycle = overview?.currentCycle;
    final financialProfile = authService.financialProfile;

    // Calculate percentage spent
    final percentUsed = cycle?.percentUsed ?? 0.0;
    final daysRemaining = cycle?.daysRemaining ?? 0;

    if (_isInitialLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            isDark ? AppColors.white : AppColors.black,
          ),
        ),
      );
    }

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadData,
        color: isDark ? AppColors.white : AppColors.black,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            FadeInDown(
              duration: const Duration(milliseconds: 400),
              child: Text(
                'Spending Analytics',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                  color: isDark
                      ? AppColors.darkText
                      : AppColors.lightText,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Spending Status Card - Premium Design
            FadeInUp(
              delay: const Duration(milliseconds: 100),
              duration: const Duration(milliseconds: 400),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _getGradientColors(percentUsed / 100),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: _getColorForPercentage(percentUsed / 100).withOpacity(0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'DAYS UNTIL PAYDAY',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$daysRemaining days',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '${percentUsed.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 56,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -2,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'of budget spent',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Premium progress bar
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.white.withOpacity(0.2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: (percentUsed / 100).clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.5),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _getMessageForPercentage(percentUsed / 100),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Category Breakdown
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              duration: const Duration(milliseconds: 400),
              child: Text(
                'Spending by Category',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : AppColors.lightText,
                ),
              ),
            ),

            const SizedBox(height: 16),

            if (categories.isEmpty)
              FadeInUp(
                delay: const Duration(milliseconds: 250),
                duration: const Duration(milliseconds: 400),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppColors.darkElevated : AppColors.grey200,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'No spending data yet',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ),
                ),
              )
            else
              ...categories.asMap().entries.map((entry) {
                final index = entry.key;
                final category = entry.value;
                return _buildCategoryCard(
                  context,
                  _getCategoryLabel(category.category),
                  '$_currencySymbol${_formatNumber(category.total)}',
                  category.percentage.round(),
                  _getCategoryColor(category.category),
                  index,
                  250 + (index * 50),
                );
              }),

            const SizedBox(height: 24),

            // Insights
            FadeInUp(
              delay: const Duration(milliseconds: 500),
              duration: const Duration(milliseconds: 400),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.primary.withOpacity(0.1)
                      : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? AppColors.primary.withOpacity(0.2)
                        : AppColors.primary.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.primary.withOpacity(0.1)
                            : AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.lightbulb_outline,
                        color: isDark ? AppColors.primary : AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Smart Tip',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: isDark ? AppColors.darkText : AppColors.lightText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getSmartTip(categories, percentUsed / 100),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
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
      ),
    );
  }

  String _getSmartTip(List<CategorySpending> categories, double percentage) {
    if (categories.isEmpty) {
      return 'Start tracking your expenses to get personalized tips!';
    }

    // Find the highest spending category
    if (categories.isNotEmpty) {
      final topCategory = categories.first;
      if (topCategory.percentage > 40) {
        return 'Your ${_getCategoryLabel(topCategory.category).toLowerCase()} spending is ${topCategory.percentage.toStringAsFixed(0)}% of total. Consider setting a limit!';
      }
    }

    if (percentage > 0.7) {
      return 'You\'ve used ${(percentage * 100).toStringAsFixed(0)}% of your budget. Try to reduce spending!';
    } else if (percentage < 0.3) {
      return 'Great job! You\'re on track with your budget. Keep it up! 💪';
    }

    return 'Track every spending, no matter how small. It all adds up!';
  }

  List<Color> _getGradientColors(double percentage) {
    if (percentage < 0.3) {
      return [AppColors.tempCool, AppColors.successMuted];
    } else if (percentage < 0.6) {
      return [AppColors.tempWarm, AppColors.tempHot];
    } else {
      return [AppColors.tempHot, AppColors.tempBoiling];
    }
  }

  Color _getColorForPercentage(double percentage) {
    if (percentage < 0.3) {
      return AppColors.tempCool;
    } else if (percentage < 0.6) {
      return AppColors.tempWarm;
    } else {
      return AppColors.tempBoiling;
    }
  }

  String _getMessageForPercentage(double percentage) {
    if (percentage < 0.3) {
      return '✅ You dey do well! Keep am up!';
    } else if (percentage < 0.6) {
      return '⚠️ E dey warm small. Watch your spending o!';
    } else {
      return '🔥 E don hot! Cool down the spending abeg!';
    }
  }

  String _getCategoryLabel(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return 'Food & Drinks';
      case 'transport':
        return 'Transport';
      case 'entertainment':
        return 'Entertainment';
      case 'shopping':
        return 'Shopping';
      case 'bills':
        return 'Bills';
      case 'health':
        return 'Health';
      case 'education':
        return 'Education';
      default:
        return 'Other';
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return AppColors.categoryFood;
      case 'transport':
        return AppColors.categoryTransport;
      case 'entertainment':
        return AppColors.categoryEntertainment;
      case 'shopping':
        return AppColors.categoryShopping;
      case 'bills':
        return AppColors.categoryBills;
      case 'health':
        return AppColors.categoryHealth;
      case 'education':
        return AppColors.categoryEducation;
      default:
        return AppColors.categoryOther;
    }
  }

  String _formatNumber(double number) {
    return number.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  Widget _buildCategoryCard(BuildContext context, String category, String amount, int percentage, Color color, int index, int delay) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return FadeInUp(
      delay: Duration(milliseconds: delay),
      duration: const Duration(milliseconds: 400),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkSurface
              : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? AppColors.grey800
                : AppColors.grey200,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(isDark ? 0.15 : 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        _getCategoryIcon(category),
                        color: color,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      category,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkText
                            : AppColors.lightText,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: color,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: isDark
                          ? AppColors.grey800
                          : AppColors.grey200,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: (percentage / 100).clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: color,
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.4),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  '$percentage%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food & Drinks':
        return Icons.restaurant;
      case 'Transport':
        return Icons.directions_car;
      case 'Entertainment':
        return Icons.movie;
      case 'Shopping':
        return Icons.shopping_bag;
      case 'Bills':
        return Icons.receipt_long;
      default:
        return Icons.category;
    }
  }
}
