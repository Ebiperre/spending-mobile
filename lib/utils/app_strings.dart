import 'package:spending_mobile/services/language_service.dart';

class AppStrings {
  final AppLanguage language;

  AppStrings(this.language);

  bool get _isPidgin => language == AppLanguage.pidgin;

  // Greetings
  String greeting(String name) => _isPidgin ? 'How far, $name' : 'Hello, $name';
  String get spendingOverview => _isPidgin ? 'See how your money dey go' : 'Here\'s your spending overview';

  // Dashboard
  String get todaysBudget => _isPidgin ? 'Today Money' : 'Today\'s Budget';
  String get spent => _isPidgin ? 'Wey You Spend' : 'Spent';
  String get remaining => _isPidgin ? 'Wey Remain' : 'Remaining';
  String get thisMonth => _isPidgin ? 'This Month' : 'This Month';
  String get budget => _isPidgin ? 'Budget' : 'Budget';
  String percentSpent(int percent) => _isPidgin ? '$percent% don go' : '$percent% spent';

  // Temperature Status
  String get tempCool => _isPidgin ? 'COOL' : 'COOL';
  String get tempCoolMsg => _isPidgin ? 'You dey manage am well!' : 'You\'re managing well!';
  String get tempWarm => _isPidgin ? 'WARM' : 'WARM';
  String get tempWarmMsg => _isPidgin ? 'E dey hot small o' : 'Getting a bit warm';
  String get tempHot => _isPidgin ? 'HOT' : 'HOT';
  String get tempHotMsg => _isPidgin ? 'Your pocket dey suffer!' : 'Your wallet is struggling!';
  String get tempBoiling => _isPidgin ? 'BOILING' : 'CRITICAL';
  String get tempBoilingMsg => _isPidgin ? 'Omo! Money don dey finish!' : 'Almost out of budget!';
  String get tempOverheat => _isPidgin ? 'FIRE' : 'OVER';
  String get tempOverheatMsg => _isPidgin ? 'You don break budget!' : 'Budget exceeded!';

  // Quick Actions
  String get quickCheckIn => _isPidgin ? 'Quick Check-in' : 'Quick Check-in';
  String get trackSpending => _isPidgin ? 'Track your daily kudi' : 'Track your daily spending';
  String get tenSec => _isPidgin ? '10 sec' : '10 sec';
  String get briefing => _isPidgin ? 'Briefing' : 'Briefing';
  String get theGist => _isPidgin ? 'The Gist' : 'The Gist';

  // Streak & Badges
  String dayStreak(int days) => _isPidgin ? '$days day fire' : '$days day streak';
  String badges(int count) => _isPidgin ? '$count badge' : '$count badges';

  // Recent Activity
  String get recentActivity => _isPidgin ? 'Recent Kudi Movement' : 'Recent Activity';
  String get viewAll => _isPidgin ? 'See All' : 'View All';

  // Check-in Dialog
  String get howDidYouSpend => _isPidgin ? 'How you spend today?' : 'How did you spend today?';
  String get compareSpending => _isPidgin ? 'Compare your spending to today budget' : 'Compare your spending to today\'s budget';
  String get belowBudget => _isPidgin ? 'Below Budget' : 'Below Budget';
  String spentLessThan(String amount) => _isPidgin ? 'I spend less than $amount' : 'I spent less than $amount';
  String get exactBudget => _isPidgin ? 'Exact Budget' : 'Exact Budget';
  String spentAround(String amount) => _isPidgin ? 'I spend around $amount' : 'I spent around $amount';
  String get aboveBudget => _isPidgin ? 'Above Budget' : 'Above Budget';
  String spentMoreThan(String amount) => _isPidgin ? 'I spend pass $amount' : 'I spent more than $amount';

  // Amount Input
  String get howMuchSpent => _isPidgin ? 'How much you spend?' : 'How much did you spend?';
  String get whatHappened => _isPidgin ? 'Wetin happen?' : 'What happened?';
  String get giveEstimate => _isPidgin ? 'Give us estimate' : 'Give us an estimate';
  String get tellUsMore => _isPidgin ? 'Tell us how much and where the money go' : 'Tell us how much and what category';
  String get whichCategory => _isPidgin ? 'Which category? (Optional)' : 'Which category? (Optional)';
  String get submit => _isPidgin ? 'Submit' : 'Submit';

