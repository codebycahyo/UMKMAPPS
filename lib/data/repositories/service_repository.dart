import 'package:flutter_laundry_offline_app/data/database/database_helper.dart';
import 'package:flutter_laundry_offline_app/data/models/service.dart';

class ServiceRepository {
  final DatabaseHelper _databaseHelper;

  ServiceRepository({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  Future<List<Service>> getAllServices() async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      'services',
      where: 'is_active = 1',
      orderBy: 'name ASC',
    );
    return result.map((map) => Service.fromMap(map)).toList();
  }

  Future<List<Service>> getAllServicesIncludingInactive() async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      'services',
      orderBy: 'is_active DESC, name ASC',
    );
    return result.map((map) => Service.fromMap(map)).toList();
  }

  Future<Service?> getServiceById(int id) async {
    final db = await _databaseHelper.database;
    final result = await db.query('services', where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    return Service.fromMap(result.first);
  }

  Future<Service> createService(Service service) async {
    final db = await _databaseHelper.database;

    if (service.name.trim().isEmpty) {
      throw Exception('Nama layanan tidak boleh kosong');
    }
    if (service.price <= 0) {
      throw Exception('Harga harus lebih dari 0');
    }

    final now = DateTime.now().toIso8601String();
    final id = await db.insert('services', {
      'name': service.name.trim(),
      'unit': service.unit.value,
      'price': service.price,
      'duration_days': service.durationDays,
      'is_active': 1,
      'created_at': now,
    });

    return service.copyWith(id: id, isActive: true, createdAt: DateTime.now());
  }

  Future<Service> updateService(Service service) async {
    final db = await _databaseHelper.database;

    if (service.id == null) {
      throw Exception('Service ID tidak ditemukan');
    }

    if (service.name.trim().isEmpty) {
      throw Exception('Nama layanan tidak boleh kosong');
    }
    if (service.price <= 0) {
      throw Exception('Harga harus lebih dari 0');
    }

    await db.update(
      'services',
      {
        'name': service.name.trim(),
        'unit': service.unit.value,
        'price': service.price,
        'duration_days': service.durationDays,
      },
      where: 'id = ?',
      whereArgs: [service.id],
    );

    return service;
  }

  Future<void> deleteService(int id) async {
    final db = await _databaseHelper.database;

    await db.update(
      'services',
      {'is_active': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> restoreService(int id) async {
    final db = await _databaseHelper.database;

    await db.update(
      'services',
      {'is_active': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> serviceNameExists(String name, {int? excludeId}) async {
    final db = await _databaseHelper.database;

    String where = 'LOWER(name) = ? AND is_active = 1';
    List<dynamic> whereArgs = [name.toLowerCase().trim()];

    if (excludeId != null) {
      where += ' AND id != ?';
      whereArgs.add(excludeId);
    }

    final result = await db.query(
      'services',
      where: where,
      whereArgs: whereArgs,
    );

    return result.isNotEmpty;
  }

  Future<int> getServiceCount() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM services WHERE is_active = 1',
    );
    return result.first['count'] as int;
  }
}
