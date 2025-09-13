class Budget {
  final int? id;
  final String month;
  final double budgetAmount;
  final DateTime createdAt;
  final String currency;

  Budget({
    this.id,
    required this.month,
    required this.budgetAmount,
    required this.createdAt,
    required this.currency,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'month': month,
      'budget_amount': budgetAmount,
      'created_at': createdAt.millisecondsSinceEpoch,
      'currency': currency,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      month: map['month'],
      budgetAmount: map['budget_amount'].toDouble(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      currency: map['currency'] ?? 'USD',
    );
  }
}