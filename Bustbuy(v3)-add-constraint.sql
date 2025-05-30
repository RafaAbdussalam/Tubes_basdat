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
    PRIMARY KEY (email),
    CONSTRAINT chk_no_telp_format CHECK (
        no_telp REGEXP '^\\+[0-9]{1,3}(-[0-9]{3})+(-[0-9]{1,})$'
    )
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
    CHECK (email <> email_following),
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
    waktu_pesan DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
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
    jumlah INT NOT NULL DEFAULT 1,
    CHECK (jumlah > 0),
    PRIMARY KEY(no_pesanan, no_produk, sku),
    FOREIGN KEY(no_pesanan) REFERENCES pesanan(no_pesanan),
    FOREIGN KEY(no_produk, sku) REFERENCES varian(no_produk, sku)
);

CREATE TABLE wishlist (
    wishlist_id INT NOT NULL AUTO_INCREMENT,
    email_pembeli VARCHAR(100) NOT NULL,
    nama_wishlist VARCHAR(20) DEFAULT NULL,
    PRIMARY KEY (wishlist_id),
    FOREIGN KEY (email_pembeli) REFERENCES pembeli(email)
);

CREATE TABLE keranjang (
    keranjang_id INT NOT NULL AUTO_INCREMENT,
    email_pembeli VARCHAR(100) NOT NULL,
    nama_keranjang VARCHAR(20) DEFAULT NULL,
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
    jumlah INT NOT NULL DEFAULT 1,
    CHECK (jumlah > 0),
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

-- VIEW: menampilkan top 5 tags
CREATE OR REPLACE VIEW top_5_tags AS
SELECT tag, COUNT(no_produk) AS jumlah_produk
FROM tag_produk
GROUP BY tag
ORDER BY jumlah_produk DESC
LIMIT 5;


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

-- TRIGGER: memastikan metode_bayar dan metode_kirim hanya dapat diubah selama status_pesanan masih "Menunggu Pembayaran"
DELIMITER //
CREATE TRIGGER trg_pesanan_metode_update
BEFORE UPDATE ON pesanan
FOR EACH ROW
BEGIN
    -- Jika status bukan "Menunggu Pembayaran" DAN metode_bayar/metode_kirim diubah
    IF OLD.status_pesanan != 'Menunggu Pembayaran' AND 
       (NEW.metode_bayar != OLD.metode_bayar OR NEW.metode_kirim != OLD.metode_kirim) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Metode bayar/kirim hanya bisa diubah saat status "Menunggu Pembayaran"';
    END IF;
END //
DELIMITER ;

-- TRIGGER: memastikan next step dari status_pesanan sesuai.
DELIMITER //
CREATE TRIGGER trg_pesanan_status_transisi
BEFORE UPDATE ON pesanan
FOR EACH ROW
BEGIN
    -- Jika status saat ini adalah "Selesai" atau "Dibatalkan", tolak semua perubahan status
    IF OLD.status_pesanan IN ('Selesai', 'Dibatalkan') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Status pesanan yang sudah "Selesai" atau "Dibatalkan" tidak dapat diubah';
    
    -- Validasi transisi status
    ELSEIF NOT (
        -- Case 1: Transisi normal (urutan berikut)
        (OLD.status_pesanan = 'Menunggu Pembayaran' AND NEW.status_pesanan = 'Diproses') OR
        (OLD.status_pesanan = 'Diproses' AND NEW.status_pesanan = 'Dikirim') OR
        (OLD.status_pesanan = 'Dikirim' AND NEW.status_pesanan = 'Selesai') OR
        
        -- Case 2: Langsung ke "Dibatalkan" dari status apa pun (kecuali "Selesai"/"Dibatalkan")
        (NEW.status_pesanan = 'Dibatalkan')
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Transisi status tidak valid. Hanya boleh ke next step atau "Dibatalkan"';
    END IF;
END //
DELIMITER ;

-- TRIGGER: penjual otomatis follow pembeli yang follow
--          penjual otomatis unfollow pembeli yang unfollow
DELIMITER //
CREATE TRIGGER trg_unfollow_reciprocal
AFTER DELETE ON friend
FOR EACH ROW
BEGIN
    DECLARE is_pembeli_lama BOOLEAN;
    DECLARE is_penjual_diikuti BOOLEAN;
    
    -- Cek apakah pengguna yang menghapus adalah pembeli dan yang diunfollow adalah penjual
    SELECT is_pembeli INTO is_pembeli_lama FROM pengguna WHERE email = OLD.email;
    SELECT is_penjual INTO is_penjual_diikuti FROM pengguna WHERE email = OLD.email_following;
    
    -- Jika pembeli berhenti mengikuti penjual, hapus hubungan sebaliknya
    IF is_pembeli_lama = TRUE AND is_penjual_diikuti = TRUE THEN
        DELETE FROM friend 
        WHERE email = OLD.email_following AND email_following = OLD.email;
    END IF;
END //
DELIMITER ;

-- Trigger: mengisi waktu_pesan dengan waktu saat ini
DELIMITER //

CREATE TRIGGER isi_waktu_pesan
BEFORE INSERT ON pesanan
FOR EACH ROW
BEGIN
    IF NEW.waktu_pesan IS NULL THEN
        SET NEW.waktu_pesan = NOW();
    END IF;
END;
//

DELIMITER ;

-- Trigger: verifikasi foto_ktp dan foto_diri pada penjual
DELIMITER //

CREATE TRIGGER verifikasi_penjual_foto
BEFORE UPDATE ON penjual
FOR EACH ROW
BEGIN
    IF NEW.is_verified = TRUE THEN
        IF NEW.foto_diri IS NULL OR NEW.foto_diri = ''
           OR NEW.foto_ktp IS NULL OR NEW.foto_ktp = '' THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Penjual tidak dapat diverifikasi tanpa mengunggah foto pribadi dan foto KTP.';
        END IF;
    END IF;
END//

DELIMITER ;

-- INSERT INTO pengguna
-- INSERT INTO pengguna
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('garan31@aol.com', 'gar6BDtWJt', 'Garan Hutasoit', '+62-508-030-330', '1983-10-21', NULL, FALSE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('heru90@hotmail.com', 'herxyns+Oj', 'Heru Namaga', '+62-254-004-988', '1987-01-06', NULL, FALSE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('gawati55@mail.com', 'gawfl-5oCd', 'Gawati Mustofa', '+62-247-010-419', '1964-11-04', NULL, FALSE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('opung93@gmail.com', 'opuSPAfuUo', 'Opung Setiawan', '+62-210-990-034', '1982-12-16', NULL, TRUE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('cemplunk31@aol.com', 'cemCdSpKzs', 'Cemplunk Gunawan', '+62-187-087-813', '1993-02-18', NULL, TRUE, FALSE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('teguh75@aol.com', 'tegT6Q#0Z2', 'Teguh Sudiati', '+62-152-501-016', '1961-09-06', NULL, TRUE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('abyasa18@protonmail.com', 'abyr12EBYu', 'Abyasa Yuliarti', '+62-003-834-289', '1974-07-10', NULL, TRUE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('rudi57@aol.com', 'rud8eH10U7', 'Rudi Hidayanto', '+62-169-076-273', '1956-12-17', NULL, TRUE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('vivi67@mail.com', 'vivyPRGcPL', 'Vivi Maryati', '+62-920-529-785', '1950-02-05', NULL, TRUE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('harimurti12@outlook.com', 'har9LX-LNy', 'Harimurti Suartini', '+62-194-831-503', '1989-09-21', NULL, TRUE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('gara24@hotmail.com', 'gar6#0I$Ng', 'Gara Firmansyah', '+62-810-224-784', '1963-01-17', NULL, TRUE, FALSE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('ade21@protonmail.com', 'adeJ-61i6Q', 'Ade Safitri', '+62-211-286-713', '1975-05-18', NULL, TRUE, FALSE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('rachel31@mail.com', 'rac^%VH25j', 'Rachel Wibowo', '+62-482-939-997', '1984-09-18', NULL, TRUE, FALSE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('laswi20@aol.com', 'las%4uCJoA', 'Laswi Prasasta', '+62-899-477-697', '1967-11-14', NULL, TRUE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('lasmono10@gmail.com', 'lasKFM-53m', 'Lasmono Prasetya', '+62-830-757-996', '1953-11-11', NULL, TRUE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('nugraha66@mail.com', 'nug@XhdT$O', 'Nugraha Wibisono', '+62-322-611-945', '1966-01-22', NULL, TRUE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('edi69@hotmail.com', 'ediD9JCzr1', 'Edi Nugroho', '+62-271-056-212', '1997-02-13', NULL, TRUE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('oni39@yahoo.com', 'onio8%deGV', 'Oni Siregar', '+62-946-552-260', '1965-11-08', NULL, FALSE, FALSE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('jati14@gmail.com', 'jatW4ZILuX', 'Jati Mayasari', '+62-669-110-283', '1991-12-21', NULL, TRUE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('daniswara51@yahoo.com', 'danI47Ckql', 'Daniswara Tarihoran', '+62-114-263-237', '1947-05-24', NULL, TRUE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('nasim25@aol.com', 'nasGCHs^*J', 'Nasim Sitompul', '+62-286-950-967', '2003-05-22', NULL, FALSE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('irwan13@yahoo.com', 'irw#zsLuhc', 'Irwan Marpaung', '+62-302-117-432', '1960-01-09', NULL, FALSE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('irnanto43@protonmail.com', 'irnjKHGSz$', 'Irnanto Saptono', '+62-464-983-970', '1988-11-28', NULL, TRUE, FALSE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('gilda79@gmail.com', 'gilpOIf&tV', 'Gilda Sudiati', '+62-263-440-845', '2005-10-10', NULL, FALSE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('siska88@gmail.com', 'sis_M2YXq6', 'Siska Haryanti', '+62-080-173-386', '1977-11-02', NULL, FALSE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('cinta78@outlook.com', 'cinAy!O@DS', 'Cinta Prastuti', '+62-221-131-286', '1996-08-26', NULL, TRUE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('rangga32@gmail.com', 'ranh$m-_Ex', 'Rangga Samosir', '+62-105-372-080', '1950-03-03', NULL, TRUE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('kusuma34@gmail.com', 'kusVxK-D!U', 'Kusuma Pradipta', '+62-538-307-238', '2001-07-26', NULL, TRUE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('mariadi4@outlook.com', 'marPYSW!_-', 'Mariadi Astuti', '+62-145-675-066', '1997-06-07', NULL, TRUE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('cornelia71@outlook.com', 'corsAmc_Q^', 'Cornelia Gunarto', '+62-576-854-707', '1965-01-07', NULL, TRUE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('atma30@outlook.com', 'atmVV9NXo_', 'Atma Wahyuni', '+62-089-840-394', '1993-01-20', NULL, TRUE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('umar49@yahoo.com', 'umaV0#5MyH', 'Umar Yulianti', '+62-506-868-655', '1965-12-03', NULL, FALSE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('purwa5@protonmail.com', 'purHR6UuoK', 'Purwa Palastri', '+62-220-878-888', '1974-09-12', NULL, TRUE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('cakrabuana55@gmail.com', 'cakB32Brje', 'Cakrabuana Haryanti', '+62-867-364-090', '1972-07-20', NULL, TRUE, FALSE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('umi33@outlook.com', 'umiO@NC1tJ', 'Umi Nashiruddin', '+62-056-632-225', '1971-01-09', NULL, TRUE, FALSE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('hairyanto16@aol.com', 'haih4mJa-D', 'Hairyanto Maryadi', '+62-728-548-904', '1957-09-16', NULL, FALSE, FALSE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('pardi19@protonmail.com', 'parPRn^mQw', 'Pardi Winarno', '+62-269-514-251', '2003-11-23', NULL, FALSE, FALSE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('ophelia59@protonmail.com', 'ophl%*JM7A', 'Ophelia Iswahyudi', '+62-327-832-477', '1959-10-21', NULL, FALSE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('naradi89@yahoo.com', 'narfj-tqUP', 'Naradi Budiyanto', '+62-145-209-533', '1980-07-02', NULL, TRUE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('karma17@protonmail.com', 'kar3WekXBn', 'Karma Andriani', '+62-695-149-496', '2009-06-05', NULL, TRUE, FALSE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('kani82@hotmail.com', 'kanByXatt#', 'Kani Sirait', '+62-524-094-631', '2005-01-22', NULL, FALSE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('kayla22@gmail.com', 'kayq1o^1YC', 'Kayla Saputra', '+62-459-252-221', '2004-08-22', NULL, TRUE, FALSE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('luis86@protonmail.com', 'luiLW7JCO0', 'Luis Prayoga', '+62-907-821-905', '1953-04-10', NULL, FALSE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('irsad44@protonmail.com', 'irsBiEUvZ&', 'Irsad Suartini', '+62-180-117-389', '2003-03-13', NULL, FALSE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('asmianto10@yahoo.com', 'asmnU15-VQ', 'Asmianto Manullang', '+62-139-239-307', '1976-05-12', NULL, TRUE, FALSE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('prayitna38@gmail.com', 'praHKE-Nrk', 'Prayitna Irawan', '+62-878-155-856', '1984-05-06', NULL, TRUE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('rini42@yahoo.com', 'riniXK9egu', 'Rini Haryanto', '+62-962-959-431', '2000-02-09', NULL, FALSE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('najib31@hotmail.com', 'naj#ixILSI', 'Najib Siregar', '+62-112-750-228', '1946-06-26', NULL, FALSE, FALSE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('talia73@yahoo.com', 'tal1%G1KY2', 'Talia Setiawan', '+62-973-484-854', '1962-10-02', NULL, FALSE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('kenari19@gmail.com', 'ken8tnlLRY', 'Kenari Wijayanti', '+62-142-823-441', '1981-07-05', NULL, FALSE, FALSE);
-- Total pengguna: 50

-- INSERT INTO alamat
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (1, 'Kalimantan Timur', 'Kendari', 'Gang Astana Anyar No. 71');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (2, 'Maluku', 'Jayapura', 'Jalan Kutisari Selatan No. 256');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (3, 'Kepulauan Bangka Belitung', 'Palu', 'Jl. Gedebage Selatan No. 84');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (4, 'Bengkulu', 'Jayapura', 'Gang Cikutra Timur No. 48');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (5, 'Papua Barat', 'Madiun', 'Gg. H.J Maemunah No. 7');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (6, 'Lampung', 'Singkawang', 'Gang S. Parman No. 094');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (7, 'Aceh', 'Solok', 'Jl. Jakarta No. 24');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (8, 'Lampung', 'Binjai', 'Gang K.H. Wahid Hasyim No. 9');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (9, 'Kalimantan Selatan', 'Lhokseumawe', 'Gg. Waringin No. 36');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (10, 'Sumatera Barat', 'Jambi', 'Jl. Pasirkoja No. 124');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (11, 'Maluku Utara', 'Blitar', 'Gg. Kiaracondong No. 66');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (12, 'Jambi', 'Pekanbaru', 'Gg. M.T Haryono No. 3');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (13, 'Jambi', 'Palembang', 'Gg. M.H Thamrin No. 940');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (14, 'Kalimantan Timur', 'Bitung', 'Jl. Ciumbuleuit No. 931');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (15, 'Kepulauan Bangka Belitung', 'Banjar', 'Gang R.E Martadinata No. 32');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (16, 'Sumatera Barat', 'Kota Administrasi Jakarta Selatan', 'Jl. Sadang Serang No. 0');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (17, 'Maluku', 'Palopo', 'Jl. Abdul Muis No. 7');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (18, 'Kepulauan Bangka Belitung', 'Surabaya', 'Gang Kutisari Selatan No. 7');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (19, 'Kalimantan Utara', 'Pagaralam', 'Jalan Soekarno Hatta No. 2');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (20, 'Sulawesi Utara', 'Makassar', 'Jalan Cikutra Barat No. 03');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (21, 'Banten', 'Banda Aceh', 'Gang Kapten Muslihat No. 087');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (22, 'Jawa Tengah', 'Kota Administrasi Jakarta Selatan', 'Jalan Stasiun Wonokromo No. 20');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (23, 'Sulawesi Barat', 'Tual', 'Jl. PHH. Mustofa No. 6');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (24, 'Sumatera Utara', 'Mataram', 'Gg. Rawamangun No. 5');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (25, 'Sumatera Barat', 'Semarang', 'Gg. S. Parman No. 385');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (26, 'Jambi', 'Ambon', 'Gang Suniaraja No. 2');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (27, 'Kepulauan Riau', 'Sabang', 'Jalan Waringin No. 6');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (28, 'Jawa Barat', 'Samarinda', 'Gg. Monginsidi No. 033');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (29, 'Papua', 'Dumai', 'Gang M.T Haryono No. 002');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (30, 'Jawa Timur', 'Surabaya', 'Jl. Stasiun Wonokromo No. 916');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (31, 'Sulawesi Barat', 'Sorong', 'Jalan H.J Maemunah No. 65');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (32, 'Sulawesi Barat', 'Cimahi', 'Gg. Erlangga No. 136');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (33, 'DKI Jakarta', 'Kota Administrasi Jakarta Barat', 'Jl. Pasir Koja No. 17');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (34, 'Kalimantan Timur', 'Pontianak', 'Gg. Medokan Ayu No. 24');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (35, 'Kalimantan Selatan', 'Balikpapan', 'Gang Rajiman No. 80');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (36, 'Sumatera Utara', 'Medan', 'Jalan Joyoboyo No. 1');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (37, 'Maluku', 'Tanjungbalai', 'Jl. Astana Anyar No. 27');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (38, 'Sulawesi Barat', 'Balikpapan', 'Jalan Asia Afrika No. 56');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (39, 'Maluku Utara', 'Dumai', 'Gang Jend. Sudirman No. 95');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (40, 'Bengkulu', 'Pekalongan', 'Jl. Moch. Toha No. 5');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (41, 'Nusa Tenggara Barat', 'Kotamobagu', 'Jl. Lembong No. 3');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (42, 'Riau', 'Palopo', 'Jl. Cihampelas No. 033');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (43, 'Sulawesi Selatan', 'Pontianak', 'Gg. HOS. Cokroaminoto No. 1');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (44, 'Lampung', 'Tanjungbalai', 'Gg. Raya Ujungberung No. 9');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (45, 'Sulawesi Utara', 'Malang', 'Gang Medokan Ayu No. 2');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (46, 'Lampung', 'Pekanbaru', 'Jalan Kutisari Selatan No. 37');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (47, 'Sulawesi Barat', 'Sorong', 'Gang Kiaracondong No. 457');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (48, 'Sulawesi Utara', 'Jambi', 'Gang Astana Anyar No. 7');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (49, 'Bali', 'Madiun', 'Jl. Otto Iskandardinata No. 5');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (50, 'Papua', 'Tegal', 'Jl. M.H Thamrin No. 5');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (51, 'Maluku', 'Palu', 'Gang Merdeka No. 9');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (52, 'Nusa Tenggara Timur', 'Tebingtinggi', 'Jalan Siliwangi No. 69');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (53, 'Aceh', 'Jayapura', 'Jl. Medokan Ayu No. 4');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (54, 'Kepulauan Bangka Belitung', 'Pematangsiantar', 'Gang Jayawijaya No. 315');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (55, 'Papua Barat', 'Sukabumi', 'Jalan Veteran No. 5');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (56, 'Gorontalo', 'Sungai Penuh', 'Gang M.H Thamrin No. 09');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (57, 'Jambi', 'Balikpapan', 'Gang Soekarno Hatta No. 817');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (58, 'Jawa Timur', 'Kota Administrasi Jakarta Timur', 'Jl. Kebonjati No. 1');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (59, 'Maluku Utara', 'Bengkulu', 'Gang Ciwastra No. 099');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (60, 'Sulawesi Tengah', 'Denpasar', 'Jalan Otto Iskandardinata No. 6');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (61, 'Kalimantan Utara', 'Padangpanjang', 'Gg. Pasteur No. 4');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (62, 'Maluku Utara', 'Denpasar', 'Jl. Gegerkalong Hilir No. 1');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (63, 'Lampung', 'Kendari', 'Gg. Gedebage Selatan No. 4');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (64, 'Sulawesi Barat', 'Medan', 'Jalan Moch. Toha No. 306');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (65, 'DKI Jakarta', 'Malang', 'Jalan Sentot Alibasa No. 9');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (66, 'Sulawesi Barat', 'Padang', 'Jalan Gardujati No. 441');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (67, 'Kepulauan Riau', 'Kota Administrasi Jakarta Pusat', 'Jalan Wonoayu No. 391');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (68, 'Riau', 'Kota Administrasi Jakarta Barat', 'Jl. Gegerkalong Hilir No. 91');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (69, 'Bali', 'Samarinda', 'Jl. Sentot Alibasa No. 8');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (70, 'Sumatera Selatan', 'Subulussalam', 'Jalan Asia Afrika No. 726');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (71, 'Sulawesi Utara', 'Prabumulih', 'Gg. Setiabudhi No. 06');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (72, 'Sumatera Utara', 'Blitar', 'Jalan Joyoboyo No. 681');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (73, 'Sulawesi Tenggara', 'Bontang', 'Gang Ciwastra No. 78');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (74, 'Maluku Utara', 'Kotamobagu', 'Gang Kutai No. 57');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (75, 'Sumatera Selatan', 'Bengkulu', 'Jalan Sukajadi No. 55');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (76, 'Sumatera Barat', 'Gorontalo', 'Jl. Cempaka No. 7');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (77, 'DKI Jakarta', 'Ternate', 'Jl. Abdul Muis No. 50');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (78, 'Nusa Tenggara Barat', 'Jayapura', 'Gang Jakarta No. 819');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (79, 'Kepulauan Bangka Belitung', 'Tangerang', 'Gang Ronggowarsito No. 649');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (80, 'Sulawesi Tengah', 'Denpasar', 'Gang Ciumbuleuit No. 891');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (81, 'Aceh', 'Malang', 'Jalan Yos Sudarso No. 90');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (82, 'Sumatera Utara', 'Malang', 'Jl. Rajiman No. 84');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (83, 'Sulawesi Selatan', 'Mataram', 'Gg. M.T Haryono No. 8');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (84, 'DKI Jakarta', 'Palu', 'Gang Kutisari Selatan No. 02');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (85, 'Kalimantan Barat', 'Bitung', 'Jl. Sentot Alibasa No. 513');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (86, 'Papua', 'Samarinda', 'Gang Cikutra Barat No. 596');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (87, 'Sumatera Utara', 'Palangkaraya', 'Jalan Laswi No. 95');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (88, 'Sumatera Utara', 'Ternate', 'Jl. Kutai No. 839');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (89, 'Kepulauan Riau', 'Metro', 'Gg. Sadang Serang No. 6');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (90, 'Sulawesi Utara', 'Subulussalam', 'Gg. Gegerkalong Hilir No. 8');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (91, 'Nusa Tenggara Barat', 'Ternate', 'Gang Peta No. 3');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (92, 'Kalimantan Selatan', 'Pagaralam', 'Jalan KH Amin Jasuta No. 35');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (93, 'Nusa Tenggara Barat', 'Sorong', 'Gang Kiaracondong No. 294');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (94, 'Sumatera Utara', 'Payakumbuh', 'Gg. Pelajar Pejuang No. 99');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (95, 'Kepulauan Riau', 'Bontang', 'Gg. Ahmad Yani No. 59');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (96, 'Kepulauan Riau', 'Padang', 'Jalan Sukabumi No. 712');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (97, 'Sulawesi Barat', 'Tangerang Selatan', 'Gang Medokan Ayu No. 06');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (98, 'Nusa Tenggara Barat', 'Metro', 'Gang Setiabudhi No. 102');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (99, 'Aceh', 'Pekalongan', 'Jl. Siliwangi No. 594');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (100, 'Lampung', 'Bau-Bau', 'Jalan Pasteur No. 1');
-- Total alamat: 100

-- INSERT INTO pembeli
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('heru90@hotmail.com', 31);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('gawati55@mail.com', 46);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('opung93@gmail.com', 69);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('cemplunk31@aol.com', 88);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('vivi67@mail.com', 86);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('gara24@hotmail.com', 36);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('ade21@protonmail.com', 81);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('rachel31@mail.com', 8);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('laswi20@aol.com', 23);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('edi69@hotmail.com', 63);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('oni39@yahoo.com', 50);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('jati14@gmail.com', 52);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('nasim25@aol.com', 6);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('irnanto43@protonmail.com', 89);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('gilda79@gmail.com', 25);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('siska88@gmail.com', 35);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('cinta78@outlook.com', 25);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('rangga32@gmail.com', 16);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('kusuma34@gmail.com', 43);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('mariadi4@outlook.com', 35);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('cornelia71@outlook.com', 52);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('atma30@outlook.com', 71);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('umar49@yahoo.com', 80);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('umi33@outlook.com', 75);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('hairyanto16@aol.com', 92);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('pardi19@protonmail.com', 1);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('ophelia59@protonmail.com', 61);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('naradi89@yahoo.com', 14);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('kani82@hotmail.com', 17);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('kayla22@gmail.com', 3);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('luis86@protonmail.com', 15);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('irsad44@protonmail.com', 92);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('asmianto10@yahoo.com', 34);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('prayitna38@gmail.com', 26);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('rini42@yahoo.com', 7);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('najib31@hotmail.com', 47);
-- Total pembeli: 36

-- INSERT INTO penjual
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('garan31@aol.com', 'ktp/6390769c-d846-4f39-9979-984191d120b9.jpg', 'selfie/737329cb-33ee-4b77-8ffa-19f3a192fa8d.jpg', FALSE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('heru90@hotmail.com', 'ktp/94a78c29-248f-439a-b892-3a9ad8da10d0.jpg', 'selfie/51cd941c-f561-4bee-a576-85ac362c5d51.jpg', FALSE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('gawati55@mail.com', 'ktp/edd7c65c-e153-4328-bb8e-92508cba8976.jpg', 'selfie/8ccdc8ea-43ab-47d1-9683-ea2015778340.jpg', TRUE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('cemplunk31@aol.com', 'ktp/6700fa7d-51ab-42a0-968d-bfc66b0d5a0d.jpg', 'selfie/558c47ad-b6d7-4f0e-be5c-6e7eb26821a2.jpg', FALSE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('teguh75@aol.com', 'ktp/c0340497-d569-4a58-9f4d-4ca3f75f6eed.jpg', 'selfie/7a69e77c-230b-4618-9da4-2afa14a3b580.jpg', FALSE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('abyasa18@protonmail.com', 'ktp/43ebead3-d15c-4787-a543-181822518f1a.jpg', 'selfie/22d0b320-faa1-4c28-a36e-f301ffafd70f.jpg', TRUE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('rudi57@aol.com', 'ktp/4e94cea3-060d-4cd2-9deb-173943291047.jpg', 'selfie/70cbb2bf-aa8b-48a2-bf9a-ec136e8d3152.jpg', TRUE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('vivi67@mail.com', 'ktp/e2d805a4-5662-49ee-b92f-ed6f64a8eebe.jpg', 'selfie/22fcb3ad-1f94-4b0c-b3f1-b593deb175d5.jpg', FALSE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('harimurti12@outlook.com', 'ktp/65d1abca-b913-482a-9c43-6f3c660dd323.jpg', 'selfie/4f60221c-991a-4223-9407-cb321c2e6e30.jpg', TRUE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('gara24@hotmail.com', 'ktp/88d59def-8d72-487a-93ba-6ea631a3f993.jpg', 'selfie/6519c04a-4dc1-4395-81fb-7b5ba27c30fd.jpg', TRUE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('ade21@protonmail.com', 'ktp/ac6b2237-5829-4c0c-b219-d00adbe4536c.jpg', 'selfie/241607d6-e577-4852-9741-3b6d09e7d240.jpg', TRUE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('rachel31@mail.com', 'ktp/69710c39-6501-476d-b949-139c7f20aca4.jpg', 'selfie/d1cf6891-94cb-40c7-a686-fe6896f64295.jpg', FALSE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('laswi20@aol.com', 'ktp/b94eacb0-ad2d-4416-bcd2-7a2786a68ce3.jpg', 'selfie/a8e6529c-c660-4bb0-b3e4-ddad1905ddf4.jpg', FALSE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('nugraha66@mail.com', 'ktp/a2eca021-9ae6-423a-85c4-f3b6b8401a57.jpg', 'selfie/a942f630-89aa-4336-86c5-f6e6e50f37e9.jpg', TRUE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('edi69@hotmail.com', 'ktp/f0e8f402-18b1-4b93-b67c-afe3bf756917.jpg', 'selfie/c68b36cd-72b4-4c44-afe8-9d92937a81f4.jpg', FALSE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('oni39@yahoo.com', 'ktp/409d8dc9-8a76-4b91-8b67-08e51e6d462a.jpg', 'selfie/ca87c7df-770e-4aa9-8f85-923f83738411.jpg', FALSE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('jati14@gmail.com', 'ktp/00a1e19c-6fe5-467c-8956-dd1eb8e40af0.jpg', 'selfie/aa412e11-8c99-4329-8bce-f9b17aa7eab1.jpg', FALSE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('gilda79@gmail.com', 'ktp/a1b65390-e3a7-44b4-a476-24b20141ad10.jpg', 'selfie/33dd43c6-671d-48a7-9cd3-9a3306ec114a.jpg', TRUE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('siska88@gmail.com', 'ktp/72ee8f4a-fb7d-47f5-8770-f423eb6ced37.jpg', 'selfie/738ad815-faa6-4e99-a318-864a64b0ce36.jpg', TRUE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('rangga32@gmail.com', 'ktp/f40ac237-0ac1-41e1-a76d-f24a47e96c40.jpg', 'selfie/bb3b184d-d7b5-4523-ba58-080c0cc78190.jpg', FALSE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('atma30@outlook.com', 'ktp/0ee846f6-1ebf-4534-a57d-c47256ef0df1.jpg', 'selfie/36e72d40-5f43-49f9-a767-9e5d78e652cb.jpg', FALSE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('umar49@yahoo.com', 'ktp/659bfbae-0895-4bbf-acfb-bd8ff49cb2a3.jpg', 'selfie/8569b90e-126c-4179-a08c-98108dd8e641.jpg', TRUE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('cakrabuana55@gmail.com', 'ktp/33745e5b-f6b1-4457-96d2-96428260b0a2.jpg', 'selfie/e194f31e-981e-475c-a111-676d82e70aac.jpg', FALSE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('umi33@outlook.com', 'ktp/5531a25f-4468-425d-b525-ec489d9c8278.jpg', 'selfie/64fbff06-55c8-46d6-85ac-533d123977a5.jpg', TRUE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('hairyanto16@aol.com', 'ktp/dd7493ca-9f2c-49f1-a85c-3a03c6f48654.jpg', 'selfie/2f1cfb47-399d-4d6d-b50c-e2d038b0d6e0.jpg', TRUE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('ophelia59@protonmail.com', 'ktp/4fcd13b0-9625-42dd-96b4-d92875f96065.jpg', 'selfie/e064e80c-b932-44a7-b7bc-08abe107525b.jpg', TRUE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('naradi89@yahoo.com', 'ktp/2926aeea-a2fd-44e3-abe0-8d31ca60be1b.jpg', 'selfie/61916bd8-d339-4f7e-99ec-8b7a108c6b85.jpg', TRUE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('karma17@protonmail.com', 'ktp/c25ebdc0-7950-4159-87db-aa4738c6a7e0.jpg', 'selfie/a3b722f3-65bf-48e6-96d6-f3e2a5c2131b.jpg', FALSE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('kani82@hotmail.com', 'ktp/852e92b5-f619-4d5d-91ff-762dc473031c.jpg', 'selfie/95a2b1f9-b459-4a34-9fd2-c34ac57c02d7.jpg', TRUE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('kayla22@gmail.com', 'ktp/4769d047-5a73-41c3-937a-7c04e074b088.jpg', 'selfie/ab4a1b30-bf74-45e6-b6fc-4b30d8495856.jpg', FALSE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('luis86@protonmail.com', 'ktp/0e93e5a9-e8bf-4b80-b826-158ca193059b.jpg', 'selfie/604258c1-f115-4565-908a-51b332173f27.jpg', TRUE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('najib31@hotmail.com', 'ktp/f7ff5cfb-8374-40a8-aa29-9932b0e8593b.jpg', 'selfie/8066fd5f-a083-4dca-aaa7-485689ea73a9.jpg', TRUE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('talia73@yahoo.com', 'ktp/91d12463-017c-47ba-8d30-fca4fac0632e.jpg', 'selfie/ac78c0fb-49a1-4c60-8f41-f7eddcdf7bba.jpg', TRUE);
-- Total penjual: 33, terverifikasi: 18

-- INSERT INTO friend
INSERT INTO friend (email, email_following)
                 VALUES ('cemplunk31@aol.com', 'cornelia71@outlook.com');
INSERT INTO friend (email, email_following)
                 VALUES ('cemplunk31@aol.com', 'lasmono10@gmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('nugraha66@mail.com', 'najib31@hotmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('irnanto43@protonmail.com', 'gilda79@gmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('mariadi4@outlook.com', 'luis86@protonmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('irsad44@protonmail.com', 'opung93@gmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('heru90@hotmail.com', 'siska88@gmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('mariadi4@outlook.com', 'nugraha66@mail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('kayla22@gmail.com', 'lasmono10@gmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('daniswara51@yahoo.com', 'lasmono10@gmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('najib31@hotmail.com', 'rangga32@gmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('kusuma34@gmail.com', 'laswi20@aol.com');
INSERT INTO friend (email, email_following)
                 VALUES ('kusuma34@gmail.com', 'rangga32@gmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('purwa5@protonmail.com', 'vivi67@mail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('teguh75@aol.com', 'edi69@hotmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('lasmono10@gmail.com', 'mariadi4@outlook.com');
INSERT INTO friend (email, email_following)
                 VALUES ('irwan13@yahoo.com', 'rangga32@gmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('atma30@outlook.com', 'siska88@gmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('siska88@gmail.com', 'atma30@outlook.com');
INSERT INTO friend (email, email_following)
                 VALUES ('jati14@gmail.com', 'ophelia59@protonmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('daniswara51@yahoo.com', 'cornelia71@outlook.com');
INSERT INTO friend (email, email_following)
                 VALUES ('nugraha66@mail.com', 'irwan13@yahoo.com');
INSERT INTO friend (email, email_following)
                 VALUES ('nasim25@aol.com', 'laswi20@aol.com');
INSERT INTO friend (email, email_following)
                 VALUES ('purwa5@protonmail.com', 'garan31@aol.com');
INSERT INTO friend (email, email_following)
                 VALUES ('heru90@hotmail.com', 'rangga32@gmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('heru90@hotmail.com', 'karma17@protonmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('irsad44@protonmail.com', 'edi69@hotmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('jati14@gmail.com', 'rangga32@gmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('karma17@protonmail.com', 'lasmono10@gmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('prayitna38@gmail.com', 'cakrabuana55@gmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('kenari19@gmail.com', 'opung93@gmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('cemplunk31@aol.com', 'hairyanto16@aol.com');
INSERT INTO friend (email, email_following)
                 VALUES ('cornelia71@outlook.com', 'gawati55@mail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('vivi67@mail.com', 'edi69@hotmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('opung93@gmail.com', 'siska88@gmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('edi69@hotmail.com', 'cemplunk31@aol.com');
INSERT INTO friend (email, email_following)
                 VALUES ('rini42@yahoo.com', 'najib31@hotmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('ophelia59@protonmail.com', 'kani82@hotmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('talia73@yahoo.com', 'vivi67@mail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('vivi67@mail.com', 'karma17@protonmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('teguh75@aol.com', 'laswi20@aol.com');
INSERT INTO friend (email, email_following)
                 VALUES ('nasim25@aol.com', 'cemplunk31@aol.com');
INSERT INTO friend (email, email_following)
                 VALUES ('umar49@yahoo.com', 'rachel31@mail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('rini42@yahoo.com', 'vivi67@mail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('siska88@gmail.com', 'lasmono10@gmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('najib31@hotmail.com', 'cornelia71@outlook.com');
INSERT INTO friend (email, email_following)
                 VALUES ('gara24@hotmail.com', 'mariadi4@outlook.com');
INSERT INTO friend (email, email_following)
                 VALUES ('cakrabuana55@gmail.com', 'jati14@gmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('naradi89@yahoo.com', 'siska88@gmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('hairyanto16@aol.com', 'irsad44@protonmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('irwan13@yahoo.com', 'gara24@hotmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('pardi19@protonmail.com', 'garan31@aol.com');
INSERT INTO friend (email, email_following)
                 VALUES ('hairyanto16@aol.com', 'kenari19@gmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('edi69@hotmail.com', 'ade21@protonmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('kusuma34@gmail.com', 'oni39@yahoo.com');
INSERT INTO friend (email, email_following)
                 VALUES ('heru90@hotmail.com', 'naradi89@yahoo.com');
INSERT INTO friend (email, email_following)
                 VALUES ('rudi57@aol.com', 'rangga32@gmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('najib31@hotmail.com', 'jati14@gmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('naradi89@yahoo.com', 'rangga32@gmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('gawati55@mail.com', 'umar49@yahoo.com');
INSERT INTO friend (email, email_following)
                 VALUES ('kayla22@gmail.com', 'gawati55@mail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('luis86@protonmail.com', 'kusuma34@gmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('oni39@yahoo.com', 'teguh75@aol.com');
INSERT INTO friend (email, email_following)
                 VALUES ('kenari19@gmail.com', 'lasmono10@gmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('opung93@gmail.com', 'cinta78@outlook.com');
INSERT INTO friend (email, email_following)
                 VALUES ('cemplunk31@aol.com', 'irnanto43@protonmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('cakrabuana55@gmail.com', 'purwa5@protonmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('oni39@yahoo.com', 'luis86@protonmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('edi69@hotmail.com', 'umar49@yahoo.com');
INSERT INTO friend (email, email_following)
                 VALUES ('edi69@hotmail.com', 'gara24@hotmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('ophelia59@protonmail.com', 'edi69@hotmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('irwan13@yahoo.com', 'najib31@hotmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('hairyanto16@aol.com', 'siska88@gmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('cinta78@outlook.com', 'harimurti12@outlook.com');
INSERT INTO friend (email, email_following)
                 VALUES ('laswi20@aol.com', 'gara24@hotmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('gilda79@gmail.com', 'rini42@yahoo.com');
INSERT INTO friend (email, email_following)
                 VALUES ('lasmono10@gmail.com', 'edi69@hotmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('heru90@hotmail.com', 'umar49@yahoo.com');
INSERT INTO friend (email, email_following)
                 VALUES ('cakrabuana55@gmail.com', 'atma30@outlook.com');
INSERT INTO friend (email, email_following)
                 VALUES ('siska88@gmail.com', 'daniswara51@yahoo.com');
INSERT INTO friend (email, email_following)
                 VALUES ('edi69@hotmail.com', 'rini42@yahoo.com');
INSERT INTO friend (email, email_following)
                 VALUES ('atma30@outlook.com', 'hairyanto16@aol.com');
INSERT INTO friend (email, email_following)
                 VALUES ('ophelia59@protonmail.com', 'rudi57@aol.com');
INSERT INTO friend (email, email_following)
                 VALUES ('cinta78@outlook.com', 'irsad44@protonmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('cinta78@outlook.com', 'nugraha66@mail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('asmianto10@yahoo.com', 'najib31@hotmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('luis86@protonmail.com', 'heru90@hotmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('cinta78@outlook.com', 'cornelia71@outlook.com');
INSERT INTO friend (email, email_following)
                 VALUES ('karma17@protonmail.com', 'cemplunk31@aol.com');
INSERT INTO friend (email, email_following)
                 VALUES ('cakrabuana55@gmail.com', 'cornelia71@outlook.com');
INSERT INTO friend (email, email_following)
                 VALUES ('siska88@gmail.com', 'edi69@hotmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('laswi20@aol.com', 'naradi89@yahoo.com');
INSERT INTO friend (email, email_following)
                 VALUES ('jati14@gmail.com', 'atma30@outlook.com');
INSERT INTO friend (email, email_following)
                 VALUES ('irwan13@yahoo.com', 'rachel31@mail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('rangga32@gmail.com', 'purwa5@protonmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('gilda79@gmail.com', 'atma30@outlook.com');
INSERT INTO friend (email, email_following)
                 VALUES ('ophelia59@protonmail.com', 'pardi19@protonmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('talia73@yahoo.com', 'rudi57@aol.com');
INSERT INTO friend (email, email_following)
                 VALUES ('umi33@outlook.com', 'gara24@hotmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('laswi20@aol.com', 'kayla22@gmail.com');
-- Total friend: 100

-- INSERT INTO alamat_alternatif
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('umi33@outlook.com', 2);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('opung93@gmail.com', 40);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('hairyanto16@aol.com', 32);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('gilda79@gmail.com', 38);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('naradi89@yahoo.com', 75);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('rangga32@gmail.com', 92);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('gawati55@mail.com', 4);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('mariadi4@outlook.com', 8);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('umi33@outlook.com', 75);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('opung93@gmail.com', 32);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('cornelia71@outlook.com', 37);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('gara24@hotmail.com', 64);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('kayla22@gmail.com', 33);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('rachel31@mail.com', 35);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('mariadi4@outlook.com', 72);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('kayla22@gmail.com', 100);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('ade21@protonmail.com', 6);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('ade21@protonmail.com', 16);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('cemplunk31@aol.com', 12);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('naradi89@yahoo.com', 77);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('heru90@hotmail.com', 67);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('kayla22@gmail.com', 37);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('ophelia59@protonmail.com', 1);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('nasim25@aol.com', 41);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('umar49@yahoo.com', 49);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('irsad44@protonmail.com', 66);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('gilda79@gmail.com', 14);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('cemplunk31@aol.com', 83);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('luis86@protonmail.com', 6);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('vivi67@mail.com', 34);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('kusuma34@gmail.com', 100);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('laswi20@aol.com', 47);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('rini42@yahoo.com', 39);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('rini42@yahoo.com', 65);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('rachel31@mail.com', 39);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('gawati55@mail.com', 71);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('kayla22@gmail.com', 31);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('kayla22@gmail.com', 41);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('laswi20@aol.com', 41);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('prayitna38@gmail.com', 16);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('umi33@outlook.com', 25);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('hairyanto16@aol.com', 31);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('edi69@hotmail.com', 100);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('rachel31@mail.com', 28);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('irnanto43@protonmail.com', 67);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('rangga32@gmail.com', 68);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('umar49@yahoo.com', 66);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('najib31@hotmail.com', 68);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('laswi20@aol.com', 61);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('naradi89@yahoo.com', 38);
-- Total alamat_alternatif: 50

-- INSERT INTO produk
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (1, 'Kaos Polos Vel', 'Desain modern', 'gawati55@mail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (2, 'Jaket Hoodie Dolores', 'Desain modern', 'gawati55@mail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (3, 'Topi Baseball Harum', 'Nyaman dipakai', 'gawati55@mail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (4, 'Kemeja Formal Qui', 'Produk berkualitas tinggi', 'gawati55@mail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (5, 'Topi Baseball Sunt', 'Tahan lama', 'gawati55@mail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (6, 'Topi Baseball Recusandae', 'Produk berkualitas tinggi', 'gawati55@mail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (7, 'Kaos Polos Dicta', 'Produk berkualitas tinggi', 'gawati55@mail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (8, 'Jaket Hoodie At', 'Produk berkualitas tinggi', 'gawati55@mail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (9, 'Topi Baseball Corporis', 'Desain modern', 'gawati55@mail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (10, 'Dress Midi Tempore', 'Desain modern', 'gawati55@mail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (11, 'Topi Baseball Voluptatibus', 'Tahan lama', 'gawati55@mail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (12, 'Sepatu Sneakers Cupiditate', 'Nyaman dipakai', 'abyasa18@protonmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (13, 'Celana Jeans Culpa', 'Tahan lama', 'abyasa18@protonmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (14, 'Dress Midi Illum', 'Nyaman dipakai', 'abyasa18@protonmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (15, 'Topi Baseball Corrupti', 'Nyaman dipakai', 'abyasa18@protonmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (16, 'Tas Ransel Deserunt', 'Produk berkualitas tinggi', 'abyasa18@protonmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (17, 'Topi Baseball Harum', 'Desain modern', 'abyasa18@protonmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (18, 'Kemeja Formal Laborum', 'Produk berkualitas tinggi', 'abyasa18@protonmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (19, 'Tas Ransel Rerum', 'Tahan lama', 'abyasa18@protonmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (20, 'Celana Jeans Quod', 'Desain modern', 'abyasa18@protonmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (21, 'Sepatu Sneakers Quibusdam', 'Produk berkualitas tinggi', 'abyasa18@protonmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (22, 'Celana Jeans Nulla', 'Nyaman dipakai', 'abyasa18@protonmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (23, 'Sepatu Sneakers Consequuntur', 'Nyaman dipakai', 'rudi57@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (24, 'Sepatu Sneakers Repudiandae', 'Nyaman dipakai', 'rudi57@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (25, 'Kemeja Formal Omnis', 'Produk berkualitas tinggi', 'rudi57@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (26, 'Dress Midi Ad', 'Tahan lama', 'rudi57@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (27, 'Jaket Hoodie Unde', 'Nyaman dipakai', 'rudi57@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (28, 'Tas Ransel Voluptates', 'Tahan lama', 'rudi57@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (29, 'Kemeja Formal Non', 'Tahan lama', 'rudi57@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (30, 'Kaos Polos Fugiat', 'Nyaman dipakai', 'rudi57@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (31, 'Celana Jeans Suscipit', 'Tahan lama', 'rudi57@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (32, 'Celana Jeans Inventore', 'Tahan lama', 'rudi57@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (33, 'Kemeja Formal Aliquid', 'Desain modern', 'rudi57@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (34, 'Kaos Polos Quidem', 'Nyaman dipakai', 'harimurti12@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (35, 'Jaket Hoodie Suscipit', 'Produk berkualitas tinggi', 'harimurti12@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (36, 'Celana Jeans Exercitationem', 'Tahan lama', 'harimurti12@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (37, 'Topi Baseball Atque', 'Nyaman dipakai', 'harimurti12@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (38, 'Kemeja Formal Id', 'Produk berkualitas tinggi', 'harimurti12@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (39, 'Kaos Polos Quas', 'Nyaman dipakai', 'harimurti12@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (40, 'Celana Jeans Repellat', 'Nyaman dipakai', 'harimurti12@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (41, 'Sepatu Sneakers Voluptatibus', 'Desain modern', 'harimurti12@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (42, 'Celana Jeans Recusandae', 'Desain modern', 'harimurti12@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (43, 'Sepatu Sneakers Natus', 'Desain modern', 'harimurti12@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (44, 'Tas Ransel Eaque', 'Desain modern', 'harimurti12@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (45, 'Dress Midi Distinctio', 'Tahan lama', 'gara24@hotmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (46, 'Topi Baseball Possimus', 'Produk berkualitas tinggi', 'gara24@hotmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (47, 'Kemeja Formal Cumque', 'Produk berkualitas tinggi', 'gara24@hotmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (48, 'Tas Ransel Repudiandae', 'Tahan lama', 'gara24@hotmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (49, 'Jaket Hoodie Veritatis', 'Tahan lama', 'gara24@hotmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (50, 'Kemeja Formal Iste', 'Produk berkualitas tinggi', 'gara24@hotmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (51, 'Dress Midi Minus', 'Nyaman dipakai', 'gara24@hotmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (52, 'Kemeja Formal Aspernatur', 'Produk berkualitas tinggi', 'gara24@hotmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (53, 'Kaos Polos Dolor', 'Nyaman dipakai', 'gara24@hotmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (54, 'Sepatu Sneakers Debitis', 'Tahan lama', 'gara24@hotmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (55, 'Sepatu Sneakers Minima', 'Nyaman dipakai', 'gara24@hotmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (56, 'Jaket Hoodie Dolor', 'Produk berkualitas tinggi', 'ade21@protonmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (57, 'Tas Ransel Rem', 'Nyaman dipakai', 'ade21@protonmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (58, 'Tas Ransel Adipisci', 'Desain modern', 'ade21@protonmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (59, 'Jaket Hoodie Eveniet', 'Desain modern', 'ade21@protonmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (60, 'Topi Baseball Porro', 'Desain modern', 'ade21@protonmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (61, 'Topi Baseball Nam', 'Produk berkualitas tinggi', 'ade21@protonmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (62, 'Tas Ransel Consequuntur', 'Desain modern', 'ade21@protonmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (63, 'Topi Baseball Itaque', 'Produk berkualitas tinggi', 'ade21@protonmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (64, 'Jaket Hoodie Nulla', 'Produk berkualitas tinggi', 'ade21@protonmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (65, 'Jaket Hoodie Harum', 'Nyaman dipakai', 'ade21@protonmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (66, 'Celana Jeans Sequi', 'Produk berkualitas tinggi', 'ade21@protonmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (67, 'Jaket Hoodie Expedita', 'Tahan lama', 'nugraha66@mail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (68, 'Dress Midi Fugiat', 'Desain modern', 'nugraha66@mail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (69, 'Kemeja Formal Eveniet', 'Tahan lama', 'nugraha66@mail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (70, 'Topi Baseball Minima', 'Nyaman dipakai', 'nugraha66@mail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (71, 'Sepatu Sneakers Hic', 'Nyaman dipakai', 'nugraha66@mail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (72, 'Celana Jeans Distinctio', 'Produk berkualitas tinggi', 'nugraha66@mail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (73, 'Topi Baseball Laboriosam', 'Desain modern', 'nugraha66@mail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (74, 'Celana Jeans Porro', 'Nyaman dipakai', 'nugraha66@mail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (75, 'Kemeja Formal Incidunt', 'Desain modern', 'nugraha66@mail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (76, 'Kemeja Formal Voluptate', 'Nyaman dipakai', 'nugraha66@mail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (77, 'Dress Midi Explicabo', 'Nyaman dipakai', 'nugraha66@mail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (78, 'Celana Jeans Nam', 'Desain modern', 'gilda79@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (79, 'Celana Jeans Dolores', 'Desain modern', 'gilda79@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (80, 'Kemeja Formal Perferendis', 'Desain modern', 'gilda79@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (81, 'Celana Jeans Commodi', 'Tahan lama', 'gilda79@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (82, 'Kemeja Formal Nam', 'Produk berkualitas tinggi', 'gilda79@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (83, 'Kaos Polos Assumenda', 'Produk berkualitas tinggi', 'gilda79@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (84, 'Kemeja Formal Quia', 'Desain modern', 'gilda79@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (85, 'Sepatu Sneakers Voluptatibus', 'Desain modern', 'gilda79@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (86, 'Jaket Hoodie Quae', 'Produk berkualitas tinggi', 'gilda79@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (87, 'Kaos Polos Voluptatem', 'Desain modern', 'gilda79@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (88, 'Kemeja Formal Dolor', 'Nyaman dipakai', 'gilda79@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (89, 'Tas Ransel Ut', 'Produk berkualitas tinggi', 'siska88@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (90, 'Topi Baseball Nesciunt', 'Desain modern', 'siska88@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (91, 'Kemeja Formal Veritatis', 'Produk berkualitas tinggi', 'siska88@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (92, 'Sepatu Sneakers Rem', 'Desain modern', 'siska88@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (93, 'Sepatu Sneakers Dolores', 'Desain modern', 'siska88@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (94, 'Jaket Hoodie Voluptate', 'Tahan lama', 'siska88@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (95, 'Sepatu Sneakers Voluptates', 'Desain modern', 'siska88@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (96, 'Sepatu Sneakers Atque', 'Desain modern', 'siska88@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (97, 'Kaos Polos Sed', 'Desain modern', 'siska88@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (98, 'Topi Baseball Voluptates', 'Desain modern', 'siska88@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (99, 'Kaos Polos Aliquid', 'Nyaman dipakai', 'siska88@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (100, 'Kaos Polos Ea', 'Nyaman dipakai', 'umar49@yahoo.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (101, 'Jaket Hoodie Voluptates', 'Desain modern', 'umar49@yahoo.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (102, 'Dress Midi Sint', 'Tahan lama', 'umar49@yahoo.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (103, 'Sepatu Sneakers Deleniti', 'Nyaman dipakai', 'umar49@yahoo.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (104, 'Celana Jeans Dolorum', 'Produk berkualitas tinggi', 'umar49@yahoo.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (105, 'Tas Ransel Quibusdam', 'Nyaman dipakai', 'umar49@yahoo.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (106, 'Tas Ransel Quo', 'Nyaman dipakai', 'umar49@yahoo.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (107, 'Celana Jeans Laudantium', 'Tahan lama', 'umar49@yahoo.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (108, 'Topi Baseball Molestias', 'Nyaman dipakai', 'umar49@yahoo.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (109, 'Tas Ransel Saepe', 'Desain modern', 'umar49@yahoo.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (110, 'Celana Jeans Iure', 'Nyaman dipakai', 'umar49@yahoo.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (111, 'Kemeja Formal Quae', 'Desain modern', 'umi33@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (112, 'Celana Jeans Veritatis', 'Produk berkualitas tinggi', 'umi33@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (113, 'Tas Ransel Modi', 'Tahan lama', 'umi33@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (114, 'Kemeja Formal Cumque', 'Produk berkualitas tinggi', 'umi33@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (115, 'Celana Jeans Natus', 'Desain modern', 'umi33@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (116, 'Sepatu Sneakers Illo', 'Tahan lama', 'umi33@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (117, 'Tas Ransel Veniam', 'Nyaman dipakai', 'umi33@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (118, 'Jaket Hoodie Veritatis', 'Tahan lama', 'umi33@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (119, 'Jaket Hoodie Nobis', 'Desain modern', 'umi33@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (120, 'Tas Ransel Alias', 'Produk berkualitas tinggi', 'umi33@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (121, 'Topi Baseball Assumenda', 'Produk berkualitas tinggi', 'umi33@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (122, 'Dress Midi In', 'Produk berkualitas tinggi', 'hairyanto16@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (123, 'Jaket Hoodie Dolorem', 'Nyaman dipakai', 'hairyanto16@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (124, 'Jaket Hoodie Ipsum', 'Desain modern', 'hairyanto16@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (125, 'Sepatu Sneakers Architecto', 'Desain modern', 'hairyanto16@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (126, 'Kemeja Formal Asperiores', 'Nyaman dipakai', 'hairyanto16@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (127, 'Kemeja Formal Aliquid', 'Desain modern', 'hairyanto16@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (128, 'Celana Jeans Illum', 'Nyaman dipakai', 'hairyanto16@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (129, 'Celana Jeans Sit', 'Tahan lama', 'hairyanto16@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (130, 'Kemeja Formal Consectetur', 'Produk berkualitas tinggi', 'hairyanto16@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (131, 'Kemeja Formal Quis', 'Desain modern', 'hairyanto16@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (132, 'Kaos Polos Culpa', 'Produk berkualitas tinggi', 'hairyanto16@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (133, 'Dress Midi Doloremque', 'Tahan lama', 'ophelia59@protonmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (134, 'Dress Midi Expedita', 'Nyaman dipakai', 'ophelia59@protonmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (135, 'Topi Baseball Tenetur', 'Nyaman dipakai', 'ophelia59@protonmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (136, 'Kemeja Formal Nihil', 'Desain modern', 'ophelia59@protonmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (137, 'Sepatu Sneakers Nostrum', 'Produk berkualitas tinggi', 'ophelia59@protonmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (138, 'Dress Midi Quibusdam', 'Tahan lama', 'ophelia59@protonmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (139, 'Topi Baseball Omnis', 'Tahan lama', 'ophelia59@protonmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (140, 'Kemeja Formal Eveniet', 'Produk berkualitas tinggi', 'ophelia59@protonmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (141, 'Kaos Polos Beatae', 'Produk berkualitas tinggi', 'ophelia59@protonmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (142, 'Tas Ransel Similique', 'Nyaman dipakai', 'ophelia59@protonmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (143, 'Tas Ransel Recusandae', 'Nyaman dipakai', 'ophelia59@protonmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (144, 'Celana Jeans Aliquam', 'Desain modern', 'naradi89@yahoo.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (145, 'Kaos Polos Excepturi', 'Desain modern', 'naradi89@yahoo.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (146, 'Kaos Polos Exercitationem', 'Desain modern', 'naradi89@yahoo.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (147, 'Kemeja Formal Voluptates', 'Produk berkualitas tinggi', 'naradi89@yahoo.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (148, 'Topi Baseball Quod', 'Tahan lama', 'naradi89@yahoo.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (149, 'Topi Baseball Ducimus', 'Nyaman dipakai', 'naradi89@yahoo.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (150, 'Kemeja Formal Fuga', 'Desain modern', 'naradi89@yahoo.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (151, 'Kaos Polos Quibusdam', 'Nyaman dipakai', 'naradi89@yahoo.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (152, 'Sepatu Sneakers Illo', 'Produk berkualitas tinggi', 'naradi89@yahoo.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (153, 'Kaos Polos Atque', 'Produk berkualitas tinggi', 'naradi89@yahoo.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (154, 'Kemeja Formal Occaecati', 'Produk berkualitas tinggi', 'naradi89@yahoo.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (155, 'Jaket Hoodie Nam', 'Produk berkualitas tinggi', 'kani82@hotmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (156, 'Kemeja Formal Numquam', 'Tahan lama', 'kani82@hotmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (157, 'Topi Baseball Hic', 'Desain modern', 'kani82@hotmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (158, 'Dress Midi Sapiente', 'Tahan lama', 'kani82@hotmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (159, 'Kaos Polos Repudiandae', 'Produk berkualitas tinggi', 'kani82@hotmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (160, 'Kaos Polos Illum', 'Nyaman dipakai', 'kani82@hotmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (161, 'Dress Midi Praesentium', 'Nyaman dipakai', 'kani82@hotmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (162, 'Jaket Hoodie Unde', 'Nyaman dipakai', 'kani82@hotmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (163, 'Jaket Hoodie Molestias', 'Produk berkualitas tinggi', 'kani82@hotmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (164, 'Topi Baseball Earum', 'Desain modern', 'kani82@hotmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (165, 'Jaket Hoodie Fugit', 'Tahan lama', 'kani82@hotmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (166, 'Tas Ransel Totam', 'Nyaman dipakai', 'luis86@protonmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (167, 'Kemeja Formal Ab', 'Desain modern', 'luis86@protonmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (168, 'Topi Baseball Quo', 'Produk berkualitas tinggi', 'luis86@protonmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (169, 'Celana Jeans Exercitationem', 'Tahan lama', 'luis86@protonmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (170, 'Jaket Hoodie Veritatis', 'Nyaman dipakai', 'luis86@protonmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (171, 'Kemeja Formal Dicta', 'Nyaman dipakai', 'luis86@protonmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (172, 'Tas Ransel Tempore', 'Tahan lama', 'luis86@protonmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (173, 'Kaos Polos Facilis', 'Tahan lama', 'luis86@protonmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (174, 'Dress Midi Nulla', 'Produk berkualitas tinggi', 'luis86@protonmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (175, 'Dress Midi Tempore', 'Nyaman dipakai', 'luis86@protonmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (176, 'Dress Midi Fuga', 'Produk berkualitas tinggi', 'luis86@protonmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (177, 'Topi Baseball Labore', 'Produk berkualitas tinggi', 'najib31@hotmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (178, 'Jaket Hoodie Sunt', 'Nyaman dipakai', 'najib31@hotmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (179, 'Celana Jeans Nihil', 'Desain modern', 'najib31@hotmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (180, 'Kaos Polos Quod', 'Nyaman dipakai', 'najib31@hotmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (181, 'Topi Baseball Culpa', 'Tahan lama', 'najib31@hotmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (182, 'Sepatu Sneakers Sed', 'Tahan lama', 'najib31@hotmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (183, 'Kemeja Formal Impedit', 'Tahan lama', 'najib31@hotmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (184, 'Sepatu Sneakers Illum', 'Produk berkualitas tinggi', 'najib31@hotmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (185, 'Tas Ransel Quam', 'Tahan lama', 'najib31@hotmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (186, 'Dress Midi Dolorum', 'Nyaman dipakai', 'najib31@hotmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (187, 'Kemeja Formal Illum', 'Desain modern', 'najib31@hotmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (188, 'Topi Baseball Provident', 'Tahan lama', 'talia73@yahoo.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (189, 'Jaket Hoodie At', 'Nyaman dipakai', 'talia73@yahoo.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (190, 'Celana Jeans Explicabo', 'Produk berkualitas tinggi', 'talia73@yahoo.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (191, 'Tas Ransel Repudiandae', 'Desain modern', 'talia73@yahoo.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (192, 'Kaos Polos Unde', 'Nyaman dipakai', 'talia73@yahoo.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (193, 'Kemeja Formal Nihil', 'Tahan lama', 'talia73@yahoo.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (194, 'Dress Midi Praesentium', 'Nyaman dipakai', 'talia73@yahoo.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (195, 'Celana Jeans Laborum', 'Nyaman dipakai', 'talia73@yahoo.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (196, 'Kaos Polos Nihil', 'Nyaman dipakai', 'talia73@yahoo.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (197, 'Topi Baseball Dolorem', 'Tahan lama', 'talia73@yahoo.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                         VALUES (198, 'Sepatu Sneakers Porro', 'Produk berkualitas tinggi', 'talia73@yahoo.com');
-- Total produk: 198

-- INSERT INTO gambar_produk
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (1, 'produk/e5124bfa-2793-4ccb-8d97-6d21c4586563.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (2, 'produk/d28a3a40-fd41-4a81-8ee8-b412e4d05181.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (2, 'produk/9ffb610f-02d3-49f5-86c3-1ada1c32f2ca.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (2, 'produk/1d0c362c-866e-4ab2-a207-7cf74cd789b4.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (3, 'produk/2bc7879a-c2b4-46e8-b282-e37ae72477f5.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (3, 'produk/a3e905f8-31c9-4250-ab5a-bd0ce142342d.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (4, 'produk/eb11ed1e-19ca-4b34-9908-a8401a96f8c3.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (4, 'produk/8ec8676a-fe6b-4905-9e5f-ba9c64f3f2e7.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (4, 'produk/3b07111e-5039-40f8-8981-da1aa8048c9b.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (5, 'produk/6bc05012-ab36-4f24-af23-244f700ced73.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (5, 'produk/df968aa5-5fc9-4661-bf1c-a7bd1e8b3a8f.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (6, 'produk/3a5dcfc3-7f2f-4379-8476-a371f36210a1.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (6, 'produk/ddeefd43-f937-41d9-a477-e1896c9a8f24.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (7, 'produk/32ce58e7-8098-4847-bb48-cc7bf8356c85.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (7, 'produk/11430715-1df4-45da-9aff-1acf4b279cb2.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (8, 'produk/9dd6a568-ddb1-4fef-b18d-453d97d1c3a5.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (9, 'produk/21f033c1-4cc7-4d1b-8e28-91e501a3468c.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (10, 'produk/9a0e85c2-955b-4454-8e64-446c2c23b8fa.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (11, 'produk/2e660add-33dd-4abd-8ba7-ea69f17ec961.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (12, 'produk/abe5c3d2-542c-4d54-a000-c0f447c7538a.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (12, 'produk/6b71d36a-2694-4eab-afcd-14301f50eff6.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (12, 'produk/3c6c577e-c717-435e-9b6b-0ce365f1f54b.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (13, 'produk/e0ea1f8a-6475-43f8-a7db-774bc51933e7.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (13, 'produk/f349fd9a-a2d8-4573-88c8-84bb448afcd2.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (14, 'produk/3babbca3-e61e-4ce3-bed1-d13712d04627.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (14, 'produk/9c97dc6b-6472-4ed6-b46f-6e072ce46497.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (14, 'produk/730ae57b-2f3f-44bc-acfd-83df32f9bdb9.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (15, 'produk/96c27cc3-f7d4-429c-8fb4-72b3dbf907c9.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (15, 'produk/4dabaae9-96ac-4828-9574-eb1c15ca6aeb.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (16, 'produk/10621e4c-de2e-490b-b347-0364858f897f.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (17, 'produk/b7a18a6d-0ce9-4aa3-b7eb-60a05959e205.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (17, 'produk/46018382-c0b6-47ed-91a6-cf79b4ba0e6e.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (17, 'produk/efd24220-3bf6-43b3-8a5b-d2d387e925a3.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (18, 'produk/514d273c-defd-42bd-8455-572e00a2c32a.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (18, 'produk/84cc37b1-93dd-48f5-9c46-3affb856c31d.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (18, 'produk/c8f09b35-0d6a-4c37-bf59-3993f3f6f81b.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (19, 'produk/a1f7e9db-8cee-43ac-819c-d86ce899650a.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (20, 'produk/d8f23e15-4915-4cb7-8870-5034a190bee2.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (20, 'produk/65ce5fe8-8378-490b-96d5-a8911c373f51.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (20, 'produk/d0872248-d3ee-4fdb-b9a4-66b22336fb9d.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (21, 'produk/fa4af328-0f2c-47d9-9875-3177a7de42e7.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (21, 'produk/b63d43cf-42b8-451d-a8c7-e59f8898bebc.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (22, 'produk/d3fba470-2207-4b92-8bc6-67bbf6ab2bf3.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (22, 'produk/19e6d271-3c4f-4908-8096-dc6986003a35.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (22, 'produk/4e03551a-941b-422d-9aa3-2a3559b5a2e3.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (23, 'produk/1a4e2563-853b-4293-9cbf-e4378c991ffa.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (23, 'produk/ce5951dd-3bc0-46ee-95ac-8aff7d81edd2.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (24, 'produk/b6a8b614-ac74-436b-b5d3-bd0b5ed47f25.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (24, 'produk/88b0519d-4ffb-475a-93f3-4f1883e93544.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (25, 'produk/4fee374f-0ebe-4bf5-beb6-cbec563ed2a2.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (26, 'produk/a4f741b4-c8b7-4927-93b1-3f7fb6b8b586.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (26, 'produk/011addf2-ec4f-4d83-89ea-e47dc35deb76.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (26, 'produk/b9e0999e-c49f-40e8-b810-57c599eb62cc.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (27, 'produk/345a9302-b99a-451c-a2e6-d20e27c7f8fe.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (27, 'produk/b322e2a0-7a4c-44d8-900b-69925622e072.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (27, 'produk/4f7a7d8c-a2fd-4847-aa50-7f2643999619.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (28, 'produk/929a3840-e284-4356-9a07-c3c30dcd93ed.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (28, 'produk/0b4f3d2f-84a0-4f18-8686-f9af2878aa56.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (29, 'produk/95c16541-fafe-4b33-ae91-5962ff620ed0.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (29, 'produk/c9a0b678-077d-479e-a7d6-b2bef20ed698.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (30, 'produk/49489c9f-9ff8-4284-a21c-99d86db85dee.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (30, 'produk/d25a4750-1130-4d3f-8d2b-f34975a6edbe.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (31, 'produk/9d3ccbf3-4ead-4341-b269-7330ce5f8359.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (32, 'produk/a58e5939-6c05-4075-ab92-386fa274bac6.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (32, 'produk/baf62ec8-8b4b-4b87-9169-705a68e22b96.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (32, 'produk/d1449c54-72a3-416a-821b-26b25783322a.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (33, 'produk/55513c54-4ccc-499c-ad50-e4ec63760198.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (34, 'produk/2af1ffef-e1e8-474b-9264-9c9a9b9da1c6.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (34, 'produk/62498453-0bdc-4ed7-b493-4deda8bd2997.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (35, 'produk/f1917791-c3aa-4bf6-b5b5-e52d410c9dd4.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (35, 'produk/735cf8ac-f49b-4111-95bd-1887636c0874.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (35, 'produk/5487d925-c5ae-42fc-a27f-fe93d6340de1.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (36, 'produk/9ac3e296-31a9-48a3-a80d-bac3cc60bcbb.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (36, 'produk/0c323df7-1556-47ed-aa80-1aca5873f915.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (37, 'produk/0dc846ad-3c31-42e7-848d-426a644951e3.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (38, 'produk/f6d03285-1c8a-469a-8b0a-672a1a658add.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (39, 'produk/5003a6b3-7d8c-4d66-9243-da22c07a8e6b.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (39, 'produk/4483fc80-e1e3-4816-80cf-dcb4cbe04368.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (40, 'produk/6256fc16-9478-46f4-817c-635c218e22f2.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (41, 'produk/2c09b334-6295-4791-88fb-ce30db7f88de.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (41, 'produk/de058424-5f21-4a2d-b96c-937e8eeec97b.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (41, 'produk/76b13c0a-7960-4a49-9e32-15377457ba52.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (42, 'produk/9ac7e771-ca5b-4fb7-81b6-fa03025a1280.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (42, 'produk/a8a47b6f-5d69-4a77-94a7-0d94c7ca2f30.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (43, 'produk/b5bd45f9-8264-40fd-a7f3-cf5ed5057a69.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (43, 'produk/918d6d1e-bfa4-47b3-bc5d-ec1c0b18e89f.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (44, 'produk/37a8dd72-5cfd-4011-aab1-2cb9c33b65bb.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (44, 'produk/5e7a0bfd-6e8f-431a-9d47-4277777dc9e5.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (45, 'produk/195ca7c5-d729-4033-8c24-6b3de63e5c99.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (45, 'produk/e385d751-a7a7-4a70-9573-874c37874aa2.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (46, 'produk/f50ec701-52f5-4699-a25b-c2d185072272.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (46, 'produk/cbf725b5-53ce-471d-ac47-b3b4c6d9dfbc.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (46, 'produk/5e2f5a4d-005a-42ac-88dd-f2bb86d363f5.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (47, 'produk/229c436b-ad4b-4bbe-97f3-1282535a59d3.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (47, 'produk/29ae57f6-4a3a-4f42-a377-f597460a6ea7.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (48, 'produk/0fbc5444-5942-4378-9bb3-bb1333e12edf.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (49, 'produk/46e49d8c-b8bf-460e-b24e-7dde6254e6eb.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (49, 'produk/9f0e647b-80dd-4a82-8147-80c538b19618.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (50, 'produk/645d3b4f-7b10-4996-8009-05087ba27e33.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (51, 'produk/ede9bfdb-072f-4626-9c04-e724026f02ab.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (52, 'produk/aa573004-7664-4a69-b6e7-e9dd77c5bc09.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (52, 'produk/02d0e038-1b93-41f9-b525-aeddb3c973ee.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (52, 'produk/d228f895-d952-4d80-a13b-de04b0042c87.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (53, 'produk/95965a25-a4c2-44d6-8a60-c825dccd2a0a.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (53, 'produk/27f1271b-74ef-41f5-9fe4-8b2ef12dbb93.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (53, 'produk/8c401971-93b8-4e82-9d13-d436c24ca057.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (54, 'produk/77184e2c-4843-4e19-a2ca-732c4bfccac6.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (54, 'produk/6c411310-f9fc-4610-afd8-21b8e81d3bf5.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (54, 'produk/c2640b36-19bb-43e4-bb19-722e69f32f53.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (55, 'produk/f990b4d6-619b-41e9-aacd-909bc1fd5206.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (55, 'produk/b8977ddc-5b04-452a-961f-67bab637348b.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (56, 'produk/e97ae008-b56e-4872-b24c-a862022a4884.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (57, 'produk/4a6a92bf-2839-4785-8b4d-b531f76e5a81.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (58, 'produk/1af69a3a-5b5a-4d27-9fd2-d55de350b68f.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (58, 'produk/eed265db-a3c9-4264-8a4a-971a949ee62c.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (59, 'produk/71d6afff-6e4e-42be-a4e0-a017fc27ad93.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (60, 'produk/7e52b351-7b7e-49bd-800e-d4737de34852.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (60, 'produk/0a9453f9-f132-4b6c-bc4f-d1cabf82bdd1.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (60, 'produk/b0277079-f762-40d5-b1cc-f7361c389d34.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (61, 'produk/f3e81582-0860-422b-a291-b878fd858171.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (61, 'produk/cf048f42-5501-4024-ac60-80ab37623e46.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (61, 'produk/f904fb96-c136-4c88-89a6-14b1694ae62b.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (62, 'produk/05e23e33-00bc-4eeb-ba90-6bd3ede90c03.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (62, 'produk/6d7fb760-91a1-4cd9-863c-b7ab5fbd0260.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (63, 'produk/52ddb44d-e7e7-4665-8f48-14635dc414bf.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (64, 'produk/8090ed8b-3e93-463f-a579-648c6f2d1eb1.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (64, 'produk/7f57fe38-27c6-4b14-b62f-8ea4fb766b5d.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (64, 'produk/6d7ddbbc-c79e-4e42-becd-c24566e514af.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (65, 'produk/cf7f9d80-4f61-45df-abca-a156ad729bb0.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (66, 'produk/6b97dca1-cf4e-4866-bd42-130d311459bb.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (67, 'produk/897eac78-3cf5-4e05-9765-fc1e276b485e.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (67, 'produk/865470f9-722e-44fa-8bf6-1fe187093c84.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (67, 'produk/fb3a9118-b3ea-497c-b155-d990b79d2ec0.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (68, 'produk/b103535f-c0d4-4af3-8ab1-8121499b2ab3.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (69, 'produk/bd7dd242-a1c0-4562-840f-75543121a105.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (70, 'produk/02f78f03-f15c-4c2b-ac53-f542258be8bd.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (71, 'produk/488bbe35-dc25-4846-bffe-124bad170ff0.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (71, 'produk/ff446716-cc0b-4810-a62d-a33509dac635.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (71, 'produk/4b8c0a0c-097a-4296-a319-e5e565685a5a.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (72, 'produk/88310c75-d4d6-4ae7-979f-a8f865e0557f.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (73, 'produk/4538e07e-6a9a-476d-923a-e311eacd04e4.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (74, 'produk/29e16abd-e809-4d14-8601-47fe22859f31.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (74, 'produk/771f0f11-8330-49c8-81c8-2b03eee8ae33.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (75, 'produk/21e3c200-8f62-4539-977b-4fdd8e5e9fe4.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (75, 'produk/4f14405b-a69a-4008-98df-1ec45831fa23.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (75, 'produk/a7d32aeb-274b-4764-961e-9f6a278509d7.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (76, 'produk/b17697a4-1235-4b3f-a37e-87227011293b.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (76, 'produk/0dc837d5-1058-48b8-926c-4860d2742933.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (77, 'produk/ae22ddd3-307c-4070-97d0-2d82a39b21f5.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (77, 'produk/6ec28c3a-ee05-41ef-a02e-a9cde96696b9.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (77, 'produk/b519e6a1-0ce6-4cea-91a2-61b231fa3c3a.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (78, 'produk/dafa07e4-1db0-4434-9822-03566a988dcc.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (79, 'produk/e1838342-ed06-4184-ba7e-d5520967244f.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (80, 'produk/116d4520-b6b1-473f-82fe-56906df7a4e5.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (80, 'produk/0078a87a-035e-4bc9-a6d5-ad8356d72c20.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (81, 'produk/684e0f59-f663-41f3-a422-d1249ff16dcf.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (81, 'produk/9c9abfc4-2a12-4fb3-9f90-c6179ecb8cfc.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (82, 'produk/a586a857-5ee0-42d8-9c77-f30c5a83d110.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (82, 'produk/14edc8bd-2906-40bc-8dcf-55c7e08e7682.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (82, 'produk/84dfc359-c068-483b-8578-6217ebe56b08.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (83, 'produk/e784500e-c110-4438-b23e-b6421feff62b.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (83, 'produk/656b3a64-0d4f-4bb5-a171-0b03ad9d88dd.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (84, 'produk/8f535ac0-6a13-4ac1-a69e-9ce82c624aa2.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (84, 'produk/dcdc9441-2958-4fd0-8604-864e0c800bb2.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (84, 'produk/20c119a7-f2ba-4bc8-b72a-8717e5f93ec4.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (85, 'produk/a42bbca5-d279-4789-a8b8-fd100dfc54dd.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (85, 'produk/a58fcf50-8e6e-42c0-928c-346c00ba17f2.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (86, 'produk/308f0eac-7613-4e9e-a67d-e0add21ac3c4.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (86, 'produk/73cb27a5-403b-4344-b742-ba33046f91e9.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (87, 'produk/0b35776b-e207-42c7-b777-042697661666.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (87, 'produk/99522237-2ac6-46d4-b46e-ab30c22b601b.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (88, 'produk/8cc0fe91-b28c-4682-b0f4-df633344b53f.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (89, 'produk/23b92ff4-8f01-40d4-85d7-7fcdda1a3a17.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (89, 'produk/915f5430-aa72-42f0-adb4-694780967fa6.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (89, 'produk/731f1b00-1eb9-4219-8e0b-7a4e751e17de.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (90, 'produk/3d57cdd4-f428-4866-9823-9aea06c39b8f.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (90, 'produk/f6620094-4988-4708-b163-766c73157b38.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (90, 'produk/5bee6392-e1a6-44d1-b65e-657e81dcd7d1.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (91, 'produk/a8221789-a7cd-43fc-bb07-c636acfca7f9.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (91, 'produk/7a36fbc2-2de9-41dc-a8c3-bb560f63e0e2.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (91, 'produk/8a4aaa42-8b8d-42f1-913f-6f4cce0e5a26.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (92, 'produk/4a20aeb1-d5f2-4ce8-b826-02f0ad75052b.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (93, 'produk/aad78a6e-6b1c-42bd-9de2-5d9aeb8a7609.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (93, 'produk/50b66ab7-e16f-4c86-8db9-bb36cda8fd6a.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (94, 'produk/588da288-0cf5-4a96-8a15-766882c24f6f.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (95, 'produk/9bdcbde0-9ec9-41c7-aadc-0bf056ce648d.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (95, 'produk/dfbe37cb-c84e-46d5-b92c-15722061ce68.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (96, 'produk/d9e19d52-2c16-4ca3-8799-3677fd971a63.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (96, 'produk/073c23e9-ba8d-436c-8a06-add7287af660.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (97, 'produk/7c0a1153-25c5-46d0-897b-4090973b6fd6.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (97, 'produk/171bf378-761d-4959-8768-fd9dfdfe26cc.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (97, 'produk/dd4be552-5ba0-4a78-b961-98f507baffdb.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (98, 'produk/15119e7b-25cd-4f9e-9c41-47aeb5f7afee.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (99, 'produk/bcd1b710-48ff-4735-b6c9-21042649d87b.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (100, 'produk/054f6ffb-63c0-42f3-a298-da1eb5641075.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (100, 'produk/5e912a2b-d1c8-4aa0-9a2f-83d3602238cf.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (101, 'produk/78df4aad-b94d-4f3e-9224-add2bf7aacbd.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (101, 'produk/68dbe783-f6a3-4ef1-a392-7336ad0dafc2.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (102, 'produk/6458194c-81cd-4971-b659-a28011adf579.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (102, 'produk/0242926d-c3c3-4d6b-9df3-99b50eaf9ab5.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (103, 'produk/4c425451-3f99-471a-9420-b5f510122040.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (103, 'produk/ad962bc3-658f-4705-9da2-2a68403c9570.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (103, 'produk/7fcaefcc-47bf-4315-b0f4-430482dfb090.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (104, 'produk/72fde64e-9a7d-4d39-9240-7a994c6a7118.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (104, 'produk/46bac722-27ac-48d4-b114-e3b952a951ea.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (105, 'produk/ca8f0f1e-c668-489b-8c72-aa97a3bcb7b0.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (106, 'produk/a24ebd47-a10b-4bcc-992b-4c686e0fb605.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (106, 'produk/f0882493-141b-4d3b-b555-2dce71be0376.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (107, 'produk/f06d834a-e253-4bbd-9b2e-9cb459879ad6.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (107, 'produk/5fbd7b43-6c01-4a28-bd8a-59d35bd295a2.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (107, 'produk/a85ecd3d-2cd1-4032-b44a-0f2d895d9eb0.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (108, 'produk/1b42a12c-a213-4349-8224-8feb8191e20b.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (109, 'produk/234036f3-3ef0-4d05-8ff9-9ae758d95c3b.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (110, 'produk/e02d7276-061d-4ed2-89cb-b114f9bf7752.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (110, 'produk/80673f75-ab62-47b6-931e-2a61ddc986c9.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (111, 'produk/a18eaf9b-f611-460a-b388-7d7f13498a4a.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (112, 'produk/64e18543-ae70-4fd4-967f-86caea9ca9c8.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (113, 'produk/4a6b58c7-3a48-4f1e-b4ee-213ed2d4a3f0.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (113, 'produk/e124041e-24fa-415e-82d6-ddef56b83ced.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (114, 'produk/51006d85-4f48-466b-96b9-08184eb78767.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (114, 'produk/855f10c1-1c32-4900-a5dd-3052da3fe609.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (115, 'produk/3843f119-6ac7-4b2d-a801-c3075aaa0a6d.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (115, 'produk/96d34cf1-f789-4ccd-a14c-87d3da81370b.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (116, 'produk/0ee7cc6e-909b-4c7c-bd33-9886195b8711.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (116, 'produk/ae316d3c-08a9-4e85-a5df-7c7d3d8c6675.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (116, 'produk/1a2ee1ea-18a3-408c-a3ee-1e76a135a6c7.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (117, 'produk/56a59547-30ff-4764-8d8d-eafea09bcf29.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (117, 'produk/f63e8b70-dd35-4165-bbf4-3e93df7fbebb.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (118, 'produk/64165719-39c7-4d0a-b970-a659c375deaa.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (118, 'produk/e98cddd8-89d1-439a-8d3e-9d07bbdf58fa.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (119, 'produk/a00ff5b8-1451-4715-be97-74b5816d4edc.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (119, 'produk/4dd63e79-c7fe-48a9-8bef-06d97eb1e1dd.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (119, 'produk/aac11185-8b9a-45fe-a370-e8bb525b96e4.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (120, 'produk/f32a0f2d-ffa1-4c34-883f-3b9b47dfac40.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (121, 'produk/e76e9f14-0982-40c1-80c2-6dfd37a03c40.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (121, 'produk/e0014b13-c9d6-4b26-942f-e0d79f890092.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (121, 'produk/05dccab1-6c35-4ed0-93dd-64aa34d97ecb.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (122, 'produk/c402c6b4-75f4-49b7-b519-cb1c85c27fee.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (123, 'produk/fb029883-7ec3-4369-abca-e8ff1b998be1.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (123, 'produk/eeafcf76-41dc-498f-8524-2bac5a892817.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (123, 'produk/17602b6b-8207-4fd0-8be3-f25e6a804129.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (124, 'produk/f1494fdf-af4c-4686-a2de-04f81053e9bc.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (125, 'produk/e534cce9-bd9b-4d74-ae79-82b5c70e6387.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (125, 'produk/b7557fd8-95ce-46ef-9010-4597e2c93dd1.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (125, 'produk/70e6e66f-bc13-4067-aab6-bbb7c103d382.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (126, 'produk/8af350b4-1ef8-4e40-8bea-0ab9428ca7b4.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (126, 'produk/90e0ca0e-6ce8-4d83-b311-563e692a592e.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (126, 'produk/085b6d43-32ff-44ec-ad3b-7fe79dc02e25.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (127, 'produk/014e104b-9cb7-424e-8e69-2ad7650676aa.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (128, 'produk/3ecf8888-6b74-4504-a6e1-c623d6ea7672.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (129, 'produk/b6c5a84e-f12e-4aa8-9d79-6db2c888b0b1.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (129, 'produk/d67777e5-24e1-4485-9866-3bc74919be88.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (130, 'produk/de9aa096-5743-464c-8505-c3c3e381e45e.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (131, 'produk/932084e4-af6b-47d5-b70c-74b4d1125855.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (131, 'produk/bd818623-f46e-40cb-bb57-92a5eade9b60.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (132, 'produk/955910b4-283b-450d-b0db-378215e53674.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (132, 'produk/efe9f530-13c7-4f04-8ffd-899c19a68edb.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (133, 'produk/73d06d01-1423-430f-a55a-8a2d4330d1b2.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (134, 'produk/a7388e7c-50ed-4752-863e-d24abacfd016.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (135, 'produk/727f1c38-fd04-4596-8eb2-236c2dd33c53.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (135, 'produk/7a9e2285-e266-4cdb-8156-b95d17f5085f.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (135, 'produk/f9fb3434-ab17-4c70-8ed4-d3f581696a9f.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (136, 'produk/dbe2b24e-a0f4-41bc-927c-c693fb6f2256.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (137, 'produk/fc96d36b-856c-408f-b619-b6b6ba844824.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (137, 'produk/7b7d1f14-bcd1-4392-8d99-bc5762f3ae53.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (138, 'produk/18959d39-ddfb-41f6-94e2-0e5fd96a6931.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (138, 'produk/e40c752a-ad42-4240-aff3-b3e1f49f1a81.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (139, 'produk/a0655812-d714-4a44-92e6-b56b7af7bff3.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (139, 'produk/8998cecf-eece-451d-bef2-b73de8d22627.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (139, 'produk/bb8fb3d2-68f0-4b9c-befb-6cbfeb170781.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (140, 'produk/cd99ba59-6118-4185-a231-ba5bad7ea2fd.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (141, 'produk/f2f78479-165c-43be-9169-d9ab678ad75a.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (141, 'produk/0d7e2021-db24-4613-8cf1-26ca26331e29.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (142, 'produk/66391a1f-5db6-46b8-be69-d84257c66d88.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (143, 'produk/1acb21b0-f671-40b0-87d5-f2f6beb4ea03.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (144, 'produk/fcfbd7bb-6ede-4f5c-b49e-599ede14caf8.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (145, 'produk/14a3429b-d657-4798-89e9-d47103c70c5e.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (145, 'produk/dd4acc69-9680-431d-989d-4240ed25f049.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (145, 'produk/453edbe3-f2f7-4998-bc8a-d8dc7b9b4dd3.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (146, 'produk/9bc0d7d0-c50c-4690-9ce0-0b468773f44e.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (146, 'produk/2056bf3e-e5dd-4a5d-ac58-7ccb242c2c10.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (147, 'produk/2b26ce83-76bd-4141-83a9-99011a9a6c8c.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (147, 'produk/61ae3c6f-2d8b-40fc-bc7e-dcc0489761b6.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (148, 'produk/cc5fdb05-87d4-4ce3-912c-d4cb1e3bb021.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (148, 'produk/0b0d6e82-7ee9-4ee3-a0dc-84dc1f1dc632.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (148, 'produk/1ec3b07f-486c-4e25-bcef-c4da2bd944d4.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (149, 'produk/d13550a0-c757-4df4-9b10-a6ff5edf3cdc.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (150, 'produk/fab1fdc7-35ab-442e-b5e8-8f03c2e32026.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (151, 'produk/9fa6f9f8-459c-4e00-b0fa-e62bf4c35ff9.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (151, 'produk/3b7c148e-0e87-42db-8104-f6f3df216729.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (152, 'produk/44b885a9-782c-436b-940f-e4d6c962696e.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (152, 'produk/50a7ac43-395d-478e-9b96-44335b14a1a3.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (152, 'produk/7edc3eab-09b3-42b4-86bf-be9b7ff064b3.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (153, 'produk/2ff9e1a9-2405-4f64-9b41-3f4d1b9c8e65.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (153, 'produk/d6bd6a22-0030-4746-bed1-fb1a37ff5df4.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (153, 'produk/072f40dc-7b04-43fe-90f9-dec7c5fa503c.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (154, 'produk/b0490d1a-b00f-4c46-a4fc-73ab8fec0711.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (155, 'produk/b8b01c49-2936-4095-9866-5743f3be7af6.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (155, 'produk/ee40de64-afa4-41c6-af50-de4aafbb9b10.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (156, 'produk/90bafe9a-3973-42c4-8c35-a766b691ec07.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (157, 'produk/d7845bb8-0e2d-4880-a240-f65bfe99f68c.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (158, 'produk/eb4eafd2-d4d2-4b2d-88c6-dac02ead23ce.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (158, 'produk/1bf4f787-35c6-4ec5-b184-66c6b5d21f89.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (158, 'produk/eddbd26a-22f2-4050-8838-462987516993.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (159, 'produk/e9b8eebc-3031-49fd-9915-14a8bf9c62f5.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (159, 'produk/240196a3-95ff-4e22-9269-58075738f8a9.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (159, 'produk/92a4b50f-338f-42a2-91d9-f086994362ef.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (160, 'produk/6cf8f432-56e3-4923-9af2-4df390a511ea.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (160, 'produk/067bb3a5-b5cb-4f52-a26e-9c4d12ca2dca.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (161, 'produk/16deb02c-fc60-4455-bfda-b0aa0ab3d2f9.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (161, 'produk/9affdbf8-023f-4d91-8313-acc40f947040.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (161, 'produk/a86b9d30-0ff1-45d3-bd0a-c12e2d620f77.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (162, 'produk/2afcd89c-04c6-4022-b760-b8c91f47205c.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (163, 'produk/8d5a1871-d8cf-45e2-b428-b9068c625733.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (163, 'produk/8a96fdf1-f572-4ea3-a3b0-a39c7a183ba7.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (164, 'produk/11a8bfa5-5f39-4d82-854c-a323a3828ac1.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (165, 'produk/c5f854c8-d851-4ecd-9681-684974b1a483.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (166, 'produk/62bc1e37-cd79-462a-8895-66dd44bb6449.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (166, 'produk/aa5116d0-57cd-4633-b608-571c6df51d13.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (166, 'produk/2b048319-b87e-43db-8231-ca4e873fe9e4.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (167, 'produk/d36dc165-f204-488d-90f0-6fdbcb9c2cb0.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (167, 'produk/981dd2cb-9ea9-4576-bb88-fe0fcab89380.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (168, 'produk/2d6a07dd-af21-4a44-b400-a7e52fcd1133.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (169, 'produk/b51478f2-eaa2-4606-bb8f-7afe5eb337a8.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (170, 'produk/f31ba183-d4c8-481b-96e1-031c1710726e.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (170, 'produk/c8b6a361-dffc-4d4c-b181-9324aaaf6217.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (170, 'produk/2b18735a-adfe-4cbf-858f-8af81e3c075b.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (171, 'produk/61be0196-7ae3-4117-b644-81028ea9401b.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (171, 'produk/ba1d836a-ca67-4d50-afe9-895910bbb7ca.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (172, 'produk/4278bca2-0218-420b-8686-e44de27b0cfd.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (172, 'produk/d1bdc457-205f-49a5-b2b7-7a6359c73c4f.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (172, 'produk/03a3132b-2b67-4992-a364-4643b41610f7.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (173, 'produk/786800e6-bd41-4853-b94a-288c6bb8ee4d.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (173, 'produk/0f9f6a4d-dbd4-43b2-a92a-ca1b6174fa62.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (173, 'produk/ef4100b1-486e-42e9-a682-2693775e6542.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (174, 'produk/f65040dd-b65b-4114-8df7-27c2aa9db923.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (175, 'produk/62d1b714-2dec-4f7a-83ae-9bb1a6bde090.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (176, 'produk/5932979a-0b78-47a9-8034-ffa49f7a8f76.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (177, 'produk/43e6d123-c216-452b-bee2-6ea2802d4158.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (177, 'produk/2da5dee9-0413-4ecd-b316-f53cce13ed3e.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (178, 'produk/2238692d-7e51-4513-a2e4-19ba721f4731.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (178, 'produk/094a6601-ca03-43c3-a5b0-4e4f06ebec32.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (179, 'produk/8dd5db1d-f095-42f8-b5aa-8ab7ab6fb8e6.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (179, 'produk/522167a9-c7a7-4811-8c22-e0330cf0648f.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (180, 'produk/115f12db-b466-46e1-bd29-0460ca9b6fbd.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (180, 'produk/413000b4-ec3d-4676-a14c-d8a4afa6711b.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (181, 'produk/93182daa-87a3-482f-8573-ba80f5447149.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (181, 'produk/3cbca889-143a-4dc0-84ca-561aff29c940.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (181, 'produk/695b04e4-bc58-4723-990d-b0e584dbee3f.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (182, 'produk/7c25c01d-b19f-4869-b38b-9376ca3bcb28.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (182, 'produk/17075469-8e63-43d2-b208-4a6f1f9eb66f.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (182, 'produk/e6b7619e-b901-4b83-8125-f9a37962545a.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (183, 'produk/4e62f572-69a4-45b3-8583-bda97695c731.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (183, 'produk/c41ccb17-7db3-4dfe-9a75-b67d54db26cb.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (183, 'produk/b194c0dd-2947-49d0-9bb2-d8357e2dfcda.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (184, 'produk/7a19dc07-9a7b-421d-a083-800263231272.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (184, 'produk/0a6d2187-da13-4fd0-baa8-f34c1520c41d.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (184, 'produk/f833f7ba-6c21-49cb-84b6-89dcd1844163.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (185, 'produk/a3a0fedd-a3c9-4d25-9346-327c4f2555ad.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (185, 'produk/d01d8ee0-f694-4de7-a03c-2aa1843181a6.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (185, 'produk/413d6732-3598-4b75-bdfe-9f85d7bd5336.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (186, 'produk/1eec5d9f-0bcf-40f6-8ab8-36d61dee3993.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (186, 'produk/c20a1ff1-1abb-46e7-841c-0f547db12b29.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (187, 'produk/d23e1f9e-0151-44a3-ab2d-3dd4fb808bd4.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (187, 'produk/3f59e7cc-5c6f-46b6-925a-f9d91a921d14.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (188, 'produk/0c5e14f1-a48e-444e-bafb-8c0ad217af4b.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (188, 'produk/6eaa65b1-909e-4fe0-877b-fe907a228d0b.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (189, 'produk/39925b44-f6cb-4e0b-912a-a8bbdef451c5.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (190, 'produk/5017fa56-1e0e-4231-a73a-f7b4d05faffe.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (191, 'produk/3555382a-81e5-4a24-a7f7-ca0419fbde15.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (191, 'produk/8d3d306b-74e2-40a9-b3bd-a009a554938a.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (192, 'produk/42225797-5a52-4375-be29-a8329541c3ae.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (192, 'produk/a6eaaaf7-4339-4cb5-a1b6-2d4c33ce3a69.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (192, 'produk/ccbd2229-92d5-4424-ae4c-e28ce0f297de.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (193, 'produk/2ae1237a-1271-49ef-989e-176386007755.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (193, 'produk/9576f1fc-9b75-4272-bfc2-6fe54a23834d.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (194, 'produk/45b5c5d0-0256-4406-8a53-e41fd45bef4f.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (194, 'produk/54907c1f-1b71-49ef-abf2-433e7593d3c0.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (195, 'produk/5991bdc7-8c68-477d-aebb-956cd5ab1f0e.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (195, 'produk/06bd85e9-14c6-4b9d-8925-d62123defc3e.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (195, 'produk/92d0b4db-1cb7-488b-923a-fafe7b277598.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (196, 'produk/bb942157-b533-4eb0-b2bf-069db920e7a3.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (197, 'produk/c928af2c-072a-4c38-8aca-f425e0cfe3b0.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (198, 'produk/91e3587b-04ca-4e11-8f6c-270f14a3724d.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (198, 'produk/01d529d7-3abd-4011-82ec-0269eb582e4e.jpg');
-- Total gambar_produk: 385

-- INSERT INTO tag_produk
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (1, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (1, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (2, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (2, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (3, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (3, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (3, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (4, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (4, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (4, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (5, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (6, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (6, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (6, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (7, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (8, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (8, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (9, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (9, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (9, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (10, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (10, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (10, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (11, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (11, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (12, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (12, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (12, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (13, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (14, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (14, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (15, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (15, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (16, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (16, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (17, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (17, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (18, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (18, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (19, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (19, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (19, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (20, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (21, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (21, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (21, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (22, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (22, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (23, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (24, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (24, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (24, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (25, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (25, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (26, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (26, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (27, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (27, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (27, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (28, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (29, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (29, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (30, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (30, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (31, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (31, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (32, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (32, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (32, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (33, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (34, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (34, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (34, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (35, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (35, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (36, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (36, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (36, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (37, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (38, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (38, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (38, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (39, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (39, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (40, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (40, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (41, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (41, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (42, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (43, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (44, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (45, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (46, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (46, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (47, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (47, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (47, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (48, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (48, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (49, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (50, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (51, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (51, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (51, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (52, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (52, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (53, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (53, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (54, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (54, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (55, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (55, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (55, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (56, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (57, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (58, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (58, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (59, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (59, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (59, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (60, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (61, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (61, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (61, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (62, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (63, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (64, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (64, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (65, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (65, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (66, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (66, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (66, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (67, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (67, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (68, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (68, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (69, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (69, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (69, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (70, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (70, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (70, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (71, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (71, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (72, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (72, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (73, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (73, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (74, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (74, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (74, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (75, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (76, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (76, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (77, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (77, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (77, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (78, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (78, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (78, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (79, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (80, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (80, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (81, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (82, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (83, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (83, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (83, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (84, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (84, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (85, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (85, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (86, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (86, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (86, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (87, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (87, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (88, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (88, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (88, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (89, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (89, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (90, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (91, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (91, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (92, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (92, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (93, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (94, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (94, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (95, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (95, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (95, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (96, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (97, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (97, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (98, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (98, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (99, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (99, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (99, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (100, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (100, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (100, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (101, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (101, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (101, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (102, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (102, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (103, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (103, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (103, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (104, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (105, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (105, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (105, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (106, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (106, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (107, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (107, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (108, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (108, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (109, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (110, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (110, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (110, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (111, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (111, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (111, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (112, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (113, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (114, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (114, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (114, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (115, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (116, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (117, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (117, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (117, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (118, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (119, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (120, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (120, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (120, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (121, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (121, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (121, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (122, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (122, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (122, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (123, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (123, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (124, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (124, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (124, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (125, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (125, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (126, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (127, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (128, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (128, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (128, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (129, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (130, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (131, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (132, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (132, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (132, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (133, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (133, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (134, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (135, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (135, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (135, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (136, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (136, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (137, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (138, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (139, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (139, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (139, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (140, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (141, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (142, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (142, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (142, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (143, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (144, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (144, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (145, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (145, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (145, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (146, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (147, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (147, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (148, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (148, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (149, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (149, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (150, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (150, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (151, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (151, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (152, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (152, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (152, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (153, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (154, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (155, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (156, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (157, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (158, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (158, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (159, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (159, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (160, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (161, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (161, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (162, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (163, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (163, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (163, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (164, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (164, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (164, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (165, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (165, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (166, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (166, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (166, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (167, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (167, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (168, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (168, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (169, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (169, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (169, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (170, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (170, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (171, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (171, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (172, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (173, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (173, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (174, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (175, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (175, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (175, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (176, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (176, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (176, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (177, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (177, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (177, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (178, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (178, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (178, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (179, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (180, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (180, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (181, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (181, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (182, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (182, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (183, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (183, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (183, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (184, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (184, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (185, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (185, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (185, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (186, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (186, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (187, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (187, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (187, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (188, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (189, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (189, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (190, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (190, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (190, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (191, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (192, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (193, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (193, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (193, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (194, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (194, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (194, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (195, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (195, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (195, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (196, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (197, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (198, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (198, 'Fashion');
-- Total tag_produk: 399

-- INSERT INTO varian
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (1, '1-WHITE-M', 'Warna: WHITE, Ukuran: M', 37, 166414.15);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (1, '1-WHITE-L', 'Warna: WHITE, Ukuran: L', 59, 155309.87);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (1, '1-GREY', 'Warna: GREY, Ukuran: L', 72, 348433.96);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (1, '1-GREEN', 'Warna: GREEN, Ukuran: L', 51, 809054.96);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (1, '1-RED', 'Warna: RED, Ukuran: L', 44, 266922.22);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (2, '2-GREY', 'Warna: GREY, Ukuran: L', 12, 60792.58);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (2, '2-GREY-M', 'Warna: GREY, Ukuran: M', 84, 995304.98);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (2, '2-RED', 'Warna: RED, Ukuran: M', 64, 477136.44);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (3, '3-NAVY-S', 'Warna: NAVY, Ukuran: S', 61, 231714.38);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (3, '3-RED', 'Warna: RED, Ukuran: S', 97, 284696.12);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (3, '3-GREY', 'Warna: GREY, Ukuran: S', 50, 113884.1);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (3, '3-BLUE-28', 'Warna: BLUE, Ukuran: 28', 28, 712831.9);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (4, '4-RED-S', 'Warna: RED, Ukuran: S', 82, 484395.06);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (4, '4-GREY-M', 'Warna: GREY, Ukuran: M', 59, 869528.36);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (4, '4-BLUE-L', 'Warna: BLUE, Ukuran: L', 54, 565070.85);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (4, '4-BLACK-32', 'Warna: BLACK, Ukuran: 32', 13, 221199.46);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (4, '4-BLACK-L', 'Warna: BLACK, Ukuran: L', 42, 341269.38);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (5, '5-NAVY', 'Warna: NAVY, Ukuran: L', 92, 523990.87);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (5, '5-NAVY-28', 'Warna: NAVY, Ukuran: 28', 77, 305538.35);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (6, '6-RED-30', 'Warna: RED, Ukuran: 30', 5, 302693.34);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (6, '6-GREY', 'Warna: GREY, Ukuran: 30', 26, 863900.93);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (6, '6-BLUE-S', 'Warna: BLUE, Ukuran: S', 36, 388279.72);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (6, '6-NAVY-30', 'Warna: NAVY, Ukuran: 30', 75, 303259.56);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (7, '7-GREY', 'Warna: GREY, Ukuran: 30', 8, 723660.0);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (7, '7-BLACK', 'Warna: BLACK, Ukuran: 30', 45, 277302.85);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (7, '7-BLACK-28', 'Warna: BLACK, Ukuran: 28', 24, 378059.32);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (7, '7-NAVY', 'Warna: NAVY, Ukuran: 28', 1, 145739.73);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (8, '8-WHITE', 'Warna: WHITE, Ukuran: 28', 42, 130459.14);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (8, '8-BLUE', 'Warna: BLUE, Ukuran: 28', 87, 658271.3);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (9, '9-GREEN', 'Warna: GREEN, Ukuran: 28', 24, 531582.25);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (9, '9-BLUE-30', 'Warna: BLUE, Ukuran: 30', 88, 363057.81);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (9, '9-GREEN-M', 'Warna: GREEN, Ukuran: M', 40, 910933.99);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (9, '9-BLUE', 'Warna: BLUE, Ukuran: M', 79, 740548.43);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (9, '9-GREEN-L', 'Warna: GREEN, Ukuran: L', 87, 573020.56);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (10, '10-NAVY-30', 'Warna: NAVY, Ukuran: 30', 22, 267719.35);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (10, '10-RED-32', 'Warna: RED, Ukuran: 32', 86, 655220.67);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (10, '10-NAVY-L', 'Warna: NAVY, Ukuran: L', 61, 121327.74);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (11, '11-GREEN', 'Warna: GREEN, Ukuran: L', 10, 961393.21);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (11, '11-WHITE', 'Warna: WHITE, Ukuran: L', 91, 490964.38);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (12, '12-NAVY-M', 'Warna: NAVY, Ukuran: M', 51, 274989.58);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (12, '12-BLACK-S', 'Warna: BLACK, Ukuran: S', 8, 755167.61);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (12, '12-NAVY', 'Warna: NAVY, Ukuran: S', 37, 360485.25);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (12, '12-BLACK-28', 'Warna: BLACK, Ukuran: 28', 56, 236538.95);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (12, '12-NAVY-30', 'Warna: NAVY, Ukuran: 30', 77, 812282.95);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (13, '13-GREEN', 'Warna: GREEN, Ukuran: 30', 52, 681961.37);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (13, '13-RED-30', 'Warna: RED, Ukuran: 30', 59, 76319.05);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (13, '13-GREEN-L', 'Warna: GREEN, Ukuran: L', 77, 623751.5);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (13, '13-GREY', 'Warna: GREY, Ukuran: L', 41, 363415.38);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (13, '13-NAVY', 'Warna: NAVY, Ukuran: L', 86, 127596.51);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (14, '14-RED-M', 'Warna: RED, Ukuran: M', 24, 731075.59);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (14, '14-BLACK-M', 'Warna: BLACK, Ukuran: M', 30, 881773.19);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (14, '14-NAVY', 'Warna: NAVY, Ukuran: M', 37, 432547.5);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (14, '14-RED', 'Warna: RED, Ukuran: M', 68, 581307.94);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (14, '14-NAVY-30', 'Warna: NAVY, Ukuran: 30', 98, 828300.39);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (15, '15-WHITE-28', 'Warna: WHITE, Ukuran: 28', 62, 718284.58);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (15, '15-WHITE', 'Warna: WHITE, Ukuran: 28', 89, 547835.71);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (15, '15-GREY', 'Warna: GREY, Ukuran: 28', 54, 108301.17);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (16, '16-BLACK-S', 'Warna: BLACK, Ukuran: S', 97, 646094.04);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (16, '16-RED-L', 'Warna: RED, Ukuran: L', 87, 741433.49);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (16, '16-GREEN', 'Warna: GREEN, Ukuran: L', 21, 534027.35);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (17, '17-RED', 'Warna: RED, Ukuran: L', 11, 641842.11);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (17, '17-BLACK-32', 'Warna: BLACK, Ukuran: 32', 76, 556759.62);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (17, '17-NAVY', 'Warna: NAVY, Ukuran: 32', 54, 922599.57);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (18, '18-GREY', 'Warna: GREY, Ukuran: 32', 47, 261290.34);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (18, '18-GREY-32', 'Warna: GREY, Ukuran: 32', 20, 437600.82);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (19, '19-NAVY', 'Warna: NAVY, Ukuran: 32', 87, 560978.52);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (19, '19-RED-30', 'Warna: RED, Ukuran: 30', 85, 577434.34);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (19, '19-NAVY-M', 'Warna: NAVY, Ukuran: M', 23, 769362.23);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (20, '20-RED-28', 'Warna: RED, Ukuran: 28', 33, 103250.54);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (20, '20-RED', 'Warna: RED, Ukuran: 28', 48, 493720.72);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (21, '21-GREY-L', 'Warna: GREY, Ukuran: L', 34, 293396.69);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (21, '21-WHITE-28', 'Warna: WHITE, Ukuran: 28', 62, 750862.33);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (21, '21-GREY-28', 'Warna: GREY, Ukuran: 28', 0, 149490.03);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (22, '22-BLUE-28', 'Warna: BLUE, Ukuran: 28', 98, 99988.07);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (22, '22-NAVY-30', 'Warna: NAVY, Ukuran: 30', 93, 540419.3);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (22, '22-NAVY-M', 'Warna: NAVY, Ukuran: M', 35, 297051.76);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (22, '22-BLACK-L', 'Warna: BLACK, Ukuran: L', 83, 836391.2);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (23, '23-GREEN-S', 'Warna: GREEN, Ukuran: S', 58, 81120.62);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (23, '23-GREY-32', 'Warna: GREY, Ukuran: 32', 12, 567000.02);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (23, '23-WHITE-L', 'Warna: WHITE, Ukuran: L', 97, 134208.1);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (24, '24-BLACK-32', 'Warna: BLACK, Ukuran: 32', 68, 264231.31);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (24, '24-WHITE', 'Warna: WHITE, Ukuran: 32', 80, 871438.22);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (24, '24-BLACK-30', 'Warna: BLACK, Ukuran: 30', 98, 908185.41);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (24, '24-RED-S', 'Warna: RED, Ukuran: S', 96, 919583.3);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (25, '25-WHITE', 'Warna: WHITE, Ukuran: S', 87, 505226.17);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (25, '25-NAVY', 'Warna: NAVY, Ukuran: S', 48, 245272.41);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (26, '26-BLACK', 'Warna: BLACK, Ukuran: S', 47, 86567.24);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (26, '26-RED', 'Warna: RED, Ukuran: S', 65, 636466.26);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (26, '26-GREY-30', 'Warna: GREY, Ukuran: 30', 2, 289024.03);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (27, '27-RED', 'Warna: RED, Ukuran: 30', 37, 202873.92);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (27, '27-RED-28', 'Warna: RED, Ukuran: 28', 72, 954689.44);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (27, '27-RED-M', 'Warna: RED, Ukuran: M', 43, 608565.95);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (27, '27-BLACK-L', 'Warna: BLACK, Ukuran: L', 23, 842242.32);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (27, '27-GREY-30', 'Warna: GREY, Ukuran: 30', 5, 880997.08);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (28, '28-GREY', 'Warna: GREY, Ukuran: 30', 50, 676644.86);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (28, '28-BLUE', 'Warna: BLUE, Ukuran: 30', 62, 750727.91);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (29, '29-RED-32', 'Warna: RED, Ukuran: 32', 10, 129541.95);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (29, '29-GREEN-S', 'Warna: GREEN, Ukuran: S', 36, 106453.04);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (29, '29-GREEN-28', 'Warna: GREEN, Ukuran: 28', 85, 908912.24);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (29, '29-NAVY-M', 'Warna: NAVY, Ukuran: M', 18, 344500.34);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (30, '30-GREEN', 'Warna: GREEN, Ukuran: M', 54, 380397.09);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (30, '30-GREY', 'Warna: GREY, Ukuran: M', 93, 731738.08);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (30, '30-BLUE', 'Warna: BLUE, Ukuran: M', 1, 834641.37);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (30, '30-NAVY', 'Warna: NAVY, Ukuran: M', 50, 129417.53);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (30, '30-BLACK-S', 'Warna: BLACK, Ukuran: S', 33, 626494.46);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (31, '31-NAVY-L', 'Warna: NAVY, Ukuran: L', 16, 379922.53);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (31, '31-NAVY-30', 'Warna: NAVY, Ukuran: 30', 41, 356040.78);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (32, '32-GREEN', 'Warna: GREEN, Ukuran: 30', 63, 364932.05);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (32, '32-BLACK-30', 'Warna: BLACK, Ukuran: 30', 7, 801624.97);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (32, '32-GREY-L', 'Warna: GREY, Ukuran: L', 37, 315635.08);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (32, '32-BLACK-32', 'Warna: BLACK, Ukuran: 32', 1, 163668.27);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (32, '32-RED', 'Warna: RED, Ukuran: 32', 40, 674801.68);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (33, '33-GREY', 'Warna: GREY, Ukuran: 32', 99, 597437.3);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (33, '33-NAVY-28', 'Warna: NAVY, Ukuran: 28', 18, 660148.48);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (33, '33-GREY-32', 'Warna: GREY, Ukuran: 32', 42, 237405.7);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (34, '34-WHITE', 'Warna: WHITE, Ukuran: 32', 81, 427405.15);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (34, '34-RED', 'Warna: RED, Ukuran: 32', 34, 72849.41);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (34, '34-BLACK-28', 'Warna: BLACK, Ukuran: 28', 54, 965554.42);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (34, '34-GREY', 'Warna: GREY, Ukuran: 28', 78, 904073.47);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (34, '34-NAVY', 'Warna: NAVY, Ukuran: 28', 88, 340562.72);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (35, '35-GREEN-S', 'Warna: GREEN, Ukuran: S', 89, 377977.6);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (35, '35-GREEN', 'Warna: GREEN, Ukuran: S', 50, 416414.64);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (36, '36-GREY', 'Warna: GREY, Ukuran: S', 48, 650005.24);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (36, '36-NAVY', 'Warna: NAVY, Ukuran: S', 2, 240835.8);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (37, '37-RED-S', 'Warna: RED, Ukuran: S', 10, 854332.3);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (37, '37-GREEN-M', 'Warna: GREEN, Ukuran: M', 72, 406274.73);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (38, '38-NAVY', 'Warna: NAVY, Ukuran: M', 59, 148256.96);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (38, '38-WHITE-30', 'Warna: WHITE, Ukuran: 30', 77, 632737.71);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (38, '38-BLACK-M', 'Warna: BLACK, Ukuran: M', 41, 963708.74);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (39, '39-GREEN-M', 'Warna: GREEN, Ukuran: M', 89, 878668.83);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (39, '39-GREEN-L', 'Warna: GREEN, Ukuran: L', 54, 57527.19);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (39, '39-GREEN', 'Warna: GREEN, Ukuran: L', 73, 242348.54);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (39, '39-GREY-M', 'Warna: GREY, Ukuran: M', 29, 214627.4);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (40, '40-GREY-M', 'Warna: GREY, Ukuran: M', 67, 862331.39);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (40, '40-RED', 'Warna: RED, Ukuran: M', 89, 812912.91);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (41, '41-GREEN-M', 'Warna: GREEN, Ukuran: M', 27, 966717.98);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (41, '41-GREEN', 'Warna: GREEN, Ukuran: M', 86, 961528.91);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (41, '41-BLUE-32', 'Warna: BLUE, Ukuran: 32', 22, 447740.97);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (41, '41-WHITE', 'Warna: WHITE, Ukuran: 32', 82, 855082.77);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (42, '42-BLACK-S', 'Warna: BLACK, Ukuran: S', 45, 638971.95);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (42, '42-BLUE-L', 'Warna: BLUE, Ukuran: L', 71, 688162.55);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (42, '42-GREY', 'Warna: GREY, Ukuran: L', 81, 256221.42);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (42, '42-WHITE', 'Warna: WHITE, Ukuran: L', 91, 274765.89);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (42, '42-WHITE-28', 'Warna: WHITE, Ukuran: 28', 4, 980067.15);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (43, '43-BLACK', 'Warna: BLACK, Ukuran: 28', 13, 464400.6);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (43, '43-GREY-28', 'Warna: GREY, Ukuran: 28', 44, 430602.92);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (44, '44-NAVY-S', 'Warna: NAVY, Ukuran: S', 19, 618352.86);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (44, '44-NAVY-L', 'Warna: NAVY, Ukuran: L', 87, 928943.59);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (44, '44-GREY-28', 'Warna: GREY, Ukuran: 28', 26, 331043.83);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (45, '45-BLACK', 'Warna: BLACK, Ukuran: 28', 47, 63314.51);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (45, '45-BLUE', 'Warna: BLUE, Ukuran: 28', 99, 669740.65);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (45, '45-BLUE-32', 'Warna: BLUE, Ukuran: 32', 73, 852644.44);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (46, '46-RED', 'Warna: RED, Ukuran: 32', 81, 897357.34);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (46, '46-NAVY-28', 'Warna: NAVY, Ukuran: 28', 99, 896786.75);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (46, '46-BLUE-28', 'Warna: BLUE, Ukuran: 28', 89, 54291.06);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (47, '47-BLACK-30', 'Warna: BLACK, Ukuran: 30', 34, 281543.65);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (47, '47-GREY-L', 'Warna: GREY, Ukuran: L', 33, 617641.37);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (47, '47-RED-28', 'Warna: RED, Ukuran: 28', 31, 266941.65);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (47, '47-WHITE', 'Warna: WHITE, Ukuran: 28', 75, 514471.0);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (48, '48-BLACK-L', 'Warna: BLACK, Ukuran: L', 86, 375624.72);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (48, '48-BLUE', 'Warna: BLUE, Ukuran: L', 98, 488538.89);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (48, '48-NAVY', 'Warna: NAVY, Ukuran: L', 83, 686187.8);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (49, '49-BLACK', 'Warna: BLACK, Ukuran: L', 25, 543021.73);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (49, '49-NAVY', 'Warna: NAVY, Ukuran: L', 0, 77491.02);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (49, '49-BLUE-32', 'Warna: BLUE, Ukuran: 32', 5, 978529.48);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (49, '49-GREEN', 'Warna: GREEN, Ukuran: 32', 72, 881191.36);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (50, '50-BLACK', 'Warna: BLACK, Ukuran: 32', 90, 888119.94);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (50, '50-BLUE-L', 'Warna: BLUE, Ukuran: L', 4, 286948.04);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (50, '50-GREEN-30', 'Warna: GREEN, Ukuran: 30', 5, 227744.59);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (50, '50-RED', 'Warna: RED, Ukuran: 30', 21, 967502.87);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (50, '50-BLUE-32', 'Warna: BLUE, Ukuran: 32', 34, 796419.21);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (51, '51-GREY-L', 'Warna: GREY, Ukuran: L', 52, 55132.11);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (51, '51-GREY', 'Warna: GREY, Ukuran: L', 58, 211765.62);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (51, '51-GREEN-30', 'Warna: GREEN, Ukuran: 30', 45, 154414.99);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (52, '52-WHITE-S', 'Warna: WHITE, Ukuran: S', 6, 231163.38);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (52, '52-WHITE', 'Warna: WHITE, Ukuran: S', 85, 359900.77);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (52, '52-BLUE', 'Warna: BLUE, Ukuran: S', 64, 220754.55);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (52, '52-GREY-28', 'Warna: GREY, Ukuran: 28', 75, 637421.19);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (53, '53-RED', 'Warna: RED, Ukuran: 28', 15, 609958.73);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (53, '53-GREEN-L', 'Warna: GREEN, Ukuran: L', 53, 294678.69);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (53, '53-BLUE-30', 'Warna: BLUE, Ukuran: 30', 31, 394605.18);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (53, '53-BLUE-S', 'Warna: BLUE, Ukuran: S', 11, 602592.15);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (53, '53-NAVY-32', 'Warna: NAVY, Ukuran: 32', 87, 133743.05);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (54, '54-GREEN', 'Warna: GREEN, Ukuran: 32', 97, 670176.7);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (54, '54-NAVY-30', 'Warna: NAVY, Ukuran: 30', 55, 331280.85);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (54, '54-WHITE-S', 'Warna: WHITE, Ukuran: S', 32, 725595.93);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (54, '54-GREEN-S', 'Warna: GREEN, Ukuran: S', 5, 909711.8);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (55, '55-RED', 'Warna: RED, Ukuran: S', 51, 237203.87);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (55, '55-WHITE', 'Warna: WHITE, Ukuran: S', 91, 275575.32);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (56, '56-NAVY-L', 'Warna: NAVY, Ukuran: L', 8, 964445.08);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (56, '56-BLACK', 'Warna: BLACK, Ukuran: L', 15, 571329.1);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (56, '56-BLUE-32', 'Warna: BLUE, Ukuran: 32', 46, 311768.28);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (56, '56-GREEN', 'Warna: GREEN, Ukuran: 32', 71, 853097.02);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (56, '56-NAVY', 'Warna: NAVY, Ukuran: 32', 50, 778021.39);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (57, '57-WHITE', 'Warna: WHITE, Ukuran: 32', 10, 917898.92);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (57, '57-NAVY-M', 'Warna: NAVY, Ukuran: M', 42, 291529.65);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (57, '57-BLUE-L', 'Warna: BLUE, Ukuran: L', 94, 50550.39);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (58, '58-RED', 'Warna: RED, Ukuran: L', 79, 517548.56);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (58, '58-RED-S', 'Warna: RED, Ukuran: S', 44, 66293.92);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (58, '58-NAVY', 'Warna: NAVY, Ukuran: S', 68, 421187.55);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (58, '58-RED-30', 'Warna: RED, Ukuran: 30', 42, 752151.43);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (58, '58-WHITE-S', 'Warna: WHITE, Ukuran: S', 48, 905424.04);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (59, '59-NAVY', 'Warna: NAVY, Ukuran: S', 0, 329443.49);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (59, '59-WHITE', 'Warna: WHITE, Ukuran: S', 53, 138051.88);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (60, '60-GREEN-S', 'Warna: GREEN, Ukuran: S', 24, 55321.09);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (60, '60-WHITE', 'Warna: WHITE, Ukuran: S', 83, 232665.52);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (60, '60-NAVY', 'Warna: NAVY, Ukuran: S', 93, 434865.73);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (60, '60-BLUE', 'Warna: BLUE, Ukuran: S', 18, 227100.63);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (61, '61-GREY', 'Warna: GREY, Ukuran: S', 61, 575224.92);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (61, '61-BLUE-M', 'Warna: BLUE, Ukuran: M', 22, 275604.86);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (61, '61-GREEN-S', 'Warna: GREEN, Ukuran: S', 61, 191820.86);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (61, '61-NAVY', 'Warna: NAVY, Ukuran: S', 37, 506080.06);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (61, '61-RED-32', 'Warna: RED, Ukuran: 32', 21, 429237.16);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (62, '62-GREEN', 'Warna: GREEN, Ukuran: 32', 58, 646563.59);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (62, '62-WHITE', 'Warna: WHITE, Ukuran: 32', 15, 109330.07);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (63, '63-NAVY-M', 'Warna: NAVY, Ukuran: M', 19, 795861.78);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (63, '63-NAVY', 'Warna: NAVY, Ukuran: M', 98, 301846.26);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (64, '64-NAVY', 'Warna: NAVY, Ukuran: M', 1, 53603.66);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (64, '64-BLUE-S', 'Warna: BLUE, Ukuran: S', 2, 540506.51);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (65, '65-BLUE', 'Warna: BLUE, Ukuran: S', 40, 881525.31);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (65, '65-GREEN', 'Warna: GREEN, Ukuran: S', 40, 359452.73);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (65, '65-GREEN-32', 'Warna: GREEN, Ukuran: 32', 32, 761149.81);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (66, '66-BLACK', 'Warna: BLACK, Ukuran: 32', 75, 960284.19);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (66, '66-BLUE-30', 'Warna: BLUE, Ukuran: 30', 6, 980047.22);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (67, '67-BLACK', 'Warna: BLACK, Ukuran: 30', 12, 209637.52);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (67, '67-GREY-30', 'Warna: GREY, Ukuran: 30', 51, 388777.32);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (67, '67-BLUE', 'Warna: BLUE, Ukuran: 30', 92, 963024.64);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (67, '67-RED-28', 'Warna: RED, Ukuran: 28', 53, 265338.8);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (68, '68-GREEN', 'Warna: GREEN, Ukuran: 28', 76, 999899.4);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (68, '68-BLUE-S', 'Warna: BLUE, Ukuran: S', 94, 296921.1);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (68, '68-NAVY-30', 'Warna: NAVY, Ukuran: 30', 11, 221546.54);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (69, '69-GREEN-30', 'Warna: GREEN, Ukuran: 30', 59, 147262.86);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (69, '69-WHITE-30', 'Warna: WHITE, Ukuran: 30', 87, 703967.8);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (69, '69-BLACK', 'Warna: BLACK, Ukuran: 30', 6, 618894.02);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (70, '70-RED', 'Warna: RED, Ukuran: 30', 37, 229123.04);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (70, '70-NAVY-32', 'Warna: NAVY, Ukuran: 32', 100, 542856.11);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (70, '70-RED-L', 'Warna: RED, Ukuran: L', 17, 190649.32);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (71, '71-BLUE', 'Warna: BLUE, Ukuran: L', 13, 98020.95);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (71, '71-WHITE-S', 'Warna: WHITE, Ukuran: S', 10, 205321.05);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (71, '71-WHITE', 'Warna: WHITE, Ukuran: S', 64, 158495.86);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (71, '71-GREY', 'Warna: GREY, Ukuran: S', 8, 480332.58);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (72, '72-WHITE-30', 'Warna: WHITE, Ukuran: 30', 17, 154922.03);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (72, '72-BLACK', 'Warna: BLACK, Ukuran: 30', 33, 191217.74);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (73, '73-BLACK-M', 'Warna: BLACK, Ukuran: M', 75, 558698.0);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (73, '73-RED', 'Warna: RED, Ukuran: M', 54, 529073.64);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (73, '73-BLACK-32', 'Warna: BLACK, Ukuran: 32', 44, 927564.37);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (73, '73-NAVY', 'Warna: NAVY, Ukuran: 32', 99, 905852.07);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (74, '74-NAVY', 'Warna: NAVY, Ukuran: 32', 63, 600828.19);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (74, '74-GREEN-28', 'Warna: GREEN, Ukuran: 28', 8, 675356.79);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (74, '74-WHITE-M', 'Warna: WHITE, Ukuran: M', 44, 462054.93);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (75, '75-BLUE', 'Warna: BLUE, Ukuran: M', 56, 271495.49);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (75, '75-BLACK', 'Warna: BLACK, Ukuran: M', 22, 912760.16);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (75, '75-RED', 'Warna: RED, Ukuran: M', 95, 885109.19);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (76, '76-WHITE', 'Warna: WHITE, Ukuran: M', 13, 628434.6);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (76, '76-BLACK-28', 'Warna: BLACK, Ukuran: 28', 32, 608584.94);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (76, '76-BLACK', 'Warna: BLACK, Ukuran: 28', 60, 304350.31);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (77, '77-GREEN', 'Warna: GREEN, Ukuran: 28', 55, 479867.9);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (77, '77-BLACK-L', 'Warna: BLACK, Ukuran: L', 72, 473984.29);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (78, '78-GREY-L', 'Warna: GREY, Ukuran: L', 13, 877889.23);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (78, '78-BLACK', 'Warna: BLACK, Ukuran: L', 63, 827831.46);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (78, '78-BLACK-32', 'Warna: BLACK, Ukuran: 32', 36, 186897.54);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (79, '79-NAVY', 'Warna: NAVY, Ukuran: 32', 91, 377541.94);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (79, '79-WHITE', 'Warna: WHITE, Ukuran: 32', 55, 71917.13);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (79, '79-WHITE-M', 'Warna: WHITE, Ukuran: M', 22, 555365.86);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (79, '79-GREEN', 'Warna: GREEN, Ukuran: M', 43, 276226.24);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (80, '80-GREY', 'Warna: GREY, Ukuran: M', 95, 981401.37);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (80, '80-BLACK', 'Warna: BLACK, Ukuran: M', 76, 295821.53);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (80, '80-GREY-S', 'Warna: GREY, Ukuran: S', 22, 663878.88);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (81, '81-RED-32', 'Warna: RED, Ukuran: 32', 21, 501232.23);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (81, '81-GREEN', 'Warna: GREEN, Ukuran: 32', 63, 699763.45);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (81, '81-BLUE', 'Warna: BLUE, Ukuran: 32', 66, 709338.83);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (81, '81-NAVY', 'Warna: NAVY, Ukuran: 32', 19, 305231.03);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (82, '82-RED', 'Warna: RED, Ukuran: 32', 85, 960555.44);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (82, '82-GREEN', 'Warna: GREEN, Ukuran: 32', 61, 625175.77);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (82, '82-GREY', 'Warna: GREY, Ukuran: 32', 90, 225184.6);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (82, '82-BLACK-28', 'Warna: BLACK, Ukuran: 28', 49, 189668.32);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (83, '83-BLUE', 'Warna: BLUE, Ukuran: 28', 57, 643903.44);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (83, '83-RED-L', 'Warna: RED, Ukuran: L', 75, 202550.37);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (83, '83-NAVY-S', 'Warna: NAVY, Ukuran: S', 13, 845308.9);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (83, '83-GREEN-28', 'Warna: GREEN, Ukuran: 28', 12, 891416.24);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (84, '84-BLACK', 'Warna: BLACK, Ukuran: 28', 53, 537079.75);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (84, '84-BLACK-S', 'Warna: BLACK, Ukuran: S', 75, 908400.85);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (85, '85-NAVY-32', 'Warna: NAVY, Ukuran: 32', 47, 923945.08);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (85, '85-BLACK', 'Warna: BLACK, Ukuran: 32', 21, 139496.47);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (85, '85-GREEN-M', 'Warna: GREEN, Ukuran: M', 19, 915639.31);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (86, '86-NAVY', 'Warna: NAVY, Ukuran: M', 27, 898286.7);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (86, '86-GREEN-30', 'Warna: GREEN, Ukuran: 30', 6, 708545.11);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (87, '87-RED', 'Warna: RED, Ukuran: 30', 62, 740204.93);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (87, '87-BLUE', 'Warna: BLUE, Ukuran: 30', 37, 83817.66);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (87, '87-GREY-L', 'Warna: GREY, Ukuran: L', 91, 981763.56);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (87, '87-RED-32', 'Warna: RED, Ukuran: 32', 4, 330274.7);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (87, '87-GREEN-L', 'Warna: GREEN, Ukuran: L', 19, 313330.08);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (88, '88-GREY-L', 'Warna: GREY, Ukuran: L', 38, 786730.08);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (88, '88-NAVY-30', 'Warna: NAVY, Ukuran: 30', 0, 466820.21);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (88, '88-BLUE', 'Warna: BLUE, Ukuran: 30', 73, 405749.8);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (88, '88-BLACK-30', 'Warna: BLACK, Ukuran: 30', 94, 723016.85);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (89, '89-WHITE-L', 'Warna: WHITE, Ukuran: L', 61, 74317.12);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (89, '89-NAVY', 'Warna: NAVY, Ukuran: L', 85, 440381.93);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (89, '89-GREEN', 'Warna: GREEN, Ukuran: L', 57, 875090.51);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (89, '89-GREY-S', 'Warna: GREY, Ukuran: S', 13, 440004.69);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (90, '90-GREY', 'Warna: GREY, Ukuran: S', 36, 112547.37);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (90, '90-BLUE-S', 'Warna: BLUE, Ukuran: S', 47, 226084.23);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (90, '90-GREEN', 'Warna: GREEN, Ukuran: S', 6, 542202.82);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (90, '90-GREY-30', 'Warna: GREY, Ukuran: 30', 24, 390701.51);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (91, '91-NAVY', 'Warna: NAVY, Ukuran: 30', 40, 231062.4);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (91, '91-RED', 'Warna: RED, Ukuran: 30', 77, 252614.89);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (91, '91-WHITE-28', 'Warna: WHITE, Ukuran: 28', 36, 464947.83);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (91, '91-BLUE', 'Warna: BLUE, Ukuran: 28', 99, 169728.19);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (92, '92-GREEN', 'Warna: GREEN, Ukuran: 28', 95, 141611.22);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (92, '92-NAVY-30', 'Warna: NAVY, Ukuran: 30', 61, 116690.35);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (92, '92-GREY', 'Warna: GREY, Ukuran: 30', 52, 597887.12);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (92, '92-NAVY-32', 'Warna: NAVY, Ukuran: 32', 38, 932740.98);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (92, '92-WHITE', 'Warna: WHITE, Ukuran: 32', 17, 244444.93);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (93, '93-WHITE', 'Warna: WHITE, Ukuran: 32', 52, 709703.83);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (93, '93-RED', 'Warna: RED, Ukuran: 32', 30, 827440.73);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (94, '94-RED-30', 'Warna: RED, Ukuran: 30', 27, 464433.85);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (94, '94-GREEN', 'Warna: GREEN, Ukuran: 30', 24, 601354.58);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (94, '94-BLUE-28', 'Warna: BLUE, Ukuran: 28', 47, 965857.47);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (94, '94-GREY', 'Warna: GREY, Ukuran: 28', 36, 369799.39);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (95, '95-WHITE-30', 'Warna: WHITE, Ukuran: 30', 64, 835892.0);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (95, '95-RED-S', 'Warna: RED, Ukuran: S', 98, 54934.12);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (95, '95-GREEN-L', 'Warna: GREEN, Ukuran: L', 62, 596686.36);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (95, '95-WHITE', 'Warna: WHITE, Ukuran: L', 11, 954990.34);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (96, '96-RED', 'Warna: RED, Ukuran: L', 54, 460000.57);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (96, '96-GREY', 'Warna: GREY, Ukuran: L', 31, 167478.2);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (97, '97-WHITE-30', 'Warna: WHITE, Ukuran: 30', 54, 457600.81);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (97, '97-GREY', 'Warna: GREY, Ukuran: 30', 51, 200292.8);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (97, '97-NAVY', 'Warna: NAVY, Ukuran: 30', 74, 355387.67);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (97, '97-NAVY-S', 'Warna: NAVY, Ukuran: S', 93, 447447.83);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (97, '97-GREEN', 'Warna: GREEN, Ukuran: S', 19, 978010.14);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (98, '98-GREY-32', 'Warna: GREY, Ukuran: 32', 19, 793325.29);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (98, '98-GREEN-S', 'Warna: GREEN, Ukuran: S', 67, 277749.35);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (98, '98-RED-28', 'Warna: RED, Ukuran: 28', 85, 585200.41);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (98, '98-GREEN-30', 'Warna: GREEN, Ukuran: 30', 97, 883431.11);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (99, '99-RED', 'Warna: RED, Ukuran: 30', 82, 960269.55);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (99, '99-WHITE-30', 'Warna: WHITE, Ukuran: 30', 61, 510212.02);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (100, '100-BLUE', 'Warna: BLUE, Ukuran: 30', 52, 533211.92);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (100, '100-NAVY-L', 'Warna: NAVY, Ukuran: L', 87, 692337.88);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (101, '101-BLACK-30', 'Warna: BLACK, Ukuran: 30', 66, 230812.03);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (101, '101-GREEN', 'Warna: GREEN, Ukuran: 30', 73, 453735.61);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (102, '102-BLUE-S', 'Warna: BLUE, Ukuran: S', 5, 375004.14);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (102, '102-GREY-L', 'Warna: GREY, Ukuran: L', 51, 756705.52);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (102, '102-BLACK', 'Warna: BLACK, Ukuran: L', 37, 202298.04);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (102, '102-BLUE-M', 'Warna: BLUE, Ukuran: M', 51, 201041.39);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (103, '103-GREEN', 'Warna: GREEN, Ukuran: M', 67, 816327.73);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (103, '103-RED-L', 'Warna: RED, Ukuran: L', 92, 264359.71);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (103, '103-BLUE-M', 'Warna: BLUE, Ukuran: M', 38, 642333.23);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (104, '104-GREY-L', 'Warna: GREY, Ukuran: L', 27, 724112.97);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (104, '104-BLACK-28', 'Warna: BLACK, Ukuran: 28', 16, 540410.47);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (104, '104-RED', 'Warna: RED, Ukuran: 28', 80, 530278.94);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (104, '104-GREEN-S', 'Warna: GREEN, Ukuran: S', 86, 352676.51);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (105, '105-BLUE-L', 'Warna: BLUE, Ukuran: L', 96, 239440.66);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (105, '105-RED-30', 'Warna: RED, Ukuran: 30', 32, 833592.71);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (106, '106-GREY-32', 'Warna: GREY, Ukuran: 32', 89, 294003.68);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (106, '106-BLUE', 'Warna: BLUE, Ukuran: 32', 85, 994951.42);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (107, '107-GREEN-28', 'Warna: GREEN, Ukuran: 28', 20, 255227.29);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (107, '107-BLUE-S', 'Warna: BLUE, Ukuran: S', 17, 920479.18);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (107, '107-NAVY', 'Warna: NAVY, Ukuran: S', 76, 849142.34);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (108, '108-GREEN', 'Warna: GREEN, Ukuran: S', 13, 361297.81);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (108, '108-GREY', 'Warna: GREY, Ukuran: S', 39, 682055.19);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (109, '109-GREEN', 'Warna: GREEN, Ukuran: S', 91, 358714.45);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (109, '109-NAVY-32', 'Warna: NAVY, Ukuran: 32', 45, 471961.59);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (109, '109-WHITE', 'Warna: WHITE, Ukuran: 32', 14, 755318.41);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (109, '109-RED-30', 'Warna: RED, Ukuran: 30', 46, 839215.26);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (110, '110-GREEN', 'Warna: GREEN, Ukuran: 30', 50, 651181.75);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (110, '110-NAVY-30', 'Warna: NAVY, Ukuran: 30', 91, 818935.45);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (110, '110-GREY', 'Warna: GREY, Ukuran: 30', 14, 247881.39);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (110, '110-BLACK', 'Warna: BLACK, Ukuran: 30', 63, 212543.98);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (110, '110-BLUE', 'Warna: BLUE, Ukuran: 30', 26, 824678.67);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (111, '111-GREEN', 'Warna: GREEN, Ukuran: 30', 61, 301705.94);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (111, '111-WHITE', 'Warna: WHITE, Ukuran: 30', 59, 312439.71);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (111, '111-GREEN-M', 'Warna: GREEN, Ukuran: M', 66, 57489.77);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (111, '111-BLACK', 'Warna: BLACK, Ukuran: M', 21, 364247.35);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (112, '112-GREEN-S', 'Warna: GREEN, Ukuran: S', 80, 354460.22);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (112, '112-RED', 'Warna: RED, Ukuran: S', 39, 790331.57);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (112, '112-BLACK', 'Warna: BLACK, Ukuran: S', 94, 852502.37);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (112, '112-WHITE-32', 'Warna: WHITE, Ukuran: 32', 81, 379817.36);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (113, '113-NAVY', 'Warna: NAVY, Ukuran: 32', 100, 681988.66);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (113, '113-RED-28', 'Warna: RED, Ukuran: 28', 15, 128182.86);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (113, '113-BLACK', 'Warna: BLACK, Ukuran: 28', 59, 708886.22);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (114, '114-GREEN-S', 'Warna: GREEN, Ukuran: S', 86, 411870.83);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (114, '114-RED', 'Warna: RED, Ukuran: S', 39, 154136.37);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (114, '114-WHITE', 'Warna: WHITE, Ukuran: S', 97, 850907.41);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (114, '114-BLACK-S', 'Warna: BLACK, Ukuran: S', 96, 359015.49);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (114, '114-BLACK', 'Warna: BLACK, Ukuran: S', 65, 150298.7);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (115, '115-BLUE', 'Warna: BLUE, Ukuran: S', 82, 329118.2);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (115, '115-WHITE-30', 'Warna: WHITE, Ukuran: 30', 9, 423451.03);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (116, '116-NAVY', 'Warna: NAVY, Ukuran: 30', 47, 568208.16);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (116, '116-GREEN-L', 'Warna: GREEN, Ukuran: L', 98, 767871.69);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (117, '117-BLACK-30', 'Warna: BLACK, Ukuran: 30', 34, 292317.39);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (117, '117-GREEN-L', 'Warna: GREEN, Ukuran: L', 89, 915224.66);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (117, '117-BLUE-S', 'Warna: BLUE, Ukuran: S', 22, 185923.88);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (117, '117-RED', 'Warna: RED, Ukuran: S', 4, 364420.19);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (118, '118-GREEN-S', 'Warna: GREEN, Ukuran: S', 80, 652583.64);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (118, '118-NAVY', 'Warna: NAVY, Ukuran: S', 91, 659036.33);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (118, '118-BLUE-M', 'Warna: BLUE, Ukuran: M', 1, 443702.03);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (118, '118-NAVY-32', 'Warna: NAVY, Ukuran: 32', 13, 504877.65);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (118, '118-GREEN', 'Warna: GREEN, Ukuran: 32', 21, 588998.64);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (119, '119-BLUE-M', 'Warna: BLUE, Ukuran: M', 98, 255780.9);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (119, '119-GREEN-M', 'Warna: GREEN, Ukuran: M', 97, 161545.76);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (120, '120-GREY', 'Warna: GREY, Ukuran: M', 56, 849331.4);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (120, '120-RED', 'Warna: RED, Ukuran: M', 18, 376774.79);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (120, '120-BLACK', 'Warna: BLACK, Ukuran: M', 68, 122274.86);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (121, '121-BLACK', 'Warna: BLACK, Ukuran: M', 29, 131533.18);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (121, '121-BLACK-M', 'Warna: BLACK, Ukuran: M', 68, 633518.91);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (122, '122-GREEN-32', 'Warna: GREEN, Ukuran: 32', 70, 546349.17);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (122, '122-BLACK-32', 'Warna: BLACK, Ukuran: 32', 86, 107379.64);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (122, '122-RED-28', 'Warna: RED, Ukuran: 28', 67, 649086.76);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (122, '122-WHITE', 'Warna: WHITE, Ukuran: 28', 44, 663338.98);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (122, '122-RED', 'Warna: RED, Ukuran: 28', 20, 340987.81);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (123, '123-NAVY-L', 'Warna: NAVY, Ukuran: L', 99, 792335.41);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (123, '123-BLACK-30', 'Warna: BLACK, Ukuran: 30', 13, 671309.62);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (124, '124-GREY-L', 'Warna: GREY, Ukuran: L', 93, 680405.99);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (124, '124-BLACK', 'Warna: BLACK, Ukuran: L', 91, 532227.42);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (125, '125-BLUE-28', 'Warna: BLUE, Ukuran: 28', 14, 91263.2);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (125, '125-BLACK', 'Warna: BLACK, Ukuran: 28', 41, 938350.08);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (125, '125-WHITE', 'Warna: WHITE, Ukuran: 28', 22, 852843.34);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (125, '125-NAVY', 'Warna: NAVY, Ukuran: 28', 59, 470816.52);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (125, '125-BLUE', 'Warna: BLUE, Ukuran: 28', 38, 946666.69);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (126, '126-GREEN-28', 'Warna: GREEN, Ukuran: 28', 71, 893759.38);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (126, '126-GREY', 'Warna: GREY, Ukuran: 28', 49, 144063.37);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (126, '126-BLUE-M', 'Warna: BLUE, Ukuran: M', 37, 652040.64);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (127, '127-NAVY-30', 'Warna: NAVY, Ukuran: 30', 82, 731723.44);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (127, '127-GREEN-L', 'Warna: GREEN, Ukuran: L', 99, 317058.87);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (127, '127-GREY-32', 'Warna: GREY, Ukuran: 32', 14, 169141.7);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (128, '128-BLACK', 'Warna: BLACK, Ukuran: 32', 8, 979280.36);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (128, '128-WHITE-S', 'Warna: WHITE, Ukuran: S', 17, 874827.71);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (128, '128-WHITE-M', 'Warna: WHITE, Ukuran: M', 25, 330939.71);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (129, '129-GREEN', 'Warna: GREEN, Ukuran: M', 47, 906282.89);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (129, '129-RED', 'Warna: RED, Ukuran: M', 11, 154022.41);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (129, '129-NAVY', 'Warna: NAVY, Ukuran: M', 16, 438973.67);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (129, '129-BLUE', 'Warna: BLUE, Ukuran: M', 43, 642387.2);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (130, '130-BLACK-L', 'Warna: BLACK, Ukuran: L', 30, 919577.5);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (130, '130-RED-28', 'Warna: RED, Ukuran: 28', 43, 169743.85);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (131, '131-GREY', 'Warna: GREY, Ukuran: 28', 95, 270637.33);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (131, '131-NAVY-30', 'Warna: NAVY, Ukuran: 30', 92, 516779.44);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (132, '132-NAVY', 'Warna: NAVY, Ukuran: 30', 52, 201896.88);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (132, '132-BLACK', 'Warna: BLACK, Ukuran: 30', 83, 252178.74);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (132, '132-BLACK-28', 'Warna: BLACK, Ukuran: 28', 23, 233666.38);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (133, '133-WHITE-28', 'Warna: WHITE, Ukuran: 28', 10, 813357.76);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (133, '133-RED', 'Warna: RED, Ukuran: 28', 58, 710804.19);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (133, '133-WHITE', 'Warna: WHITE, Ukuran: 28', 70, 437483.56);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (134, '134-BLACK', 'Warna: BLACK, Ukuran: 28', 59, 247580.5);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (134, '134-RED-30', 'Warna: RED, Ukuran: 30', 33, 863089.44);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (134, '134-BLUE-S', 'Warna: BLUE, Ukuran: S', 4, 582128.32);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (135, '135-GREEN-S', 'Warna: GREEN, Ukuran: S', 16, 261953.45);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (135, '135-GREY-M', 'Warna: GREY, Ukuran: M', 45, 206979.7);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (135, '135-WHITE', 'Warna: WHITE, Ukuran: M', 79, 592129.07);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (135, '135-NAVY', 'Warna: NAVY, Ukuran: M', 3, 118274.0);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (135, '135-BLUE-M', 'Warna: BLUE, Ukuran: M', 53, 913608.41);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (136, '136-GREEN', 'Warna: GREEN, Ukuran: M', 89, 745011.97);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (136, '136-RED-30', 'Warna: RED, Ukuran: 30', 75, 585844.66);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (137, '137-BLUE-S', 'Warna: BLUE, Ukuran: S', 92, 854010.25);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (137, '137-BLACK', 'Warna: BLACK, Ukuran: S', 9, 98107.65);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (137, '137-BLUE', 'Warna: BLUE, Ukuran: S', 22, 156863.47);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (138, '138-GREEN-28', 'Warna: GREEN, Ukuran: 28', 51, 378914.66);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (138, '138-WHITE-28', 'Warna: WHITE, Ukuran: 28', 25, 232475.43);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (138, '138-NAVY-28', 'Warna: NAVY, Ukuran: 28', 63, 354752.64);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (139, '139-WHITE-30', 'Warna: WHITE, Ukuran: 30', 38, 603479.26);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (139, '139-BLACK-L', 'Warna: BLACK, Ukuran: L', 96, 133738.42);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (139, '139-GREY', 'Warna: GREY, Ukuran: L', 29, 306446.46);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (140, '140-GREY-S', 'Warna: GREY, Ukuran: S', 77, 934624.13);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (140, '140-BLUE', 'Warna: BLUE, Ukuran: S', 85, 625239.85);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (140, '140-WHITE-S', 'Warna: WHITE, Ukuran: S', 14, 916570.01);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (140, '140-RED', 'Warna: RED, Ukuran: S', 93, 457719.74);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (140, '140-GREEN', 'Warna: GREEN, Ukuran: S', 1, 409042.38);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (141, '141-NAVY', 'Warna: NAVY, Ukuran: S', 0, 536661.47);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (141, '141-GREY-L', 'Warna: GREY, Ukuran: L', 57, 831211.74);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (141, '141-GREEN-28', 'Warna: GREEN, Ukuran: 28', 66, 278407.84);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (142, '142-NAVY', 'Warna: NAVY, Ukuran: 28', 13, 107791.41);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (142, '142-RED-32', 'Warna: RED, Ukuran: 32', 41, 959935.87);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (143, '143-WHITE', 'Warna: WHITE, Ukuran: 32', 30, 51432.97);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (143, '143-GREY-S', 'Warna: GREY, Ukuran: S', 10, 737907.71);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (144, '144-NAVY-M', 'Warna: NAVY, Ukuran: M', 35, 812475.09);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (144, '144-GREEN-M', 'Warna: GREEN, Ukuran: M', 11, 491332.2);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (145, '145-GREY-30', 'Warna: GREY, Ukuran: 30', 2, 255052.9);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (145, '145-GREEN-L', 'Warna: GREEN, Ukuran: L', 22, 956983.12);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (145, '145-BLUE', 'Warna: BLUE, Ukuran: L', 48, 956613.52);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (145, '145-WHITE', 'Warna: WHITE, Ukuran: L', 94, 866697.8);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (146, '146-BLUE-M', 'Warna: BLUE, Ukuran: M', 55, 736016.51);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (146, '146-GREY-M', 'Warna: GREY, Ukuran: M', 34, 310366.39);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (146, '146-NAVY-S', 'Warna: NAVY, Ukuran: S', 33, 710927.86);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (146, '146-RED-S', 'Warna: RED, Ukuran: S', 49, 229257.62);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (146, '146-GREEN', 'Warna: GREEN, Ukuran: S', 49, 961399.02);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (147, '147-WHITE-30', 'Warna: WHITE, Ukuran: 30', 13, 495016.47);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (147, '147-NAVY-32', 'Warna: NAVY, Ukuran: 32', 69, 175439.24);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (147, '147-BLACK-28', 'Warna: BLACK, Ukuran: 28', 30, 625316.37);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (147, '147-GREEN-L', 'Warna: GREEN, Ukuran: L', 32, 163660.22);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (147, '147-BLACK', 'Warna: BLACK, Ukuran: L', 90, 824459.78);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (148, '148-GREY-M', 'Warna: GREY, Ukuran: M', 88, 287665.08);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (148, '148-WHITE-30', 'Warna: WHITE, Ukuran: 30', 84, 235503.47);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (148, '148-NAVY', 'Warna: NAVY, Ukuran: 30', 85, 423449.09);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (148, '148-WHITE', 'Warna: WHITE, Ukuran: 30', 47, 793049.09);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (148, '148-GREEN', 'Warna: GREEN, Ukuran: 30', 96, 160058.34);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (149, '149-RED-30', 'Warna: RED, Ukuran: 30', 9, 726724.96);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (149, '149-GREY-28', 'Warna: GREY, Ukuran: 28', 59, 52312.12);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (149, '149-GREY', 'Warna: GREY, Ukuran: 28', 60, 362486.18);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (150, '150-RED-32', 'Warna: RED, Ukuran: 32', 100, 167960.52);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (150, '150-BLACK-M', 'Warna: BLACK, Ukuran: M', 19, 284790.54);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (150, '150-GREY', 'Warna: GREY, Ukuran: M', 36, 603560.5);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (150, '150-GREEN', 'Warna: GREEN, Ukuran: M', 55, 972240.69);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (151, '151-BLUE-30', 'Warna: BLUE, Ukuran: 30', 82, 503898.58);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (151, '151-GREEN-L', 'Warna: GREEN, Ukuran: L', 20, 903359.26);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (152, '152-BLACK-30', 'Warna: BLACK, Ukuran: 30', 40, 89215.89);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (152, '152-WHITE', 'Warna: WHITE, Ukuran: 30', 63, 667495.77);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (153, '153-NAVY-L', 'Warna: NAVY, Ukuran: L', 36, 559492.61);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (153, '153-NAVY', 'Warna: NAVY, Ukuran: L', 6, 739885.23);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (153, '153-GREEN-S', 'Warna: GREEN, Ukuran: S', 5, 389873.15);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (153, '153-GREY-S', 'Warna: GREY, Ukuran: S', 100, 520616.12);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (153, '153-GREEN', 'Warna: GREEN, Ukuran: S', 53, 727101.13);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (154, '154-BLUE', 'Warna: BLUE, Ukuran: S', 75, 446701.64);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (154, '154-GREY-S', 'Warna: GREY, Ukuran: S', 14, 792219.01);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (155, '155-BLUE', 'Warna: BLUE, Ukuran: S', 14, 135552.91);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (155, '155-GREEN', 'Warna: GREEN, Ukuran: S', 66, 240011.41);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (155, '155-BLUE-L', 'Warna: BLUE, Ukuran: L', 91, 645859.76);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (155, '155-GREEN-M', 'Warna: GREEN, Ukuran: M', 40, 939434.63);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (155, '155-WHITE-S', 'Warna: WHITE, Ukuran: S', 33, 436509.45);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (156, '156-WHITE-30', 'Warna: WHITE, Ukuran: 30', 28, 398809.09);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (156, '156-NAVY-L', 'Warna: NAVY, Ukuran: L', 40, 441085.49);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (156, '156-BLACK-M', 'Warna: BLACK, Ukuran: M', 38, 78973.54);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (157, '157-BLUE', 'Warna: BLUE, Ukuran: M', 1, 206510.61);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (157, '157-RED-30', 'Warna: RED, Ukuran: 30', 33, 973987.89);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (157, '157-RED-28', 'Warna: RED, Ukuran: 28', 92, 953630.86);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (158, '158-BLACK-L', 'Warna: BLACK, Ukuran: L', 57, 210914.13);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (158, '158-GREEN-L', 'Warna: GREEN, Ukuran: L', 93, 132056.76);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (158, '158-RED', 'Warna: RED, Ukuran: L', 5, 533174.95);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (158, '158-BLUE-M', 'Warna: BLUE, Ukuran: M', 56, 469279.86);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (159, '159-NAVY', 'Warna: NAVY, Ukuran: M', 20, 71030.87);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (159, '159-GREEN', 'Warna: GREEN, Ukuran: M', 65, 885368.79);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (159, '159-NAVY-32', 'Warna: NAVY, Ukuran: 32', 14, 395817.06);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (159, '159-BLACK-28', 'Warna: BLACK, Ukuran: 28', 2, 914500.22);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (159, '159-WHITE', 'Warna: WHITE, Ukuran: 28', 72, 719380.53);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (160, '160-BLACK', 'Warna: BLACK, Ukuran: 28', 86, 227803.98);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (160, '160-BLACK-28', 'Warna: BLACK, Ukuran: 28', 40, 968158.5);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (160, '160-BLUE', 'Warna: BLUE, Ukuran: 28', 7, 658701.25);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (161, '161-BLACK-L', 'Warna: BLACK, Ukuran: L', 52, 714725.91);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (161, '161-GREY', 'Warna: GREY, Ukuran: L', 18, 231874.8);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (161, '161-RED-S', 'Warna: RED, Ukuran: S', 46, 103993.82);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (161, '161-RED', 'Warna: RED, Ukuran: S', 52, 187191.2);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (162, '162-WHITE-M', 'Warna: WHITE, Ukuran: M', 33, 639690.26);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (162, '162-BLACK', 'Warna: BLACK, Ukuran: M', 86, 951894.88);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (162, '162-BLUE-32', 'Warna: BLUE, Ukuran: 32', 46, 961003.93);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (163, '163-GREY', 'Warna: GREY, Ukuran: 32', 83, 598973.84);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (163, '163-RED-S', 'Warna: RED, Ukuran: S', 20, 349558.18);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (163, '163-WHITE-30', 'Warna: WHITE, Ukuran: 30', 83, 763987.21);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (164, '164-GREY-32', 'Warna: GREY, Ukuran: 32', 36, 987572.16);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (164, '164-NAVY-28', 'Warna: NAVY, Ukuran: 28', 36, 439041.16);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (164, '164-BLACK', 'Warna: BLACK, Ukuran: 28', 0, 892183.05);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (164, '164-GREEN', 'Warna: GREEN, Ukuran: 28', 80, 827747.01);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (164, '164-WHITE-30', 'Warna: WHITE, Ukuran: 30', 90, 614237.64);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (165, '165-GREEN', 'Warna: GREEN, Ukuran: 30', 98, 693911.45);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (165, '165-BLACK', 'Warna: BLACK, Ukuran: 30', 43, 240334.05);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (165, '165-GREY-M', 'Warna: GREY, Ukuran: M', 90, 544561.37);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (165, '165-WHITE-28', 'Warna: WHITE, Ukuran: 28', 70, 624674.71);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (165, '165-WHITE', 'Warna: WHITE, Ukuran: 28', 82, 719540.33);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (166, '166-GREY', 'Warna: GREY, Ukuran: 28', 6, 185698.58);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (166, '166-NAVY', 'Warna: NAVY, Ukuran: 28', 55, 191357.88);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (166, '166-NAVY-30', 'Warna: NAVY, Ukuran: 30', 34, 523229.71);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (166, '166-BLUE', 'Warna: BLUE, Ukuran: 30', 32, 700979.09);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (167, '167-BLUE-S', 'Warna: BLUE, Ukuran: S', 82, 295467.01);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (167, '167-GREY-L', 'Warna: GREY, Ukuran: L', 48, 782034.63);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (167, '167-WHITE', 'Warna: WHITE, Ukuran: L', 85, 155449.22);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (168, '168-BLACK', 'Warna: BLACK, Ukuran: L', 8, 819860.38);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (168, '168-NAVY-S', 'Warna: NAVY, Ukuran: S', 80, 592774.21);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (169, '169-RED-S', 'Warna: RED, Ukuran: S', 80, 803869.3);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (169, '169-RED', 'Warna: RED, Ukuran: S', 71, 778661.94);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (169, '169-BLUE-28', 'Warna: BLUE, Ukuran: 28', 67, 339552.98);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (169, '169-GREEN-28', 'Warna: GREEN, Ukuran: 28', 53, 59822.66);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (170, '170-NAVY', 'Warna: NAVY, Ukuran: 28', 71, 640004.86);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (170, '170-GREEN', 'Warna: GREEN, Ukuran: 28', 92, 636534.86);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (171, '171-NAVY-30', 'Warna: NAVY, Ukuran: 30', 76, 221734.48);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (171, '171-GREY-32', 'Warna: GREY, Ukuran: 32', 3, 395999.07);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (171, '171-NAVY-28', 'Warna: NAVY, Ukuran: 28', 92, 137895.17);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (172, '172-RED', 'Warna: RED, Ukuran: 32', 49, 381731.13);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (172, '172-GREEN-28', 'Warna: GREEN, Ukuran: 28', 77, 368582.92);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (172, '172-BLUE', 'Warna: BLUE, Ukuran: 28', 23, 101744.31);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (172, '172-GREEN', 'Warna: GREEN, Ukuran: 28', 5, 811297.74);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (172, '172-GREEN-L', 'Warna: GREEN, Ukuran: L', 38, 369811.67);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (173, '173-NAVY', 'Warna: NAVY, Ukuran: L', 92, 248376.91);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (173, '173-GREEN', 'Warna: GREEN, Ukuran: L', 99, 630606.69);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (173, '173-WHITE-L', 'Warna: WHITE, Ukuran: L', 8, 972698.5);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (174, '174-BLACK', 'Warna: BLACK, Ukuran: L', 25, 882239.33);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (174, '174-GREY', 'Warna: GREY, Ukuran: L', 7, 102109.91);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (174, '174-BLUE-30', 'Warna: BLUE, Ukuran: 30', 14, 708849.19);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (175, '175-NAVY', 'Warna: NAVY, Ukuran: 30', 19, 591724.96);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (175, '175-GREY', 'Warna: GREY, Ukuran: 30', 51, 759900.51);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (175, '175-RED', 'Warna: RED, Ukuran: 30', 90, 643623.89);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (175, '175-BLUE', 'Warna: BLUE, Ukuran: 30', 35, 959849.95);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (176, '176-GREY-L', 'Warna: GREY, Ukuran: L', 84, 971151.47);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (176, '176-WHITE-L', 'Warna: WHITE, Ukuran: L', 95, 795620.9);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (176, '176-WHITE-S', 'Warna: WHITE, Ukuran: S', 91, 378615.02);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (176, '176-BLUE-28', 'Warna: BLUE, Ukuran: 28', 26, 248347.57);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (177, '177-GREY', 'Warna: GREY, Ukuran: 28', 63, 797654.15);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (177, '177-RED-30', 'Warna: RED, Ukuran: 30', 94, 57849.67);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (177, '177-NAVY', 'Warna: NAVY, Ukuran: 30', 50, 311586.84);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (177, '177-WHITE', 'Warna: WHITE, Ukuran: 30', 31, 988029.27);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (177, '177-BLUE-32', 'Warna: BLUE, Ukuran: 32', 2, 792578.54);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (178, '178-RED', 'Warna: RED, Ukuran: 32', 86, 834608.73);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (178, '178-NAVY', 'Warna: NAVY, Ukuran: 32', 48, 177777.88);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (178, '178-GREY', 'Warna: GREY, Ukuran: 32', 80, 847174.29);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (179, '179-GREY-30', 'Warna: GREY, Ukuran: 30', 66, 106510.9);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (179, '179-NAVY-30', 'Warna: NAVY, Ukuran: 30', 14, 962590.64);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (180, '180-WHITE', 'Warna: WHITE, Ukuran: 30', 89, 250521.49);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (180, '180-RED', 'Warna: RED, Ukuran: 30', 69, 619980.2);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (180, '180-BLACK', 'Warna: BLACK, Ukuran: 30', 31, 914238.45);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (180, '180-BLUE-32', 'Warna: BLUE, Ukuran: 32', 76, 825471.68);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (181, '181-GREY', 'Warna: GREY, Ukuran: 32', 29, 504452.93);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (181, '181-GREEN-32', 'Warna: GREEN, Ukuran: 32', 29, 452439.69);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (182, '182-BLUE-30', 'Warna: BLUE, Ukuran: 30', 88, 465061.7);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (182, '182-BLUE-L', 'Warna: BLUE, Ukuran: L', 30, 564875.69);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (182, '182-GREY-L', 'Warna: GREY, Ukuran: L', 68, 333133.08);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (182, '182-GREEN-32', 'Warna: GREEN, Ukuran: 32', 73, 589163.59);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (183, '183-RED', 'Warna: RED, Ukuran: 32', 55, 340794.23);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (183, '183-NAVY', 'Warna: NAVY, Ukuran: 32', 86, 463569.41);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (184, '184-BLUE', 'Warna: BLUE, Ukuran: 32', 23, 341172.48);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (184, '184-WHITE', 'Warna: WHITE, Ukuran: 32', 27, 888016.99);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (184, '184-GREEN-S', 'Warna: GREEN, Ukuran: S', 50, 477084.48);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (185, '185-BLUE-30', 'Warna: BLUE, Ukuran: 30', 2, 107020.17);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (185, '185-GREY-30', 'Warna: GREY, Ukuran: 30', 38, 435290.32);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (185, '185-BLACK', 'Warna: BLACK, Ukuran: 30', 73, 435038.49);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (185, '185-GREEN-M', 'Warna: GREEN, Ukuran: M', 34, 70271.59);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (186, '186-NAVY-M', 'Warna: NAVY, Ukuran: M', 42, 564992.93);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (186, '186-GREEN-M', 'Warna: GREEN, Ukuran: M', 10, 335455.81);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (186, '186-GREY', 'Warna: GREY, Ukuran: M', 4, 182360.88);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (187, '187-NAVY', 'Warna: NAVY, Ukuran: M', 36, 723735.01);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (187, '187-GREEN', 'Warna: GREEN, Ukuran: M', 34, 290688.88);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (187, '187-BLACK', 'Warna: BLACK, Ukuran: M', 2, 509291.49);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (188, '188-GREEN-S', 'Warna: GREEN, Ukuran: S', 76, 681795.19);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (188, '188-NAVY-S', 'Warna: NAVY, Ukuran: S', 79, 109061.1);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (189, '189-BLUE-32', 'Warna: BLUE, Ukuran: 32', 93, 978447.52);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (189, '189-WHITE', 'Warna: WHITE, Ukuran: 32', 100, 467036.56);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (190, '190-NAVY-S', 'Warna: NAVY, Ukuran: S', 81, 421290.11);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (190, '190-GREY-S', 'Warna: GREY, Ukuran: S', 3, 820705.22);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (191, '191-GREEN', 'Warna: GREEN, Ukuran: S', 10, 410285.05);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (191, '191-RED', 'Warna: RED, Ukuran: S', 76, 135585.8);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (191, '191-RED-28', 'Warna: RED, Ukuran: 28', 70, 499864.54);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (191, '191-BLACK-28', 'Warna: BLACK, Ukuran: 28', 6, 377398.3);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (192, '192-NAVY-32', 'Warna: NAVY, Ukuran: 32', 32, 253908.97);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (192, '192-RED-32', 'Warna: RED, Ukuran: 32', 43, 842890.1);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (193, '193-BLUE-L', 'Warna: BLUE, Ukuran: L', 95, 306752.84);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (193, '193-NAVY', 'Warna: NAVY, Ukuran: L', 100, 819636.88);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (193, '193-GREY-S', 'Warna: GREY, Ukuran: S', 48, 687600.67);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (193, '193-RED', 'Warna: RED, Ukuran: S', 5, 422375.5);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (194, '194-GREEN', 'Warna: GREEN, Ukuran: S', 8, 816401.85);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (194, '194-BLACK-L', 'Warna: BLACK, Ukuran: L', 17, 373811.38);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (195, '195-GREY', 'Warna: GREY, Ukuran: L', 68, 495298.95);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (195, '195-BLACK', 'Warna: BLACK, Ukuran: L', 34, 308748.58);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (196, '196-NAVY', 'Warna: NAVY, Ukuran: L', 47, 103675.53);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (196, '196-NAVY-M', 'Warna: NAVY, Ukuran: M', 69, 297283.08);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (196, '196-BLUE', 'Warna: BLUE, Ukuran: M', 34, 467889.17);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (196, '196-WHITE', 'Warna: WHITE, Ukuran: M', 90, 427678.27);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (197, '197-BLUE-30', 'Warna: BLUE, Ukuran: 30', 45, 659179.0);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (197, '197-WHITE', 'Warna: WHITE, Ukuran: 30', 38, 699068.5);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (198, '198-GREY', 'Warna: GREY, Ukuran: 30', 65, 434721.07);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (198, '198-BLACK', 'Warna: BLACK, Ukuran: 30', 74, 169818.24);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (198, '198-GREEN-30', 'Warna: GREEN, Ukuran: 30', 100, 936039.07);
-- Total varian: 656

-- INSERT INTO pesanan
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (1, 'Dikirim', 2235113.5, 'Kartu Kredit', 'Libero voluptas enim itaque vero laudantium ratione corporis.', '2024-07-17 19:12:55', 'Same Day', 'rini42@yahoo.com', 45, 'umar49@yahoo.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (2, 'Selesai', 1574842.68, 'Transfer Bank', NULL, '2025-01-20 19:12:55', 'Same Day', 'oni39@yahoo.com', 42, 'ade21@protonmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (3, 'Dikirim', 4616295.59, 'Kartu Kredit', NULL, '2024-10-26 19:12:55', 'Ambil di Tempat', 'mariadi4@outlook.com', 40, 'ade21@protonmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (4, 'Menunggu Pembayaran', 3399518.38, 'COD', NULL, '2025-04-17 19:12:55', 'Kurir Standar', 'kayla22@gmail.com', 81, 'rudi57@aol.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (5, 'Dikirim', 3252101.74, 'Kartu Kredit', NULL, '2025-05-09 19:12:55', 'Kurir Standar', 'ophelia59@protonmail.com', 41, 'umar49@yahoo.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (6, 'Selesai', 2446940.5, 'COD', NULL, '2024-10-17 19:12:55', 'Kurir Standar', 'cinta78@outlook.com', 50, 'siska88@gmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (7, 'Menunggu Pembayaran', 1570210.1, 'COD', NULL, '2025-03-25 19:12:55', 'Ambil di Tempat', 'cinta78@outlook.com', 63, 'gawati55@mail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (8, 'Diproses', 3709122.9, 'COD', NULL, '2024-09-17 19:12:55', 'Instant Courier', 'pardi19@protonmail.com', 64, 'hairyanto16@aol.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (9, 'Menunggu Pembayaran', 3841943.35, 'Kartu Kredit', 'Quaerat eum magnam.', '2025-02-10 19:12:55', 'Same Day', 'kusuma34@gmail.com', 21, 'abyasa18@protonmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (10, 'Diproses', 1544270.03, 'Transfer Bank', NULL, '2024-07-02 19:12:55', 'Instant Courier', 'rini42@yahoo.com', 23, 'luis86@protonmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (11, 'Selesai', 1308013.13, 'E-Wallet', NULL, '2025-01-21 19:12:55', 'Instant Courier', 'laswi20@aol.com', 84, 'talia73@yahoo.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (12, 'Selesai', 455558.48, 'Kartu Kredit', 'Corrupti voluptatem odit molestiae.', '2025-05-15 19:12:55', 'Instant Courier', 'kayla22@gmail.com', 36, 'siska88@gmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (13, 'Menunggu Pembayaran', 2445057.8, 'E-Wallet', NULL, '2024-12-17 19:12:55', 'Instant Courier', 'ade21@protonmail.com', 82, 'abyasa18@protonmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (14, 'Dikirim', 2013837.49, 'Transfer Bank', NULL, '2024-06-09 19:12:55', 'Ambil di Tempat', 'gara24@hotmail.com', 90, 'ophelia59@protonmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (15, 'Menunggu Pembayaran', 1161099.68, 'E-Wallet', 'Itaque praesentium molestiae corporis odit voluptas.', '2025-04-20 19:12:55', 'Instant Courier', 'gilda79@gmail.com', 46, 'luis86@protonmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (16, 'Diproses', 2340608.8, 'COD', 'Dicta voluptates eveniet odio.', '2025-04-08 19:12:55', 'Kurir Standar', 'heru90@hotmail.com', 71, 'rudi57@aol.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (17, 'Diproses', 4172609.86, 'COD', NULL, '2024-11-30 19:12:55', 'Kurir Standar', 'opung93@gmail.com', 49, 'ophelia59@protonmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (18, 'Menunggu Pembayaran', 2435608.94, 'COD', NULL, '2025-02-27 19:12:55', 'Ambil di Tempat', 'oni39@yahoo.com', 62, 'gara24@hotmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (19, 'Dikirim', 4798331.65, 'COD', 'Ipsum vel voluptate consequatur omnis perspiciatis voluptatibus consequatur.', '2024-07-23 19:12:55', 'Ambil di Tempat', 'oni39@yahoo.com', 43, 'gilda79@gmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (20, 'Dikirim', 2169590.34, 'COD', 'Tempore aspernatur quasi maxime.', '2024-09-26 19:12:55', 'Kurir Standar', 'siska88@gmail.com', 11, 'talia73@yahoo.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (21, 'Menunggu Pembayaran', 1620816.16, 'E-Wallet', 'Ipsam eos nam voluptas debitis molestias alias vitae.', '2025-01-14 19:12:55', 'Same Day', 'opung93@gmail.com', 95, 'gilda79@gmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (22, 'Selesai', 715295.09, 'Kartu Kredit', 'Beatae amet perspiciatis quia.', '2025-01-23 19:12:55', 'Instant Courier', 'cemplunk31@aol.com', 15, 'siska88@gmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (23, 'Dibatalkan', 3269575.72, 'Kartu Kredit', 'Magnam delectus nisi officia at nisi officia odio.', '2024-05-19 19:12:55', 'Ambil di Tempat', 'nasim25@aol.com', 81, 'ade21@protonmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (24, 'Diproses', 982615.01, 'E-Wallet', 'Iste accusantium repudiandae pariatur quibusdam.', '2025-03-29 19:12:55', 'Kurir Standar', 'rangga32@gmail.com', 5, 'nugraha66@mail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (25, 'Menunggu Pembayaran', 4515707.66, 'COD', NULL, '2025-02-22 19:12:55', 'Ambil di Tempat', 'cemplunk31@aol.com', 78, 'siska88@gmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (26, 'Dikirim', 4378762.27, 'COD', NULL, '2024-11-11 19:12:55', 'Instant Courier', 'hairyanto16@aol.com', 59, 'siska88@gmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (27, 'Selesai', 3694408.2, 'COD', 'Incidunt occaecati ullam esse ipsam amet.', '2025-04-29 19:12:55', 'Ambil di Tempat', 'atma30@outlook.com', 21, 'luis86@protonmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (28, 'Menunggu Pembayaran', 2575148.44, 'E-Wallet', 'Laudantium eum et ipsam aspernatur.', '2024-10-15 19:12:55', 'Ambil di Tempat', 'heru90@hotmail.com', 84, 'rudi57@aol.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (29, 'Selesai', 2655453.26, 'E-Wallet', NULL, '2024-08-19 19:12:55', 'Same Day', 'irsad44@protonmail.com', 94, 'luis86@protonmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (30, 'Dikirim', 3869441.6, 'E-Wallet', NULL, '2024-05-30 19:12:55', 'Kurir Standar', 'opung93@gmail.com', 90, 'harimurti12@outlook.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (31, 'Selesai', 3368727.96, 'Transfer Bank', 'Reiciendis repellat mollitia ullam.', '2024-06-05 19:12:55', 'Same Day', 'kayla22@gmail.com', 47, 'talia73@yahoo.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (32, 'Selesai', 3243661.64, 'E-Wallet', NULL, '2024-07-21 19:12:55', 'Same Day', 'heru90@hotmail.com', 51, 'abyasa18@protonmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (33, 'Menunggu Pembayaran', 4385577.38, 'Kartu Kredit', NULL, '2024-10-27 19:12:55', 'Ambil di Tempat', 'siska88@gmail.com', 36, 'naradi89@yahoo.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (34, 'Dibatalkan', 2987236.53, 'Kartu Kredit', 'Omnis eveniet explicabo amet.', '2024-10-31 19:12:55', 'Ambil di Tempat', 'asmianto10@yahoo.com', 6, 'naradi89@yahoo.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (35, 'Dikirim', 1294456.37, 'E-Wallet', 'Facere quasi adipisci.', '2024-10-04 19:12:55', 'Ambil di Tempat', 'umar49@yahoo.com', 30, 'gara24@hotmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (36, 'Menunggu Pembayaran', 604242.17, 'Kartu Kredit', NULL, '2025-03-12 19:12:55', 'Instant Courier', 'atma30@outlook.com', 39, 'naradi89@yahoo.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (37, 'Diproses', 3559591.85, 'COD', 'Earum ab corrupti eius illo officia neque.', '2024-12-25 19:12:55', 'Kurir Standar', 'rachel31@mail.com', 86, 'rudi57@aol.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (38, 'Menunggu Pembayaran', 630331.89, 'Kartu Kredit', 'Ipsam necessitatibus repudiandae quas.', '2024-06-24 19:12:55', 'Ambil di Tempat', 'siska88@gmail.com', 13, 'gawati55@mail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (39, 'Selesai', 897481.45, 'Transfer Bank', NULL, '2025-03-15 19:12:55', 'Instant Courier', 'cinta78@outlook.com', 68, 'najib31@hotmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (40, 'Dibatalkan', 910491.24, 'Kartu Kredit', NULL, '2025-04-17 19:12:55', 'Kurir Standar', 'pardi19@protonmail.com', 29, 'kani82@hotmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (41, 'Menunggu Pembayaran', 3331398.01, 'E-Wallet', NULL, '2024-12-07 19:12:55', 'Instant Courier', 'kani82@hotmail.com', 87, 'najib31@hotmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (42, 'Menunggu Pembayaran', 704847.52, 'COD', 'Nesciunt magni cupiditate sapiente ducimus.', '2024-12-01 19:12:55', 'Kurir Standar', 'mariadi4@outlook.com', 28, 'rudi57@aol.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (43, 'Menunggu Pembayaran', 764766.64, 'Kartu Kredit', NULL, '2025-03-14 19:12:55', 'Instant Courier', 'jati14@gmail.com', 69, 'abyasa18@protonmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (44, 'Dibatalkan', 569940.21, 'COD', NULL, '2025-03-01 19:12:55', 'Ambil di Tempat', 'gara24@hotmail.com', 84, 'siska88@gmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (45, 'Dibatalkan', 1419417.29, 'E-Wallet', NULL, '2024-07-11 19:12:55', 'Same Day', 'gara24@hotmail.com', 13, 'gara24@hotmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (46, 'Menunggu Pembayaran', 226005.54, 'Kartu Kredit', 'Et expedita modi dolorum explicabo occaecati modi minus.', '2024-10-29 19:12:55', 'Same Day', 'opung93@gmail.com', 66, 'ade21@protonmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (47, 'Diproses', 3702659.46, 'Kartu Kredit', 'Corrupti enim voluptatum ea magni id facilis accusantium.', '2025-05-07 19:12:55', 'Instant Courier', 'najib31@hotmail.com', 60, 'gawati55@mail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (48, 'Diproses', 2533009.7, 'Transfer Bank', NULL, '2024-10-20 19:12:55', 'Kurir Standar', 'kayla22@gmail.com', 41, 'ade21@protonmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (49, 'Selesai', 767212.55, 'E-Wallet', NULL, '2025-03-10 19:12:55', 'Same Day', 'jati14@gmail.com', 52, 'hairyanto16@aol.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (50, 'Diproses', 3284678.57, 'Kartu Kredit', NULL, '2025-02-03 19:12:55', 'Kurir Standar', 'siska88@gmail.com', 15, 'umar49@yahoo.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (51, 'Selesai', 1819527.0, 'E-Wallet', 'Quo autem repellat quas possimus impedit est.', '2024-06-05 19:12:55', 'Instant Courier', 'heru90@hotmail.com', 55, 'naradi89@yahoo.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (52, 'Dikirim', 2521748.01, 'Transfer Bank', NULL, '2024-09-11 19:12:55', 'Instant Courier', 'heru90@hotmail.com', 33, 'umi33@outlook.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (53, 'Dikirim', 2213303.9, 'COD', 'Harum ullam suscipit.', '2024-09-05 19:12:55', 'Instant Courier', 'irsad44@protonmail.com', 96, 'harimurti12@outlook.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (54, 'Dikirim', 4195329.78, 'COD', 'Temporibus totam deserunt maxime repellat.', '2024-07-03 19:12:55', 'Same Day', 'irsad44@protonmail.com', 47, 'talia73@yahoo.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (55, 'Menunggu Pembayaran', 4801169.15, 'Transfer Bank', 'Odit voluptatibus aspernatur aperiam modi cum.', '2025-01-20 19:12:55', 'Ambil di Tempat', 'jati14@gmail.com', 1, 'abyasa18@protonmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (56, 'Dibatalkan', 2207985.4, 'E-Wallet', 'Esse nobis ipsam voluptatum non ducimus temporibus.', '2024-08-22 19:12:55', 'Kurir Standar', 'edi69@hotmail.com', 84, 'kani82@hotmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (57, 'Dibatalkan', 4615911.01, 'COD', NULL, '2024-09-05 19:12:55', 'Kurir Standar', 'hairyanto16@aol.com', 81, 'umar49@yahoo.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (58, 'Menunggu Pembayaran', 2218642.78, 'Kartu Kredit', 'Perspiciatis fuga et incidunt dolorum ratione minus.', '2024-08-18 19:12:55', 'Kurir Standar', 'ophelia59@protonmail.com', 72, 'kani82@hotmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (59, 'Selesai', 2497054.07, 'Kartu Kredit', NULL, '2025-03-29 19:12:55', 'Instant Courier', 'laswi20@aol.com', 80, 'naradi89@yahoo.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (60, 'Selesai', 4716720.16, 'COD', 'Fugit veniam tempora ratione.', '2025-01-18 19:12:55', 'Instant Courier', 'rini42@yahoo.com', 48, 'kani82@hotmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (61, 'Dibatalkan', 653837.33, 'Transfer Bank', NULL, '2024-05-21 19:12:55', 'Instant Courier', 'mariadi4@outlook.com', 32, 'umar49@yahoo.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (62, 'Diproses', 1970866.47, 'COD', NULL, '2025-03-10 19:12:55', 'Same Day', 'rangga32@gmail.com', 7, 'gilda79@gmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (63, 'Selesai', 2526694.06, 'Transfer Bank', NULL, '2025-04-03 19:12:55', 'Kurir Standar', 'luis86@protonmail.com', 72, 'talia73@yahoo.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (64, 'Dibatalkan', 1637546.58, 'Kartu Kredit', NULL, '2025-01-02 19:12:55', 'Instant Courier', 'jati14@gmail.com', 37, 'ade21@protonmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (65, 'Dikirim', 4413207.27, 'COD', 'Magnam nihil cupiditate omnis repudiandae accusamus dolorum.', '2024-07-19 19:12:55', 'Same Day', 'rangga32@gmail.com', 67, 'ade21@protonmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (66, 'Selesai', 516760.46, 'Transfer Bank', 'Et exercitationem dolorem natus itaque similique.', '2024-07-17 19:12:55', 'Ambil di Tempat', 'prayitna38@gmail.com', 91, 'abyasa18@protonmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (67, 'Selesai', 3116976.76, 'Transfer Bank', 'Non quia sapiente sapiente.', '2025-03-31 19:12:55', 'Kurir Standar', 'opung93@gmail.com', 85, 'umi33@outlook.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (68, 'Dibatalkan', 506113.45, 'Transfer Bank', NULL, '2025-03-19 19:12:55', 'Kurir Standar', 'luis86@protonmail.com', 87, 'najib31@hotmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (69, 'Diproses', 4902091.5, 'COD', 'Accusamus illo cum soluta voluptate explicabo.', '2024-09-07 19:12:55', 'Kurir Standar', 'kayla22@gmail.com', 74, 'siska88@gmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (70, 'Selesai', 839398.67, 'COD', 'Sapiente magni consectetur voluptate quis a ab.', '2025-04-11 19:12:55', 'Same Day', 'jati14@gmail.com', 44, 'gara24@hotmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (71, 'Dikirim', 1693728.6, 'COD', NULL, '2025-02-16 19:12:55', 'Ambil di Tempat', 'najib31@hotmail.com', 94, 'najib31@hotmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (72, 'Dikirim', 4040724.8, 'Kartu Kredit', 'Quos quasi at beatae nesciunt ullam.', '2024-06-21 19:12:55', 'Instant Courier', 'kusuma34@gmail.com', 23, 'umi33@outlook.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (73, 'Dibatalkan', 3140109.25, 'E-Wallet', 'Rerum officia modi recusandae omnis eveniet necessitatibus.', '2025-02-10 19:12:55', 'Ambil di Tempat', 'gilda79@gmail.com', 33, 'luis86@protonmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (74, 'Selesai', 2194145.04, 'Transfer Bank', 'Voluptatum omnis laudantium iste laboriosam quia a.', '2024-05-17 19:12:55', 'Same Day', 'ade21@protonmail.com', 44, 'talia73@yahoo.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (75, 'Dikirim', 1790638.14, 'COD', NULL, '2024-09-12 19:12:55', 'Kurir Standar', 'ophelia59@protonmail.com', 96, 'ophelia59@protonmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (76, 'Menunggu Pembayaran', 1060427.32, 'Kartu Kredit', 'Consequatur delectus autem repellat.', '2024-11-14 19:12:55', 'Kurir Standar', 'ophelia59@protonmail.com', 87, 'naradi89@yahoo.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (77, 'Selesai', 1212623.41, 'Kartu Kredit', 'Eaque eius ipsa aut ratione voluptates.', '2024-09-30 19:12:55', 'Kurir Standar', 'laswi20@aol.com', 21, 'gara24@hotmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (78, 'Diproses', 585996.21, 'COD', 'Numquam voluptas quaerat aut suscipit impedit.', '2024-07-12 19:12:55', 'Same Day', 'gilda79@gmail.com', 5, 'umar49@yahoo.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (79, 'Diproses', 1636596.29, 'Transfer Bank', 'Rem voluptatum id quia praesentium debitis fugit quia.', '2024-12-27 19:12:55', 'Same Day', 'prayitna38@gmail.com', 5, 'umar49@yahoo.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (80, 'Diproses', 3546627.96, 'Kartu Kredit', 'Dicta minus ad consectetur.', '2024-12-01 19:12:55', 'Ambil di Tempat', 'irnanto43@protonmail.com', 65, 'hairyanto16@aol.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (81, 'Menunggu Pembayaran', 493758.01, 'Kartu Kredit', NULL, '2025-03-27 19:12:55', 'Instant Courier', 'kayla22@gmail.com', 8, 'gara24@hotmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (82, 'Dikirim', 1417455.76, 'E-Wallet', 'Ipsa et dolor laboriosam beatae cum animi error.', '2024-12-05 19:12:55', 'Kurir Standar', 'kani82@hotmail.com', 47, 'siska88@gmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (83, 'Diproses', 3869560.53, 'E-Wallet', NULL, '2024-06-26 19:12:55', 'Same Day', 'hairyanto16@aol.com', 70, 'nugraha66@mail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (84, 'Selesai', 3505128.94, 'Transfer Bank', 'Est ipsum corrupti eos.', '2025-04-26 19:12:55', 'Ambil di Tempat', 'atma30@outlook.com', 50, 'umar49@yahoo.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (85, 'Diproses', 384623.58, 'COD', 'Aut impedit eos debitis.', '2025-02-18 19:12:55', 'Ambil di Tempat', 'gara24@hotmail.com', 93, 'ophelia59@protonmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (86, 'Selesai', 4891018.1, 'COD', NULL, '2025-04-26 19:12:55', 'Kurir Standar', 'umi33@outlook.com', 89, 'harimurti12@outlook.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (87, 'Menunggu Pembayaran', 599539.11, 'E-Wallet', NULL, '2025-03-09 19:12:55', 'Kurir Standar', 'oni39@yahoo.com', 14, 'gara24@hotmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (88, 'Menunggu Pembayaran', 1715166.52, 'Transfer Bank', 'Inventore fugit quaerat molestias.', '2025-04-05 19:12:55', 'Instant Courier', 'luis86@protonmail.com', 10, 'abyasa18@protonmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (89, 'Diproses', 3806940.83, 'COD', 'Laboriosam error earum quia.', '2024-06-13 19:12:55', 'Kurir Standar', 'gara24@hotmail.com', 55, 'ophelia59@protonmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (90, 'Dikirim', 1844590.72, 'Transfer Bank', 'Architecto praesentium nemo molestiae.', '2024-06-14 19:12:55', 'Instant Courier', 'naradi89@yahoo.com', 66, 'najib31@hotmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (91, 'Dikirim', 1261432.45, 'COD', NULL, '2024-11-07 19:12:55', 'Kurir Standar', 'gawati55@mail.com', 37, 'talia73@yahoo.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (92, 'Selesai', 572168.61, 'Transfer Bank', NULL, '2024-06-11 19:12:55', 'Same Day', 'siska88@gmail.com', 59, 'talia73@yahoo.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (93, 'Selesai', 880334.72, 'Kartu Kredit', NULL, '2024-07-14 19:12:55', 'Instant Courier', 'kayla22@gmail.com', 38, 'nugraha66@mail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (94, 'Menunggu Pembayaran', 4016945.45, 'E-Wallet', 'Reiciendis odio velit nisi dolor eaque.', '2025-04-14 19:12:55', 'Kurir Standar', 'ophelia59@protonmail.com', 73, 'harimurti12@outlook.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (95, 'Dibatalkan', 2112521.3, 'E-Wallet', 'Sit molestias aperiam nostrum delectus maxime eveniet.', '2025-03-29 19:12:55', 'Same Day', 'rini42@yahoo.com', 86, 'rudi57@aol.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (96, 'Diproses', 1052106.2, 'COD', 'Corrupti aut magni impedit cum.', '2025-02-13 19:12:55', 'Kurir Standar', 'vivi67@mail.com', 21, 'ade21@protonmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (97, 'Selesai', 237492.87, 'Kartu Kredit', 'In doloremque quas doloribus excepturi.', '2024-08-16 19:12:55', 'Instant Courier', 'cornelia71@outlook.com', 96, 'gawati55@mail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (98, 'Dibatalkan', 2291700.47, 'E-Wallet', 'Voluptatibus quisquam doloremque inventore delectus.', '2024-06-15 19:12:55', 'Ambil di Tempat', 'atma30@outlook.com', 26, 'gawati55@mail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (99, 'Menunggu Pembayaran', 3369647.64, 'Transfer Bank', NULL, '2024-11-26 19:12:55', 'Ambil di Tempat', 'siska88@gmail.com', 78, 'siska88@gmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (100, 'Dibatalkan', 3995757.58, 'Transfer Bank', NULL, '2024-09-22 19:12:55', 'Ambil di Tempat', 'vivi67@mail.com', 67, 'ade21@protonmail.com');
-- Total pesanan: 100

-- INSERT INTO rincian_pesanan
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (1, 109, '109-WHITE', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (1, 109, '109-GREEN', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (1, 109, '109-RED-30', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (2, 57, '57-BLUE-L', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (2, 59, '59-NAVY', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (3, 66, '66-BLUE-30', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (3, 58, '58-RED', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (3, 57, '57-NAVY-M', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (4, 25, '25-NAVY', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (4, 25, '25-WHITE', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (4, 30, '30-GREY', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (5, 107, '107-NAVY', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (5, 106, '106-GREY-32', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (6, 89, '89-WHITE-L', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (7, 2, '2-GREY', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (8, 129, '129-BLUE', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (8, 124, '124-BLACK', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (9, 22, '22-BLUE-28', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (9, 13, '13-GREEN', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (10, 176, '176-GREY-L', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (10, 166, '166-BLUE', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (10, 175, '175-BLUE', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (11, 197, '197-BLUE-30', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (11, 197, '197-WHITE', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (11, 192, '192-RED-32', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (12, 96, '96-GREY', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (12, 95, '95-GREEN-L', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (13, 17, '17-NAVY', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (13, 16, '16-BLACK-S', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (13, 15, '15-GREY', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (14, 139, '139-BLACK-L', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (14, 139, '139-WHITE-30', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (15, 175, '175-NAVY', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (15, 173, '173-NAVY', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (15, 166, '166-GREY', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (16, 26, '26-RED', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (16, 29, '29-GREEN-S', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (17, 140, '140-RED', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (17, 139, '139-WHITE-30', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (18, 55, '55-WHITE', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (19, 86, '86-GREEN-30', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (19, 86, '86-NAVY', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (20, 196, '196-WHITE', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (20, 194, '194-BLACK-L', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (20, 194, '194-GREEN', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (21, 88, '88-BLACK-30', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (21, 84, '84-BLACK-S', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (22, 96, '96-RED', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (22, 93, '93-RED', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (23, 61, '61-RED-32', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (23, 64, '64-BLUE-S', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (24, 71, '71-BLUE', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (25, 93, '93-WHITE', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (25, 94, '94-GREY', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (25, 97, '97-GREY', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (26, 99, '99-WHITE-30', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (26, 96, '96-GREY', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (26, 93, '93-RED', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (27, 174, '174-GREY', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (27, 168, '168-NAVY-S', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (28, 32, '32-GREY-L', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (28, 24, '24-RED-S', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (28, 32, '32-GREEN', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (29, 173, '173-NAVY', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (29, 174, '174-GREY', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (29, 166, '166-NAVY-30', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (30, 42, '42-GREY', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (30, 36, '36-NAVY', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (31, 193, '193-BLUE-L', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (32, 15, '15-WHITE', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (33, 151, '151-GREEN-L', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (33, 152, '152-WHITE', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (34, 151, '151-GREEN-L', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (34, 153, '153-NAVY-L', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (35, 49, '49-NAVY', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (36, 144, '144-NAVY-M', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (36, 151, '151-BLUE-30', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (37, 31, '31-NAVY-30', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (37, 25, '25-WHITE', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (37, 25, '25-NAVY', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (38, 8, '8-WHITE', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (39, 186, '186-NAVY-M', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (39, 184, '184-BLUE', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (39, 178, '178-NAVY', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (40, 165, '165-BLACK', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (40, 155, '155-GREEN', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (40, 157, '157-RED-28', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (41, 179, '179-NAVY-30', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (41, 186, '186-NAVY-M', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (42, 28, '28-BLUE', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (43, 13, '13-GREEN-L', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (44, 98, '98-GREEN-S', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (44, 94, '94-GREEN', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (44, 98, '98-GREEN-30', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (45, 47, '47-BLACK-30', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (45, 49, '49-BLUE-32', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (46, 57, '57-WHITE', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (46, 56, '56-BLACK', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (47, 7, '7-NAVY', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (48, 63, '63-NAVY', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (48, 58, '58-RED-S', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (49, 125, '125-BLACK', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (50, 107, '107-BLUE-S', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (50, 109, '109-NAVY-32', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (50, 104, '104-GREEN-S', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (51, 144, '144-NAVY-M', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (52, 117, '117-GREEN-L', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (53, 35, '35-GREEN', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (54, 190, '190-GREY-S', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (55, 20, '20-RED-28', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (55, 12, '12-NAVY', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (55, 15, '15-GREY', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (56, 159, '159-GREEN', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (56, 163, '163-GREY', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (57, 107, '107-BLUE-S', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (58, 158, '158-RED', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (59, 149, '149-GREY', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (60, 165, '165-GREEN', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (60, 161, '161-BLACK-L', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (61, 103, '103-BLUE-M', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (61, 100, '100-BLUE', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (61, 110, '110-BLUE', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (62, 87, '87-RED', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (62, 80, '80-GREY-S', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (63, 192, '192-RED-32', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (63, 197, '197-BLUE-30', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (63, 195, '195-BLACK', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (64, 57, '57-NAVY-M', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (64, 60, '60-NAVY', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (64, 64, '64-BLUE-S', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (65, 60, '60-GREEN-S', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (66, 22, '22-BLACK-L', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (67, 119, '119-BLUE-M', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (67, 121, '121-BLACK-M', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (67, 119, '119-GREEN-M', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (68, 179, '179-GREY-30', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (68, 181, '181-GREEN-32', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (69, 93, '93-WHITE', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (70, 54, '54-WHITE-S', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (71, 178, '178-GREY', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (71, 184, '184-BLUE', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (71, 180, '180-BLUE-32', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (72, 118, '118-GREEN', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (72, 111, '111-GREEN-M', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (72, 113, '113-NAVY', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (73, 170, '170-NAVY', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (73, 171, '171-GREY-32', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (74, 189, '189-BLUE-32', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (74, 195, '195-BLACK', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (74, 191, '191-RED', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (75, 135, '135-GREY-M', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (75, 140, '140-BLUE', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (76, 148, '148-WHITE-30', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (76, 151, '151-GREEN-L', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (76, 149, '149-GREY', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (77, 52, '52-BLUE', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (77, 51, '51-GREY-L', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (77, 49, '49-BLUE-32', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (78, 107, '107-BLUE-S', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (79, 102, '102-BLUE-S', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (79, 108, '108-GREEN', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (79, 109, '109-RED-30', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (80, 122, '122-BLACK-32', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (80, 129, '129-NAVY', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (80, 130, '130-RED-28', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (81, 50, '50-GREEN-30', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (82, 94, '94-BLUE-28', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (82, 95, '95-WHITE-30', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (82, 90, '90-BLUE-S', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (83, 71, '71-WHITE-S', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (83, 77, '77-BLACK-L', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (83, 77, '77-GREEN', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (84, 106, '106-BLUE', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (85, 136, '136-RED-30', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (85, 142, '142-RED-32', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (85, 143, '143-GREY-S', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (86, 37, '37-RED-S', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (86, 42, '42-BLACK-S', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (86, 37, '37-GREEN-M', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (87, 53, '53-GREEN-L', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (87, 47, '47-GREY-L', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (88, 21, '21-GREY-28', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (88, 19, '19-NAVY-M', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (88, 17, '17-BLACK-32', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (89, 142, '142-NAVY', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (90, 181, '181-GREEN-32', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (90, 187, '187-GREEN', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (91, 194, '194-GREEN', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (92, 194, '194-BLACK-L', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (92, 189, '189-BLUE-32', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (92, 198, '198-BLACK', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (93, 72, '72-BLACK', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (93, 76, '76-BLACK-28', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (93, 69, '69-GREEN-30', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (94, 43, '43-BLACK', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (94, 44, '44-NAVY-L', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (95, 31, '31-NAVY-30', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (95, 31, '31-NAVY-L', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (96, 66, '66-BLACK', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (96, 56, '56-BLUE-32', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (96, 59, '59-NAVY', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (97, 10, '10-NAVY-30', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (97, 8, '8-WHITE', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (98, 1, '1-WHITE-L', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (99, 94, '94-BLUE-28', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (99, 96, '96-GREY', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (99, 97, '97-WHITE-30', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (100, 59, '59-NAVY', 5);
-- Total rincian_pesanan: 208

-- INSERT INTO ulasan
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('cemplunk31@aol.com', 10, 'Debitis autem iusto. Ipsam temporibus non laboriosam culpa.', 4.0);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('rachel31@mail.com', 46, 'Beatae quas iusto quod ab laboriosam nesciunt. Nam dolores alias corporis.', 2.4);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('kayla22@gmail.com', 67, 'Nesciunt nam hic vitae exercitationem dignissimos quos. Rerum numquam culpa asperiores blanditiis fugit. Magnam voluptatem pariatur hic magni quaerat sapiente aliquam. Autem doloribus porro doloremque nulla repellat tempora.', 1.3);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('oni39@yahoo.com', 21, 'Hic eos similique. Quas nemo veniam sequi. Facere ducimus illo voluptate asperiores aut.', 1.4);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('kusuma34@gmail.com', 74, NULL, 3.2);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('jati14@gmail.com', 90, NULL, 2.4);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('oni39@yahoo.com', 10, 'Reprehenderit dolore iusto excepturi sed veritatis consequuntur. Cum non minima incidunt dolor sapiente dolorum. Odio eaque magni ea.', 0.3);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('najib31@hotmail.com', 17, NULL, 3.9);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('umar49@yahoo.com', 5, 'Aliquid harum consequuntur fugit at at possimus. Maiores quis nisi expedita.', 0.7);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('atma30@outlook.com', 60, NULL, 3.3);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('kusuma34@gmail.com', 63, 'Officia ut optio consectetur. Iste suscipit qui in incidunt enim exercitationem eligendi. Neque architecto est vel.', 3.6);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('oni39@yahoo.com', 28, 'Voluptas asperiores autem perferendis cumque rem. Iste similique iure ut assumenda delectus dolorem quod. Rem ratione dolore tempora asperiores doloribus blanditiis.', 2.9);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('nasim25@aol.com', 53, NULL, 3.2);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('mariadi4@outlook.com', 41, 'Atque voluptatem enim voluptas quod sunt accusamus. Distinctio itaque laudantium soluta ad nobis at.', 3.4);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('umar49@yahoo.com', 100, NULL, 1.5);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('cornelia71@outlook.com', 36, NULL, 0.4);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('nasim25@aol.com', 3, NULL, 3.4);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('irnanto43@protonmail.com', 61, NULL, 1.5);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('ade21@protonmail.com', 57, NULL, 4.0);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('mariadi4@outlook.com', 51, 'Aperiam quasi cum earum in iusto molestias alias. Ab quaerat beatae vel nam magnam. Porro laboriosam placeat tenetur.', 0.6);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('siska88@gmail.com', 25, 'Animi ea dolor. Maiores soluta harum impedit omnis fugit sapiente. Unde assumenda aliquid minus sint. Officia laudantium architecto dignissimos ipsam.', 0.5);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('gara24@hotmail.com', 48, 'Nesciunt vitae quam suscipit non occaecati. Quos fugit vero dolore laboriosam. Porro consectetur maiores blanditiis in praesentium assumenda.', 4.9);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('rini42@yahoo.com', 72, 'Eligendi tenetur impedit delectus hic. Provident perspiciatis temporibus fugit fugit.', 0.7);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('rini42@yahoo.com', 46, 'Perferendis magni deserunt quaerat quae dolorum. Molestiae eligendi minus at quo.', 0.7);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('irnanto43@protonmail.com', 7, 'Quo itaque quasi maiores inventore. Cum aperiam nihil inventore.', 1.6);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('laswi20@aol.com', 96, NULL, 3.0);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('laswi20@aol.com', 71, NULL, 3.5);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('prayitna38@gmail.com', 73, NULL, 3.2);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('gara24@hotmail.com', 63, NULL, 0.9);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('heru90@hotmail.com', 85, 'Saepe praesentium quibusdam cum cum ut. Cumque provident tempore rerum.', 3.6);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('rangga32@gmail.com', 96, 'A molestiae qui labore accusantium. Iusto unde aperiam vero. Fugiat autem reprehenderit nobis.', 3.5);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('cornelia71@outlook.com', 55, 'Tempora porro ea quisquam necessitatibus. Natus quas officia omnis. Perspiciatis soluta amet totam quaerat.', 4.7);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('cornelia71@outlook.com', 93, NULL, 3.8);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('heru90@hotmail.com', 60, 'Qui inventore incidunt aliquam dolor. Delectus laudantium incidunt temporibus animi laudantium iure.', 2.3);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('kusuma34@gmail.com', 84, 'Consequuntur ut at sint. Expedita repellendus officia dolores. Odio accusamus consectetur voluptas impedit inventore.', 4.9);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('ade21@protonmail.com', 48, NULL, 2.5);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('pardi19@protonmail.com', 53, NULL, 1.5);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('irnanto43@protonmail.com', 8, NULL, 4.6);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('siska88@gmail.com', 43, NULL, 2.5);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('vivi67@mail.com', 71, NULL, 3.0);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('asmianto10@yahoo.com', 33, NULL, 1.4);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('opung93@gmail.com', 65, 'Quod consequuntur enim quisquam adipisci recusandae. Commodi voluptatem quas cupiditate.', 4.9);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('kusuma34@gmail.com', 18, NULL, 1.0);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('mariadi4@outlook.com', 7, 'Laudantium distinctio vero.', 0.4);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('rini42@yahoo.com', 30, NULL, 2.4);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('cinta78@outlook.com', 20, 'Optio dolores animi. Pariatur totam laboriosam quia amet.', 3.7);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('gilda79@gmail.com', 2, 'Eius sint voluptate dicta. Possimus eaque eius adipisci aliquam laboriosam. Quidem quasi nemo perferendis ipsum impedit corporis.', 4.1);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('vivi67@mail.com', 41, NULL, 1.1);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('ophelia59@protonmail.com', 78, NULL, 2.2);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('rini42@yahoo.com', 9, 'Itaque atque a quam ex doloribus atque eligendi. Explicabo quaerat quod.', 3.4);
-- Total ulasan: 50

-- INSERT INTO wishlist
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (1, 'heru90@hotmail.com', 'Wishlist 8');
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (2, 'heru90@hotmail.com', NULL);
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (3, 'gawati55@mail.com', 'Wishlist 1');
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (4, 'gawati55@mail.com', NULL);
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (5, 'opung93@gmail.com', 'Wishlist 2');
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (6, 'opung93@gmail.com', 'Wishlist 1');
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (7, 'opung93@gmail.com', NULL);
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (8, 'cemplunk31@aol.com', NULL);
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (9, 'cemplunk31@aol.com', NULL);
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (10, 'vivi67@mail.com', 'Wishlist 10');
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (11, 'vivi67@mail.com', 'Wishlist 7');
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (12, 'vivi67@mail.com', NULL);
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (13, 'gara24@hotmail.com', NULL);
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (14, 'gara24@hotmail.com', NULL);
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (15, 'gara24@hotmail.com', 'Wishlist 9');
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (16, 'ade21@protonmail.com', NULL);
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (17, 'ade21@protonmail.com', NULL);
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (18, 'rachel31@mail.com', NULL);
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (19, 'laswi20@aol.com', NULL);
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (20, 'edi69@hotmail.com', 'Wishlist 6');
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (21, 'oni39@yahoo.com', 'Wishlist 8');
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (22, 'jati14@gmail.com', NULL);
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (23, 'jati14@gmail.com', 'Wishlist 4');
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (24, 'nasim25@aol.com', NULL);
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (25, 'irnanto43@protonmail.com', NULL);
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (26, 'irnanto43@protonmail.com', NULL);
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (27, 'irnanto43@protonmail.com', NULL);
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (28, 'gilda79@gmail.com', 'Wishlist 10');
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (29, 'siska88@gmail.com', NULL);
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (30, 'siska88@gmail.com', NULL);
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (31, 'siska88@gmail.com', 'Wishlist 3');
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (32, 'cinta78@outlook.com', NULL);
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (33, 'cinta78@outlook.com', NULL);
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (34, 'cinta78@outlook.com', NULL);
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (35, 'rangga32@gmail.com', NULL);
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (36, 'rangga32@gmail.com', 'Wishlist 10');
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (37, 'kusuma34@gmail.com', NULL);
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (38, 'kusuma34@gmail.com', NULL);
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (39, 'kusuma34@gmail.com', 'Wishlist 9');
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (40, 'mariadi4@outlook.com', 'Wishlist 7');
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (41, 'mariadi4@outlook.com', 'Wishlist 4');
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (42, 'mariadi4@outlook.com', 'Wishlist 8');
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (43, 'cornelia71@outlook.com', 'Wishlist 7');
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (44, 'cornelia71@outlook.com', 'Wishlist 9');
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (45, 'cornelia71@outlook.com', 'Wishlist 1');
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (46, 'atma30@outlook.com', NULL);
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (47, 'atma30@outlook.com', NULL);
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (48, 'umar49@yahoo.com', NULL);
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (49, 'umar49@yahoo.com', 'Wishlist 4');
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (50, 'umi33@outlook.com', 'Wishlist 1');
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (51, 'hairyanto16@aol.com', 'Wishlist 1');
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (52, 'hairyanto16@aol.com', NULL);
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (53, 'hairyanto16@aol.com', NULL);
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (54, 'pardi19@protonmail.com', 'Wishlist 8');
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (55, 'ophelia59@protonmail.com', NULL);
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (56, 'ophelia59@protonmail.com', NULL);
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (57, 'naradi89@yahoo.com', NULL);
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (58, 'naradi89@yahoo.com', NULL);
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (59, 'naradi89@yahoo.com', NULL);
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (60, 'kani82@hotmail.com', 'Wishlist 3');
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (61, 'kani82@hotmail.com', NULL);
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (62, 'kayla22@gmail.com', 'Wishlist 10');
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (63, 'kayla22@gmail.com', NULL);
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (64, 'kayla22@gmail.com', NULL);
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (65, 'luis86@protonmail.com', 'Wishlist 1');
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (66, 'irsad44@protonmail.com', NULL);
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (67, 'asmianto10@yahoo.com', 'Wishlist 1');
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (68, 'asmianto10@yahoo.com', 'Wishlist 2');
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (69, 'prayitna38@gmail.com', 'Wishlist 3');
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (70, 'prayitna38@gmail.com', NULL);
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (71, 'rini42@yahoo.com', NULL);
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (72, 'najib31@hotmail.com', 'Wishlist 5');
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (73, 'najib31@hotmail.com', 'Wishlist 9');
INSERT INTO wishlist (wishlist_id, email_pembeli, nama_wishlist)
                     VALUES (74, 'najib31@hotmail.com', 'Wishlist 7');
-- Total wishlist: 74

-- INSERT INTO keranjang
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (1, 'heru90@hotmail.com', 'Keranjang 7');
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (2, 'gawati55@mail.com', 'Keranjang 1');
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (3, 'gawati55@mail.com', NULL);
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (4, 'opung93@gmail.com', 'Keranjang 9');
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (5, 'opung93@gmail.com', NULL);
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (6, 'cemplunk31@aol.com', 'Keranjang 10');
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (7, 'cemplunk31@aol.com', NULL);
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (8, 'vivi67@mail.com', 'Keranjang 3');
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (9, 'gara24@hotmail.com', NULL);
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (10, 'gara24@hotmail.com', 'Keranjang 10');
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (11, 'gara24@hotmail.com', 'Keranjang 10');
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (12, 'ade21@protonmail.com', 'Keranjang 1');
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (13, 'ade21@protonmail.com', NULL);
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (14, 'rachel31@mail.com', NULL);
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (15, 'rachel31@mail.com', 'Keranjang 7');
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (16, 'laswi20@aol.com', NULL);
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (17, 'edi69@hotmail.com', 'Keranjang 10');
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (18, 'oni39@yahoo.com', 'Keranjang 5');
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (19, 'oni39@yahoo.com', 'Keranjang 7');
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (20, 'jati14@gmail.com', NULL);
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (21, 'nasim25@aol.com', 'Keranjang 10');
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (22, 'nasim25@aol.com', NULL);
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (23, 'irnanto43@protonmail.com', 'Keranjang 1');
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (24, 'irnanto43@protonmail.com', 'Keranjang 6');
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (25, 'irnanto43@protonmail.com', 'Keranjang 3');
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (26, 'gilda79@gmail.com', 'Keranjang 4');
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (27, 'gilda79@gmail.com', NULL);
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (28, 'siska88@gmail.com', 'Keranjang 7');
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (29, 'siska88@gmail.com', NULL);
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (30, 'cinta78@outlook.com', NULL);
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (31, 'cinta78@outlook.com', 'Keranjang 9');
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (32, 'cinta78@outlook.com', 'Keranjang 3');
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (33, 'rangga32@gmail.com', NULL);
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (34, 'rangga32@gmail.com', NULL);
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (35, 'rangga32@gmail.com', 'Keranjang 1');
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (36, 'kusuma34@gmail.com', 'Keranjang 10');
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (37, 'mariadi4@outlook.com', NULL);
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (38, 'mariadi4@outlook.com', NULL);
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (39, 'mariadi4@outlook.com', NULL);
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (40, 'cornelia71@outlook.com', NULL);
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (41, 'cornelia71@outlook.com', NULL);
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (42, 'atma30@outlook.com', NULL);
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (43, 'atma30@outlook.com', NULL);
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (44, 'atma30@outlook.com', NULL);
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (45, 'umar49@yahoo.com', NULL);
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (46, 'umi33@outlook.com', 'Keranjang 4');
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (47, 'umi33@outlook.com', 'Keranjang 1');
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (48, 'umi33@outlook.com', NULL);
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (49, 'hairyanto16@aol.com', 'Keranjang 2');
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (50, 'hairyanto16@aol.com', NULL);
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (51, 'pardi19@protonmail.com', NULL);
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (52, 'pardi19@protonmail.com', NULL);
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (53, 'pardi19@protonmail.com', 'Keranjang 9');
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (54, 'ophelia59@protonmail.com', NULL);
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (55, 'ophelia59@protonmail.com', NULL);
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (56, 'naradi89@yahoo.com', 'Keranjang 6');
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (57, 'naradi89@yahoo.com', 'Keranjang 2');
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (58, 'kani82@hotmail.com', 'Keranjang 7');
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (59, 'kani82@hotmail.com', 'Keranjang 5');
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (60, 'kani82@hotmail.com', NULL);
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (61, 'kayla22@gmail.com', 'Keranjang 7');
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (62, 'kayla22@gmail.com', NULL);
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (63, 'kayla22@gmail.com', 'Keranjang 7');
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (64, 'luis86@protonmail.com', NULL);
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (65, 'luis86@protonmail.com', 'Keranjang 5');
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (66, 'irsad44@protonmail.com', 'Keranjang 2');
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (67, 'asmianto10@yahoo.com', 'Keranjang 8');
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (68, 'asmianto10@yahoo.com', NULL);
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (69, 'asmianto10@yahoo.com', NULL);
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (70, 'prayitna38@gmail.com', 'Keranjang 2');
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (71, 'prayitna38@gmail.com', 'Keranjang 6');
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (72, 'rini42@yahoo.com', NULL);
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (73, 'rini42@yahoo.com', 'Keranjang 9');
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (74, 'najib31@hotmail.com', NULL);
INSERT INTO keranjang (keranjang_id, email_pembeli, nama_keranjang)
                     VALUES (75, 'najib31@hotmail.com', NULL);
-- Total keranjang: 75

-- INSERT INTO rincian_wishlist
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (1, 97);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (1, 125);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (1, 157);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (1, 85);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (1, 53);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (2, 103);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (2, 169);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (2, 12);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (3, 185);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (4, 65);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (4, 36);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (5, 97);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (5, 2);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (6, 57);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (6, 86);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (6, 56);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (7, 62);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (8, 34);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (8, 97);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (8, 196);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (9, 129);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (10, 87);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (10, 48);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (11, 129);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (11, 168);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (11, 131);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (12, 64);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (12, 104);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (12, 18);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (12, 186);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (13, 93);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (13, 115);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (13, 137);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (14, 2);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (14, 189);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (14, 125);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (15, 15);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (15, 81);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (16, 104);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (17, 173);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (17, 10);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (17, 57);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (17, 83);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (18, 25);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (18, 177);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (18, 78);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (19, 149);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (19, 17);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (19, 78);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (20, 180);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (20, 197);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (20, 24);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (20, 98);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (20, 151);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (21, 59);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (21, 118);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (21, 117);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (22, 129);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (23, 99);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (24, 122);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (24, 70);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (24, 189);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (25, 121);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (25, 192);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (25, 187);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (25, 182);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (26, 39);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (26, 69);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (26, 197);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (26, 67);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (27, 22);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (27, 137);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (28, 183);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (29, 62);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (29, 66);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (29, 72);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (29, 102);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (29, 191);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (30, 18);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (30, 6);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (30, 91);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (31, 58);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (32, 149);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (33, 141);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (33, 27);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (34, 160);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (34, 18);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (34, 134);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (34, 90);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (35, 96);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (35, 132);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (36, 183);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (37, 118);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (37, 63);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (37, 175);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (37, 23);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (37, 15);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (38, 161);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (38, 20);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (38, 112);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (38, 127);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (38, 128);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (39, 16);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (39, 160);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (39, 113);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (40, 73);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (40, 133);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (40, 154);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (41, 190);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (41, 88);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (41, 169);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (41, 48);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (41, 57);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (42, 89);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (42, 31);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (42, 145);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (43, 130);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (44, 42);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (44, 5);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (44, 161);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (44, 128);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (45, 4);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (45, 138);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (46, 91);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (47, 151);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (47, 139);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (47, 53);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (47, 108);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (47, 180);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (48, 188);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (48, 136);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (48, 49);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (49, 133);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (50, 65);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (50, 195);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (50, 54);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (50, 105);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (51, 83);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (51, 157);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (51, 184);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (51, 189);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (51, 102);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (52, 37);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (52, 15);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (52, 195);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (53, 166);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (53, 5);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (53, 40);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (53, 182);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (53, 155);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (54, 3);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (54, 142);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (54, 59);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (54, 190);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (55, 57);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (55, 90);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (55, 98);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (55, 181);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (55, 170);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (56, 10);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (56, 193);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (56, 138);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (56, 132);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (57, 89);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (58, 64);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (58, 188);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (58, 42);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (58, 9);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (58, 126);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (59, 73);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (59, 124);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (59, 195);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (60, 184);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (60, 95);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (60, 151);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (60, 30);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (60, 130);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (61, 141);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (61, 15);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (62, 152);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (62, 174);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (62, 46);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (63, 95);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (63, 134);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (63, 179);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (63, 180);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (64, 33);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (65, 124);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (65, 44);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (65, 32);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (65, 77);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (66, 115);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (66, 90);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (67, 19);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (67, 4);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (68, 113);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (69, 184);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (69, 37);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (69, 116);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (69, 68);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (70, 83);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (70, 70);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (70, 185);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (71, 41);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (71, 127);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (72, 152);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (72, 67);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (72, 115);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (72, 122);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (72, 164);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (73, 81);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (73, 70);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (73, 98);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (73, 93);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (74, 40);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (74, 87);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (74, 2);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (74, 117);
-- Total rincian_wishlist: 218

-- INSERT INTO rincian_keranjang
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (1, 71, '71-GREY', 1);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (1, 145, '145-WHITE', 1);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (1, 103, '103-RED-L', 1);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (2, 78, '78-BLACK', 3);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (2, 8, '8-WHITE', 2);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (2, 93, '93-WHITE', 5);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (3, 50, '50-GREEN-30', 3);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (3, 31, '31-NAVY-30', 4);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (3, 114, '114-GREEN-S', 1);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (4, 92, '92-WHITE', 4);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (4, 154, '154-GREY-S', 3);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (5, 118, '118-BLUE-M', 4);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (5, 84, '84-BLACK', 3);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (6, 50, '50-GREEN-30', 4);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (6, 45, '45-BLUE', 3);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (7, 193, '193-BLUE-L', 2);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (7, 182, '182-BLUE-L', 4);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (7, 39, '39-GREEN-M', 4);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (8, 60, '60-BLUE', 2);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (9, 56, '56-NAVY-L', 3);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (10, 179, '179-GREY-30', 1);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (10, 2, '2-GREY', 3);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (11, 84, '84-BLACK', 3);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (12, 126, '126-GREEN-28', 3);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (12, 105, '105-BLUE-L', 5);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (13, 1, '1-WHITE-M', 1);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (13, 50, '50-BLUE-32', 2);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (14, 153, '153-GREEN', 1);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (14, 84, '84-BLACK', 3);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (15, 5, '5-NAVY-28', 2);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (15, 86, '86-NAVY', 5);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (16, 189, '189-WHITE', 2);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (16, 75, '75-BLACK', 4);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (17, 100, '100-BLUE', 5);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (18, 48, '48-BLUE', 4);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (19, 158, '158-BLUE-M', 4);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (19, 186, '186-GREY', 2);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (20, 32, '32-GREEN', 2);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (20, 149, '149-RED-30', 4);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (20, 76, '76-BLACK-28', 5);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (21, 9, '9-BLUE-30', 4);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (21, 81, '81-NAVY', 4);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (21, 147, '147-NAVY-32', 5);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (22, 164, '164-GREY-32', 4);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (22, 90, '90-BLUE-S', 4);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (23, 189, '189-BLUE-32', 4);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (23, 135, '135-GREEN-S', 3);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (24, 64, '64-NAVY', 5);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (25, 59, '59-WHITE', 4);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (25, 47, '47-BLACK-30', 5);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (25, 172, '172-RED', 1);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (26, 114, '114-RED', 5);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (26, 5, '5-NAVY', 3);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (27, 137, '137-BLACK', 1);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (27, 55, '55-WHITE', 5);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (28, 21, '21-GREY-L', 1);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (28, 24, '24-BLACK-32', 1);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (28, 44, '44-NAVY-L', 3);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (29, 146, '146-BLUE-M', 3);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (30, 109, '109-GREEN', 3);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (30, 148, '148-WHITE-30', 5);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (30, 151, '151-BLUE-30', 3);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (31, 178, '178-RED', 2);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (31, 120, '120-RED', 5);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (32, 52, '52-GREY-28', 4);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (32, 41, '41-GREEN-M', 1);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (32, 50, '50-BLUE-L', 4);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (33, 148, '148-GREY-M', 3);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (33, 177, '177-RED-30', 5);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (33, 24, '24-BLACK-32', 2);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (34, 89, '89-NAVY', 1);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (34, 97, '97-NAVY', 4);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (34, 168, '168-NAVY-S', 3);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (35, 176, '176-WHITE-S', 2);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (36, 116, '116-GREEN-L', 5);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (36, 130, '130-BLACK-L', 3);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (36, 84, '84-BLACK', 1);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (37, 153, '153-GREEN', 5);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (37, 160, '160-BLACK-28', 3);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (38, 30, '30-NAVY', 2);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (38, 173, '173-NAVY', 5);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (39, 116, '116-NAVY', 1);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (40, 161, '161-RED', 5);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (40, 155, '155-GREEN', 4);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (41, 102, '102-BLUE-M', 1);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (41, 177, '177-BLUE-32', 2);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (41, 89, '89-WHITE-L', 2);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (42, 175, '175-GREY', 4);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (43, 24, '24-BLACK-30', 2);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (43, 129, '129-BLUE', 2);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (43, 49, '49-GREEN', 5);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (44, 55, '55-RED', 4);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (44, 105, '105-RED-30', 2);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (44, 55, '55-WHITE', 1);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (45, 69, '69-WHITE-30', 4);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (45, 9, '9-BLUE-30', 3);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (45, 179, '179-GREY-30', 3);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (46, 157, '157-RED-30', 5);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (46, 7, '7-BLACK-28', 5);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (46, 19, '19-NAVY-M', 4);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (47, 120, '120-BLACK', 2);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (47, 11, '11-WHITE', 5);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (48, 63, '63-NAVY', 3);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (48, 167, '167-GREY-L', 5);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (48, 120, '120-GREY', 1);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (49, 129, '129-RED', 2);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (50, 90, '90-BLUE-S', 5);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (51, 104, '104-RED', 1);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (51, 197, '197-BLUE-30', 4);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (51, 13, '13-NAVY', 1);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (52, 174, '174-GREY', 2);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (52, 66, '66-BLACK', 2);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (52, 38, '38-WHITE-30', 1);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (53, 196, '196-NAVY', 4);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (53, 148, '148-NAVY', 3);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (54, 93, '93-RED', 5);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (55, 71, '71-WHITE-S', 2);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (56, 114, '114-RED', 1);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (57, 100, '100-NAVY-L', 2);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (57, 18, '18-GREY', 4);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (57, 9, '9-GREEN', 5);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (58, 85, '85-NAVY-32', 1);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (58, 75, '75-BLUE', 4);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (58, 66, '66-BLUE-30', 5);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (59, 72, '72-WHITE-30', 5);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (59, 15, '15-GREY', 4);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (59, 157, '157-BLUE', 1);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (60, 87, '87-BLUE', 4);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (60, 43, '43-GREY-28', 1);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (61, 68, '68-BLUE-S', 1);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (61, 145, '145-BLUE', 2);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (61, 16, '16-GREEN', 2);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (62, 1, '1-RED', 4);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (63, 6, '6-BLUE-S', 4);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (63, 87, '87-RED-32', 3);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (64, 48, '48-NAVY', 3);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (64, 198, '198-BLACK', 2);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (64, 133, '133-WHITE', 4);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (65, 153, '153-GREEN', 2);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (66, 190, '190-NAVY-S', 2);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (67, 156, '156-WHITE-30', 3);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (67, 131, '131-NAVY-30', 5);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (68, 73, '73-RED', 2);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (68, 164, '164-BLACK', 3);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (68, 80, '80-GREY-S', 4);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (69, 58, '58-RED-S', 1);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (69, 126, '126-GREY', 2);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (69, 193, '193-NAVY', 5);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (70, 7, '7-BLACK', 5);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (70, 153, '153-GREY-S', 2);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (70, 133, '133-RED', 2);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (71, 144, '144-GREEN-M', 1);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (71, 154, '154-GREY-S', 3);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (72, 109, '109-RED-30', 1);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (72, 114, '114-BLACK', 2);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (72, 159, '159-NAVY', 4);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (73, 65, '65-GREEN', 1);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (73, 99, '99-RED', 3);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (73, 170, '170-NAVY', 5);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (74, 48, '48-BLUE', 2);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (74, 29, '29-RED-32', 3);
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku, jumlah)
                         VALUES (75, 41, '41-GREEN', 3);
-- Total rincian_keranjang: 162