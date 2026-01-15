class User {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String? gender;
  final String? ageRange;
  final String languagePreference;
  final bool isActive;
  final DateTime? lastLogin;
  final DateTime createdAt;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.gender,
    this.ageRange,
    this.languagePreference = 'mix',
    this.isActive = true,
    this.lastLogin,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      gender: json['gender'],
      ageRange: json['age_range'] ?? json['ageRange'],
      languagePreference: json['language_preference'] ?? json['languagePreference'] ?? 'mix',
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'])
          : (json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : (json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'gender': gender,
      'age_range': ageRange,
      'language_preference': languagePreference,
      'is_active': isActive,
      'last_login': lastLogin?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class FinancialProfile {
  final String? id;
  final String userId;
  final double monthlyIncome;
  final int salaryDay;
  final double rent;
  final double transport;
  final double bills;
  final double savingsTarget;
  final double otherFixed;
  final double spendableAmount;

  FinancialProfile({
    this.id,
    required this.userId,
    required this.monthlyIncome,
    required this.salaryDay,
    this.rent = 0,
    this.transport = 0,
    this.bills = 0,
    this.savingsTarget = 0,
    this.otherFixed = 0,
    required this.spendableAmount,
  });

  factory FinancialProfile.fromJson(Map<String, dynamic> json) {
    return FinancialProfile(
      id: json['id'],
      userId: json['user_id'] ?? json['userId'] ?? '',
      monthlyIncome: (json['monthly_income'] ?? json['monthlyIncome'] ?? 0).toDouble(),
      salaryDay: json['salary_day'] ?? json['salaryDay'] ?? 25,
      rent: (json['rent'] ?? 0).toDouble(),
      transport: (json['transport'] ?? 0).toDouble(),
      bills: (json['bills'] ?? 0).toDouble(),
      savingsTarget: (json['savings_target'] ?? json['savingsTarget'] ?? 0).toDouble(),
      otherFixed: (json['other_fixed'] ?? json['otherFixed'] ?? 0).toDouble(),
      spendableAmount: (json['spendable_amount'] ?? json['spendableAmount'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'monthly_income': monthlyIncome,
      'salary_day': salaryDay,
      'rent': rent,
      'transport': transport,
      'bills': bills,
      'savings_target': savingsTarget,
      'other_fixed': otherFixed,
    };
  }

  double get totalFixedExpenses => rent + transport + bills + savingsTarget + otherFixed;
  double get dailyBudget => spendableAmount / 30;
}

class Streak {
  final int currentStreak;
  final int longestStreak;

  Streak({
    required this.currentStreak,
    required this.longestStreak,
  });

  factory Streak.fromJson(Map<String, dynamic> json) {
    return Streak(
      currentStreak: json['current_streak'] ?? json['currentStreak'] ?? json['current'] ?? 0,
      longestStreak: json['longest_streak'] ?? json['longestStreak'] ?? json['longest'] ?? 0,
    );
  }
}
