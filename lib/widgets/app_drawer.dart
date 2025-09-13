import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/monthly_overview_screen.dart';
import '../screens/statistics_screen.dart';
import '../screens/currency_selector_screen.dart';
import '../screens/add_expense_screen.dart';
import '../screens/category_management_screen.dart';
import '../services/currency_service.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;
  
  const AppDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          _buildDrawerHeader(context),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuSection(
                  context,
                  title: 'OVERVIEW',
                  items: [
                    _DrawerItem(
                      icon: Icons.dashboard,
                      title: 'Dashboard',
                      route: '/',
                      onTap: () => _navigateTo(context, const HomeScreen()),
                    ),
                    _DrawerItem(
                      icon: Icons.calendar_month,
                      title: 'Monthly Overview',
                      route: '/monthly',
                      onTap: () => _navigateTo(context, const MonthlyOverviewScreen()),
                    ),
                    _DrawerItem(
                      icon: Icons.analytics,
                      title: 'Statistics',
                      route: '/statistics',
                      onTap: () => _navigateTo(context, const StatisticsScreen()),
                    ),
                  ],
                ),
                _buildMenuSection(
                  context,
                  title: 'EXPENSES',
                  items: [
                    _DrawerItem(
                      icon: Icons.add_circle,
                      title: 'Add Expense',
                      route: '/add-expense',
                      onTap: () => _showAddExpenseDialog(context),
                    ),
                    _DrawerItem(
                      icon: Icons.category,
                      title: 'Categories',
                      route: '/categories',
                      onTap: () => _navigateTo(context, const CategoryManagementScreen()),
                    ),
                  ],
                ),
                _buildMenuSection(
                  context,
                  title: 'REPORTS & DATA',
                  items: [
                    _DrawerItem(
                      icon: Icons.file_download,
                      title: 'Export Data',
                      route: '/export',
                      onTap: () => _showComingSoon(context, 'Export Data'),
                    ),
                    _DrawerItem(
                      icon: Icons.backup,
                      title: 'Backup & Restore',
                      route: '/backup',
                      onTap: () => _showComingSoon(context, 'Backup & Restore'),
                    ),
                  ],
                ),
                _buildMenuSection(
                  context,
                  title: 'SETTINGS',
                  items: [
                    _DrawerItem(
                      icon: Icons.currency_exchange,
                      title: 'Currency',
                      subtitle: CurrencyService.selectedCurrency.name,
                      route: '/currency',
                      onTap: () => _navigateTo(context, const CurrencySelectorScreen()),
                    ),
                    _DrawerItem(
                      icon: Icons.account_balance_wallet,
                      title: 'Budget Settings',
                      route: '/budget-settings',
                      onTap: () => _showComingSoon(context, 'Budget Settings'),
                    ),
                    _DrawerItem(
                      icon: Icons.notifications,
                      title: 'Notifications',
                      route: '/notifications',
                      onTap: () => _showComingSoon(context, 'Notification Settings'),
                    ),
                  ],
                ),
                const Divider(),
                _buildDrawerItem(
                  context,
                  _DrawerItem(
                    icon: Icons.info_outline,
                    title: 'About',
                    route: '/about',
                    onTap: () => _showAboutDialog(context),
                  ),
                ),
                _buildDrawerItem(
                  context,
                  _DrawerItem(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    route: '/help',
                    onTap: () => _showComingSoon(context, 'Help & Support'),
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerFooter(context),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MyBudget',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Personal Finance Tracker',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(
    BuildContext context, {
    required String title,
    required List<_DrawerItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...items.map((item) => _buildDrawerItem(context, item)),
      ],
    );
  }

  Widget _buildDrawerItem(BuildContext context, _DrawerItem item) {
    final isSelected = currentRoute == item.route;
    
    return ListTile(
      leading: Icon(
        item.icon,
        color: isSelected 
            ? Theme.of(context).colorScheme.primary 
            : Colors.grey[600],
      ),
      title: Text(
        item.title,
        style: TextStyle(
          color: isSelected 
              ? Theme.of(context).colorScheme.primary 
              : Colors.grey[800],
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      subtitle: item.subtitle != null 
          ? Text(
              item.subtitle!,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            )
          : null,
      selected: isSelected,
      selectedTileColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
      onTap: item.onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
    );
  }

  Widget _buildDrawerFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.apps, color: Colors.grey[600], size: 16),
          const SizedBox(width: 8),
          Text(
            'MyBudget v1.3.0',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const Spacer(),
          Text(
            '© 2024',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.pop(context); // Close drawer
    
    // Use regular push for better navigation stack management
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  void _showAddExpenseDialog(BuildContext context) {
    Navigator.pop(context); // Close drawer
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    Navigator.pop(context); // Close drawer
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Coming Soon!'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    Navigator.pop(context); // Close drawer
    showAboutDialog(
      context: context,
      applicationName: 'MyBudget',
      applicationVersion: '1.2.1',
      applicationIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.account_balance_wallet,
          color: Colors.white,
          size: 24,
        ),
      ),
      children: [
        const Text('A modern, intuitive personal finance tracker built with Flutter.'),
        const SizedBox(height: 16),
        const Text('Features:'),
        const Text('• Multi-currency support'),
        const Text('• Monthly budget tracking'),
        const Text('• Expense categorization'),
        const Text('• Statistical insights'),
        const Text('• Historical data browsing'),
        const SizedBox(height: 16),
        const Text('Built with ❤️ using Flutter'),
      ],
    );
  }
}

class _DrawerItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String route;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.route,
    required this.onTap,
  });
}