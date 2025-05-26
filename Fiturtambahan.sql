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
