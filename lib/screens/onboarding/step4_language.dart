import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class Step4Language extends StatefulWidget {
  const Step4Language({super.key});

  @override
  State<Step4Language> createState() => _Step4LanguageState();
}

class _Step4LanguageState extends State<Step4Language> {
  String _selectedMode = 'mix';

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    Expanded(child: _buildProgressBar(true)),
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
                  'Step 4 of 5',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ),

              const SizedBox(height: 24),

              FadeInDown(
                delay: const Duration(milliseconds: 200),
                duration: const Duration(milliseconds: 600),
                child: Text(
                  'How should we talk to you?',
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
                delay: const Duration(milliseconds: 300),
                duration: const Duration(milliseconds: 600),
                child: Text(
                  'Choose your preferred language mode',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
              ),

              const SizedBox(height: 40),

              // Mix Mode (Default)
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                duration: const Duration(milliseconds: 600),
                child: _buildLanguageOption(
                  mode: 'mix',
                  title: 'Mix Mode (Recommended)',
                  pidginExample: '"Omo! Temperature don dey rise!"',
                  professionalExample: 'Budget report: 65% spent',
                  description: 'Pidgin alerts + Professional reports',
                  emoji: '🔥',
                ),
              ),

              const SizedBox(height: 16),

              // Full Pidgin
              FadeInUp(
                delay: const Duration(milliseconds: 500),
                duration: const Duration(milliseconds: 600),
                child: _buildLanguageOption(
                  mode: 'pidgin',
                  title: 'Full Pidgin',
                  pidginExample: '"Your pocket don dey suffer!"',
                  professionalExample: 'Report go still dey professional for sharing',
                  description: 'All messages in Nigerian Pidgin',
                  emoji: '💬',
                ),
              ),

              const SizedBox(height: 16),

              // Professional Only
              FadeInUp(
                delay: const Duration(milliseconds: 600),
                duration: const Duration(milliseconds: 600),
                child: _buildLanguageOption(
                  mode: 'professional',
                  title: 'Professional Only',
                  pidginExample: '"Budget alert: 85% spent"',
                  professionalExample: 'All messages in formal English',
                  description: 'Formal language throughout',
                  emoji: '💼',
                ),
              ),

              const SizedBox(height: 40),

              // Continue Button
              FadeInUp(
                delay: const Duration(milliseconds: 700),
                duration: const Duration(milliseconds: 600),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/onboarding/step5');
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

  Widget _buildLanguageOption({
    required String mode,
    required String title,
    required String pidginExample,
    required String professionalExample,
    required String description,
    required String emoji,
  }) {
    final isSelected = _selectedMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _selectedMode = mode),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6366F1).withOpacity(0.1)
              : Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1A1A1A)
                  : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF6366F1)
                : Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF2A2A2A)
                    : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  emoji,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? const Color(0xFF6366F1)
                          : Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : const Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: const Color(0xFF6366F1),
                    size: 28,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF2A2A2A)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pidginExample,
                    style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade300
                          : Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    professionalExample,
                    style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade400
                          : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
