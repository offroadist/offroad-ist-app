import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/cart_item.dart';
import '../widgets/price_text.dart';
import 'auth/login_screen.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> _items = [];
  bool _loading = true;
  bool _loggedIn = false;
  double _total = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loggedIn = await AuthService.isLoggedIn();
    if (!loggedIn) { setState(() { _loggedIn = false; _loading = false; }); return; }
    setState(() => _loggedIn = true);
    try {
      final data = await ApiService.getCart();
      final items = (data['items'] as List?)?.map((i) => CartItem.fromJson(i)).toList() ?? [];
      final total = (data['total'] ?? 0).toDouble();
      setState(() { _items = items; _total = total; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _remove(int productId) async {
    await ApiService.removeFromCart(productId);
    _load();
  }

  Future<void> _updateQty(int productId, int qty) async {
    if (qty <= 0) { _remove(productId); return; }
    await ApiService.updateCart(productId, qty);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loggedIn && !_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sepetim')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Sepetinizi görmek için giriş yapın'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())).then((_) => _load()),
                child: const Text('Giriş Yap'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_items.isEmpty ? 'Sepetim' : 'Sepetim (${_items.length})'),
        actions: [
          if (_items.isNotEmpty)
            TextButton(
              onPressed: () async {
                await ApiService.clearCart();
                _load();
              },
              child: const Text('Temizle', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 8),
                      Text('Sepetiniz boş', style: TextStyle(color: Colors.grey[500])),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _items.length,
                        itemBuilder: (_, i) {
                          final item = _items[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: item.image != null
                                        ? CachedNetworkImage(imageUrl: item.image!, width: 80, height: 80, fit: BoxFit.cover,
                                            errorWidget: (_, __, ___) => Container(width: 80, height: 80, color: Colors.grey[100]))
                                        : Container(width: 80, height: 80, color: Colors.grey[100]),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w500)),
                                        if (item.variantName != null)
                                          Text(item.variantName!, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                        const SizedBox(height: 4),
                                        PriceText(price: item.price, discountedPrice: item.discountedPrice),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Row(children: [
                                        IconButton(icon: const Icon(Icons.remove, size: 18), onPressed: () => _updateQty(item.id, item.quantity - 1)),
                                        Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        IconButton(icon: const Icon(Icons.add, size: 18), onPressed: () => _updateQty(item.id, item.quantity + 1)),
                                      ]),
                                      IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20), onPressed: () => _remove(item.id)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, -2))]),
                      child: SafeArea(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Toplam:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                PriceText(price: _total, fontSize: 18),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen())).then((_) => _load()),
                              child: const Text('Ödemeye Geç'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
