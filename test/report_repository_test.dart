import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_laundry_offline_app/logic/cubits/report/report_state.dart';
import 'package:flutter_laundry_offline_app/data/models/order.dart';
import 'package:flutter_laundry_offline_app/data/models/expense_entry.dart';

void main() {
  group('ReportData & Cash Flow Aggregation Tests', () {
    test('ReportData holds unified financial numbers properly', () {
      final now = DateTime.now();
      final report = ReportData(
        startDate: now.subtract(const Duration(days: 7)),
        endDate: now,
        totalOrders: 10,
        completedOrders: 8,
        pendingOrders: 2,
        totalRevenue: 500000,
        totalPaid: 450000,
        totalUnpaid: 50000,
        totalIncome: 750000,
        totalExpense: 200000,
        netProfit: 550000,
        ordersByStatus: {OrderStatus.done: 8, OrderStatus.process: 2},
        dailyRevenue: [],
        topServices: [],
        expenses: [
          ExpenseEntry(
            id: 1,
            type: 'masuk',
            item: 'Penjualan offline',
            nominal: 250000,
            tanggal: now,
            supplier: '',
            source: 'voice',
            createdAt: now,
          ),
          ExpenseEntry(
            id: 2,
            type: 'keluar',
            item: 'Beli kemasan & bahan',
            nominal: 200000,
            tanggal: now,
            supplier: 'Toko Plastik',
            source: 'ocr',
            createdAt: now,
          ),
        ],
      );

      expect(report.totalIncome, 750000);
      expect(report.totalExpense, 200000);
      expect(report.netProfit, 550000);
      expect(report.expenses.length, 2);
      expect(report.expenses.first.type, 'masuk');
      expect(report.expenses.last.type, 'keluar');
    });
  });
}
