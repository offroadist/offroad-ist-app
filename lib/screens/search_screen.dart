import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  List<Product> _results = [];
  bool _loading = false;
  bool _searched = false;
  int _page = 1;
  bool _hasMore = true;

  Future<void> _search({bool reset = false}) async {
    final q = _controller.text.trim();
    if (q.length < 2) return;
    if (reset) { setState(() { _results.clear(); _page = 1; _hasMore = true; }); }
    setState(() => _loading = true);
    try {
      final data = await ApiService.searchProducts(q, page: _page);
      final items = (data['data'] as List).map((p) => Product.fromJson(p)).toList();
      final meta = data['meta'];
      setState(() {
        _results.addAll(items);
        _hasMore = meta['current_page'] < meta['last_page'];
        _page++;
        _loading = false;
        _searched = true;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: false,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Ürün ara...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          onSubmitted: (_) => _search(reset: true),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () => _search(reset: true)),
        ],
      ),
      body: !_searched
          ? Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 8),
                Text('Ürün aramak için yazın', style: TextStyle(color: Colors.grey[500])),
              ],
            ))
          : _loading && _results.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : _results.isEmpty
                  ? Center(child: Text('"${_controller.text}" için sonuç bulunamadı'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, childAspectRatio: 0.68, crossAxisSpacing: 8, mainAxisSpacing: 8,
                      ),
                      itemCount: _results.length + (_hasMore ? 1 : 0),
                      itemBuilder: (_, i) {
                        if (i == _results.length) return const Center(child: CircularProgressIndicator());
                        return ProductCard(product: _results[i]);
                      },
                    ),
    );
  }
}
