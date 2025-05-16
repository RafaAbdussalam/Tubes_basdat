DROP DATABASE IF EXISTS bustbuydb;
DROP DATABASE IF EXISTS bustbuy_db;
CREATE DATABASE IF NOT EXISTS bustbuy_db;
USE bustbuy_db;

CREATE TABLE pengguna (
    email VARCHAR(50) NOT NULL,
    kata_sandi VARCHAR(255) NOT NULL,
    nama_panjang VARCHAR(100) NOT NULL,
    no_telp VARCHAR(20) NOT NULL,
    tgl_lahir DATE NOT NULL,
    foto_profil VARCHAR(255) DEFAULT NULL,
    is_pembeli BOOLEAN DEFAULT FALSE,
    is_penjual BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (email)
);

CREATE TABLE alamat (
    alamat_id INT NOT NULL AUTO_INCREMENT,
    provinsi VARCHAR(50) NOT NULL,
    kota VARCHAR(50) NOT NULL,
    jalan VARCHAR(50) NOT NULL,
    PRIMARY KEY (alamat_id)
);

CREATE TABLE friend (
    email VARCHAR(50) NOT NULL,
    email_following VARCHAR(50) NOT NULL,
    UNIQUE (email, email_following),
    FOREIGN KEY (email) REFERENCES pengguna(email),
    FOREIGN KEY (email_following) REFERENCES pengguna(email)
);

CREATE TABLE pembeli (
    email VARCHAR(50) NOT NULL,
    alamat_utama_id INT NOT NULL,
    PRIMARY KEY (email),
    FOREIGN KEY (email) REFERENCES pengguna(email) ON DELETE CASCADE,
    FOREIGN KEY (alamat_utama_id) REFERENCES alamat(alamat_id)
);

CREATE TABLE penjual (
    email VARCHAR(50) NOT NULL,
    foto_ktp VARCHAR(255) DEFAULT NULL,
    foto_diri VARCHAR(255) DEFAULT NULL,
    is_verified BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (email),
    FOREIGN KEY (email) REFERENCES pengguna(email) ON DELETE CASCADE
);

CREATE TABLE alamat_alternatif (
    email VARCHAR(50) NOT NULL,
    alamat_id INT NOT NULL,
    UNIQUE (email, alamat_id),
    FOREIGN KEY (email) REFERENCES pembeli(email), 
    FOREIGN KEY (alamat_id) REFERENCES alamat(alamat_id)  
);

CREATE TABLE pesanan (
    no_pesanan INT NOT NULL AUTO_INCREMENT,
    status_pesanan VARCHAR(50) NOT NULL,
    harga_total DECIMAL(15,2) NOT NULL,
    metode_bayar VARCHAR(50) NOT NULL,
    catatan VARCHAR(200) DEFAULT NULL,
    waktu_pesan DATETIME NOT NULL,
    metode_kirim VARCHAR(50) NOT NULL,
    email_pembeli VARCHAR(50) NOT NULL,
    alamat_id INT NOT NULL,
    email_penjual VARCHAR(50) NOT NULL,
    CHECK (status_pesanan IN ('Menunggu Pembayaran', 'Diproses', 'Dikirim', 'Selesai', 'Dibatalkan')),
    CHECK (metode_bayar IN ('Transfer Bank', 'COD', 'E-Wallet', 'Kartu Kredit')),
    CHECK (metode_kirim IN ('Kurir Standar', 'Same Day', 'Ambil di Tempat', 'Instant Courier')),
    PRIMARY KEY(no_pesanan), 
    FOREIGN KEY(email_pembeli) REFERENCES pembeli(email),
    FOREIGN KEY(alamat_id) REFERENCES alamat(alamat_id),
    FOREIGN KEY(email_penjual) REFERENCES penjual(email)
);

CREATE TABLE ulasan (
    email_pembeli VARCHAR(50) NOT NULL,
    no_pesanan INT NOT NULL,
    konten TEXT DEFAULT NULL,
    nilai DECIMAL(2,1) NOT NULL,
    CHECK (nilai BETWEEN 0 AND 5),
    PRIMARY KEY(email_pembeli, no_pesanan),
    FOREIGN KEY(email_pembeli) REFERENCES pembeli(email),
    FOREIGN KEY(no_pesanan) REFERENCES pesanan(no_pesanan)
);

CREATE TABLE produk (
    no_produk INT NOT NULL AUTO_INCREMENT,
    nama_produk VARCHAR(100) NOT NULL,
    deskripsi TEXT DEFAULT NULL,
    email_penjual VARCHAR(50) NOT NULL,
    PRIMARY KEY (no_produk),
    FOREIGN KEY (email_penjual) REFERENCES penjual(email)
);

