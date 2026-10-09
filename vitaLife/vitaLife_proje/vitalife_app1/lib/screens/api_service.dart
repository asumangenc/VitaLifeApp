import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // Emülatör kullanıyorsan: "http://10.0.2.2:5000/api"
  // Gerçek cihaz kullanıyorsan bilgisayarının IP'sini yaz:
  static const String baseUrl = "http://127.0.0.1:5000/api";

  // --- KAYIT OL ---
  static Future<bool> register(Map<String, dynamic> data) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 10));
      return res.statusCode == 201;
    } catch (e) {
      print("Register Hatası: $e");
      return false;
    }
  }

  // --- GİRİŞ YAP ---
  static Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      ).timeout(const Duration(seconds: 50));

      if (res.statusCode == 200) {
        return jsonDecode(utf8.decode(res.bodyBytes));
      }
      return null;
    } catch (e) {
      print("Login Hatası: $e");
      return null;
    }
  }

  // --- PROFİL GÜNCELLE ---
  static Future<bool> updateUser(Map<String, dynamic> data) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/update_user"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 10));
      return res.statusCode == 200;
    } catch (e) {
      print("Update Hatası: $e");
      return false;
    }
  }

  // --- TARİFLERİ ÇEK (FİLTRELEMELİ TEK FONKSİYON) ---
  // İsim çakışmasını önlemek için eski fetchRecipes fonksiyonunu sildik,
  // yerine bu kapsamlı olanı koyduk.
  static Future<List<dynamic>> fetchRecipes({
    String exclude = '',
    String city = '',
    String ingredient = '',
  }) async {
    try {
      // Dinamik URL oluşturma
      final String url = "$baseUrl/get_recipes?exclude=$exclude&city=$city&ingredient=$ingredient";
      print(">>> Tarif Listesi İsteği: $url");

      final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        return jsonDecode(utf8.decode(res.bodyBytes));
      }
      return [];
    } catch (e) {
      print("Fetch Hatası: $e");
      return [];
    }
  }

  // --- TARİF DETAYINI ÇEK ---
  static Future<Map<String, dynamic>?> fetchRecipeDetail(dynamic id) async {
    try {
      final String detailUrl = "$baseUrl/get_recipe_detail/${id.toString()}";
      print(">>> Detay İsteği Atılıyor: $detailUrl");

      final res = await http.get(
          Uri.parse(detailUrl)
      ).timeout(const Duration(seconds: 10));

      print(">>> Sunucu Yanıtı: ${res.statusCode}");

      if (res.statusCode == 200) {
        return jsonDecode(utf8.decode(res.bodyBytes));
      }
      return null;
    } catch (e) {
      print(">>> Detay çekme hatası (API): $e");
      return null;
    }
  }

  // --- AI CHAT (GEMINI) ---
  static Future<String> askGemini(String message, Map<String, dynamic>? userInfo) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "message": message,
          "user_info": userInfo ?? {}
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['response'] ?? "Asistan cevap veremedi.";
      }
      return "Sunucu hatası: ${response.statusCode}";
    } catch (e) {
      print("AI Bağlantı Hatası: $e");
      return "VitaLife asistanına şu an ulaşılamıyor.";
    }
  }
}