import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_laundry_offline_app/data/models/order.dart';
import 'package:flutter_laundry_offline_app/data/repositories/order_repository.dart';
import 'package:flutter_laundry_offline_app/data/repositories/payment_repository.dart';
import 'package:flutter_laundry_offline_app/data/repositories/expense_repository.dart';
import 'package:flutter_laundry_offline_app/logic/cubits/dashboard/dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final OrderRepository _orderRepository;
  final PaymentRepository _paymentRepository;
  final ExpenseRepository _expenseRepository;

  DashboardCubit({
    OrderRepository? orderRepository,
    PaymentRepository? paymentRepository,
    ExpenseRepository? expenseRepository,
  })  : _orderRepository = orderRepository ?? OrderRepository(),
        _paymentRepository = paymentRepository ?? PaymentRepository(),
        _expenseRepository = expenseRepository ?? ExpenseRepository(),
        super(const DashboardInitial());

  Future<void> loadDashboard({String period = 'mingguan'}) async {
    emit(const DashboardLoading());

    try {
      // Load all dashboard data in parallel
      final results = await Future.wait([
        _orderRepository.getTodayOrderCountByStatus(),
        _paymentRepository.getTodayRevenue(),
        _paymentRepository.getThisMonthOrderCount(),
        _orderRepository.getRecentOrders(limit: 5),
      ]);

      // Determine date range based on period
      final now = DateTime.now();
      DateTime startDate;
      switch (period) {
        case 'harian':
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case 'bulanan':
          startDate = DateTime(now.year, now.month - 2, now.day);
          break;
        case 'mingguan':
        default:
          startDate = now.subtract(const Duration(days: 7));
          break;
      }

      // Load expense data
      int totalIncome = 0;
      int totalExpense = 0;
      List<DailyFinancial> chartData = [];

      try {
        totalIncome = await _expenseRepository.getTotalByType('masuk', startDate, now);
        totalExpense = await _expenseRepository.getTotalByType('keluar', startDate, now);

        // Build chart data — daily aggregates
        final expenses = await _expenseRepository.getExpensesByDateRange(startDate, now);
        final Map<String, int> incomeByDay = {};
        final Map<String, int> expenseByDay = {};

        for (final entry in expenses) {
          final dayKey = '${entry.tanggal.year}-${entry.tanggal.month.toString().padLeft(2, '0')}-${entry.tanggal.day.toString().padLeft(2, '0')}';
          if (entry.type == 'masuk') {
            incomeByDay[dayKey] = (incomeByDay[dayKey] ?? 0) + entry.nominal;
          } else {
            expenseByDay[dayKey] = (expenseByDay[dayKey] ?? 0) + entry.nominal;
          }
        }

        // Generate chart entries for date range
        final int dayCount = now.difference(startDate).inDays + 1;
        for (int i = 0; i < dayCount && i < 31; i++) {
          final date = startDate.add(Duration(days: i));
          final dayKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          chartData.add(DailyFinancial(
            date: date,
            income: incomeByDay[dayKey] ?? 0,
            expense: expenseByDay[dayKey] ?? 0,
          ));
        }
      } catch (_) {
        // Expense data not available yet — that's OK, show zeroes
      }

      emit(DashboardLoaded(
        todayStatusCounts: results[0] as Map<OrderStatus, int>,
        todayRevenue: results[1] as int,
        monthOrderCount: results[2] as int,
        recentOrders: results[3] as List<Order>,
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        netBalance: totalIncome - totalExpense,
        chartData: chartData,
        selectedPeriod: period,
      ));
    } catch (e) {
      emit(DashboardError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void changePeriod(String period) {
    loadDashboard(period: period);
  }
}
