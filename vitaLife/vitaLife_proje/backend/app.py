from flask import Flask, request, jsonify
from flask_cors import CORS
import mysql.connector
from werkzeug.security import generate_password_hash, check_password_hash
from google import genai
from datetime import date

# 1. UYGULAMA AYARLARI
app = Flask(__name__)
CORS(app)

# 2. GEMINI AI AYARI
import os
client = genai.Client(api_key=os.environ.get("GEMINI_API_KEY", "YOUR_GEMINI_API_KEY_HERE"))

# 3. VERİTABANI BAĞLANTISI
def get_db():
    try:
        conn = mysql.connector.connect(
            host="127.0.0.1",
            user="root",
            password="",
            database="vitalife_db",
            port=3309        )
        if conn.is_connected():
            return conn
    except Exception as e:
        print(f">>> Veritabanı Bağlantı Hatası: {e}")
        return None

def calculate_age(birth_date):
    if not birth_date: return "Bilinmiyor"
    today = date.today()
    return today.year - birth_date.year - ((today.month, today.day) < (birth_date.month, birth_date.day))

# --- API ROTALARI ---

@app.route('/api/chat', methods=['POST'])
def chat():
    try:
        data = request.json
        user_info = data.get('user_info', {})

        # Veritabanı sütun isimlerine göre çekiyoruz
        isim = f"{user_info.get('first_name', '')} {user_info.get('last_name', '')}"
        boy = user_info.get('height', 'Bilinmiyor')
        kilo = user_info.get('weight', 'Bilinmiyor')
        alerji = user_info.get('allergens', 'Yok')

        # Yaş hesaplama
        b_date = user_info.get('birth_date')
        yas = calculate_age(b_date) if b_date else "Bilinmiyor"

        system_instruction = (
            f"Sen VitaLife sağlık asistanısın. Kullanıcı: {isim}, {yas} yaşında, {boy}cm, {kilo}kg. "
            f"Alerjiler: {alerji}. Kısa, öz ve motive edici cevaplar ver."
        )

        response = client.models.generate_content(
            model="gemini-3-flash-preview",
            contents=f"{system_instruction}\n\nKullanıcı Sorusu: {data.get('message', '')}"
        )

        return jsonify({"response": response.text if response else "Yanıt alınamadı."}), 200
    except Exception as e:
        return jsonify({"response": "Teknik bir sorun oluştu."}), 200

@app.route('/api/login', methods=['POST'])
def login():
    try:
        data = request.json
        conn = get_db()
        cur = conn.cursor(dictionary=True)

        # SQL şemana göre: password_hash sütununa bakıyoruz
        cur.execute("SELECT * FROM users WHERE email = %s", (data['email'],))
        user = cur.fetchone()
        cur.close(); conn.close()

        if user:
            # Şifre kontrolü: Veritabanındaki sütun adın 'password_hash'
            if check_password_hash(user['password_hash'], data['password']):
                user.pop('password_hash', None)
                # Tarih objesini JSON için stringe çevir
                if user.get('birth_date'):
                    user['birth_date'] = user['birth_date'].isoformat()
                return jsonify(user), 200

        return jsonify({"error": "Hatalı giriş"}), 401
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/register', methods=['POST'])
def register():
    data = request.json
    # Şifreyi güvenli şekilde hashliyoruz
    pw_hash = generate_password_hash(data['password'])

    conn = get_db()
    cur = conn.cursor()
    try:
        # SÜTUN İSİMLERİ: first_name, last_name, email, password_hash, height, weight, birth_date, allergens
        query = """INSERT INTO users
                   (first_name, last_name, email, password_hash, height, weight, birth_date, allergens)
                   VALUES (%s, %s, %s, %s, %s, %s, %s, %s)"""

        values = (
            data.get('first_name'),
            data.get('last_name'),
            data.get('email'),
            pw_hash,
            data.get('height'),
            data.get('weight'),
            data.get('birth_date'),
            data.get('allergens', 'Yok')
        )

        cur.execute(query, values)
        conn.commit()
        return jsonify({"status": "success"}), 201
    except Exception as e:
        print(f"Kayıt Hatası: {e}")
        return jsonify({"error": str(e)}), 400
    finally:
        cur.close(); conn.close()

@app.route('/api/update_user', methods=['POST'])
def update_user():
    try:
        data = request.json
        conn = get_db()
        cur = conn.cursor()
        # Profil sayfasından gelen güncellemeler için
        query = "UPDATE users SET weight=%s, height=%s, birth_date=%s WHERE email=%s"
        cur.execute(query, (data.get('weight'), data.get('height'), data.get('birth_date'), data.get('email')))
        conn.commit()
        cur.close(); conn.close()
        return jsonify({"status": "success"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/get_recipes', methods=['GET'])
def get_recipes():
    exclude = request.args.get('exclude', '')
    city = request.args.get('city', '')
    ingredient = request.args.get('ingredient', '')

    conn = get_db()
    cur = conn.cursor(dictionary=True)
    query = "SELECT id, food_name, calories_per_portion, allergens FROM meals WHERE 1=1"
    params = []

    if city:
        query += " AND city = %s"; params.append(city)
    if ingredient:
        query += " AND materials LIKE %s"; params.append(f"%{ingredient}%")
    if exclude and exclude != "null":
        for item in exclude.split(','):
            query += " AND allergens NOT LIKE %s AND materials NOT LIKE %s"
            params.append(f"%{item.strip()}%"); params.append(f"%{item.strip()}%")

    cur.execute(query, params)
    recipes = cur.fetchall()
    cur.close(); conn.close()
    return jsonify(recipes)

@app.route('/api/get_recipe_detail/<int:recipe_id>', methods=['GET'])
def get_recipe_detail(recipe_id):
    try:
        conn = get_db()
        cur = conn.cursor(dictionary=True)
        cur.execute("SELECT * FROM meals WHERE id = %s", (recipe_id,))
        recipe = cur.fetchone()
        cur.close(); conn.close()
        return jsonify(recipe) if recipe else (jsonify({"error": "Tarif yok"}), 404)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True, threaded=True)