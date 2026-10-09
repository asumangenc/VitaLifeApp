import 'package:flutter/material.dart';
import 'api_service.dart';
import 'home_screen.dart';
import 'health_input_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        // 1. Python'dan kullanıcı verilerini (Map) çekiyoruz
        final userData = await ApiService.login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        if (userData != null) {
          // --- HATA BURADAYDI VE DÜZELTİLDİ ---
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                // userData: userData ekledik, artık paket HomeScreen'e gidiyor!
                builder: (context) => HomeScreen(userData: userData),
              ),
            );
          }
        } else {
          _showError('E-posta veya şifre hatalı.');
        }
      } else {
        // Kayıt Ol Modu
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HealthInputScreen(
                email: _emailController.text.trim(),
                password: _passwordController.text.trim(),
              ),
            ),
          );
        }
      }
    } catch (e) {
      _showError('Sunucuya bağlanırken bir hata oluştu.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal, // Arka plan rengini düzelttim
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo ikonunun rengini beyaz yaptım ki teal üzerinde görünsün
              const Icon(Icons.eco, size: 80, color: Colors.white),
              const SizedBox(height: 10),
              const Text(
                'VitaLife',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 30),

              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(labelText: 'E-posta', prefixIcon: Icon(Icons.email)),
                          validator: (value) => (value == null || !value.contains('@')) ? 'Geçerli bir e-posta girin.' : null,
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(labelText: 'Şifre', prefixIcon: Icon(Icons.lock)),
                          validator: (value) => (value == null || value.length < 6) ? 'Şifre en az 6 karakter olmalı.' : null,
                        ),
                        const SizedBox(height: 25),

                        if (_isLoading)
                          const CircularProgressIndicator()
                        else ...[
                          ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text(_isLogin ? 'Giriş Yap' : 'Sonraki Adım', style: const TextStyle(color: Colors.white)),
                          ),
                          TextButton(
                            onPressed: () => setState(() => _isLogin = !_isLogin),
                            child: Text(_isLogin ? 'Hesabın yok mu? Kayıt Ol' : 'Zaten hesabın var mı? Giriş Yap'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}