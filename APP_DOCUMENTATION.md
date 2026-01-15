# Spending Mobile App - Complete Documentation

## Overview

**Spending Mobile** is a premium fintech mobile application built with Flutter that helps Nigerian salary earners track their daily spending and stay within budget using a unique temperature-based visualization system.

**Current Version:** 1.0.0+1
**Platform:** iOS & Android
**Framework:** Flutter (Dart SDK ^3.10.0)
**Current App Name:** Spending Mobile
**Suggested App Name:** Heatcheck (pending decision)

---

## Core Concept

The app calculates a **daily spendable budget** based on your salary, payday, and fixed expenses (rent, bills, transport, etc.). It then tracks your spending and displays your budget status using a **temperature metaphor**:

| Temperature | Status | Percentage Used |
|-------------|--------|-----------------|
| Cool | Healthy spending | 0-30% |
| Warm | Caution | 31-60% |
| Hot | Warning | 61-85% |
| Boiling | Alert | 86-100% |
| Overheat | Critical (over budget) | 100%+ |

---

## Technology Stack

### Dependencies
```yaml
flutter: SDK
provider: ^6.1.1          # State management
http: ^1.2.0              # API calls
flutter_secure_storage: ^9.2.4  # Token storage
shared_preferences: ^2.2.2      # Local preferences
animate_do: ^3.3.4        # UI animations
cupertino_icons: ^1.0.8   # iOS-style icons
```

### Architecture
- **Pattern:** MVVM with Provider
- **State Management:** ChangeNotifier + Provider
- **API Client:** Custom HTTP client with JWT refresh
- **Storage:** FlutterSecureStorage (tokens) + SharedPreferences (settings)

---

## Design System

### Color Palette

**Primary Brand:**
- Primary: `#00D09C` (Vibrant mint green)
- Primary Dark: `#00B386`
- Accent: `#FF6B6B` (Electric coral)

**Temperature Colors:**
- Cool: `#00D09C` (Mint green)
- Warm: `#FFB020` (Amber)
- Hot: `#FF8C42` (Orange)
- Boiling: `#FF4757` (Red)
- Overheat: `#DC2626` (Deep red)

**Dark Theme:**
- Background: `#0D0D0D` (True black)
- Surface: `#171717`
- Elevated: `#262626`

**Light Theme:**
- Background: `#FAFAFA`
- Surface: `#FFFFFF`

### Category Colors
- Food: `#FF8C42` (Orange)
- Transport: `#3B82F6` (Blue)
- Bills: `#8B5CF6` (Purple)
- Entertainment: `#EC4899` (Pink)
- Shopping: `#00D09C` (Mint)
- Health: `#10B981` (Emerald)

---

## App Structure

### File Organization
```
lib/
├── main.dart                 # App entry, providers, routes
├── models/
│   ├── user.dart            # User, FinancialProfile, Streak
│   ├── transaction.dart     # Transaction, RecurringTransaction
│   ├── budget.dart          # DailyBudget, MonthlyBudget, Temperature
│   └── analytics.dart       # Overview, Reports, Trends
├── services/
│   ├── api_client.dart      # HTTP client with token refresh
│   ├── api_config.dart      # API endpoints configuration
│   ├── auth_service.dart    # Authentication
│   ├── transaction_service.dart
│   ├── budget_service.dart
│   ├── settings_service.dart
│   ├── language_service.dart
│   └── preferences_service.dart
├── screens/
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   ├── dashboard_screen.dart
│   ├── analytics_screen.dart
│   ├── wallet_screen.dart
│   ├── profile_screen.dart
│   ├── add_transaction_screen.dart
│   ├── quick_add_screen.dart
│   ├── the_gist_screen.dart
│   └── onboarding/
│       ├── step1_basic_info.dart
│       ├── step2_financial_setup.dart
│       ├── step3_calculation.dart
│       ├── step4_language.dart
│       └── step5_welcome.dart
├── widgets/
│   └── animated_thermometer.dart
├── providers/
│   └── theme_provider.dart
└── utils/
    ├── app_theme.dart       # Colors, themes
    ├── app_strings.dart     # i18n (English/Pidgin)
    └── page_transitions.dart
```

