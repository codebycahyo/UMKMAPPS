import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter_laundry_offline_app/data/models/expense_entry.dart';
import 'package:flutter_laundry_offline_app/logic/cubits/expense/expense_cubit.dart';
import 'package:flutter_laundry_offline_app/core/services/ocr_service.dart';

class ScanReceiptScreen extends StatefulWidget {
  const ScanReceiptScreen({super.key});

  @override
  State<ScanReceiptScreen> createState() => _ScanReceiptScreenState();
}

class _ScanReceiptScreenState extends State<ScanReceiptScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _rawText;

  final _itemController = TextEditingController();
  final _nominalController = TextEditingController();
  final _tanggalController = TextEditingController();
  final _supplierController = TextEditingController();
  String _selectedType = 'keluar';

  DateTime _selectedDate = DateTime.now();
  String _source = 'manual';

  @override
  void dispose() {
    _itemController.dispose();
    _nominalController.dispose();
    _tanggalController.dispose();
    _supplierController.dispose();
    super.dispose();
  }

  Future<void> _processImage({ImageSource source = ImageSource.camera}) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _isLoading = true;
      });
      if (mounted) {
        SemanticsService.sendAnnouncement(
          View.of(context),
          'Sedang memproses gambar nota...',
          TextDirection.ltr,
        );
      }

      try {
        final inputImage = InputImage.fromFilePath(pickedFile.path);
        final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
        final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

        _rawText = recognizedText.text;

        final parsedExpense = OcrService.parseReceiptText(_rawText!);

        setState(() {
          _itemController.text = parsedExpense.item;
          _nominalController.text = parsedExpense.nominal.toString();
          _supplierController.text = parsedExpense.supplier ?? '';
          _selectedDate = parsedExpense.tanggal;
          _tanggalController.text = _selectedDate.toLocal().toString().split(' ')[0];
          _selectedType = parsedExpense.type;
          _source = 'ocr';
        });

        textRecognizer.close();
        HapticFeedback.mediumImpact();
        if (mounted) {
          SemanticsService.sendAnnouncement(
            View.of(context),
            'Nota berhasil dipindai. Total Rp ${parsedExpense.nominal}, Toko: ${parsedExpense.supplier ?? "-"}',
            TextDirection.ltr,
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memproses gambar: $e')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _tanggalController.text = _selectedDate.toLocal().toString().split(' ')[0];
      });
    }
  }

  void _saveExpense() {
    if (_formKey.currentState!.validate()) {
      final expense = ExpenseEntry(
        type: _selectedType,
        item: _itemController.text,
        nominal: int.parse(_nominalController.text),
        tanggal: _selectedDate,
        supplier: _supplierController.text,
        source: _source,
        rawText: _rawText,
        createdAt: DateTime.now(),
      );

      context.read<ExpenseCubit>().addExpense(expense);
      HapticFeedback.heavyImpact();
      SemanticsService.sendAnnouncement(
        View.of(context),
        'Catatan transaksi berhasil disimpan.',
        TextDirection.ltr,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Catatan nota berhasil disimpan!'),
          backgroundColor: Color(0xFF0F766E),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Nota Belanja'),
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF0F766E)),
                  SizedBox(height: 16),
                  Text('Membaca teks nota on-device...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Semantics(
                          button: true,
                          label: 'Ambil Foto Nota dari Kamera',
                          child: ElevatedButton.icon(
                            onPressed: () => _processImage(source: ImageSource.camera),
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Kamera'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              backgroundColor: const Color(0xFF0F766E),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Semantics(
                          button: true,
                          label: 'Pilih Foto Nota dari Galeri',
                          child: OutlinedButton.icon(
                            onPressed: () => _processImage(source: ImageSource.gallery),
                            icon: const Icon(Icons.photo_library_rounded),
                            label: const Text('Galeri'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              foregroundColor: const Color(0xFF0F766E),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: _selectedType,
                          decoration: const InputDecoration(
                            labelText: 'Tipe Transaksi',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'masuk', child: Text('Pemasukan')),
                            DropdownMenuItem(value: 'keluar', child: Text('Pengeluaran')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedType = val);
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _itemController,
                          decoration: const InputDecoration(
                            labelText: 'Nama Barang/Jasa',
                            border: OutlineInputBorder(),
                          ),
                          validator: (val) =>
                              val == null || val.isEmpty ? 'Wajib diisi' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nominalController,
                          decoration: const InputDecoration(
                            labelText: 'Nominal (Rp)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Wajib diisi';
                            if (int.tryParse(val) == null) return 'Harus berupa angka valid';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: AbsorbPointer(
                            child: TextFormField(
                              controller: _tanggalController,
                              decoration: const InputDecoration(
                                labelText: 'Tanggal',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                              validator: (val) =>
                                  val == null || val.isEmpty ? 'Wajib diisi' : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _supplierController,
                          decoration: const InputDecoration(
                            labelText: 'Nama Toko/Supplier (Opsional)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Semantics(
                          button: true,
                          label: 'Simpan Catatan',
                          child: ElevatedButton(
                            onPressed: _saveExpense,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              backgroundColor: const Color(0xFF0F766E),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Simpan'),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
