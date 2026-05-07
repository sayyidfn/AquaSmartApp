import 'package:get/get.dart';
import '../../data/models/species_model.dart';
import '../../data/providers/api_provider.dart';
import '../../core/utils/snackbar_helper.dart';

class EncyclopediaController extends GetxController {
  var isLoading = false.obs;
  var speciesList = <SpeciesModel>[].obs; // Data asli dari API
  var filteredList = <SpeciesModel>[].obs; // Data yang tampil di layar

  var selectedCategory = 'All'.obs;
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSpeciesData();
  }

  // Ambil data spesies ikan dari RapidAPI
  Future<void> fetchSpeciesData() async {
    isLoading.value = true;

    final apiData = await ApiProvider.getFishes();

    if (apiData != null) {
      final mappedData = apiData.map((jsonItem) {
        // Ekstraksi URL gambar dari format Map atau String
        String imageUrl = 'https://via.placeholder.com/150';
        final imgSrc = jsonItem['img_src_set'];
        if (imgSrc is Map<String, dynamic> && imgSrc.containsKey('1.5x')) {
          imageUrl = imgSrc['1.5x'].toString();
        } else if (imgSrc is String && imgSrc != 'Not available') {
          imageUrl = imgSrc;
        }
        if (imageUrl.startsWith('//')) imageUrl = 'https:$imageUrl';

        // Ekstraksi famili dan status konservasi dari metadata
        final meta = jsonItem['meta'];
        String fishFamily = 'Unknown Family';
        String status = 'Unknown';

        if (meta != null && meta is Map<String, dynamic>) {
          final classification = meta['scientific_classification'];
          if (classification?['family'] != null) {
            fishFamily = classification['family'].toString().capitalizeFirst ?? '';
          }
          if (meta['conservation_status'] != null) {
            // Ambil teks sebelum tanda kurung, contoh: "Least Concern (IUCN 3.1)" → "Least Concern"
            status = meta['conservation_status'].toString().split(' (').first;
          }
        }

        final fishName = jsonItem['name'] ?? 'Unknown Species';

        return SpeciesModel(
          id: jsonItem['id'].toString(),
          name: fishName,
          family: fishFamily,
          difficulty: status,
          description:
              'A fascinating marine species commonly known as the $fishName. '
              'Tap this card to explore detailed information, or ask our AI Assistant for care requirements.',
          imageUrl: imageUrl,
        );
      }).toList();

      speciesList.assignAll(mappedData);
      filteredList.assignAll(mappedData);
    } else {
      Future.delayed(
        const Duration(milliseconds: 200),
        () => SnackbarHelper.showError('Koneksi Gagal', 'Tidak dapat mengambil data dari server.'),
      );
    }

    isLoading.value = false;
  }

  // Filter data berdasarkan kata kunci pencarian dan kategori
  void filterData(String query, String category) {
    searchQuery.value = query;
    selectedCategory.value = category;

    final result = speciesList.where((species) {
      final matchName = species.name.toLowerCase().contains(query.toLowerCase());
      final matchCategory = category == 'All' || species.difficulty == category;
      return matchName && matchCategory;
    }).toList();

    filteredList.assignAll(result);
  }

  // Toggle status bookmark spesies
  void toggleBookmark(String id) {
    final index = filteredList.indexWhere((s) => s.id == id);
    if (index != -1) {
      filteredList[index].isBookmarked = !filteredList[index].isBookmarked;
      filteredList.refresh();
      // TODO: simpan bookmark ke Hive local storage
    }
  }
}
