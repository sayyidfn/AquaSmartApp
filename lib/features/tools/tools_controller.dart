import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
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

  // Fish Health Scanner
  var scanImagePath = ''.obs;
  var isAnalyzing = false.obs;
  var isResultReady = false.obs;
  var diseaseLabel = ''.obs;
  var diseaseConfidence = 0.0.obs;

  // Label sesuai urutan output model
  static const List<String> _labels = ['Sehat', 'Bercak Merah', 'Jamur'];

  Interpreter? _interpreter;
  bool _isModelLoaded = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    _startTicking();
    fetchCurrencyRates();
    // Model dimuat secara lazy saat pertama kali scan dijalankan
  }

  // Mulai timer jam real-time, update tiap 1 detik
  void _startTicking() {
    _calculateTime();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _calculateTime(),
    );
  }

  // Fungsi untuk calculate time
  void _calculateTime() {
    final nowUtc = DateTime.now().toUtc();
    final fmt = DateFormat('HH:mm:ss');
    timeWIB.value = fmt.format(nowUtc.add(const Duration(hours: 7)));
    timeWITA.value = fmt.format(nowUtc.add(const Duration(hours: 8)));
    timeWIT.value = fmt.format(nowUtc.add(const Duration(hours: 9)));
    timeLondon.value = fmt.format(nowUtc);
  }

  // Fungsi untuk fetch currency rates dari API
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
    final String rawText = amountController.text.trim();

    if (rawText.isEmpty) {
      conversionResult.value = '0.00';
      return;
    }

    final double? amount = double.tryParse(rawText);

    if (amount == null) {
      SnackbarHelper.showError('Input Tidak Valid', 'Masukkan angka yang valid.');
      return;
    }

    if (amount < 0) {
      SnackbarHelper.showError('Input Tidak Valid', 'Jumlah tidak boleh negatif.');
      conversionResult.value = '0.00';
      return;
    }

    if (amount == 0.0) {
      conversionResult.value = '0.00';
      return;
    }

    // Guard: kurs belum tersedia dari API
    if (usdToIdr.value == 0) {
      SnackbarHelper.showError(
        'Kurs Belum Tersedia',
        'Data kurs sedang dimuat, coba beberapa saat lagi.',
      );
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

  // Fungsi untuk load model TFLite
  Future<bool> _ensureModelLoaded() async {
    if (_isModelLoaded && _interpreter != null) return true;
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/ml/model.tflite',
        options: InterpreterOptions()..threads = 2,
      );
      _isModelLoaded = true;
      return true;
    } catch (e) {
      debugPrint('[ToolsController] Gagal memuat model TFLite: $e');
      return false;
    }
  }

  // Fungsi untuk pick image and analyze
  Future<void> pickImageAndAnalyze(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 640,
      );
      if (file == null) return;

      scanImagePath.value = file.path;
      isResultReady.value = false;
      diseaseLabel.value = '';
      diseaseConfidence.value = 0.0;
      isAnalyzing.value = true;

      // Muat model jika belum siap
      final ready = await _ensureModelLoaded();
      if (!ready) {
        SnackbarHelper.showError(
          'Model Tidak Tersedia',
          'Gagal memuat model AI. Coba restart aplikasi.',
        );
        return;
      }

      await _runInference(file.path);
    } catch (e) {
      SnackbarHelper.showError('Error', 'Gagal memproses gambar.');
    } finally {
      isAnalyzing.value = false;
    }
  }

  // Jalankan inferensi model TFLite pada gambar yang dipilih
  Future<void> _runInference(String imagePath) async {
    try {
      final interpreter = _interpreter!;

      // Ambil dimensi input dari model: [1, H, W, C]
      final inputShape = interpreter.getInputTensor(0).shape;
      final h = inputShape[1];
      final w = inputShape[2];

      // Decode dan resize gambar ke ukuran yang dibutuhkan model
      final rawBytes = await File(imagePath).readAsBytes();
      final decoded = img.decodeImage(rawBytes);
      if (decoded == null) {
        SnackbarHelper.showError('Error', 'Format gambar tidak didukung.');
        return;
      }
      final resized = img.copyResize(decoded, width: w, height: h);

      // Susun input sebagai nested List [1][H][W][3] dengan nilai uint8 [0, 255]
      // Model ini adalah kuantisasi uint8, bukan float32
      final input = List.generate(
        1,
        (_) => List.generate(
          h,
          (y) => List.generate(
            w,
            (x) {
              final pixel = resized.getPixel(x, y);
              return [
                pixel.r.toInt(),
                pixel.g.toInt(),
                pixel.b.toInt(),
              ];
            },
          ),
        ),
      );

      // Output: [1][jumlahKelas] — nilai uint8 [0, 255]
      final numClasses = _labels.length;
      final output = [List<int>.filled(numClasses, 0)];

      // Jalankan model
      interpreter.run(input, output);

      // Cari kelas dengan skor tertinggi
      final scores = output[0];
      int maxScore = -1;
      int maxIndex = 0;
      for (int i = 0; i < scores.length; i++) {
        if (scores[i] > maxScore) {
          maxScore = scores[i];
          maxIndex = i;
        }
      }

      // Konversi skor uint8 [0-255] ke persentase [0-100]
      diseaseLabel.value = _labels[maxIndex];
      diseaseConfidence.value = (maxScore / 255.0 * 100).clamp(0.0, 100.0);
      isResultReady.value = true;
    } catch (e) {
      SnackbarHelper.showError('Analisis Gagal', 'Model tidak dapat memproses gambar ini. Coba gambar lain.');
    }
  }

  // Reset hasil scan untuk mencoba gambar baru
  void resetScan() {
    scanImagePath.value = '';
    isResultReady.value = false;
    diseaseLabel.value = '';
    diseaseConfidence.value = 0.0;
  }

  // Teks saran berdasarkan label hasil deteksi
  String get diseaseAdvice {
    switch (diseaseLabel.value) {
      case 'Sehat':
        return 'Ikan Anda terlihat sehat! Tetap pantau kualitas air dan pola makan secara rutin.';
      case 'Bercak Merah':
        return 'Terdeteksi gejala Bercak Merah. Segera isolasi ikan dan tambahkan garam akuarium sesuai dosis.';
      case 'Jamur':
        return 'Terdeteksi infeksi Jamur. Berikan obat antijamur dan pertahankan suhu air di 26–28°C.';
      default:
        return 'Kondisi tidak dikenali. Konsultasikan dengan ahli akuarium.';
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    amountController.dispose();
    _interpreter?.close();
    super.onClose();
  }
}