CREATE TABLE gambar_produk (
    no_produk INT NOT NULL,
    gambar VARCHAR(255) NOT NULL,
    UNIQUE (no_produk, gambar),
    FOREIGN KEY (no_produk) REFERENCES produk(no_produk)
);

CREATE TABLE tag_produk (
    no_produk INT NOT NULL,
    tag VARCHAR(50) NOT NULL,
    UNIQUE (no_produk, tag),
    FOREIGN KEY (no_produk) REFERENCES produk(no_produk)
);

CREATE TABLE varian (
    no_produk INT NOT NULL,
    sku VARCHAR(50) NOT NULL,
    nama_varian VARCHAR(100) NOT NULL,
    stok INT NOT NULL DEFAULT 0,
    harga DECIMAL(12, 2) NOT NULL,
    CHECK (stok >= 0),
    CHECK (harga >= 0),
    PRIMARY KEY (no_produk, sku),
    FOREIGN KEY (no_produk) REFERENCES produk(no_produk)
);

CREATE TABLE rincian_pesanan (
    no_pesanan INT NOT NULL,
    no_produk INT NOT NULL,
    sku VARCHAR(50) NOT NULL,
    jumlah INT NOT NULL,
    PRIMARY KEY(no_pesanan, no_produk, sku),
    FOREIGN KEY(no_pesanan) REFERENCES pesanan(no_pesanan),
    FOREIGN KEY(no_produk, sku) REFERENCES varian(no_produk, sku)
);

CREATE TABLE wishlist (
    wishlist_id INT NOT NULL AUTO_INCREMENT,
    email_pembeli VARCHAR(100) NOT NULL UNIQUE,
    PRIMARY KEY (wishlist_id),
    FOREIGN KEY (email_pembeli) REFERENCES pembeli(email)
);

CREATE TABLE keranjang (
    keranjang_id INT NOT NULL AUTO_INCREMENT,
    email_pembeli VARCHAR(100) NOT NULL UNIQUE,
    PRIMARY KEY (keranjang_id),
    FOREIGN KEY (email_pembeli) REFERENCES pembeli(email)
);

CREATE TABLE rincian_wishlist (
    wishlist_id INT NOT NULL,
    no_produk INT NOT NULL,
    UNIQUE (wishlist_id, no_produk),
    FOREIGN KEY (wishlist_id) REFERENCES wishlist(wishlist_id),
    FOREIGN KEY (no_produk) REFERENCES produk(no_produk)
);

CREATE TABLE rincian_keranjang (
    keranjang_id INT NOT NULL,
    no_produk INT NOT NULL,
    sku VARCHAR(50) NOT NULL,
    UNIQUE (keranjang_id, no_produk, sku),
    FOREIGN KEY (keranjang_id) REFERENCES keranjang(keranjang_id),
    FOREIGN KEY (no_produk, sku) REFERENCES varian(no_produk, sku)
);

-- ======================== INDEXING ===============================
-- untuk meningkatkan performa

-- Tabel pengguna
CREATE INDEX idx_pengguna_is_pembeli ON pengguna(is_pembeli);
CREATE INDEX idx_pengguna_is_penjual ON pengguna(is_penjual);
-- Tabel friend
CREATE INDEX idx_friend_email_following ON friend(email_following);
-- Tabel pembeli dan penjual
CREATE INDEX idx_pembeli_alamat ON pembeli(alamat_utama_id);
CREATE INDEX idx_penjual_is_verified ON penjual(is_verified);
-- Tabel alamat_alternatif
CREATE INDEX idx_alternatif_alamat ON alamat_alternatif(alamat_id);
-- Tabel pesanan
CREATE INDEX idx_pesanan_email_pembeli ON pesanan(email_pembeli);
CREATE INDEX idx_pesanan_email_penjual ON pesanan(email_penjual);
CREATE INDEX idx_pesanan_alamat_id ON pesanan(alamat_id);
-- Tabel ulasan
CREATE INDEX idx_ulasan_nilai ON ulasan(nilai);
-- Tabel rincian_pesanan
CREATE INDEX idx_rincian_no_produk_sku ON rincian_pesanan(no_produk, sku);
-- Tabel produk
CREATE INDEX idx_produk_email_penjual ON produk(email_penjual);
-- Tabel gambar_produk
CREATE INDEX idx_gambar_produk ON gambar_produk(no_produk);
-- Tabel tag_produk
CREATE INDEX idx_tag_produk ON tag_produk(tag);
-- Tabel varian
CREATE INDEX idx_varian_stok ON varian(stok);
CREATE INDEX idx_varian_harga ON varian(harga);
-- Tabel wishlist
CREATE INDEX idx_wishlist_id ON wishlist(wishlist_id);
CREATE INDEX idx_rincian_wishlist ON rincian_wishlist(wishlist_id);
-- Tabel keranjang
CREATE INDEX idx_keranjang_id ON keranjang(keranjang_id);
CREATE INDEX idx_rincian_keranjang ON rincian_keranjang(keranjang_id);


