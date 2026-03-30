import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final data = await ApiService.register(
        _firstNameCtrl.text.trim(),
        _lastNameCtrl.text.trim(),
        _emailCtrl.text.trim(),
        _passCtrl.text,
      );
      await AuthService.saveToken(data['token']);
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      setState(() => _loading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kayıt başarısız'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kayıt Ol')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(children: [
                Expanded(child: TextFormField(controller: _firstNameCtrl, decoration: const InputDecoration(labelText: 'Ad', border: OutlineInputBorder()), validator: (v) => v == null || v.isEmpty ? 'Gerekli' : null)),
                const SizedBox(width: 12),
                Expanded(child: TextFormField(controller: _lastNameCtrl, decoration: const InputDecoration(labelText: 'Soyad', border: OutlineInputBorder()), validator: (v) => v == null || v.isEmpty ? 'Gerekli' : null)),
              ]),
              const SizedBox(height: 16),
              TextFormField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'E-posta', prefixIcon: Icon(Icons.email_outlined), border: OutlineInputBorder()), validator: (v) => v == null || v.isEmpty ? 'Gerekli' : null),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passCtrl, obscureText: _obscure,
                decoration: InputDecoration(labelText: 'Şifre', prefixIcon: const Icon(Icons.lock_outline), border: const OutlineInputBorder(), suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined), onPressed: () => setState(() => _obscure = !_obscure))),
                validator: (v) => v != null && v.length < 8 ? 'En az 8 karakter' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _register,
                child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Kayıt Ol'),
              ),
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Zaten hesabın var mı? Giriş yap')),
            ],
          ),
        ),
      ),
    );
  }
}
