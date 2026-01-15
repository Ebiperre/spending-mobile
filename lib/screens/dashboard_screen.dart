import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:spending_mobile/screens/analytics_screen.dart';
import 'package:spending_mobile/screens/wallet_screen.dart';
import 'package:spending_mobile/screens/profile_screen.dart';
import 'package:spending_mobile/screens/add_transaction_screen.dart';
import 'package:spending_mobile/screens/quick_add_screen.dart';
import 'package:spending_mobile/screens/morning_briefing_screen.dart';
import 'package:spending_mobile/screens/the_gist_screen.dart';
import 'package:spending_mobile/services/preferences_service.dart';
import 'package:spending_mobile/services/language_service.dart';
import 'package:spending_mobile/utils/app_theme.dart';
import 'package:spending_mobile/utils/app_strings.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  String _currency = 'NGN';
  String _currencySymbol = '₦';
  bool _isFabMenuOpen = false;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;


  final List<Map<String, dynamic>> _recentTransactions = [
    {'title': 'Okada to work', 'amount': -500.0, 'category': '🚗 MOVE', 'icon': Icons.local_taxi},
    {'title': 'Lunch (Rice & Stew)', 'amount': -800.0, 'category': '🍔 CHOP', 'icon': Icons.restaurant},
    {'title': 'MTN Data', 'amount': -1000.0, 'category': '🏠 MUST PAY', 'icon': Icons.wifi},
    {'title': 'Babe Birthday Gift', 'amount': -5000.0, 'category': '❤️ RELATIONSHIP', 'icon': Icons.card_giftcard},
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrency();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrency() async {
    final currency = await PreferencesService.getCurrency();
    setState(() {
      _currency = currency;
      _currencySymbol = PreferencesService.getCurrencySymbol(currency);
    });
  }

  String _formatNumber(double number) {
    return number.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild screens to reflect currency changes
    final screens = [
      _buildHomeScreen(),
      const AnalyticsScreen(),
      const WalletScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: Stack(
        children: [
          screens[_selectedIndex],
          if (_isFabMenuOpen)
            GestureDetector(
              onTap: _toggleFabMenu,
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0 ? Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isFabMenuOpen) ...[
            _buildFabMenuItem(
              icon: Icons.flash_on,
              label: 'Quick Add',
              color: AppColors.accent,
              delay: 0,
              onTap: () {
                _toggleFabMenu();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QuickAddScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildFabMenuItem(
              icon: Icons.edit,
              label: 'Manual Input',
              color: AppColors.primary,
              delay: 50,
              onTap: () {
                _toggleFabMenu();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddTransactionScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
          FadeInUp(
            delay: const Duration(milliseconds: 800),
            duration: const Duration(milliseconds: 600),
            child: FloatingActionButton(
              onPressed: _toggleFabMenu,
              backgroundColor: AppColors.primary,
              child: AnimatedBuilder(
                animation: _fabAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _fabAnimation.value * 0.785398, // 45 degrees in radians
                    child: Icon(
                      _isFabMenuOpen ? Icons.close : Icons.add,
                      size: 32,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ) : null,
      bottomNavigationBar: FadeInUp(
        delay: const Duration(milliseconds: 900),
        duration: const Duration(milliseconds: 600),
        child: Container(
          decoration: const BoxDecoration(),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            selectedItemColor: Theme.of(context).brightness == Brightness.dark
                ? AppColors.white
                : AppColors.black,
            unselectedItemColor: AppColors.grey600,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.analytics),
                label: 'Analytics',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.device_thermostat),
                label: 'Thermometer',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleFabMenu() {
    setState(() {
      _isFabMenuOpen = !_isFabMenuOpen;
      if (_isFabMenuOpen) {
        _fabAnimationController.forward();
      } else {
        _fabAnimationController.reverse();
      }
    });
  }

  Widget _buildFabMenuItem({
    required IconData icon,
    required String label,
    required Color color,
    required int delay,
    required VoidCallback onTap,
  }) {
    return ScaleTransition(
      scale: _fabAnimation,
      child: FadeTransition(
        opacity: _fabAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.3),
            end: Offset.zero,
          ).animate(_fabAnimation),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkSurface
                        : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Material(
                color: color,
                elevation: 4,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 28,
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

  Widget _buildHomeScreen() {
    // Calculate days until payday (assuming 25th of each month)
    final now = DateTime.now();
    final nextPayday = now.day <= 25
        ? DateTime(now.year, now.month, 25)
        : DateTime(now.year, now.month + 1, 25);
    final daysUntilPayday = nextPayday.difference(now).inDays;

    // Mock data - replace with actual data
    final dailyBudget = 1500.0;
    final todaySpent = 1200.0;
    final monthlyBudget = 45000.0;
    final totalSpent = 28000.0;
    final spendingPercentage = (totalSpent / monthlyBudget * 100).round();

    // Gamification data
    final streakDays = 5;
    final badgesEarned = 3;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final langService = Provider.of<LanguageService>(context);
    final strings = AppStrings(langService.currentLanguage);

    // Temperature status based on spending
    String temperatureEmoji;
    String temperatureStatus;
    String temperatureMessage;
    Color temperatureColor;

    if (spendingPercentage <= 30) {
      temperatureEmoji = '🟢';
      temperatureStatus = strings.tempCool;
      temperatureMessage = strings.tempCoolMsg;
      temperatureColor = AppColors.success;
    } else if (spendingPercentage <= 60) {
      temperatureEmoji = '🟡';
      temperatureStatus = strings.tempWarm;
      temperatureMessage = strings.tempWarmMsg;
      temperatureColor = AppColors.warning;
    } else if (spendingPercentage <= 85) {
      temperatureEmoji = '🟠';
      temperatureStatus = strings.tempHot;
      temperatureMessage = strings.tempHotMsg;
      temperatureColor = AppColors.error;
    } else if (spendingPercentage <= 100) {
      temperatureEmoji = '🔴';
      temperatureStatus = strings.tempBoiling;
      temperatureMessage = strings.tempBoilingMsg;
      temperatureColor = AppColors.hot;
    } else {
      temperatureEmoji = '🔥';
      temperatureStatus = strings.tempOverheat;
      temperatureMessage = strings.tempOverheatMsg;
      temperatureColor = AppColors.hot;
    }

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header Section
            Container(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurface
                    : AppColors.lightSurface,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInDown(
                    duration: const Duration(milliseconds: 400),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              strings.greeting('John'),
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.darkText
                                    : AppColors.lightText,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              strings.spendingOverview,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkElevated
                                : AppColors.lightBackground,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.notifications_outlined,
                            color: isDark
                                ? AppColors.darkText
                                : AppColors.lightText,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeInDown(
                    delay: const Duration(milliseconds: 100),
                    duration: const Duration(milliseconds: 400),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🔥', style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Text(
                                strings.dayStreak(streakDays),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.accent.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('⭐', style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Text(
                                strings.badges(badgesEarned),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Main Balance Card
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    duration: const Duration(milliseconds: 400),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurface
                            : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkElevated
                              : AppColors.grey200,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    strings.todaysBudget,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '$_currencySymbol${_formatNumber(dailyBudget)}',
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? AppColors.darkText
                                          : AppColors.lightText,
                                      letterSpacing: -1,
                                      height: 1,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _getTemperatureColor(spendingPercentage).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _getTemperatureColor(spendingPercentage).withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      temperatureEmoji,
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      temperatureStatus,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: _getTemperatureColor(spendingPercentage),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Progress Bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: TweenAnimationBuilder(
                              tween: Tween<double>(begin: 0, end: todaySpent / dailyBudget),
                              duration: const Duration(milliseconds: 1200),
                              curve: Curves.easeOutCubic,
                              builder: (context, double value, child) {
                                return LinearProgressIndicator(
                                  value: value,
                                  minHeight: 8,
                                  backgroundColor: isDark
                                      ? AppColors.darkElevated
                                      : AppColors.lightTextSecondary.withOpacity(0.2),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _getTemperatureColor(spendingPercentage),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    strings.spent,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$_currencySymbol${_formatNumber(todaySpent)}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? AppColors.darkText
                                          : AppColors.lightText,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    strings.remaining,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$_currencySymbol${_formatNumber(dailyBudget - todaySpent)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.success,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _getTemperatureColor(spendingPercentage).withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getTemperatureColor(spendingPercentage).withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 16,
                                  color: _getTemperatureColor(spendingPercentage),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    temperatureMessage,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: _getTemperatureColor(spendingPercentage),
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

                  const SizedBox(height: 20),

                  // Quick Actions
                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    duration: const Duration(milliseconds: 400),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.white
                            : AppColors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () => _showQuickCheckInDialog(),
                        borderRadius: BorderRadius.circular(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.grey200
                                        : AppColors.grey900,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.bolt_rounded,
                                    color: isDark
                                        ? AppColors.black
                                        : AppColors.white,
                                    size: 20,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.grey200
                                        : AppColors.grey900,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '10 sec',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? AppColors.black
                                          : AppColors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              strings.quickCheckIn,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.black
                                    : AppColors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              strings.trackSpending,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? AppColors.grey600
                                    : AppColors.grey400,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Secondary Actions Grid
                  FadeInUp(
                    delay: const Duration(milliseconds: 350),
                    duration: const Duration(milliseconds: 400),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildSecondaryActionCard(
                            icon: Icons.wb_sunny_outlined,
                            title: 'Briefing',
                            color: AppColors.warning,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MorningBriefingScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSecondaryActionCard(
                            icon: Icons.forum_outlined,
                            title: 'The Gist',
                            color: AppColors.secondary,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const TheGistScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

            const SizedBox(height: 24),

            // Monthly Overview
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              duration: const Duration(milliseconds: 600),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurface
                      : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkElevated
                        : AppColors.grey200,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          strings.thisMonth,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: spendingPercentage > 80
                                ? AppColors.error.withOpacity(0.1)
                                : spendingPercentage > 60
                                    ? AppColors.warning.withOpacity(0.1)
                                    : AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            strings.percentSpent(spendingPercentage),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: spendingPercentage > 80
                                  ? AppColors.error
                                  : spendingPercentage > 60
                                      ? AppColors.warning
                                      : AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                strings.budget,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$_currencySymbol${_formatNumber(monthlyBudget)}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 50,
                          width: 1,
                          color: isDark
                              ? AppColors.darkElevated
                              : AppColors.lightTextSecondary.withOpacity(0.3),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  strings.spent,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$_currencySymbol${_formatNumber(totalSpent)}',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: spendingPercentage > 80
                                        ? AppColors.error
                                        : spendingPercentage > 60
                                            ? AppColors.warning
                                            : AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: totalSpent / monthlyBudget,
                        minHeight: 8,
                        backgroundColor: isDark
                            ? AppColors.darkElevated
                            : AppColors.lightTextSecondary.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          spendingPercentage > 80
                              ? AppColors.error
                              : spendingPercentage > 60
                                  ? AppColors.warning
                                  : AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Recent Activity Section
            FadeInUp(
              delay: const Duration(milliseconds: 500),
              duration: const Duration(milliseconds: 600),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    strings.recentActivity,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/transactions');
                    },
                    child: Text(strings.viewAll),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Transactions List
            ...List.generate(
              _recentTransactions.length,
              (index) {
                final transaction = _recentTransactions[index];
                return FadeInUp(
                  delay: Duration(milliseconds: 600 + (index * 100)),
                  duration: const Duration(milliseconds: 600),
                  child: _buildTransactionCard(
                    transaction['title'],
                    transaction['amount'],
                    transaction['category'],
                    transaction['icon'],
                  ),
                );
              },
            ),

            const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTemperatureColor(int percentage) {
    if (percentage <= 30) return AppColors.success;
    if (percentage <= 60) return AppColors.warning;
    if (percentage <= 85) return AppColors.error;
    if (percentage <= 100) return AppColors.hot;
    return AppColors.hot;
  }

  void _showQuickCheckInDialog() {
    final dailyBudget = 1500.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final langService = Provider.of<LanguageService>(context, listen: false);
    final strings = AppStrings(langService.currentLanguage);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkSurface
              : AppColors.lightSurface,
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
                color: isDark
                    ? AppColors.darkElevated
                    : AppColors.lightTextSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              strings.howDidYouSpend,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              strings.compareSpending,
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildCheckInOption(
              icon: Icons.trending_down,
              title: strings.belowBudget,
              subtitle: strings.spentLessThan('$_currencySymbol${_formatNumber(dailyBudget)}'),
              color: AppColors.success,
              onTap: () {
                Navigator.pop(context);
                _showAmountInputDialog('below', dailyBudget);
              },
            ),
            const SizedBox(height: 12),
            _buildCheckInOption(
              icon: Icons.check_circle,
              title: strings.exactBudget,
              subtitle: strings.spentAround('$_currencySymbol${_formatNumber(dailyBudget)}'),
              color: AppColors.primary,
              onTap: () {
                Navigator.pop(context);
                _showCelebrationDialog('exact');
              },
            ),
            const SizedBox(height: 12),
            _buildCheckInOption(
              icon: Icons.trending_up,
              title: strings.aboveBudget,
              subtitle: strings.spentMoreThan('$_currencySymbol${_formatNumber(dailyBudget)}'),
              color: AppColors.error,
              onTap: () {
                Navigator.pop(context);
                _showAmountInputDialog('above', dailyBudget);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showAmountInputDialog(String type, double dailyBudget) {
    final amountController = TextEditingController();
    String? selectedCategory;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final langService = Provider.of<LanguageService>(context, listen: false);
    final strings = AppStrings(langService.currentLanguage);

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
            color: isDark
                ? AppColors.darkSurface
                : AppColors.lightSurface,
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
                  color: isDark
                      ? AppColors.darkElevated
                      : AppColors.lightTextSecondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                type == 'below' ? strings.howMuchSpent : strings.whatHappened,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                type == 'below' ? strings.giveEstimate : strings.tellUsMore,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  prefixText: '$_currencySymbol ',
                  prefixStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  hintText: '0',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: isDark
                          ? AppColors.darkElevated
                          : AppColors.lightTextSecondary.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
              if (type == 'above') ...[
                const SizedBox(height: 24),
                Text(
                  strings.whichCategory,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildCategoryChip('🍔 ${strings.catFood}', selectedCategory, (value) {
                      setModalState(() => selectedCategory = value);
                    }),
                    _buildCategoryChip('🚗 ${strings.catTransport}', selectedCategory, (value) {
                      setModalState(() => selectedCategory = value);
                    }),
                    _buildCategoryChip('💰 ${strings.catFlex}', selectedCategory, (value) {
                      setModalState(() => selectedCategory = value);
                    }),
                    _buildCategoryChip('❤️ ${strings.catRelationship}', selectedCategory, (value) {
                      setModalState(() => selectedCategory = value);
                    }),
                    _buildCategoryChip('🏠 ${strings.catBills}', selectedCategory, (value) {
                      setModalState(() => selectedCategory = value);
                    }),
                    _buildCategoryChip('📱 ${strings.catOther}', selectedCategory, (value) {
                      setModalState(() => selectedCategory = value);
                    }),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (amountController.text.isNotEmpty) {
                      Navigator.pop(context);
                      _showCelebrationDialog(type);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    strings.submit,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category, String? selectedCategory, Function(String?) onTap) {
    final isSelected = selectedCategory == category;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => onTap(isSelected ? null : category),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : isDark
                  ? AppColors.darkElevated
                  : AppColors.lightTextSecondary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          category,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? Colors.white
                : isDark
                    ? AppColors.darkText
                    : AppColors.lightText,
          ),
        ),
      ),
    );
  }

  void _showCelebrationDialog(String type) {
    final langService = Provider.of<LanguageService>(context, listen: false);
    final strings = AppStrings(langService.currentLanguage);

    String emoji;
    String title;
    String message;
    Color color;

    if (type == 'below') {
      emoji = '🎉';
      title = strings.wellDone;
      message = strings.savedMoney;
      color = AppColors.success;
    } else if (type == 'exact') {
      emoji = '👍';
      title = strings.perfect;
      message = strings.stayDisciplined;
      color = AppColors.primary;
    } else {
      emoji = '⚠️';
      title = strings.itHappened;
      message = strings.tryReduce;
      color = AppColors.warning;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    strings.done,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkSurface
              : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? AppColors.darkElevated
                : AppColors.grey200,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkElevated
                    : AppColors.grey100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isDark
                    ? AppColors.darkText
                    : AppColors.lightText,
                size: 20,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkText
                    : AppColors.lightText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckInOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3), width: 2),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(String title, double amount, String category, IconData icon) {
    final isIncome = amount > 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface
            : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? AppColors.darkElevated
              : AppColors.grey200,
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
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  category,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : ''}$_currencySymbol${_formatNumber(amount.abs())}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isIncome ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}
