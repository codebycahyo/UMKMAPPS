import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_laundry_offline_app/core/theme/app_theme.dart';
import 'package:flutter_laundry_offline_app/core/utils/date_formatter.dart';
import 'package:flutter_laundry_offline_app/data/database/database_helper.dart';
import 'package:flutter_laundry_offline_app/logic/cubits/auth/auth_cubit.dart';
import 'package:flutter_laundry_offline_app/logic/cubits/auth/auth_state.dart';
import 'package:flutter_laundry_offline_app/logic/cubits/expense/expense_cubit.dart';
import 'package:flutter_laundry_offline_app/logic/cubits/customer/customer_cubit.dart';
import 'package:flutter_laundry_offline_app/logic/cubits/order/order_cubit.dart';
import 'package:flutter_laundry_offline_app/logic/cubits/report/report_cubit.dart';
import 'package:flutter_laundry_offline_app/presentation/screens/auth/login_screen.dart';
import 'package:flutter_laundry_offline_app/presentation/screens/main_screen.dart';
import 'package:flutter_laundry_offline_app/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit()),
        BlocProvider(create: (_) => ExpenseCubit()),
        BlocProvider(create: (_) => CustomerCubit()),
        BlocProvider(create: (_) => OrderCubit()),
        BlocProvider(create: (_) => ReportCubit()),
      ],
      child: MaterialApp(
        title: 'LegaliKas AI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isInitializing = true;
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await DateFormatter.initialize();
      await DatabaseHelper.instance.database;
      final prefs = await SharedPreferences.getInstance();
      final showOnboarding = !(prefs.getBool('onboarding_complete') ?? false);
      if (mounted) {
        setState(() {
          _showOnboarding = showOnboarding;
          _isInitializing = false;
        });
        context.read<AuthCubit>().checkAuthStatus();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
        context.read<AuthCubit>().checkAuthStatus();
      }
    }
  }

  void _onOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (mounted) {
      setState(() {
        _showOnboarding = false;
      });
      context.read<AuthCubit>().checkAuthStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return Scaffold(
        backgroundColor: AppThemeColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadius.xlRadius,
                  boxShadow: AppShadows.medium,
                ),
                child: Image.asset(
                  'assets/icons/logo_baru.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const CircularProgressIndicator(color: AppThemeColors.primary),
            ],
          ),
        ),
      );
    }

    if (_showOnboarding) {
      return OnboardingScreen(onComplete: _onOnboardingComplete);
    }

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial || state is AuthLoading) {
          return Scaffold(
            backgroundColor: AppThemeColors.background,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppRadius.xlRadius,
                      boxShadow: AppShadows.medium,
                    ),
                    child: Image.asset(
                      'assets/icons/logo_baru.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const CircularProgressIndicator(
                    color: AppThemeColors.primary,
                  ),
                ],
              ),
            ),
          );
        }

        if (state is AuthAuthenticated) {
          return const MainScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
