import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/custom_textfield.dart';
import 'auth_controller.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authC = Get.find<AuthController>();

    final TextEditingController nameController = TextEditingController();
    final TextEditingController nimController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            children: [
              SvgPicture.asset('assets/images/aquasmart_logo.svg', height: 140),
              // const SizedBox(height: 20),
              Text(
                'AquaSmart',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Text(
                'Intelligent Aquarium Care',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.tfPlaceholder,
                ),
              ),
              const SizedBox(height: 28),

              CustomTextField(
                controller: nameController,
                hintText: 'Full name',
                prefixIcon: Icons.person_outline,
              ),
              CustomTextField(
                controller: nimController,
                hintText: 'Nim',
                prefixIcon: Icons.badge_outlined,
              ),
              CustomTextField(
                controller: emailController,
                hintText: 'Email address',
                prefixIcon: Icons.email_outlined,
              ),
              Obx(
                () => CustomTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  obscureText: authC.isPasswordHidden.value,
                  onTogglePassword: () => authC.togglePasswordVisibility(),
                ),
              ),
              Obx(
                () => CustomTextField(
                  controller: confirmPasswordController,
                  hintText: 'Confirm password',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  obscureText: authC.isConfirmPasswordHidden.value,
                  onTogglePassword: () =>
                      authC.toggleConfirmPasswordVisibility(),
                ),
              ),

              const SizedBox(height: 18),

              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: authC.isLoading.value
                        ? null
                        : () async {
                            if (passwordController.text !=
                                confirmPasswordController.text) {
                              Get.snackbar(
                                'Error',
                                'Konfirmasi password tidak cocok',
                              );
                              return;
                            }
                            bool success = await authC.register(
                              nameController.text,
                              nimController.text,
                              emailController.text,
                              passwordController.text,
                            );
                            if (success) {
                              Get.back();
                              Get.snackbar(
                                'Berhasil',
                                'Akun berhasil dibuat, silakan login',
                              );
                            } else {
                              Get.snackbar('Gagal', authC.errorMessage.value);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: authC.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Sign Up',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: GoogleFonts.inter(color: AppColors.tfPlaceholder),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Text(
                      "Sign In",
                      style: GoogleFonts.inter(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
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
  }
}
