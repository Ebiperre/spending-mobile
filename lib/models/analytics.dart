import 'package:spending_mobile/models/budget.dart';
import 'package:spending_mobile/models/user.dart';

class DashboardOverview {
  final bool hasActiveCycle;
  final CycleOverview? currentCycle;
  final Streak streak;
  final List<CategorySpending> topCategories;

  DashboardOverview({
    required this.hasActiveCycle,
    this.currentCycle,
    required this.streak,
    required this.topCategories,
  });

  factory DashboardOverview.fromJson(Map<String, dynamic> json) {
    return DashboardOverview(
      hasActiveCycle: json['hasActiveCycle'] ?? false,
      currentCycle: json['currentCycle'] != null
          ? CycleOverview.fromJson(json['currentCycle'])
          : null,
      streak: Streak.fromJson(json['streak'] ?? {}),
      topCategories: (json['topCategories'] as List<dynamic>?)
              ?.map((c) => CategorySpending.fromJson(c))
              .toList() ??
          [],
    );
  }
}

class CycleOverview {
  final double totalBudget;
  final double totalSpent;
  final double remaining;
  final double percentUsed;
  final int daysInCycle;
  final int daysPassed;
  final int daysRemaining;
  final double expectedSpend;
  final double actualVsExpected;
  final Temperature temperature;

  CycleOverview({
    required this.totalBudget,
    required this.totalSpent,
    required this.remaining,
    required this.percentUsed,
    required this.daysInCycle,
    required this.daysPassed,
    required this.daysRemaining,
    required this.expectedSpend,
    required this.actualVsExpected,
    required this.temperature,
  });

  factory CycleOverview.fromJson(Map<String, dynamic> json) {
    return CycleOverview(
      totalBudget: (json['totalBudget'] ?? 0).toDouble(),
      totalSpent: (json['totalSpent'] ?? 0).toDouble(),
      remaining: (json['remaining'] ?? 0).toDouble(),
      percentUsed: (json['percentUsed'] ?? 0).toDouble(),
      daysInCycle: json['daysInCycle'] ?? 0,
      daysPassed: json['daysPassed'] ?? 0,
      daysRemaining: json['daysRemaining'] ?? 0,
      expectedSpend: (json['expectedSpend'] ?? 0).toDouble(),
      actualVsExpected: (json['actualVsExpected'] ?? 0).toDouble(),
      temperature: Temperature.fromJson(json['temperature'] ?? {}),
    );
  }

  bool get isUnderBudget => actualVsExpected < 0;
  bool get isOverBudget => actualVsExpected > 0;
}

class CategorySpending {
  final String category;
  final double total;
  final int count;
  final double percentage;
  final double? average;

  CategorySpending({
    required this.category,
    required this.total,
    this.count = 0,
    required this.percentage,
    this.average,
  });

  factory CategorySpending.fromJson(Map<String, dynamic> json) {
    return CategorySpending(
      category: json['category'] ?? 'other',
      total: (json['total'] ?? 0).toDouble(),
      count: json['count'] ?? 0,
      percentage: (json['percentage'] ?? 0).toDouble(),
      average: json['average']?.toDouble(),
    );
  }
}

class SpendingTrend {
  final String period;
  final double total;
  final double average;
  final int count;

  SpendingTrend({
    required this.period,
    required this.total,
    required this.average,
    required this.count,
  });

  factory SpendingTrend.fromJson(Map<String, dynamic> json) {
    return SpendingTrend(
      period: json['period'] ?? '',
      total: (json['total'] ?? 0).toDouble(),
      average: (json['average'] ?? 0).toDouble(),
      count: json['count'] ?? 0,
    );
  }
}

class TrendDirection {
  final String direction; // up, down, stable
  final double percentChange;

  TrendDirection({
    required this.direction,
    required this.percentChange,
  });

  factory TrendDirection.fromJson(Map<String, dynamic> json) {
    return TrendDirection(
      direction: json['direction'] ?? 'stable',
      percentChange: (json['percentChange'] ?? 0).toDouble(),
    );
  }

  bool get isUp => direction == 'up';
  bool get isDown => direction == 'down';
  bool get isStable => direction == 'stable';
}

class WeeklyReport {
  final ReportPeriod period;
  final ReportSummary summary;
  final List<CategorySpending> categoryBreakdown;
  final List<DailyBreakdown> dailyBreakdown;

  WeeklyReport({
    required this.period,
    required this.summary,
    required this.categoryBreakdown,
    required this.dailyBreakdown,
  });

  factory WeeklyReport.fromJson(Map<String, dynamic> json) {
    return WeeklyReport(
      period: ReportPeriod.fromJson(json['period'] ?? {}),
      summary: ReportSummary.fromJson(json['summary'] ?? {}),
      categoryBreakdown: (json['categoryBreakdown'] as List<dynamic>?)
              ?.map((c) => CategorySpending.fromJson(c))
              .toList() ??
          [],
      dailyBreakdown: (json['dailyBreakdown'] as List<dynamic>?)
              ?.map((d) => DailyBreakdown.fromJson(d))
              .toList() ??
          [],
    );
  }
}

class ReportPeriod {
  final DateTime startDate;
  final DateTime endDate;
  final String type;

  ReportPeriod({
    required this.startDate,
    required this.endDate,
    required this.type,
  });

  factory ReportPeriod.fromJson(Map<String, dynamic> json) {
    return ReportPeriod(
      startDate: DateTime.parse(json['startDate'] ?? json['start_date'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json['endDate'] ?? json['end_date'] ?? DateTime.now().toIso8601String()),
      type: json['type'] ?? 'weekly',
    );
  }
}

class ReportSummary {
  final double totalSpent;
  final double totalBudget;
  final double savings;
  final double savingsRate;
  final double avgDailySpend;
  final CheckinStats checkins;

  ReportSummary({
    required this.totalSpent,
    required this.totalBudget,
    required this.savings,
    required this.savingsRate,
    required this.avgDailySpend,
    required this.checkins,
  });

  factory ReportSummary.fromJson(Map<String, dynamic> json) {
    return ReportSummary(
      totalSpent: (json['totalSpent'] ?? 0).toDouble(),
      totalBudget: (json['totalBudget'] ?? 0).toDouble(),
      savings: (json['savings'] ?? 0).toDouble(),
      savingsRate: (json['savingsRate'] ?? 0).toDouble(),
      avgDailySpend: (json['avgDailySpend'] ?? 0).toDouble(),
      checkins: CheckinStats.fromJson(json['checkins'] ?? {}),
    );
  }
}

class CheckinStats {
  final int total;
  final int under;
  final int exact;
  final int over;

  CheckinStats({
    required this.total,
    required this.under,
    required this.exact,
    required this.over,
  });

  factory CheckinStats.fromJson(Map<String, dynamic> json) {
    return CheckinStats(
      total: json['total'] ?? 0,
      under: json['under'] ?? 0,
      exact: json['exact'] ?? 0,
      over: json['over'] ?? 0,
    );
  }
}

class DailyBreakdown {
  final DateTime date;
  final double spent;
  final double budget;
  final String? status;

  DailyBreakdown({
    required this.date,
    required this.spent,
    required this.budget,
    this.status,
  });

  factory DailyBreakdown.fromJson(Map<String, dynamic> json) {
    return DailyBreakdown(
      date: DateTime.parse(json['date']),
      spent: (json['spent'] ?? 0).toDouble(),
      budget: (json['budget'] ?? 0).toDouble(),
      status: json['status'],
    );
  }
}
