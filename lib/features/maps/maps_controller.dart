import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart'; // Import ini
import '../../core/constants/api_constants.dart';

class MapsController extends GetxController {
  var currentLatLng = const LatLng(-6.2000, 106.8166).obs;
  var markers = <Marker>{}.obs;
  var circles = <Circle>{}.obs;
  var placeList = <dynamic>[].obs;
  var isLoading = false.obs;

  GoogleMapController? mapController;

  @override
  void onInit() {
    super.onInit();
    determinePosition();
  }

  // FUNGSI 1: MENGHITUNG JARAK
  String calculateDistance(double endLat, double endLng) {
    double distanceInMeters = Geolocator.distanceBetween(
      currentLatLng.value.latitude,
      currentLatLng.value.longitude,
      endLat,
      endLng,
    );
    // Konversi ke KM dengan 1 angka di belakang koma
    return (distanceInMeters / 1000).toStringAsFixed(1);
  }

  // FUNGSI 2: MEMBUKA RUTE NAVIGASI
  void openDirections(double lat, double lng) async {
    final String googleMapsUrl =
        "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving";
    final Uri uri = Uri.parse(googleMapsUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar("Error", "Tidak dapat membuka aplikasi navigasi");
    }
  }

  void determinePosition() async {
    isLoading.value = true;
    try {
      bool serviceEnabled;
      LocationPermission permission;

      // 1. CEK GPS NYALA ATAU TIDAK
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception("GPS HP Anda mati. Mohon nyalakan GPS.");
      }

      // 2. CEK STATUS IZIN LOKASI
      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        // Jika ditolak biasa, minta izin (munculkan pop-up)
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception("Izin lokasi ditolak.");
        }
      }

      // 3. JIKA DITOLAK PERMANEN (TIDAK BISA MUNCUL POP-UP LAGI)
      if (permission == LocationPermission.deniedForever) {
        // Perintah ini akan otomatis membuka halaman Pengaturan HP!
        await Geolocator.openAppSettings();
        throw Exception(
          "Izin lokasi diblokir permanen. Silakan izinkan di Pengaturan.",
        );
      }

      // 4. JIKA SEMUA AMAN, LANJUT CARI LOKASI
      Position position =
          await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
          ).timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception(
                "Gagal mendapat sinyal GPS. Coba keluar ruangan.",
              );
            },
          );

      currentLatLng.value = LatLng(position.latitude, position.longitude);
      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(currentLatLng.value, 13),
      );

      circles.assign(
        Circle(
          circleId: const CircleId("radius_10km"),
          center: currentLatLng.value,
          radius: 10000,
          fillColor: Colors.blue.withOpacity(0.1),
          strokeColor: Colors.blue.withOpacity(0.5),
          strokeWidth: 1,
        ),
      );

      // Lanjut cari toko
      fetchNearbyPlaces(position.latitude, position.longitude);
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        "Error GPS",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void fetchNearbyPlaces(double lat, double lng) async {
    final String url =
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$lng&radius=10000&type=pet_store&keyword=aquarium&key=${ApiConstants.googleMapsKey}";

    try {
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        // 2. CEK APAKAH GOOGLE MEMBERIKAN ERROR MESSAGE (Misal: REQUEST_DENIED)
        if (data['status'] != "OK" && data['status'] != "ZERO_RESULTS") {
          print("API ERROR MESSAGE: ${data['error_message']}");
          Get.snackbar(
            "Google API Error",
            data['error_message'] ?? data['status'],
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
          );
        }

        var results = data['results'] as List;
        final Set<Marker> newMarkers = {};

        for (var place in results) {
          final latToko = place['geometry']['location']['lat'];
          final lngToko = place['geometry']['location']['lng'];
          place['distance'] = calculateDistance(latToko, lngToko);

          newMarkers.add(
            Marker(
              markerId: MarkerId(place['place_id']),
              position: LatLng(latToko, lngToko),
              infoWindow: InfoWindow(
                title: place['name'],
                snippet: "${place['distance']} km",
              ),
            ),
          );
        }

        placeList.value = results;
        markers.assignAll(newMarkers);
      } else {
        Get.snackbar(
          "Error Server",
          "Gagal menghubungi Google: ${response.statusCode}",
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error Internet",
        "Periksa koneksi Anda",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      // 3. PASTIKAN LOADING BERHENTI APAPUN YANG TERJADI
      isLoading.value = false;
    }
  }
}
