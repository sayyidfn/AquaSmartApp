import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';

class ApiProvider {
  // - 1. Fungsi ambil data suhu & cuaca -
  static Future<Map<String, dynamic>?> getWeather(
    double lat,
    double lng,
  ) async {
    try {
      // menyusun url beserta parameter garis lintang (lat) dan bujur (lng)
      final url = Uri.parse(
        '${ApiConstants.stormglassUrl}?lat=$lat&lng=$lng&params=waterTemperature',
      );

      // melakukan http get request dengan api key
      final response = await http.get(
        url,
        headers: {'Authorization': ApiConstants.stormglassKey},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error Weather API: $e');
      return null;
    }
  }

  // - 2. Fungsi ambil kurs mata uang
  static Future<Map<String, dynamic>?> getCurrencyRates() async {
    try {
      final url = Uri.parse(ApiConstants.currencyUrl);
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error Currency API: $e');
      return null;
    }
  }

  // 3. Fungsi ambil daftar ikan
  static Future<Map<String, dynamic>?> getFishes() async {
    try {
      final url = Uri.parse(ApiConstants.fishUrl);
      final response = await http.get(
        url,
        headers: {
          'X-RapidAPI-Key': ApiConstants.fishKey,
          'X-RapidAPI-Host': 'fish-species.p.rapidapi.com',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error Fish API: $e');
      return null;
    }
  }

  // 4. Fungsi mengirim pesan ke chatbot ai
  static Future<Map<String, dynamic>?> askCohereAI(String promptText) async {
    try {
      final url = Uri.parse(ApiConstants.cohereUrl);

      // melakukan http post request karena kita mengirim prompt ke server
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer ${ApiConstants.cohereKey}',
          'Content-Type': 'aplication/json',
        },
        body: jsonEncode({
          'model': 'command', // model ai
          'prompt': promptText,
          'max_tokens': 150, // batasan panjang jawaban agar tidak limit
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return data['generations'][0]['text']; // mengambil teks jawaban ai nya saja
      }
      return null;
    } catch (e) {
      print('Error Cohere API: $e');
      return null;
    }
  }
}
