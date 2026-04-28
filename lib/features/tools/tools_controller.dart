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
  final List<String> currencies = ['USD', 'EUR', 'IDR'];

  void convertCurrency() {
    double amount = double.tryParse(amountController.text) ?? 0.0;
    double result = 0.0;

    if (amount == 0.0) {
      conversionResult.value = '0.00';
      return;
    }

    // Logika perhitungan berdasarkan kurs dari Floatrates API
    if (selectedFrom.value == 'USD' && selectedTo.value == 'IDR') {
      result = amount * usdToIdr.value;
    } else if (selectedFrom.value == 'EUR' && selectedTo.value == 'IDR') {
      result = amount * eurToIdr.value;
    } else if (selectedFrom.value == 'IDR' && selectedTo.value == 'USD') {
      result = amount / usdToIdr.value;
    } else if (selectedFrom.value == 'IDR' && selectedTo.value == 'EUR') {
      result = amount / eurToIdr.value;
    } else if (selectedFrom.value == 'USD' && selectedTo.value == 'EUR') {
      // Cross rate USD -> IDR -> EUR
      double inIdr = amount * usdToIdr.value;
      result = inIdr / eurToIdr.value;
    } else if (selectedFrom.value == 'EUR' && selectedTo.value == 'USD') {
      // Cross rate EUR -> IDR -> USD
      double inIdr = amount * eurToIdr.value;
      result = inIdr / usdToIdr.value;
    } else {
      result = amount; // Jika dari dan ke mata uang yang sama
    }

    // Format hasilnya (misal: Rp 15.000)
    conversionResult.value = NumberFormat.currency(
      locale: selectedTo.value == 'IDR' ? 'id_ID' : 'en_US',
      symbol: selectedTo.value == 'IDR'
          ? 'Rp '
          : (selectedTo.value == 'EUR' ? '€' : '\$'),
      decimalDigits: 2,
    ).format(result);
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  String get formattedUsd => NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(usdToIdr.value);

  String get formattedEur => NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(eurToIdr.value);

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
