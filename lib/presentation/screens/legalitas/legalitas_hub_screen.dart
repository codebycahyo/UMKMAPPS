import 'package:flutter/material.dart';
import 'package:flutter_laundry_offline_app/core/theme/app_theme.dart';
import 'package:flutter_laundry_offline_app/presentation/screens/halal_wizard/halal_wizard_screen.dart';
import 'package:flutter_laundry_offline_app/presentation/screens/nib_guide/nib_guide_screen.dart';

class LegalitasHubScreen extends StatelessWidget {
  const LegalitasHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeColors.background,
      appBar: AppBar(
        title: const Text('Pusat Legalitas & Kepatuhan'),
        backgroundColor: AppThemeColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                gradient: AppThemeColors.primaryGradient,
                borderRadius: AppRadius.lgRadius,
                boxShadow: AppShadows.primaryShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: AppRadius.mdRadius,
                        ),
                        child: const Icon(
                          Icons.verified_user_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Legalitas Usaha UMKM',
                              style: AppTypography.titleLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Lengkap, mudah, dan terstruktur',
                              style: AppTypography.bodySmall.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Kelola izin usaha (NIB) dan sertifikasi halal mandiri (SEHATI) untuk meningkatkan kepercayaan konsumen dan memenuhi standar legalitas resmi.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.95),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            Text(
              'Layanan Legalitas',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Card 1: Wizard Halal SEHATI
            _buildServiceCard(
              context: context,
              icon: Icons.verified_rounded,
              iconColor: const Color(0xFFD97706),
              title: 'Wizard Self-Declare Halal SEHATI',
              subtitle:
                  'Panduan 5 langkah pengisian draf sertifikasi halal gratis & unduh dokumen PDF siap ajukan.',
              tag: 'Sertifikasi Halal',
              tagColor: const Color(0xFFD97706),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HalalWizardScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: AppSpacing.lg),

            // Card 2: Panduan NIB OSS
            _buildServiceCard(
              context: context,
              icon: Icons.business_center_rounded,
              iconColor: AppThemeColors.primary,
              title: 'Panduan & Checklist NIB OSS',
              subtitle:
                  'Checklist syarat dokumen (KTP, NPWP, foto) dan langkah pendaftaran resmi di oss.go.id.',
              tag: 'Nomor Induk Berusaha',
              tagColor: AppThemeColors.primary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NibGuideScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Info Card
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.mdRadius,
                border: Border.all(color: AppThemeColors.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppThemeColors.textSecondary,
                    size: 24,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mengapa Legalitas Penting?',
                          style: AppTypography.titleSmall.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Dengan NIB dan Sertifikasi Halal, usaha Anda berhak mengakses pembiayaan perbankan (KUR), mengikuti program bantuan pemerintah, dan memperluas jangkauan pasar modern.',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppThemeColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String tag,
    required Color tagColor,
    required VoidCallback onTap,
  }) {
    return Semantics(
      label: '$title. $subtitle. Tag: $tag',
      button: true,
      child: Material(
        color: Colors.white,
        borderRadius: AppRadius.lgRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.lgRadius,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              borderRadius: AppRadius.lgRadius,
              border: Border.all(color: AppThemeColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.1),
                        borderRadius: AppRadius.mdRadius,
                      ),
                      child: Icon(icon, color: iconColor, size: 28),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: tagColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              tag,
                              style: AppTypography.labelSmall.copyWith(
                                color: tagColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            title,
                            style: AppTypography.titleSmall.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: AppThemeColors.textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppThemeColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
