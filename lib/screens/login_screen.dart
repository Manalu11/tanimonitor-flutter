import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _showPassword = false;

  void _login() {
    if (_formKey.currentState!.validate()) {
      NotificationService.instance.tampilkan(
        judul: 'Login Berhasil',
        isi: 'Selamat datang kembali di TaniMonitor',
        id: 1,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login berhasil, mengalihkan ke dashboard')),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => DashboardScreen(username: _usernameController.text),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.eco, size: 60, color: Color(0xFF2E7D32)),
                const SizedBox(height: 12),
                const Text(
                  'Masuk ke TaniMonitor',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Username wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_showPassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _showPassword = !_showPassword),
                    ),
                  ),
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Password wajib diisi' : null,
                ),
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) => setState(() => _rememberMe = value ?? false),
                    ),
                    const Text('Ingat Saya'),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _login,
                    child: const Text('Masuk', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
