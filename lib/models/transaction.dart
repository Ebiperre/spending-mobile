class Transaction {
  final String id;
  final double amount;
  final String category;
  final String? description;
  final DateTime transactionDate;
  final String type; // 'income' or 'expense'
  final DateTime createdAt;
  final String? syncStatus; // 'synced', 'pending', 'failed', 'deleted'

  Transaction({
    required this.id,
    required this.amount,
    required this.category,
    this.description,
    required this.transactionDate,
    this.type = 'expense',
    required this.createdAt,
    this.syncStatus,
  });

  // Convenience getter for date (alias for transactionDate)
  DateTime get date => transactionDate;

  // Check if transaction is pending sync
  bool get isPendingSync => syncStatus == 'pending';

  // Check if transaction sync failed
  bool get isSyncFailed => syncStatus == 'failed';

  // Check if transaction is synced
  bool get isSynced => syncStatus == 'synced' || syncStatus == null;

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      category: json['category'] ?? 'other',
      description: json['description'],
      transactionDate: json['transaction_date'] != null
          ? DateTime.parse(json['transaction_date'])
          : (json['transactionDate'] != null
              ? DateTime.parse(json['transactionDate'])
              : (json['date'] != null ? DateTime.parse(json['date']) : DateTime.now())),
      type: json['type'] ?? 'expense',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : (json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'category': category,
      'description': description,
      'date': transactionDate.toIso8601String(),
      'type': type,
    };
  }

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';
}

class RecurringTransaction {
  final String id;
  final double amount;
  final String category;
  final String? description;
  final String frequency; // daily, weekly, biweekly, monthly
  final int? dayOfMonth;
  final int? dayOfWeek;
  final bool isActive;
  final DateTime? nextOccurrence;
  final DateTime createdAt;

  RecurringTransaction({
    required this.id,
    required this.amount,
    required this.category,
    this.description,
    required this.frequency,
    this.dayOfMonth,
    this.dayOfWeek,
    this.isActive = true,
    this.nextOccurrence,
    required this.createdAt,
  });

  factory RecurringTransaction.fromJson(Map<String, dynamic> json) {
    return RecurringTransaction(
      id: json['id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      category: json['category'] ?? 'other',
      description: json['description'],
      frequency: json['frequency'] ?? 'monthly',
      dayOfMonth: json['day_of_month'] ?? json['dayOfMonth'],
      dayOfWeek: json['day_of_week'] ?? json['dayOfWeek'],
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      nextOccurrence: json['next_occurrence'] != null
          ? DateTime.parse(json['next_occurrence'])
          : (json['nextOccurrence'] != null ? DateTime.parse(json['nextOccurrence']) : null),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : (json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'category': category,
      'description': description,
      'frequency': frequency,
      'day_of_month': dayOfMonth,
    };
  }
}

class TransactionPagination {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  TransactionPagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory TransactionPagination.fromJson(Map<String, dynamic> json) {
    return TransactionPagination(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      total: json['total'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
    );
  }

  bool get hasNextPage => page < totalPages;
  bool get hasPreviousPage => page > 1;
}
