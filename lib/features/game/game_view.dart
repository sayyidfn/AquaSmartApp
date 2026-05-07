import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flame/game.dart';
import '../../core/theme/app_colors.dart';
import 'game_controller.dart';
import 'aqua_catch_game.dart';

class GameView extends StatefulWidget {
  const GameView({super.key});

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  late final GameController _controller;
  late final AquaCatchGame _game;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<GameController>();
    _game = AquaCatchGame(_controller);
    // Pasang callback reset Flame ke controller
    _controller.attachFlameGameReset(_game.resetAll);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      body: SafeArea(
        child: Stack(
          children: [
            // Layer 1: HUD atas + kanvas game
            Column(
              children: [
                // Top HUD: nyawa, skor, tombol keluar
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  color: AppColors.pureWhite,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Ikon nyawa (hati)
                      Obx(
                        () => Row(
                          children: List.generate(
                            3,
                            (index) => Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Icon(
                                Icons.favorite_rounded,
                                size: 26,
                                color: index < _controller.hearts.value
                                    ? AppColors.dangerRed
                                    : Colors.grey.shade300,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Skor + Multiplier/Streak badge
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'SCORE ',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              Obx(
                                () => Text(
                                  '${_controller.score.value}',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.gameScoreText,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'HI: ',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              Obx(
                                () => Text(
                                  '${_controller.highScore.value}',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.gameScoreText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Badge streak dan multiplier, muncul jika streak > 0
                          Obx(() {
                            final int streak = _controller.streak.value;
                            final int multi = _controller.multiplier.value;
                            if (streak == 0) return const SizedBox.shrink();
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.only(top: 3),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: multi >= 3
                                    ? AppColors.dangerRed
                                    : multi == 2
                                        ? AppColors.coralOrange
                                        : AppColors.seaGreen,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                multi > 1
                                    ? 'x$multi  STREAK $streak'
                                    : 'STREAK $streak',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          }),
                        ],
                      ),

                      // Tombol keluar
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.tfBorder,
                            width: 1.5,
                          ),
                        ),
                        child: IconButton(
                          iconSize: 20,
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(6),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: AppColors.tfPlaceholder,
                          ),
                          onPressed: () => Get.back(),
                        ),
                      ),
                    ],
                  ),
                ),

                // Kanvas game + overlay siang/malam
                Expanded(
                  child: ClipRRect(
                    child: Stack(
                      children: [
                        // Flame game yang sudah stable (dibuat sekali di initState)
                        GameWidget(game: _game),

                        // Overlay gelap berdasarkan sensor cahaya (lux)
                        Obx(
                          () => IgnorePointer(
                            child: AnimatedContainer(
                              duration: const Duration(seconds: 2),
                              width: double.infinity,
                              height: double.infinity,
                              color: Colors.black.withValues(
                                alpha: _controller.nightOverlayOpacity,
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

            // Layer 2: Overlay game over
            Obx(() {
              if (!_controller.isGameOver.value) return const SizedBox.shrink();

              return Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black.withValues(alpha: 0.7),
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
                          '${_controller.score.value}',
                          style: GoogleFonts.inter(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Obx(
                          () => Text(
                            'Best: ${_controller.highScore.value}',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.tfPlaceholder,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => Get.back(),
                              icon: const Icon(
                                Icons.home_rounded,
                                color: AppColors.primary,
                              ),
                              label: Text(
                                'HOME',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                side: const BorderSide(
                                  color: AppColors.tfBorder,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: _controller.resetGame,
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
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
