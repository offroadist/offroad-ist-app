import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  List<dynamic> _addresses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await ApiService.getAddresses();
      setState(() { _addresses = data; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adreslerim')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _addresses.isEmpty
              ? const Center(child: Text('Kayıtlı adres yok'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _addresses.length,
                  itemBuilder: (_, i) {
                    final a = _addresses[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.location_on, color: Color(0xFF1B5E20)),
                        title: Text(a['title'] ?? a['name'] ?? 'Adres ${i + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${a['address'] ?? ''}\n${a['city'] ?? ''} ${a['district'] ?? ''}'),
                        isThreeLine: true,
                        trailing: a['is_default'] == true ? const Icon(Icons.check_circle, color: Color(0xFF1B5E20)) : null,
                      ),
                    );
                  },
                ),
    );
  }
}
