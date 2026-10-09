import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  // 1. API KEY KONTROLÜ: Key'inin başında veya sonunda boşluk kalmadığından emin ol.
  static const String _apiKey = "AIzaSyArfZ1MaoNRYjX85qokteYew1Gjdmc16ew";

  Future<String> getAdvice({
    required String ad,
    required double kilo,
    required double boy,
    required String alerjiler,
    required String soru,
  }) async {
    try {
      // 2. MODEL SEÇİMİ: 'gemini-pro' bazen kütüphane sürümüne göre 'models/gemini-pro' ister.
      // Eğer hata alırsan 'gemini-1.5-flash' denemek en sağlıklısıdır.
      final model = GenerativeModel(
        model: 'gemini-1.5-flash', // 'gemini-pro' yerine bunu öneririm, daha günceldir.
        apiKey: _apiKey,
      );

      final prompt = """
        Sen VitaLife uygulamasının uzman diyetisyen asistanısın.
        Kullanıcı Bilgileri:
        - İsim: $ad
        - Boy: $boy cm
        - Kilo: $kilo kg
        - Alerjiler: $alerjiler
        
        Kullanıcının Sorusu: $soru
        
        Lütfen kullanıcının vücut bilgilerini ve alerjilerini dikkate alarak motive edici, kısa ve öz bir cevap ver. 
        Tıbbi bir teşhis koyma, sadece sağlıklı yaşam önerisi sun.
      """;

      // 3. İÇERİK OLUŞTURMA:
      final content = [Content.text(prompt)];

      // 4. CEVAP BEKLEME:
      final response = await model.generateContent(content);

      if (response.text != null) {
        return response.text!;
      } else {
        return "Üzgünüm, şu an uygun bir yanıt oluşturamadım.";
      }
    } catch (e) {
      // Konsolda hatanın ne olduğunu görmek için:
      print("--- GEMINI SERVIS HATASI ---");
      print(e);
      return "Bağlantı hatası: Gemini şu an cevap veremiyor.";
    }
  }
}