-- ======================== VIEWS ===============================
-- VIEW: menampilkan umur
CREATE OR REPLACE VIEW pengguna_dengan_umur AS
SELECT
    email,
    kata_sandi,
    nama_panjang,
    no_telp,
    tgl_lahir,
    foto_profil,
    is_pembeli,
    is_penjual,
    TIMESTAMPDIFF(YEAR, tgl_lahir, CURDATE()) AS umur
FROM pengguna;


-- ======================== TRIGGERS ===============================

-- TRIGGER: memastikan specialization sesuai
DELIMITER //
CREATE TRIGGER trg_set_is_pembeli
    AFTER INSERT ON pembeli
    FOR EACH ROW
    BEGIN
        UPDATE pengguna SET is_pembeli = TRUE WHERE email = NEW.email;
    END;
//
DELIMITER ;
DELIMITER //
CREATE TRIGGER trg_unset_is_pembeli
    AFTER DELETE ON pembeli
    FOR EACH ROW
    BEGIN
        UPDATE pengguna SET is_pembeli = FALSE WHERE email = OLD.email;
    END;
//
DELIMITER ;
DELIMITER //
CREATE TRIGGER trg_set_is_penjual
    AFTER INSERT ON penjual
    FOR EACH ROW
    BEGIN
        UPDATE pengguna SET is_penjual = TRUE WHERE email = NEW.email;
    END;
//
DELIMITER ;
DELIMITER //
CREATE TRIGGER trg_unset_is_penjual
    AFTER DELETE ON penjual
    FOR EACH ROW
    BEGIN
        UPDATE pengguna SET is_penjual = FALSE WHERE email = OLD.email;
    END;
//
DELIMITER ;

-- TRIGGER: tidak boleh delete rincian pesanan terakhir kalau pesanan masihh ada
DELIMITER //
CREATE TRIGGER prevent_orphan_pesanan
BEFORE DELETE ON rincian_pesanan
FOR EACH ROW
BEGIN
    DECLARE cnt INT;

    -- Hitung berapa rincian yang masih tersisa untuk pesanan terkait
    SELECT COUNT(*) INTO cnt
    FROM rincian_pesanan
    WHERE no_pesanan = OLD.no_pesanan;

    -- Jika hanya ada satu, tolak penghapusan
    IF cnt = 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Tidak dapat menghapus rincian terakhir dari pesanan (melanggar total participation)';
    END IF;
END//
DELIMITER ;

-- TRIGGER: memastikan pesanan terdiri dari penjual yang sama
DELIMITER //
CREATE TRIGGER trg_check_penjual_consistency
BEFORE INSERT ON rincian_pesanan
FOR EACH ROW
BEGIN
    DECLARE penjual_pesanan VARCHAR(50);
    DECLARE penjual_varian VARCHAR(50);

    -- Ambil penjual dari tabel pesanan
    SELECT email_penjual INTO penjual_pesanan
    FROM pesanan
    WHERE no_pesanan = NEW.no_pesanan;

    -- Ambil penjual dari produk terkait varian
    SELECT p.email_penjual INTO penjual_varian
    FROM varian v
    JOIN produk p ON v.no_produk = p.no_produk
    WHERE v.no_produk = NEW.no_produk AND v.sku = NEW.sku;

    -- Bandingkan keduanya
    IF penjual_pesanan IS NULL OR penjual_varian IS NULL OR penjual_pesanan != penjual_varian THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Varian tidak berasal dari penjual yang sama dengan pesanan';
    END IF;
END;
//
DELIMITER ;

-- TRIGGER: memastikan bahwa insert produk hanya boleh dilakukan pada pengguna yang verified
DELIMITER //
CREATE TRIGGER verifikasi_penjual_trigger
BEFORE INSERT ON produk
FOR EACH ROW
BEGIN
    DECLARE verifikasi_status BOOLEAN;

    SELECT is_verified INTO verifikasi_status
    FROM penjual
    WHERE email = NEW.email_penjual;

    IF verifikasi_status IS NULL OR verifikasi_status = FALSE THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Penjual belum terverifikasi.';
    END IF;
END;
//
DELIMITER ;


-- ======================== INSERT DATA ===============================

