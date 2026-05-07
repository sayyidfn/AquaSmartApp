import 'package:get/get.dart';

class SpeciesModel {
  final String id;
  final String name;
  final String family;
  final String status;
  final String description;
  final String imageUrl;
  final String wikiUrl;
  final String fishClass;
  final String fishOrder; 

  SpeciesModel({
    required this.id,
    required this.name,
    required this.family,
    required this.status,
    required this.description,
    required this.imageUrl,
    required this.wikiUrl,
    required this.fishClass,
    required this.fishOrder,
  });

  factory SpeciesModel.fromJson(Map<String, dynamic> jsonItem) {
    String imageUrl = 'https://via.placeholder.com/150';
    final imgSrc = jsonItem['img_src_set'];

    if (imgSrc is Map<String, dynamic> && imgSrc.containsKey('1.5x')) {
      imageUrl = imgSrc['1.5x'].toString();
    } else if (imgSrc is String && imgSrc != 'Not available') {
      imageUrl = imgSrc;
    }
    if (imageUrl.startsWith('//')) imageUrl = 'https:$imageUrl';

    final meta = jsonItem['meta'];
    String fishFamily = 'Unknown Family';
    String status = 'Not Evaluated';
    String fClass = 'Unknown';
    String fOrder = 'Unknown';

    if (meta != null && meta is Map<String, dynamic>) {
      final classification = meta['scientific_classification'];
      if (classification != null) {
        if (classification['family'] != null) {
          fishFamily =
              classification['family'].toString().capitalizeFirst ?? '';
        }
        if (classification['class'] != null) {
          fClass = classification['class'].toString().capitalizeFirst ?? '';
        }
        if (classification['order'] != null) {
          fOrder = classification['order'].toString().capitalizeFirst ?? '';
        }
      }
      if (meta['conservation_status'] != null) {
        status = meta['conservation_status'].toString().split(' (').first;
      }
    }

    final fishName = jsonItem['name'] ?? 'Unknown Species';

    return SpeciesModel(
      id: jsonItem['id'].toString(),
      name: fishName,
      family: fishFamily,
      status: status,
      wikiUrl: jsonItem['url'] ?? '',
      fishClass: fClass,
      fishOrder: fOrder,
      description:
          'A fascinating marine species commonly known as the $fishName. '
          'Tap the button below to read its full history on Wikipedia, or ask our AI Assistant for specific care requirements.',
      imageUrl: imageUrl,
    );
  }
}
