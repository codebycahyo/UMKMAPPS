import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_laundry_offline_app/data/models/expense_entry.dart';
import 'package:flutter_laundry_offline_app/data/repositories/expense_repository.dart';
import 'package:flutter_laundry_offline_app/logic/cubits/expense/expense_state.dart';

class ExpenseCubit extends Cubit<ExpenseState> {
  final ExpenseRepository _repository;

  ExpenseCubit([ExpenseRepository? repository]) 
      : _repository = repository ?? ExpenseRepository(), 
        super(ExpenseInitial());

  Future<void> loadExpenses() async {
    emit(ExpenseLoading());
    try {
      final expenses = await _repository.getAllExpenses();
      emit(ExpenseLoaded(expenses: expenses));
    } catch (e) {
      emit(ExpenseError(message: e.toString()));
    }
  }

  Future<void> addExpense(ExpenseEntry entry) async {
    emit(ExpenseLoading());
    try {
      await _repository.createExpense(entry);
      emit(ExpenseCreated(expense: entry));
      await loadExpenses();
    } catch (e) {
      emit(ExpenseError(message: e.toString()));
    }
  }

  Future<void> updateExpense(ExpenseEntry entry) async {
    emit(ExpenseLoading());
    try {
      await _repository.updateExpense(entry);
      await loadExpenses();
    } catch (e) {
      emit(ExpenseError(message: e.toString()));
    }
  }

  Future<void> deleteExpense(int id) async {
    emit(ExpenseLoading());
    try {
      await _repository.deleteExpense(id);
      await loadExpenses();
    } catch (e) {
      emit(ExpenseError(message: e.toString()));
    }
  }

  Future<void> loadByDateRange(DateTime start, DateTime end) async {
    emit(ExpenseLoading());
    try {
      final expenses = await _repository.getExpensesByDateRange(start, end);
      emit(ExpenseLoaded(expenses: expenses));
    } catch (e) {
      emit(ExpenseError(message: e.toString()));
    }
  }

  Future<void> loadBySource(String source) async {
    if (source.isEmpty || source.toLowerCase() == 'semua') {
      return loadExpenses();
    }
    emit(ExpenseLoading());
    try {
      final expenses = await _repository.getExpensesBySource(source.toLowerCase());
      emit(ExpenseLoaded(expenses: expenses));
    } catch (e) {
      emit(ExpenseError(message: e.toString()));
    }
  }
}
