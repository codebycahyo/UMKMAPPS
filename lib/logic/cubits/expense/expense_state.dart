import 'package:equatable/equatable.dart';
import 'package:flutter_laundry_offline_app/data/models/expense_entry.dart';

abstract class ExpenseState extends Equatable {
  const ExpenseState();

  @override
  List<Object?> get props => [];
}

class ExpenseInitial extends ExpenseState {}

class ExpenseLoading extends ExpenseState {}

class ExpenseLoaded extends ExpenseState {
  final List<ExpenseEntry> expenses;

  const ExpenseLoaded({required this.expenses});

  @override
  List<Object?> get props => [expenses];
}

class ExpenseCreated extends ExpenseState {
  final ExpenseEntry expense;

  const ExpenseCreated({required this.expense});

  @override
  List<Object?> get props => [expense];
}

class ExpenseError extends ExpenseState {
  final String message;

  const ExpenseError({required this.message});

  @override
  List<Object?> get props => [message];
}
