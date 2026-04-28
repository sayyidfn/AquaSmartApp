import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/custom_textfield.dart';
import 'auth_controller.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    // menghubungkan ke authcontroller
    final AuthController authC = Get.find<AuthController>();

    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // const SizedBox(height: 40),
              // logo aquasmart
              SvgPicture.asset('assets/images/aquasmart_logo.svg', height: 140),
              // const SizedBox(height: 24),
              Text(
                'AquaSmart',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Intelligent Aquarium Care',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 32),

              // form input
              CustomTextField(
                controller: emailController,
                hintText: 'Email address',
                prefixIcon: Icons.email_outlined,
              ),

              // input password
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
              const SizedBox(height: 8),

              // sign in button
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: authC.isLoading.value
                        ? null
                        : () async {
                            bool success = await authC.login(
                              emailController.text,
                              passwordController.text,
                            );
                            if (success) {
                              Get.offAllNamed('/dashboard');
                            } else {
                              Get.snackbar(
                                'Login Gagal',
                                authC.errorMessage.value,
                                backgroundColor: Colors.redAccent,
                                colorText: Colors.white,
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: authC.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Sign In',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              Row(
                children: [
                  const Expanded(
                    child: Divider(color: AppColors.tfBorder, thickness: 1),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'or',
                      style: GoogleFonts.inter(color: AppColors.tfPlaceholder),
                    ),
                  ),
                  const Expanded(
                    child: Divider(color: AppColors.tfBorder, thickness: 1),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // biometric button
              Container(
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                  color: AppColors.tfBackground,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.fingerprint,
                    color: AppColors.primary,
                    size: 32,
                  ),
                  onPressed: () {
                    // Implementasi local_auth nanti
                  },
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: GoogleFonts.inter(color: AppColors.tfPlaceholder),
                  ),
                  GestureDetector(
                    onTap: () => Get.toNamed('/register'),
                    child: Text(
                      "Sign Up",
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
