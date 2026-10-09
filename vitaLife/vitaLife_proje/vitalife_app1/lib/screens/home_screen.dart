import 'package:flutter/material.dart';
import 'api_service.dart';
import 'profil_sayfasi.dart';
import 'ai_chat_screen.dart';
import '../game/ingredient_game_screen.dart';
class HomeScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const HomeScreen({super.key, this.userData});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _searchQuery = "";
  String _selectedFilter = "Hepsi";
  List<String> _excludedAllergens = [];
  String _selectedCity = "";
  String _selectedIngredient = "";
  final List<String> _cities = ["Hepsi", "Malatya", "İstanbul", "Adana", "Bolu", "İzmir"]; // Örnek liste
  final List<String> _commonIngredients = ["Hepsi", "Bulgur", "Et", "Tavuk", "Patlıcan", "Nohut"];

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      _buildDashboard(),
      AIChatScreen(userData: widget.userData),
      _buildRecipesPage(),
      IngredientGameScreen()
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFA), // Daha yumuşak bir arka plan
      appBar: AppBar(
        title: const Text('VitaLife', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
        ),
        actions: [
          _buildPointsBadge(),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              icon: const Icon(Icons.account_circle_outlined, size: 32),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilSayfasi(userData: widget.userData)),
              ),
            ),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            selectedItemColor: Colors.teal,
            unselectedItemColor: Colors.grey.shade400,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Ana Sayfa'),
              BottomNavigationBarItem(icon: Icon(Icons.psychology_rounded), label: 'AI Analiz'),
              // flat_ware_rounded yerine restaurant_menu_rounded kullandık:
              BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu_rounded), label: 'Tarifler'),
              BottomNavigationBarItem(icon: Icon(Icons.sports_esports_rounded), label: 'Oyun'),
            ],
          ),
        ),
      ),
    );
  }


  // --- MODERN ANA SAYFA ---
  Widget _buildDashboard() {
    double kilo = double.tryParse(widget.userData?['weight']?.toString() ?? "0") ?? 0;
    double boy = double.tryParse(widget.userData?['height']?.toString() ?? "0") ?? 0;
    double vki = boy > 0 ? kilo / ((boy / 100) * (boy / 100)) : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: "Merhaba, ",
              style: const TextStyle(fontSize: 24, color: Colors.black87),
              children: [
                TextSpan(
                  text: "${widget.userData?['first_name'] ?? 'Kullanıcı'} 👋",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          _buildGoalCard(),
          const SizedBox(height: 30),
          Row(
            children: [
              _statCard("VKİ", vki.toStringAsFixed(1), Colors.blue, Icons.speed_rounded),
              const SizedBox(width: 15),
              _statCard("Kilo", "$kilo kg", Colors.orange, Icons.monitor_weight_rounded),
            ],
          ),
          const SizedBox(height: 35),
          const Text("Bugünkü Görevler ✨",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          const SizedBox(height: 15),
          _taskItem("Yeni Tarif Dene", "50 Puan", Icons.restaurant_rounded, Colors.green),
          _taskItem("AI Analizini Kontrol Et", "20 Puan", Icons.psychology_alt_rounded, Colors.purple),
          const SizedBox(height: 35),
          _buildInspirationCard(), // Yeni eklediğimiz görsel kart
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  // --- MODERN TARİFLER ---
  Widget _buildInspirationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        image: const DecorationImage(
          image: NetworkImage("https://images.unsplash.com/photo-1490645935967-10de6ba17061?q=80&w=2070"), // Taze sebze/sağlık temalı bir görsel
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Container(
        // Görselin üzerine metnin okunması için hafif karartma
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Icon(Icons.format_quote_rounded, color: Colors.orange, size: 40),
            Text(
              "Sağlıklı beslenmek bir zorunluluk değil, kendine verdiğin bir hediyedir.",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "- VitaLife Ekibi",
              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildRecipesPage() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          ),
          child: Column(
            children: [
              TextField(
                onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                decoration: InputDecoration(
                  hintText: "Yemek ara...",
                  prefixIcon: const Icon(Icons.search_rounded, color: Colors.teal),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 15),
              // _buildRecipesPage içindeki Row'u şununla değiştir:
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _filterChip("Hepsi"),
                    const SizedBox(width: 10),
                    _ingredientExcludeMenu(),
                    _cityFilterMenu(), // Yeni Şehir Filtresi
                    const SizedBox(width: 10),
                    _ingredientFilterMenu(), // Yeni Malzeme Filtresi
                    const SizedBox(width: 10),
                    _allergenMenuButton(),
                  ],
                ),
              ),
              if (_excludedAllergens.isNotEmpty) _buildAllergenChips(),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<dynamic>>(
            future: ApiService.fetchRecipes(
              exclude:_excludedAllergens.join(','),
              city: _selectedCity,                  // Şehir filtresini ekledik
              ingredient: _selectedIngredient,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              if (snapshot.hasError) return const Center(child: Text("Sunucu bağlantı hatası."));

              List<dynamic> recipes = snapshot.data?.where((r) {
                final name = (r['food_name'] ?? "").toString().toLowerCase();
                return name.contains(_searchQuery);
              }).toList() ?? [];

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: recipes.length,
                itemBuilder: (context, index) {
                  final data = recipes[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.fastfood_rounded, color: Colors.orange),
                      ),
                      title: Text(data['food_name'] ?? "Tarif", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      subtitle: Text("🔥 ${data['calories_per_portion'] ?? '0'} kcal", style: TextStyle(color: Colors.grey.shade600)),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.teal, size: 18),
                      onTap: () => _handleRecipeClick(context, data),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // --- MODERN METODLAR ---
  Widget _ingredientExcludeMenu() {
    final List<String> commonFoods = ["Soğan", "Domates", "Sarımsak", "Biber", "Kıyma", "Pirinç"];

    return PopupMenuButton<String>(
      onSelected: (val) {
        if (!_excludedAllergens.contains(val)) {
          setState(() => _excludedAllergens.add(val));
        }
      },
      itemBuilder: (context) => commonFoods.map((food) => PopupMenuItem(
        value: food,
        child: Text("$food Olmasın"),
      )).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Text("Malzeme Çıkar ❌", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
      ),
    );
  }
  // Şehir Filtreleme Menüsü
  Widget _cityFilterMenu() {
    return PopupMenuButton<String>(
      onSelected: (val) => setState(() => _selectedCity = val == "Hepsi" ? "" : val),
      itemBuilder: (context) => _cities.map((city) => PopupMenuItem(value: city, child: Text(city))).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: _selectedCity.isEmpty ? Colors.blue.shade50 : Colors.blue.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(_selectedCity.isEmpty ? "Şehir 📍" : _selectedCity,
            style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold)),
      ),
    );
  }

// Malzeme Filtreleme Menüsü
  Widget _ingredientFilterMenu() {
    return PopupMenuButton<String>(
      onSelected: (val) => setState(() => _selectedIngredient = val == "Hepsi" ? "" : val),
      itemBuilder: (context) => _commonIngredients.map((ing) => PopupMenuItem(value: ing, child: Text(ing))).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: _selectedIngredient.isEmpty ? Colors.orange.shade50 : Colors.orange.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(_selectedIngredient.isEmpty ? "Malzeme 🥕" : _selectedIngredient,
            style: TextStyle(color: Colors.orange.shade900, fontWeight: FontWeight.bold)),
      ),
    );
  }
  Widget _statCard(String label, String val, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 12),
            Text(val, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: const TextStyle(fontSize: 14, color: Colors.blueGrey, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.teal, Colors.teal.shade700]),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.teal.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Günlük Hedef", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
              Text("%65", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
                value: 0.65,
                backgroundColor: Colors.white24,
                color: Colors.orange,
                minHeight: 10
            ),
          ),
        ],
      ),
    );
  }

  Widget _taskItem(String title, String pts, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: ListTile(
        leading: Icon(icon, color: color, size: 28),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12)),
          child: Text("+$pts", style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ),
    );
  }

  Widget _filterChip(String label) {
    bool isSelected = _selectedFilter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) => setState(() => _selectedFilter = label),
      selectedColor: Colors.teal,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.teal, fontWeight: FontWeight.bold),
      backgroundColor: Colors.white,
      shape: StadiumBorder(side: BorderSide(color: Colors.teal.withOpacity(0.2))),
    );
  }

  // Tıklama, dialog ve badge metodlarını senin çalışan versiyonundan olduğu gibi bıraktım (Mantık değişmedi)
  // --- YENİLENMİŞ TIKLAMA FONKSİYONU ---
  void _handleRecipeClick(BuildContext context, Map<String, dynamic> basicData) async {
    print(">>> Tıklanan Yemek ID: ${basicData['id']}"); // Bunu ekle
    // Yükleme ekranı
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => const Center(child: CircularProgressIndicator())
    );

    // Veritabanından tam detayı çekiyoruz
    final detailData = await ApiService.fetchRecipeDetail(basicData['id'].toString());

    if (mounted) Navigator.pop(context); // Yüklemeyi kapat

    if (detailData != null && mounted) {
      _showQuickSummarySheet(context, detailData);
    }
  }

  // --- KISA ÖZET PENCERESİ ---
  void _showQuickSummarySheet(BuildContext context, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(25, 20, 25, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            Text(data['food_name'] ?? "Tarif",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal)),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _summaryIcon(Icons.local_fire_department, "${data['calories_per_portion'] ?? 0} kcal"),
                _summaryIcon(Icons.timer, "${data['prep_time'] ?? 0} dk"),
                _summaryIcon(Icons.location_on, data['city'] ?? "Genel"),
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () {
                  Navigator.pop(context); // Özet panelini kapat
                  // DETAY SAYFASINA GİT
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MealDetailScreen(meal: data)),
                  );
                },
                child: const Text("TÜM DETAYLARI VE TARİFİ GÖR",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _summaryIcon(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.orange),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  void _showRecipeDetailsSheet(BuildContext context, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        padding: const EdgeInsets.fromLTRB(25, 20, 25, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 20),
            Text(data['food_name'] ?? "Tarif Detayı", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal)),
            const SizedBox(height: 20),
            const Text("🍳 Malzemeler", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text(data['materials'] ?? '', style: const TextStyle(fontSize: 16, height: 1.5)),
            const SizedBox(height: 25),
            const Text("📖 Hazırlanışı", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text(data['description'] ?? '', style: const TextStyle(fontSize: 16, height: 1.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsBadge() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white30),
        ),
        child: Row(
          children: const [
            Icon(Icons.stars_rounded, size: 20, color: Colors.orange),
            SizedBox(width: 6),
            Text("450 Puan", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _allergenMenuButton() {
    return PopupMenuButton<String>(
      onSelected: (val) { if(!_excludedAllergens.contains(val)) setState(() => _excludedAllergens.add(val)); },
      itemBuilder: (context) => [
        const PopupMenuItem(value: "Gluten", child: Text("Gluten")),
        const PopupMenuItem(value: "Süt", child: Text("Süt")),
        const PopupMenuItem(value: "Yumurta", child: Text("Yumurta")),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(20)),
        child: const Text("Alerjen +", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildAllergenChips() {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Wrap(
        spacing: 8,
        children: _excludedAllergens.map((a) => Chip(
          label: Text(a, style: const TextStyle(color: Colors.white, fontSize: 12)),
          backgroundColor: Colors.redAccent,
          onDeleted: () => setState(() => _excludedAllergens.remove(a)),
          deleteIconColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        )).toList(),
      ),
    );
  }
}
class MealDetailScreen extends StatelessWidget {
  final Map<String, dynamic> meal;
  const MealDetailScreen({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(meal['food_name'] ?? "Detay"), backgroundColor: Colors.teal),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _section("Yemeğin Hikayesi 📜", meal['story']),
            _besinDegerleri(),
            const SizedBox(height: 20),
            _section("Malzemeler 🛒", meal['materials']),
            _section("Hazırlanışı 👨‍🍳", meal['description']),
          ],
        ),
      ),
    );
  }

  Widget _besinDegerleri() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(15)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _macroCol("Protein", "${meal['protein_per_portion']}g"),
          _macroCol("Yağ", "${meal['fat_per_portion']}g"),
          _macroCol("Karb", "${meal['carbs_per_portion']}g"),
        ],
      ),
    );
  }

  Widget _macroCol(String l, String v) => Column(children: [Text(l), Text(v, style: const TextStyle(fontWeight: FontWeight.bold))]);

  Widget _section(String title, dynamic content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
          const SizedBox(height: 8),
          Text(content?.toString() ?? "Bilgi yok.", style: const TextStyle(fontSize: 16, height: 1.5)),
        ],
      ),
    );
  }
}