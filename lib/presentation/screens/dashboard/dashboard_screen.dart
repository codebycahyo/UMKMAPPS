import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_laundry_offline_app/core/theme/app_theme.dart';
import 'package:flutter_laundry_offline_app/core/utils/currency_formatter.dart';
import 'package:flutter_laundry_offline_app/data/models/order.dart';
import 'package:flutter_laundry_offline_app/data/models/user.dart';
import 'package:flutter_laundry_offline_app/logic/cubits/auth/auth_cubit.dart';
import 'package:flutter_laundry_offline_app/logic/cubits/auth/auth_state.dart';
import 'package:flutter_laundry_offline_app/logic/cubits/dashboard/dashboard_cubit.dart';
import 'package:flutter_laundry_offline_app/logic/cubits/dashboard/dashboard_state.dart';
import 'package:flutter_laundry_offline_app/logic/cubits/order/order_cubit.dart';
import 'package:flutter_laundry_offline_app/logic/cubits/printer/printer_cubit.dart';
import 'package:flutter_laundry_offline_app/presentation/screens/orders/order_detail_screen.dart';
import 'package:flutter_laundry_offline_app/presentation/screens/orders/order_list_screen.dart';
import 'package:flutter_laundry_offline_app/presentation/screens/settings/printer_settings_screen.dart';
import 'package:flutter_laundry_offline_app/presentation/widgets/order_card.dart';

