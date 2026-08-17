import 'package:flutter_laundry_offline_app/data/models/expense_entry.dart';
import 'package:flutter_laundry_offline_app/data/database/database_helper.dart';

class ExpenseRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  final String _tableName = 'expenses';

  Future<List<ExpenseEntry>> getAllExpenses() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      orderBy: 'tanggal DESC, created_at DESC',
    );
    return maps.map((map) => ExpenseEntry.fromMap(map)).toList();
  }

  Future<ExpenseEntry?> getExpenseById(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return ExpenseEntry.fromMap(maps.first);
    }
    return null;
  }

  Future<int> createExpense(ExpenseEntry entry) async {
    final db = await _databaseHelper.database;
    return await db.insert(_tableName, entry.toMap());
  }

  Future<int> updateExpense(ExpenseEntry entry) async {
    final db = await _databaseHelper.database;
    return await db.update(
      _tableName,
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deleteExpense(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<ExpenseEntry>> getExpensesByDateRange(DateTime start, DateTime end) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'tanggal >= ? AND tanggal <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'tanggal DESC',
    );
    return maps.map((map) => ExpenseEntry.fromMap(map)).toList();
  }

  Future<List<ExpenseEntry>> getExpensesBySource(String source) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'source = ?',
      whereArgs: [source],
      orderBy: 'tanggal DESC',
    );
    return maps.map((map) => ExpenseEntry.fromMap(map)).toList();
  }

  Future<int> getTotalByType(String type, DateTime start, DateTime end) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT SUM(nominal) as total FROM $_tableName WHERE type = ? AND tanggal >= ? AND tanggal <= ?',
      [type, start.toIso8601String(), end.toIso8601String()],
    );
    if (result.isNotEmpty && result.first['total'] != null) {
      return result.first['total'] as int;
    }
    return 0;
  }
}
