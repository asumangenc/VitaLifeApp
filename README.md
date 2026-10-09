# 🌿 VitaLife – AI Destekli Sağlıklı Yaşam ve Mobil Sağlık Asistanı

VitaLife, kullanıcıların sağlıklı yaşam alışkanlıklarını optimize etmelerine yardımcı olmak amacıyla geliştirilmiş, yapay zeka entegrasyonuna sahip, oyunlaştırılmış ve tam katmanlı (Full-Stack) bir mobil sağlık asistanı uygulamasıdır. 

Uygulama, modern **Flutter** mimarisiyle geliştirilmiş bir ön yüz ile verileri işleyen, yapay zeha entegrasyonlarını ve veri yönetimini üstlenen güvenli bir **Python** backend katmanından oluşur. Kullanıcılar sağlık parametrelerini takip edebilir, Gemini tabanlı yapay zeka ile dinamik olarak sohbet edebilir ve oyunlaştırılmış mekanizmalarla sağlıklı beslenme alışkanlıkları kazanabilirler.

---

## 🚀 Öne Çıkan Özellikler

### 🧠 Gelişmiş Yapay Zeka Entegrasyonu (Generative AI)
* **Gemini AI Destekli Chatbot:** Kullanıcıların beslenme, diyet, spor ve genel yaşam tarzı sorularını yanıtlayan kişiselleştirilmiş asistan.
* **Akıllı Sağlık Danışmanlığı:** Kullanıcının fiziksel verilerine göre özelleştirilmiş, bağlama duyarlı sağlıklı yaşam ve beslenme tavsiyeleri.

### 📊 Detaylı Sağlık ve Metrik Takibi
* **Biyometrik Veri Girişi:** Boy, kilo, yaş ve aktivite düzeyi parametrelerinin dinamik takibi.
* **Vücut Kitle İndeksi (BMI) Hesaplama:** Gerçek zamanlı BMI hesaplaması ve ideal kilo kategorizasyonu.
* **Sağlık Geçmişi Analizi:** Kullanıcının geçmişe dönük sağlık verilerinin kaydedilmesi ve listelenmesi.

### 🍽️ Makro ve Mikro Besin Odaklı Tarif Sistemi
* **Geniş Veri Seti:** Yöresel ve sağlıklı yemekleri içeren detaylı tarif kütüphanesi.
* **Besin Değerleri Analizi:** Her tarif için kalori, protein, karbonhidrat ve yağ (makro besin) miktarlarının anlık gösterimi.
* **Alerjen ve Güvenlik Uyarıları:** Hassasiyeti olan kullanıcılar için içerik ve alerjen filtreleme mekanizmaları.

### 🎮 Oyunlaştırma ve Etkileşim (Gamification)
* **Malzeme Yakalama Mini Oyunu (Ingredient Game):** Sağlıklı ve sağlıksız besin maddelerini ayırt etmeye dayalı, kullanıcı katılımını artıran interaktif mini oyun.
* **Puan ve Görev Sistemi:** Günlük hedefleri tamamlayan ve oyunda başarı gösteren kullanıcılar için motivasyon artırıcı ödül yapısı.

### 🔐 Kimlik Doğrulama ve Kullanıcı Yönetimi
* **Özelleştirilmiş Auth Sistemi:** Güvenli Kayıt Olma (Register) ve Giriş Yapma (Login) süreçleri.
* **Merkezi Veri Yönetimi:** Kullanıcı profilleri, kişisel veriler, tercihler ve uygulama içi kazanımların MySQL mimarisi üzerinde güvenli entegrasyonu.

---

## 🛠️ Teknolojik Altyapı ve Mimari

### Ön Yüz (Frontend)
* **Framework:** Flutter (Dart)
* **Mimari Yaklaşım:** Clean Architecture prensiplerine uygun servis ve ekran ayrımı.
* **Veri İletişimi:** Asenkron HTTP istekleri ile güvenli REST API haberleşmesi.

### Arka Yüz (Backend) & Veritabanı
* **Programlama Dili:** Python 3.12+
* **Mimari Yapı:** RESTful API (Gelişmiş ve ölçeklenebilir backend modülleri)
* **Veritabanı (Database):** İlişkisel veri modeli yönetimi için **MySQL** altyapısı (Bulut mimarisi ve güvenli uzak veritabanı entegrasyonu).
* **Güvenlik Standartı:** Endüstri standartlarına uygun SSL/TLS şifreleme ve veri güvenliği protokolleri.

