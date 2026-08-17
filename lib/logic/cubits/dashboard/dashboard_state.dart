import 'package:equatable/equatable.dart';
import 'package:flutter_laundry_offline_app/data/models/order.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  final Map<OrderStatus, int> todayStatusCounts;
  final int todayRevenue;
  final int monthOrderCount;
  final List<Order> recentOrders;

  // LegaliKas AI financial data
  final int totalIncome;
  final int totalExpense;
  final int netBalance;
  final List<DailyFinancial> chartData;
  final String selectedPeriod; // 'harian', 'mingguan', 'bulanan'

  const DashboardLoaded({
    required this.todayStatusCounts,
    required this.todayRevenue,
    required this.monthOrderCount,
    required this.recentOrders,
    this.totalIncome = 0,
    this.totalExpense = 0,
    this.netBalance = 0,
    this.chartData = const [],
    this.selectedPeriod = 'mingguan',
  });

  @override
  List<Object?> get props => [
        todayStatusCounts,
        todayRevenue,
        monthOrderCount,
        recentOrders,
        totalIncome,
        totalExpense,
        netBalance,
        chartData,
        selectedPeriod,
      ];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Data class for daily income/expense chart
class DailyFinancial extends Equatable {
  final DateTime date;
  final int income;
  final int expense;

  const DailyFinancial({
    required this.date,
    required this.income,
    required this.expense,
  });

  @override
  List<Object?> get props => [date, income, expense];
}
