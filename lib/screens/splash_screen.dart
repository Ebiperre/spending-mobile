import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:spending_mobile/screens/login_screen.dart';
import 'package:spending_mobile/utils/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  Future<void> _navigateToLogin() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // App Logo/Icon
              FadeIn(
                duration: const Duration(milliseconds: 400),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.account_balance_wallet,
                      size: 48,
                      color: AppColors.black,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // App Name
              FadeIn(
                delay: const Duration(milliseconds: 200),
                duration: const Duration(milliseconds: 400),
                child: const Text(
                  'SpendWise',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: AppColors.white,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Tagline
              FadeIn(
                delay: const Duration(milliseconds: 400),
                duration: const Duration(milliseconds: 400),
                child: const Text(
                  'Track your spending, stay on budget',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey400,
                  ),
                ),
              ),

              const Spacer(),

              // Loading Indicator
              FadeIn(
                delay: const Duration(milliseconds: 600),
                duration: const Duration(milliseconds: 400),
                child: const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                  ),
                ),
              ),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
