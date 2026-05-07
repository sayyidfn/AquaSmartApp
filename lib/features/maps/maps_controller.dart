import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/api_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/snackbar_helper.dart';

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

  String calculateDistance(double endLat, double endLng) {
    double distanceInMeters = Geolocator.distanceBetween(
      currentLatLng.value.latitude,
      currentLatLng.value.longitude,
      endLat,
      endLng,
    );
    return (distanceInMeters / 1000).toStringAsFixed(1);
  }

  Future<void> openDirections(double lat, double lng) async {
    final Uri uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      SnackbarHelper.showError('Navigasi Gagal', 'Tidak dapat membuka aplikasi navigasi.');
    }
  }

  Future<void> determinePosition() async {
    isLoading.value = true;
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('GPS mati. Mohon nyalakan GPS terlebih dahulu.');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Izin lokasi ditolak.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings();
        throw Exception('Izin lokasi diblokir. Silakan izinkan di Pengaturan.');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Sinyal GPS lemah. Coba keluar ruangan.'),
      );

      currentLatLng.value = LatLng(position.latitude, position.longitude);
      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(currentLatLng.value, 13),
      );

      circles.assign(
        Circle(
          circleId: const CircleId('radius_10km'),
          center: currentLatLng.value,
          radius: 10000,
          fillColor: AppColors.deepOceanBlue.withOpacity(0.08),
          strokeColor: AppColors.deepOceanBlue.withOpacity(0.4),
          strokeWidth: 1,
        ),
      );

      await fetchNearbyPlaces(position.latitude, position.longitude);
    } catch (e) {
      isLoading.value = false;
      SnackbarHelper.showError('GPS Error', e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> fetchNearbyPlaces(double lat, double lng) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
        '?location=$lat,$lng&radius=10000&type=pet_store&keyword=aquarium'
        '&key=${ApiConstants.googleMapsKey}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] != 'OK' && data['status'] != 'ZERO_RESULTS') {
          SnackbarHelper.showWarning(
            'Google API Error',
            data['error_message'] ?? data['status'],
          );
        }

        final results = data['results'] as List;
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
                snippet: '${place['distance']} km',
              ),
            ),
          );
        }

        placeList.value = results;
        markers.assignAll(newMarkers);
      } else {
        SnackbarHelper.showError(
          'Server Error',
          'Gagal menghubungi Google (${response.statusCode}).',
        );
      }
    } catch (e) {
      SnackbarHelper.showError('Koneksi Error', 'Periksa koneksi internet Anda.');
    } finally {
      isLoading.value = false;
    }
  }
}
