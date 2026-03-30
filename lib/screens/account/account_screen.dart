import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../auth/login_screen.dart';
import 'orders_screen.dart';
import 'addresses_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _loading = true;
  bool _loggedIn = false;
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loggedIn = await AuthService.isLoggedIn();
    if (!loggedIn) { setState(() { _loggedIn = false; _loading = false; }); return; }
    try {
      final data = await ApiService.getUser();
      setState(() { _user = data['data'] ?? data; _loggedIn = true; _loading = false; });
    } catch (_) {
      setState(() { _loggedIn = false; _loading = false; });
    }
  }

  Future<void> _logout() async {
    try { await ApiService.logout(); } catch (_) {}
    await AuthService.logout();
    setState(() { _loggedIn = false; _user = null; });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    if (!_loggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hesabım')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Hesabınıza erişmek için giriş yapın'),
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

    final name = '${_user?['first_name'] ?? ''} ${_user?['last_name'] ?? ''}'.trim();
    final email = _user?['email'] ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Hesabım')),
      body: ListView(
        children: [
          Container(
            color: const Color(0xFF1B5E20),
            padding: const EdgeInsets.all(24),
            child: Row(children: [
              CircleAvatar(radius: 32, backgroundColor: Colors.white24, child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'U', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold))),
              const SizedBox(width: 16),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text(email, style: const TextStyle(color: Colors.white70)),
              ]),
            ]),
          ),
          const SizedBox(height: 8),
          _tile(Icons.shopping_bag_outlined, 'Siparişlerim', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen()))),
          _tile(Icons.location_on_outlined, 'Adreslerim', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressesScreen()))),
          _tile(Icons.help_outline, 'Yardım', () {}),
          const Divider(),
          _tile(Icons.logout, 'Çıkış Yap', _logout, color: Colors.red),
        ],
      ),
    );
  }

  Widget _tile(IconData icon, String title, VoidCallback onTap, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: color != null ? TextStyle(color: color) : null),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
