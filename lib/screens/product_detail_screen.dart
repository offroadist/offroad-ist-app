import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/price_text.dart';
import 'auth/login_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final String slug;
  const ProductDetailScreen({super.key, required this.slug});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Map<String, dynamic>? _product;
  bool _loading = true;
  bool _addingToCart = false;
  int _selectedVariant = -1;
  int _qty = 1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await ApiService.getProduct(widget.slug);
      setState(() { _product = data['data']; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _addToCart() async {
    final loggedIn = await AuthService.isLoggedIn();
    if (!loggedIn) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }
    setState(() => _addingToCart = true);
    try {
      final p = _product!;
      final variants = p['variants'] as List?;
      final variantId = (variants != null && _selectedVariant >= 0 && _selectedVariant < variants.length)
          ? variants[_selectedVariant]['id'] as int?
          : null;
      await ApiService.addToCart(p['id'], quantity: _qty, variantId: variantId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sepete eklendi'), backgroundColor: Color(0xFF1B5E20)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sepete eklenemedi'), backgroundColor: Colors.red));
      }
    }
    setState(() => _addingToCart = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_product == null) return Scaffold(appBar: AppBar(), body: const Center(child: Text('Ürün bulunamadı')));

    final p = _product!;
    final images = (p['images'] as List?) ?? [];
    final variants = (p['variants'] as List?) ?? [];
    final specs = p['specifications'] as Map<String, dynamic>?;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: images.isNotEmpty
                  ? PageView.builder(
                      itemCount: images.length,
                      itemBuilder: (_, i) => CachedNetworkImage(
                        imageUrl: images[i]['url'] ?? images[i]['image'] ?? '',
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(color: Colors.grey[100], child: const Icon(Icons.image_not_supported, size: 60)),
                      ),
                    )
                  : Container(color: Colors.grey[100], child: const Icon(Icons.image_not_supported, size: 60, color: Colors.grey)),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (p['brand'] != null)
                    Text(p['brand'], style: const TextStyle(color: Color(0xFF1B5E20), fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(p['name'] ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  PriceText(
                    price: (p['price'] ?? 0).toDouble(),
                    discountedPrice: p['discounted_price'] != null ? (p['discounted_price']).toDouble() : null,
                    fontSize: 22,
                  ),
                  if (p['average_rating'] != null) ...[
                    const SizedBox(height: 8),
                    Row(children: [
                      RatingBarIndicator(
                        rating: (p['average_rating'] ?? 0).toDouble(),
                        itemBuilder: (_, __) => const Icon(Icons.star, color: Colors.amber),
                        itemCount: 5, itemSize: 18,
                      ),
                      const SizedBox(width: 4),
                      Text('(${p['review_count'] ?? 0})', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ]),
                  ],
                ],
              ),
            ),
          ),

          // Variants
          if (variants.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Seçenekler', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: List.generate(variants.length, (i) {
                        final v = variants[i];
                        final selected = _selectedVariant == i;
                        return ChoiceChip(
                          label: Text(v['name'] ?? ''),
                          selected: selected,
                          onSelected: (_) => setState(() => _selectedVariant = i),
                          selectedColor: const Color(0xFF1B5E20),
                          labelStyle: TextStyle(color: selected ? Colors.white : null),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),

          // Description
          if (p['description'] != null)
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ürün Açıklaması', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(p['description'] ?? '', style: TextStyle(color: Colors.grey[700], height: 1.5)),
                  ],
                ),
              ),
            ),

          // Specs
          if (specs != null && specs.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Özellikler', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    ...specs.entries.map((e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(flex: 2, child: Text(e.key, style: const TextStyle(color: Colors.grey))),
                          Expanded(flex: 3, child: Text(e.value.toString(), style: const TextStyle(fontWeight: FontWeight.w500))),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
                child: Row(children: [
                  IconButton(icon: const Icon(Icons.remove), onPressed: () { if (_qty > 1) setState(() => _qty--); }),
                  Text('$_qty', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  IconButton(icon: const Icon(Icons.add), onPressed: () => setState(() => _qty++)),
                ]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _addingToCart ? null : _addToCart,
                  icon: _addingToCart ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.shopping_cart),
                  label: const Text('Sepete Ekle'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
