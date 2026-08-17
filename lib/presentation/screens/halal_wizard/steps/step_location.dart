import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/halal_wizard_cubit.dart';

class StepLocation extends StatefulWidget {
  const StepLocation({super.key});

  @override
  State<StepLocation> createState() => _StepLocationState();
}

class _StepLocationState extends State<StepLocation> {
  late TextEditingController _alamatController;
  late TextEditingController _luasController;
  String _statusTempat = 'Milik Sendiri';
  bool _lokasiBersih = false;
  bool _lokasiTerpisah = false;

  final List<String> _statusOptions = ['Milik Sendiri', 'Sewa', 'Pinjam'];

  @override
  void initState() {
    super.initState();
    final state = context.read<HalalWizardCubit>().state;
    _alamatController = TextEditingController(text: state.alamatProduksi);
    _luasController = TextEditingController(text: state.luasArea);
    _statusTempat = state.statusTempat;
    if (!_statusOptions.contains(_statusTempat)) {
      _statusTempat = _statusOptions.first;
    }
    _lokasiBersih = state.lokasiBersih;
    _lokasiTerpisah = state.lokasiTerpisahHaram;

    _alamatController.addListener(_updateData);
    _luasController.addListener(_updateData);
  }

  void _updateData() {
    context.read<HalalWizardCubit>().updateStep4Data(
      alamatProduksi: _alamatController.text,
      statusTempat: _statusTempat,
      luasArea: _luasController.text,
      lokasiBersih: _lokasiBersih,
      lokasiTerpisahHaram: _lokasiTerpisah,
    );
  }

  @override
  void dispose() {
    _alamatController.dispose();
    _luasController.dispose();
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
            'Lokasi Produksi',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Semantics(
            label: 'Input Alamat Lokasi Produksi',
            textField: true,
            child: TextField(
              controller: _alamatController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Alamat lokasi produksi *',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Semantics(
            label: 'Dropdown Status Tempat',
            child: DropdownButtonFormField<String>(
              initialValue: _statusTempat,
              decoration: const InputDecoration(
                labelText: 'Status Tempat',
                border: OutlineInputBorder(),
              ),
              items: _statusOptions.map((status) {
                return DropdownMenuItem(value: status, child: Text(status));
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _statusTempat = val);
                  _updateData();
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          Semantics(
            label: 'Input Luas Area Produksi',
            textField: true,
            child: TextField(
              controller: _luasController,
              decoration: const InputDecoration(
                labelText: 'Luas area produksi (Opsional)',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Kondisi Lokasi:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Semantics(
            checked: _lokasiBersih,
            label: 'Checkbox Lokasi produksi bersih',
            child: CheckboxListTile(
              title: const Text('Lokasi produksi bersih dan higienis'),
              value: _lokasiBersih,
              onChanged: (val) {
                setState(() => _lokasiBersih = val ?? false);
                _updateData();
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ),
          Semantics(
            checked: _lokasiTerpisah,
            label: 'Checkbox Lokasi terpisah dari barang haram',
            child: CheckboxListTile(
              title: const Text(
                'Terpisah dari tempat yang memproduksi barang haram',
              ),
              value: _lokasiTerpisah,
              onChanged: (val) {
                setState(() => _lokasiTerpisah = val ?? false);
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
              final stepIndex = 3;
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
