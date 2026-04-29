import 'package:aquasmart/features/home/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController homeC = Get.find<HomeController>();
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(
              () => Text(
                'Hallo, ${homeC.userName.value}',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Monitor your aquarium',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: AppColors.tfPlaceholder,
              ),
            ),
            const SizedBox(height: 24),

            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: double.infinity,
                color: AppColors.primary, // deepOceanBlue = 0xFF0A5C7A
                child: Stack(
                  children: [
                    Positioned(
                      top: -50,
                      right: -60,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.cardAccentLight, // 0xFF0D7298
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -55,
                      left: -55,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.cardAccentDark, // 0xFF085269
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            'Water Temperature',
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Obx(
                                () => Text(
                                  homeC.isLoading.value
                                      ? '--'
                                      : homeC.waterTemperature.value
                                            .toStringAsFixed(1),
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 64,
                                    fontWeight: FontWeight.bold,
                                    height: 1,
                                  ),
                                ),
                              ),
                              Text(
                                '°C',
                                style: GoogleFonts.inter(
                                  color: Colors.white70,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildMetricCard(
                    title: 'pH',
                    value: '7.0',
                    icon: Icons.water_drop_outlined,
                    bgColor: AppColors.seaGreen, // 0xFF2DD4A8
                    textColor: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  _buildMetricCard(
                    title: 'NH₃ ppm',
                    value: '0.0',
                    icon: Icons.show_chart_rounded,
                    bgColor: AppColors.oceanTeal, // 0xFF5A8BA0
                    textColor: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.shakeCardBg, // 0xFFE5E7EB
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.phone_android_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Shake to refresh',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Text(
              'Quick Actions',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 14),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _buildActionCard(
                      title: 'Aqua Catch',
                      subtitle: 'Relax & play',
                      iconAsset: 'assets/icons/Icon_game.svg',
                      iconColor: AppColors.coralOrange, // 0xFFFFA726
                      onTap: () => Get.toNamed('/game'),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildActionCard(
                      title: 'Aquarium Stores',
                      subtitle: 'Find nearby',
                      iconAsset: null,
                      iconData: Icons.location_on_outlined,
                      iconColor: AppColors.locationRed, // 0xFFEA4335
                      onTap: () => Get.toNamed('/maps'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color bgColor,
    required Color textColor,
  }) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          color: bgColor,
          child: Stack(
            children: [
              Positioned(
                top: -23,
                right: -23,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
              ),
              // Konten card
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      icon,
                      color: textColor.withValues(alpha: 0.8),
                      size: 20,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      value,
                      style: GoogleFonts.inter(
                        color: textColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w200,
                        color: textColor.withValues(alpha: 0.9),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    String? iconAsset,
    IconData? iconData,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.tfBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (iconAsset != null)
              SvgPicture.asset(
                iconAsset,
                width: 28,
                height: 28,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              )
            else if (iconData != null)
              Icon(iconData, color: iconColor, size: 28),
            const SizedBox(height: 20),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: GoogleFonts.inter(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                color: AppColors.tfPlaceholder,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
