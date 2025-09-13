import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/category.dart';
import '../widgets/app_drawer.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  List<ExpenseCategory> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      final categories = await DatabaseService.getAllCategories();
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error loading categories: ${e.toString()}', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(currentRoute: '/categories'),
      appBar: AppBar(
        title: const Text('Manage Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCategoryDialog(),
            tooltip: 'Add Category',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadCategories,
              child: _categories.isEmpty
                  ? _buildEmptyState()
                  : _buildCategoriesList(),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Categories Found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first category to get started',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showCategoryDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add Category'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getCategoryColor(index),
              child: Icon(
                _getCategoryIcon(category.icon),
                color: Colors.white,
                size: 20,
              ),
            ),
            title: Text(
              category.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: FutureBuilder<int>(
              future: DatabaseService.getExpenseCountByCategory(category.name),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final count = snapshot.data!;
                  return Text(
                    count == 0
                        ? 'No expenses'
                        : '$count expense${count == 1 ? '' : 's'}',
                    style: TextStyle(color: Colors.grey[600]),
                  );
                }
                return Text(
                  'Loading...',
                  style: TextStyle(color: Colors.grey[600]),
                );
              },
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) => _handleMenuAction(value, category),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Edit'),
                    dense: true,
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Delete', style: TextStyle(color: Colors.red)),
                    dense: true,
                  ),
                ),
              ],
            ),
            onTap: () => _showCategoryDialog(category: category),
          ),
        );
      },
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

  IconData _getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_car':
        return Icons.directions_car;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'movie':
        return Icons.movie;
      case 'receipt':
        return Icons.receipt;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'school':
        return Icons.school;
      case 'home':
        return Icons.home;
      case 'work':
        return Icons.work;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'pets':
        return Icons.pets;
      case 'flight':
        return Icons.flight;
      case 'local_gas_station':
        return Icons.local_gas_station;
      case 'phone':
        return Icons.phone;
      case 'wifi':
        return Icons.wifi;
      default:
        return Icons.category;
    }
  }

  void _handleMenuAction(String action, ExpenseCategory category) {
    switch (action) {
      case 'edit':
        _showCategoryDialog(category: category);
        break;
      case 'delete':
        _confirmDelete(category);
        break;
    }
  }

  Future<void> _confirmDelete(ExpenseCategory category) async {
    final isInUse = await DatabaseService.isCategoryInUse(category.id!);
    
    if (!mounted) return;

    if (isInUse) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cannot Delete Category'),
          content: Text(
            'The category "${category.name}" cannot be deleted because it has associated expenses. Please remove or reassign those expenses first.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _deleteCategory(category);
    }
  }

  Future<void> _deleteCategory(ExpenseCategory category) async {
    try {
      await DatabaseService.deleteCategory(category.id!);
      _loadCategories();
      _showSnackBar('Category "${category.name}" deleted successfully');
    } catch (e) {
      _showSnackBar('Error deleting category: ${e.toString()}', isError: true);
    }
  }

  void _showCategoryDialog({ExpenseCategory? category}) {
    final isEditing = category != null;
    final nameController = TextEditingController(text: category?.name ?? '');
    String selectedIcon = category?.icon ?? 'category';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit Category' : 'Add Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              Text(
                'Icon:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _getAvailableIcons().map((iconData) {
                  final iconName = _getIconName(iconData);
                  final isSelected = iconName == selectedIcon;
                  
                  return InkWell(
                    onTap: () {
                      setDialogState(() {
                        selectedIcon = iconName;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        iconData,
                        color: isSelected ? Colors.white : Colors.grey[700],
                        size: 24,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  _saveCategory(category, name, selectedIcon);
                  Navigator.pop(context);
                }
              },
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  List<IconData> _getAvailableIcons() {
    return [
      Icons.restaurant,
      Icons.directions_car,
      Icons.shopping_bag,
      Icons.movie,
      Icons.receipt,
      Icons.local_hospital,
      Icons.school,
      Icons.home,
      Icons.work,
      Icons.fitness_center,
      Icons.pets,
      Icons.flight,
      Icons.local_gas_station,
      Icons.phone,
      Icons.wifi,
      Icons.category,
    ];
  }

  String _getIconName(IconData iconData) {
    switch (iconData) {
      case Icons.restaurant:
        return 'restaurant';
      case Icons.directions_car:
        return 'directions_car';
      case Icons.shopping_bag:
        return 'shopping_bag';
      case Icons.movie:
        return 'movie';
      case Icons.receipt:
        return 'receipt';
      case Icons.local_hospital:
        return 'local_hospital';
      case Icons.school:
        return 'school';
      case Icons.home:
        return 'home';
      case Icons.work:
        return 'work';
      case Icons.fitness_center:
        return 'fitness_center';
      case Icons.pets:
        return 'pets';
      case Icons.flight:
        return 'flight';
      case Icons.local_gas_station:
        return 'local_gas_station';
      case Icons.phone:
        return 'phone';
      case Icons.wifi:
        return 'wifi';
      default:
        return 'category';
    }
  }

  Future<void> _saveCategory(ExpenseCategory? existingCategory, String name, String icon) async {
    try {
      if (existingCategory != null) {
        // Update existing category
        final updatedCategory = ExpenseCategory(
          id: existingCategory.id,
          name: name,
          icon: icon,
        );
        await DatabaseService.updateCategory(updatedCategory);
        _showSnackBar('Category updated successfully');
      } else {
        // Add new category
        final newCategory = ExpenseCategory(
          name: name,
          icon: icon,
        );
        await DatabaseService.insertCategory(newCategory);
        _showSnackBar('Category added successfully');
      }
      _loadCategories();
    } catch (e) {
      _showSnackBar('Error saving category: ${e.toString()}', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          duration: Duration(seconds: isError ? 4 : 2),
        ),
      );
    }
  }
}