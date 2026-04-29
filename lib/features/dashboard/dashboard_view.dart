import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import 'dashboard_controller.dart';
import '../home/home_view.dart';
import '../encyclopedia/encyclopedia_view.dart';
import '../tools/tools_view.dart';
import '../profile/profile_view.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  // Data navigasi: index → asset path
  static const List<String> _navIcons = [
    'assets/icons/Icon_home.svg',
    'assets/icons/Icon_book.svg',
    'assets/icons/Icon_tool.svg',
    'assets/icons/Icon_user.svg',
  ];

  @override
  Widget build(BuildContext context) {
    final DashboardController dashC = Get.find<DashboardController>();

    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      body: Obx(
        () => IndexedStack(
          index: dashC.tabIndex.value,
          children: [
            const HomeView(), // Tab 0
            const EncyclopediaView(), // Tab 1
            const ToolsView(), // Tab 2
            const ProfileView(), // Tab 3
          ],
        ),
      ),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            border: Border(
              top: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  _navIcons.length,
                  (index) => _buildNavItem(
                    assetPath: _navIcons[index],
                    index: index,
                    currentIndex: dashC.tabIndex.value,
                    onTap: () => dashC.changeTabIndex(index),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required String assetPath,
    required int index,
    required int currentIndex,
    required VoidCallback onTap,
  }) {
    final bool isActive = currentIndex == index;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: SvgPicture.asset(
              assetPath,
              width: 22,
              height: 22,
              colorFilter: ColorFilter.mode(
                isActive ? AppColors.pureWhite : AppColors.inactiveNav,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(height: 4),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isActive ? 1.0 : 0.0,
            child: Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
