import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../data/providers/api_provider.dart';
import '../../core/utils/snackbar_helper.dart';

class ToolsController extends GetxController {
  // Jam zona waktu
  var timeWIB = ''.obs;
  var timeWITA = ''.obs;
  var timeWIT = ''.obs;
  var timeLondon = ''.obs;

  Timer? _timer;

  // Kurs mata uang
  var isLoadingCurrency = false.obs;
  var usdToIdr = 0.0.obs;
  var eurToIdr = 0.0.obs;
  var gbpToIdr = 0.0.obs;

  // Konversi mata uang
  final TextEditingController amountController = TextEditingController();
  var selectedFrom = 'USD'.obs;
  var selectedTo = 'IDR'.obs;
  var conversionResult = '0.00'.obs;
  final List<String> currencies = ['USD', 'EUR', 'GBP', 'IDR'];

  @override
  void onInit() {
    super.onInit();
    _startTicking();
    fetchCurrencyRates();
  }

  // Mulai timer jam real-time, update tiap 1 detik
  void _startTicking() {
    _calculateTime();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _calculateTime(),
    );
  }

  void _calculateTime() {
    final nowUtc = DateTime.now().toUtc();
    final fmt = DateFormat('HH:mm:ss');
    timeWIB.value = fmt.format(nowUtc.add(const Duration(hours: 7)));
    timeWITA.value = fmt.format(nowUtc.add(const Duration(hours: 8)));
    timeWIT.value = fmt.format(nowUtc.add(const Duration(hours: 9)));
    timeLondon.value = fmt.format(nowUtc);
  }

  // Ambil kurs valuta asing dari API
  Future<void> fetchCurrencyRates() async {
    isLoadingCurrency.value = true;
    final data = await ApiProvider.getCurrencyRates();

    if (data != null) {
      // Base currency adalah USD; EUR dan GBP ke IDR dihitung lewat rasio
      usdToIdr.value = (data['idr']['rate'] ?? 0).toDouble();
      final eurRate = (data['eur']['rate'] ?? 1).toDouble();
      final gbpRate = (data['gbp']['rate'] ?? 1).toDouble();
      eurToIdr.value = usdToIdr.value / eurRate;
      gbpToIdr.value = usdToIdr.value / gbpRate;
    } else {
      Future.delayed(
        const Duration(milliseconds: 200),
        () => SnackbarHelper.showError(
          'Gagal Memuat',
          'Data kurs terbaru tidak tersedia.',
        ),
      );
    }

    isLoadingCurrency.value = false;
  }

  // Hitung hasil konversi antar mata uang
  void convertCurrency() {
    final amount = double.tryParse(amountController.text) ?? 0.0;
    if (amount == 0.0) {
      conversionResult.value = '0.00';
      return;
    }

    // Tahap 1: konversi mata uang asal ke IDR
    final double amountInIdr = switch (selectedFrom.value) {
      'USD' => amount * usdToIdr.value,
      'EUR' => amount * eurToIdr.value,
      'GBP' => amount * gbpToIdr.value,
      _ => amount,
    };

    // Tahap 2: konversi dari IDR ke mata uang tujuan
    final double result = switch (selectedTo.value) {
      'USD' => amountInIdr / usdToIdr.value,
      'EUR' => amountInIdr / eurToIdr.value,
      'GBP' => amountInIdr / gbpToIdr.value,
      _ => amountInIdr,
    };

    final symbol = switch (selectedTo.value) {
      'IDR' => 'Rp ',
      'EUR' => '€',
      'GBP' => '£',
      _ => '\$',
    };

    conversionResult.value = NumberFormat.currency(
      locale: selectedTo.value == 'IDR' ? 'id_ID' : 'en_US',
      symbol: symbol,
      decimalDigits: 2,
    ).format(result);
  }

  @override
  void onClose() {
    _timer?.cancel();
    amountController.dispose();
    super.onClose();
  }
}
