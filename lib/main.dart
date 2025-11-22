import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spending_mobile/screens/splash_screen.dart';
import 'package:spending_mobile/screens/login_screen.dart';
import 'package:spending_mobile/screens/signup_screen.dart';
import 'package:spending_mobile/screens/dashboard_screen.dart';
import 'package:spending_mobile/screens/quick_add_screen.dart';
import 'package:spending_mobile/screens/add_transaction_screen.dart';
import 'package:spending_mobile/screens/wallet_screen.dart';
import 'package:spending_mobile/screens/currency_settings_screen.dart';
import 'package:spending_mobile/screens/onboarding/step1_basic_info.dart';
import 'package:spending_mobile/screens/onboarding/step2_financial_setup.dart';
import 'package:spending_mobile/screens/onboarding/step3_calculation.dart';
import 'package:spending_mobile/screens/onboarding/step4_language.dart';
import 'package:spending_mobile/screens/onboarding/step5_welcome.dart';
import 'package:spending_mobile/providers/theme_provider.dart';
import 'package:spending_mobile/utils/app_theme.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Spending Mobile',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/quick-add': (context) => const QuickAddScreen(),
        '/add-transaction': (context) => const AddTransactionScreen(),
        '/wallet': (context) => const WalletScreen(),
        '/currency-settings': (context) => const CurrencySettingsScreen(),
        '/onboarding/step1': (context) => const Step1BasicInfo(),
        '/onboarding/step2': (context) => const Step2FinancialSetup(),
        '/onboarding/step3': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return Step3Calculation(
            income: args['income'],
            expenses: args['expenses'],
            payday: args['payday'],
          );
        },
        '/onboarding/step4': (context) => const Step4Language(),
        '/onboarding/step5': (context) => const Step5Welcome(),
      },
    );
  }
}