  // Celebration Dialog
  String get wellDone => _isPidgin ? 'Well done!' : 'Well done!';
  String get savedMoney => _isPidgin ? 'You save money today! Keep am up!' : 'You saved money today! Keep it up!';
  String get perfect => _isPidgin ? 'Perfect!' : 'Perfect!';
  String get stayDisciplined => _isPidgin ? 'You dey manage am well! Stay disciplined!' : 'You\'re managing well! Stay disciplined!';
  String get itHappened => _isPidgin ? 'E don happen!' : 'It happens!';
  String get tryReduce => _isPidgin
      ? 'Make you try reduce spending tomorrow. We go readjust your budget for the rest of the month.'
      : 'Try to reduce spending tomorrow. We\'ll readjust your budget for the rest of the month.';
  String get done => _isPidgin ? 'Done' : 'Done';

  // Navigation
  String get home => _isPidgin ? 'Home' : 'Home';
  String get analytics => _isPidgin ? 'Analytics' : 'Analytics';
  String get thermometer => _isPidgin ? 'Thermometer' : 'Thermometer';
  String get profile => _isPidgin ? 'Profile' : 'Profile';

  // FAB Menu
  String get quickAdd => _isPidgin ? 'Quick Add' : 'Quick Add';
  String get manualInput => _isPidgin ? 'Manual Input' : 'Manual Input';

  // Profile Screen
  String get editProfile => _isPidgin ? 'Edit Profile' : 'Edit Profile';
  String get totalTransactions => _isPidgin ? 'Transactions' : 'Transactions';
  String get settings => _isPidgin ? 'Settings' : 'Settings';
  String get managePreferences => _isPidgin ? 'Manage your app settings' : 'Manage your preferences';
  String get currency => _isPidgin ? 'Currency' : 'Currency';
  String get selectCurrency => _isPidgin ? 'Choose your money type' : 'Select your currency';
  String get languageLabel => _isPidgin ? 'Language' : 'Language';
  String get selectLanguage => _isPidgin ? 'Choose how app go talk' : 'Select app language';
  String get notifications => _isPidgin ? 'Notifications' : 'Notifications';
  String get manageNotifications => _isPidgin ? 'Control your alerts' : 'Manage your alerts';
  String get darkMode => _isPidgin ? 'Dark Mode' : 'Dark Mode';
  String get toggleTheme => _isPidgin ? 'Switch light/dark' : 'Toggle light/dark theme';
  String get logout => _isPidgin ? 'Log Out' : 'Log Out';

  // Login Screen
  String get login => _isPidgin ? 'Login' : 'Login';
  String get welcomeBack => _isPidgin ? 'Welcome Back' : 'Welcome Back';
  String get loginToAccount => _isPidgin ? 'Enter your account' : 'Login to your account';
  String get email => _isPidgin ? 'Email' : 'Email';
  String get password => _isPidgin ? 'Password' : 'Password';
  String get rememberMe => _isPidgin ? 'Remember me' : 'Remember me';
  String get forgotPassword => _isPidgin ? 'Forgot Password?' : 'Forgot Password?';
  String get noAccount => _isPidgin ? 'You no get account? ' : 'Don\'t have an account? ';
  String get signUp => _isPidgin ? 'Sign Up' : 'Sign Up';

  // Splash Screen
  String get appName => 'SpendWise';
  String get tagline => _isPidgin ? 'Track your kudi, stay on budget' : 'Track your spending, stay on budget';

  // Categories
  String get catFood => _isPidgin ? 'CHOP' : 'FOOD';
  String get catTransport => _isPidgin ? 'MOVE' : 'TRANSPORT';
  String get catFlex => _isPidgin ? 'FLEX' : 'LIFESTYLE';
  String get catRelationship => _isPidgin ? 'RELATIONSHIP' : 'RELATIONSHIP';
  String get catBills => _isPidgin ? 'MUST PAY' : 'BILLS';
  String get catOther => _isPidgin ? 'OTHER' : 'OTHER';

  // Validation
  String get enterEmail => _isPidgin ? 'Abeg enter your email' : 'Please enter your email';
  String get validEmail => _isPidgin ? 'Abeg enter correct email' : 'Please enter a valid email';
  String get enterPassword => _isPidgin ? 'Abeg enter your password' : 'Please enter your password';
  String get passwordLength => _isPidgin ? 'Password must reach 8 characters' : 'Password must be at least 8 characters';

