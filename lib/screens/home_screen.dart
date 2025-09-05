import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';
import '../services/currency_service.dart';
import '../models/budget.dart';
import '../models/expense.dart';
import 'budget_setup_screen.dart';
import 'add_expense_screen.dart';
import 'monthly_overview_screen.dart';
import 'currency_selector_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Budget? currentBudget;
  double totalExpenses = 0.0;
  List<Expense> recentExpenses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    
    final currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
    
    currentBudget = await DatabaseService.getBudgetForMonth(currentMonth);
    totalExpenses = await DatabaseService.getTotalExpensesForMonth(currentMonth);
    
    final expenses = await DatabaseService.getExpensesForMonth(currentMonth);
    recentExpenses = expenses.take(5).toList();
    
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (currentBudget == null) {
      return BudgetSetupScreen(onBudgetSet: _loadData);
    }

    final remaining = currentBudget!.budgetAmount - totalExpenses;
    final progressPercentage = totalExpenses / currentBudget!.budgetAmount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MyBudget'),
        actions: [
          IconButton(
            icon: const Icon(Icons.currency_exchange),
            tooltip: 'Change Currency',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CurrencySelectorScreen()),
              );
              if (result == true && mounted) {
                setState(() {}); // Refresh to show new currency
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MonthlyOverviewScreen()),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBudgetCard(remaining, progressPercentage),
              const SizedBox(height: 24),
              _buildQuickActions(),
              const SizedBox(height: 24),
              _buildRecentExpenses(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddExpense(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBudgetCard(double remaining, double progressPercentage) {
    final currentMonth = DateFormat('MMMM yyyy').format(DateTime.now());
    final isOverBudget = remaining < 0;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              currentMonth,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Budget',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        CurrencyService.formatAmount(currentBudget!.budgetAmount),
                        style: Theme.of(context).textTheme.headlineSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Spent',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        CurrencyService.formatAmount(totalExpenses),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: isOverBudget ? Colors.red : null,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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
            const SizedBox(height: 8),
            Text(
              isOverBudget
                  ? 'Over budget by ${CurrencyService.formatAmount(-remaining)}'
                  : 'Remaining: ${CurrencyService.formatAmount(remaining)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isOverBudget ? Colors.red : Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _navigateToAddExpense(),
                icon: const Icon(Icons.add, size: 18),
                label: const Text(
                  'Add Expense',
                  overflow: TextOverflow.ellipsis,
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showSetBudgetDialog(),
                icon: const Icon(Icons.edit, size: 18),
                label: const Text(
                  'Edit Budget',
                  overflow: TextOverflow.ellipsis,
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentExpenses() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Expenses',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MonthlyOverviewScreen()),
              ),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        recentExpenses.isEmpty
            ? Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No expenses yet',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : Column(
                children: recentExpenses.map((expense) => Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Icon(_getCategoryIcon(expense.category)),
                    ),
                    title: Text(expense.description),
                    subtitle: Text('${expense.category} • ${DateFormat('MMM dd').format(expense.date)}'),
                    trailing: Text(
                      CurrencyService.formatAmount(expense.amount),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                )).toList(),
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

  Future<void> _navigateToAddExpense() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
    );
    _loadData();
  }

  Future<void> _showSetBudgetDialog() async {
    final controller = TextEditingController(
      text: currentBudget!.budgetAmount.toStringAsFixed(2),
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Monthly Budget'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Budget Amount',
            prefixText: '${CurrencyService.currencySymbol} ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final amount = double.tryParse(controller.text);
              if (amount != null && amount > 0) {
                final updatedBudget = Budget(
                  id: currentBudget!.id,
                  month: currentBudget!.month,
                  budgetAmount: amount,
                  createdAt: currentBudget!.createdAt,
                );
                await DatabaseService.updateBudget(updatedBudget);
                if (mounted) {
                  Navigator.pop(context);
                  _loadData();
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}