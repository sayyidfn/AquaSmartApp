import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import 'tools_controller.dart';

class ToolsView extends StatelessWidget {
  const ToolsView({super.key});

  @override
  Widget build(BuildContext context) {
    final ToolsController controller = Get.find<ToolsController>();

    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Tools',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Convert currency, check time, and scan fish health',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.tfPlaceholder,
                ),
              ),
              const SizedBox(height: 32),

              _buildCurrencyCard(controller),
              const SizedBox(height: 24),
              _buildFishHealthCard(controller),
              const SizedBox(height: 24),
              _buildWorldClockCard(controller),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  // Widget kartu kurs mata uang
  Widget _buildCurrencyCard(ToolsController controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.tfBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.calculate_outlined,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Currency Converter',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Convert prices when buying aquarium equipment from international suppliers',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.tfPlaceholder,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.tfBorder),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInputLabel('Amount'),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.tfBackground,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.tfBorder),
                  ),
                  child: TextField(
                    controller: controller.amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: false,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: AppColors.textDark,
                    ),
                    decoration: const InputDecoration(
                      hintText: '0.00',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputLabel('From'),
                          _buildRealDropdown(controller, true),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputLabel('To'),
                          _buildRealDropdown(controller, false),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => controller.convertCurrency(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'CONVERT',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Obx(
                    () => Text(
                      controller.conversionResult.value,
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.seaGreen,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Container(
                //   padding: const EdgeInsets.all(16),
                //   decoration: BoxDecoration(
                //     color: AppColors.seaGreen.withValues(alpha: 0.8),
                //     borderRadius: BorderRadius.circular(10),
                //   ),
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       Row(
                //         children: [
                //           const Icon(
                //             Icons.lightbulb,
                //             color: Colors.white,
                //             size: 16,
                //           ),
                //           const SizedBox(width: 8),
                //           Text(
                //             'Common Equipment Prices',
                //             style: GoogleFonts.inter(
                //               fontWeight: FontWeight.bold,
                //               color: AppColors.primary,
                //             ),
                //           ),
                //         ],
                //       ),
                //       const SizedBox(height: 12),
                //       _buildPriceRow('Heater (100W)', '\$25 - \$45'),
                //       const SizedBox(height: 8),
                //       _buildPriceRow('Filter (External)', '\$60 - \$120'),
                //       const SizedBox(height: 8),
                //       _buildPriceRow('LED Light', '\$35 - \$80'),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget kartu fish health scanner
  Widget _buildFishHealthCard(ToolsController controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.tfBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header kartu
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.biotech_outlined,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fish Health Scanner',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Use a camera or photo gallery to identify fish diseases',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.tfPlaceholder,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.tfBorder),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Obx(() {
              return Column(
                children: [
                  // Area preview gambar
                  GestureDetector(
                    onTap: () => controller.resetScan(),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppColors.tfBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: controller.scanImagePath.value.isNotEmpty
                              ? AppColors.primary
                              : AppColors.tfBorder,
                          width: 1.5,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: controller.scanImagePath.value.isNotEmpty
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.file(
                                  File(controller.scanImagePath.value),
                                  fit: BoxFit.cover,
                                ),
                                // Overlay tombol ganti gambar
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.5,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close_rounded,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.add_photo_alternate_outlined,
                                  size: 48,
                                  color: AppColors.tfPlaceholder,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Pilih foto ikan untuk dianalisis',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: AppColors.tfPlaceholder,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tombol kamera dan galeri
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: controller.isAnalyzing.value
                              ? null
                              : () => controller.pickImageAndAnalyze(
                                  ImageSource.camera,
                                ),
                          icon: const Icon(
                            Icons.camera_alt_outlined,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          label: Text(
                            'Kamera',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: AppColors.tfBorder),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: controller.isAnalyzing.value
                              ? null
                              : () => controller.pickImageAndAnalyze(
                                  ImageSource.gallery,
                                ),
                          icon: const Icon(
                            Icons.photo_library_outlined,
                            size: 18,
                            color: AppColors.pureWhite,
                          ),
                          label: Text(
                            'Galeri',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              color: AppColors.pureWhite,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Indikator loading saat analisis berjalan
                  if (controller.isAnalyzing.value)
                    Column(
                      children: [
                        const SizedBox(
                          height: 36,
                          width: 36,
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 3,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Menganalisis gambar...',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.tfPlaceholder,
                          ),
                        ),
                      ],
                    ),

                  // Kartu hasil deteksi
                  if (controller.isResultReady.value)
                    _buildResultCard(controller),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // Widget kartu hasil deteksi penyakit
  Widget _buildResultCard(ToolsController controller) {
    final String label = controller.diseaseLabel.value;
    final double confidence = controller.diseaseConfidence.value;
    final String advice = controller.diseaseAdvice;

    final Color resultColor;
    final IconData resultIcon;

    switch (label) {
      case 'Sehat':
        resultColor = AppColors.seaGreen;
        resultIcon = Icons.check_circle_rounded;
        break;
      case 'Bercak Merah':
        resultColor = AppColors.coralOrange;
        resultIcon = Icons.warning_rounded;
        break;
      case 'Jamur':
        resultColor = AppColors.dangerRed;
        resultIcon = Icons.dangerous_rounded;
        break;
      default:
        resultColor = AppColors.tfPlaceholder;
        resultIcon = Icons.help_outline_rounded;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: resultColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: resultColor.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Icon(resultIcon, color: resultColor, size: 40),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: resultColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Kepercayaan: ${confidence.toStringAsFixed(1)}%',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.tfPlaceholder,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              advice,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textDark,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // Widget kartu world clock
  Widget _buildWorldClockCard(ToolsController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.tfBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.access_time,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'World Clock',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Coordinate with fish breeders and suppliers across different time zones',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.tfPlaceholder,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Obx(
            () => Column(
              children: [
                _buildTimeItem(
                  '🇬🇧',
                  'London, UK',
                  'Discus Farms',
                  controller.timeLondon.value,
                ),
                _buildTimeItem(
                  '🇮🇩',
                  'Jakarta (WIB)',
                  'Local Breeders',
                  controller.timeWIB.value,
                ),
                _buildTimeItem(
                  '🇮🇩',
                  'Makassar (WITA)',
                  'Shrimp Suppliers',
                  controller.timeWITA.value,
                ),
                _buildTimeItem(
                  '🇮🇩',
                  'Jayapura (WIT)',
                  'Coral Farms',
                  controller.timeWIT.value,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget helper: dropdown mata uang
  Widget _buildRealDropdown(ToolsController controller, bool isFrom) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.tfBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.tfBorder),
      ),
      child: Obx(
        () => DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: isFrom
                ? controller.selectedFrom.value
                : controller.selectedTo.value,
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.tfPlaceholder,
            ),
            items: controller.currencies.map((String currency) {
              return DropdownMenuItem<String>(
                value: currency,
                child: Text(
                  currency,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                if (isFrom) {
                  controller.selectedFrom.value = newValue;
                } else {
                  controller.selectedTo.value = newValue;
                }
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.inter(fontSize: 12, color: AppColors.tfPlaceholder),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildPriceRow(String item, String price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          item,
          style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary),
        ),
        Text(
          price,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeItem(
    String flag,
    String title,
    String subtitle,
    String time,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.tfBackground.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.tfBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(flag, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.tfPlaceholder,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            time.isNotEmpty
                ? time.substring(0, 5)
                : '--:--', // Mengambil HH:mm saja dari HH:mm:ss
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w300,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
