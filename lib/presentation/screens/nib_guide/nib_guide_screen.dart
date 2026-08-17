import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_laundry_offline_app/core/theme/app_theme.dart';

class NibGuideScreen extends StatefulWidget {
  const NibGuideScreen({super.key});

  @override
  State<NibGuideScreen> createState() => _NibGuideScreenState();
}

class _NibGuideScreenState extends State<NibGuideScreen> {
  final List<Map<String, dynamic>> _documents = [
    {'title': 'KTP Pemilik Usaha', 'isChecked': false},
    {'title': 'NPWP (jika sudah punya)', 'isChecked': false},
    {'title': 'Alamat lengkap usaha', 'isChecked': false},
    {'title': 'Email aktif', 'isChecked': false},
    {'title': 'Nomor telepon aktif', 'isChecked': false},
    {'title': 'Pas foto pemilik (digital)', 'isChecked': false},
  ];

  bool _isWhyNibExpanded = true;

  int get _readyDocsCount =>
      _documents.where((doc) => doc['isChecked'] as bool).length;

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak dapat membuka tautan')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panduan NIB'),
        backgroundColor: AppThemeColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeroCard(),
            _buildWhyNibSection(),
            _buildDocumentsSection(),
            _buildStepsSection(),
            _buildActionButtons(),
            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: AppThemeColors.primaryGradient,
        borderRadius: AppRadius.lgRadius,
        boxShadow: AppShadows.primaryShadow,
      ),
      child: Column(
        children: [
          Semantics(
            label: 'Ikon Tas Kerja',
            child: const Icon(
              Icons.business_center_rounded,
              size: 64,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Nomor Induk Berusaha (NIB)',
            style: AppTypography.headlineMedium.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'NIB adalah identitas pelaku usaha yang diterbitkan oleh Lembaga OSS. Setiap UMKM wajib memiliki NIB untuk legalitas usaha.',
            style: AppTypography.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWhyNibSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdRadius,
          side: const BorderSide(color: AppThemeColors.border),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: _isWhyNibExpanded,
            onExpansionChanged: (expanded) {
              setState(() {
                _isWhyNibExpanded = expanded;
              });
            },
            title: Text(
              'Mengapa NIB Penting?',
              style: AppTypography.titleLarge,
            ),
            childrenPadding: const EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: AppSpacing.lg,
            ),
            children: [
              _buildBenefitItem(
                Icons.verified_rounded,
                'Syarat pengajuan sertifikasi halal SEHATI',
              ),
              _buildBenefitItem(
                Icons.gavel_rounded,
                'Syarat mengikuti tender/pengadaan pemerintah',
              ),
              _buildBenefitItem(
                Icons.account_balance_rounded,
                'Akses ke pembiayaan & kredit usaha dari bank',
              ),
              _buildBenefitItem(
                Icons.shield_rounded,
                'Perlindungan hukum bagi usaha Anda',
              ),
              _buildBenefitItem(
                Icons.money_off_rounded,
                'Gratis dan mudah diurus secara online',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppThemeColors.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(text, style: AppTypography.bodyMedium)),
        ],
      ),
    );
  }

  Widget _buildDocumentsSection() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dokumen yang Dibutuhkan', style: AppTypography.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '$_readyDocsCount dari ${_documents.length} dokumen siap',
            style: AppTypography.bodySmall.copyWith(
              color: _readyDocsCount == _documents.length
                  ? AppThemeColors.success
                  : AppThemeColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.mdRadius,
              side: const BorderSide(color: AppThemeColors.border),
            ),
            child: Column(
              children: List.generate(_documents.length, (index) {
                final doc = _documents[index];
                return Semantics(
                  label: 'Dokumen ${doc['title']}',
                  checked: doc['isChecked'] as bool,
                  child: CheckboxListTile(
                    title: Text(
                      doc['title'] as String,
                      style: AppTypography.bodyMedium.copyWith(
                        decoration: doc['isChecked'] as bool
                            ? TextDecoration.lineThrough
                            : null,
                        color: doc['isChecked'] as bool
                            ? AppThemeColors.textHint
                            : AppThemeColors.textPrimary,
                      ),
                    ),
                    value: doc['isChecked'] as bool,
                    activeColor: AppThemeColors.primary,
                    onChanged: (bool? value) {
                      setState(() {
                        _documents[index]['isChecked'] = value ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsSection() {
    final List<String> steps = [
      'Buka portal OSS di oss.go.id',
      'Buat akun atau login dengan NIK',
      'Pilih menu \'Perizinan Berusaha\'',
      'Isi data usaha sesuai formulir',
      'Unggah dokumen yang diminta',
      'Submit dan tunggu verifikasi',
      'Unduh NIB setelah disetujui',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Langkah-Langkah Pengurusan NIB',
            style: AppTypography.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          ...List.generate(steps.length, (index) {
            return Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.mdRadius,
                side: const BorderSide(color: AppThemeColors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppThemeColors.accentSurface,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: AppTypography.titleMedium.copyWith(
                            color: AppThemeColors.accent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        steps[index],
                        style: AppTypography.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            button: true,
            label: 'Buka Portal OSS',
            child: ElevatedButton(
              onPressed: () => _launchUrl('https://oss.go.id'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Buka Portal OSS'),
            ),
          ),
          Semantics(
            button: true,
            label: 'Panduan Resmi Perizinan OSS',
            child: OutlinedButton.icon(
              icon: const Icon(Icons.menu_book_rounded),
              onPressed: () => _launchUrl('https://oss.go.id/panduan'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                foregroundColor: AppThemeColors.primary,
              ),
              label: const Text('Panduan Lengkap di oss.go.id'),
            ),
          ),
        ],
      ),
    );
  }
}
