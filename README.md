VitaLife – AI Destekli Sağlıklı Yaşam ve Mobil Sağlık AsistanıVitaLife, kullanıcıların sağlıklı yaşam alışkanlıklarını optimize etmelerine yardımcı olmak amacıyla geliştirilmiş, üretken yapay zeka entegrasyonuna sahip, oyunlaştırılmış ve tam katmanlı (Full-Stack) bir mobil sağlık asistanı uygulamasıdır.Uygulama; modern Flutter mimarisiyle geliştirilmiş zengin bir ön yüz ile verileri işleyen, Gemini LLM entegrasyonunu yöneten ve güvenli veri yönetimini üstlenen Python Flask backend katmanından oluşur.🚀 Öne Çıkan Özellikler🧠 Gelişmiş Yapay Zeka Entegrasyonu (Generative AI)Gemini AI Destekli Sağlık Danışmanı: Kullanıcının fiziksel verilerine (yaş, boy, kilo, alerjenler) göre kişiselleştirilmiş bağlam sunan akıllı sohbet motoru.Dinamik Prompt Mimarisi: Arka planda kullanıcının güncel metriklerini okuyarak kişiye özel, motive edici ve güvenli yanıtlar üreten servis yapısı.📊 Detaylı Sağlık ve Metrik TakibiBiyometrik Veri Girişi: Boy, kilo, doğum tarihi ve alerjen parametrelerinin dinamik takibi.Vücut Kitle İndeksi (BMI): Kullanıcı verilerine göre otomatik indeksleme ve ideal form takibi.Profil Güncelleme: Dinamik sağlık durumuna göre backend üzerinde anlık güncellenen veri yapısı.🍽️ Akıllı Tarif ve Besin SistemiYöresel ve Sağlıklı Tarifler: Zengin yemek kütüphanesi ve porsiyon başına kalori analizi.Alerjen ve İçerik Filtreleme: Kullanıcının hassasiyetlerine göre alerjen içeren yemekleri otomatik eleyen filtreleme algoritması.🎮 Oyunlaştırma ve Etkileşim (Gamification)Ingredient Mini Game: Sağlıklı ve sağlıksız besin maddelerini ayırt etmeye dayalı, kullanıcı etkileşimini artıran refleks oyunu.Puan ve Kazanım Sistemi: Kullanıcı motivasyonunu artıran dinamik puanlama yapısı.🔐 Kimlik Doğrulama ve Güvenlik (Auth)Güvenli Kimlik Doğrulama: Werkzeug tabanlı tuzlanmış şifreleme (salted password hashing) ile güvenli kayıt ve giriş akışı.İlişkisel Veri Yönetimi: Kullanıcı profilleri ve tercihlerinin MySQL mimarisi üzerinde yönetimi.🛠️ Teknolojik AltyapıKatmanTeknolojiAçıklamaMobil Ön YüzFlutter & DartÇok platformlu, reaktif ve performanslı mobil kullanıcı deneyimiArka Yüz (Backend)Python 3 & FlaskRESTful API mimarisi, uç nokta yönetimi ve veri doğrulamaYapay ZekaGoogle GenAI SDKgemini-2.0-flash tabanlı kişiselleştirilmiş asistan entegrasyonuVeritabanıMySQL / phpMyAdminİlişkisel kullanıcı ve içerik veri tabanı yönetimiGüvenlikWerkzeug SecurityPBKDF2/SHA-256 tabanlı güvenli şifre hashleme protokolü📂 Proje Dizin YapısıPlaintextVitaLifeApp/
├── backend/
│   └── app.py                      # Python Flask REST API ve Gemini AI servisleri
├── vitalife_app1/                  # Flutter Mobil Uygulama Kök Dizini
│   ├── android/                    # Android yerel yapılandırmaları
│   ├── ios/                        # iOS yerel yapılandırmaları
│   ├── assets/                     # İkonlar ve görsel varlıklar
│   └── lib/                        # Dart kaynak kodları
│       ├── game/
│       │   └── ingredient_game_screen.dart   # Mini oyun motoru ve arayüzü
│       ├── screens/
│       │   ├── ai_chat_screen.dart           # Gemini AI sohbet arayüzü
│       │   ├── auth_screen.dart              # Giriş / Kayıt ekranı
│       │   ├── health_input_screen.dart      # Biyometrik veri giriş ekranı
│       │   └── home_screen.dart              # Ana kontrol paneli
│       └── services/
│           ├── api_service.dart              # REST API haberleşme katmanı
│           └── gemini_service.dart           # AI entegrasyon servisi
└── requirements.txt                # Python bağımlılıkları listesi
💻 Kurulum ve Çalıştırma Rehberi1️⃣ Depoyu KlonlayınBashgit clone https://github.com/asumangenc/VitaLifeApp.git
cd VitaLifeApp
2️⃣ Veritabanı Hazırlığı (MySQL)WampServer / XAMPP üzerinde MySQL servisini başlatın.phpMyAdmin arayüzüne girerek vitalife_db adında bir veritabanı oluşturun.users tablonuzu ilgili sütunlarla (first_name, last_name, email, password_hash, height, weight, birth_date, allergens) yapılandırın.3️⃣ Backend Servisini BaşlatınBash# Bağımlılıkları yükleyin
pip install flask flask-cors mysql-connector-python werkzeug google-genai

# Backend dizinine geçin ve sunucuyu başlatın
cd backend
python app.py
Backend servisi varsayılan olarak [http://127.0.0.1:5000](http://127.0.0.1:5000) portunda ayağa kalkacaktır.4️⃣ Flutter Mobil Uygulamasını BaşlatınAyrı bir terminal penceresi açarak:Bashcd vitalife_app1

# Paketleri yükleyin
flutter pub get

# Bağlı cihazları listeleyin
flutter devices

# Uygulamayı çalıştırın
flutter run
