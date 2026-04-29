import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';

class MapsController extends GetxController {
  var currentLatLng = const LatLng(-6.2000, 106.8166).obs;
  var markers = <Marker>{}.obs;
  var circles = <Circle>{}.obs;
  var placeList = <dynamic>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    determinePosition();
  }

  void determinePosition() async {
    isLoading.value = true;
    Position position = await Geolocator.getCurrentPosition();
    currentLatLng.value = LatLng(position.latitude, position.longitude);

    // Set Radius 10KM
    circles.add(
      Circle(
        circleId: const CircleId("radius_10km"),
        center: currentLatLng.value,
        radius: 10000,
        fillColor: const Color(0x332196F3),
        strokeColor: Colors.blue,
        strokeWidth: 1,
      ),
    );

    // Panggil fungsi pencarian otomatis
    fetchNearbyPlaces(position.latitude, position.longitude);
  }

  void fetchNearbyPlaces(double lat, double lng) async {
    final String url =
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$lng&radius=10000&type=pet_store&keyword=aquarium&key=${ApiConstants.googleMapsKey}";

    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        var results = data['results'] as List;

        // 1. Update daftar teks di bawah
        placeList.value = results;

        // 2. PERBAIKAN: Buat "wadah Set" sementara yang baru
        Set<Marker> newMarkers = {};

        for (var place in results) {
          final latToko = place['geometry']['location']['lat'];
          final lngToko = place['geometry']['location']['lng'];

          newMarkers.add(
            Marker(
              markerId: MarkerId(place['place_id']),
              position: LatLng(latToko, lngToko),
              infoWindow: InfoWindow(
                title: place['name'],
                snippet: place['vicinity'],
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueRed,
              ),
            ),
          );
        }

        // 3. Timpa state markers yang lama dengan yang baru sekaligus
        markers.value = newMarkers;
      }
    } catch (e) {
      print("Error fetching places: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
