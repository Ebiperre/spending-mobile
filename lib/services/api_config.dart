class ApiConfig {
  // Backend URL - iOS simulator uses 127.0.0.1 for localhost
  static const String baseUrl = 'http://127.0.0.1:5001';

  // For Android emulator use: 'http://10.0.2.2:5001'
  // For production use your deployed URL

  // API endpoints
  static const String auth = '/auth';
  static const String users = '/users';
  static const String transactions = '/transactions';
  static const String recurring = '/recurring';
  static const String budget = '/budget';
  static const String analytics = '/analytics';
  static const String reports = '/reports';
  static const String notifications = '/notifications';
  static const String settings = '/settings';

  // Auth endpoints
  static String get login => '$auth/login';
  static String get register => '$auth/register';
  static String get logout => '$auth/logout';
  static String get refreshToken => '$auth/refresh-token';
  static String get forgotPassword => '$auth/forgot-password';
  static String get resetPassword => '$auth/reset-password';

  // User endpoints
  static String get me => '$users/me';
  static String get changePassword => '$users/me/password';

  // Settings endpoints
  static String get salary => '$settings/salary';
  static String get payday => '$settings/payday';
  static String get currency => '$settings/currency';
  static String get language => '$settings/language';
  static String get financialProfile => '$settings/financial-profile';

  // Budget endpoints
  static String get dailyBudget => '$budget/daily';
  static String get monthlyBudget => '$budget/monthly';
  static String get calculateBudget => '$budget/calculate';

  // Analytics endpoints
  static String get overview => '$analytics/overview';
  static String get byCategory => '$analytics/by-category';
  static String get trends => '$analytics/trends';

  // Reports endpoints
  static String get weeklyReport => '$reports/weekly';
  static String get monthlyReport => '$reports/monthly';
  static String get exportReport => '$reports/export';

  // Notifications endpoints
  static String get notificationSettings => '$notifications/settings';
  static String get registerDevice => '$notifications/register-device';
}
