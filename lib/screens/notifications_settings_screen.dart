import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:spending_mobile/services/language_service.dart';
import 'package:spending_mobile/utils/app_strings.dart';
import 'package:spending_mobile/utils/app_theme.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends State<NotificationsSettingsScreen> {
  // Notification toggles
  bool _dailyReminder = true;
  bool _budgetAlerts = true;
  bool _weeklyReport = true;
  bool _monthlyReport = false;
  bool _overspendingWarning = true;
  bool _streakReminder = true;
  bool _tipOfTheDay = false;

  // Budget alert threshold
  double _budgetThreshold = 80;

  // Daily reminder time
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);

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
        title: Text(
          strings.notifications,
          style: TextStyle(
            color: isDark ? AppColors.white : AppColors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Budget Alerts Section
            FadeInDown(
              duration: const Duration(milliseconds: 300),
              child: _buildSectionHeader('Budget Alerts', Icons.warning_amber_rounded, isDark),
            ),
            const SizedBox(height: 12),

            FadeInDown(
              delay: const Duration(milliseconds: 50),
              duration: const Duration(milliseconds: 300),
              child: _buildToggleTile(
                'Budget Threshold Alert',
                'Get notified when spending reaches ${_budgetThreshold.toInt()}% of budget',
                Icons.pie_chart,
                _budgetAlerts,
                (value) => setState(() => _budgetAlerts = value),
                isDark,
              ),
            ),

            if (_budgetAlerts) ...[
              FadeInDown(
                delay: const Duration(milliseconds: 100),
                duration: const Duration(milliseconds: 300),
                child: _buildSliderTile(
                  'Alert Threshold',
                  _budgetThreshold,
                  (value) => setState(() => _budgetThreshold = value),
                  isDark,
                ),
              ),
            ],

            FadeInDown(
              delay: const Duration(milliseconds: 150),
              duration: const Duration(milliseconds: 300),
              child: _buildToggleTile(
                'Overspending Warning',
                'Immediate alert when you exceed daily budget',
                Icons.trending_up,
                _overspendingWarning,
                (value) => setState(() => _overspendingWarning = value),
                isDark,
              ),
            ),

            const SizedBox(height: 24),

            // Daily Reminders Section
            FadeInDown(
              delay: const Duration(milliseconds: 200),
              duration: const Duration(milliseconds: 300),
              child: _buildSectionHeader('Daily Reminders', Icons.notifications_active, isDark),
            ),
            const SizedBox(height: 12),

            FadeInDown(
              delay: const Duration(milliseconds: 250),
              duration: const Duration(milliseconds: 300),
              child: _buildToggleTile(
                'Daily Check-in Reminder',
                'Reminder to log your daily spending',
                Icons.today,
                _dailyReminder,
                (value) => setState(() => _dailyReminder = value),
                isDark,
              ),
            ),

            if (_dailyReminder) ...[
              FadeInDown(
                delay: const Duration(milliseconds: 300),
                duration: const Duration(milliseconds: 300),
                child: _buildTimeTile(
                  'Reminder Time',
                  _reminderTime,
                  () => _selectTime(context),
                  isDark,
                ),
              ),
            ],

            FadeInDown(
              delay: const Duration(milliseconds: 350),
              duration: const Duration(milliseconds: 300),
              child: _buildToggleTile(
                'Streak Reminder',
                'Don\'t break your check-in streak!',
                Icons.local_fire_department,
                _streakReminder,
                (value) => setState(() => _streakReminder = value),
                isDark,
              ),
            ),

            const SizedBox(height: 24),

            // Reports Section
            FadeInDown(
              delay: const Duration(milliseconds: 400),
              duration: const Duration(milliseconds: 300),
              child: _buildSectionHeader('Reports', Icons.analytics, isDark),
            ),
            const SizedBox(height: 12),

            FadeInDown(
              delay: const Duration(milliseconds: 450),
              duration: const Duration(milliseconds: 300),
              child: _buildToggleTile(
                'Weekly Summary',
                'Get a summary every Sunday',
                Icons.calendar_view_week,
                _weeklyReport,
                (value) => setState(() => _weeklyReport = value),
                isDark,
              ),
            ),

            FadeInDown(
              delay: const Duration(milliseconds: 500),
              duration: const Duration(milliseconds: 300),
              child: _buildToggleTile(
                'Monthly Report',
                'Detailed report at month end',
                Icons.calendar_month,
                _monthlyReport,
                (value) => setState(() => _monthlyReport = value),
                isDark,
              ),
            ),

            const SizedBox(height: 24),

            // Other Section
            FadeInDown(
              delay: const Duration(milliseconds: 550),
              duration: const Duration(milliseconds: 300),
              child: _buildSectionHeader('Other', Icons.more_horiz, isDark),
            ),
            const SizedBox(height: 12),

            FadeInDown(
              delay: const Duration(milliseconds: 600),
              duration: const Duration(milliseconds: 300),
              child: _buildToggleTile(
                'Tip of the Day',
                'Daily money-saving tips',
                Icons.lightbulb_outline,
                _tipOfTheDay,
                (value) => setState(() => _tipOfTheDay = value),
                isDark,
              ),
            ),

            const SizedBox(height: 32),

            // Save Button
            FadeInUp(
              delay: const Duration(milliseconds: 650),
              duration: const Duration(milliseconds: 300),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppColors.white : AppColors.black,
                    foregroundColor: isDark ? AppColors.black : AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save Settings',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildToggleTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkElevated : AppColors.grey200,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: value
                ? (isDark ? AppColors.white.withOpacity(0.1) : AppColors.black.withOpacity(0.05))
                : (isDark ? AppColors.darkElevated : AppColors.grey100),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: value
                ? (isDark ? AppColors.white : AppColors.black)
                : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: isDark ? AppColors.white : AppColors.black,
          activeTrackColor: isDark ? AppColors.white.withOpacity(0.3) : AppColors.black.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildSliderTile(String title, double value, Function(double) onChanged, bool isDark) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _getThresholdColor(value).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${value.toInt()}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _getThresholdColor(value),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: _getThresholdColor(value),
              inactiveTrackColor: isDark ? AppColors.darkElevated : AppColors.grey200,
              thumbColor: _getThresholdColor(value),
              overlayColor: _getThresholdColor(value).withOpacity(0.2),
            ),
            child: Slider(
              value: value,
              min: 50,
              max: 100,
              divisions: 10,
              onChanged: onChanged,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '50%',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              Text(
                '100%',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeTile(String title, TimeOfDay time, VoidCallback onTap, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkElevated : AppColors.grey200,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkElevated : AppColors.grey100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.access_time,
            color: isDark ? AppColors.darkText : AppColors.lightText,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
        subtitle: Text(
          time.format(context),
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        ),
        onTap: onTap,
      ),
    );
  }

  Color _getThresholdColor(double value) {
    if (value <= 60) return AppColors.success;
    if (value <= 80) return AppColors.warning;
    return AppColors.error;
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked != null && picked != _reminderTime) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }

  void _saveSettings() {
    // TODO: Save settings to SharedPreferences
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Settings saved successfully!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    Navigator.pop(context);
  }
}
