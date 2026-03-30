class Category {
  final int id;
  final String name;
  final String slug;
  final String? image;
  final int? parentId;
  final List<Category> children;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    this.image,
    this.parentId,
    this.children = const [],
  });

  static String _fullUrl(String path) {
    if (path.startsWith('http')) return path;
    final clean = path.replaceAll(RegExp(r'/+'), '/');
    return 'https://www.offroad.ist$clean';
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      image: json['image'] != null ? _fullUrl(json['image']) : null,
      parentId: json['parent_id'],
      children: (json['children'] as List<dynamic>?)
              ?.map((c) => Category.fromJson(c))
              .toList() ?? [],
    );
  }
}
