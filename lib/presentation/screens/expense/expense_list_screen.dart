import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_laundry_offline_app/core/theme/app_theme.dart';
import 'package:flutter_laundry_offline_app/core/utils/currency_formatter.dart';
import 'package:flutter_laundry_offline_app/core/utils/date_formatter.dart';
import 'package:flutter_laundry_offline_app/logic/cubits/expense/expense_cubit.dart';
import 'package:flutter_laundry_offline_app/logic/cubits/expense/expense_state.dart';
import 'package:flutter_laundry_offline_app/presentation/screens/expense/scan_receipt_screen.dart';
import 'package:flutter_laundry_offline_app/presentation/screens/expense/voice_entry_screen.dart';
import 'package:flutter_laundry_offline_app/presentation/screens/transaction/manual_entry_screen.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  String _selectedSourceFilter = 'Semua';
  String _selectedTypeFilter = 'semua'; // 'semua', 'masuk', 'keluar'

  @override
  void initState() {
    super.initState();
    context.read<ExpenseCubit>().loadExpenses();
  }

  void _onSourceFilterChanged(String filter) {
    setState(() {
      _selectedSourceFilter = filter;
    });
    if (filter == 'Semua') {
      context.read<ExpenseCubit>().loadExpenses();
    } else {
      context.read<ExpenseCubit>().loadBySource(filter);
    }
  }

  void _showAddTransactionOptions(BuildContext context) {
    final expenseCubit = context.read<ExpenseCubit>();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Tambah Transaksi Baru',
                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildBottomSheetOption(
                icon: Icons.mic_rounded,
                title: 'Catat Suara',
                subtitle: 'Bicara untuk mencatat transaksi',
                color: AppThemeColors.info,
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: expenseCubit,
                        child: const VoiceEntryScreen(),
                      ),
                    ),
                  ).then((_) {
                    if (mounted) expenseCubit.loadExpenses();
                  });
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildBottomSheetOption(
                icon: Icons.document_scanner_rounded,
                title: 'Scan Nota (OCR)',
                subtitle: 'Foto struk / nota belanja bahan',
                color: AppThemeColors.primary,
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: expenseCubit,
                        child: const ScanReceiptScreen(),
                      ),
                    ),
                  ).then((_) {
                    if (mounted) expenseCubit.loadExpenses();
                  });
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildBottomSheetOption(
                icon: Icons.edit_note_rounded,
                title: 'Input Manual',
                subtitle: 'Ketik langsung data transaksi',
                color: AppThemeColors.success,
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: expenseCubit,
                        child: const ManualEntryScreen(),
                      ),
                    ),
                  ).then((_) {
                    if (mounted) expenseCubit.loadExpenses();
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSheetOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      label: '$title. $subtitle',
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: AppRadius.mdRadius,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(title, style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: AppTypography.bodySmall),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buku Kas UMKM'),
        backgroundColor: AppThemeColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Segarkan data',
            onPressed: () => context.read<ExpenseCubit>().loadExpenses(),
          ),
        ],
      ),
      backgroundColor: AppThemeColors.background,
      body: Column(
        children: [
          // Filter Chips (Source: Semua, OCR, Suara, Manual)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: Row(
              children: ['Semua', 'OCR', 'Suara', 'Manual'].map((filter) {
                final isSelected = _selectedSourceFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: Semantics(
                    button: true,
                    label: 'Filter sumber: $filter',
                    selected: isSelected,
                    child: FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      selectedColor: AppThemeColors.primary.withValues(alpha: 0.2),
                      checkmarkColor: AppThemeColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? AppThemeColors.primary : AppThemeColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                      onSelected: (_) => _onSourceFilterChanged(filter),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Content
          Expanded(
            child: BlocBuilder<ExpenseCubit, ExpenseState>(
              builder: (context, state) {
                if (state is ExpenseLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppThemeColors.primary),
                  );
                } else if (state is ExpenseError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: AppThemeColors.error),
                          const SizedBox(height: AppSpacing.md),
                          Text('Terjadi kesalahan: ${state.message}', textAlign: TextAlign.center),
                          const SizedBox(height: AppSpacing.md),
                          ElevatedButton(
                            onPressed: () => context.read<ExpenseCubit>().loadExpenses(),
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (state is ExpenseLoaded) {
                  var expenses = state.expenses;

                  // Apply type filter if active
                  if (_selectedTypeFilter != 'semua') {
                    expenses = expenses.where((e) => e.type == _selectedTypeFilter).toList();
                  }

                  int totalMasuk = 0;
                  int totalKeluar = 0;
                  for (var e in state.expenses) {
                    if (e.type == 'masuk') totalMasuk += e.nominal;
                    if (e.type == 'keluar') totalKeluar += e.nominal;
                  }
                  final saldo = totalMasuk - totalKeluar;

                  return Column(
                    children: [
                      // Financial Summary Card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: AppRadius.lgRadius,
                            boxShadow: AppShadows.small,
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildSummaryMetric(
                                      'Pemasukan',
                                      CurrencyFormatter.format(totalMasuk),
                                      AppThemeColors.success,
                                      Icons.arrow_downward_rounded,
                                    ),
                                  ),
                                  Container(width: 1, height: 40, color: AppThemeColors.border),
                                  Expanded(
                                    child: _buildSummaryMetric(
                                      'Pengeluaran',
                                      CurrencyFormatter.format(totalKeluar),
                                      AppThemeColors.error,
                                      Icons.arrow_upward_rounded,
                                    ),
                                  ),
                                  Container(width: 1, height: 40, color: AppThemeColors.border),
                                  Expanded(
                                    child: _buildSummaryMetric(
                                      'Saldo Kas',
                                      CurrencyFormatter.format(saldo),
                                      saldo >= 0 ? AppThemeColors.primary : AppThemeColors.error,
                                      Icons.account_balance_wallet_rounded,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Type toggle chips (Semua, Masuk, Keluar)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        child: Row(
                          children: [
                            _buildTypeFilterChip('Semua Transaksi', 'semua'),
                            const SizedBox(width: AppSpacing.xs),
                            _buildTypeFilterChip('Pemasukan (+)', 'masuk'),
                            const SizedBox(width: AppSpacing.xs),
                            _buildTypeFilterChip('Pengeluaran (-)', 'keluar'),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),

                      // List View
                      Expanded(
                        child: expenses.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.receipt_long_outlined,
                                      size: 56,
                                      color: AppThemeColors.textSecondary.withValues(alpha: 0.4),
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    Text(
                                      'Belum ada catatan transaksi.',
                                      style: AppTypography.bodyMedium.copyWith(
                                        color: AppThemeColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    Text(
                                      'Gunakan tombol + untuk mencatat lewat suara atau nota.',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppThemeColors.textHint,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.xs,
                                ),
                                itemCount: expenses.length,
                                itemBuilder: (context, index) {
                                  final e = expenses[index];
                                  final isMasuk = e.type == 'masuk';

                                  IconData sourceIcon;
                                  Color sourceColor;
                                  switch (e.source) {
                                    case 'ocr':
                                      sourceIcon = Icons.document_scanner_rounded;
                                      sourceColor = AppThemeColors.primary;
                                      break;
                                    case 'voice':
                                      sourceIcon = Icons.mic_rounded;
                                      sourceColor = AppThemeColors.info;
                                      break;
                                    default:
                                      sourceIcon = Icons.edit_note_rounded;
                                      sourceColor = AppThemeColors.success;
                                  }

                                  return Semantics(
                                    label: '${isMasuk ? "Pemasukan" : "Pengeluaran"} ${e.item} senilai ${CurrencyFormatter.format(e.nominal)} tanggal ${DateFormatter.formatDate(e.tanggal)}',
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: AppRadius.mdRadius,
                                        boxShadow: AppShadows.small,
                                      ),
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.md,
                                          vertical: AppSpacing.xs,
                                        ),
                                        leading: Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: (isMasuk ? AppThemeColors.success : AppThemeColors.error)
                                                .withValues(alpha: 0.1),
                                            borderRadius: AppRadius.mdRadius,
                                          ),
                                          child: Icon(
                                            isMasuk ? Icons.arrow_downward : Icons.arrow_upward,
                                            color: isMasuk ? AppThemeColors.success : AppThemeColors.error,
                                            size: 22,
                                          ),
                                        ),
                                        title: Text(
                                          e.item,
                                          style: AppTypography.titleSmall.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        subtitle: Row(
                                          children: [
                                            Icon(sourceIcon, size: 14, color: sourceColor),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${e.source.toUpperCase()} • ${DateFormatter.formatDateCompact(e.tanggal)}',
                                              style: AppTypography.bodySmall.copyWith(
                                                color: AppThemeColors.textSecondary,
                                                fontSize: 11,
                                              ),
                                            ),
                                            if (e.supplier != null && e.supplier!.isNotEmpty) ...[
                                              const SizedBox(width: 4),
                                              Text(
                                                '• ${e.supplier}',
                                                style: AppTypography.bodySmall.copyWith(
                                                  color: AppThemeColors.textHint,
                                                  fontSize: 11,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ],
                                        ),
                                        trailing: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '${isMasuk ? "+" : "-"} ${CurrencyFormatter.format(e.nominal)}',
                                              style: AppTypography.labelLarge.copyWith(
                                                color: isMasuk ? AppThemeColors.success : AppThemeColors.error,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                }
                return const Center(child: Text('Tidak ada data.'));
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Semantics(
        button: true,
        label: 'Tambah catatan transaksi baru',
        child: FloatingActionButton.extended(
          backgroundColor: AppThemeColors.primary,
          foregroundColor: Colors.white,
          onPressed: () => _showAddTransactionOptions(context),
          icon: const Icon(Icons.add),
          label: const Text('Catat Transaksi'),
        ),
      ),
    );
  }

  Widget _buildSummaryMetric(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 2),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: AppThemeColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.labelMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 11,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildTypeFilterChip(String label, String type) {
    final isSelected = _selectedTypeFilter == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedTypeFilter = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppThemeColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppThemeColors.primary : AppThemeColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppThemeColors.textSecondary,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
