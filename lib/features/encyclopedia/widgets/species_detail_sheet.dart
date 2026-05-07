import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/species_model.dart';

class SpeciesDetailSheet extends StatelessWidget {
  final SpeciesModel species;

  const SpeciesDetailSheet({super.key, required this.species});

  // Fungsi untuk membuka Wikipedia
  Future<void> _launchWiki() async {
    if (species.wikiUrl.isNotEmpty) {
      final Uri url = Uri.parse(species.wikiUrl);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        debugPrint('Could not launch $url');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.tfBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        species.name,
                        style: GoogleFonts.inter(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        species.family,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: AppColors.tfPlaceholder,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.tfBackground,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.tfBorder),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: AppColors.tfPlaceholder,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              species.description,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textDark.withValues(alpha: 0.75),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 20),

            // KOTAK KLASIFIKASI BIOLOGI (DATA ASLI DARI API)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.tfBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.tfBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scientific Classification',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _careRow('Status', species.status),
                  _careRow('Class', species.fishClass),
                  _careRow('Order', species.fishOrder),
                  _careRow('Family', species.family),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // TOMBOL WIKIPEDIA
            if (species.wikiUrl.isNotEmpty)
              ElevatedButton.icon(
                onPressed: _launchWiki,
                icon: const Icon(Icons.language, color: Colors.white, size: 20),
                label: Text(
                  'Read on Wikipedia',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _careRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: AppColors.primary)),
          Text(
            '$label: ',
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textDark),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}