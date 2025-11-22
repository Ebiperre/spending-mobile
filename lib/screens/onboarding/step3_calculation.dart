import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class Step3Calculation extends StatefulWidget {
  final double income;
  final double expenses;
  final int payday;

  const Step3Calculation({
    super.key,
    required this.income,
    required this.expenses,
    required this.payday,
  });

  @override
  State<Step3Calculation> createState() => _Step3CalculationState();
}

class _Step3CalculationState extends State<Step3Calculation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showCalculation = false;

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

    // Start animation after a delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _controller.forward();
      setState(() => _showCalculation = true);
    });
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
          ? const Color(0xFF0A0A0A)
          : const Color(0xFFF8F9FA),
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
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
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
                          const Color(0xFF6366F1),
                          const Color(0xFF4F46E5),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.3),
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
                          ? const Color(0xFF1A1A1A)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFFF59E0B).withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF59E0B).withOpacity(0.1),
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
                            color: Colors.grey.shade600,
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
                                    ? Colors.white
                                    : const Color(0xFF1A1A1A),
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
                                        ? Colors.white
                                        : const Color(0xFF1A1A1A),
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
                            color: Colors.grey.shade600,
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
                              ? Colors.white
                              : const Color(0xFF1A1A1A),
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
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
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
        color: isActive ? const Color(0xFF6366F1) : Colors.grey.shade300,
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
