import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_laundry_offline_app/core/theme/app_theme.dart';
import 'package:flutter_laundry_offline_app/data/models/expense_entry.dart';
import 'package:flutter_laundry_offline_app/logic/cubits/expense/expense_cubit.dart';

class ManualEntryScreen extends StatefulWidget {
  const ManualEntryScreen({super.key});

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  final _formKey = GlobalKey<FormState>();

  String _type = 'keluar';
  String _item = '';
  String _nominalText = '';
  DateTime _tanggal = DateTime.now();
  String? _supplier;
  String? _kategori;

  final List<String> _kategoriList = [
    'Bahan Baku',
    'Operasional',
    'Gaji',
    'Lainnya',
  ];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _tanggal) {
      setState(() {
        _tanggal = picked;
      });
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final int nominal =
          int.tryParse(_nominalText.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

      final entry = ExpenseEntry(
        type: _type,
        item: _item,
        nominal: nominal,
        tanggal: _tanggal,
        supplier: _supplier,
        source: 'manual',
        rawText: _kategori != null ? 'Kategori: $_kategori' : null,
        createdAt: DateTime.now(),
      );

      context.read<ExpenseCubit>().addExpense(entry);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Transaksi berhasil disimpan',
            style: AppTypography.bodyMedium.copyWith(color: Colors.white),
          ),
          backgroundColor: AppThemeColors.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Input Manual',
          style: AppTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppThemeColors.textPrimary),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Semantics(
                label: 'Tipe Transaksi',
                child: DropdownButtonFormField<String>(
                  initialValue: _type,
                  decoration: InputDecoration(
                    labelText: 'Tipe Transaksi',
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.mdRadius,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'keluar',
                      child: Text('Pengeluaran'),
                    ),
                    DropdownMenuItem(value: 'masuk', child: Text('Pemasukan')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _type = val);
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Semantics(
                label: 'Nama Item',
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Nama Item',
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.mdRadius,
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Nama item harus diisi'
                      : null,
                  onSaved: (value) => _item = value ?? '',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Semantics(
                label: 'Nominal',
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Nominal (Rp)',
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.mdRadius,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) => value == null || value.isEmpty
                      ? 'Nominal harus diisi'
                      : null,
                  onSaved: (value) => _nominalText = value ?? '',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Semantics(
                label: 'Pilih Tanggal',
                button: true,
                child: InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Tanggal',
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.mdRadius,
                      ),
                    ),
                    child: Text(
                      '${_tanggal.day}/${_tanggal.month}/${_tanggal.year}',
                      style: AppTypography.bodyLarge,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Semantics(
                label: 'Supplier atau Toko',
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Supplier/Toko (Opsional)',
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.mdRadius,
                    ),
                  ),
                  onSaved: (value) => _supplier = value,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Semantics(
                label: 'Kategori',
                child: DropdownButtonFormField<String>(
                  initialValue: _kategori,
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.mdRadius,
                    ),
                  ),
                  items: _kategoriList.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() => _kategori = val);
                  },
                  onSaved: (val) => _kategori = val,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Semantics(
                button: true,
                label: 'Simpan Transaksi',
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppThemeColors.primary,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.mdRadius,
                    ),
                  ),
                  child: Text(
                    'Simpan',
                    style: AppTypography.button.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
