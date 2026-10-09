Markdown
# VITALIFE – AI DESTEKLİ SAĞLIKLI YAŞAM VE MOBİL SAĞLIK ASİSTANI

VitaLife, kullanıcıların sağlıklı yaşam alışkanlıklarını optimize etmelerine yardımcı olmak amacıyla geliştirilmiş, üretken yapay zeka entegrasyonuna sahip, oyunlaştırılmış ve tam katmanlı (Full-Stack) bir mobil sağlık asistanı uygulamasıdır.

Uygulama, modern Flutter mimarisiyle geliştirilmiş bir ön yüz ile verileri işleyen, yapay zeka entegrasyonlarını ve veri yönetimini üstlenen güvenli bir Python backend katmanından oluşur. Kullanıcılar sağlık parametrelerini takip edebilir, Gemini tabanlı yapay zeka ile dinamik olarak sohbet edebilir ve oyunlaştırılmış mekanizmalarla sağlıklı beslenme alışkanlıkları kazanabilirler.

---

## 🚀 ÖNE ÇIKAN ÖZELLİKLER

### 🧠 YAPAY ZEKA ENTEGRASYONU (GENERATIVE AI)
* **Gemini AI Destekli Chatbot:** Beslenme, diyet, spor ve genel yaşam tarzı sorularını yanıtlayan akıllı asistan.
* **Kişiselleştirilmiş Sağlık Danışmanlığı:** Kullanıcının boy, kilo, yaş ve alerji verilerine göre özelleştirilmiş, bağlama duyarlı tavsiyeler.

### 📊 SAĞLIK VE METRİK TAKİBİ
* **Biyometrik Veri Girişi:** Boy, kilo, doğum tarihi ve alerjen parametrelerinin anlık takibi.
* **Vücut Kitle İndeksi (BMI):** Dinamik BMI hesaplama ve form analizi.
* **Sağlık Geçmişi Yönetimi:** Kullanıcının geçmiş ve güncel sağlık verilerinin saklanması ve güncellenmesi.

### 🍽️ TARİF VE BESİN YÖNETİM SİSTEMİ
* **Geniş Tarif Kütüphanesi:** Yöresel ve sağlıklı yemekleri içeren detaylı tarif arşivi.
* **Besin Değerleri Analizi:** Porsiyon başına kalori ve besin öğesi bilgileri.
* **Akıllı Alerjen Filtreleme:** Hassasiyeti olan kullanıcılar için alerjen ve içerik bazlı otomatik filtreleme.

### 🎮 OYUNLAŞTIRMA VE ETKİLEŞİM (GAMIFICATION)
* **Ingredient Mini Game:** Sağlıklı ve sağlıksız besinleri ayırt etmeye dayalı interaktif mini oyun.
* **Puan ve Görev Mekanizması:** Kullanıcı motivasyonunu artıran dinamik ödül ve puanlama sistemi.

### 🔐 KİMLİK DOĞRULAMA VE KULLANICI GÜVENLİĞİ
* **Özelleştirilmiş Auth Sistemi:** Güvenli kayıt olma (Register) ve giriş yapma (Login) süreçleri.
* **Şifrelenmiş Veri Güvenliği:** PBKDF2/SHA-256 tabanlı güvenli şifre hashleme protokolü.
* **İlişkisel Veri Mimarisi:** Kullanıcı verileri ve tercihlerinin MySQL üzerinde güvenli yönetimi.

---

## 🛠️ TEKNOLOJİK ALTYAPI

| Katman | Teknoloji | Açıklama |
|---|---|---|
| **Frontend** | Flutter & Dart | Çok platformlu mobil arayüz geliştirme |
| **Backend** | Python & Flask | RESTful API mimarisi ve servis yönetimi |
| **Yapay Zeka** | Google GenAI SDK | `gemini-2.0-flash` model entegrasyonu |
| **Veritabanı** | MySQL / phpMyAdmin | İlişkisel veri tabanı yönetimi |
| **Güvenlik** | Werkzeug Security | Tuzlanmış (salted) şifre hashleme |

---

## 📂 PROJE DİZİN YAPISI

```text
VitaLifeApp/
├── backend/
│   └── app.py                      # Flask REST API ve Gemini AI servisleri
├── vitalife_app1/                  # Flutter Mobil Uygulama Kök Dizini
│   ├── android/                    # Android yerel yapılandırma dosyaları
│   ├── ios/                        # iOS yerel yapılandırma dosyaları
│   ├── assets/                     # İkonlar ve görsel varlıklar
│   └── lib/                        # Dart kaynak kodları
│       ├── game/
│       │   └── ingredient_game_screen.dart   # Mini oyun motoru ve arayüzü
│       ├── screens/
│       │   ├── ai_chat_screen.dart           # Yapay zeka sohbet ekranı
│       │   ├── auth_screen.dart              # Giriş ve kayıt ekranı
│       │   ├── health_input_screen.dart      # Sağlık verisi giriş ekranı
│       │   └── home_screen.dart              # Ana kontrol paneli (Dashboard)
│       └── services/
│           ├── api_service.dart              # Backend REST API servis entegrasyonu
│           └── gemini_service.dart           # Gemini AI servis katmanı
└── requirements.txt                # Python backend kütüphane bağımlılıkları
💻 KURULUM VE ÇALIŞTIRMA
1️⃣ REPOYU KLONLAYIN
Bash
git clone [https://github.com/asumangenc/VitaLifeApp.git](https://github.com/asumangenc/VitaLifeApp.git)
cd VitaLifeApp
2️⃣ VERİTABANINI YAPILANDIRIN (MYSQL)
WampServer veya XAMPP üzerinden MySQL servisini başlatın.

phpMyAdmin panelinde vitalife_db isimli veritabanını açın.

users tablosunu ilgili alanlarla (first_name, last_name, email, password_hash, height, weight, birth_date, allergens) oluşturun.

3️⃣ BACKEND SERVİSİNİ BAŞLATIN
Bash
# Gerekli bağımlılıkları yükleyin
pip install flask flask-cors mysql-connector-python werkzeug google-genai

# Backend dizinine geçin ve servisi çalıştırın
cd backend
python app.py
4️⃣ FLUTTER UYGULAMASINI BAŞLATIN
Yeni bir terminal sekmesinde:

Bash
# Flutter proje dizinine geçin
cd vitalife_app1

# Paketleri yükleyin
flutter pub get

# Cihazları listeleyin
flutter devices

# Uygulamayı başlatın
flutter run
