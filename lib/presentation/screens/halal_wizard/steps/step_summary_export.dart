import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart' show SharePlus, ShareParams, XFile;
import '../logic/halal_wizard_cubit.dart';

class StepSummaryExport extends StatefulWidget {
  const StepSummaryExport({super.key});

  @override
  State<StepSummaryExport> createState() => _StepSummaryExportState();
}

class _StepSummaryExportState extends State<StepSummaryExport> {
  bool _isExporting = false;

  Future<void> _generatePdf(
    BuildContext context,
    HalalWizardState state,
  ) async {
    if (!state.setujuPernyataan) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Silakan centang persetujuan pernyataan terlebih dahulu.',
          ),
          backgroundColor: Color(0xFFD97706),
        ),
      );
      return;
    }

    setState(() => _isExporting = true);

    try {
      final pdf = pw.Document();
      final completionPercent = context
          .read<HalalWizardCubit>()
          .getDocumentCompletionPercent();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(36),
          build: (pw.Context pdfContext) {
            return [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'DOKUMEN SELF-DECLARE HALAL SEHATI',
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          'Pendampingan Sertifikasi Halal Usaha Mikro & Kecil (UMKM)',
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ],
                    ),
                    pw.Text(
                      'LegaliKas AI',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.teal700,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              _buildPdfSection('1. Informasi Pelaku Usaha', [
                'Nama Usaha / Toko: ${state.namaUsaha.isEmpty ? "-" : state.namaUsaha}',
                'Nomor Induk Berusaha (NIB): ${state.nib.isEmpty ? "-" : state.nib}',
                'Alamat Usaha: ${state.alamatUsaha.isEmpty ? "-" : state.alamatUsaha}',
                'Nomor Kontak: ${state.teleponUsaha.isEmpty ? "-" : state.teleponUsaha}',
              ]),
              pw.SizedBox(height: 12),

              _buildPdfSection('2. Daftar Bahan Baku & Tambahan', [
                'Bahan Digunakan: ${state.bahanBaku.isEmpty ? "Belum dicatat" : state.bahanBaku.join(", ")}',
                'Bahan Wajib Sertifikat Halal: ${state.bahanWaspada.isEmpty ? "Tidak ada (Bahan Kategori Bebas)" : state.bahanWaspada.join(", ")}',
              ]),
              pw.SizedBox(height: 12),

              _buildPdfSection('3. Proses & Fasilitas Produksi', [
                'Deskripsi Alur: ${state.deskripsiProses.isEmpty ? "-" : state.deskripsiProses}',
                'Tempat Produksi: ${state.tempatProses.isEmpty ? "-" : state.tempatProses}',
                'Fasilitas Bebas dari Non-Halal: ${state.prosesTerpisah ? "Ya (Sesuai Syarat)" : "Tidak"}',
                'Peralatan Terpisah Khusus Produk Halal: ${state.alatTidakBersama ? "Ya (Sesuai Syarat)" : "Tidak"}',
              ]),
              pw.SizedBox(height: 12),

              _buildPdfSection('4. Lokasi Produksi & Higienitas', [
                'Alamat Lokasi: ${state.alamatProduksi.isEmpty ? "-" : state.alamatProduksi}',
                'Status Tempat Usaha: ${state.statusTempat.isEmpty ? "-" : state.statusTempat}',
                'Luas Area Produksi: ${state.luasArea.isEmpty ? "-" : state.luasArea}',
                'Kebersihan dan Sanitasi: ${state.lokasiBersih ? "Terjaga Higienis" : "Perlu Peningkatan"}',
                'Bebas dari Kontaminasi Najis/Haram: ${state.lokasiTerpisahHaram ? "Ya (Aman)" : "Tidak"}',
              ]),
              pw.SizedBox(height: 12),

              _buildPdfSection('5. Kelengkapan Berkas Persyaratan', [
                'Tingkat Kesiapan Dokumen: $completionPercent%',
                ..._getUncheckedDocs(
                  state,
                ).map((doc) => '• Belum Lengkap: $doc'),
              ]),
              pw.SizedBox(height: 20),

              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(6),
                  ),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Surat Pernyataan Pelaku Usaha',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Dengan ini saya menyatakan bahwa seluruh data yang diisikan di atas adalah benar dan sesuai kondisi riil. Produk yang dihasilkan bebas dari bahan haram, najis, dan diproduksi sesuai standar kehalalan yang berlaku.',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'Dibuat oleh Pelaku Usaha,',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      pw.SizedBox(height: 36),
                      pw.Text(
                        state.namaUsaha.isEmpty
                            ? '(...................................)'
                            : state.namaUsaha,
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ];
          },
        ),
      );

      final output = await getApplicationDocumentsDirectory();
      final sanitizedName = state.namaUsaha.replaceAll(
        RegExp(r'[^a-zA-Z0-9]'),
        '_',
      );
      final fileName =
          'Dokumen_Halal_SEHATI_${sanitizedName.isEmpty ? "UMKM" : sanitizedName}.pdf';
      final file = File('${output.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      HapticFeedback.heavyImpact();

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Dokumen Self-Declare Halal SEHATI - ${state.namaUsaha}',
        ),
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dokumen PDF berhasil dibuat: $fileName'),
            backgroundColor: const Color(0xFF0F766E),
            action: SnackBarAction(
              label: 'Buka / Bagikan',
              textColor: Colors.white,
              onPressed: () {
                SharePlus.instance.share(
                  ShareParams(
                    files: [XFile(file.path)],
                    text:
                        'Dokumen Self-Declare Halal SEHATI - ${state.namaUsaha}',
                  ),
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memproses PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  pw.Widget _buildPdfSection(String title, List<String> content) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.teal900,
          ),
        ),
        pw.SizedBox(height: 4),
        ...content.map(
          (text) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 2),
            child: pw.Text(text, style: const pw.TextStyle(fontSize: 9)),
          ),
        ),
      ],
    );
  }

  List<String> _getUncheckedDocs(HalalWizardState state) {
    List<String> missingDocs = [];
    for (int step = 0; step < 5; step++) {
      final checklist = state.documentChecklist[step] ?? [];
      final labels = HalalWizardState.defaultChecklistLabels[step] ?? [];
      for (int i = 0; i < labels.length; i++) {
        if (i < checklist.length && !checklist[i]) {
          missingDocs.add(labels[i]);
        }
      }
    }
    return missingDocs;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HalalWizardCubit, HalalWizardState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ringkasan Data Sertifikasi Halal',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildSectionCard('1. Informasi Usaha', [
                'Nama: ${state.namaUsaha.isEmpty ? "-" : state.namaUsaha}',
                'NIB: ${state.nib.isEmpty ? "-" : state.nib}',
                'Alamat: ${state.alamatUsaha.isEmpty ? "-" : state.alamatUsaha}',
                'Kontak: ${state.teleponUsaha.isEmpty ? "-" : state.teleponUsaha}',
              ]),
              _buildSectionCard('2. Bahan Baku', [
                'Bahan: ${state.bahanBaku.isEmpty ? "-" : state.bahanBaku.join(", ")}',
                if (state.bahanWaspada.isNotEmpty)
                  'Bahan Diwaspadai: ${state.bahanWaspada.join(", ")}',
              ]),
              _buildSectionCard('3. Proses Produksi', [
                'Tempat: ${state.tempatProses.isEmpty ? "-" : state.tempatProses}',
                'Deskripsi: ${state.deskripsiProses.isEmpty ? "-" : state.deskripsiProses}',
              ]),
              _buildSectionCard('4. Lokasi Produksi', [
                'Alamat: ${state.alamatProduksi.isEmpty ? "-" : state.alamatProduksi}',
                'Status: ${state.statusTempat.isEmpty ? "-" : state.statusTempat}',
              ]),
              const SizedBox(height: 24),
              const Text(
                'Pernyataan Pelaku Usaha',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD97706),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Dengan ini saya menyatakan bahwa seluruh informasi di atas adalah benar dan produk yang saya hasilkan tidak mengandung bahan haram/najis.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 16),
              Semantics(
                checked: state.setujuPernyataan,
                label: 'Checkbox Setuju Pernyataan Kehalalan',
                child: CheckboxListTile(
                  title: const Text(
                    'Saya menyetujui pernyataan kehalalan di atas',
                  ),
                  value: state.setujuPernyataan,
                  activeColor: const Color(0xFFD97706),
                  onChanged: (val) {
                    context.read<HalalWizardCubit>().updateStep5Data(
                      setujuPernyataan: val ?? false,
                    );
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
              Builder(
                builder: (context) {
                  final stepIndex = 4;
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
                              context
                                  .read<HalalWizardCubit>()
                                  .toggleDocumentCheck(stepIndex, index);
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
              const Divider(height: 32),
              Builder(
                builder: (context) {
                  final percent = context
                      .read<HalalWizardCubit>()
                      .getDocumentCompletionPercent();
                  final missingDocs = _getUncheckedDocs(state);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status Dokumen: $percent% Lengkap',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: percent == 100 ? Colors.green : Colors.red,
                        ),
                      ),
                      if (missingDocs.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'Dokumen belum lengkap:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ...missingDocs.map(
                          (doc) => Text(
                            '• $doc',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: Semantics(
                  button: true,
                  label: 'Unduh dan Bagikan PDF Self-Declare Halal',
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD97706),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    onPressed: _isExporting
                        ? null
                        : () => _generatePdf(context, state),
                    icon: _isExporting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.download_rounded),
                    label: Text(
                      _isExporting ? 'Memproses PDF...' : 'Unduh & Bagikan PDF',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: Semantics(
                  button: true,
                  label: 'Mulai Ulang Wizard Halal',
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(double.infinity, 48),
                      foregroundColor: const Color(0xFFD97706),
                    ),
                    onPressed: () {
                      context.read<HalalWizardCubit>().resetWizard();
                    },
                    child: const Text('Mulai Ulang Wizard'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionCard(String title, List<String> items) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFD97706),
              ),
            ),
            const Divider(),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(item),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
