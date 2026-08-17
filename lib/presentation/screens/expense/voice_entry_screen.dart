import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_laundry_offline_app/core/services/voice_input_service.dart';
import 'package:flutter_laundry_offline_app/core/utils/voice_transaction_parser.dart';
import 'package:flutter_laundry_offline_app/data/models/expense_entry.dart';
import 'package:flutter_laundry_offline_app/logic/cubits/expense/expense_cubit.dart';

class VoiceEntryScreen extends StatefulWidget {
  const VoiceEntryScreen({super.key});

  @override
  State<VoiceEntryScreen> createState() => _VoiceEntryScreenState();
}

class _VoiceEntryScreenState extends State<VoiceEntryScreen>
    with SingleTickerProviderStateMixin {
  final VoiceInputService _voiceService = VoiceInputService();
  final VoiceTransactionParser _parser = VoiceTransactionParser();

  bool _isListening = false;
  String _transcribedText = '';
  VoiceParseResult? _parseResult;

  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _nominalController = TextEditingController();
  String _selectedType = 'keluar';

  @override
  void initState() {
    super.initState();
    _initVoiceService();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initVoiceService() async {
    await _voiceService.init();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _itemController.dispose();
    _nominalController.dispose();
    _voiceService.stopListening();
    super.dispose();
  }

  void _toggleListening() async {
    if (_isListening) {
      await _voiceService.stopListening();
      HapticFeedback.mediumImpact();
      setState(() {
        _isListening = false;
      });
      _animationController.stop();
      _animationController.reset();
      _processTranscription();
    } else {
      if (!_voiceService.isAvailable) {
        bool available = await _voiceService.init();
        if (!available) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Layanan pengenalan suara tidak tersedia.'),
              ),
            );
          }
          return;
        }
      }

      setState(() {
        _transcribedText = '';
        _parseResult = null;
        _isListening = true;
      });
      HapticFeedback.mediumImpact();
      _animationController.repeat(reverse: true);

      await _voiceService.startListening((text) {
        setState(() {
          _transcribedText = text;
        });
      });
    }
  }

  void _processTranscription() {
    if (_transcribedText.isEmpty) return;

    final result = _parser.parseTransaction(_transcribedText);
    setState(() {
      _parseResult = result;

      if (result.entry != null) {
        _itemController.text = result.entry!.item;
        _nominalController.text = result.entry!.nominal.toInt().toString();
        _selectedType = result.entry!.type;
      }
    });

    if (result.feedbackMessage != null &&
        result.feedbackMessage!.isNotEmpty &&
        mounted) {
      SemanticsService.sendAnnouncement(
        View.of(context),
        result.feedbackMessage!,
        TextDirection.ltr,
      );
    }

    if (result.detectedCommand == 'simpan' &&
        result.entry != null &&
        result.entry!.nominal > 0) {
      _saveTransaction();
    } else if (result.detectedCommand == 'batal' ||
        result.detectedCommand == 'kembali') {
      Navigator.pop(context);
    } else if (result.detectedCommand == 'ulangi') {
      setState(() {
        _transcribedText = '';
        _parseResult = null;
        _itemController.clear();
        _nominalController.clear();
      });
      _toggleListening();
    }
  }

  void _saveTransaction() {
    final type = _selectedType;
    final item = _itemController.text.trim();
    final nominalText = _nominalController.text.trim();
    final nominal =
        int.tryParse(nominalText) ??
        (double.tryParse(nominalText)?.toInt() ?? 0);

    if (item.isEmpty || nominal <= 0) {
      final msg = 'Mohon lengkapi data item dan nominal dengan benar.';
      if (mounted) {
        SemanticsService.sendAnnouncement(
          View.of(context),
          msg,
          TextDirection.ltr,
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      return;
    }

    final entry = ExpenseEntry(
      id: null,
      type: type,
      item: item,
      nominal: nominal,
      tanggal: DateTime.now(),
      supplier: '',
      source: 'voice',
      rawText: _transcribedText,
      createdAt: DateTime.now(),
    );

    context.read<ExpenseCubit>().addExpense(entry);
    HapticFeedback.heavyImpact();
    if (mounted) {
      SemanticsService.sendAnnouncement(
        View.of(context),
        'Transaksi berhasil disimpan.',
        TextDirection.ltr,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Transaksi berhasil disimpan.'),
        backgroundColor: Color(0xFF0F766E),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          label: 'Judul Halaman: Catat Suara',
          child: const Text('Catat Suara'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            _buildMicButton(),
            const SizedBox(height: 32),
            _buildTranscribedText(),
            const SizedBox(height: 24),
            _buildResultForm(),
          ],
        ),
      ),
      bottomNavigationBar: _parseResult != null
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Semantics(
                label: 'Tombol Simpan Transaksi',
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    backgroundColor: const Color(0xFF0F766E),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _saveTransaction,
                  child: const Text('Simpan'),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildMicButton() {
    return Center(
      child: Semantics(
        label: _isListening ? 'Berhenti Merekam Suara' : 'Mulai Merekam Suara',
        button: true,
        child: GestureDetector(
          onTap: _toggleListening,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isListening ? _pulseAnimation.value : 1.0,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isListening ? Colors.red : const Color(0xFF0F766E),
                    boxShadow: _isListening
                        ? [
                            BoxShadow(
                              color: Colors.red.withValues(alpha: 0.4),
                              blurRadius: 20,
                              spreadRadius: 10,
                            ),
                          ]
                        : [],
                  ),
                  child: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTranscribedText() {
    return Semantics(
      label: 'Teks yang dikenali',
      child: Container(
        padding: const EdgeInsets.all(16.0),
        constraints: const BoxConstraints(minHeight: 100),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          _transcribedText.isEmpty
              ? 'Tekan tombol mikrofon dan mulai bicara...'
              : _transcribedText,
          style: TextStyle(
            fontSize: 16,
            color: _transcribedText.isEmpty ? Colors.grey[600] : Colors.black87,
            fontStyle: _transcribedText.isEmpty
                ? FontStyle.italic
                : FontStyle.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildResultForm() {
    if (_parseResult == null) return const SizedBox.shrink();

    final confidence = _parseResult!.confidence;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (confidence == 'low') ...[
          Semantics(
            label: 'Peringatan: Periksa kembali data transaksi',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFD97706).withValues(alpha: 0.1),
                border: Border.all(color: const Color(0xFFD97706)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Silakan periksa dan perbaiki detail transaksi di bawah ini.',
                      style: TextStyle(color: Color(0xFFD97706)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (confidence == 'none') ...[
          Semantics(
            label: 'Peringatan: Suara tidak dikenali sebagai transaksi',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                border: Border.all(color: Colors.red),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tidak dapat mengenali transaksi. Silakan masukkan secara manual.',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        Semantics(
          label: 'Pilih Tipe Transaksi',
          child: DropdownButtonFormField<String>(
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
        ),
        const SizedBox(height: 16),
        Semantics(
          label: 'Input Nama Item',
          child: TextFormField(
            controller: _itemController,
            decoration: const InputDecoration(
              labelText: 'Nama Item',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Semantics(
          label: 'Input Nominal',
          child: TextFormField(
            controller: _nominalController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Nominal',
              border: OutlineInputBorder(),
              prefixText: 'Rp ',
            ),
          ),
        ),
      ],
    );
  }
}
