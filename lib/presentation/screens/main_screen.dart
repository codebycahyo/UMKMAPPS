import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_laundry_offline_app/core/theme/app_theme.dart';
import 'package:flutter_laundry_offline_app/data/models/user.dart';
import 'package:flutter_laundry_offline_app/data/repositories/expense_repository.dart';
import 'package:flutter_laundry_offline_app/logic/cubits/auth/auth_cubit.dart';
import 'package:flutter_laundry_offline_app/logic/cubits/auth/auth_state.dart';
import 'package:flutter_laundry_offline_app/logic/cubits/customer/customer_cubit.dart';
import 'package:flutter_laundry_offline_app/logic/cubits/expense/expense_cubit.dart';
import 'package:flutter_laundry_offline_app/logic/cubits/order/order_cubit.dart';
import 'package:flutter_laundry_offline_app/logic/cubits/report/report_cubit.dart';
import 'package:flutter_laundry_offline_app/logic/cubits/service/service_cubit.dart';
import 'package:flutter_laundry_offline_app/logic/cubits/user/user_cubit.dart';
import 'package:flutter_laundry_offline_app/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:flutter_laundry_offline_app/presentation/screens/customers/customer_list_screen.dart';
import 'package:flutter_laundry_offline_app/presentation/screens/expense/expense_list_screen.dart';
import 'package:flutter_laundry_offline_app/presentation/screens/legalitas/legalitas_hub_screen.dart';
import 'package:flutter_laundry_offline_app/presentation/screens/orders/order_form_screen.dart';
import 'package:flutter_laundry_offline_app/presentation/screens/orders/order_list_screen.dart';
import 'package:flutter_laundry_offline_app/presentation/screens/reports/report_screen.dart';
import 'package:flutter_laundry_offline_app/presentation/screens/services/service_list_screen.dart';
import 'package:flutter_laundry_offline_app/presentation/screens/settings/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = state.user;
        final isOwner = user.role == UserRole.owner;

        final navItems = <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.point_of_sale_outlined),
            activeIcon: Icon(Icons.point_of_sale_rounded),
            label: 'Kasir POS',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Buku Kas',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics_rounded),
            label: 'Laporan',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            activeIcon: Icon(Icons.grid_view_rounded),
            label: 'Lainnya',
          ),
        ];

        final screens = <Widget>[
          const DashboardScreen(),

          MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => ServiceCubit()..loadServices()),
              BlocProvider(create: (_) => CustomerCubit()..loadCustomers()),
              BlocProvider(create: (_) => OrderCubit()),
            ],
            child: const OrderFormScreen(),
          ),

          BlocProvider(
            create: (_) => ExpenseCubit(ExpenseRepository())..loadExpenses(),
            child: const ExpenseListScreen(),
          ),

          BlocProvider(
            create: (_) => ReportCubit(),
            child: const ReportScreen(),
          ),

          _buildLainnyaScreen(isOwner),
        ];

        if (_currentIndex >= screens.length) {
          _currentIndex = 0;
        }

        return Scaffold(
          body: IndexedStack(index: _currentIndex, children: screens),
          bottomNavigationBar: _buildCustomBottomNav(navItems),
        );
      },
    );
  }

  Widget _buildLainnyaScreen(bool isOwner) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Lainnya'),
        backgroundColor: AppThemeColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      backgroundColor: AppThemeColors.background,
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _buildMenuCard(
            icon: Icons.verified_user_rounded,
            title: 'Pusat Legalitas & Sertifikasi',
            subtitle: 'Wizard Halal SEHATI (PDF) & Panduan NIB OSS',
            color: const Color(0xFFD97706),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LegalitasHubScreen()),
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),

          _buildMenuCard(
            icon: Icons.people_alt_rounded,
            title: 'Database Pelanggan',
            subtitle: 'Kelola data kontak & riwayat pelanggan toko',
            color: AppThemeColors.info,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (_) => CustomerCubit()..loadCustomers(),
                    child: const CustomerListScreen(),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),

          _buildMenuCard(
            icon: Icons.inventory_2_rounded,
            title: 'Katalog Produk & Layanan',
            subtitle: 'Atur daftar produk jualan, harga, dan kategori',
            color: AppThemeColors.success,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (_) => ServiceCubit()..loadServices(),
                    child: const ServiceListScreen(),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),

          _buildMenuCard(
            icon: Icons.receipt_long_rounded,
            title: 'Riwayat Struk & Order Kasir',
            subtitle: 'Lihat daftar struk transaksi dan status order',
            color: AppThemeColors.primary,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (_) => OrderCubit()..loadOrders(),
                    child: const OrderListScreen(),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),

          if (isOwner)
            _buildMenuCard(
              icon: Icons.settings_rounded,
              title: 'Pengaturan Toko & Printer',
              subtitle: 'Profil usaha, akun kasir, & printer thermal Bluetooth',
              color: AppThemeColors.warning,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => UserCubit(),
                      child: const SettingsScreen(),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Semantics(
      label: '$title. $subtitle',
      button: true,
      child: Material(
        color: Colors.white,
        borderRadius: AppRadius.lgRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.lgRadius,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              borderRadius: AppRadius.lgRadius,
              border: Border.all(color: AppThemeColors.border),
            ),
            child: Row(
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
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppThemeColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppThemeColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomBottomNav(List<BottomNavigationBarItem> navItems) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(navItems.length, (index) {
              final item = navItems[index];
              final isSelected = _currentIndex == index;
              final activeColor = AppThemeColors.primary;

              return Expanded(
                child: Semantics(
                  label: item.label,
                  selected: isSelected,
                  button: true,
                  child: GestureDetector(
                    onTap: () => setState(() => _currentIndex = index),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconTheme(
                          data: IconThemeData(
                            color: isSelected
                                ? activeColor
                                : AppThemeColors.textSecondary,
                            size: 24,
                          ),
                          child: isSelected ? item.activeIcon : item.icon,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label ?? '',
                          style: AppTypography.labelSmall.copyWith(
                            color: isSelected
                                ? activeColor
                                : AppThemeColors.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
