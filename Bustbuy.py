from faker import Faker
import random
import string
from datetime import datetime, timedelta

# Initialize Faker with Indonesian locale
fake = Faker('id_ID')
domains = ['gmail.com', 'yahoo.com', 'hotmail.com', 'outlook.com', 'aol.com', 'mail.com', 'protonmail.com']

# Function to generate phone number in format +62-XXX-XXX-XXX
def generate_phone_number():
    digits = fake.random_number(digits=9)
    return f"+62-{digits//1000000:03d}-{digits//1000%1000:03d}-{digits%1000:03d}"

# Function to generate password based on nama_panjang
def generate_password(nama, length=10):
    nama_base = ''.join(c for c in nama if c.isalnum()).lower()[:3]
    chars = string.ascii_letters + string.digits + "!@#$%^&*_-+"
    random_chars = ''.join(random.choice(chars) for _ in range(length - 3))
    return nama_base + random_chars

# Function to generate fake file path
def generate_file_path(prefix='uploads'):
    return f"{prefix}/{fake.uuid4()}.jpg"

# Function to generate random wishlist/keranjang name
def generate_list_name(prefix="List"):
    if random.choice([True, False]):
        return f"{prefix} {random.randint(1, 10)}"
    return None

# Lists to store generated data
pengguna_emails = []
pembeli_emails = []
penjual_emails = []
verified_penjual_emails = []
alamat_ids = []
produk_ids = []
produk_by_penjual = {}  # Dict: email_penjual -> list of no_produk
varian_skus = {}  # Dict: no_produk -> list of (sku, harga)
pesanan_ids = []
pesanan_penjual = {}  # Dict: no_pesanan -> email_penjual
wishlist_ids = []
keranjang_ids = []

