import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/halal_wizard_cubit.dart';

class StepBusinessInfo extends StatefulWidget {
  const StepBusinessInfo({super.key});

  @override
  State<StepBusinessInfo> createState() => _StepBusinessInfoState();
}

class _StepBusinessInfoState extends State<StepBusinessInfo> {
  late TextEditingController _namaController;
  late TextEditingController _nibController;
  late TextEditingController _alamatController;
  late TextEditingController _teleponController;

  @override
  void initState() {
    super.initState();
    final state = context.read<HalalWizardCubit>().state;
    _namaController = TextEditingController(text: state.namaUsaha);
    _nibController = TextEditingController(text: state.nib);
    _alamatController = TextEditingController(text: state.alamatUsaha);
    _teleponController = TextEditingController(text: state.teleponUsaha);

    _namaController.addListener(_updateData);
    _nibController.addListener(_updateData);
    _alamatController.addListener(_updateData);
    _teleponController.addListener(_updateData);
  }

  void _updateData() {
    context.read<HalalWizardCubit>().updateStep1Data(
      namaUsaha: _namaController.text,
      nib: _nibController.text,
      alamatUsaha: _alamatController.text,
      teleponUsaha: _teleponController.text,
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nibController.dispose();
    _alamatController.dispose();
    _teleponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Usaha',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Semantics(
            label: 'Input Nama Usaha',
            textField: true,
            child: TextField(
              controller: _namaController,
              decoration: const InputDecoration(
                labelText: 'Nama Usaha *',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Semantics(
            label: 'Input NIB',
            textField: true,
            child: TextField(
              controller: _nibController,
              decoration: const InputDecoration(
                labelText: 'NIB / Nomor Induk Berusaha *',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Semantics(
            label: 'Input Alamat Usaha',
            textField: true,
            child: TextField(
              controller: _alamatController,
              decoration: const InputDecoration(
                labelText: 'Alamat Usaha *',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ),
          const SizedBox(height: 16),
          Semantics(
            label: 'Input Telepon Usaha',
            textField: true,
            child: TextField(
              controller: _teleponController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Telepon Usaha',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('* Wajib diisi', style: TextStyle(color: Colors.red)),
          const Divider(height: 32),
          const Text(
            '📋 Dokumen yang Dibutuhkan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          BlocBuilder<HalalWizardCubit, HalalWizardState>(
            builder: (context, state) {
              final stepIndex = 0;
              final checklist = state.documentChecklist[stepIndex] ?? [];
              final labels =
                  HalalWizardState.defaultChecklistLabels[stepIndex] ?? [];
              final checkedCount = checklist.where((c) => c).length;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$checkedCount dari ${labels.length} dokumen siap'),
                  const SizedBox(height: 8),
                  ...List.generate(labels.length, (index) {
                    final isChecked = index < checklist.length
                        ? checklist[index]
                        : false;
                    return Semantics(
                      checked: isChecked,
                      label: 'Checkbox ${labels[index]}',
                      child: CheckboxListTile(
                        title: Text(labels[index]),
                        value: isChecked,
                        activeColor: const Color(0xFFD97706),
                        onChanged: (val) {
                          context.read<HalalWizardCubit>().toggleDocumentCheck(
                            stepIndex,
                            index,
                          );
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    );
                  }),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
