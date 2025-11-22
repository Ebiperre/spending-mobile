import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';

class Step2FinancialSetup extends StatefulWidget {
  const Step2FinancialSetup({super.key});

  @override
  State<Step2FinancialSetup> createState() => _Step2FinancialSetupState();
}

class _Step2FinancialSetupState extends State<Step2FinancialSetup> {
  final _formKey = GlobalKey<FormState>();
  final _incomeController = TextEditingController();
  final _rentController = TextEditingController();
  final _transportController = TextEditingController();
  final _billsController = TextEditingController();
  final _savingsController = TextEditingController();
  final _otherController = TextEditingController();

  int _selectedPayday = 25;

  @override
  void dispose() {
    _incomeController.dispose();
    _rentController.dispose();
    _transportController.dispose();
    _billsController.dispose();
    _savingsController.dispose();
    _otherController.dispose();
    super.dispose();
  }

  double _getTotal() {
    double rent = double.tryParse(_rentController.text) ?? 0;
    double transport = double.tryParse(_transportController.text) ?? 0;
    double bills = double.tryParse(_billsController.text) ?? 0;
    double savings = double.tryParse(_savingsController.text) ?? 0;
    double other = double.tryParse(_otherController.text) ?? 0;
    return rent + transport + bills + savings + other;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF0A0A0A)
          : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF0A0A0A)
            : const Color(0xFFF8F9FA),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : const Color(0xFF1A1A1A),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress indicator
                FadeInDown(
                  duration: const Duration(milliseconds: 400),
                  child: Row(
                    children: [
                      Expanded(child: _buildProgressBar(true)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildProgressBar(true)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildProgressBar(false)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildProgressBar(false)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildProgressBar(false)),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                FadeInDown(
                  delay: const Duration(milliseconds: 50),
                  duration: const Duration(milliseconds: 400),
                  child: Text(
                    'Step 2 of 5',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                FadeInDown(
                  delay: const Duration(milliseconds: 100),
                  duration: const Duration(milliseconds: 400),
                  child: Text(
                    'Financial Setup',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : const Color(0xFF1A1A1A),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                FadeInDown(
                  delay: const Duration(milliseconds: 150),
                  duration: const Duration(milliseconds: 400),
                  child: Text(
                    'Help us calculate your daily budget',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Payday Selection
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  duration: const Duration(milliseconds: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'When does salary enter?',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (int day in [1, 15, 25, 30])
                            _buildPaydayChip(day),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Monthly Income
                FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  duration: const Duration(milliseconds: 600),
                  child: TextFormField(
                    controller: _incomeController,
                    style: const TextStyle(color: Colors.black),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'Monthly Income',
                      prefixText: '₦ ',
                      prefixIcon: const Icon(Icons.account_balance_wallet),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your monthly income';
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 24),

                FadeInUp(
                  delay: const Duration(milliseconds: 600),
                  duration: const Duration(milliseconds: 600),
                  child: const Text(
                    'Fixed Monthly Expenses',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 16),

                // Rent
                FadeInUp(
                  delay: const Duration(milliseconds: 700),
                  child: _buildExpenseField(
                    controller: _rentController,
                    label: 'Rent',
                    icon: Icons.home,
                  ),
                ),

                const SizedBox(height: 16),

                // Transport
                FadeInUp(
                  delay: const Duration(milliseconds: 750),
                  child: _buildExpenseField(
                    controller: _transportController,
                    label: 'Transport',
                    icon: Icons.directions_car,
                  ),
                ),

                const SizedBox(height: 16),

                // Bills
                FadeInUp(
                  delay: const Duration(milliseconds: 800),
                  child: _buildExpenseField(
                    controller: _billsController,
                    label: 'Bills (Light, Water, etc.)',
                    icon: Icons.receipt_long,
                  ),
                ),

                const SizedBox(height: 16),

                // Savings
                FadeInUp(
                  delay: const Duration(milliseconds: 850),
                  child: _buildExpenseField(
                    controller: _savingsController,
                    label: 'Target Savings',
                    icon: Icons.savings,
                  ),
                ),

                const SizedBox(height: 16),

                // Other
                FadeInUp(
                  delay: const Duration(milliseconds: 900),
                  child: _buildExpenseField(
                    controller: _otherController,
                    label: 'Other Fixed Expenses',
                    icon: Icons.more_horiz,
                  ),
                ),

                const SizedBox(height: 32),

                // Continue Button
                FadeInUp(
                  delay: const Duration(milliseconds: 450),
                  duration: const Duration(milliseconds: 400),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // TODO: Navigate to step 3 with calculation
                          Navigator.pushNamed(context, '/onboarding/step3', arguments: {
                            'income': double.parse(_incomeController.text),
                            'expenses': _getTotal(),
                            'payday': _selectedPayday,
                          });
                        }
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

                const SizedBox(height: 40),
              ],
            ),
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

  Widget _buildPaydayChip(int day) {
    final isSelected = _selectedPayday == day;
    return GestureDetector(
      onTap: () => setState(() => _selectedPayday = day),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6366F1)
              : Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1A1A1A)
                  : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF6366F1)
                : Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF2A2A2A)
                    : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          '${day}${_getDaySuffix(day)} of month',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? Colors.white
                : Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : const Color(0xFF1A1A1A),
          ),
        ),
      ),
    );
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

  Widget _buildExpenseField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : const Color(0xFF1A1A1A),
        fontWeight: FontWeight.w500,
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w500,
        ),
        prefixText: '₦ ',
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1A1A1A)
            : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF2A2A2A)
                : Colors.grey.shade200,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
        ),
      ),
    );
  }
}
