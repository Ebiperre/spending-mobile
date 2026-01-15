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
import 'package:spending_mobile/screens/transactions_list_screen.dart';
import 'package:spending_mobile/screens/notifications_settings_screen.dart';
import 'package:spending_mobile/screens/recurring_transactions_screen.dart';
import 'package:spending_mobile/screens/spending_reports_screen.dart';
import 'package:spending_mobile/screens/forgot_password_screen.dart';
import 'package:spending_mobile/screens/edit_profile_screen.dart';
import 'package:spending_mobile/screens/salary_settings_screen.dart';
import 'package:spending_mobile/screens/payday_settings_screen.dart';
import 'package:spending_mobile/screens/onboarding/step1_basic_info.dart';
import 'package:spending_mobile/screens/onboarding/step2_financial_setup.dart';
import 'package:spending_mobile/screens/onboarding/step3_calculation.dart';
import 'package:spending_mobile/screens/onboarding/step4_language.dart';
import 'package:spending_mobile/screens/onboarding/step5_welcome.dart';
import 'package:spending_mobile/providers/theme_provider.dart';
import 'package:spending_mobile/services/language_service.dart';
import 'package:spending_mobile/services/auth_service.dart';
import 'package:spending_mobile/services/transaction_service.dart';
import 'package:spending_mobile/services/budget_service.dart';
import 'package:spending_mobile/services/settings_service.dart';
import 'package:spending_mobile/services/database_service.dart';
import 'package:spending_mobile/services/connectivity_service.dart';
import 'package:spending_mobile/services/sync_queue_service.dart';
import 'package:spending_mobile/utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize core services
  final databaseService = DatabaseService();
  final connectivityService = ConnectivityService();
  final syncQueueService = SyncQueueService();

  // Initialize database
  await databaseService.init();

  // Initialize connectivity monitoring
  await connectivityService.init();

  // Initialize sync queue
  await syncQueueService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageService()),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => TransactionService()),
        ChangeNotifierProvider(create: (_) => BudgetService()),
        ChangeNotifierProvider(create: (_) => SettingsService()),
        // Offline-first services (singletons already initialized)
        ChangeNotifierProvider.value(value: connectivityService),
        ChangeNotifierProvider.value(value: syncQueueService),
      ],
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
        '/transactions': (context) => const TransactionsListScreen(),
        '/notifications-settings': (context) => const NotificationsSettingsScreen(),
        '/recurring-transactions': (context) => const RecurringTransactionsScreen(),
        '/spending-reports': (context) => const SpendingReportsScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),
        '/salary-settings': (context) => const SalarySettingsScreen(),
        '/payday-settings': (context) => const PaydaySettingsScreen(),
        '/onboarding/step1': (context) => const Step1BasicInfo(),
        '/onboarding/step2': (context) => const Step2FinancialSetup(),
        '/onboarding/step3': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return Step3Calculation(
            income: args['income'],
            expenses: args['expenses'],
            payday: args['payday'],
            rent: args['rent'],
            transport: args['transport'],
            bills: args['bills'],
            savings: args['savings'],
            other: args['other'],
          );
        },
        '/onboarding/step4': (context) => const Step4Language(),
        '/onboarding/step5': (context) => const Step5Welcome(),
      },
    );
  }
}
