import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common/src/exception.dart' as sqflite_exception;
import '../../../core/error/exceptions.dart' as app_exceptions;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      String path = join(await getDatabasesPath(), 'student_budget_tracker.db');
      return await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
      );
    } catch (e) {
      throw app_exceptions.DatabaseException('Failed to initialize database: ${e.toString()}');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create expenses table
    await db.execute('''
      CREATE TABLE expenses(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        date INTEGER NOT NULL,
        category TEXT NOT NULL,
        notes TEXT
      )
    ''');

    // Create budget table
    await db.execute('''
      CREATE TABLE budgets(
        id TEXT PRIMARY KEY,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        startDate INTEGER NOT NULL,
        endDate INTEGER NOT NULL,
        isActive INTEGER NOT NULL
      )
    ''');

    // Create categories table
    await db.execute('''
      CREATE TABLE categories(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        color INTEGER NOT NULL,
        iconCodePoint INTEGER NOT NULL,
        iconFontFamily TEXT,
        iconFontPackage TEXT,
        isDefault INTEGER NOT NULL,
        isVisible INTEGER NOT NULL
      )
    ''');

    // Create savings goals table
    await db.execute('''
      CREATE TABLE savings_goals(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        targetAmount REAL NOT NULL,
        currentAmount REAL NOT NULL,
        createdDate INTEGER NOT NULL,
        targetDate INTEGER NOT NULL,
        notes TEXT,
        isCompleted INTEGER NOT NULL
      )
    ''');
  }

  // Generic methods for CRUD operations

  Future<int> insert(String table, Map<String, dynamic> data) async {
    try {
      Database db = await database;
      return await db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      throw app_exceptions.DatabaseException('Failed to insert data: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> queryAllRows(String table) async {
    try {
      Database db = await database;
      return await db.query(table);
    } catch (e) {
      throw app_exceptions.DatabaseException('Failed to query data: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> queryWithCondition(String table, String whereClause, List<dynamic> whereArgs) async {
    try {
      Database db = await database;
      return await db.query(table, where: whereClause, whereArgs: whereArgs);
    } catch (e) {
      throw app_exceptions.DatabaseException('Failed to query data with condition: ${e.toString()}');
    }
  }

  Future<int> update(String table, Map<String, dynamic> data, String idField) async {
    try {
      Database db = await database;
      return await db.update(
        table,
        data,
        where: '$idField = ?',
        whereArgs: [data[idField]],
      );
    } catch (e) {
      throw app_exceptions.DatabaseException('Failed to update data: ${e.toString()}');
    }
  }

  Future<int> delete(String table, String idField, String id) async {
    try {
      Database db = await database;
      return await db.delete(
        table,
        where: '$idField = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw app_exceptions.DatabaseException('Failed to delete data: ${e.toString()}');
    }
  }

  Future<int> deleteAll(String table) async {
    try {
      Database db = await database;
      return await db.delete(table);
    } catch (e) {
      throw app_exceptions.DatabaseException('Failed to delete all data: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<dynamic>? arguments]) async {
    try {
      Database db = await database;
      return await db.rawQuery(sql, arguments);
    } catch (e) {
      throw app_exceptions.DatabaseException('Failed to execute raw query: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> queryWithLimit(
      String table, {
        String? orderBy,
        int? limit,
      }) async {
    try {
      final db = await database;
      return await db.query(
        table,
        orderBy: orderBy,
        limit: limit,
      );
    } catch (e) {
      throw app_exceptions.DatabaseException('Failed to query with limit: ${e.toString()}');
    }
  }

  // Close the database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}