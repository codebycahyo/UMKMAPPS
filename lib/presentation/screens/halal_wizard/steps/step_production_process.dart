import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/halal_wizard_cubit.dart';

class StepProductionProcess extends StatefulWidget {
  const StepProductionProcess({super.key});

  @override
  State<StepProductionProcess> createState() => _StepProductionProcessState();
}

class _StepProductionProcessState extends State<StepProductionProcess> {
  late TextEditingController _deskripsiController;
  late TextEditingController _tempatController;
  bool _prosesTerpisah = false;
  bool _alatTidakBersama = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<HalalWizardCubit>().state;
    _deskripsiController = TextEditingController(text: state.deskripsiProses);
    _tempatController = TextEditingController(text: state.tempatProses);
    _prosesTerpisah = state.prosesTerpisah;
    _alatTidakBersama = state.alatTidakBersama;

    _deskripsiController.addListener(_updateData);
    _tempatController.addListener(_updateData);
  }

  void _updateData() {
    context.read<HalalWizardCubit>().updateStep3Data(
          deskripsiProses: _deskripsiController.text,
          tempatProses: _tempatController.text,
          prosesTerpisah: _prosesTerpisah,
          alatTidakBersama: _alatTidakBersama,
        );
  }

  @override
  void dispose() {
    _deskripsiController.dispose();
    _tempatController.dispose();
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
            'Proses Produksi',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Semantics(
            label: 'Input Deskripsi Proses Produksi',
            textField: true,
            child: TextField(
              controller: _deskripsiController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Deskripsi singkat proses produksi *',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Semantics(
            label: 'Input Tempat atau Area Produksi',
            textField: true,
            child: TextField(
              controller: _tempatController,
              decoration: const InputDecoration(
                labelText: 'Tempat/area produksi *',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Pernyataan Produksi:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Semantics(
            checked: _prosesTerpisah,
            label: 'Checkbox Proses produksi terpisah',
            child: CheckboxListTile(
              title: const Text('Proses produksi terpisah dari bahan non-halal'),
              value: _prosesTerpisah,
              onChanged: (val) {
                setState(() => _prosesTerpisah = val ?? false);
                _updateData();
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ),
          Semantics(
            checked: _alatTidakBersama,
            label: 'Checkbox Peralatan tidak digunakan bersama',
            child: CheckboxListTile(
              title: const Text('Peralatan tidak digunakan bersama produk non-halal'),
              value: _alatTidakBersama,
              onChanged: (val) {
                setState(() => _alatTidakBersama = val ?? false);
                _updateData();
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ),
          const Divider(height: 32),
          const Text(
            '📋 Dokumen yang Dibutuhkan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          BlocBuilder<HalalWizardCubit, HalalWizardState>(
            builder: (context, state) {
              final stepIndex = 2;
              final checklist = state.documentChecklist[stepIndex] ?? [];
              final labels = HalalWizardState.defaultChecklistLabels[stepIndex] ?? [];
              final checkedCount = checklist.where((c) => c).length;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$checkedCount dari ${labels.length} dokumen siap'),
                  const SizedBox(height: 8),
                  ...List.generate(labels.length, (index) {
                    final isChecked = index < checklist.length ? checklist[index] : false;
                    return Semantics(
                      checked: isChecked,
                      label: 'Checkbox ${labels[index]}',
                      child: CheckboxListTile(
                        title: Text(labels[index]),
                        value: isChecked,
                        activeColor: const Color(0xFFD97706),
                        onChanged: (val) {
                          context.read<HalalWizardCubit>().toggleDocumentCheck(stepIndex, index);
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
