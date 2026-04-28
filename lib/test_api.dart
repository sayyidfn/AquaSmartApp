import 'package:flutter/material.dart';
import 'data/providers/api_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('=============================================');
  print('MEMULAI PENGUJIAN API AQUASMART');
  print('=============================================\n');

  // 1. Test Open-Meteo (Cuaca/Suhu)
  print('[1] Menguji API Cuaca (Open-Meteo)...');
  var weather = await ApiProvider.getWeather(-8.023, 110.334);
  if (weather != null && weather['current_weather'] != null) {
    print(
      'Berhasil! Suhu saat ini: ${weather['current_weather']['temperature']} °C',
    );
  } else {
    print('Gagal! Periksa koneksi internet Anda.');
  }

  // 2. Test Floatrates (Mata Uang)
  print('\n[2] Menguji API Kurs Mata Uang (Floatrates)...');
  var rates = await ApiProvider.getCurrencyRates();
  if (rates != null && rates['idr'] != null) {
    print('Berhasil! Kurs 1 USD ke IDR: Rp ${rates['idr']['rate']}');
  } else {
    print('Gagal! Periksa koneksi internet Anda.');
  }

  // 3. Test Fish API (RapidAPI)
  print('\n[3] Menguji API Ensiklopedia Ikan (RapidAPI)...');
  var fishes = await ApiProvider.getFishes();
  if (fishes != null) {
    print(
      'Berhasil! Data Ikan berhasil ditarik: ${fishes.toString().substring(0, 70)}...',
    );
  } else {
    print('Gagal! Periksa API Key RapidAPI Anda di api_constants.dart.');
  }

  // 4. Test Gemini AI (Google AI Studio)
  print('\n[4] Menguji Asisten Pintar (Gemini AI)...');
  var aiResponse = await ApiProvider.askGemini(
    "Berikan 1 fakta unik dan sangat singkat tentang ikan cupang.",
  );
  if (aiResponse != null) {
    print('Berhasil! Jawaban Gemini: $aiResponse');
  } else {
    print('Gagal! Periksa API Key Gemini Anda di api_constants.dart.');
  }

  print('\n=============================================');
  print('PENGUJIAN SELESAI');
  print('=============================================');
}
