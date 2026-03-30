class Product {
  final int id;
  final String name;
  final String slug;
  final double price;
  final double? discountedPrice;
  final int? discountPercent;
  final bool isInStock;
  final String? image;
  final String? category;
  final String? brand;
  final double? rating;
  final int? reviewCount;
  final bool isNew;

  Product({
    required this.id,
    required this.name,
    required this.slug,
    required this.price,
    this.discountedPrice,
    this.discountPercent,
    required this.isInStock,
    this.image,
    this.category,
    this.brand,
    this.rating,
    this.reviewCount,
    this.isNew = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      discountedPrice: json['discounted_price'] != null ? (json['discounted_price']).toDouble() : null,
      discountPercent: json['discount_percent'],
      isInStock: json['is_in_stock'] ?? true,
      image: json['image'],
      category: json['category'],
      brand: json['brand'],
      rating: json['rating'] != null ? (json['rating']).toDouble() : null,
      reviewCount: json['review_count'],
      isNew: json['is_new'] ?? false,
    );
  }

  double get displayPrice => discountedPrice ?? price;
  bool get hasDiscount => discountedPrice != null && discountedPrice! < price;
}
