CREATE DATABASE IF NOT EXISTS BustBuyDB;
USE BustBuyDB;

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