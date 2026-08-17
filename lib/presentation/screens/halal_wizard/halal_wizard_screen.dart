import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'logic/halal_wizard_cubit.dart';
import 'steps/step_business_info.dart';
import 'steps/step_ingredients.dart';
import 'steps/step_location.dart';
import 'steps/step_production_process.dart';
import 'steps/step_summary_export.dart';

class HalalWizardScreen extends StatelessWidget {
  const HalalWizardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HalalWizardCubit(),
      child: const _HalalWizardView(),
    );
  }
}

class _HalalWizardView extends StatefulWidget {
  const _HalalWizardView();

  @override
  State<_HalalWizardView> createState() => _HalalWizardViewState();
}

class _HalalWizardViewState extends State<_HalalWizardView> {
  final PageController _pageController = PageController();

  final List<String> _stepTitles = [
    'Info Usaha',
    'Bahan Baku',
    'Proses Produksi',
    'Lokasi',
    'Ringkasan',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onStepChanged(BuildContext context, int step) {
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wizard Halal SEHATI'),
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.event),
                tooltip: 'Set Deadline SEHATI',
                onPressed: () async {
                  final currentDeadline = context.read<HalalWizardCubit>().state.sehatiDeadline;
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: currentDeadline ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null && context.mounted) {
                    context.read<HalalWizardCubit>().setSehatiDeadline(picked);
                  }
                },
              );
            }
          ),
        ],
      ),
      body: BlocConsumer<HalalWizardCubit, HalalWizardState>(
        listenWhen: (previous, current) => previous.currentStep != current.currentStep,
        listener: (context, state) {
          _onStepChanged(context, state.currentStep);
        },
        builder: (context, state) {
          return Column(
            children: [
              // Progress Indicator
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                color: Colors.grey.shade100,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(5, (index) {
                        final isCompleted = index < state.currentStep;
                        final isActive = index == state.currentStep;
                        return Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCompleted || isActive ? const Color(0xFFD97706) : Colors.grey.shade300,
                          ),
                          child: Center(
                            child: isCompleted
                                ? const Icon(Icons.check, size: 16, color: Colors.white)
                                : Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: isActive ? Colors.white : Colors.grey.shade600,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Langkah ${state.currentStep + 1} dari 5: ${_stepTitles[state.currentStep]}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Builder(
                      builder: (context) {
                        final percent = context.read<HalalWizardCubit>().getDocumentCompletionPercent();
                        return LinearProgressIndicator(
                          value: percent / 100,
                          backgroundColor: Colors.grey.shade300,
                          color: const Color(0xFFD97706),
                        );
                      }
                    ),
                    const SizedBox(height: 4),
                    Text('${context.read<HalalWizardCubit>().getDocumentCompletionPercent()}% Dokumen Siap', style: const TextStyle(fontSize: 12)),
                    if (state.sehatiDeadline != null) ...[
                      const SizedBox(height: 8),
                      Builder(
                        builder: (context) {
                          final now = DateTime.now();
                          final deadline = state.sehatiDeadline!;
                          final diff = deadline.difference(DateTime(now.year, now.month, now.day)).inDays;
                          
                          if (diff < 0) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(16)),
                              child: Text('Tenggat waktu SEHATI telah terlewat!', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                            );
                          } else {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(16)),
                              child: Text('Sisa $diff hari menuju tenggat SEHATI', style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold)),
                            );
                          }
                        }
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(), // Prevent swipe to skip validation
                  children: const [
                    StepBusinessInfo(),
                    StepIngredients(),
                    StepProductionProcess(),
                    StepLocation(),
                    StepSummaryExport(),
                  ],
                ),
              ),
              // Bottom Navigation
              if (state.currentStep < 4)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Semantics(
                        button: true,
                        label: 'Kembali',
                        child: TextButton(
                          onPressed: state.currentStep > 0
                              ? () => context.read<HalalWizardCubit>().previousStep()
                              : null,
                          style: TextButton.styleFrom(minimumSize: const Size(80, 48)),
                          child: const Text('Kembali'),
                        ),
                      ),
                      Semantics(
                        button: true,
                        label: 'Selanjutnya',
                        child: ElevatedButton(
                          onPressed: context.read<HalalWizardCubit>().validateCurrentStep()
                              ? () => context.read<HalalWizardCubit>().nextStep()
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F766E),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(120, 48),
                          ),
                          child: const Text('Selanjutnya'),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
