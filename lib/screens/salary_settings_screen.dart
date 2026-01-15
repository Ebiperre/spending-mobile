import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:spending_mobile/services/language_service.dart';
import 'package:spending_mobile/services/preferences_service.dart';
import 'package:spending_mobile/utils/app_theme.dart';
import 'package:spending_mobile/utils/app_strings.dart';

class SalarySettingsScreen extends StatefulWidget {
  const SalarySettingsScreen({super.key});

  @override
  State<SalarySettingsScreen> createState() => _SalarySettingsScreenState();
}

class _SalarySettingsScreenState extends State<SalarySettingsScreen> {
  final _salaryController = TextEditingController(text: '3000');
  String _selectedFrequency = 'monthly';
  bool _isLoading = false;
  String _currency = 'NGN';
  String _currencySymbol = '₦';

  final List<Map<String, String>> _frequencies = [
    {'value': 'weekly', 'label': 'Weekly'},
    {'value': 'biweekly', 'label': 'Bi-weekly'},
    {'value': 'monthly', 'label': 'Monthly'},
    {'value': 'yearly', 'label': 'Yearly'},
  ];

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

  @override
  void dispose() {
    _salaryController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_salaryController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    // TODO: Implement actual salary save logic
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Salary settings updated'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context);
    }
  }

  String _formatNumber(String value) {
    if (value.isEmpty) return '';
    final number = double.tryParse(value.replaceAll(',', '')) ?? 0;
    return number.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
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
                    strings.salarySettings,
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

                      // Salary Amount Section
                      FadeInDown(
                        duration: const Duration(milliseconds: 400),
                        child: Text(
                          strings.monthlySalary,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkText : AppColors.lightText,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      FadeInDown(
                        delay: const Duration(milliseconds: 50),
                        duration: const Duration(milliseconds: 400),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark ? AppColors.darkElevated : AppColors.grey200,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                _currencySymbol,
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.darkText : AppColors.lightText,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _salaryController,
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.darkText : AppColors.lightText,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: '0',
                                  ),
                                  onChanged: (value) {
                                    final formatted = _formatNumber(value);
                                    if (formatted != value) {
                                      _salaryController.value = TextEditingValue(
                                        text: formatted,
                                        selection: TextSelection.collapsed(offset: formatted.length),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Frequency Section
                      FadeInDown(
                        delay: const Duration(milliseconds: 100),
                        duration: const Duration(milliseconds: 400),
                        child: Text(
                          strings.paymentFrequency,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkText : AppColors.lightText,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      FadeInUp(
                        delay: const Duration(milliseconds: 150),
                        duration: const Duration(milliseconds: 400),
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _frequencies.map((freq) {
                            final isSelected = _selectedFrequency == freq['value'];
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedFrequency = freq['value']!;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? (isDark ? AppColors.white : AppColors.black)
                                      : (isDark ? AppColors.darkBackground : AppColors.lightBackground),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.transparent
                                        : (isDark ? AppColors.darkElevated : AppColors.grey200),
                                  ),
                                ),
                                child: Text(
                                  freq['label']!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? (isDark ? AppColors.black : AppColors.white)
                                        : (isDark ? AppColors.darkText : AppColors.lightText),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Summary Card
                      FadeInUp(
                        delay: const Duration(milliseconds: 200),
                        duration: const Duration(milliseconds: 400),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkBackground : AppColors.grey100,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              _buildSummaryRow(
                                label: strings.dailyBudget,
                                value: '$_currencySymbol${_formatNumber((double.tryParse(_salaryController.text.replaceAll(',', '')) ?? 0) ~/ 30 as int > 0 ? ((double.tryParse(_salaryController.text.replaceAll(',', '')) ?? 0) / 30).toStringAsFixed(0) : '0')}',
                                isDark: isDark,
                              ),
                              const SizedBox(height: 12),
                              Divider(color: isDark ? AppColors.darkElevated : AppColors.grey200),
                              const SizedBox(height: 12),
                              _buildSummaryRow(
                                label: strings.weeklyBudget,
                                value: '$_currencySymbol${_formatNumber(((double.tryParse(_salaryController.text.replaceAll(',', '')) ?? 0) / 4).toStringAsFixed(0))}',
                                isDark: isDark,
                              ),
                              const SizedBox(height: 12),
                              Divider(color: isDark ? AppColors.darkElevated : AppColors.grey200),
                              const SizedBox(height: 12),
                              _buildSummaryRow(
                                label: strings.yearlyIncome,
                                value: '$_currencySymbol${_formatNumber(((double.tryParse(_salaryController.text.replaceAll(',', '')) ?? 0) * 12).toStringAsFixed(0))}',
                                isDark: isDark,
                                isHighlighted: true,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Info Box
                      FadeInUp(
                        delay: const Duration(milliseconds: 250),
                        duration: const Duration(milliseconds: 400),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  strings.salaryInfoText,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primary,
                                  ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow({
    required String label,
    required String value,
    required bool isDark,
    bool isHighlighted = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlighted ? 18 : 16,
            fontWeight: FontWeight.w700,
            color: isHighlighted
                ? AppColors.success
                : (isDark ? AppColors.darkText : AppColors.lightText),
          ),
        ),
      ],
    );
  }
}
