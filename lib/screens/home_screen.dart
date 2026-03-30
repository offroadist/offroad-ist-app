import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/api_service.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../widgets/product_card.dart';
import 'product_list_screen.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = true;
  List<dynamic> _sliders = [];
  List<Category> _categories = [];
  List<Product> _latestProducts = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHome();
  }

  Future<void> _loadHome() async {
    try {
      final data = await ApiService.getHome();
      setState(() {
        _sliders = data['sliders'] ?? [];
        _categories = (data['categories']['data'] as List)
            .map((c) => Category.fromJson(c))
            .toList();
        _latestProducts = (data['latest_products']['data'] as List)
            .map((p) => Product.fromJson(p))
            .toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 60,
            floating: true,
            pinned: true,
            backgroundColor: const Color(0xFF1B5E20),
            title: Row(
              children: [
                const Icon(Icons.terrain, color: Colors.white),
                const SizedBox(width: 8),
                const Text('OffRoad.ist', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
          if (_loading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else if (_error != null)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                    const SizedBox(height: 8),
                    Text('Yüklenemedi', style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: _loadHome, child: const Text('Tekrar Dene')),
                  ],
                ),
              ),
            )
          else ...[
            // Sliders
            if (_sliders.isNotEmpty)
              SliverToBoxAdapter(
                child: _SliderBanner(sliders: _sliders),
              ),

            // Categories
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Kategoriler', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductListScreen())),
                      child: const Text('Tümü'),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _categories.length,
                  itemBuilder: (_, i) {
                    final cat = _categories[i];
                    return GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => ProductListScreen(categorySlug: cat.slug, title: cat.name),
                      )),
                      child: Container(
                        width: 80,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                              ),
                              child: cat.image != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: CachedNetworkImage(imageUrl: cat.image!, fit: BoxFit.cover,
                                        errorWidget: (_, __, ___) => const Icon(Icons.category, color: Color(0xFF1B5E20)),
                                      ),
                                    )
                                  : const Icon(Icons.category, color: Color(0xFF1B5E20)),
                            ),
                            const SizedBox(height: 4),
                            Text(cat.name, style: const TextStyle(fontSize: 11), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Latest Products
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Yeni Ürünler', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductListScreen())),
                      child: const Text('Tümü'),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.68,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                delegate: SliverChildBuilderDelegate(
                  (_, i) => ProductCard(product: _latestProducts[i]),
                  childCount: _latestProducts.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        ],
      ),
    );
  }
}

class _SliderBanner extends StatefulWidget {
  final List<dynamic> sliders;
  const _SliderBanner({required this.sliders});

  @override
  State<_SliderBanner> createState() => _SliderBannerState();
}

class _SliderBannerState extends State<_SliderBanner> {
  final PageController _pageController = PageController(viewportFraction: 0.92);
  int _current = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), _autoScroll);
  }

  void _autoScroll() {
    if (!mounted) return;
    final next = (_current + 1) % widget.sliders.length;
    _pageController.animateToPage(next, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    Future.delayed(const Duration(seconds: 3), _autoScroll);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.sliders.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (_, i) {
              final s = widget.sliders[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: s['image'] ?? '',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorWidget: (_, __, ___) => Container(
                      color: const Color(0xFF1B5E20),
                      child: const Center(child: Icon(Icons.terrain, color: Colors.white, size: 48)),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.sliders.length, (i) => Container(
            width: _current == i ? 16 : 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: _current == i ? const Color(0xFF1B5E20) : Colors.grey[300],
              borderRadius: BorderRadius.circular(3),
            ),
          )),
        ),
      ],
    );
  }
}
