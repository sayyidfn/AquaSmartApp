import 'package:get/get.dart';
import '../../data/models/species_model.dart';
import '../../data/providers/api_provider.dart';
import '../../core/utils/snackbar_helper.dart';

class EncyclopediaController extends GetxController {
  var isLoading = false.obs;
  var speciesList = <SpeciesModel>[].obs;
  var filteredList = <SpeciesModel>[].obs;

  var selectedCategory = 'All'.obs;
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSpeciesData();
  }

  Future<void> fetchSpeciesData() async {
    isLoading.value = true;

    final apiData = await ApiProvider.getFishes();

    if (apiData != null) {
      // KODE MENJADI SANGAT BERSIH & ELEGAN!
      // Kita langsung melempar setiap item JSON ke dalam SpeciesModel.fromJson
      final mappedData = apiData
          .map<SpeciesModel>((jsonItem) => SpeciesModel.fromJson(jsonItem))
          .toList();

      speciesList.assignAll(mappedData);
      filteredList.assignAll(mappedData);
    } else {
      Future.delayed(
        const Duration(milliseconds: 200),
        () => SnackbarHelper.showError(
          'Koneksi Gagal',
          'Tidak dapat mengambil data dari server.',
        ),
      );
    }

    isLoading.value = false;
  }

  void filterData(String query, String category) {
    searchQuery.value = query;
    selectedCategory.value = category;

    final result = speciesList.where((species) {
      final matchName = species.name.toLowerCase().contains(
        query.toLowerCase(),
      );
      final matchCategory = category == 'All' || species.status == category;
      return matchName && matchCategory;
    }).toList();

    filteredList.assignAll(result);
  }
}
