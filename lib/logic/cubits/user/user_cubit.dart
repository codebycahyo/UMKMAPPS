import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_laundry_offline_app/data/models/user.dart';
import 'package:flutter_laundry_offline_app/data/repositories/user_repository.dart';
import 'package:flutter_laundry_offline_app/logic/cubits/user/user_state.dart';

class UserCubit extends Cubit<UserState> {
  final UserRepository _userRepository;
  List<User> _users = [];

  UserCubit({UserRepository? userRepository})
    : _userRepository = userRepository ?? UserRepository(),
      super(const UserInitial());

  List<User> get users => _users;

  Future<void> loadUsers() async {
    emit(const UserLoading());

    try {
      _users = await _userRepository.getAllUsers();
      emit(UserLoaded(_users));
    } catch (e) {
      emit(UserError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> createUser({
    required String username,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    emit(const UserLoading());

    try {
      await _userRepository.createUser(
        username: username,
        password: password,
        name: name,
        role: role,
      );

      emit(const UserOperationSuccess('User berhasil ditambahkan'));

      await loadUsers();
    } catch (e) {
      emit(UserError(e.toString().replaceAll('Exception: ', '')));

      emit(UserLoaded(_users));
    }
  }

  Future<void> updateUser({
    required int id,
    required String name,
    required UserRole role,
  }) async {
    emit(const UserLoading());

    try {
      await _userRepository.updateUser(id: id, name: name, role: role);

      emit(const UserOperationSuccess('User berhasil diupdate'));

      await loadUsers();
    } catch (e) {
      emit(UserError(e.toString().replaceAll('Exception: ', '')));

      emit(UserLoaded(_users));
    }
  }

  Future<void> resetPassword({
    required int userId,
    required String newPassword,
  }) async {
    emit(const UserLoading());

    try {
      await _userRepository.resetPassword(
        userId: userId,
        newPassword: newPassword,
      );

      emit(const UserOperationSuccess('Password berhasil direset'));

      emit(UserLoaded(_users));
    } catch (e) {
      emit(UserError(e.toString().replaceAll('Exception: ', '')));

      emit(UserLoaded(_users));
    }
  }

  Future<void> toggleUserStatus(int id) async {
    try {
      final isActive = await _userRepository.toggleUserStatus(id);
      final message = isActive ? 'User diaktifkan' : 'User dinonaktifkan';

      emit(UserOperationSuccess(message));

      await loadUsers();
    } catch (e) {
      emit(UserError(e.toString().replaceAll('Exception: ', '')));

      emit(UserLoaded(_users));
    }
  }
}
