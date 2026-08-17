import 'package:flutter_laundry_offline_app/core/services/session_service.dart';
import 'package:flutter_laundry_offline_app/core/utils/password_helper.dart';
import 'package:flutter_laundry_offline_app/data/database/database_helper.dart';
import 'package:flutter_laundry_offline_app/data/models/user.dart';

class AuthRepository {
  final DatabaseHelper _databaseHelper;
  SessionService? _sessionService;

  AuthRepository({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  Future<SessionService> get _session async {
    _sessionService ??= await SessionService.getInstance();
    return _sessionService!;
  }

  Future<User> login(String username, String password) async {
    final db = await _databaseHelper.database;

    final result = await db.query(
      'users',
      where: 'username = ? AND is_active = 1',
      whereArgs: [username.toLowerCase().trim()],
    );

    if (result.isEmpty) {
      throw Exception('Username tidak ditemukan');
    }

    final userMap = result.first;
    final storedHash = userMap['password_hash'] as String;

    if (!PasswordHelper.verifyPassword(password, storedHash)) {
      throw Exception('Password salah');
    }

    final user = User.fromMap(userMap);

    final session = await _session;
    await session.saveSession(
      userId: user.id!,
      username: user.username,
      role: user.role.value,
      name: user.name,
    );

    return user;
  }

  Future<void> logout() async {
    final session = await _session;
    await session.clearSession();
  }

  Future<bool> isLoggedIn() async {
    final session = await _session;
    return session.isLoggedIn();
  }

  Future<User?> getCurrentUser() async {
    final session = await _session;

    if (!session.isLoggedIn()) {
      return null;
    }

    final userId = session.getUserId();
    if (userId == null) {
      return null;
    }

    final db = await _databaseHelper.database;
    final result = await db.query(
      'users',
      where: 'id = ? AND is_active = 1',
      whereArgs: [userId],
    );

    if (result.isEmpty) {
      await session.clearSession();
      return null;
    }

    return User.fromMap(result.first);
  }

  Future<void> changePassword({
    required int userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    final db = await _databaseHelper.database;

    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (result.isEmpty) {
      throw Exception('User tidak ditemukan');
    }

    final storedHash = result.first['password_hash'] as String;

    if (!PasswordHelper.verifyPassword(currentPassword, storedHash)) {
      throw Exception('Password lama salah');
    }

    final validation = PasswordHelper.validatePassword(newPassword);
    if (validation != null) {
      throw Exception(validation);
    }

    final newHash = PasswordHelper.hashPassword(newPassword);

    await db.update(
      'users',
      {
        'password_hash': newHash,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
  }
}
