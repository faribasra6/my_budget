class Expense {
  final int? id;
  final double amount;
  final String category;
  final String description;
  final DateTime date;
  final DateTime createdAt;
  final String currency;

  Expense({
    this.id,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
    required this.createdAt,
    required this.currency,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'description': description,
      'date': date.toIso8601String().split('T')[0],
      'created_at': createdAt.millisecondsSinceEpoch,
      'currency': currency,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      amount: map['amount'].toDouble(),
      category: map['category'],
      description: map['description'],
      date: DateTime.parse(map['date']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      currency: map['currency'] ?? 'USD',
    );
  }
}