---

## Screens & Navigation

### Authentication Flow
1. **Splash Screen** - App launch, checks auth status
2. **Login Screen** - Email/password login
3. **Signup Screen** - New user registration
4. **Forgot Password** - Password reset via email

### Onboarding (5 Steps)
1. **Basic Info** - Name, email, phone, gender
2. **Financial Setup** - Monthly income, payday selection
3. **Calculation** - Fixed expenses (rent, transport, bills, savings)
4. **Language** - English or Nigerian Pidgin
5. **Welcome** - Onboarding completion

### Main App (Bottom Navigation)
| Tab | Screen | Purpose |
|-----|--------|---------|
| Home | Dashboard | Budget overview, temperature, recent transactions |
| Analytics | Analytics | Category breakdown, trends, charts |
| Heat | Wallet | Thermometer visualization |
| Profile | Profile | Settings, account management |

### Other Screens
- **Add Transaction** - Manual expense entry
- **Quick Add** - Daily check-in (spent less/exact/more than budget)
- **Transactions List** - Full history with filters
- **Recurring Transactions** - Manage recurring expenses
- **The Gist** - Anonymous spending confessions community
- **Morning Briefing** - Daily spending summary
- **Spending Reports** - Weekly/monthly reports
- **Settings:** Edit Profile, Currency, Salary, Payday, Notifications

---

## Features

### Budget Management
- Automatic daily budget calculation based on salary and expenses
- Real-time spending tracking
- Temperature-based visual status
- Spending cycle management (payday to payday)

### Transaction Tracking
- Manual transaction entry with categories
- Quick daily check-in (3 options)
- Recurring transaction support (daily/weekly/monthly)
- Transaction history with search and filters

### Analytics
- Category spending breakdown
- Weekly/monthly trends
- Budget vs actual comparison
- Exportable reports

### Gamification
- Streak counter (consecutive days within budget)
- Achievement badges
- Celebration dialogs for good spending behavior

### Personalization
- **Languages:** English, Nigerian Pidgin
- **Themes:** Light/Dark mode
- **Currency:** NGN (Naira), USD, EUR, GBP
- **Notifications:** Morning briefing, evening check-in, budget alerts

---

## Data Models

### User
```dart
class User {
  String id;
  String fullName;
  String email;
  String? phone;
  String? gender;
  String? ageRange;
  String languagePreference;  // 'english', 'pidgin', 'mix'
  bool isActive;
  DateTime? lastLogin;
  DateTime createdAt;
}
```

### FinancialProfile
```dart
class FinancialProfile {
  String userId;
  double monthlyIncome;
  int salaryDay;
  double rent;
  double transport;
  double bills;
  double savingsTarget;
  double otherFixed;
  double spendableAmount;  // Calculated: income - fixed expenses
}
```

### Transaction
```dart
class Transaction {
  String id;
  double amount;
  String category;  // 'food', 'transport', 'bills', 'flex', etc.
  String? description;
  DateTime date;
  String type;  // 'income' or 'expense'
}
```

### Budget
```dart
class DailyBudget {
  double budget;
  double spent;
  double remaining;
  double percentUsed;
  bool hasActiveCycle;
}

class MonthlyBudget {
  double budget;
  double spent;
  double remaining;
  double percentUsed;
  int daysRemaining;
  Temperature temperature;
}
```

---

## API Integration

### Base URL
- Development: `http://127.0.0.1:5001`
- Production: Configure in `api_config.dart`

### Endpoints

**Authentication:**
```
POST /auth/login
POST /auth/register
POST /auth/logout
POST /auth/refresh-token
POST /auth/forgot-password
POST /auth/reset-password
```

**User:**
```
GET  /users/me
PUT  /users/me
PUT  /users/me/password
DELETE /users/me
```

**Budget:**
```
GET  /budget/daily
GET  /budget/monthly
POST /budget/calculate
```

**Transactions:**
```
GET    /transactions
POST   /transactions
PUT    /transactions/:id
DELETE /transactions/:id
POST   /transactions/quick-add
```

