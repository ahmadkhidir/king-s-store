class FeatureModel {
  FeatureModel({required this.title, required this.description});
  final String title, description;

  factory FeatureModel.fromMap(Map<String, dynamic> map) {
    return FeatureModel(
      title: map.entries.first.key,
      description: map.entries.first.value,
    );
  }
}

class ProductModel {
  ProductModel({
    required this.id,
    required this.asin,
    required this.brand,
    required this.breadcumbs,
    required this.productDetails,
    required this.title,
    required this.features,
    required this.images,
    required this.price,
  });
  final String? id, asin, brand, breadcumbs, productDetails, title;
  final List<FeatureModel> features;
  final List<String> images;
  final ({String? min, String? max}) price;

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'],
      asin: map['asin'],
      brand: map['brand'],
      breadcumbs: map['breadcumbs'],
      productDetails: map['product_details'].replaceAll("\n\n", "###").replaceAll("\n", " ").replaceAll("###", ""),
      title: map['title'],
      features: List<FeatureModel>.from(
        (map['features']).map((x) => FeatureModel.fromMap(x)),
      ),
      images: List<String>.from((map['images_list'] as List).where((x) => x != null)),
      price: (
        min: (map['price'] as String?)?.split('-').firstOrNull ?? "Free",
        max: (map['price'] as String?)?.split('-').lastOrNull,
      ),
    );
  }
}
