import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';

class ProductListScreen extends StatefulWidget {
  final String? categorySlug;
  final String? title;

  const ProductListScreen({super.key, this.categorySlug, this.title});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final List<Product> _products = [];
  bool _loading = false;
  bool _hasMore = true;
  int _page = 1;
  String _sort = 'newest';
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200 && !_loading && _hasMore) {
        _loadProducts();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _loadProducts({bool reset = false}) async {
    if (_loading) return;
    if (reset) {
      setState(() { _products.clear(); _page = 1; _hasMore = true; });
    }
    setState(() => _loading = true);
    try {
      final data = await ApiService.getProducts(
        category: widget.categorySlug,
        sort: _sort,
        page: _page,
      );
      final items = (data['data'] as List).map((p) => Product.fromJson(p)).toList();
      final meta = data['meta'];
      setState(() {
        _products.addAll(items);
        _hasMore = meta['current_page'] < meta['last_page'];
        _page++;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Ürünler'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (v) { _sort = v; _loadProducts(reset: true); },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'newest', child: Text('En Yeni')),
              const PopupMenuItem(value: 'price_low', child: Text('Fiyat: Düşükten Yükseğe')),
              const PopupMenuItem(value: 'price_high', child: Text('Fiyat: Yüksekten Düşüğe')),
              const PopupMenuItem(value: 'popular', child: Text('En Popüler')),
            ],
          ),
        ],
      ),
      body: _products.isEmpty && _loading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
              ? const Center(child: Text('Ürün bulunamadı'))
              : GridView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _products.length + (_hasMore ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (i == _products.length) return const Center(child: CircularProgressIndicator());
                    return ProductCard(product: _products[i]);
                  },
                ),
    );
  }
}
