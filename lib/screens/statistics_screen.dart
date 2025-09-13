import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/currency_service.dart';
import '../widgets/app_drawer.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool _isLoading = true;
  double _weeklyAverage = 0.0;
  double _dailyAverage = 0.0;
  double _currentWeekTotal = 0.0;
  List<Map<String, dynamic>> _topCategories = [];
  Map<String, double> _monthlyComparison = {};

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        DatabaseService.getWeeklyAverage(),
        DatabaseService.getDailyAverage(),
        DatabaseService.getCurrentWeekExpenses(),
        DatabaseService.getTopSpendingCategories(),
        DatabaseService.getMonthlyComparison(),
      ]);

      setState(() {
        _weeklyAverage = results[0] as double;
        _dailyAverage = results[1] as double;
        _currentWeekTotal = results[2] as double;
        _topCategories = results[3] as List<Map<String, dynamic>>;
        _monthlyComparison = results[4] as Map<String, double>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(currentRoute: '/statistics'),
      appBar: AppBar(
        title: const Text('Statistics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatistics,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStatistics,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSpendingOverview(),
                    const SizedBox(height: 24),
                    _buildAveragesSection(),
                    const SizedBox(height: 24),
                    _buildTopCategories(),
                    const SizedBox(height: 24),
                    _buildMonthlyComparison(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSpendingOverview() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'This Week',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Spent',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyService.formatAmount(_currentWeekTotal),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getCurrentWeekStatus() == 'Over' 
                        ? Colors.red[100] 
                        : Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getCurrentWeekStatus(),
                    style: TextStyle(
                      color: _getCurrentWeekStatus() == 'Over' 
                          ? Colors.red[700] 
                          : Colors.green[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'vs ${CurrencyService.formatAmount(_weeklyAverage)} weekly average',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCurrentWeekStatus() {
    if (_weeklyAverage == 0) return 'No Data';
    return _currentWeekTotal > _weeklyAverage ? 'Over' : 'Under';
  }

  Widget _buildAveragesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Spending Averages',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildAverageItem(
                    'Daily Average',
                    _dailyAverage,
                    Icons.today,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildAverageItem(
                    'Weekly Average',
                    _weeklyAverage,
                    Icons.date_range,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAverageItem(String title, double amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyService.formatAmount(amount),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopCategories() {
    if (_topCategories.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(Icons.category, color: Colors.grey[400], size: 48),
              const SizedBox(height: 8),
              Text(
                'No spending data available',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.leaderboard, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Top Categories This Month',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            for (final entry in _topCategories.asMap().entries) ...[
              Builder(builder: (context) {
                final index = entry.key;
                final category = entry.value;
                final total = category['total'] as double;
                final maxAmount = _topCategories.first['total'] as double;
                final percentage = maxAmount > 0 ? (total / maxAmount) : 0.0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: _getCategoryColor(index),
                            child: Icon(
                              _getCategoryIcon(category['category']),
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category['category'],
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                Text(
                                  '${category['count']} expenses',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            CurrencyService.formatAmount(total),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: percentage,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation(_getCategoryColor(index)),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyComparison() {
    final currentMonth = _monthlyComparison['currentMonth'] ?? 0.0;
    final lastMonth = _monthlyComparison['lastMonth'] ?? 0.0;
    final difference = currentMonth - lastMonth;
    final percentageChange = lastMonth > 0 ? (difference / lastMonth * 100) : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.compare, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Monthly Comparison',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'This Month',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyService.formatAmount(currentMonth),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Last Month',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyService.formatAmount(lastMonth),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: difference > 0 ? Colors.red[50] : Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: difference > 0 ? Colors.red[200]! : Colors.green[200]!,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    difference > 0 ? Icons.trending_up : Icons.trending_down,
                    color: difference > 0 ? Colors.red[700] : Colors.green[700],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      difference > 0 
                          ? 'Spending increased by ${CurrencyService.formatAmount(difference.abs())} (${percentageChange.abs().toStringAsFixed(1)}%)'
                          : 'Spending decreased by ${CurrencyService.formatAmount(difference.abs())} (${percentageChange.abs().toStringAsFixed(1)}%)',
                      style: TextStyle(
                        color: difference > 0 ? Colors.red[700] : Colors.green[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.amber,
      Colors.indigo,
    ];
    return colors[index % colors.length];
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
        return Icons.category;
    }
  }
}