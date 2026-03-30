import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  Map<String, dynamic>? _checkout;
  bool _loading = true;
  bool _processing = false;
  int? _selectedAddressId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await ApiService.getCheckout();
      setState(() { _checkout = data; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _processOrder() async {
    if (_selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen adres seçin'), backgroundColor: Colors.red));
      return;
    }
    setState(() => _processing = true);
    try {
      final data = await ApiService.processCheckout({'address_id': _selectedAddressId});
      if (data['payment_url'] != null) {
        final url = Uri.parse(data['payment_url']);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      } else if (data['order_id'] != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sipariş oluşturuldu!'), backgroundColor: Color(0xFF1B5E20)));
          Navigator.pop(context, true);
        }
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sipariş verilemedi'), backgroundColor: Colors.red));
    }
    setState(() => _processing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ödeme')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _checkout == null
              ? const Center(child: Text('Yüklenemedi'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Addresses
                    const Text('Teslimat Adresi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    ...(_checkout!['addresses'] as List? ?? []).map((a) {
                      return RadioListTile<int>(
                        value: a['id'],
                        groupValue: _selectedAddressId,
                        onChanged: (v) => setState(() => _selectedAddressId = v),
                        title: Text(a['title'] ?? 'Adres'),
                        subtitle: Text('${a['address'] ?? ''}, ${a['city'] ?? ''}'),
                        activeColor: const Color(0xFF1B5E20),
                      );
                    }),
                    const SizedBox(height: 16),
                    // Order summary
                    const Text('Sipariş Özeti', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    ...(_checkout!['items'] as List? ?? []).map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text('${item['name']} x${item['quantity']}')),
                            Text('₺${item['total'] ?? 0}'),
                          ],
                        ),
                      );
                    }),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Toplam', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('₺${_checkout!['total'] ?? 0}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1B5E20))),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _processing ? null : _processOrder,
                      child: _processing ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Siparişi Tamamla'),
                    ),
                  ],
                ),
    );
  }
}
