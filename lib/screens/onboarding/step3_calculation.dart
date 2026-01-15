import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:spending_mobile/services/settings_service.dart';
import 'package:spending_mobile/services/auth_service.dart';
import 'package:spending_mobile/services/budget_service.dart';
import 'package:spending_mobile/utils/app_theme.dart';

class Step3Calculation extends StatefulWidget {
  final double income;
  final double expenses;
  final int payday;
  final double? rent;
  final double? transport;
  final double? bills;
  final double? savings;
  final double? other;

  const Step3Calculation({
    super.key,
    required this.income,
    required this.expenses,
    required this.payday,
    this.rent,
    this.transport,
    this.bills,
    this.savings,
    this.other,
  });

  @override
  State<Step3Calculation> createState() => _Step3CalculationState();
}

class _Step3CalculationState extends State<Step3Calculation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showCalculation = false;
  bool _isSaving = false;
  bool _savedSuccessfully = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Start animation and save to API after a delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _controller.forward();
      setState(() => _showCalculation = true);
      _saveFinancialProfile();
    });
  }

  Future<void> _saveFinancialProfile() async {
    setState(() => _isSaving = true);

    final settingsService = Provider.of<SettingsService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final budgetService = Provider.of<BudgetService>(context, listen: false);

    final success = await settingsService.saveFinancialProfile(
      monthlyIncome: widget.income,
      salaryDay: widget.payday,
      rent: widget.rent ?? 0,
      transport: widget.transport ?? 0,
      bills: widget.bills ?? 0,
      savingsTarget: widget.savings ?? 0,
      otherFixed: widget.other ?? 0,
    );

    if (success) {
      // Refresh user data to get the new financial profile
      await authService.fetchCurrentUser();
      // Calculate budget based on new profile
      await budgetService.calculateBudget();
      budgetService.fetchDailyBudget();
      budgetService.fetchMonthlyBudget();
    }

    if (mounted) {
      setState(() {
        _isSaving = false;
        _savedSuccessfully = success;
      });

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(settingsService.error ?? 'Failed to save financial profile'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get spendableAmount => widget.income - widget.expenses;
  double get dailyBudget => spendableAmount / 30;

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Progress indicator
              FadeInDown(
                duration: const Duration(milliseconds: 600),
                child: Row(
                  children: [
                    Expanded(child: _buildProgressBar(true)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildProgressBar(true)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildProgressBar(true)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildProgressBar(false)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildProgressBar(false)),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              FadeInDown(
                delay: const Duration(milliseconds: 100),
                duration: const Duration(milliseconds: 600),
                child: Text(
                  'Step 3 of 5',
                  style: TextStyle(fontSize: 14, color: AppColors.grey600),
                ),
              ),

              const Spacer(),

              // Calculation Display
              if (_showCalculation) ...[
                FadeIn(
                  duration: const Duration(milliseconds: 800),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.darkSurface,
                          AppColors.primary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildCalcRow('Monthly Income', widget.income, delay: 0),
                        const SizedBox(height: 16),
                        _buildCalcRow('Fixed Expenses', widget.expenses, delay: 200, isNegative: true),
                        const SizedBox(height: 16),
                        Container(
                          height: 2,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildCalcRow('Spendable Amount', spendableAmount, delay: 400, isBold: true),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Daily Budget Reveal
                FadeIn(
                  delay: const Duration(milliseconds: 1000),
                  duration: const Duration(milliseconds: 600),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkSurface
                          : AppColors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.warning.withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.warning.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Your Daily Budget',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.grey600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '₦',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.white
                                    : AppColors.darkSurface,
                              ),
                            ),
                            const SizedBox(width: 4),
                            AnimatedBuilder(
                              animation: _animation,
                              builder: (context, child) {
                                return Text(
                                  _formatCurrency(dailyBudget * _animation.value),
                                  style: TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -1,
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? AppColors.white
                                        : AppColors.darkSurface,
                                    height: 1,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'per day',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Temperature Set Message
                FadeIn(
                  delay: const Duration(milliseconds: 1600),
                  duration: const Duration(milliseconds: 600),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Temperature Set! ',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.white
                              : AppColors.darkSurface,
                        ),
                      ),
                      const Text(
                        '🌡️',
                        style: TextStyle(fontSize: 28),
                      ),
                    ],
                  ),
                ),
              ],

              const Spacer(),

              // Continue Button
              if (_showCalculation)
                FadeInUp(
                  delay: const Duration(milliseconds: 2200),
                  duration: const Duration(milliseconds: 600),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/onboarding/step4');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(bool isActive) {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.grey300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildCalcRow(String label, double amount, {required int delay, bool isNegative = false, bool isBold = false}) {
    return FadeInLeft(
      delay: Duration(milliseconds: delay),
      duration: const Duration(milliseconds: 600),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: isBold ? 18 : 16,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${isNegative ? '-' : ''}₦${_formatCurrency(amount)}',
            style: TextStyle(
              color: Colors.white,
              fontSize: isBold ? 22 : 18,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
