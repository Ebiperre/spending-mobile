import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:spending_mobile/services/language_service.dart';
import 'package:spending_mobile/services/settings_service.dart';
import 'package:spending_mobile/services/auth_service.dart';
import 'package:spending_mobile/services/budget_service.dart';
import 'package:spending_mobile/utils/app_theme.dart';
import 'package:spending_mobile/utils/app_strings.dart';

class PaydaySettingsScreen extends StatefulWidget {
  const PaydaySettingsScreen({super.key});

  @override
  State<PaydaySettingsScreen> createState() => _PaydaySettingsScreenState();
}

class _PaydaySettingsScreenState extends State<PaydaySettingsScreen> {
  int _selectedDay = 25;
  String _selectedType = 'specific'; // specific, last_day, first_day
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final financialProfile = authService.financialProfile;

    if (mounted && financialProfile != null) {
      setState(() {
        _selectedDay = financialProfile.salaryDay;
      });
    }
  }

  Future<void> _handleSave() async {
    setState(() {
      _isLoading = true;
    });

    final settingsService = Provider.of<SettingsService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final budgetService = Provider.of<BudgetService>(context, listen: false);
    final currentProfile = authService.financialProfile;

    // Determine the actual day based on type
    int actualDay = _selectedDay;
    if (_selectedType == 'last_day') {
      actualDay = 31; // Will be handled by backend
    } else if (_selectedType == 'first_day') {
      actualDay = 1;
    }

    final success = await settingsService.saveFinancialProfile(
      monthlyIncome: currentProfile?.monthlyIncome ?? 0,
      salaryDay: actualDay,
      rent: currentProfile?.rent ?? 0,
      transport: currentProfile?.transport ?? 0,
      bills: currentProfile?.bills ?? 0,
      savingsTarget: currentProfile?.savingsTarget ?? 0,
      otherFixed: currentProfile?.otherFixed ?? 0,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      // Refresh user data and budgets
      await authService.fetchCurrentUser();
      budgetService.fetchDailyBudget();
      budgetService.fetchMonthlyBudget();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Payday settings updated'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.pop(context);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(settingsService.error ?? 'Failed to update payday'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  int _getDaysUntilPayday() {
    final now = DateTime.now();
    int targetDay = _selectedDay;

    if (_selectedType == 'last_day') {
      final lastDay = DateTime(now.year, now.month + 1, 0).day;
      targetDay = lastDay;
    } else if (_selectedType == 'first_day') {
      targetDay = 1;
    }

    DateTime nextPayday;
    if (now.day <= targetDay) {
      nextPayday = DateTime(now.year, now.month, targetDay);
    } else {
      nextPayday = DateTime(now.year, now.month + 1, targetDay);
    }

    return nextPayday.difference(now).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final langService = Provider.of<LanguageService>(context);
    final strings = AppStrings(langService.currentLanguage);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: isDark ? AppColors.white : AppColors.black,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    strings.paydaySettings,
                    style: TextStyle(
                      color: isDark ? AppColors.white : AppColors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _isLoading ? null : _handleSave,
                    child: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: isDark ? AppColors.white : AppColors.black,
                            ),
                          )
                        : Text(
                            strings.save,
                            style: TextStyle(
                              color: isDark ? AppColors.white : AppColors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // Countdown Card
                      FadeInDown(
                        duration: const Duration(milliseconds: 400),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.accent,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Text(
                                strings.nextPayday,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.white.withOpacity(0.8),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${_getDaysUntilPayday()}',
                                style: const TextStyle(
                                  fontSize: 56,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.white,
                                ),
                              ),
                              Text(
                                strings.daysAway,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Payday Type Selection
                      FadeInDown(
                        delay: const Duration(milliseconds: 100),
                        duration: const Duration(milliseconds: 400),
                        child: Text(
                          strings.whenDoYouGetPaid,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkText : AppColors.lightText,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Type Options
                      FadeInUp(
                        delay: const Duration(milliseconds: 150),
                        duration: const Duration(milliseconds: 400),
                        child: _buildPaydayOption(
                          title: strings.specificDay,
                          subtitle: strings.specificDayDesc,
                          icon: Icons.calendar_today,
                          isSelected: _selectedType == 'specific',
                          isDark: isDark,
                          onTap: () {
                            setState(() {
                              _selectedType = 'specific';
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 12),

                      FadeInUp(
                        delay: const Duration(milliseconds: 200),
                        duration: const Duration(milliseconds: 400),
                        child: _buildPaydayOption(
                          title: strings.lastDayOfMonth,
                          subtitle: strings.lastDayDesc,
                          icon: Icons.last_page,
                          isSelected: _selectedType == 'last_day',
                          isDark: isDark,
                          onTap: () {
                            setState(() {
                              _selectedType = 'last_day';
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 12),

                      FadeInUp(
                        delay: const Duration(milliseconds: 250),
                        duration: const Duration(milliseconds: 400),
                        child: _buildPaydayOption(
                          title: strings.firstDayOfMonth,
                          subtitle: strings.firstDayDesc,
                          icon: Icons.first_page,
                          isSelected: _selectedType == 'first_day',
                          isDark: isDark,
                          onTap: () {
                            setState(() {
                              _selectedType = 'first_day';
                            });
                          },
                        ),
                      ),

                      // Day Selector (only show for specific day)
                      if (_selectedType == 'specific') ...[
                        const SizedBox(height: 24),

                        FadeInUp(
                          delay: const Duration(milliseconds: 300),
                          duration: const Duration(milliseconds: 400),
                          child: Text(
                            strings.selectDay,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.darkText : AppColors.lightText,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        FadeInUp(
                          delay: const Duration(milliseconds: 350),
                          duration: const Duration(milliseconds: 400),
                          child: Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark ? AppColors.darkElevated : AppColors.grey200,
                              ),
                            ),
                            child: GridView.builder(
                              padding: const EdgeInsets.all(12),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 7,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                              ),
                              itemCount: 31,
                              itemBuilder: (context, index) {
                                final day = index + 1;
                                final isSelected = _selectedDay == day;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedDay = day;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? (isDark ? AppColors.white : AppColors.black)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '$day',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                          color: isSelected
                                              ? (isDark ? AppColors.black : AppColors.white)
                                              : (isDark ? AppColors.darkText : AppColors.lightText),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        FadeInUp(
                          delay: const Duration(milliseconds: 400),
                          duration: const Duration(milliseconds: 400),
                          child: Center(
                            child: Text(
                              '${strings.selectedPayday}: $_selectedDay${_getDaySuffix(_selectedDay)} ${strings.ofEveryMonth}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.darkText : AppColors.lightText,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaydayOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.white.withOpacity(0.1) : AppColors.black.withOpacity(0.05))
              : (isDark ? AppColors.darkBackground : AppColors.lightBackground),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? (isDark ? AppColors.white : AppColors.black)
                : (isDark ? AppColors.darkElevated : AppColors.grey200),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? AppColors.white.withOpacity(0.2) : AppColors.black.withOpacity(0.1))
                    : (isDark ? AppColors.darkElevated : AppColors.grey100),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isDark ? AppColors.darkText : AppColors.lightText,
                size: 22,
              ),
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
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: isDark ? AppColors.white : AppColors.black,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
