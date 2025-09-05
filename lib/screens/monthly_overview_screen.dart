import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';
import '../services/currency_service.dart';
import '../models/expense.dart';
import '../models/budget.dart';

class MonthlyOverviewScreen extends StatefulWidget {
  const MonthlyOverviewScreen({super.key});

  @override
  State<MonthlyOverviewScreen> createState() => _MonthlyOverviewScreenState();
}

class _MonthlyOverviewScreenState extends State<MonthlyOverviewScreen> {
  List<Expense> expenses = [];
  Budget? currentBudget;
  Map<String, double> categoryTotals = {};
  double totalSpent = 0.0;
  double avgDaily = 0.0;
  double predictedMonthly = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    
    final currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
    
    expenses = await DatabaseService.getExpensesForMonth(currentMonth);
    currentBudget = await DatabaseService.getBudgetForMonth(currentMonth);
    
    _calculateStats();
    
    setState(() => isLoading = false);
  }

  void _calculateStats() {
    categoryTotals.clear();
    totalSpent = 0.0;
    
    for (var expense in expenses) {
      totalSpent += expense.amount;
      categoryTotals[expense.category] = (categoryTotals[expense.category] ?? 0) + expense.amount;
    }
    
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysPassed = now.day;
    
    avgDaily = daysPassed > 0 ? totalSpent / daysPassed : 0;
    predictedMonthly = avgDaily * daysInMonth;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${DateFormat('MMMM yyyy').format(DateTime.now())} Overview'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (currentBudget != null) _buildBudgetSummary(),
            const SizedBox(height: 24),
            _buildPredictionCard(),
            const SizedBox(height: 24),
            _buildCategoryBreakdown(),
            const SizedBox(height: 24),
            _buildExpensesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetSummary() {
    final remaining = currentBudget!.budgetAmount - totalSpent;
    final isOverBudget = remaining < 0;
    final progressPercentage = totalSpent / currentBudget!.budgetAmount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Budget Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('Budget', CurrencyService.formatAmount(currentBudget!.budgetAmount)),
                ),
                Expanded(
                  child: _buildStatItem('Spent', CurrencyService.formatAmount(totalSpent)),
                ),
                Expanded(
                  child: _buildStatItem(
                    isOverBudget ? 'Over by' : 'Remaining',
                    CurrencyService.formatAmount(remaining.abs()),
                    color: isOverBudget ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progressPercentage > 1 ? 1 : progressPercentage,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverBudget ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionCard() {
    final currentMonth = DateTime.now();
    final daysInMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    final daysRemaining = daysInMonth - currentMonth.day;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spending Prediction',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('Daily Average', CurrencyService.formatAmount(avgDaily)),
                ),
                Expanded(
                  child: _buildStatItem('Predicted Total', CurrencyService.formatAmount(predictedMonthly)),
                ),
                Expanded(
                  child: _buildStatItem('Days Left', daysRemaining.toString()),
                ),
              ],
            ),
            if (currentBudget != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: predictedMonthly > currentBudget!.budgetAmount 
                      ? Colors.red[50] 
                      : Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      predictedMonthly > currentBudget!.budgetAmount 
                          ? Icons.warning 
                          : Icons.check_circle,
                      color: predictedMonthly > currentBudget!.budgetAmount 
                          ? Colors.red 
                          : Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        predictedMonthly > currentBudget!.budgetAmount
                            ? 'You may exceed your budget by ${CurrencyService.formatAmount(predictedMonthly - currentBudget!.budgetAmount)}'
                            : 'You\'re on track to stay within budget!',
                        style: TextStyle(
                          color: predictedMonthly > currentBudget!.budgetAmount 
                              ? Colors.red[700] 
                              : Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown() {
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category Breakdown',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (sortedCategories.isEmpty)
              const Center(
                child: Text('No expenses to show'),
              )
            else
              Column(
                children: sortedCategories.map((entry) {
                  final percentage = totalSpent > 0 ? (entry.value / totalSpent) * 100 : 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Icon(_getCategoryIcon(entry.key)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(entry.key),
                              LinearProgressIndicator(
                                value: percentage / 100,
                                backgroundColor: Colors.grey[300],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              CurrencyService.formatAmount(entry.value),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${percentage.toStringAsFixed(1)}%',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpensesList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'All Expenses (${expenses.length})',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (expenses.isEmpty)
              const Center(
                child: Text('No expenses to show'),
              )
            else
              Column(
                children: expenses.map((expense) => Dismissible(
                  key: Key(expense.id.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Expense'),
                        content: const Text('Are you sure you want to delete this expense?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (direction) async {
                    await DatabaseService.deleteExpense(expense.id!);
                    _loadData();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Expense deleted')),
                      );
                    }
                  },
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Icon(_getCategoryIcon(expense.category)),
                    ),
                    title: Text(expense.description),
                    subtitle: Text('${expense.category} • ${DateFormat('MMM dd, yyyy').format(expense.date)}'),
                    trailing: Text(
                      CurrencyService.formatAmount(expense.amount),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                )).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'transportation':
        return Icons.directions_car;
      case 'shopping':
        return Icons.shopping_bag;
      case 'entertainment':
        return Icons.movie;
      case 'bills':
        return Icons.receipt;
      case 'health':
        return Icons.local_hospital;
      case 'education':
        return Icons.school;
      default:
        return Icons.more_horiz;
    }
  }
}