import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../core/constants/api_constants.dart';

class ApiProvider {
  // [1] PERBAIKAN OPEN-METEO: Menggunakan Standard Forecast API yang lebih stabil
  static Future<Map<String, dynamic>?> getWeather(
    double lat,
    double lng,
  ) async {
    try {
      // Menggunakan current_weather=true agar JSON yang dikembalikan lebih sederhana
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lng&current_weather=true',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Weather API Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error Weather API: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getCurrencyRates() async {
    try {
      final url = Uri.parse(ApiConstants.currencyUrl);
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) return jsonDecode(response.body);
      return null;
    } catch (e) {
      print('Error Currency API: $e');
      return null;
    }
  }

  // [3] Perbaikan Fish API: Ganti Map menjadi List
  static Future<List<dynamic>?> getFishes() async {
    try {
      final url = Uri.parse(ApiConstants.fishUrl);
      final response = await http
          .get(
            url,
            headers: {
              'X-RapidAPI-Key': ApiConstants.fishKey,
              'X-RapidAPI-Host': 'fish-species.p.rapidapi.com',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // Langsung return List dari JSON
        return jsonDecode(response.body) as List<dynamic>;
      }
      print('Fish API Server Error: ${response.statusCode}');
      return null;
    } catch (e) {
      print('Error Fish API: $e');
      return null;
    }
  }

  // [4] PERBAIKAN GEMINI API: Menggunakan 'gemini-pro'
  static Future<String?> askGemini(String promptText) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: ApiConstants.geminiKey,
      );

      final content = [Content.text(promptText)];
      final response = await model.generateContent(content);

      return response.text;
    } catch (e) {
      print('Error Gemini API: $e');
      return null;
    }
  }
}
