CREATE TABLE produk (
    no_produk VARCHAR(20) NOT NULL,
    nama_produk VARCHAR(100) NOT NULL,
    deskripsi TEXT,
    email_penjual VARCHAR(100) NOT NULL,
    PRIMARY KEY (no_produk),
    FOREIGN KEY (email_penjual) REFERENCES penjual(email)
);

CREATE TABLE gambar_produk (
    no_produk VARCHAR(20) NOT NULL,
    gambar MEDIUMBLOB NOT NULL,
    FOREIGN KEY (no_produk) REFERENCES produk(no_produk)
);

CREATE TABLE tag_produk (
    no_produk VARCHAR(20) NOT NULL,
    tag VARCHAR(50) NOT NULL,
    FOREIGN KEY (no_produk) REFERENCES produk(no_produk)
);

CREATE TABLE varian (
    no_produk VARCHAR(20) NOT NULL,
    sku VARCHAR(50) NOT NULL,
    nama_varian VARCHAR(100) NOT NULL,
    stok INT NOT NULL DEFAULT 0,
    harga DECIMAL(12, 2) NOT NULL,
    PRIMARY KEY (no_produk, sku),
    FOREIGN KEY (no_produk) REFERENCES produk(no_produk)
);

-- Insert data ke tabel Produk
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
VALUES (1, 'Kemeja Formal Pria', 'Kemeja formal untuk acara resmi dan kantor', 'bagas83@outlook.com');

INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
VALUES (2, 'Celana Chino', 'Celana casual yang nyaman untuk aktivitas sehari-hari', 'ratih65@outlook.com');

INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
VALUES (3, 'Sepatu Sneakers', 'Sepatu olahraga yang stylish dan nyaman', 'umi31@mail.com');

INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
VALUES (4, 'Tas Ransel', 'Tas multifungsi dengan kapasitas besar', 'jaka13@aol.com');

INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
VALUES (5, 'Jam Tangan Digital', 'Jam tangan dengan fitur lengkap dan tahan air', 'maman60@outlook.com');

INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
VALUES (6, 'Kacamata Fashion', 'Kacamata gaya dengan filter cahaya biru', 'prima36@mail.com');

INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
VALUES (7, 'Topi Baseball', 'Topi dengan desain modern untuk aktivitas outdoor', 'hasta35@yahoo.com');

INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
VALUES (8, 'Masker Kain', 'Masker kain dengan 3 lapisan yang dapat dicuci ulang', 'taswir29@hotmail.com');

INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
VALUES (9, 'Handphone Case', 'Pelindung handphone dengan desain premium', 'opan61@mail.com');

INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
VALUES (10, 'Kaos Polos', 'Kaos dengan bahan katun berkualitas tinggi', 'daruna6@mail.com');

-- Insert data ke tabel Gambar_Produk
INSERT INTO gambar_produk (no_produk, gambar)
VALUES (1, "/path/to/kemeja1.jpg");

INSERT INTO gambar_produk (no_produk, gambar)
VALUES (1, "/path/to/kemeja2.jpg");

INSERT INTO gambar_produk (no_produk, gambar)
VALUES (2, "/path/to/celana1.jpg");

INSERT INTO gambar_produk (no_produk, gambar)
VALUES (3, "/path/to/sepatu1.jpg");

INSERT INTO gambar_produk (no_produk, gambar)
VALUES (4, "/path/to/tas1.jpg");

INSERT INTO gambar_produk (no_produk, gambar)
VALUES (5, "/path/to/jam1.jpg");

INSERT INTO gambar_produk (no_produk, gambar)
VALUES (6, "/path/to/kacamata1.jpg");

INSERT INTO gambar_produk (no_produk, gambar)
VALUES (7, "/path/to/topi1.jpg");

INSERT INTO gambar_produk (no_produk, gambar)
VALUES (8, "/path/to/masker1.jpg");

INSERT INTO gambar_produk (no_produk, gambar)
VALUES (9, "/path/to/case1.jpg");

INSERT INTO gambar_produk (no_produk, gambar)
VALUES (10, "/path/to/kaos1.jpg");

-- Insert data ke tabel Tag_Produk
INSERT INTO tag_produk (no_produk, tag)
VALUES (1, 'Formal');

INSERT INTO tag_produk (no_produk, tag)
VALUES (1, 'Kemeja');

INSERT INTO tag_produk (no_produk, tag)
VALUES (1, 'Kantor');

INSERT INTO tag_produk (no_produk, tag)
VALUES (2, 'Casual');

INSERT INTO tag_produk (no_produk, tag)
VALUES (2, 'Celana');

INSERT INTO tag_produk (no_produk, tag)
VALUES (3, 'Sepatu');

INSERT INTO tag_produk (no_produk, tag)
VALUES (3, 'Olahraga');

INSERT INTO tag_produk (no_produk, tag)
VALUES (4, 'Tas');

INSERT INTO tag_produk (no_produk, tag)
VALUES (4, 'Travel');

INSERT INTO tag_produk (no_produk, tag)
VALUES (5, 'Jam');

INSERT INTO tag_produk (no_produk, tag)
VALUES (5, 'Aksesoris');

INSERT INTO tag_produk (no_produk, tag)
VALUES (6, 'Fashion');

INSERT INTO tag_produk (no_produk, tag)
VALUES (6, 'Kacamata');

INSERT INTO tag_produk (no_produk, tag)
VALUES (7, 'Outdoor');

INSERT INTO tag_produk (no_produk, tag)
VALUES (7, 'Topi');

INSERT INTO tag_produk (no_produk, tag)
VALUES (8, 'Kesehatan');

