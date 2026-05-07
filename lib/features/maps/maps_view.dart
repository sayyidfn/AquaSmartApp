import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/theme/app_colors.dart';
import 'maps_controller.dart';

class MapsView extends StatelessWidget {
  const MapsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MapsController>();
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Stack(
        children: [
          // Layer 1: peta
          Obx(
            () => GoogleMap(
              initialCameraPosition: CameraPosition(
                target: controller.currentLatLng.value,
                zoom: 13,
              ),
              markers: controller.markers.toSet(),
              circles: controller.circles.toSet(),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              onMapCreated: (gController) {
                controller.mapController = gController;
                gController.animateCamera(
                  CameraUpdate.newLatLngZoom(
                    controller.currentLatLng.value,
                    13,
                  ),
                );
              },
            ),
          ),

          // Layer 2: header melayang (judul + info jumlah toko)
          Positioned(
            top: topPadding + 12,
            left: 16,
            right: 16,
            child: Row(
              children: [
                // Tombol Back
                _FloatingIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onPressed: () => Get.back(),
                ),
                const SizedBox(width: 12),
                // Judul
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          color: AppColors.deepOceanBlue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Toko Ikan Terdekat',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        const Spacer(),
                        Obx(
                          () => Text(
                            controller.isLoading.value
                                ? 'Mencari...'
                                : '${controller.placeList.length} toko',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.oceanTeal,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Layer 3: tombol my location (custom)
          Positioned(
            bottom: 300,
            right: 16,
            child: _FloatingIconButton(
              icon: Icons.my_location_rounded,
              onPressed: () {
                controller.mapController?.animateCamera(
                  CameraUpdate.newLatLngZoom(
                    controller.currentLatLng.value,
                    15,
                  ),
                );
              },
            ),
          ),

          // Layer 4: bottom sheet list toko terdekat
          DraggableScrollableSheet(
            initialChildSize: 0.32,
            minChildSize: 0.14,
            maxChildSize: 0.65,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Handle drag
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 4),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.tfBorder,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    // Header bottom sheet
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.aquaMist,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.storefront_rounded,
                              color: AppColors.deepOceanBlue,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Toko Ikan & Aquarium',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              Text(
                                'Radius 10 km dari lokasi Anda',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.softGray,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const Divider(height: 1, color: AppColors.tfBorder),

                    // List Toko
                    Expanded(
                      child: Obx(() {
                        if (controller.isLoading.value) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  color: AppColors.deepOceanBlue,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Sedang mencari toko terdekat...',
                                  style: TextStyle(
                                    color: AppColors.softGray,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        if (controller.placeList.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.storefront_outlined,
                                  size: 52,
                                  color: AppColors.tfBorder,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Tidak ada toko ditemukan',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Coba perluas area pencarian',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.softGray,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.separated(
                          controller: scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                          itemCount: controller.placeList.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final toko = controller.placeList[index];
                            final latToko = toko['geometry']['location']['lat'];
                            final lngToko = toko['geometry']['location']['lng'];
                            final String distance = toko['distance'] ?? '?';
                            final bool isOpen =
                                toko['opening_hours']?['open_now'] ?? false;

                            return _StoreCard(
                              name: toko['name'] ?? 'Toko Ikan',
                              vicinity: toko['vicinity'] ?? '-',
                              distance: distance,
                              isOpen: isOpen,
                              onRoute: () =>
                                  controller.openDirections(latToko, lngToko),
                              onTap: () {
                                // Fokuskan peta ke marker toko
                                controller.mapController?.animateCamera(
                                  CameraUpdate.newLatLngZoom(
                                    LatLng(latToko, lngToko),
                                    16,
                                  ),
                                );
                              },
                            );
                          },
                        );
                      }),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Widget: tombol ikon melayang
class _FloatingIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _FloatingIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 4,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: Icon(icon, color: AppColors.deepOceanBlue, size: 20),
        ),
      ),
    );
  }
}

// Widget: kartu toko di bottom sheet
class _StoreCard extends StatelessWidget {
  final String name;
  final String vicinity;
  final String distance;
  final bool isOpen;
  final VoidCallback onRoute;
  final VoidCallback onTap;

  const _StoreCard({
    required this.name,
    required this.vicinity,
    required this.distance,
    required this.isOpen,
    required this.onRoute,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.aquaMist,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Ikon toko
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.deepOceanBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),

              // Info toko
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      vicinity,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.softGray,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        // Badge jarak
                        _Badge(
                          icon: Icons.near_me_rounded,
                          label: '$distance km',
                          color: AppColors.oceanTeal,
                        ),
                        const SizedBox(width: 6),
                        // Badge status buka/tutup
                        _Badge(
                          icon: isOpen
                              ? Icons.check_circle_outline
                              : Icons.cancel_outlined,
                          label: isOpen ? 'Buka' : 'Tutup',
                          color: isOpen
                              ? AppColors.seaGreen
                              : AppColors.dangerRed,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Tombol rute
              GestureDetector(
                onTap: onRoute,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.deepOceanBlue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.directions_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Rute',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget: badge kecil (jarak & status buka)
class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Badge({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
