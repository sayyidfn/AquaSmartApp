import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flame/game.dart';
import '../../core/theme/app_colors.dart';
import 'game_controller.dart';
import 'aqua_catch_game.dart';

class GameView extends StatelessWidget {
  const GameView({super.key});

  @override
  Widget build(BuildContext context) {
    final GameController controller = Get.put(GameController());

    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      body: SafeArea(
        // KITA BUNGKUS DENGAN STACK AGAR BISA MENUMPUK POP-UP DI ATAS GAME
        child: Stack(
          children: [
            // --- LAYER 1: HUD & GAME FLAME ---
            Column(
              children: [
                // --- 1. TOP HUD ---
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  color: AppColors
                      .pureWhite, // Sesuaikan dengan warna background header Anda
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // KIRI: Deretan Hati (Nyawa)
                      Obx(
                        () => Row(
                          children: List.generate(
                            3,
                            (index) => Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Icon(
                                Icons.favorite_rounded,
                                size: 26,
                                color: index < controller.hearts.value
                                    ? AppColors.dangerRed
                                    : Colors.grey.shade300,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // TENGAH: Score & High Score (Horizontal)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Current Score
                          Text(
                            'SCORE ',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          Obx(
                            () => Text(
                              '${controller.score.value}',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.gameScoreText,
                              ),
                            ),
                          ), // Gunakan warna biru gelap

                          const SizedBox(
                            width: 12,
                          ), // Jarak antara Score dan High Score
                          // High Score
                          Text(
                            'HI: ',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          Obx(
                            () => Text(
                              '${controller.highScore.value}',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.gameScoreText,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // KANAN: Tombol Exit Bulat
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                        child: IconButton(
                          iconSize: 20,
                          constraints:
                              const BoxConstraints(), // Menghilangkan padding bawaan agar lingkaran rapi
                          padding: const EdgeInsets.all(6),
                          icon: Icon(
                            Icons.close_rounded,
                            color: Colors.grey.shade600,
                          ),
                          onPressed: () => Get.back(),
                        ),
                      ),
                    ],
                  ),
                ),
                // Kanvas Game
                Expanded(
                  child: ClipRRect(
                    child: Stack(
                      children: [
                        GameWidget(game: AquaCatchGame(controller)),

                        // --- TAMBAHAN: OVERLAY SIANG/MALAM ---
                        Obx(
                          () => IgnorePointer(
                            // Agar sentuhan tetap tembus ke game
                            child: AnimatedContainer(
                              duration: const Duration(
                                seconds: 2,
                              ), // Transisi halus 2 detik
                              width: double.infinity,
                              height: double.infinity,
                              // Warna hitam dengan opacity yang diatur oleh lux sensor
                              color: Colors.black.withValues(
                                alpha: controller.nightOverlayOpacity,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // --- LAYER 2: OVERLAY GAME OVER (Ide Anda) ---
            Obx(() {
              // Hanya muncul jika isGameOver = true
              if (controller.isGameOver.value) {
                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black.withValues(
                    alpha: 0.7,
                  ), // Latar belakang gelap
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppColors.pureWhite,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'GAME OVER',
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.dangerRed,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Final Score',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: AppColors.tfPlaceholder,
                            ),
                          ),
                          Text(
                            '${controller.score.value}',
                            style: GoogleFonts.inter(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // TOMBOL RESTART
                          ElevatedButton.icon(
                            onPressed: () {
                              controller.resetGame(); // Panggil fungsi reset
                            },
                            icon: const Icon(
                              Icons.refresh_rounded,
                              color: AppColors.pureWhite,
                            ),
                            label: Text(
                              'PLAY AGAIN',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                color: AppColors.pureWhite,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.seaGreen,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              // Jika game masih berjalan, overlay ini hilang (kosong)
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }
}
