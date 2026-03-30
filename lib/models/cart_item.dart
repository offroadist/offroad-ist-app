class CartItem {
  final int id;
  final String name;
  final String slug;
  final double price;
  final double? discountedPrice;
  final String? image;
  int quantity;
  final int? variantId;
  final String? variantName;

  CartItem({
    required this.id,
    required this.name,
    required this.slug,
    required this.price,
    this.discountedPrice,
    this.image,
    required this.quantity,
    this.variantId,
    this.variantName,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final product = json['product'] ?? json;
    return CartItem(
      id: product['id'] ?? json['product_id'],
      name: product['name'] ?? '',
      slug: product['slug'] ?? '',
      price: (json['price'] ?? product['price'] ?? 0).toDouble(),
      discountedPrice: json['discounted_price'] != null ? (json['discounted_price']).toDouble() : null,
      image: product['image'],
      quantity: json['quantity'] ?? 1,
      variantId: json['variant_id'],
      variantName: json['variant_name'],
    );
  }

  double get displayPrice => discountedPrice ?? price;
  double get total => displayPrice * quantity;
}