INSERT INTO tag_produk (no_produk, tag)
VALUES (8, 'Masker');

INSERT INTO tag_produk (no_produk, tag)
VALUES (9, 'Gadget');

INSERT INTO tag_produk (no_produk, tag)
VALUES (9, 'Aksesoris');

INSERT INTO tag_produk (no_produk, tag)
VALUES (10, 'Pakaian');

INSERT INTO tag_produk (no_produk, tag)
VALUES (10, 'Kaos');

-- Insert data ke tabel Varian
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
VALUES (1, '1-BLUE-S', 'Kemeja Biru Ukuran S', 10, 150000.00);

INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
VALUES (1, '1-BLUE-M', 'Kemeja Biru Ukuran M', 15, 150000.00);

INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
VALUES (1, '1-BLUE-L', 'Kemeja Biru Ukuran L', 12, 155000.00);

INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
VALUES (1, '1-WHITE-S', 'Kemeja Putih Ukuran S', 8, 150000.00);

INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
VALUES (1, '1-WHITE-M', 'Kemeja Putih Ukuran M', 20, 150000.00);

INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
VALUES (1, '1-WHITE-L', 'Kemeja Putih Ukuran L', 15, 155000.00);

INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
VALUES (2, '2-BLACK-28', 'Celana Chino Hitam Ukuran 28', 7, 200000.00);

INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
VALUES (2, '2-BLACK-30', 'Celana Chino Hitam Ukuran 30', 10, 200000.00);

INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
VALUES (2, '2-BLACK-32', 'Celana Chino Hitam Ukuran 32', 5, 200000.00);

INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
VALUES (2, '2-NAVY-28', 'Celana Chino Navy Ukuran 28', 8, 200000.00);

INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
VALUES (2, '2-NAVY-30', 'Celana Chino Navy Ukuran 30', 12, 200000.00);

INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
VALUES (2, '2-NAVY-32', 'Celana Chino Navy Ukuran 32', 6, 200000.00);

INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
VALUES (3, '3-BLACK-39', 'Sepatu Sneakers Hitam Ukuran 39', 5, 350000.00);

INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
VALUES (3, '3-BLACK-40', 'Sepatu Sneakers Hitam Ukuran 40', 8, 350000.00);

INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
VALUES (3, '3-BLACK-41', 'Sepatu Sneakers Hitam Ukuran 41', 7, 350000.00);

INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
VALUES (3, '3-WHITE-39', 'Sepatu Sneakers Putih Ukuran 39', 4, 350000.00);

INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
VALUES (3, '3-WHITE-40', 'Sepatu Sneakers Putih Ukuran 40', 10, 350000.00);

INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
VALUES (3, '3-WHITE-41', 'Sepatu Sneakers Putih Ukuran 41', 9, 350000.00);

INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
VALUES (4, '4-BLACK', 'Tas Ransel Hitam', 15, 225000.00);

INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
VALUES (4, '4-NAVY', 'Tas Ransel Navy', 12, 225000.00);

INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
VALUES (4, '4-RED', 'Tas Ransel Merah', 8, 225000.00);

INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
VALUES (5, '5-BLACK', 'Jam Tangan Digital Hitam', 20, 175000.00);

INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
VALUES (5, '5-SILVER', 'Jam Tangan Digital Silver', 18, 175000.00);

INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
VALUES (5, '5-GOLD', 'Jam Tangan Digital Gold', 10, 190000.00);

-- Query contoh: Mendapatkan semua produk beserta jumlah varian dan total stok
SELECT 
    p.no_produk,
    p.nama_produk,
    p.email_penjual,
    COUNT(v.sku) AS jumlah_varian,
    SUM(v.stok) AS total_stok
FROM 
    produk p
LEFT JOIN 
    varian v ON p.no_produk = v.no_produk
GROUP BY 
    p.no_produk, p.nama_produk, p.email_penjual;

-- Query contoh: Mendapatkan produk beserta tag-tagnya
SELECT 
    p.no_produk,
    p.nama_produk,
    GROUP_CONCAT(DISTINCT t.tag ORDER BY t.tag ASC SEPARATOR ', ') AS tags
FROM 
    produk p
LEFT JOIN 
    tag_produk t ON p.no_produk = t.no_produk
GROUP BY 
    p.no_produk, p.nama_produk;

-- Query contoh: Mendapatkan semua varian dari suatu produk
SELECT 
    v.no_produk,
    p.nama_produk,
    v.sku,
    v.nama_varian,
    v.stok,
    v.harga
FROM 
    varian v
JOIN 
    produk p ON v.no_produk = p.no_produk
WHERE 
    v.no_produk = 1
ORDER BY 
    v.nama_varian;

-- Query contoh: Mendapatkan produk dengan harga varian terendah dan tertinggi
SELECT 
    p.no_produk,
    p.nama_produk,
    MIN(v.harga) AS harga_terendah,
    MAX(v.harga) AS harga_tertinggi
FROM 
    produk p
JOIN 
    varian v ON p.no_produk = v.no_produk
GROUP BY 
    p.no_produk, p.nama_produk;

-- Query contoh: Mendapatkan produk dari penjual tertentu beserta detail variannya
SELECT 
    p.no_produk,
    p.nama_produk,
    p.deskripsi,
    v.sku,
    v.nama_varian,
    v.stok,
    v.harga
FROM 
    produk p
JOIN 
    varian v ON p.no_produk = v.no_produk
WHERE 
    p.email_penjual = 'bagas83@outlook.com'
ORDER BY 
    p.nama_produk, v.nama_varian;