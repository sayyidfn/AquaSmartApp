import 'package:get/get.dart';
import '../../data/models/species_model.dart';
import '../../data/providers/api_provider.dart';

class EncyclopediaController extends GetxController {
  var isLoading = false.obs;
  var speciesList = <SpeciesModel>[].obs; // Daftar data asli dari API
  var filteredList = <SpeciesModel>[].obs; // Daftar yang tampil di layar

  var selectedCategory = 'All'.obs;
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSpeciesData();
  }

  // --- MENGAMBIL DATA DARI RAPIDAPI ---
  void fetchSpeciesData() async {
    isLoading.value = true;

    var apiData = await ApiProvider.getFishes();

    if (apiData != null) {
      var mappedData = apiData.map((jsonItem) {
        // 1. PERBAIKAN GAMBAR: Ekstraksi Map JSON dengan presisi
        String imageUrl = 'https://via.placeholder.com/150'; // Gambar default
        var imgSrc = jsonItem['img_src_set'];

        // Cek apakah data gambar berbentuk Map (Kamus) dan punya kunci '1.5x'
        if (imgSrc is Map<String, dynamic> && imgSrc.containsKey('1.5x')) {
          imageUrl = imgSrc['1.5x'].toString();
        } else if (imgSrc is String && imgSrc != "Not available") {
          imageUrl = imgSrc;
        }

        if (imageUrl.startsWith('//')) {
          imageUrl = 'https:$imageUrl';
        }

        // 2. PERBAIKAN META DATA: Mengambil famili asli
        var meta = jsonItem['meta'];
        String fishFamily = 'Unknown Family';
        String status = 'Unknown';

        if (meta != null && meta is Map<String, dynamic>) {
          // Ambil family jika ada
          if (meta['scientific_classification'] != null &&
              meta['scientific_classification']['family'] != null) {
            fishFamily =
                meta['scientific_classification']['family']
                    .toString()
                    .capitalizeFirst ??
                '';
          }
          // Ambil status konservasi (Kita jadikan pengganti badge difficulty)
          if (meta['conservation_status'] != null) {
            // Mengambil teks sebelum kurung buka, e.g. "Least Concern (IUCN 3.1)" -> "Least Concern"
            status = meta['conservation_status'].toString().split(' (').first;
          }
        }

        String fishName = jsonItem['name'] ?? 'Unknown Species';

        return SpeciesModel(
          id: jsonItem['id'].toString(),
          name: fishName,
          family: fishFamily,
          difficulty:
              status, // Kita ubah fungsi badge menjadi Status Konservasi!
          description:
              'A fascinating marine species commonly known as the $fishName. Tap this card to explore detailed information, or ask our AI Assistant for care requirements.',
          imageUrl: imageUrl,
        );
      }).toList();

      speciesList.assignAll(mappedData);
      filteredList.assignAll(mappedData);
    } else {
      Future.delayed(const Duration(milliseconds: 200), () {
        Get.snackbar(
          'Koneksi Gagal',
          'Tidak dapat mengambil data dari server RapidAPI.',
        );
      });
    }

    isLoading.value = false;
  }

  // --- FUNGSI SEARCH & FILTER ---
  void filterData(String query, String category) {
    searchQuery.value = query;
    selectedCategory.value = category;

    var result = speciesList.where((species) {
      final matchName = species.name.toLowerCase().contains(
        query.toLowerCase(),
      );
      // Logika pencocokan kategori (Difficulty)
      final matchCategory = category == 'All' || species.difficulty == category;
      return matchName && matchCategory;
    }).toList();

    filteredList.assignAll(result);
  }

  // --- FUNGSI BOOKMARK ---
  void toggleBookmark(String id) {
    var index = filteredList.indexWhere((s) => s.id == id);
    if (index != -1) {
      filteredList[index].isBookmarked = !filteredList[index].isBookmarked;
      filteredList
          .refresh(); // Memaksa UI untuk me-render ulang ikon hati (love)

      // TODO: Implementasi simpan bookmark ke Hive local storage
    }
  }
}