-- PENGGUNA
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual) VALUES
('oskar64@aol.com', 'oskd3%4qJj', 'Oskar Pertiwi', '+62-527-118-537', '2003-06-29', NULL, True, False),
('argono11@aol.com', 'arg9-adbb_', 'Argono Nurdiyanti', '+62-015-017-362', '1973-01-29', NULL, True, True),
('jindra4@protonmail.com', 'jinm+Tzz7&', 'Jindra Hassanah', '+62-243-379-819', '2000-12-15', NULL, True, True),
('jane49@protonmail.com', 'jant$1%F@c', 'Jane Rahimah', '+62-259-350-649', '1974-06-21', NULL, False, True),
('dono72@gmail.com', 'donjmG^NuH', 'Dono Puspasari', '+62-793-255-250', '1984-10-02', NULL, False, True),
('tantri37@outlook.com', 'tan5h5HPpN', 'Tantri Wahyuni', '+62-130-508-252', '1982-09-23', NULL, True, True),
('rini38@outlook.com', 'rins^V^Iyw', 'Rini Hariyah', '+62-843-898-446', '1974-11-22', NULL, True, False),
('bakidin22@hotmail.com', 'bakXB%!Jr%', 'Bakidin Siregar', '+62-761-390-963', '1981-05-03', NULL, True, True),
('asirwada33@aol.com', 'asiACWE7wH', 'Asirwada Farida', '+62-723-744-422', '1957-12-09', NULL, True, False),
('jaiman22@mail.com', 'jaix8w-u7A', 'Jaiman Maheswara', '+62-454-467-458', '2009-07-02', NULL, True, True),
('ajiono27@mail.com', 'ajieyj7B_&', 'Ajiono Wijayanti', '+62-606-937-971', '1998-12-27', NULL, True, True),
('maria7@hotmail.com', 'marqye&zG0', 'Maria Prasasta', '+62-597-712-575', '1948-08-22', NULL, True, True),
('jarwi97@mail.com', 'jar--@@hVu', 'Jarwi Kusumo', '+62-457-350-036', '1986-06-22', NULL, True, True),
('adinata11@gmail.com', 'adit&63*9c', 'Adinata Simbolon', '+62-644-762-003', '1986-11-09', NULL, False, True),
('harimurti20@yahoo.com', 'har654LQX9', 'Harimurti Nashiruddin', '+62-458-455-391', '1977-11-07', NULL, True, True),
('luwes56@gmail.com', 'luwn7xh*zH', 'Luwes Winarno', '+62-060-938-860', '1999-03-17', NULL, False, True),
('halim35@protonmail.com', 'hal8ZNz0Py', 'Halim Pertiwi', '+62-539-194-413', '1973-04-01', NULL, True, False),
('unjani96@hotmail.com', 'unj6kvoc@Q', 'Unjani Yuniar', '+62-413-113-161', '2002-05-24', NULL, True, True),
('jagapati36@gmail.com', 'jagW*pQyQu', 'Jagapati Laksmiwati', '+62-508-905-549', '1999-05-09', NULL, True, True),
('anastasia68@outlook.com', 'anadAs!v8a', 'Anastasia Mahendra', '+62-988-870-238', '1983-07-15', NULL, False, True);

