-- Validasi Email
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
VALUES ('test1@.com', 'pass123!@#', 'Test User', '+628123456789', '2000-01-01', NULL, TRUE, TRUE);

--Query Manipulasi
DELIMITER //

CREATE TRIGGER validate_pengguna_email
BEFORE INSERT ON pengguna
FOR EACH ROW
BEGIN
    IF NEW.email NOT REGEXP '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.com$' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Format email tidak valid. Harus berupa <...>@<...>.com';
    END IF;
END
//
DELIMITER ;

-- Validasi Umur
-- Query testing
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('Bocil@gmail.com', 'Cilcilbocil', 'Bocil cil', '+62-605-117-123', '2012-06-05', NULL, TRUE, FALSE);

--Query Manipulasi
DELIMITER //


CREATE TRIGGER validate_pengguna_age_insert
BEFORE INSERT ON pengguna
FOR EACH ROW
BEGIN
    IF TIMESTAMPDIFF(YEAR, NEW.tgl_lahir, CURDATE()) <= 17 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Pengguna harus berusia lebih dari 17 tahun.';
    END IF;
END//


CREATE TRIGGER validate_pengguna_age_update
BEFORE UPDATE ON pengguna
FOR EACH ROW
BEGIN
    IF TIMESTAMPDIFF(YEAR, NEW.tgl_lahir, CURDATE()) <= 17 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Pengguna harus berusia lebih dari 17 tahun.';
    END IF;
END//

DELIMITER ;

-- Verifikasi Produk
--Query testing 
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
VALUES (999, 'Kaos Test', 'Kaos untuk testing', 'vivi67@mail.com');

-- Query manipulasi 
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

-- hasil
-- ERROR 1644 (45000): Penjual belum terverifikasi.

-- Membuat VIEW top 5 tags
-- VIEW: menampilkan top 5 tags
CREATE OR REPLACE VIEW top_5_tags AS
SELECT tag, COUNT(no_produk) AS jumlah_produk
FROM tag_produk
GROUP BY tag
ORDER BY jumlah_produk DESC
LIMIT 5;


-- Validasi status pengiriman
-- Query testing
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (102, 'Paket hilang di DC Cakung', 2235113.5, 'Kartu Kredit', 'Pedes ya bang.', '2024-07-17 19:12:55', 'Same Day', 'rini42@yahoo.com', 45, 'umar49@yahoo.com');


-- -- Query Manipulasi
-- DELIMITER //

-- CREATE TRIGGER validate_status_pesanan_insert
-- BEFORE INSERT ON pesanan
-- FOR EACH ROW
-- BEGIN
--     IF NEW.status_pesanan NOT IN (
--         'Pesanan belum dibayar',
--         'Pesanan sedang disiapkan',
--         'Pesanan sedang dikirim',
--         'Pesanan sampai',
--         'Pesanan dibatalkan'
--     ) THEN
--         SIGNAL SQLSTATE '45000'
--         SET MESSAGE_TEXT = 'Status pesanan tidak valid. Harus salah satu dari: Pesanan belum dibayar, Pesanan sedang disiapkan, Pesanan sedang dikirim, Pesanan sampai, Pesanan dibatalkan';
--     END IF;
-- END
-- //
-- DELIMITER ;

-- Tambahan transition Constraint
-- Query Testing
UPDATE pesanan
SET status_pesanan = 'Dikirim', metode_bayar = NULL
WHERE no_pesanan = 4 AND status_pesanan = 'Menunggu Pembayaran';

DELIMITER //

CREATE TRIGGER validate_pesanan_status_transition
BEFORE UPDATE ON pesanan
FOR EACH ROW
BEGIN
    IF OLD.status_pesanan = 'Menunggu Pembayaran' 
       AND NEW.status_pesanan = 'Dikirim' 
       AND NEW.metode_bayar IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Metode pembayaran harus diisi sebelum status pesanan berubah ke Dikirim.';
    END IF;
END//

DELIMITER ;


-- Business Rule

-- Wah aneh nih
-- Query Testing
UPDATE penjual SET foto_ktp = NULL, is_verified = TRUE WHERE email = 'talia73@yahoo.com';
UPDATE penjual SET foto_ktp = 'ktp/737329cb-33ee-4b77.jpg', is_verified = TRUE WHERE email = 'talia73@yahoo.com';

ktp/737329cb-33ee-4b77.jpg
-- Query Manipulasi
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


INSERT INTO pesanan (
    no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, 
    metode_kirim, email_pembeli, alamat_id, email_penjual
)
VALUES (
    102, 'Dikirim', 2235113.5, 'Kartu Kredit', 
    'Libero voluptas enim itaque vero laudantium ratione corporis.', 
    'Same Day', 'rini42@yahoo.com', 45, 'umar49@yahoo.com'
);


-- Trigger mengisi waktu_pesan dengan waktu saat ini
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
