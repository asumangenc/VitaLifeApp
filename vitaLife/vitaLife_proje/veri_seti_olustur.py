import pandas as pd
import numpy as np
from sklearn.feature_extraction.text import TfidfVectorizer

print("VitaLife Veri Seti Oluşturma Başlatılıyor...")
# ----------------------------------------------------------------------
# 1. VERİ TANIMLAMA (Mock Veri Kullanımı)
# ----------------------------------------------------------------------

# A. TÜRK MUTFAĞI TARİF VERİLERİ (Örnek/Mock)
# Gerçek projede bu veriler web scraping veya harici API'lerden çekilecektir.
tarif_veri = {
    'TarifID': [101, 102, 103, 104, 105, 106],
    'TarifAdı': ['Kırmızı Mercimek Çorbası', 'Zeytinyağlı Enginar', 'Kuru Fasulye', 'Etli Güveç', 'Ispanak Yemeği (Yoğurtlu)', 'Fırında Tavuk Sote'],
    'Malzemeler': [
        ['250g kırmızı mercimek', '1 soğan', '1 lt su', '50g tereyağı'],
        ['2 adet enginar', '100ml zeytinyağı', '1 havuç', '1 patates'],
        ['300g kuru fasulye', '1 soğan', '50g kıyma', '30g salça'],
        ['500g dana kuşbaşı', '2 adet domates', '1 patlıcan', '1 kaşık tereyağı'],
        ['500g ıspanak', '1 soğan', '200g yoğurt', '10g pirinç'],
        ['500g tavuk göğsü', '1 biber', '1 domates', '2 diş sarımsak']
    ],
    'Porsiyon_Sayısı': [4, 4, 6, 5, 4, 4]
}
df = pd.DataFrame(tarif_veri)

# B. BESİN DEĞERLERİ SÖZLÜĞÜ (100g/ml için)
# Bu sözlük, TURKOMP veya USDA gibi güvenilir kaynaklardan türetilmelidir.
BESIN_DEGERLERI = {
    "kırmızı mercimek": {"kalori": 352, "protein": 24.6, "yag": 1.1, "kolesterol": False},
    "soğan": {"kalori": 40, "protein": 1.1, "yag": 0.1, "kolesterol": False},
    "tereyağı": {"kalori": 717, "protein": 0.9, "yag": 81.1, "kolesterol": True}, # Hayvansal Yağ
    "enginar": {"kalori": 47, "protein": 3.3, "yag": 0.2, "kolesterol": False},
    "zeytinyağı": {"kalori": 884, "protein": 0, "yag": 100, "kolesterol": False},
    "kuru fasulye": {"kalori": 347, "protein": 21, "yag": 1.5, "kolesterol": False},
    "kıyma": {"kalori": 250, "protein": 26, "yag": 15, "kolesterol": True}, # Hayvansal Protein/Yağ
    "dana kuşbaşı": {"kalori": 200, "protein": 30, "yag": 8, "kolesterol": True}, # Hayvansal Protein/Yağ
    "tavuk göğsü": {"kalori": 165, "protein": 31, "yag": 3.6, "kolesterol": True}, # Hayvansal Protein/Yağ
    "ıspanak": {"kalori": 23, "protein": 2.9, "yag": 0.4, "kolesterol": False},
    "yoğurt": {"kalori": 61, "protein": 3.5, "yag": 3.3, "kolesterol": True}, # Süt Ürünü/Alerjen
    # ...Diğer malzemeler (su, salça, domates vb.) bu örnek için basit tutulmuştur.
}

# ----------------------------------------------------------------------
# 2. BESİN DEĞERİ HESAPLAMA (Örnek Basitleştirme)
# ----------------------------------------------------------------------

def porsiyon_degerleri_hesapla(malzemeler_list, porsiyon_sayisi):
    """Her tarif için toplam besin değerini hesaplar ve porsiyon bazına indirir."""
    toplam_kalori = 0
    toplam_protein = 0
    
    for malzeme_metni in malzemeler_list:
        # Basit ayrıştırma (Örn: '250g kırmızı mercimek' -> 250, 'g', 'kırmızı mercimek')
        try:
            miktar_str, ad = malzeme_metni.split(' ', 1)
            miktar = float(miktar_str.replace('g', '').replace('ml', '').replace('lt', '0')) # Ölçü birimini sadeleştirme
            
            # Besin değerlerini al
            if any(key in ad for key in BESIN_DEGERLERI):
                # Doğru malzemeyi bulmak için basit bir anahtar kelime eşleşmesi
                besin_key = next(key for key in BESIN_DEGERLERI if key in ad)
                degerler = BESIN_DEGERLERI[besin_key]
                
                # Toplam kalori ve protein hesaplama (100g bazından)
                toplam_kalori += (degerler["kalori"] / 100) * miktar
                toplam_protein += (degerler["protein"] / 100) * miktar
        except Exception as e:
            # print(f"Ayrıştırma hatası: {malzeme_metni} - {e}")
            continue
            
    # Porsiyon başına hesaplama
    if porsiyon_sayisi > 0:
        porsiyon_kalori = round(toplam_kalori / porsiyon_sayisi, 2)
        porsiyon_protein = round(toplam_protein / porsiyon_sayisi, 2)
    else:
        porsiyon_kalori, porsiyon_protein = 0, 0
        
    return porsiyon_kalori, porsiyon_protein