import 'package:flutter_laundry_offline_app/logic/cubits/report/report_cubit.dart';
import 'package:flutter_laundry_offline_app/presentation/screens/reports/report_screen.dart';
import 'package:flutter_laundry_offline_app/logic/cubits/expense/expense_cubit.dart';
import 'package:flutter_laundry_offline_app/data/repositories/expense_repository.dart';
import 'package:flutter_laundry_offline_app/presentation/screens/expense/scan_receipt_screen.dart';
import 'package:flutter_laundry_offline_app/presentation/screens/expense/voice_entry_screen.dart';
import 'package:flutter_laundry_offline_app/presentation/screens/transaction/manual_entry_screen.dart';
import 'package:flutter_laundry_offline_app/presentation/screens/legalitas/legalitas_hub_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late DashboardCubit _dashboardCubit;

  @override
  void initState() {
    super.initState();
    _dashboardCubit = DashboardCubit()..loadDashboard();
  }

  @override
  void dispose() {
    _dashboardCubit.close();
    super.dispose();
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return 'Owner';
      case UserRole.kasir:
        return 'Kasir';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final user = authState is AuthAuthenticated ? authState.user : null;

        return Scaffold(
          backgroundColor: AppThemeColors.background,
          body: BlocBuilder<DashboardCubit, DashboardState>(
            bloc: _dashboardCubit,
            builder: (context, state) {
              return RefreshIndicator(
                onRefresh: () async {
                  _dashboardCubit.loadDashboard();
                },
                color: AppThemeColors.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(user, state),

                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildQuickActions(),

                            const SizedBox(height: AppSpacing.xl),

                            _buildFinancialSection(state),

                            const SizedBox(height: AppSpacing.xl),

                            _buildOrderStatusSection(state),

                            const SizedBox(height: AppSpacing.xl),

                            _buildRecentOrders(state),

                            const SizedBox(height: AppSpacing.lg),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppThemeColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.logout,
                color: AppThemeColors.error,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Logout',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar dari aplikasi?',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Batal',
              style: AppTypography.labelMedium.copyWith(
                color: AppThemeColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthCubit>().logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemeColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Logout',
              style: AppTypography.labelMedium.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(User? user, DashboardState state) {
    int todayRevenue = 0;
    int monthOrders = 0;

    if (state is DashboardLoaded) {
      todayRevenue = state.todayRevenue;
      monthOrders = state.monthOrderCount;
    }

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: AppThemeColors.headerGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppRadius.fullRadius,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: AppThemeColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selamat Datang,',
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          user?.name ?? 'User',
                          style: AppTypography.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: AppRadius.fullRadius,
                    ),
                    child: Text(
                      user != null ? _getRoleDisplayName(user.role) : '-',
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),

                  GestureDetector(
                    onTap: _showLogoutConfirmation,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: AppRadius.fullRadius,
                      ),
                      child: const Icon(
                        Icons.logout,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              Row(
                children: [
                  Expanded(
                    child: _buildHeaderStatCard(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'Omzet Hari Ini',
                      value: CurrencyFormatter.formatCompact(todayRevenue),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _buildHeaderStatCard(
                      icon: Icons.receipt_long_outlined,
                      label: 'Order Bulan Ini',
                      value: monthOrders.toString(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: AppRadius.mdRadius,
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                ),
                Text(
                  value,
                  style: AppTypography.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pencatatan Cepat AI',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _buildLegaliKasEntry(
                icon: Icons.document_scanner_rounded,
                label: 'Scan Nota',
                description: 'Foto & ekstrak',
                color: AppThemeColors.primary,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (_) =>
                            ExpenseCubit(ExpenseRepository())..loadExpenses(),
                        child: const ScanReceiptScreen(),
                      ),
                    ),
                  ).then((_) => _dashboardCubit.loadDashboard());
                },
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildLegaliKasEntry(
                icon: Icons.mic_rounded,
                label: 'Catat Suara',
                description: 'Bicara transaksi',
                color: AppThemeColors.info,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (_) =>
                            ExpenseCubit(ExpenseRepository())..loadExpenses(),
                        child: const VoiceEntryScreen(),
                      ),
                    ),
                  ).then((_) => _dashboardCubit.loadDashboard());
                },
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildLegaliKasEntry(
                icon: Icons.edit_note_rounded,
                label: 'Input Manual',
                description: 'Ketik manual',
                color: const Color(0xFFD97706),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (_) =>
                            ExpenseCubit(ExpenseRepository())..loadExpenses(),
                        child: const ManualEntryScreen(),
                      ),
                    ),
                  ).then((_) => _dashboardCubit.loadDashboard());
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.xl),

        Text(
          'Akses Cepat',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionItem(
                icon: Icons.analytics_rounded,
                label: 'Laporan',
                color: AppThemeColors.success,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (_) => ReportCubit(),
                        child: const ReportScreen(),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildQuickActionItem(
                icon: Icons.verified_user_rounded,
                label: 'Legalitas',
                color: const Color(0xFFD97706),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LegalitasHubScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildQuickActionItem(
                icon: Icons.print_rounded,
                label: 'Printer',
                color: AppThemeColors.warning,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (_) => PrinterCubit(),
                        child: const PrinterSettingsScreen(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLegaliKasEntry({
    required IconData icon,
    required String label,
    required String description,
    required Color color,
    required VoidCallback onTap,
    bool isWide = false,
  }) {
    return Semantics(
      label: '$label. $description',
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.lgRadius,
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: isWide ? AppSpacing.lg : AppSpacing.xl,
              horizontal: AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: 0.08),
                  color.withValues(alpha: 0.03),
                ],
              ),
              borderRadius: AppRadius.lgRadius,
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: isWide
                ? Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: AppRadius.mdRadius,
                        ),
                        child: Icon(icon, color: color, size: 28),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              description,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppThemeColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, color: color, size: 16),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: AppRadius.mdRadius,
                        ),
                        child: Icon(icon, color: color, size: 28),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        label,
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppThemeColors.textSecondary,
                          fontSize: 9,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.lgRadius,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: AppRadius.mdRadius,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialSection(DashboardState state) {
    int totalIncome = 0;
    int totalExpense = 0;
    int netBalance = 0;
    List<DailyFinancial> chartData = [];
    String selectedPeriod = 'mingguan';

    if (state is DashboardLoaded) {
      totalIncome = state.totalIncome;
      totalExpense = state.totalExpense;
      netBalance = state.netBalance;
      chartData = state.chartData;
      selectedPeriod = state.selectedPeriod;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ringkasan Keuangan',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        Wrap(
          spacing: AppSpacing.sm,
          children: [
            _buildPeriodChip('Harian', 'harian', selectedPeriod),
            _buildPeriodChip('Mingguan', 'mingguan', selectedPeriod),
            _buildPeriodChip('Bulanan', 'bulanan', selectedPeriod),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        Row(
          children: [
            Expanded(
              child: _buildFinancialCard(
                label: 'Pemasukan',
                amount: totalIncome,
                color: AppThemeColors.success,
                icon: Icons.arrow_downward_rounded,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildFinancialCard(
                label: 'Pengeluaran',
                amount: totalExpense,
                color: AppThemeColors.error,
                icon: Icons.arrow_upward_rounded,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildFinancialCard(
                label: 'Saldo',
                amount: netBalance,
                color: netBalance >= 0
                    ? AppThemeColors.primary
                    : AppThemeColors.error,
                icon: Icons.account_balance_wallet_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        if (chartData.isNotEmpty) _buildBarChart(chartData),
      ],
    );
  }

  Widget _buildPeriodChip(String label, String value, String selected) {
    final isSelected = value == selected;
    return Semantics(
      label: 'Periode $label',
      selected: isSelected,
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => _dashboardCubit.changePeriod(value),
        selectedColor: AppThemeColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppThemeColors.textPrimary,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _buildFinancialCard({
    required String label,
    required int amount,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.mdRadius,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppThemeColors.textSecondary,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            CurrencyFormatter.format(amount),
            style: AppTypography.labelMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(List<DailyFinancial> data) {
    final displayData = data.length > 7 ? data.sublist(data.length - 7) : data;
    final maxVal = displayData.fold<int>(0, (prev, d) {
      final m = d.income > d.expense ? d.income : d.expense;
      return m > prev ? m : prev;
    });

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.lgRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Grafik Keuangan',
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),

              _buildChartLegend('Masuk', AppThemeColors.success),
              const SizedBox(width: AppSpacing.md),
              _buildChartLegend('Keluar', AppThemeColors.error),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxVal > 0 ? maxVal.toDouble() * 1.2 : 100000,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final d = displayData[group.x];
                      final val = rodIndex == 0 ? d.income : d.expense;
                      final label = rodIndex == 0 ? 'Masuk' : 'Keluar';
                      return BarTooltipItem(
                        '$label\n${CurrencyFormatter.format(val)}',
                        const TextStyle(color: Colors.white, fontSize: 11),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 &&
                            value.toInt() < displayData.length) {
                          final d = displayData[value.toInt()].date;
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '${d.day}/${d.month}',
                              style: const TextStyle(
                                fontSize: 9,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                      reservedSize: 22,
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                barGroups: List.generate(displayData.length, (index) {
                  final d = displayData[index];
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: d.income.toDouble(),
                        color: AppThemeColors.success,
                        width: 10,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                      BarChartRodData(
                        toY: d.expense.toDouble(),
                        color: AppThemeColors.error,
                        width: 10,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartLegend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildOrderStatusSection(DashboardState state) {
    Map<OrderStatus, int> counts = {
      OrderStatus.pending: 0,
      OrderStatus.process: 0,
      OrderStatus.ready: 0,
      OrderStatus.done: 0,
    };

    if (state is DashboardLoaded) {
      counts = Map.from(state.todayStatusCounts);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status Order Hari Ini',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.lgRadius,
            boxShadow: AppShadows.small,
          ),
          child: Row(
            children: [
              _buildStatusItem(
                'Pending',
                counts[OrderStatus.pending] ?? 0,
                AppThemeColors.warning,
              ),
              _buildStatusDivider(),
              _buildStatusItem(
                'Proses',
                counts[OrderStatus.process] ?? 0,
                AppThemeColors.primary,
              ),
              _buildStatusDivider(),
              _buildStatusItem(
                'Siap',
                counts[OrderStatus.ready] ?? 0,
                AppThemeColors.success,
              ),
              _buildStatusDivider(),
              _buildStatusItem(
                'Selesai',
                counts[OrderStatus.done] ?? 0,
                AppThemeColors.completed,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusItem(String label, int count, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                count.toString(),
                style: AppTypography.titleMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppThemeColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDivider() {
    return Container(width: 1, height: 50, color: AppThemeColors.border);
  }

  Widget _buildRecentOrders(DashboardState state) {
    List<Order> recentOrders = [];

    if (state is DashboardLoaded) {
      recentOrders = state.recentOrders.take(5).toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Order Terbaru',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<OrderCubit>(),
                      child: const OrderListScreen(),
                    ),
                  ),
                ).then((_) {
                  _dashboardCubit.loadDashboard();
                });
              },
              child: Text(
                'Lihat Semua',
                style: AppTypography.labelMedium.copyWith(
                  color: AppThemeColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (state is DashboardLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(color: AppThemeColors.primary),
            ),
          )
        else if (recentOrders.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.xxl),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadius.lgRadius,
              boxShadow: AppShadows.small,
            ),
            child: Column(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 48,
                  color: AppThemeColors.textSecondary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Belum ada order hari ini',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppThemeColors.textSecondary,
                  ),
                ),
              ],
            ),
          )
        else
          ...recentOrders.map(
            (order) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: OrderCard(
                order: order,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<OrderCubit>(),
                        child: OrderDetailScreen(orderId: order.id!),
                      ),
                    ),
                  ).then((_) => _dashboardCubit.loadDashboard());
                },
              ),
            ),
          ),
      ],
    );
  }
}
