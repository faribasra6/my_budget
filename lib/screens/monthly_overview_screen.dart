import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';
import '../services/currency_service.dart';
import '../models/expense.dart';
import '../models/budget.dart';
import 'edit_expense_screen.dart';
import '../widgets/app_drawer.dart';

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
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    
    final selectedMonth = DateFormat('yyyy-MM').format(selectedDate);
    
    expenses = await DatabaseService.getExpensesForMonth(selectedMonth);
    currentBudget = await DatabaseService.getBudgetForMonth(selectedMonth);
    
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
    final isCurrentMonth = selectedDate.year == now.year && selectedDate.month == now.month;
    
    if (isCurrentMonth) {
      // Current month - show prediction
      final daysInMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0).day;
      final daysPassed = now.day;
      
      avgDaily = daysPassed > 0 ? totalSpent / daysPassed : 0;
      predictedMonthly = avgDaily * daysInMonth;
    } else {
      // Historical month - show actual totals
      final daysInMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0).day;
      avgDaily = daysInMonth > 0 ? totalSpent / daysInMonth : 0;
      predictedMonthly = totalSpent; // Already completed month
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      drawer: const AppDrawer(currentRoute: '/monthly'),
      appBar: AppBar(
        title: const Text('Monthly Overview'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _previousMonth,
                  tooltip: 'Previous Month',
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: _showMonthPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('MMMM yyyy').format(selectedDate),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.calendar_today, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _nextMonth,
                  tooltip: 'Next Month',
                ),
              ],
            ),
          ),
        ),
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
    final now = DateTime.now();
    final isCurrentMonth = selectedDate.year == now.year && selectedDate.month == now.month;
    final daysInMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0).day;
    final daysRemaining = isCurrentMonth ? daysInMonth - now.day : 0;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isCurrentMonth ? 'Spending Prediction' : 'Monthly Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('Daily Average', CurrencyService.formatAmount(avgDaily)),
                ),
                Expanded(
                  child: _buildStatItem(
                    isCurrentMonth ? 'Predicted Total' : 'Month Total', 
                    CurrencyService.formatAmount(predictedMonthly)
                  ),
                ),
                if (isCurrentMonth)
                  Expanded(
                    child: _buildStatItem('Days Left', daysRemaining.toString()),
                  )
                else
                  Expanded(
                    child: _buildStatItem('Days in Month', daysInMonth.toString()),
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
                        isCurrentMonth 
                            ? (predictedMonthly > currentBudget!.budgetAmount
                                ? 'You may exceed your budget by ${CurrencyService.formatAmount(predictedMonthly - currentBudget!.budgetAmount)}'
                                : 'You\'re on track to stay within budget!')
                            : (totalSpent > currentBudget!.budgetAmount
                                ? 'Budget exceeded by ${CurrencyService.formatAmount(totalSpent - currentBudget!.budgetAmount)}'
                                : 'Stayed within budget! ${CurrencyService.formatAmount(currentBudget!.budgetAmount - totalSpent)} left unused'),
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
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          CurrencyService.formatAmount(expense.amount),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.edit, size: 16, color: Colors.grey[600]),
                      ],
                    ),
                    onTap: () => _navigateToEditExpense(expense),
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

  Future<void> _navigateToEditExpense(Expense expense) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditExpenseScreen(expense: expense),
      ),
    );
    
    if (result == true) {
      _loadData(); // Refresh data if expense was updated or deleted
    }
  }

  void _previousMonth() {
    setState(() {
      selectedDate = DateTime(selectedDate.year, selectedDate.month - 1);
    });
    _loadData();
  }

  void _nextMonth() {
    final now = DateTime.now();
    final nextMonth = DateTime(selectedDate.year, selectedDate.month + 1);
    
    // Don't go beyond current month
    if (nextMonth.isBefore(DateTime(now.year, now.month + 1))) {
      setState(() {
        selectedDate = nextMonth;
      });
      _loadData();
    }
  }

  Future<void> _showMonthPicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(2020, 1); // Allow going back to 2020
    final lastDate = now;

    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDatePickerMode: DatePickerMode.year,
      helpText: 'Select Month and Year',
      fieldLabelText: 'Month/Year',
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = DateTime(picked.year, picked.month);
      });
      _loadData();
    }
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