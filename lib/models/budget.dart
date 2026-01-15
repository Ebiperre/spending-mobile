class DailyBudget {
  final double budget;
  final double spent;
  final double remaining;
  final double percentUsed;
  final bool hasActiveCycle;

  DailyBudget({
    required this.budget,
    required this.spent,
    required this.remaining,
    required this.percentUsed,
    this.hasActiveCycle = false,
  });

  factory DailyBudget.fromJson(Map<String, dynamic> json) {
    return DailyBudget(
      budget: (json['budget'] ?? 0).toDouble(),
      spent: (json['spent'] ?? 0).toDouble(),
      remaining: (json['remaining'] ?? 0).toDouble(),
      percentUsed: (json['percentUsed'] ?? json['percent_used'] ?? 0).toDouble(),
      hasActiveCycle: json['hasActiveCycle'] ?? json['has_active_cycle'] ?? false,
    );
  }
}

class MonthlyBudget {
  final double budget;
  final double spent;
  final double remaining;
  final double percentUsed;
  final int daysRemaining;
  final double dailyBudgetRemaining;
  final Temperature temperature;
  final bool hasActiveCycle;
  final DateTime? cycleStart;
  final DateTime? cycleEnd;

  MonthlyBudget({
    required this.budget,
    required this.spent,
    required this.remaining,
    required this.percentUsed,
    required this.daysRemaining,
    required this.dailyBudgetRemaining,
    required this.temperature,
    this.hasActiveCycle = false,
    this.cycleStart,
    this.cycleEnd,
  });

  factory MonthlyBudget.fromJson(Map<String, dynamic> json) {
    return MonthlyBudget(
      budget: (json['budget'] ?? 0).toDouble(),
      spent: (json['spent'] ?? 0).toDouble(),
      remaining: (json['remaining'] ?? 0).toDouble(),
      percentUsed: (json['percentUsed'] ?? json['percent_used'] ?? 0).toDouble(),
      daysRemaining: json['daysRemaining'] ?? json['days_remaining'] ?? 0,
      dailyBudgetRemaining: (json['dailyBudgetRemaining'] ?? json['daily_budget_remaining'] ?? 0).toDouble(),
      temperature: Temperature.fromJson(json['temperature'] ?? {}),
      hasActiveCycle: json['hasActiveCycle'] ?? json['has_active_cycle'] ?? false,
      cycleStart: json['cycleStart'] != null
          ? DateTime.parse(json['cycleStart'])
          : (json['cycle_start'] != null ? DateTime.parse(json['cycle_start']) : null),
      cycleEnd: json['cycleEnd'] != null
          ? DateTime.parse(json['cycleEnd'])
          : (json['cycle_end'] != null ? DateTime.parse(json['cycle_end']) : null),
    );
  }
}

class Temperature {
  final String level; // cool, warm, hot, boiling, overheating
  final double percentage;

  Temperature({
    required this.level,
    required this.percentage,
  });

  factory Temperature.fromJson(Map<String, dynamic> json) {
    return Temperature(
      level: json['level'] ?? 'cool',
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }

  bool get isCool => level == 'cool';
  bool get isWarm => level == 'warm';
  bool get isHot => level == 'hot';
  bool get isBoiling => level == 'boiling';
  bool get isOverheating => level == 'overheating';
}

class SpendingCycle {
  final String id;
  final double dailyBudget;
  final double totalBudget;
  final DateTime startDate;
  final DateTime endDate;

  SpendingCycle({
    required this.id,
    required this.dailyBudget,
    required this.totalBudget,
    required this.startDate,
    required this.endDate,
  });

  factory SpendingCycle.fromJson(Map<String, dynamic> json) {
    return SpendingCycle(
      id: json['id'] ?? '',
      dailyBudget: (json['daily_budget'] ?? json['dailyBudget'] ?? 0).toDouble(),
      totalBudget: (json['total_budget'] ?? json['totalBudget'] ?? 0).toDouble(),
      startDate: DateTime.parse(json['start_date'] ?? json['startDate']),
      endDate: DateTime.parse(json['end_date'] ?? json['endDate']),
    );
  }

  int get daysInCycle => endDate.difference(startDate).inDays;
  int get daysPassed => DateTime.now().difference(startDate).inDays;
  int get daysRemaining => endDate.difference(DateTime.now()).inDays;
}
