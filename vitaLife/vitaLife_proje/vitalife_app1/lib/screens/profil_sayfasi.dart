import 'package:flutter/material.dart';
import 'api_service.dart';

class ProfilSayfasi extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const ProfilSayfasi({super.key, this.userData});

  @override
  State<ProfilSayfasi> createState() => _ProfilSayfasiState();
}

class _ProfilSayfasiState extends State<ProfilSayfasi> {
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;

  DateTime? _selectedBirthDate;
  bool _isEditing = false;
  bool _isLoading = false;
  late Map<String, dynamic> _currentUserData;

  @override
  void initState() {
    super.initState();
    _initializeData();

    _weightController.addListener(_onInputChanged);
    _heightController.addListener(_onInputChanged);
  }

  void _onInputChanged() {
    if (mounted) setState(() {});
  }

  int _calculateAge(DateTime birthDate) {
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  void _initializeData() {
    _currentUserData = Map<String, dynamic>.from(widget.userData ?? {});

    String getVal(String key) {
      var val = _currentUserData[key];
      if (val == null || val.toString() == "null" || val.toString() == "0") return "";
      return val.toString();
    }

    // Controller'ları veritabanı sütun isimlerine göre dolduruyoruz
    _firstNameController = TextEditingController(text: getVal('first_name'));
    _lastNameController = TextEditingController(text: getVal('last_name'));
    _weightController = TextEditingController(text: getVal('weight'));
    _heightController = TextEditingController(text: getVal('height'));

    if (_currentUserData['birth_date'] != null && _currentUserData['birth_date'] != "null") {
      _selectedBirthDate = DateTime.tryParse(_currentUserData['birth_date'].toString());
    }
  }

  @override
  void dispose() {
    _weightController.removeListener(_onInputChanged);
    _heightController.removeListener(_onInputChanged);
    _firstNameController.dispose();
    _lastNameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      locale: const Locale('tr', 'TR'),
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

  @override
  Widget build(BuildContext context) {
    double kilo = double.tryParse(_weightController.text) ?? 0;
    double boy = double.tryParse(_heightController.text) ?? 0;
    double vki = boy > 0 ? kilo / ((boy / 100) * (boy / 100)) : 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFA),
      appBar: AppBar(
        title: const Text("Profilim", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.cancel_outlined : Icons.edit_note_rounded, size: 28),
            onPressed: () => setState(() => _isEditing = !_isEditing),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
              ),
              padding: const EdgeInsets.only(bottom: 30),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: const CircleAvatar(
                      radius: 55,
                      backgroundColor: Color(0xFFE0F2F1),
                      child: Icon(Icons.person_rounded, size: 70, color: Colors.teal),
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Veritabanındaki ad ve soyadı burada birleştirip gösteriyoruz
                  Text(
                    "${_firstNameController.text} ${_lastNameController.text}",
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                children: [
                  if (_isEditing) ...[
                    _buildInputField("Adınız", _firstNameController, Icons.person_outline),
                    _buildInputField("Soyadınız", _lastNameController, Icons.person_pin_outlined),
                  ],
                  _buildBirthDateTile(),
                  _buildInputField("Boyunuz (cm)", _heightController, Icons.height_rounded),
                  _buildInputField("Kilonuz (kg)", _weightController, Icons.scale_rounded),

                  const SizedBox(height: 25),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
                    ),
                    child: Column(
                      children: [
                        const Text("Canlı Sağlık Özeti (VKİ)", style: TextStyle(fontSize: 14, color: Colors.blueGrey)),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              vki > 0 ? vki.toStringAsFixed(1) : "--",
                              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.teal),
                            ),
                            const SizedBox(width: 15),
                            _buildBMIDisplay(vki),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  if (_isEditing)
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.teal)
                        : ElevatedButton(
                      onPressed: _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        minimumSize: const Size(double.infinity, 60),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text("TÜM BİLGİLERİ KAYDET", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),

                  const SizedBox(height: 20),
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false),
                    icon: const Icon(Icons.logout_rounded, color: Colors.red),
                    label: const Text("Çıkış Yap", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBirthDateTile() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: InkWell(
        onTap: _isEditing ? _pickBirthDate : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              const Icon(Icons.cake_rounded, color: Colors.teal),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Doğum Tarihi", style: TextStyle(fontSize: 12, color: Colors.teal)),
                  Text(
                    _selectedBirthDate == null
                        ? "Seçmek için dokunun"
                        : "${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year} "
                        "(${_calculateAge(_selectedBirthDate!)} Yaş)",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const Spacer(),
              if (_isEditing) const Icon(Icons.calendar_month, color: Colors.teal, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        controller: controller,
        enabled: _isEditing,
        keyboardType: (label.contains("Boy") || label.contains("Kilo"))
            ? TextInputType.number
            : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.teal),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Colors.teal)),
        ),
      ),
    );
  }

  Widget _buildBMIDisplay(double vki) {
    String durum; Color renk;
    if (vki <= 0) { durum = "---"; renk = Colors.grey; }
    else if (vki < 18.5) { durum = "Zayıf"; renk = Colors.blue; }
    else if (vki < 25) { durum = "İdeal"; renk = Colors.green; }
    else if (vki < 30) { durum = "Kilolu"; renk = Colors.orange; }
    else { durum = "Obez"; renk = Colors.red; }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: renk.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Text(durum, style: TextStyle(color: renk, fontWeight: FontWeight.bold)),
    );
  }

  Future<void> _updateProfile() async {
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    String weightText = _weightController.text.replaceAll(',', '.');

    Map<String, dynamic> updateData = {
      "email": _currentUserData['email'],
      "first_name": _firstNameController.text, // Güncellendi
      "last_name": _lastNameController.text,   // Güncellendi
      "weight": double.tryParse(weightText) ?? 0.0,
      "height": int.tryParse(_heightController.text) ?? 0,
      "birth_date": _selectedBirthDate?.toIso8601String().split('T')[0],
    };

    try {
      bool success = await ApiService.updateUser(updateData);
      if (success) {
        setState(() {
          _isEditing = false;
          _currentUserData['first_name'] = updateData['first_name'];
          _currentUserData['last_name'] = updateData['last_name'];
          _currentUserData['weight'] = updateData['weight'];
          _currentUserData['height'] = updateData['height'];
          _currentUserData['birth_date'] = updateData['birth_date'];
        });
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profil bilgileriniz güncellendi!"), backgroundColor: Colors.teal)
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Hata: Bilgiler kaydedilemedi."), backgroundColor: Colors.red)
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}