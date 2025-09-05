class Budget {
  final int? id;
  final String month;
  final double budgetAmount;
  final DateTime createdAt;

  Budget({
    this.id,
    required this.month,
    required this.budgetAmount,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'month': month,
      'budget_amount': budgetAmount,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      month: map['month'],
      budgetAmount: map['budget_amount'].toDouble(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }
}