-- ALAMAT
INSERT INTO alamat (alamat_id, provinsi, kota, jalan) VALUES
(1,'Pennsylvania','Lake Retha','11192 Annette Run Apt. 066'),
(2,'Connecticut','Maximofort','112 Branson Lane Suite 535'),
(3,'Mississippi','Kuhicborough','253 Rodrick Fields Apt. 758'),
(4,'Nebraska','Lelandside','86680 Rocio Well'),
(5,'Montana','North Abigale','565 Wunsch Drives Suite 590'),
(6,'Wisconsin','Lake Boyd','603 Myrl Junction'),
(7,'Delaware','East Ramirofurt','545 Korey Ridge'),
(8,'Virginia','New Ramonmouth','06608 Harris Radial Suite 205'),
(9,'NewMexico','Aprilshire','955 Grady Expressway'),
(10,'Connecticut','South Harmonfurt','292 Meagan Spurs'),
(11,'Ohio','West Rebekastad','2074 Imogene Ways Suite 445'),
(12,'Florida','Cummerataland','2011 Klein Union'),
(13,'Maine','West Rogers','49790 Abigayle Lights'),
(14,'Massachusetts','Sherwoodtown','82666 Barton Lakes'),
(15,'Idaho','Shaniyaview','573 Brekke Mountains'),
(16,'Louisiana','Leuschkeside','718 Ressie Trail Apt. 762'),
(17,'NewJersey','Port Ofelia','321 Klein Prairie Apt. 884'),
(18,'NewHampshire','West Colin','61434 Botsford Loaf Suite 588'),
(19,'Alaska','Kyraburgh','47284 Estevan Island Apt. 832'),
(20,'NewYork','Skyemouth','963 Louvenia Fort'),
(21,'Florida','Elisabethfort','12455 Maxine Drives Suite 312'),
(22,'Hawaii','Lake Roelborough','70705 Howe Landing'),
(23,'Michigan','New Vena','1861 Dooley Skyway'),
(24,'NewHampshire','East Eric','91209 Zemlak Center Suite 711'),
(25,'Wisconsin','Port Billie','8226 Bennie Vista'),
(26,'Connecticut','Collierport','9435 Elmo Courts Suite 612'),
(27,'California','Sengertown','2858 Granville Extensions Suite 731'),
(28,'Mississippi','West Floydshire','557 Giovanna Lights Apt. 950'),
(29,'SouthCarolina','Sanfordport','8228 Wava Plain Apt. 864'),
(30,'NewHampshire','New Lexieshire','6917 Mireille Skyway Suite 383'),
(31,'Connecticut','South Sallyshire','6565 Richard Pine Suite 870'),
(32,'NewMexico','Port Davin','14931 Jarred Trafficway Apt. 908'),
(33,'NewMexico','Port Leora','9212 Erdman Summit'),
(34,'Alaska','Khalilberg','88271 Opal Burg Suite 272'),
(35,'Louisiana','South Tevin','351 Morar Light'),
(36,'Iowa','Mertzshire','71846 Landen Oval'),
(37,'Alaska','Dawsonfort','86543 Ramiro Cliff Apt. 278'),
(38,'Mississippi','North Danny','757 Willms Grove'),
(39,'Iowa','South Trudie','807 Jade Fork Suite 767'),
(40,'Wyoming','Lubowitzside','72495 Glover Courts Apt. 131'),
(41,'Nevada','Lake Yeseniaberg','791 Nicolas Alley Suite 860'),
(42,'Mississippi','East Noemiemouth','66379 Rempel Mount Apt. 929'),
(43,'Oklahoma','Lake Bernie','946 Norval Crossroad'),
(44,'NewHampshire','Breitenbergchester','757 Hyatt Cliff Suite 646'),
(45,'Mississippi','Jacobiborough','16084 Heidi Circle Apt. 391'),
(46,'Arkansas','North Lexi','01393 Murray Estates Suite 387'),
(47,'Massachusetts','Fadelchester','5856 Mayra Plains'),
(48,'District of Columbia','Janaeton','5561 Goyette Branch Suite 694'),
(49,'NewMexico','Jastton','949 Leuschke Orchard'),
(50,'Georgia','Ankundingfurt','3574 Desiree Mills');

-- PEMBELI
INSERT INTO pembeli (email, alamat_utama_id) VALUES
('oskar64@aol.com', 1),
('argono11@aol.com', 2),
('jindra4@protonmail.com', 3),
('tantri37@outlook.com', 6),
('rini38@outlook.com', 7),
('bakidin22@hotmail.com', 8),
('asirwada33@aol.com', 9),
('jaiman22@mail.com', 10),
('ajiono27@mail.com', 11),
('maria7@hotmail.com', 12),
('jarwi97@mail.com', 13),
('harimurti20@yahoo.com', 15),
('unjani96@hotmail.com', 17),
('jagapati36@gmail.com', 18),
('halim35@protonmail.com', 16);

-- PENJUAL
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified) VALUES
('argono11@aol.com', '/path/ktp/argono11.png', '/path/diri/argono11.png', TRUE),
('jindra4@protonmail.com', '/path/ktp/jindra4.png', '/path/diri/jindra4.png', TRUE),
('jane49@protonmail.com', '/path/ktp/jane49.png', '/path/diri/jane49.png', TRUE),
('dono72@gmail.com', '/path/ktp/dono72.png', '/path/diri/dono72.png', TRUE),
('tantri37@outlook.com', '/path/ktp/tantri37.png', '/path/diri/tantri37.png', TRUE),
('bakidin22@hotmail.com', '/path/ktp/bakidin22.png', '/path/diri/bakidin22.png', TRUE),
('jaiman22@mail.com', '/path/ktp/jaiman22.png', '/path/diri/jaiman22.png', TRUE),
('ajiono27@mail.com', '/path/ktp/ajiono27.png', '/path/diri/ajiono27.png', TRUE),
('maria7@hotmail.com', NULL, NULL, FALSE),
('jarwi97@mail.com', NULL, NULL, FALSE),
('adinata11@gmail.com', NULL, NULL, FALSE),
('harimurti20@yahoo.com', NULL, NULL, FALSE),
('luwes56@gmail.com', NULL, NULL, FALSE),
('unjani96@hotmail.com', NULL, NULL, FALSE),
('jagapati36@gmail.com', NULL, NULL, FALSE),
('anastasia68@outlook.com', NULL, NULL, FALSE);

