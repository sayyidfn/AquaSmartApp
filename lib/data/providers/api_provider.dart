import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../core/constants/api_constants.dart';

class ApiProvider {
  // Ambil data cuaca saat ini dari Open-Meteo
  static Future<Map<String, dynamic>?> getWeather(double lat, double lng) async {
    try {
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=$lat&longitude=$lng&current_weather=true',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) return jsonDecode(response.body);
      return null;
    } catch (e) {
      return null;
    }
  }

  // Ambil kurs valuta asing USD-base dari Floatrates
  static Future<Map<String, dynamic>?> getCurrencyRates() async {
    try {
      final response = await http
          .get(Uri.parse(ApiConstants.currencyUrl))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) return jsonDecode(response.body);
      return null;
    } catch (e) {
      return null;
    }
  }

  // Ambil daftar spesies ikan dari RapidAPI
  static Future<List<dynamic>?> getFishes() async {
    try {
      final response = await http
          .get(
            Uri.parse(ApiConstants.fishUrl),
            headers: {
              'X-RapidAPI-Key': ApiConstants.fishKey,
              'X-RapidAPI-Host': 'fish-species.p.rapidapi.com',
            },
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Kirim prompt ke Gemini AI dan kembalikan teks respons
  static Future<String?> askGemini(String promptText) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: ApiConstants.geminiKey,
      );
      final response = await model.generateContent([Content.text(promptText)]);
      return response.text;
    } catch (e) {
      return null;
    }
  }
}
