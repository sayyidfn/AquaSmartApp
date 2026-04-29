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
                zoom: 13,
              ),
              // Penting: Menggunakan .value agar Obx mendeteksi perubahan Set
              markers: controller.markers.toSet(),
              circles: controller.circles.toSet(),

              myLocationEnabled: true, // Menampilkan titik biru lokasi Anda
              myLocationButtonEnabled: true,
              zoomControlsEnabled:
                  false, // Matikan agar tidak mengganggu UI desain Anda

              onMapCreated: (gController) {
                controller.mapController = gController;
                // Jika posisi sudah didapat sebelum map siap, animasikan sekarang
                gController.animateCamera(
                  CameraUpdate.newLatLngZoom(
                    controller.currentLatLng.value,
                    13,
                  ),
                );
              },
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
                  // ... bagian atas MapsView tetap sama ...
                  Expanded(
                    child: Obx(
                      () => controller.isLoading.value
                          ? const Center(child: CircularProgressIndicator())
                          : ListView.builder(
                              itemCount: controller.placeList.length,
                              itemBuilder: (context, index) {
                                var toko = controller.placeList[index];
                                var latToko =
                                    toko['geometry']['location']['lat'];
                                var lngToko =
                                    toko['geometry']['location']['lng'];

                                return Card(
                                  elevation: 0,
                                  color: Colors.blue[50],
                                  margin: const EdgeInsets.only(bottom: 10),
                                  child: ListTile(
                                    leading: const CircleAvatar(
                                      backgroundColor: Colors.blue,
                                      child: Icon(
                                        Icons.store,
                                        color: Colors.white,
                                      ),
                                    ),
                                    title: Text(
                                      toko['name'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    // TAMPILKAN JARAK DI SINI
                                    subtitle: Text("${toko['vicinity']}"),

                                    trailing: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey[800],
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        // PANGGIL FUNGSI RUTE
                                        controller.openDirections(
                                          latToko,
                                          lngToko,
                                        );
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