-- PRODUK
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual) VALUES
(1, 'Kemeja Formal Pria', 'Kemeja formal untuk acara resmi dan kantor', 'argono11@aol.com'),
(2, 'Celana Chino', 'Celana casual yang nyaman untuk aktivitas sehari-hari', 'jindra4@protonmail.com'),
(3, 'Sepatu Sneakers', 'Sepatu olahraga yang stylish dan nyaman', 'jane49@protonmail.com'),
(4, 'Tas Ransel', 'Tas multifungsi dengan kapasitas besar', 'dono72@gmail.com'),
(5, 'Jam Tangan Digital', 'Jam tangan dengan fitur lengkap dan tahan air', 'tantri37@outlook.com'),
(6, 'Kacamata Fashion', 'Kacamata gaya dengan filter cahaya biru', 'bakidin22@hotmail.com'),
(7, 'Topi Baseball', 'Topi dengan desain modern untuk aktivitas outdoor', 'jaiman22@mail.com'),
(8, 'Masker Kain', 'Masker kain dengan 3 lapisan yang dapat dicuci ulang', 'ajiono27@mail.com'),
(9, 'Handphone Case', 'Pelindung handphone dengan desain premium', 'ajiono27@mail.com'),
(10, 'Kaos Polos', 'Kaos dengan bahan katun berkualitas tinggi', 'bakidin22@hotmail.com');

-- GAMBAR_PRODUK
INSERT INTO gambar_produk (no_produk, gambar) VALUES
(1, "/path/to/kemeja1.jpg"),
(1, "/path/to/kemeja2.jpg"),
(2, "/path/to/celana1.jpg"),
(3, "/path/to/sepatu1.jpg"),
(4, "/path/to/tas1.jpg"),
(5, "/path/to/jam1.jpg"),
(6, "/path/to/kacamata1.jpg"),
(7, "/path/to/topi1.jpg"),
(8, "/path/to/masker1.jpg"),
(9, "/path/to/case1.jpg"),
(10, "/path/to/kaos1.jpg");

-- TAG_PRODUK
INSERT INTO tag_produk (no_produk, tag) VALUES
(1, 'Formal'),
(1, 'Kemeja'),
(1, 'Kantor'),
(2, 'Casual'),
(2, 'Celana'),
(3, 'Sepatu'),
(3, 'Olahraga'),
(4, 'Tas'),
(4, 'Travel'),
(5, 'Jam'),
(5, 'Aksesoris'),
(6, 'Fashion'),
(6, 'Kacamata'),
(7, 'Outdoor'),
(7, 'Topi'),
(8, 'Kesehatan'),
(8, 'Masker'),
(9, 'Gadget'),
(9, 'Aksesoris'),
(10, 'Pakaian'),
(10, 'Kaos');

-- VARIAN
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga) VALUES
(1, '1-BLUE-S', 'Kemeja Biru Ukuran S', 10, 150000.00),
(1, '1-BLUE-M', 'Kemeja Biru Ukuran M', 15, 150000.00),
(1, '1-BLUE-L', 'Kemeja Biru Ukuran L', 12, 155000.00),
(1, '1-WHITE-S', 'Kemeja Putih Ukuran S', 8, 150000.00),
(1, '1-WHITE-M', 'Kemeja Putih Ukuran M', 20, 150000.00),
(1, '1-WHITE-L', 'Kemeja Putih Ukuran L', 15, 155000.00),
(2, '2-BLACK-28', 'Celana Chino Hitam Ukuran 28', 7, 200000.00),
(2, '2-BLACK-30', 'Celana Chino Hitam Ukuran 30', 10, 200000.00),
(2, '2-BLACK-32', 'Celana Chino Hitam Ukuran 32', 5, 200000.00),
(2, '2-NAVY-28', 'Celana Chino Navy Ukuran 28', 8, 200000.00),
(2, '2-NAVY-30', 'Celana Chino Navy Ukuran 30', 12, 200000.00),
(2, '2-NAVY-32', 'Celana Chino Navy Ukuran 32', 6, 200000.00),
(3, '3-BLACK-39', 'Sepatu Sneakers Hitam Ukuran 39', 5, 350000.00),
(3, '3-BLACK-40', 'Sepatu Sneakers Hitam Ukuran 40', 8, 350000.00),
(3, '3-BLACK-41', 'Sepatu Sneakers Hitam Ukuran 41', 7, 350000.00),
(3, '3-WHITE-39', 'Sepatu Sneakers Putih Ukuran 39', 4, 350000.00),
(3, '3-WHITE-40', 'Sepatu Sneakers Putih Ukuran 40', 10, 350000.00),
(3, '3-WHITE-41', 'Sepatu Sneakers Putih Ukuran 41', 9, 350000.00),
(4, '4-BLACK', 'Tas Ransel Hitam', 15, 225000.00),
(4, '4-NAVY', 'Tas Ransel Navy', 12, 225000.00),
(4, '4-RED', 'Tas Ransel Merah', 8, 225000.00),
(5, '5-BLACK', 'Jam Tangan Digital Hitam', 20, 175000.00),
(5, '5-SILVER', 'Jam Tangan Digital Silver', 18, 175000.00),
(5, '5-GOLD', 'Jam Tangan Digital Gold', 10, 190000.00);

