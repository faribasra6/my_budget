import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/budget.dart';
import '../models/expense.dart';
import '../models/category.dart';

class DatabaseService {
  static Database? _database;
  static const String _databaseName = 'my_budget.db';
  static const int _databaseVersion = 2;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE budgets(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        month TEXT NOT NULL UNIQUE,
        budget_amount REAL NOT NULL,
        created_at INTEGER NOT NULL,
        currency TEXT NOT NULL DEFAULT 'USD'
      )
    ''');

    await db.execute('''
      CREATE TABLE expenses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        description TEXT NOT NULL,
        date TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        currency TEXT NOT NULL DEFAULT 'USD'
      )
    ''');

    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        icon TEXT NOT NULL
      )
    ''');

    await _insertDefaultCategories(db);
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        // Add currency column to budgets table (nullable first, then update)
        await db.execute('ALTER TABLE budgets ADD COLUMN currency TEXT');
        await db.execute('UPDATE budgets SET currency = "USD" WHERE currency IS NULL');
        
        // Add currency column to expenses table (nullable first, then update)
        await db.execute('ALTER TABLE expenses ADD COLUMN currency TEXT');
        await db.execute('UPDATE expenses SET currency = "USD" WHERE currency IS NULL');
        
        print('Database migration from version $oldVersion to $newVersion completed successfully');
      } catch (e) {
        print('Database migration failed: $e');
        // In case of migration failure, we could implement recovery logic here
        rethrow;
      }
    }
  }

  static Future<void> _insertDefaultCategories(Database db) async {
    final defaultCategories = [
      {'name': 'Food', 'icon': 'restaurant'},
      {'name': 'Transportation', 'icon': 'directions_car'},
      {'name': 'Shopping', 'icon': 'shopping_bag'},
      {'name': 'Entertainment', 'icon': 'movie'},
      {'name': 'Bills', 'icon': 'receipt'},
      {'name': 'Health', 'icon': 'local_hospital'},
      {'name': 'Education', 'icon': 'school'},
      {'name': 'Other', 'icon': 'more_horiz'},
    ];

    for (var category in defaultCategories) {
      await db.insert('categories', category);
    }
  }

  // Budget operations
  static Future<int> insertBudget(Budget budget) async {
    final db = await database;
    return await db.insert('budgets', budget.toMap());
  }

  static Future<Budget?> getBudgetForMonth(String month) async {
    final db = await database;
    final maps = await db.query(
      'budgets',
      where: 'month = ?',
      whereArgs: [month],
    );
    
    if (maps.isEmpty) return null;
    return Budget.fromMap(maps.first);
  }

  static Future<List<Budget>> getAllBudgets() async {
    final db = await database;
    final maps = await db.query('budgets', orderBy: 'month DESC');
    return List.generate(maps.length, (i) => Budget.fromMap(maps[i]));
  }

  static Future<int> updateBudget(Budget budget) async {
    final db = await database;
    return await db.update(
      'budgets',
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  // Expense operations
  static Future<int> insertExpense(Expense expense) async {
    final db = await database;
    return await db.insert('expenses', expense.toMap());
  }

  static Future<List<Expense>> getExpensesForMonth(String month) async {
    final db = await database;
    final maps = await db.query(
      'expenses',
      where: 'date LIKE ?',
      whereArgs: ['$month%'],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  static Future<List<Expense>> getExpensesForDateRange(DateTime start, DateTime end) async {
    final db = await database;
    final startDate = start.toIso8601String().split('T')[0];
    final endDate = end.toIso8601String().split('T')[0];
    
    final maps = await db.query(
      'expenses',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDate, endDate],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  static Future<double> getTotalExpensesForMonth(String month) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM expenses WHERE date LIKE ?',
      ['$month%'],
    );
    return (result.first['total'] as double?) ?? 0.0;
  }

  static Future<double> getWeeklyAverage() async {
    final db = await database;
    final now = DateTime.now();
    final fourWeeksAgo = now.subtract(const Duration(days: 28));
    
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM expenses WHERE date >= ? AND date <= ?',
      [fourWeeksAgo.toIso8601String().split('T')[0], now.toIso8601String().split('T')[0]],
    );
    
    final total = (result.first['total'] as double?) ?? 0.0;
    return total / 4; // 4 weeks
  }

  static Future<double> getCurrentWeekExpenses() async {
    final db = await database;
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1)); // Monday
    
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM expenses WHERE date >= ? AND date <= ?',
      [startOfWeek.toIso8601String().split('T')[0], now.toIso8601String().split('T')[0]],
    );
    
    return (result.first['total'] as double?) ?? 0.0;
  }

  static Future<List<Map<String, dynamic>>> getTopSpendingCategories({int limit = 5}) async {
    final db = await database;
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    
    final result = await db.rawQuery(
      '''
      SELECT category, SUM(amount) as total, COUNT(*) as count 
      FROM expenses 
      WHERE date >= ? 
      GROUP BY category 
      ORDER BY total DESC 
      LIMIT ?
      ''',
      [startOfMonth.toIso8601String().split('T')[0], limit],
    );
    
    return result;
  }

  static Future<double> getDailyAverage({int days = 30}) async {
    final db = await database;
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
    
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM expenses WHERE date >= ? AND date <= ?',
      [startDate.toIso8601String().split('T')[0], now.toIso8601String().split('T')[0]],
    );
    
    final total = (result.first['total'] as double?) ?? 0.0;
    return total / days;
  }

  static Future<Map<String, double>> getMonthlyComparison() async {
    final db = await database;
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);
    final lastMonth = DateTime(now.year, now.month - 1, 1);
    
    // Current month total
    final currentResult = await db.rawQuery(
      'SELECT SUM(amount) as total FROM expenses WHERE date >= ? AND date < ?',
      [currentMonth.toIso8601String().split('T')[0], 
       DateTime(now.year, now.month + 1, 1).toIso8601String().split('T')[0]],
    );
    
    // Last month total
    final lastResult = await db.rawQuery(
      'SELECT SUM(amount) as total FROM expenses WHERE date >= ? AND date < ?',
      [lastMonth.toIso8601String().split('T')[0], currentMonth.toIso8601String().split('T')[0]],
    );
    
    return {
      'currentMonth': (currentResult.first['total'] as double?) ?? 0.0,
      'lastMonth': (lastResult.first['total'] as double?) ?? 0.0,
    };
  }

  static Future<int> updateExpense(Expense expense) async {
    final db = await database;
    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  static Future<int> deleteExpense(int id) async {
    final db = await database;
    return await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  // Category operations
  static Future<List<ExpenseCategory>> getAllCategories() async {
    final db = await database;
    final maps = await db.query('categories', orderBy: 'name');
    return List.generate(maps.length, (i) => ExpenseCategory.fromMap(maps[i]));
  }

  static Future<int> insertCategory(ExpenseCategory category) async {
    final db = await database;
    return await db.insert('categories', category.toMap());
  }

  static Future<int> updateCategory(ExpenseCategory category) async {
    final db = await database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  static Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  static Future<bool> isCategoryInUse(int categoryId) async {
    final db = await database;
    final category = await db.query('categories', where: 'id = ?', whereArgs: [categoryId]);
    if (category.isEmpty) return false;
    
    final categoryName = category.first['name'] as String;
    final result = await db.query('expenses', where: 'category = ?', whereArgs: [categoryName], limit: 1);
    return result.isNotEmpty;
  }

  static Future<int> getExpenseCountByCategory(String categoryName) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM expenses WHERE category = ?',
      [categoryName],
    );
    return (result.first['count'] as int?) ?? 0;
  }
}