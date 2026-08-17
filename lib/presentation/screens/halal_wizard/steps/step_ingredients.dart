import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/halal_wizard_cubit.dart';

class StepIngredients extends StatefulWidget {
  const StepIngredients({super.key});

  @override
  State<StepIngredients> createState() => _StepIngredientsState();
}

class _StepIngredientsState extends State<StepIngredients> {
  late List<TextEditingController> _controllers;
  late List<String> _bahanWaspada;
  final List<String> _waspadaOptions = [
    'Gelatin',
    'Alkohol/Etanol',
    'Lemak Hewani',
    'Enzim',
    'Pewarna',
    'Perisa/Flavor',
    'Emulsifier'
  ];

  @override
  void initState() {
    super.initState();
    final state = context.read<HalalWizardCubit>().state;
    _controllers = state.bahanBaku.isEmpty
        ? [TextEditingController()]
        : state.bahanBaku.map((b) => TextEditingController(text: b)).toList();
    _bahanWaspada = List.from(state.bahanWaspada);

    for (var controller in _controllers) {
      controller.addListener(_updateData);
    }
  }

  void _updateData() {
    final bahanBaku = _controllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    context.read<HalalWizardCubit>().updateStep2Data(
          bahanBaku: bahanBaku,
          bahanWaspada: _bahanWaspada,
        );
  }

  void _addBahan() {
    setState(() {
      final controller = TextEditingController();
      controller.addListener(_updateData);
      _controllers.add(controller);
    });
  }

  void _removeBahan(int index) {
    setState(() {
      _controllers[index].dispose();
      _controllers.removeAt(index);
    });
    _updateData();
  }

  void _toggleWaspada(String bahan, bool? value) {
    setState(() {
      if (value == true) {
        _bahanWaspada.add(bahan);
      } else {
        _bahanWaspada.remove(bahan);
      }
    });
    _updateData();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
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
            'Bahan Baku *',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Masukkan semua bahan baku yang digunakan.'),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _controllers.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Semantics(
                        label: 'Input Bahan Baku ${index + 1}',
                        textField: true,
                        child: TextField(
                          controller: _controllers[index],
                          decoration: InputDecoration(
                            labelText: 'Bahan Baku ${index + 1}',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                    if (_controllers.length > 1)
                      Semantics(
                        button: true,
                        label: 'Hapus Bahan Baku',
                        child: IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () => _removeBahan(index),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Semantics(
            button: true,
            label: 'Tambah Bahan Baku Baru',
            child: TextButton.icon(
              onPressed: _addBahan,
              icon: const Icon(Icons.add),
              label: const Text('+ Tambah Bahan Baku'),
            ),
          ),
          const Divider(height: 32),
          const Text(
            'Bahan yang Perlu Diwaspadai',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Centang jika usaha Anda menggunakan bahan-bahan berikut:',
          ),
          const SizedBox(height: 8),
          if (_bahanWaspada.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 8),
              color: Colors.orange.shade100,
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Perhatian: Bahan yang dicentang perlu dipastikan kehalalannya',
                      style: TextStyle(color: Colors.deepOrange),
                    ),
                  ),
                ],
              ),
            ),
          ..._waspadaOptions.map((bahan) {
            return Semantics(
              checked: _bahanWaspada.contains(bahan),
              label: 'Checkbox $bahan',
              child: CheckboxListTile(
                title: Text(bahan),
                value: _bahanWaspada.contains(bahan),
                onChanged: (val) => _toggleWaspada(bahan, val),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            );
          }),
          const Divider(height: 32),
          const Text(
            '📋 Dokumen yang Dibutuhkan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          BlocBuilder<HalalWizardCubit, HalalWizardState>(
            builder: (context, state) {
              final stepIndex = 1;
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
