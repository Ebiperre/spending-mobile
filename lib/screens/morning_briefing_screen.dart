import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:spending_mobile/services/budget_service.dart';
import 'package:spending_mobile/services/auth_service.dart';
import 'package:spending_mobile/services/preferences_service.dart';
import 'package:spending_mobile/utils/app_theme.dart';

class MorningBriefingScreen extends StatefulWidget {
  const MorningBriefingScreen({super.key});

  @override
  State<MorningBriefingScreen> createState() => _MorningBriefingScreenState();
}

class _MorningBriefingScreenState extends State<MorningBriefingScreen> {
  bool _isLoading = true;
  String _currencySymbol = '₦';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final budgetService = Provider.of<BudgetService>(context, listen: false);
    final currency = await PreferencesService.getCurrency();

    setState(() {
      _currencySymbol = PreferencesService.getCurrencySymbol(currency);
    });

    await Future.wait([
      budgetService.fetchDailyBudget(),
      budgetService.fetchMonthlyBudget(),
      budgetService.fetchOverview(),
    ]);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatNumber(double number) {
    return number.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final budgetService = Provider.of<BudgetService>(context);
    final authService = Provider.of<AuthService>(context);

    // Get data from services
    final user = authService.currentUser;
    final userName = user?.fullName.split(' ').first ?? 'Friend';
    final dailyBudget = budgetService.dailyBudget;
    final monthlyBudget = budgetService.monthlyBudget;
    final overview = budgetService.overview;
    final cycle = overview?.currentCycle;

    // Calculate values from API
    final dailyBudgetAmount = dailyBudget?.budget ?? 0.0;
    final totalBudget = cycle?.totalBudget ?? monthlyBudget?.budget ?? 0.0;
    final totalSpent = monthlyBudget?.spent ?? 0.0;
    final spendingPercentage = totalBudget > 0 ? (totalSpent / totalBudget * 100).round() : 0;
    final daysRemaining = cycle?.daysRemaining ?? monthlyBudget?.daysRemaining ?? 0;

    // Temperature status from API or calculated
    final temperature = cycle?.temperature;
    String temperatureEmoji;
    String temperatureMessage;
    Color temperatureColor;
    String morningGreeting;
    String motivationalMessage;

    // Use API temperature if available, otherwise calculate
    final tempLevel = temperature?.level ?? _calculateTempLevel(spendingPercentage);

    switch (tempLevel.toLowerCase()) {
      case 'cool':
        temperatureEmoji = '🟢';
        temperatureMessage = 'COOL';
        temperatureColor = AppColors.tempCool;
        morningGreeting = 'Good morning, $userName!';
        motivationalMessage = 'You dey do well! Your budget still dey intact. Make we continue this vibe!';
        break;
      case 'warm':
        temperatureEmoji = '🟡';
        temperatureMessage = 'WARM';
        temperatureColor = AppColors.tempWarm;
        morningGreeting = 'Morning, $userName!';
        motivationalMessage = 'E dey hot small o! Try reduce spending today, we fit still balance am.';
        break;
      case 'hot':
        temperatureEmoji = '🟠';
        temperatureMessage = 'HOT';
        temperatureColor = AppColors.tempHot;
        morningGreeting = 'Morning, $userName';
        motivationalMessage = 'Your pocket don dey suffer! Today, make we tight belt small. We go manage!';
        break;
      case 'boiling':
        temperatureEmoji = '🔴';
        temperatureMessage = 'BOILING';
        temperatureColor = AppColors.tempBoiling;
        morningGreeting = 'Morning o, $userName...';
        motivationalMessage = 'Omo! Money don dey finish o! Be careful today, we get only $daysRemaining days left!';
        break;
      default:
        temperatureEmoji = '🔥';
        temperatureMessage = 'OVERHEATING';
        temperatureColor = AppColors.tempOverheat;
        morningGreeting = 'Ah $userName!';
        motivationalMessage = 'You don break budget! Today, no spending at all. We need reset this thing!';
    }

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
          'Morning Briefing',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.white : AppColors.black,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? AppColors.white : AppColors.black,
                  ),
                ),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting
                      FadeInDown(
                        duration: const Duration(milliseconds: 400),
                        child: Text(
                          morningGreeting,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.white : AppColors.black,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      FadeInDown(
                        delay: const Duration(milliseconds: 100),
                        duration: const Duration(milliseconds: 400),
                        child: Text(
                          'Here\'s your temperature for today',
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Temperature Status Card
                      FadeInUp(
                        delay: const Duration(milliseconds: 200),
                        duration: const Duration(milliseconds: 400),
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: temperatureColor,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: temperatureColor.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                temperatureEmoji,
                                style: const TextStyle(fontSize: 64),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                temperatureMessage,
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '$spendingPercentage% of budget spent',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Stats Grid
                      FadeInUp(
                        delay: const Duration(milliseconds: 300),
                        duration: const Duration(milliseconds: 400),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                context,
                                'Today\'s Budget',
                                '$_currencySymbol${_formatNumber(dailyBudgetAmount)}',
                                Icons.calendar_today_outlined,
                                AppColors.primary,
                                isDark,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                context,
                                'Days Left',
                                '$daysRemaining days',
                                Icons.timer_outlined,
                                AppColors.success,
                                isDark,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Motivational Message
                      FadeInUp(
                        delay: const Duration(milliseconds: 400),
                        duration: const Duration(milliseconds: 400),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark ? AppColors.darkElevated : AppColors.grey200,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.warning.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.lightbulb_outline,
                                      color: AppColors.warning,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Today\'s Ginger',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppColors.white : AppColors.black,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                motivationalMessage,
                                style: TextStyle(
                                  fontSize: 15,
                                  height: 1.6,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24.0),
        child: FadeInUp(
          delay: const Duration(milliseconds: 500),
          duration: const Duration(milliseconds: 400),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Let\'s Go!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _calculateTempLevel(int percentage) {
    if (percentage <= 30) return 'cool';
    if (percentage <= 60) return 'warm';
    if (percentage <= 85) return 'hot';
    if (percentage <= 100) return 'boiling';
    return 'overheating';
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkElevated : AppColors.grey200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.white : AppColors.black,
            ),
          ),
        ],
      ),
    );
  }
}