# DataFrame'e yeni sütunları ekleme
df['Kalori_Porsiyon'] = 0.0
df['Protein_Porsiyon'] = 0.0

for index, row in df.iterrows():
    kalori, protein = porsiyon_degerleri_hesapla(row['Malzemeler'], row['Porsiyon_Sayısı'])
    df.loc[index, 'Kalori_Porsiyon'] = kalori
    df.loc[index, 'Protein_Porsiyon'] = protein

# ----------------------------------------------------------------------
# 3. KURAL TABANLI ETİKETLEME (Kişiselleştirilmiş Beslenme İçin)
# ----------------------------------------------------------------------

def vegan_etiketle(malzemeler):
    """Vegan kuralı: Et, tavuk, balık, süt ürünü veya yumurta içeriyor mu?"""
    hayvansal_urunler = ["kıyma", "dana", "tavuk", "tereyağı", "yoğurt"]
    for malzeme in malzemeler:
        if any(urun in malzeme.lower() for urun in hayvansal_urunler):
            return 'Hayır'
    return 'Evet'

def kolesterol_etiketle(malzemeler):
    """Kolesterol riski: Kolesterol içeren malzemeler içeriyor mu?"""
    riskli_urunler = [k for k, v in BESIN_DEGERLERI.items() if v.get("kolesterol")]
    for malzeme in malzemeler:
        if any(urun in malzeme.lower() for urun in riskli_urunler):
            return 'Yüksek Risk'
    return 'Düşük Risk'

def dusuk_kalori_etiketle(kalori):
    """Kural: 300 kcal altı düşük kalorili kabul edilir."""
    return 'Evet' if kalori < 300 else 'Hayır'

# Etiketleme fonksiyonlarını DataFrame'e uygulama
df['Vegan'] = df['Malzemeler'].apply(vegan_etiketle)
df['Kolesterol_Durumu'] = df['Malzemeler'].apply(kolesterol_etiketle)
df['Düşük_Kalorili'] = df['Kalori_Porsiyon'].apply(dusuk_kalori_etiketle)

# ----------------------------------------------------------------------
# 4. İÇERİK TABANLI FİLTRELEME İÇİN HAZIRLIK (Yapay Zekâ)
# ----------------------------------------------------------------------

# Malzemeleri tek bir metin dizesine dönüştürerek metin içeriği sütunu oluşturma
df['Metin_Icerigi'] = df['Malzemeler'].apply(lambda x: ' '.join(x))

# TF-IDF Matrisi Oluşturma
# Bu matris, öneri sistemi için kullanılacak temel yapıdır.
tfidf = TfidfVectorizer(stop_words='english') 
tfidf_matrix = tfidf.fit_transform(df['Metin_Icerigi'])
print(f"\nTF-IDF Matrisi Oluşturuldu: {tfidf_matrix.shape}") # Matris boyutu (6 tarif, N farklı malzeme) 

# ----------------------------------------------------------------------
# 5. VERİ SETİNİ KAYDETME
# ----------------------------------------------------------------------

# Gereksiz sütunları temizleme ve son sütun sırasını belirleme
df_son = df[['TarifID', 'TarifAdı', 'Kalori_Porsiyon', 'Protein_Porsiyon', 
             'Vegan', 'Kolesterol_Durumu', 'Düşük_Kalorili', 'Metin_Icerigi']]

# Veri setini CSV olarak kaydetme
csv_dosya_adi = 'VitaLife_Tarif_Dataset.csv'
df_son.to_csv(csv_dosya_adi, index=False, encoding='utf-8')

print("\n---------------------------------------------------------")
print(f"✅ Başarılı! Veri seti oluşturuldu ve kaydedildi: {csv_dosya_adi}")
print("İlk 5 Kayıt:")
print(df_son.head())
print("---------------------------------------------------------")