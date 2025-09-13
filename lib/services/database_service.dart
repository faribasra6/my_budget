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
      await db.execute('ALTER TABLE budgets ADD COLUMN currency TEXT NOT NULL DEFAULT "USD"');
      await db.execute('ALTER TABLE expenses ADD COLUMN currency TEXT NOT NULL DEFAULT "USD"');
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
}