-- WISHLIST
INSERT INTO wishlist (wishlist_id, email_pembeli) VALUES
(1, 'oskar64@aol.com'), 
(2, 'argono11@aol.com'), 
(3, 'jindra4@protonmail.com'), 
(4, 'tantri37@outlook.com'), 
(5, 'rini38@outlook.com'), 
(6, 'bakidin22@hotmail.com'), 
(7, 'asirwada33@aol.com'), 
(8, 'jaiman22@mail.com'), 
(9, 'ajiono27@mail.com'), 
(10, 'maria7@hotmail.com'), 
(11, 'jarwi97@mail.com'),
(12, 'harimurti20@yahoo.com'),
(13, 'unjani96@hotmail.com'),
(14, 'jagapati36@gmail.com'),
(15, 'halim35@protonmail.com');

-- KERANJANG
INSERT INTO keranjang (keranjang_id, email_pembeli) VALUES
(1, 'oskar64@aol.com'),
(2, 'argono11@aol.com'),
(3, 'jindra4@protonmail.com'),
(4, 'tantri37@outlook.com'),
(5, 'rini38@outlook.com'),
(6, 'bakidin22@hotmail.com'),
(7, 'asirwada33@aol.com'),
(8, 'jaiman22@mail.com'),
(9, 'ajiono27@mail.com'),
(10, 'maria7@hotmail.com'),
(11, 'jarwi97@mail.com'),
(12, 'harimurti20@yahoo.com'),
(13, 'unjani96@hotmail.com'),
(14, 'jagapati36@gmail.com'),
(15, 'halim35@protonmail.com');

-- RINCIAN_WISHLIST
INSERT INTO rincian_wishlist (wishlist_id, no_produk) VALUES
(1, 1),
(1, 2),
(2, 10),
(3, 7),
(4, 5),
(4, 9),
(4, 10),
(5, 8),
(5, 1),
(6, 2),
(6, 1),
(7, 10),
(8, 7),
(8, 5),
(8, 9),
(9, 4),
(9, 1),
(10, 6),
(10, 2),
(10, 8),
(11, 8),
(11, 3),
(12, 2),
(13, 7),
(14, 1),
(15, 5),
(15, 6);

-- RINCIAN_KERANJANG
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku) VALUES
(1, 2, '2-BLACK-28'),
(1, 1, '1-BLUE-S'),
(2, 1, '1-BLUE-M'),
(2, 2, '2-BLACK-28'),
(3, 4, '4-NAVY'),
(3, 2, '2-NAVY-30'),
(4, 4, '4-NAVY'),
(5, 3, '3-WHITE-41'),
(6, 2, '2-NAVY-30'),
(7, 3, '3-WHITE-41'),
(8, 1, '1-BLUE-M'),
(8, 2, '2-NAVY-30'),
(9, 2, '2-NAVY-30'),
(10, 4, '4-NAVY'),
(10, 2, '2-BLACK-28'),
(10, 3, '3-WHITE-41'),
(11, 2, '2-NAVY-30'),
(11, 5, '5-GOLD'),
(11, 1, '1-BLUE-L'),
(12, 1, '1-BLUE-M'),
(13, 2, '2-NAVY-30'),
(13, 4, '4-NAVY'),
(13, 1, '1-BLUE-L'),
(14, 1, '1-BLUE-L'),
(15, 4, '4-NAVY');


-- friend
INSERT INTO friend (email, email_following)
             VALUES ('unjani96@hotmail.com', 'halim35@protonmail.com')
INSERT INTO friend (email, email_following)
             VALUES ('anastasia68@outlook.com', 'adinata11@gmail.com')
INSERT INTO friend (email, email_following)
             VALUES ('anastasia68@outlook.com', 'jagapati36@gmail.com')
INSERT INTO friend (email, email_following)
             VALUES ('maria7@hotmail.com', 'jane49@protonmail.com')
INSERT INTO friend (email, email_following)
             VALUES ('jarwi97@mail.com', 'anastasia68@outlook.com')
INSERT INTO friend (email, email_following)
             VALUES ('harimurti20@yahoo.com', 'anastasia68@outlook.com')
INSERT INTO friend (email, email_following)
             VALUES ('luwes56@gmail.com', 'maria7@hotmail.com')
INSERT INTO friend (email, email_following)
             VALUES ('halim35@protonmail.com', 'argono11@aol.com')
INSERT INTO friend (email, email_following)
             VALUES ('halim35@protonmail.com', 'unjani96@hotmail.com')
INSERT INTO friend (email, email_following)
             VALUES ('dono72@gmail.com', 'jane49@protonmail.com')
INSERT INTO friend (email, email_following)
             VALUES ('jindra4@protonmail.com', 'jarwi97@mail.com')