---

## 📂 Proje Dizin Yapısı

Projenin gerçek dosya ve klasör hiyerarşisi şu şekildedir:

```bash
vitalLifeGuncel/
└── vitaLife/
    └── vitaLife_proje/
        ├── backend/
        │   └── app.py                      # Python REST API ana backend dosyası
        ├── venv/                           # Python Sanal Ortam (Yerelde tutulur, repoya dahil edilmez)
        ├── vitalifeapp1/                   # Flutter Mobil Uygulama Kök Dizini
        │   ├── android/                    # Android Yerel Yapılandırma Dosyaları
        │   ├── assets/                     # Görseller, Yazı Tipleri ve Yerel Varlıklar
        │   ├── ios/                        # iOS Yerel Yapılandırma Dosyaları
        │   └── lib/                        # Dart Kaynak Kodları
        │       ├── game/
        │       │   └── ingredient_game_screen.dart  # Oyunlaştırma ekranı ve oyun motoru
        │       └── screens/
        │           ├── ai_chat_screen.dart          # Yapay zeka sohbet arayüzü
        │           ├── aichat.dart                  # Chat modülü bileşenleri
        │           ├── api_service.dart             # Backend REST API servis entegrasyonu
        │           ├── auth_screen.dart             # Giriş ve Kayıt Olma arayüzü
        │           ├── gemini_service.dart          # Gemini AI API entegrasyon katmanı
        │           ├── health_input_screen.dart     # Biyometrik sağlık veri giriş ekranı
        │           └── home_screen.dart             # Uygulama ana paneli (Dashboard)
        └── requirements.txt                # Python backend bağımlılıkları listesi
Projeyi yerel bilgisayarınızda ayağa kaldırmak için aşağıdaki adımları 
sırasıyla takip ediniz:

'''

## 1️⃣ Repoyu Klonla

```bash
git clone [https://github.com/Mervenuryalcinn/VitaLifeApp.git](https://github.com/Mervenuryalcinn/VitaLifeApp.git)
cd VitaLifeApp/vitaLife/vitaLife_proje

## 2️⃣ Arka Yüzü (Backend) Başlatın
Backend klasörüne giderek sanal ortamı aktifleştirin ve 
gerekli bağımlılıkları yükleyip servisi çalıştırın:
# Sanal ortamı aktifleştirin (Windows için)
```bash
venv\\Scripts\\activate

# macOS/Linux için: source venv/bin/activate
# Gerekli kütüphaneleri yükleyin (Eğer requirements.txt varsa)
pip install -r requirements.txt

# Backend uygulamasını başlatın
cd backend
python app.py

## 3️⃣ Ön Yüzü (Flutter Uygulaması) Çalıştırın
Yeni bir terminal sekmesinde mobil uygulama dizinine geçiş yapın,
bağımlılıkları çekin ve cihazınızda simüle edin:
```bash
# Flutter proje dizinine girin
cd vitalife_app1

# Paketleri ve bağımlılıkları güncelleyin
flutter pub get

# Bağlı cihazları listeleyin
flutter devices

# Uygulamayı hata ayıklama (Debug) modunda çalıştırın
flutter run

4️⃣ Uygulamayı Çalıştır
flutter run

# 🚀 Özellikler

## 🧠 Yapay Zeka Destekli Sohbet
- Gemini AI entegrasyonu
- Sağlıklı yaşam önerileri
- Beslenme tavsiyeleri
- Kullanıcı sorularına AI cevapları

## ❤️ Sağlık Takibi
- Boy / kilo bilgileri
- BMI hesaplama
- Günlük sağlık verileri
- Kullanıcı sağlık geçmişi

## 🍽️ Akıllı Tarif Sistemi
- Yöresel yemek veri seti
- Kalori bilgileri
- Protein / karbonhidrat / yağ değerleri
- Alerjen bilgileri

## 🎮 Oyunlaştırma Sistemi
- Ingredient mini game
- Puan sistemi
- Kullanıcı etkileşimini artıran görevler

## 🔐 Kimlik Doğrulama
- Login / Register sistemi
- Kullanıcı profili

---

# 🛠️ Kullanılan Teknolojiler

| Teknoloji | Açıklama |
|---|---|
| Flutter | Mobil uygulama geliştirme |
| Dart | Uygulama dili |
| Python | Backend işlemleri |
| Flask | API geliştirme |
| Gemini AI | Yapay zeka sistemi |
| SQLite / MySQL | Veritabanı |


