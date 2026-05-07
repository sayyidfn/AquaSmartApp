import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/providers/api_provider.dart';

class AiAssistantController extends GetxController {
  var isLoading = false.obs;
  var messages = <Map<String, String>>[].obs; // Riwayat chat

  final TextEditingController chatController = TextEditingController();

  // Kirim pesan user ke Gemini AI dan tambahkan respons ke riwayat chat
  Future<void> sendMessage() async {
    final text = chatController.text.trim();
    if (text.isEmpty) return;

    messages.add({'role': 'user', 'text': text});
    chatController.clear();
    isLoading.value = true;

    final prompt =
        'Anda adalah asisten ahli akuarium AquaSmart. '
        'Jawablah pertanyaan berikut dengan singkat, ramah, dan informatif: $text';

    final response = await ApiProvider.askGemini(prompt);

    messages.add({
      'role': 'ai',
      'text': response ?? 'Maaf, saya sedang mengalami gangguan koneksi. Bisa diulangi?',
    });

    isLoading.value = false;
  }

  @override
  void onClose() {
    chatController.dispose();
    super.onClose();
  }
}
