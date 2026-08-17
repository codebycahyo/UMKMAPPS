import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_laundry_offline_app/core/theme/app_theme.dart';
import 'package:flutter_laundry_offline_app/logic/cubits/expense/expense_cubit.dart';
import 'package:flutter_laundry_offline_app/presentation/screens/expense/scan_receipt_screen.dart';
import 'package:flutter_laundry_offline_app/presentation/screens/expense/voice_entry_screen.dart';
import 'package:flutter_laundry_offline_app/presentation/screens/transaction/manual_entry_screen.dart';
import 'package:flutter_laundry_offline_app/presentation/screens/expense/expense_list_screen.dart';

class TransactionHubScreen extends StatelessWidget {
  const TransactionHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Catat Transaksi',
          style: AppTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Pilih Metode Pencatatan',
                style: AppTypography.titleMedium.copyWith(
                  color: AppThemeColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildActionCard(
                context,
                title: 'Scan Nota',
                description: 'Foto nota belanja, otomatis tercatat',
                icon: Icons.document_scanner_rounded,
                color: AppThemeColors.primary,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider(
                        create: (context) => ExpenseCubit(),
                        child: const ScanReceiptScreen(),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md),
              _buildActionCard(
                context,
                title: 'Rekam Suara',
                description: 'Bicara, langsung tercatat',
                icon: Icons.mic_rounded,
                color: AppThemeColors.info,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider(
                        create: (context) => ExpenseCubit(),
                        child: const VoiceEntryScreen(),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md),
              _buildActionCard(
                context,
                title: 'Input Manual',
                description: 'Ketik langsung catatan transaksi',
                icon: Icons.edit_note_rounded,
                color: AppThemeColors.success,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider(
                        create: (context) => ExpenseCubit(),
                        child: const ManualEntryScreen(),
                      ),
                    ),
                  );
                },
              ),
              const Spacer(),
              Semantics(
                button: true,
                label: 'Lihat semua catatan transaksi',
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlocProvider(
                          create: (context) => ExpenseCubit()..loadExpenses(),
                          child: const ExpenseListScreen(),
                        ),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                  ),
                  child: Text(
                    'Lihat Semua Catatan',
                    style: AppTypography.button.copyWith(
                      color: AppThemeColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      label: '$title, $description',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.lgRadius,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: AppRadius.lgRadius,
              border: Border.all(color: AppThemeColors.border),
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.05),
                  color.withValues(alpha: 0.15),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: AppRadius.mdRadius,
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.titleMedium.copyWith(
                          color: AppThemeColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppThemeColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppThemeColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
