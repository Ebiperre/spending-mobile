import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:spending_mobile/services/language_service.dart';
import 'package:spending_mobile/utils/app_theme.dart';
import 'package:spending_mobile/utils/app_strings.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value, AppStrings strings) {
    if (value == null || value.isEmpty) {
      return strings.enterEmail;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return strings.validEmail;
    }
    return null;
  }

  Future<void> _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // TODO: Implement actual password reset logic
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
        _emailSent = true;
      });
    }
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
                    strings.forgotPasswordTitle,
                    style: TextStyle(
                      color: isDark ? AppColors.white : AppColors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Form Container
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
                  child: _emailSent ? _buildSuccessView(isDark, strings) : _buildFormView(isDark, strings),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormView(bool isDark, AppStrings strings) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),

          // Icon
          FadeInDown(
            duration: const Duration(milliseconds: 400),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkElevated : AppColors.grey100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.lock_reset,
                size: 40,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Title
          FadeInDown(
            delay: const Duration(milliseconds: 50),
            duration: const Duration(milliseconds: 400),
            child: Text(
              strings.resetPassword,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
          ),

          const SizedBox(height: 8),

          FadeInDown(
            delay: const Duration(milliseconds: 100),
            duration: const Duration(milliseconds: 400),
            child: Text(
              strings.resetPasswordSubtitle,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Email Field
          FadeInUp(
            delay: const Duration(milliseconds: 150),
            duration: const Duration(milliseconds: 400),
            child: TextFormField(
              controller: _emailController,
              validator: (value) => _validateEmail(value, strings),
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(
                color: isDark ? AppColors.darkText : AppColors.lightText,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                labelText: strings.email,
                labelStyle: TextStyle(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: Icon(
                  Icons.email_outlined,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
                filled: true,
                fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.darkElevated : AppColors.grey200,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.white : AppColors.black,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Reset Button
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            duration: const Duration(milliseconds: 400),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleResetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppColors.white : AppColors.black,
                  foregroundColor: isDark ? AppColors.black : AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark ? AppColors.black : AppColors.white,
                          ),
                        ),
                      )
                    : Text(
                        strings.sendResetLink,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Back to Login
          FadeIn(
            delay: const Duration(milliseconds: 250),
            duration: const Duration(milliseconds: 400),
            child: Center(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text(
                  strings.backToLogin,
                  style: TextStyle(
                    color: isDark ? AppColors.white : AppColors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(bool isDark, AppStrings strings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 60),

        FadeInDown(
          duration: const Duration(milliseconds: 400),
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.mark_email_read,
              size: 50,
              color: AppColors.success,
            ),
          ),
        ),

        const SizedBox(height: 32),

        FadeInDown(
          delay: const Duration(milliseconds: 100),
          duration: const Duration(milliseconds: 400),
          child: Text(
            strings.checkEmail,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 12),

        FadeInDown(
          delay: const Duration(milliseconds: 150),
          duration: const Duration(milliseconds: 400),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              strings.resetLinkSent(_emailController.text),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),

        const SizedBox(height: 40),

        FadeInUp(
          delay: const Duration(milliseconds: 200),
          duration: const Duration(milliseconds: 400),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.white : AppColors.black,
                foregroundColor: isDark ? AppColors.black : AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                strings.backToLogin,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        FadeInUp(
          delay: const Duration(milliseconds: 250),
          duration: const Duration(milliseconds: 400),
          child: TextButton(
            onPressed: () {
              setState(() {
                _emailSent = false;
              });
            },
            child: Text(
              strings.didntReceiveEmail,
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
