class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  String? imageUrl;
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.category,
  });

  String get priceLabel => '${price.toStringAsFixed(0)} EGP';
}