  // Forgot Password Screen
  String get forgotPasswordTitle => _isPidgin ? 'Forgot Password' : 'Forgot Password';
  String get resetPassword => _isPidgin ? 'Reset Password' : 'Reset Password';
  String get resetPasswordSubtitle => _isPidgin ? 'Enter your email make we send you reset link' : 'Enter your email and we\'ll send you a reset link';
  String get sendResetLink => _isPidgin ? 'Send Reset Link' : 'Send Reset Link';
  String get backToLogin => _isPidgin ? 'Back to Login' : 'Back to Login';
  String get checkEmail => _isPidgin ? 'Check Your Email' : 'Check Your Email';
  String resetLinkSent(String email) => _isPidgin ? 'We don send reset link to $email' : 'We\'ve sent a reset link to $email';
  String get didntReceiveEmail => _isPidgin ? 'You no see email? Try again' : 'Didn\'t receive the email? Try again';

  // Edit Profile Screen
  String get fullName => _isPidgin ? 'Full Name' : 'Full Name';
  String get enterName => _isPidgin ? 'Abeg enter your name' : 'Please enter your name';
  String get phoneNumber => _isPidgin ? 'Phone Number' : 'Phone Number';
  String get save => _isPidgin ? 'Save' : 'Save';
  String get changePassword => _isPidgin ? 'Change Password' : 'Change Password';
  String get updateYourPassword => _isPidgin ? 'Update your password' : 'Update your password';
  String get deleteAccount => _isPidgin ? 'Delete Account' : 'Delete Account';
  String get permanentlyDelete => _isPidgin ? 'Remove your account forever' : 'Permanently delete your account';
  String get deleteAccountConfirm => _isPidgin ? 'You sure say you wan delete your account? This one no fit reverse o!' : 'Are you sure you want to delete your account? This action cannot be undone.';
  String get cancel => _isPidgin ? 'Cancel' : 'Cancel';
  String get delete => _isPidgin ? 'Delete' : 'Delete';

  // Salary Settings Screen
  String get salarySettings => _isPidgin ? 'Salary Settings' : 'Salary Settings';
  String get monthlySalary => _isPidgin ? 'Your Monthly Salary' : 'Your Monthly Salary';
  String get paymentFrequency => _isPidgin ? 'How You Dey Collect' : 'Payment Frequency';
  String get dailyBudget => _isPidgin ? 'Daily Budget' : 'Daily Budget';
  String get weeklyBudget => _isPidgin ? 'Weekly Budget' : 'Weekly Budget';
  String get yearlyIncome => _isPidgin ? 'Yearly Income' : 'Yearly Income';
  String get salaryInfoText => _isPidgin ? 'Your budget go adjust based on your salary and expenses' : 'Your budget will be calculated based on your salary and fixed expenses';

  // Payday Settings Screen
  String get paydaySettings => _isPidgin ? 'Payday Settings' : 'Payday Settings';
  String get nextPayday => _isPidgin ? 'Next Payday' : 'Next Payday';
  String get daysAway => _isPidgin ? 'days remain' : 'days away';
  String get whenDoYouGetPaid => _isPidgin ? 'When dem dey pay you?' : 'When do you get paid?';
  String get specificDay => _isPidgin ? 'Specific Day' : 'Specific Day';
  String get specificDayDesc => _isPidgin ? 'Choose particular day every month' : 'Choose a specific day each month';
  String get lastDayOfMonth => _isPidgin ? 'Last Day of Month' : 'Last Day of Month';
  String get lastDayDesc => _isPidgin ? 'Dem dey pay me last day' : 'I get paid on the last day';
  String get firstDayOfMonth => _isPidgin ? 'First Day of Month' : 'First Day of Month';
  String get firstDayDesc => _isPidgin ? 'Dem dey pay me first day' : 'I get paid on the first day';
  String get selectDay => _isPidgin ? 'Select Day' : 'Select Day';
  String get selectedPayday => _isPidgin ? 'Selected' : 'Selected';
  String get ofEveryMonth => _isPidgin ? 'of every month' : 'of every month';

  // Logout
  String get logoutConfirm => _isPidgin ? 'You sure say you wan comot?' : 'Are you sure you want to logout?';
  String get logoutMessage => _isPidgin ? 'You go need login again o' : 'You will need to login again to access your account';
}