# Open file to write output
with open('test.txt', 'w', encoding='utf-8') as f:
    # 1. Tabel pengguna (50 pengguna)
    jumlah_pengguna = 50
    count_pengguna = 0
    f.write("-- INSERT INTO pengguna\n")
    for _ in range(jumlah_pengguna):
        nama_depan = fake.first_name()
        nama_belakang = fake.last_name()
        nama_panjang = f"{nama_depan} {nama_belakang}"
        email = f"{nama_depan.lower()}{random.randint(1, 99)}@{random.choice(domains)}"
        while email in pengguna_emails:
            email = f"{nama_depan.lower()}{random.randint(1, 99)}@{random.choice(domains)}"
        pengguna_emails.append(email)
        kata_sandi = generate_password(nama_panjang)
        no_telp = generate_phone_number()
        tgl_lahir = fake.date_of_birth(minimum_age=15, maximum_age=80).strftime('%Y-%m-%d')
        
        # edit for specialization
        is_pembeli = random.choice([True, True, False])
        if is_pembeli :
            pembeli_emails.append(email)
            is_penjual = False
        else :
            penjual_emails.append(email)
            is_penjual = True

        foto_profil = None

        sql = """INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('%s', '%s', '%s', '%s', '%s', %s, %s, %s);\n"""
        values = (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, 'NULL', 'TRUE' if is_pembeli else 'FALSE', 'TRUE' if is_penjual else 'FALSE')
        f.write(sql % values)
        count_pengguna += 1
    f.write(f"-- Total pengguna: {count_pengguna}\n")

    # 2. Tabel alamat (100 alamat)
    jumlah_alamat = 100
    count_alamat = 0
    f.write("\n-- INSERT INTO alamat\n")
    for i in range(1, jumlah_alamat + 1):
        provinsi = fake.administrative_unit()
        kota = fake.city()
        jalan = fake.street_address()
        alamat_ids.append(i)

        sql = """INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (%s, '%s', '%s', '%s');\n"""
        values = (i, provinsi, kota, jalan)
        f.write(sql % values)
        count_alamat += 1
    f.write(f"-- Total alamat: {count_alamat}\n")

    # 3. Tabel pembeli (pengguna dengan is_pembeli = TRUE)
    count_pembeli = 0
    f.write("\n-- INSERT INTO pembeli\n")
    for email in pembeli_emails:
        alamat_utama_id = random.choice(alamat_ids)

        sql = """INSERT INTO pembeli (email, alamat_utama_id)
                    VALUES ('%s', %s);\n"""
        values = (email, alamat_utama_id)
        f.write(sql % values)
        count_pembeli += 1

    f.write(f"-- Total pembeli: {count_pembeli}\n")

    # 4. Tabel penjual (pengguna dengan is_penjual = TRUE)
    count_penjual = 0
    f.write("\n-- INSERT INTO penjual\n")
    for email in penjual_emails:
        foto_ktp = generate_file_path('ktp')
        foto_diri = generate_file_path('selfie')
        is_verified = random.choice([True, False])
        if is_verified:
            verified_penjual_emails.append(email)
            produk_by_penjual[email] = []

        sql = """INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                    VALUES ('%s', '%s', '%s', %s);\n"""
        values = (email, foto_ktp, foto_diri, 'TRUE' if is_verified else 'FALSE')
        f.write(sql % values)
        count_penjual += 1
    f.write(f"-- Total penjual: {count_penjual}, terverifikasi: {len(verified_penjual_emails)}\n")

    # 5. Tabel friend (100 relasi follow)
    jumlah_friend = 100
    count_friend = 0
    used_friend_pairs = set()
    f.write("\n-- INSERT INTO friend\n")
    for _ in range(jumlah_friend):
        while True:
            email = random.choice(pengguna_emails)
            email_following = random.choice(pengguna_emails)
            if email != email_following and (email, email_following) not in used_friend_pairs:
                used_friend_pairs.add((email, email_following))
                break

        sql = """INSERT INTO friend (email, email_following)
                 VALUES ('%s', '%s');\n"""
        values = (email, email_following)
        f.write(sql % values)
        count_friend += 1
    f.write(f"-- Total friend: {count_friend}\n")

    # 6. Tabel alamat_alternatif (50 alamat alternatif)
    jumlah_alamat_alternatif = 50
    count_alamat_alternatif = 0
    used_alamat_pairs = set()
    f.write("\n-- INSERT INTO alamat_alternatif\n")
    for _ in range(jumlah_alamat_alternatif):
        while True:
            email = random.choice(pembeli_emails)
            alamat_id = random.choice(alamat_ids)
            if (email, alamat_id) not in used_alamat_pairs:
                used_alamat_pairs.add((email, alamat_id))
                break

        sql = """INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('%s', %s);\n"""
        values = (email, alamat_id)
        f.write(sql % values)
        count_alamat_alternatif += 1
    f.write(f"-- Total alamat_alternatif: {count_alamat_alternatif}\n")

    # 7. Tabel produk (200 produk, distribusi merata ke penjual terverifikasi)
    jumlah_produk = 200
    count_produk = 0
    produk_nama = ['Kaos Polos', 'Jaket Hoodie', 'Celana Jeans', 'Sepatu Sneakers', 'Tas Ransel', 'Kemeja Formal', 'Dress Midi', 'Topi Baseball']
    deskripsi = ['Produk berkualitas tinggi', 'Nyaman dipakai', 'Desain modern', 'Tahan lama']
    f.write("\n-- INSERT INTO produk\n")
    if verified_penjual_emails:
        produk_per_penjual = max(5, jumlah_produk // len(verified_penjual_emails))  # Minimal 5 produk
        produk_index = 1
        for email_penjual in verified_penjual_emails:
            num_produk = min(produk_per_penjual, jumlah_produk - count_produk)
            for _ in range(num_produk):
                if produk_index > jumlah_produk:
                    break
                nama_produk = f"{random.choice(produk_nama)} {fake.word().capitalize()}"
                deskripsi_produk = random.choice(deskripsi)
                produk_ids.append(produk_index)
                produk_by_penjual[email_penjual].append(produk_index)

                sql = """INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (%s, '%s', '%s', '%s');\n"""
                values = (produk_index, nama_produk, deskripsi_produk, email_penjual)
                f.write(sql % values)
                count_produk += 1
                produk_index += 1
            if produk_index > jumlah_produk:
                break
    else:
        f.write("-- Tidak ada penjual terverifikasi untuk produk\n")
    f.write(f"-- Total produk: {count_produk}\n")

    # 8. Tabel gambar_produk (1-3 gambar per produk)
    count_gambar_produk = 0
    f.write("\n-- INSERT INTO gambar_produk\n")
    used_gambar_pairs = set()
    for no_produk in produk_ids:
        num_gambar = random.randint(1, 3)
        for _ in range(num_gambar):
            gambar = generate_file_path('produk')
            if (no_produk, gambar) not in used_gambar_pairs:
                used_gambar_pairs.add((no_produk, gambar))
                sql = """INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (%s, '%s');\n"""
                values = (no_produk, gambar)
                f.write(sql % values)
                count_gambar_produk += 1
    f.write(f"-- Total gambar_produk: {count_gambar_produk}\n")

    # 9. Tabel tag_produk (1-3 tag per produk)
    tags = ['Fashion', 'Casual', 'Formal', 'Sport', 'Aksesoris', 'Pria', 'Wanita']
    count_tag_produk = 0
    f.write("\n-- INSERT INTO tag_produk\n")
    used_tag_pairs = set()
    for no_produk in produk_ids:
        num_tags = random.randint(1, 3)
        selected_tags = random.sample(tags, num_tags)
        for tag in selected_tags:
            if (no_produk, tag) not in used_tag_pairs:
                used_tag_pairs.add((no_produk, tag))
                sql = """INSERT INTO tag_produk (no_produk, tag)
                         VALUES (%s, '%s');\n"""
                values = (no_produk, tag)
                f.write(sql % values)
                count_tag_produk += 1
    f.write(f"-- Total tag_produk: {count_tag_produk}\n")

    # 10. Tabel varian (2-5 varian per produk)
    warna = ['BLACK', 'BLUE', 'RED', 'WHITE', 'NAVY', 'GREEN', 'GREY']
    ukuran = ['S', 'M', 'L', '28', '30', '32']
    count_varian = 0
    f.write("\n-- INSERT INTO varian\n")
    for no_produk in produk_ids:
        num_varian = random.randint(2, 5)
        varian_skus[no_produk] = []
        used_sku = set()
        for _ in range(num_varian):
            warna_choice = random.choice(warna)
            if random.choice([True, False]):
                ukuran_choice = random.choice(ukuran)
                sku = f"{no_produk}-{warna_choice}-{ukuran_choice}"
            else:
                sku = f"{no_produk}-{warna_choice}"
            if sku not in used_sku:
                used_sku.add(sku)
                nama_varian = f"Warna: {warna_choice}" + (f", Ukuran: {ukuran_choice}" if 'ukuran_choice' in locals() else "")
                stok = random.randint(0, 100)
                harga = round(random.uniform(50000, 1000000), 2)
                varian_skus[no_produk].append((sku, harga))

                sql = """INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (%s, '%s', '%s', %s, %s);\n"""
                values = (no_produk, sku, nama_varian, stok, harga)
                f.write(sql % values)
                count_varian += 1
    f.write(f"-- Total varian: {count_varian}\n")

    # 11. Tabel pesanan (100 pesanan)
    jumlah_pesanan = 100
    status_pesanan = ['Menunggu Pembayaran', 'Diproses', 'Dikirim', 'Selesai', 'Dibatalkan']
    metode_bayar = ['Transfer Bank', 'COD', 'E-Wallet', 'Kartu Kredit']
    metode_kirim = ['Kurir Standar', 'Same Day', 'Ambil di Tempat', 'Instant Courier']
    count_pesanan = 0
    f.write("\n-- INSERT INTO pesanan\n")
    for i in range(1, jumlah_pesanan + 1):
        status = random.choice(status_pesanan)
        harga_total = round(random.uniform(100000, 5000000), 2)
        metode_bayar_choice = random.choice(metode_bayar)
        catatan = fake.sentence() if random.choice([True, False]) else None
        waktu_pesan = (datetime.now() - timedelta(days=random.randint(1, 365))).strftime('%Y-%m-%d %H:%M:%S')
        metode_kirim_choice = random.choice(metode_kirim)
        email_pembeli = random.choice(pembeli_emails)
        alamat_id = random.choice(alamat_ids)
        penjual_with_produk = [email for email in verified_penjual_emails if produk_by_penjual[email]]
        if not penjual_with_produk:
            f.write(f"-- Tidak ada penjual dengan produk untuk pesanan {i}\n")
            continue
        email_penjual = random.choice(penjual_with_produk)
        pesanan_ids.append(i)
        pesanan_penjual[i] = email_penjual

        sql = """INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (%s, '%s', %s, '%s', %s, '%s', '%s', '%s', %s, '%s');\n"""
        values = (i, status, harga_total, metode_bayar_choice, f"'{catatan}'" if catatan else 'NULL', waktu_pesan, metode_kirim_choice, email_pembeli, alamat_id, email_penjual)
        f.write(sql % values)
        count_pesanan += 1
    f.write(f"-- Total pesanan: {count_pesanan}\n")

    # 12. Tabel rincian_pesanan (1-3 item per pesanan, sesuai penjual)
    count_rincian_pesanan = 0
    f.write("\n-- INSERT INTO rincian_pesanan\n")
    for no_pesanan in pesanan_ids:
        email_penjual = pesanan_penjual[no_pesanan]
        available_produk = produk_by_penjual.get(email_penjual, [])
        if not available_produk:
            f.write(f"-- Tidak ada produk untuk penjual {email_penjual} pada pesanan {no_pesanan}\n")
            continue
        num_items = random.randint(1, min(3, len(available_produk)))
        used_items = set()
        for _ in range(num_items):
            no_produk = random.choice(available_produk)
            if no_produk not in varian_skus or not varian_skus[no_produk]:
                f.write(f"-- Tidak ada varian untuk produk {no_produk} pada pesanan {no_pesanan}\n")
                continue
            sku, harga = random.choice(varian_skus[no_produk])
            jumlah = random.randint(1, 5)
            if (no_pesanan, no_produk, sku) not in used_items:
                used_items.add((no_pesanan, no_produk, sku))
                sql = """INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (%s, %s, '%s', %s);\n"""
                values = (no_pesanan, no_produk, sku, jumlah)
                f.write(sql % values)
                count_rincian_pesanan += 1
    f.write(f"-- Total rincian_pesanan: {count_rincian_pesanan}\n")

    # 13. Tabel ulasan (50 ulasan)
    jumlah_ulasan = 50
    count_ulasan = 0
    f.write("\n-- INSERT INTO ulasan\n")
    used_ulasan_pairs = set()
    for _ in range(jumlah_ulasan):
        while True:
            email_pembeli = random.choice(pembeli_emails)
            no_pesanan = random.choice(pesanan_ids)
            if (email_pembeli, no_pesanan) not in used_ulasan_pairs:
                used_ulasan_pairs.add((email_pembeli, no_pesanan))
                break
        konten = fake.paragraph() if random.choice([True, False]) else None
        nilai = round(random.uniform(0, 5), 1)

        sql = """INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('%s', %s, %s, %s);\n"""
        values = (email_pembeli, no_pesanan, f"'{konten}'" if konten else 'NULL', nilai)
        f.write(sql % values)
        count_ulasan += 1
    f.write(f"-- Total ulasan: {count_ulasan}\n")

    # 14. Tabel wishlist (1-3 per pembeli, dengan nama_wishlist)
    count_wishlist = 0
    wishlist_id_counter = 1
    f.write("\n-- INSERT INTO wishlist\n")
    for email in pembeli_emails:
        num_wishlists = random.randint(1, 3)  # 1-3 wishlist per pembeli
        for _ in range(num_wishlists):
            wishlist_ids.append(wishlist_id_counter)
            nama_wishlist = generate_list_name("Wishlist")
            sql = """INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (%s, '%s', %s);\n"""
            values = (wishlist_id_counter, email, f"'{nama_wishlist}'" if nama_wishlist else 'NULL')
            f.write(sql % values)
            count_wishlist += 1
            wishlist_id_counter += 1
    f.write(f"-- Total wishlist: {count_wishlist}\n")

    # 15. Tabel keranjang (1-3 per pembeli, dengan nama_keranjang)
    count_keranjang = 0
    keranjang_id_counter = 1
    f.write("\n-- INSERT INTO keranjang\n")
    for email in pembeli_emails:
        num_keranjang = random.randint(1, 3)  # 1-3 keranjang per pembeli
        for _ in range(num_keranjang):
            keranjang_ids.append(keranjang_id_counter)
            nama_keranjang = generate_list_name("Keranjang")
            sql = """INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (%s, '%s', %s);\n"""
            values = (keranjang_id_counter, email, f"'{nama_keranjang}'" if nama_keranjang else 'NULL')
            f.write(sql % values)
            count_keranjang += 1
            keranjang_id_counter += 1
    f.write(f"-- Total keranjang: {count_keranjang}\n")

    # 16. Tabel rincian_wishlist (1-5 produk per wishlist)
    count_rincian_wishlist = 0
    f.write("\n-- INSERT INTO rincian_wishlist\n")
    for wishlist_id in wishlist_ids:
        num_produk = random.randint(1, 5)
        used_produk = set()
        for _ in range(num_produk):
            no_produk = random.choice(produk_ids)
            if (wishlist_id, no_produk) not in used_produk:
                used_produk.add((wishlist_id, no_produk))
                sql = """INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (%s, %s);\n"""
                values = (wishlist_id, no_produk)
                f.write(sql % values)
                count_rincian_wishlist += 1
    f.write(f"-- Total rincian_wishlist: {count_rincian_wishlist}\n")

    # 17. Tabel rincian_keranjang (1-3 varian per keranjang, dengan jumlah)
    count_rincian_keranjang = 0
    f.write("\n-- INSERT INTO rincian_keranjang\n")
    for keranjang_id in keranjang_ids:
        num_varian = random.randint(1, 3)
        used_varian = set()
        for _ in range(num_varian):
            no_produk = random.choice(produk_ids)
            if no_produk not in varian_skus or not varian_skus[no_produk]:
                continue
            sku, _ = random.choice(varian_skus[no_produk])
            jumlah = random.randint(1, 5)  # jumlah > 0 sesuai CHECK
            if (keranjang_id, no_produk, sku) not in used_varian:
                used_varian.add((keranjang_id, no_produk, sku))
                sql = """INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (%s, %s, '%s', %s);\n"""
                values = (keranjang_id, no_produk, sku, jumlah)
                f.write(sql % values)
                count_rincian_keranjang += 1
    f.write(f"-- Total rincian_keranjang: {count_rincian_keranjang}\n")