INSERT INTO friend (email, email_following)
             VALUES ('bakidin22@hotmail.com', 'argono11@aol.com')
INSERT INTO friend (email, email_following)
             VALUES ('dono72@gmail.com', 'unjani96@hotmail.com')
INSERT INTO friend (email, email_following)
             VALUES ('oskar64@aol.com', 'ajiono27@mail.com')
INSERT INTO friend (email, email_following)
             VALUES ('maria7@hotmail.com', 'tantri37@outlook.com')
INSERT INTO friend (email, email_following)
             VALUES ('asirwada33@aol.com', 'anastasia68@outlook.com')
INSERT INTO friend (email, email_following)
             VALUES ('dono72@gmail.com', 'maria7@hotmail.com')
INSERT INTO friend (email, email_following)
             VALUES ('asirwada33@aol.com', 'maria7@hotmail.com')
INSERT INTO friend (email, email_following)
             VALUES ('bakidin22@hotmail.com', 'oskar64@aol.com')
INSERT INTO friend (email, email_following)
             VALUES ('ajiono27@mail.com', 'asirwada33@aol.com')
INSERT INTO friend (email, email_following)
             VALUES ('harimurti20@yahoo.com', 'bakidin22@hotmail.com')
INSERT INTO friend (email, email_following)
             VALUES ('jaiman22@mail.com', 'ajiono27@mail.com')
INSERT INTO friend (email, email_following)
             VALUES ('rini38@outlook.com', 'halim35@protonmail.com')
INSERT INTO friend (email, email_following)
             VALUES ('jane49@protonmail.com', 'oskar64@aol.com')
INSERT INTO friend (email, email_following)
             VALUES ('argono11@aol.com', 'jindra4@protonmail.com')
INSERT INTO friend (email, email_following)
             VALUES ('rini38@outlook.com', 'maria7@hotmail.com')
INSERT INTO friend (email, email_following)
             VALUES ('halim35@protonmail.com', 'tantri37@outlook.com')
INSERT INTO friend (email, email_following)
             VALUES ('dono72@gmail.com', 'adinata11@gmail.com')
INSERT INTO friend (email, email_following)
             VALUES ('jagapati36@gmail.com', 'luwes56@gmail.com')
INSERT INTO friend (email, email_following)
             VALUES ('argono11@aol.com', 'oskar64@aol.com')
INSERT INTO friend (email, email_following)
             VALUES ('oskar64@aol.com', 'asirwada33@aol.com')
INSERT INTO friend (email, email_following)
             VALUES ('jaiman22@mail.com', 'bakidin22@hotmail.com')
INSERT INTO friend (email, email_following)
             VALUES ('rini38@outlook.com', 'harimurti20@yahoo.com')
INSERT INTO friend (email, email_following)
             VALUES ('maria7@hotmail.com', 'ajiono27@mail.com')
INSERT INTO friend (email, email_following)
             VALUES ('dono72@gmail.com', 'bakidin22@hotmail.com')
INSERT INTO friend (email, email_following)
             VALUES ('jaiman22@mail.com', 'anastasia68@outlook.com')
INSERT INTO friend (email, email_following)
             VALUES ('jagapati36@gmail.com', 'halim35@protonmail.com')
INSERT INTO friend (email, email_following)
             VALUES ('jindra4@protonmail.com', 'asirwada33@aol.com')
INSERT INTO friend (email, email_following)
             VALUES ('argono11@aol.com', 'jarwi97@mail.com')
INSERT INTO friend (email, email_following)
             VALUES ('tantri37@outlook.com', 'jarwi97@mail.com')
INSERT INTO friend (email, email_following)
             VALUES ('bakidin22@hotmail.com', 'unjani96@hotmail.com')
INSERT INTO friend (email, email_following)
             VALUES ('asirwada33@aol.com', 'ajiono27@mail.com')
INSERT INTO friend (email, email_following)
             VALUES ('anastasia68@outlook.com', 'harimurti20@yahoo.com')
INSERT INTO friend (email, email_following)
             VALUES ('adinata11@gmail.com', 'ajiono27@mail.com')
INSERT INTO friend (email, email_following)
             VALUES ('anastasia68@outlook.com', 'halim35@protonmail.com')
INSERT INTO friend (email, email_following)
             VALUES ('rini38@outlook.com', 'jane49@protonmail.com')
INSERT INTO friend (email, email_following)
             VALUES ('halim35@protonmail.com', 'luwes56@gmail.com')
INSERT INTO friend (email, email_following)
             VALUES ('harimurti20@yahoo.com', 'ajiono27@mail.com')
INSERT INTO friend (email, email_following)
             VALUES ('anastasia68@outlook.com', 'dono72@gmail.com')
INSERT INTO friend (email, email_following)
             VALUES ('jaiman22@mail.com', 'maria7@hotmail.com')

