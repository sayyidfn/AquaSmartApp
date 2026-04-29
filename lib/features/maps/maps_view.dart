import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'maps_controller.dart';

class MapsView extends StatelessWidget {
  const MapsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Menghubungkan View dengan Controller
    final controller = Get.put(MapsController());

    return Scaffold(
      body: Stack(
        children: [
          // LAYER 1: PETA Paling Bawah
          Obx(
            () => GoogleMap(
              initialCameraPosition: CameraPosition(
                target: controller.currentLatLng.value,
                zoom: 12,
              ),
              markers: controller.markers,
              circles: controller.circles,
              myLocationEnabled: true, // Menampilkan titik biru (lokasi user)
              onMapCreated: (GoogleMapController gController) {},
            ),
          ),

          // LAYER 2: TOMBOL BACK Melayang Kiri Atas
          Positioned(
            top: 50,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Get.back(),
              ),
            ),
          ),

          // LAYER 3: DAFTAR TOKO (Bottom Sheet) Melayang di Bawah
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 250,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Garis kecil di tengah atas bottom sheet (Handle)
                  Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  // List Toko Ikan
                  Expanded(
                    child: Obx(
                      () => controller.isLoading.value
                          ? const Center(child: CircularProgressIndicator())
                          : ListView.builder(
                              itemCount: controller.placeList.length,
                              itemBuilder: (context, index) {
                                var toko = controller.placeList[index];
                                return Card(
                                  elevation: 0,
                                  color: Colors.blue[50],
                                  child: ListTile(
                                    leading: const Icon(
                                      Icons.storefront,
                                      color: Colors.blue,
                                    ),
                                    title: Text(
                                      toko['name'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      toko['vicinity'] ??
                                          "Alamat tidak tersedia",
                                    ),
                                    trailing: ElevatedButton(
                                      onPressed: () {
                                        // Nanti di sini kita pasang url_launcher untuk rute
                                      },
                                      child: const Text("Rute"),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
