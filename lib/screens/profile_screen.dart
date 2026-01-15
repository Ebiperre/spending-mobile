import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:spending_mobile/screens/currency_settings_screen.dart';
import 'package:spending_mobile/services/preferences_service.dart';
import 'package:spending_mobile/services/language_service.dart';
import 'package:spending_mobile/providers/theme_provider.dart';
import 'package:spending_mobile/utils/app_theme.dart';
import 'package:spending_mobile/utils/app_strings.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _currency = 'NGN';
  String _currencySymbol = '₦';

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

  void _showLanguageDialog(BuildContext context, LanguageService langService) {
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
              'Select Language',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose your preferred language',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 24),
            _buildLanguageOption(
              context: context,
              title: 'English',
              subtitle: 'Standard English',
              isSelected: langService.currentLanguage == AppLanguage.english,
              onTap: () {
                langService.setLanguage(AppLanguage.english);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 12),
            _buildLanguageOption(
              context: context,
              title: 'Pidgin',
              subtitle: 'Nigerian Pidgin English',
              isSelected: langService.currentLanguage == AppLanguage.pidgin,
              onTap: () {
                langService.setLanguage(AppLanguage.pidgin);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.white.withOpacity(0.1) : AppColors.black.withOpacity(0.05))
              : Colors.transparent,
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

  void _showLogoutDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final langService = Provider.of<LanguageService>(context, listen: false);
    final strings = AppStrings(langService.currentLanguage);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.logout, color: AppColors.error, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              strings.logout,
              style: TextStyle(
                color: isDark ? AppColors.darkText : AppColors.lightText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Text(
          strings.logoutMessage,
          style: TextStyle(
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              strings.cancel,
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to login and clear all routes
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(strings.logout),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Profile Header
            FadeInDown(
              duration: const Duration(milliseconds: 400),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/edit-profile');
                },
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: isDark
                              ? AppColors.darkElevated
                              : AppColors.grey200,
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: isDark
                                ? AppColors.darkText
                                : AppColors.lightText,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.white : AppColors.black,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.edit,
                              size: 14,
                              color: isDark ? AppColors.black : AppColors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'John Doe',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        color: isDark
                            ? AppColors.darkText
                            : AppColors.lightText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'john.doe@example.com',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to edit profile',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.darkTextSecondary.withOpacity(0.7)
                            : AppColors.lightTextSecondary.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Stats Cards
            FadeInUp(
              delay: const Duration(milliseconds: 100),
              duration: const Duration(milliseconds: 400),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context: context,
                      icon: Icons.local_fire_department,
                      label: 'Streak',
                      value: '12 days',
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context: context,
                      icon: Icons.star,
                      label: 'Level',
                      value: 'Beginner',
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Menu Items
            _buildMenuItem(
              context: context,
              icon: Icons.account_balance_wallet,
              title: 'Salary Settings',
              subtitle: '\$3,000/month',
              delay: 150,
              onTap: () {
                Navigator.pushNamed(context, '/salary-settings');
              },
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.currency_exchange,
              title: 'Salary Currency',
              subtitle: '${PreferencesService.getCurrencyName(_currency)} ($_currencySymbol)',
              delay: 200,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CurrencySettingsScreen(),
                  ),
                );
                _loadCurrency();
              },
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.calendar_today,
              title: 'Payday',
              subtitle: '25th of every month',
              delay: 250,
              onTap: () {
                Navigator.pushNamed(context, '/payday-settings');
              },
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.repeat,
              title: 'Recurring Transactions',
              subtitle: 'Manage recurring expenses',
              delay: 275,
              onTap: () {
                Navigator.pushNamed(context, '/recurring-transactions');
              },
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.notifications,
              title: 'Notifications',
              subtitle: 'Daily check-in reminders',
              delay: 300,
              onTap: () {
                Navigator.pushNamed(context, '/notifications-settings');
              },
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.bar_chart,
              title: 'Spending Reports',
              subtitle: 'Weekly & monthly insights',
              delay: 325,
              onTap: () {
                Navigator.pushNamed(context, '/spending-reports');
              },
            ),
            // Dark Mode Toggle
            FadeInUp(
              delay: const Duration(milliseconds: 350),
              duration: const Duration(milliseconds: 400),
              child: Container(
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
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkElevated
                            : AppColors.grey100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.dark_mode,
                        color: isDark
                            ? AppColors.darkText
                            : AppColors.lightText,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dark Mode',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: isDark
                                  ? AppColors.darkText
                                  : AppColors.lightText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Switch to dark theme',
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Consumer<ThemeProvider>(
                      builder: (context, themeProvider, child) {
                        return Switch(
                          value: themeProvider.isDarkMode,
                          onChanged: (value) {
                            themeProvider.toggleTheme();
                          },
                          activeColor: isDark
                              ? AppColors.white
                              : AppColors.black,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Language Selection
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              duration: const Duration(milliseconds: 400),
              child: Consumer<LanguageService>(
                builder: (context, langService, child) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
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
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkElevated
                              : AppColors.grey100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.language,
                          color: isDark
                              ? AppColors.darkText
                              : AppColors.lightText,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        'Language',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: isDark
                              ? AppColors.darkText
                              : AppColors.lightText,
                        ),
                      ),
                      subtitle: Text(
                        langService.languageName,
                        style: TextStyle(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                        size: 20,
                      ),
                      onTap: () => _showLanguageDialog(context, langService),
                    ),
                  );
                },
              ),
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.security,
              title: 'Privacy & Security',
              subtitle: 'Manage your privacy',
              delay: 450,
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.help,
              title: 'Help & Support',
              subtitle: 'Get help and send feedback',
              delay: 500,
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.info,
              title: 'About',
              subtitle: 'Version 1.0.0',
              delay: 550,
            ),

            const SizedBox(height: 24),

            // Logout Button
            FadeInUp(
              delay: const Duration(milliseconds: 600),
              duration: const Duration(milliseconds: 400),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _showLogoutDialog(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark
                        ? AppColors.white
                        : AppColors.black,
                    side: BorderSide(
                      color: isDark
                          ? AppColors.darkElevated
                          : AppColors.grey200,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
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
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.darkText
                  : AppColors.lightText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required int delay,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FadeInUp(
      delay: Duration(milliseconds: delay),
      duration: const Duration(milliseconds: 400),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
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
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: isDark
                  ? AppColors.darkText
                  : AppColors.lightText,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
            size: 20,
          ),
          onTap: onTap ?? () {
            // TODO: Navigate to respective screens
          },
        ),
      ),
    );
  }
}