**Recurring:**
```
GET    /recurring
POST   /recurring
PUT    /recurring/:id/toggle
DELETE /recurring/:id
```

**Analytics:**
```
GET /analytics/overview
GET /analytics/by-category
GET /analytics/trends
```

**Reports:**
```
GET /reports/weekly
GET /reports/monthly
GET /reports/export
```

**Settings:**
```
GET/PUT /settings/salary
GET/PUT /settings/payday
GET/PUT /settings/currency
GET/PUT /settings/language
GET/PUT /settings/financial-profile
GET/PUT /settings/notifications
POST    /settings/notifications/register-device
```

### Authentication
- JWT Bearer tokens
- Stored in FlutterSecureStorage
- Auto-refresh on 401 response

---

## Services

### AuthService
Handles user authentication, registration, profile management.
```dart
// Key methods
await authService.login(email, password);
await authService.register(userData);
await authService.logout();
await authService.fetchCurrentUser();
await authService.updateProfile(data);
await authService.changePassword(oldPass, newPass);
```

### TransactionService
Manages transactions and quick check-ins.
```dart
await transactionService.fetchTransactions(filters);
await transactionService.createTransaction(transaction);
await transactionService.quickAdd(status);  // 'under', 'exact', 'over'
await transactionService.fetchRecurringTransactions();
```

### BudgetService
Handles budget calculations and analytics.
```dart
await budgetService.fetchDailyBudget();
await budgetService.fetchMonthlyBudget();
await budgetService.fetchOverview();
await budgetService.fetchByCategory();
await budgetService.fetchTrends();
```

### SettingsService
Manages all user settings.
```dart
await settingsService.fetchSalarySettings();
await settingsService.updateSalarySettings(salary, day);
await settingsService.updateCurrency(currency);
await settingsService.updateNotificationSettings(settings);
```

---

## State Management

Uses **Provider** with ChangeNotifier pattern:

```dart
// main.dart setup
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ChangeNotifierProvider(create: (_) => LanguageService()),
    ChangeNotifierProvider(create: (_) => AuthService()),
    ChangeNotifierProvider(create: (_) => TransactionService()),
    ChangeNotifierProvider(create: (_) => BudgetService()),
    ChangeNotifierProvider(create: (_) => SettingsService()),
  ],
)

// Usage in widgets
final authService = Provider.of<AuthService>(context);
final budget = Provider.of<BudgetService>(context);
```

---

## Localization

Supports two languages:
1. **English** - Professional financial language
2. **Nigerian Pidgin** - Casual, relatable tone

Example strings:
```dart
// English
"You're doing great! Keep it up."
"You've spent 75% of today's budget"

// Pidgin
"You dey try! Keep am up."
"You don spend 75% of today money"
```

Language is stored in SharedPreferences and managed by `LanguageService`.

---

## Running the App

### Prerequisites
- Flutter SDK ^3.10.0
- Xcode (for iOS)
- Android Studio (for Android)

### Commands
```bash
# Install dependencies
flutter pub get

# Run on Chrome (development)
flutter run -d chrome

# Run on iOS Simulator
flutter run -d "iPhone 16"

# Run on physical iOS device
flutter run -d "DEVICE_ID"

# Build iOS
flutter build ios

# Build Android
flutter build apk
```

### iOS Device Setup
1. Enable Developer Mode: Settings → Privacy & Security → Developer Mode
2. Trust computer when prompted
3. May need to open Xcode and accept device prompts

---

## Git Status

**Current Branch:** main

**Modified Files:**
- `lib/screens/dashboard_screen.dart`
- `lib/screens/login_screen.dart`
- `lib/screens/profile_screen.dart`
- `lib/screens/splash_screen.dart`
- `lib/utils/app_theme.dart`

---

## Future Enhancements

### Pending Decisions
- [ ] Finalize app name (Heatcheck recommended)
- [ ] Update iOS/Android display names

### Potential Features
- Push notifications integration
- Bank account linking
- Receipt scanning
- Social sharing achievements
- More detailed analytics charts
- Budget predictions/AI insights

---

## Contact & Support

For issues or feature requests, please create an issue in the GitHub repository.

---

*Last Updated: January 2026*
