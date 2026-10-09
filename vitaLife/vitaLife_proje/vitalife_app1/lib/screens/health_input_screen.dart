import 'package:flutter/material.dart';
import 'api_service.dart';
import 'home_screen.dart';

class HealthInputScreen extends StatefulWidget {
  final String email, password;
  const HealthInputScreen({super.key, required this.email, required this.password});
  @override State<HealthInputScreen> createState() => _HealthInputScreenState();
}

class _HealthInputScreenState extends State<HealthInputScreen> {
  final _form = GlobalKey<FormState>();
  String _name = '', _surname = '', _allergies = '';

  // DEĞİŞİKLİK: Yaş yerine Doğum Tarihi tutuyoruz
  DateTime? _selectedBirthDate;
  double _w = 0, _h = 0;
  bool _isLoading = false;

  void _save() async {
    if (_form.currentState!.validate()) {
      // Doğum tarihi seçilmediyse kullanıcıyı uyaralım
      if (_selectedBirthDate == null) {
        _showError("Lütfen doğum tarihinizi seçin.");
        return;
      }

      _form.currentState!.save();
      setState(() => _isLoading = true);

      Map<String, dynamic> registerData = {
        "first_name": _name,
        "last_name": _surname,
        "email": widget.email,
        "password": widget.password,
        // DEĞİŞİKLİK: Veritabanındaki birth_date DATE formatına (YYYY-MM-DD) çeviriyoruz
        "birth_date": _selectedBirthDate!.toIso8601String().split('T')[0],
        "weight": _w,
        "height": _h,
        "allergens": _allergies
      };

      try {
        bool ok = await ApiService.register(registerData);

        if (ok) {
          Map<String, dynamic>? freshUser = await ApiService.login(widget.email, widget.password);

          if (freshUser != null && mounted) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (c) => HomeScreen(userData: freshUser))
            );
          }
        } else {
          _showError("Kayıt sırasında bir hata oluştu.");
        }
      } catch (e) {
        _showError("Sunucu hatası: $e");
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  // Takvim Seçici Fonksiyonu
  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.teal),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedBirthDate = picked);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9F8),
      appBar: AppBar(title: const Text("Profilini Oluştur"), backgroundColor: Colors.teal, foregroundColor: Colors.white),
      body: Form(
          key: _form,
          child: ListView(
              padding: const EdgeInsets.all(25),
              children: [
                const Text("Seni daha iyi tanımamıza yardımcı ol ✨",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal)),
                const SizedBox(height: 20),
                _inputField("Ad", (v) => _name = v ?? ""),
                _inputField("Soyad", (v) => _surname = v ?? ""),

                // DEĞİŞİKLİK: Yaş inputu yerine Doğum Tarihi butonu
                _dateSelector(),

                _inputField("Boy (cm)", (v) => _h = double.tryParse(v?.replaceAll(',', '.') ?? "0") ?? 0, isNum: true),
                _inputField("Kilo (kg)", (v) => _w = double.tryParse(v?.replaceAll(',', '.') ?? "0") ?? 0, isNum: true),
                _inputField("Alerjiler (Yoksa boş bırak)", (v) => _allergies = (v == null || v.isEmpty) ? "Yok" : v),
                const SizedBox(height: 30),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                    ),
                    child: const Text("Hesabımı Oluştur", style: TextStyle(fontSize: 16, color: Colors.white))
                )
              ]
          )
      ),
    );
  }

  // Takvim Seçme Alanı Tasarımı
  Widget _dateSelector() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: InkWell(
        onTap: _pickDate,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.cake_rounded, color: Colors.teal),
              const SizedBox(width: 10),
              Text(
                _selectedBirthDate == null
                    ? "Doğum Tarihinizi Seçin"
                    : "${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year}",
                style: TextStyle(
                  fontSize: 16,
                  color: _selectedBirthDate == null ? Colors.grey[600] : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField(String label, Function(String?) onSave, {bool isNum = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true, fillColor: Colors.white
        ),
        keyboardType: isNum ? TextInputType.number : TextInputType.text,
        onSaved: onSave,
      ),
    );
  }
}