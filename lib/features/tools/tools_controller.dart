import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../data/providers/api_provider.dart';

class ToolsController extends GetxController {
  var timeWIB = ''.obs;
  var timeWITA = ''.obs;
  var timeWIT = ''.obs;
  var timeLondon = ''.obs;

  Timer? _timer;

  var isLoadingCurrency = false.obs;
  var usdToIdr = 0.0.obs;
  var eurToIdr = 0.0.obs;
  var gbpToIdr = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _startTicking();
    fetchCurrencyRates();
  }

  // - Logika clock -
  void _startTicking() {
    _calculateTime(); // Panggil detik pertama

    // refresh tiap 1 detik
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _calculateTime();
    });
  }

  void _calculateTime() {
    DateTime nowUtc = DateTime.now().toUtc();

    // Format menjadi HH:mm:ss
    timeWIB.value = DateFormat(
      'HH:mm:ss',
    ).format(nowUtc.add(const Duration(hours: 7)));
    timeWITA.value = DateFormat(
      'HH:mm:ss',
    ).format(nowUtc.add(const Duration(hours: 8)));
    timeWIT.value = DateFormat(
      'HH:mm:ss',
    ).format(nowUtc.add(const Duration(hours: 9)));
    timeLondon.value = DateFormat('HH:mm:ss').format(nowUtc);
  }

  // - Fetch data currency -
  void fetchCurrencyRates() async {
    isLoadingCurrency.value = true;
    var data = await ApiProvider.getCurrencyRates();

    if (data != null) {
      // Floatrates USD JSON menjadikan IDR dan EUR sebagai key di dalam respons
      usdToIdr.value = (data['idr']['rate'] ?? 0).toDouble();

      // Karena base-nya USD, untuk dapat EUR ke IDR kita harus membagi rasio IDR dengan EUR
      double eurRate = (data['eur']['rate'] ?? 1).toDouble();
      eurToIdr.value = usdToIdr.value / eurRate;

      double gbpRate = (data['gbp']['rate'] ?? 1).toDouble();
      gbpToIdr.value = usdToIdr.value / gbpRate;
    } else {
      Future.delayed(const Duration(milliseconds: 200), () {
        Get.snackbar('Error', 'Gagal memuat data kurs terbaru');
      });
    }

    isLoadingCurrency.value = false;
  }

  // - Logika convert currency -
  final TextEditingController amountController = TextEditingController();
  var selectedFrom = 'USD'.obs;
  var selectedTo = 'IDR'.obs;
  var conversionResult = '0.00'.obs;

  // Daftar mata uang yang tersedia di dropdown
  final List<String> currencies = ['USD', 'EUR', 'GBP', 'IDR'];

  void convertCurrency() {
    double amount = double.tryParse(amountController.text) ?? 0.0;

    if (amount == 0.0) {
      conversionResult.value = '0.00';
      return;
    }

    // TAHAP A: Konversi mata uang ASAL (From) ke IDR terlebih dahulu
    double amountInIdr = 0.0;
    if (selectedFrom.value == 'USD') {
      amountInIdr = amount * usdToIdr.value;
    } else if (selectedFrom.value == 'EUR') {
      amountInIdr = amount * eurToIdr.value;
    } else if (selectedFrom.value == 'GBP') {
      amountInIdr = amount * gbpToIdr.value;
    } else {
      amountInIdr = amount; // Jika asalnya sudah IDR
    }

    // TAHAP B: Konversi dari IDR ke mata uang TUJUAN (To)
    double result = 0.0;
    if (selectedTo.value == 'USD') {
      result = amountInIdr / usdToIdr.value;
    } else if (selectedTo.value == 'EUR') {
      result = amountInIdr / eurToIdr.value;
    } else if (selectedTo.value == 'GBP') {
      result = amountInIdr / gbpToIdr.value;
    } else {
      result = amountInIdr; // Jika tujuannya IDR
    }

    // 5. ATUR SIMBOL MATA UANGNYA
    String symbol = '';
    if (selectedTo.value == 'IDR') {
      symbol = 'Rp ';
    } else if (selectedTo.value == 'EUR') {
      symbol = '€';
    } else if (selectedTo.value == 'GBP') {
      symbol = '£';
    } // Simbol Poundsterling
    else {
      symbol = '\$';
    }

    // Format hasil akhir
    conversionResult.value = NumberFormat.currency(
      locale: selectedTo.value == 'IDR' ? 'id_ID' : 'en_US',
      symbol: symbol,
      decimalDigits: 2,
    ).format(result);
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
