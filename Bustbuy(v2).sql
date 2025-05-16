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

-- INSERT INTO pengguna
-- INSERT INTO pengguna
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('ayu65@hotmail.com', 'ayu9fXbIo^', 'Ayu Rahayu', '+62-545-029-172', '1991-09-13', NULL, FALSE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('yuni97@gmail.com', 'yunuwJX^LL', 'Yuni Prayoga', '+62-188-279-849', '2008-04-03', NULL, FALSE, FALSE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('asmadi11@outlook.com', 'asmRwv4Vn1', 'Asmadi Haryanti', '+62-927-533-172', '1953-06-19', NULL, TRUE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('nyana52@yahoo.com', 'nyaR5%i&^B', 'Nyana Rajata', '+62-235-354-193', '1963-10-01', NULL, TRUE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('legawa24@protonmail.com', 'legHYmm*w6', 'Legawa Hartati', '+62-526-258-817', '2000-04-16', NULL, TRUE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('eman5@aol.com', 'emayr_yX@E', 'Eman Hidayanto', '+62-793-288-894', '1968-10-05', NULL, TRUE, FALSE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('salman90@protonmail.com', 'salc6A@qHx', 'Salman Saragih', '+62-945-488-446', '1988-12-01', NULL, TRUE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('zahra10@mail.com', 'zahZHfUA#R', 'Zahra Ardianto', '+62-454-212-379', '2010-02-23', NULL, TRUE, FALSE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('kusuma42@hotmail.com', 'kusBt9%1Tl', 'Kusuma Natsir', '+62-188-687-495', '2003-12-17', NULL, TRUE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('danuja30@yahoo.com', 'danW21xEL%', 'Danuja Waluyo', '+62-568-919-300', '1996-10-04', NULL, TRUE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('budi58@gmail.com', 'budBs!ZsW%', 'Budi Agustina', '+62-306-969-078', '2001-01-27', NULL, TRUE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('mulyono88@protonmail.com', 'mul1uPbWWa', 'Mulyono Halimah', '+62-051-909-774', '1961-01-14', NULL, TRUE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('wadi81@hotmail.com', 'wad5Quwdll', 'Wadi Kusmawati', '+62-125-423-153', '1992-01-24', NULL, TRUE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('pranawa90@aol.com', 'praVPYrAaZ', 'Pranawa Hakim', '+62-249-643-158', '2007-03-26', NULL, FALSE, FALSE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('nrima45@outlook.com', 'nri35@3pW#', 'Nrima Pratiwi', '+62-425-250-073', '2010-01-23', NULL, TRUE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('jumadi52@gmail.com', 'jumn&8lzZ@', 'Jumadi Zulkarnain', '+62-821-272-577', '1984-07-09', NULL, TRUE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('maimunah64@yahoo.com', 'mai%@N8qJ2', 'Maimunah Maheswara', '+62-288-035-678', '2005-05-25', NULL, TRUE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('puji19@gmail.com', 'pujN24VW^^', 'Puji Adriansyah', '+62-190-390-465', '1978-10-04', NULL, TRUE, FALSE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('jaya68@outlook.com', 'jayNG9+etb', 'Jaya Kusmawati', '+62-083-505-749', '1954-09-28', NULL, TRUE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('jarwadi70@mail.com', 'jariX10kF#', 'Jarwadi Jailani', '+62-442-142-531', '1944-08-28', NULL, TRUE, FALSE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('iriana68@yahoo.com', 'iri-jrkt%3', 'Iriana Siregar', '+62-054-492-815', '1958-03-20', NULL, FALSE, FALSE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('sakura70@aol.com', 'sakuNkX2wL', 'Sakura Napitupulu', '+62-922-597-767', '1976-05-22', NULL, TRUE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('umay10@aol.com', 'uma2Eto*g1', 'Umay Gunawan', '+62-952-387-015', '1958-12-08', NULL, TRUE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('ivan42@aol.com', 'ivaBSOToP#', 'Ivan Wahyudin', '+62-764-074-100', '1959-07-29', NULL, TRUE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('olga77@gmail.com', 'olgprz6^Ot', 'Olga Mulyani', '+62-534-305-609', '1984-01-20', NULL, FALSE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('elisa62@gmail.com', 'elirZVPG%k', 'Elisa Tamba', '+62-788-159-176', '1949-03-24', NULL, TRUE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('dimaz63@outlook.com', 'dimuoFRRV0', 'Dimaz Wahyudin', '+62-282-958-505', '2009-01-09', NULL, FALSE, FALSE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('nadia54@gmail.com', 'nadUFreoBZ', 'Nadia Iswahyudi', '+62-564-546-084', '1970-01-07', NULL, TRUE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('oskar15@aol.com', 'oskqxW9xEu', 'Oskar Waluyo', '+62-993-293-652', '2003-02-15', NULL, FALSE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('ivan20@gmail.com', 'ivacwzk#yW', 'Ivan Andriani', '+62-301-520-073', '1958-07-18', NULL, TRUE, FALSE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('kala24@hotmail.com', 'kalC#RoNOo', 'Kala Laksita', '+62-946-950-977', '2003-06-02', NULL, TRUE, FALSE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('zulaikha2@outlook.com', 'zuludE@@OA', 'Zulaikha Yulianti', '+62-030-859-200', '1963-07-13', NULL, TRUE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('irfan87@gmail.com', 'irfkz&yuZ-', 'Irfan Samosir', '+62-973-513-946', '1999-09-25', NULL, TRUE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('ida22@yahoo.com', 'idaUKwVLxM', 'Ida Saefullah', '+62-141-785-647', '1996-03-24', NULL, FALSE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('harsanto74@mail.com', 'harXaGSLsN', 'Harsanto Suryono', '+62-938-782-715', '1967-06-24', NULL, TRUE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('patricia49@gmail.com', 'patLQYrPOU', 'Patricia Hidayat', '+62-577-067-268', '1976-04-17', NULL, TRUE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('catur70@protonmail.com', 'cat-9pU1k_', 'Catur Nashiruddin', '+62-216-739-201', '2002-12-27', NULL, TRUE, FALSE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('yani96@mail.com', 'yan^LbkMQ3', 'Yani Usamah', '+62-911-375-469', '1999-08-07', NULL, TRUE, FALSE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('dono69@aol.com', 'donmQUOhAc', 'Dono Tamba', '+62-266-037-299', '2000-01-19', NULL, TRUE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('jamalia36@aol.com', 'jamO^z7v_P', 'Jamalia Waluyo', '+62-597-361-088', '1957-11-15', NULL, TRUE, FALSE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('rahmi63@gmail.com', 'rahN!9$TK_', 'Rahmi Maryadi', '+62-452-468-918', '2006-03-19', NULL, TRUE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('ciaobella63@protonmail.com', 'ciau0GMA3e', 'Ciaobella Handayani', '+62-458-053-312', '1956-04-09', NULL, TRUE, FALSE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('wage52@yahoo.com', 'wagd77Q8Cn', 'Wage Ramadan', '+62-280-756-760', '1989-11-27', NULL, TRUE, FALSE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('hendri93@yahoo.com', 'hen$Xl97rQ', 'Hendri Yulianti', '+62-115-404-947', '1968-05-26', NULL, TRUE, FALSE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('lulut53@aol.com', 'lulCmPUMBA', 'Lulut Hakim', '+62-736-591-954', '1999-10-10', NULL, TRUE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('cawisadi28@yahoo.com', 'cawj+F3PsO', 'Cawisadi Simbolon', '+62-860-886-563', '1946-12-14', NULL, TRUE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('mahfud5@protonmail.com', 'maht+a$yFS', 'Mahfud Saputra', '+62-892-879-781', '1987-07-27', NULL, TRUE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('perkasa91@outlook.com', 'perA7UDQV9', 'Perkasa Kurniawan', '+62-758-817-496', '2009-01-10', NULL, TRUE, FALSE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('heryanto85@mail.com', 'herc%uR^uC', 'Heryanto Fujiati', '+62-766-915-206', '2001-03-31', NULL, TRUE, TRUE);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
                 VALUES ('maria16@outlook.com', 'marA!6^a74', 'Maria Prakasa', '+62-167-116-040', '1955-03-08', NULL, FALSE, TRUE);

-- INSERT INTO alamat
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (1, 'Kalimantan Utara', 'Salatiga', 'Gang Pacuan Kuda No. 25');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (2, 'Lampung', 'Banjar', 'Jalan Indragiri No. 861');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (3, 'Banten', 'Tangerang', 'Gg. Sukabumi No. 4');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (4, 'Nusa Tenggara Barat', 'Probolinggo', 'Gg. Cihampelas No. 451');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (5, 'DKI Jakarta', 'Bau-Bau', 'Gang Cikutra Barat No. 707');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (6, 'Jawa Barat', 'Semarang', 'Jl. Medokan Ayu No. 55');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (7, 'Kepulauan Riau', 'Medan', 'Jl. Jamika No. 217');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (8, 'Sulawesi Tengah', 'Pekalongan', 'Gang Antapani Lama No. 5');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (9, 'Jawa Timur', 'Probolinggo', 'Jl. Jamika No. 739');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (10, 'Lampung', 'Palangkaraya', 'Gg. R.E Martadinata No. 42');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (11, 'Kalimantan Selatan', 'Subulussalam', 'Gang Ciumbuleuit No. 373');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (12, 'Maluku Utara', 'Langsa', 'Gg. Raya Ujungberung No. 8');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (13, 'Sulawesi Utara', 'Banjar', 'Jalan Lembong No. 384');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (14, 'Kepulauan Bangka Belitung', 'Tangerang Selatan', 'Jalan K.H. Wahid Hasyim No. 27');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (15, 'Kalimantan Utara', 'Pekalongan', 'Jl. Waringin No. 745');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (16, 'Papua Barat', 'Padangpanjang', 'Gg. Gegerkalong Hilir No. 0');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (17, 'Lampung', 'Banjar', 'Jl. Merdeka No. 07');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (18, 'DI Yogyakarta', 'Palangkaraya', 'Gang Abdul Muis No. 319');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (19, 'Jawa Tengah', 'Lubuklinggau', 'Jl. S. Parman No. 990');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (20, 'Kepulauan Riau', 'Sibolga', 'Jalan Rumah Sakit No. 55');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (21, 'Nusa Tenggara Timur', 'Kota Administrasi Jakarta Barat', 'Gang Pelajar Pejuang No. 724');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (22, 'Jambi', 'Sibolga', 'Gg. Moch. Ramdan No. 189');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (23, 'Sulawesi Selatan', 'Pagaralam', 'Jl. Ahmad Dahlan No. 4');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (24, 'DKI Jakarta', 'Pematangsiantar', 'Jl. Kendalsari No. 6');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (25, 'DKI Jakarta', 'Tebingtinggi', 'Gg. Jakarta No. 951');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (26, 'Sulawesi Tengah', 'Meulaboh', 'Jalan Erlangga No. 0');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (27, 'Sulawesi Utara', 'Tangerang Selatan', 'Jalan Gedebage Selatan No. 29');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (28, 'Kepulauan Riau', 'Blitar', 'Jalan Kutisari Selatan No. 12');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (29, 'Gorontalo', 'Bitung', 'Jalan Setiabudhi No. 1');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (30, 'Nusa Tenggara Timur', 'Blitar', 'Jalan Rajawali Barat No. 87');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (31, 'Kalimantan Tengah', 'Manado', 'Gang Suniaraja No. 795');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (32, 'Sulawesi Tenggara', 'Meulaboh', 'Jl. Merdeka No. 4');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (33, 'Bali', 'Bandung', 'Gg. Siliwangi No. 45');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (34, 'DI Yogyakarta', 'Depok', 'Gang Dr. Djunjunan No. 879');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (35, 'Jambi', 'Banjarmasin', 'Jalan Monginsidi No. 1');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (36, 'Jambi', 'Balikpapan', 'Gang Rajawali Timur No. 613');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (37, 'Kalimantan Utara', 'Sungai Penuh', 'Gang Rumah Sakit No. 95');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (38, 'Riau', 'Tebingtinggi', 'Gang Cihampelas No. 94');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (39, 'Kalimantan Barat', 'Tanjungpinang', 'Jalan Monginsidi No. 31');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (40, 'Sulawesi Selatan', 'Solok', 'Gg. Rajawali Barat No. 9');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (41, 'Jambi', 'Pagaralam', 'Gang Raya Setiabudhi No. 767');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (42, 'Sumatera Utara', 'Parepare', 'Jl. Stasiun Wonokromo No. 4');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (43, 'Kalimantan Timur', 'Madiun', 'Jl. Rungkut Industri No. 020');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (44, 'Maluku', 'Surakarta', 'Jalan Monginsidi No. 03');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (45, 'Kalimantan Barat', 'Banjar', 'Gg. Pacuan Kuda No. 1');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (46, 'Jawa Barat', 'Lhokseumawe', 'Gg. Rungkut Industri No. 246');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (47, 'Kalimantan Barat', 'Tomohon', 'Jl. Raya Ujungberung No. 92');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (48, 'Kalimantan Timur', 'Tomohon', 'Jl. Cikutra Barat No. 200');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (49, 'Riau', 'Palangkaraya', 'Jalan HOS. Cokroaminoto No. 1');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (50, 'Riau', 'Cilegon', 'Gang Wonoayu No. 42');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (51, 'Sumatera Barat', 'Bukittinggi', 'Jl. Kendalsari No. 9');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (52, 'Kalimantan Selatan', 'Banda Aceh', 'Jalan M.H Thamrin No. 34');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (53, 'Kalimantan Barat', 'Sibolga', 'Jalan Pelajar Pejuang No. 369');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (54, 'Bali', 'Jambi', 'Jl. Bangka Raya No. 914');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (55, 'Maluku', 'Bandung', 'Jalan Yos Sudarso No. 4');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (56, 'Jawa Barat', 'Serang', 'Gang Waringin No. 00');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (57, 'Sulawesi Selatan', 'Batu', 'Gg. Gegerkalong Hilir No. 2');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (58, 'Banten', 'Metro', 'Jalan Ahmad Dahlan No. 24');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (59, 'Sumatera Barat', 'Sukabumi', 'Gang Suryakencana No. 2');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (60, 'Kepulauan Bangka Belitung', 'Sawahlunto', 'Jalan Jend. Sudirman No. 3');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (61, 'Riau', 'Sorong', 'Jalan Cikutra Timur No. 420');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (62, 'Sulawesi Tengah', 'Banjarbaru', 'Jalan Pasirkoja No. 77');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (63, 'Kalimantan Barat', 'Tanjungbalai', 'Jalan Siliwangi No. 45');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (64, 'Riau', 'Cilegon', 'Gang KH Amin Jasuta No. 333');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (65, 'Sumatera Utara', 'Sorong', 'Jalan PHH. Mustofa No. 0');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (66, 'Banten', 'Palangkaraya', 'Gang Jamika No. 07');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (67, 'Jawa Barat', 'Sibolga', 'Jl. Erlangga No. 675');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (68, 'DI Yogyakarta', 'Pariaman', 'Gang Rajiman No. 3');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (69, 'Sumatera Utara', 'Manado', 'Gg. M.H Thamrin No. 393');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (70, 'Jawa Barat', 'Pariaman', 'Jl. Cihampelas No. 39');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (71, 'Sulawesi Selatan', 'Pekalongan', 'Jl. Ahmad Yani No. 7');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (72, 'Papua', 'Tanjungbalai', 'Gang Siliwangi No. 7');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (73, 'DI Yogyakarta', 'Kota Administrasi Jakarta Barat', 'Jalan Surapati No. 8');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (74, 'DKI Jakarta', 'Surakarta', 'Gg. Asia Afrika No. 111');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (75, 'Gorontalo', 'Ambon', 'Jl. Sentot Alibasa No. 7');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (76, 'Kalimantan Utara', 'Banda Aceh', 'Jl. Cikapayang No. 3');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (77, 'Jambi', 'Makassar', 'Gang Pacuan Kuda No. 9');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (78, 'Gorontalo', 'Metro', 'Jl. Kebonjati No. 241');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (79, 'Lampung', 'Pematangsiantar', 'Gang Bangka Raya No. 4');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (80, 'Kalimantan Barat', 'Sukabumi', 'Jl. Waringin No. 98');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (81, 'Sulawesi Selatan', 'Meulaboh', 'Jalan Kendalsari No. 03');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (82, 'Kepulauan Bangka Belitung', 'Sabang', 'Gg. Veteran No. 617');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (83, 'Sulawesi Selatan', 'Singkawang', 'Gang Merdeka No. 38');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (84, 'Kepulauan Riau', 'Gorontalo', 'Gang Dr. Djunjunan No. 2');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (85, 'Sumatera Utara', 'Bekasi', 'Gg. Rungkut Industri No. 7');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (86, 'Banten', 'Banjar', 'Gg. Kutai No. 81');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (87, 'Jambi', 'Tangerang Selatan', 'Gang Wonoayu No. 604');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (88, 'Sumatera Barat', 'Tangerang', 'Gang Ahmad Dahlan No. 08');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (89, 'Nusa Tenggara Barat', 'Singkawang', 'Gg. Suniaraja No. 7');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (90, 'Papua', 'Pekanbaru', 'Gang H.J Maemunah No. 50');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (91, 'Kepulauan Riau', 'Pematangsiantar', 'Gang Astana Anyar No. 8');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (92, 'Jawa Timur', 'Makassar', 'Gang M.T Haryono No. 670');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (93, 'Kalimantan Utara', 'Metro', 'Jl. Merdeka No. 932');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (94, 'Jawa Tengah', 'Metro', 'Gang Moch. Ramdan No. 380');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (95, 'Jambi', 'Gorontalo', 'Gg. Siliwangi No. 80');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (96, 'Kalimantan Barat', 'Prabumulih', 'Gang Setiabudhi No. 25');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (97, 'DI Yogyakarta', 'Pekanbaru', 'Jl. Gegerkalong Hilir No. 9');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (98, 'Sumatera Selatan', 'Mataram', 'Gang Pelajar Pejuang No. 60');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (99, 'DKI Jakarta', 'Lubuklinggau', 'Gg. Pasirkoja No. 036');
INSERT INTO alamat (alamat_id, provinsi, kota, jalan)
                 VALUES (100, 'Maluku Utara', 'Tangerang', 'Gang Ahmad Yani No. 0');

-- INSERT INTO pembeli
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('ayu65@hotmail.com', 71);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('yuni97@gmail.com', 28);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('asmadi11@outlook.com', 77);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('nyana52@yahoo.com', 21);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('legawa24@protonmail.com', 87);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('eman5@aol.com', 33);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('zahra10@mail.com', 23);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('kusuma42@hotmail.com', 94);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('budi58@gmail.com', 44);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('mulyono88@protonmail.com', 65);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('wadi81@hotmail.com', 2);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('jumadi52@gmail.com', 44);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('maimunah64@yahoo.com', 6);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('puji19@gmail.com', 16);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('jaya68@outlook.com', 42);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('jarwadi70@mail.com', 68);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('iriana68@yahoo.com', 36);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('sakura70@aol.com', 48);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('umay10@aol.com', 23);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('ivan42@aol.com', 19);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('olga77@gmail.com', 50);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('elisa62@gmail.com', 46);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('dimaz63@outlook.com', 92);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('oskar15@aol.com', 41);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('kala24@hotmail.com', 57);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('zulaikha2@outlook.com', 5);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('irfan87@gmail.com', 46);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('patricia49@gmail.com', 81);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('yani96@mail.com', 72);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('rahmi63@gmail.com', 84);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('ciaobella63@protonmail.com', 97);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('hendri93@yahoo.com', 3);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('cawisadi28@yahoo.com', 42);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('mahfud5@protonmail.com', 15);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('perkasa91@outlook.com', 28);
INSERT INTO pembeli (email, alamat_utama_id)
                     VALUES ('maria16@outlook.com', 17);

-- INSERT INTO penjual
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('ayu65@hotmail.com', 'ktp/2d29d969-de68-4f60-a0bf-41ff4c4dcef1.jpg', 'selfie/45b1d8d2-dfdd-4d00-b2fb-effbe847e1f1.jpg', FALSE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('asmadi11@outlook.com', 'ktp/64e0b831-094c-405e-99f3-99ab66f912f5.jpg', 'selfie/6b82de15-bbd7-4e59-b246-4404ab6b9a07.jpg', FALSE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('salman90@protonmail.com', 'ktp/b6f9ea2b-1152-48d6-92f2-360bf54fc7a7.jpg', 'selfie/32811981-7fad-4704-8e7b-aa10c558d293.jpg', TRUE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('zahra10@mail.com', 'ktp/c830e69a-f598-40a5-80ed-bf2ac84978fd.jpg', 'selfie/06c4aecf-cb2f-4e31-9d95-89dd5559ea7c.jpg', FALSE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('kusuma42@hotmail.com', 'ktp/9821dafb-907c-4e08-a757-20f88678da1b.jpg', 'selfie/56bbd682-1bfa-4c80-96c6-27a06577bec2.jpg', FALSE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('danuja30@yahoo.com', 'ktp/16c91303-d82f-4c15-9da8-ab30e5b4165c.jpg', 'selfie/65998abf-00ad-4876-b6b7-000a759d51c7.jpg', TRUE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('budi58@gmail.com', 'ktp/aada7db8-6adf-4351-8f56-113427745bb1.jpg', 'selfie/7c6e4fce-6aa6-4871-b48a-712a0f6df76a.jpg', TRUE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('wadi81@hotmail.com', 'ktp/62f5dbc7-3e37-4f83-b258-50b8d40408a4.jpg', 'selfie/ee5de2fe-67d6-4e75-835d-ffd2979c3279.jpg', FALSE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('pranawa90@aol.com', 'ktp/ba574775-c317-49af-baa3-af4bd83c25f6.jpg', 'selfie/87a65c8e-18b3-45fa-ae49-a0704e4de002.jpg', FALSE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('jumadi52@gmail.com', 'ktp/9ecf6e79-ea6f-4b09-b61b-77b1be50c53d.jpg', 'selfie/93ab63f0-160f-49be-a1a5-d616dc562733.jpg', FALSE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('puji19@gmail.com', 'ktp/dad44a44-d2cc-439d-84f7-c08f25f82ae6.jpg', 'selfie/99837f62-b795-4eef-97c2-0073891df03f.jpg', TRUE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('iriana68@yahoo.com', 'ktp/aacc1167-dc7a-482d-82c8-0cda67ec2e3a.jpg', 'selfie/da3398b9-f68d-4102-87f3-8db350dbc748.jpg', TRUE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('sakura70@aol.com', 'ktp/93ae688d-f59f-46bd-ad4c-b193497a9be2.jpg', 'selfie/7ebc26d7-73e8-40b5-91c1-190ab9899e52.jpg', TRUE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('umay10@aol.com', 'ktp/660bb5cb-3fd7-4dd8-9724-9c1b23e0ebb1.jpg', 'selfie/a0986113-d025-48a0-b388-e8d272787a56.jpg', TRUE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('ivan42@aol.com', 'ktp/49cf22f0-ee85-4e76-8311-754629066ade.jpg', 'selfie/312fa535-c2df-411a-8d76-6a3b322d2b3f.jpg', FALSE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('olga77@gmail.com', 'ktp/af3517d6-2781-4a82-adb1-0db40acff268.jpg', 'selfie/00b2101c-913c-4d7c-bff5-d8f05152bbbb.jpg', FALSE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('dimaz63@outlook.com', 'ktp/42026eef-e97f-4c5c-9ddd-ae2352b2942a.jpg', 'selfie/8dac1f1e-7788-40ba-96ad-43c6c7af317e.jpg', TRUE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('nadia54@gmail.com', 'ktp/21ced126-80fb-447d-b05c-a2ee27c82c3b.jpg', 'selfie/014da7e2-b46e-41d2-9264-3693f1c51442.jpg', TRUE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('oskar15@aol.com', 'ktp/05c1ab31-0239-4e77-b78a-3817a330a337.jpg', 'selfie/d00f5699-c939-4eb7-ab33-da87edf6fd84.jpg', TRUE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('ivan20@gmail.com', 'ktp/ca777f10-6019-4d0e-b647-b13cc7427922.jpg', 'selfie/f4fbb8e5-5a95-43cf-98f9-562ee2a59367.jpg', TRUE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('zulaikha2@outlook.com', 'ktp/47283601-438e-417d-ab6a-b28131bca9f6.jpg', 'selfie/f29c5dee-c640-4ff4-9803-6faf6e8710cc.jpg', TRUE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('irfan87@gmail.com', 'ktp/fccf003a-c68b-4c35-b27d-e25fc2d25031.jpg', 'selfie/1d927ea2-1802-4b9a-aca6-52ded26dc987.jpg', FALSE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('harsanto74@mail.com', 'ktp/f06a8809-5288-4bf4-be4a-823ec5af95c6.jpg', 'selfie/61fa1791-79fd-420d-8917-2e61f1cf598d.jpg', TRUE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('patricia49@gmail.com', 'ktp/9adb9c65-04ce-4887-98bd-de585c5599ed.jpg', 'selfie/cdb40723-7a03-4499-9f84-b22a2c866c25.jpg', FALSE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('catur70@protonmail.com', 'ktp/376853e6-2eec-4b4c-b9cc-888606d102f8.jpg', 'selfie/071f058d-0139-4caa-914c-4ce95c17d166.jpg', FALSE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('yani96@mail.com', 'ktp/43f4c4af-4805-4861-9821-8e27501c8a24.jpg', 'selfie/0c49c7a0-672a-4c06-a1e7-95c8d0d13499.jpg', FALSE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('jamalia36@aol.com', 'ktp/8ed9a55c-cf0a-476f-82eb-ec938fc64828.jpg', 'selfie/99f35e3e-3336-4879-88d0-2c33e3e4e7b3.jpg', TRUE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('hendri93@yahoo.com', 'ktp/4642762b-8dce-48ae-8669-cd47fd3310a1.jpg', 'selfie/a3aa85d3-0845-4dc7-9cba-49d1196a3b7c.jpg', FALSE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('lulut53@aol.com', 'ktp/57db5649-d818-4148-856d-87303724a75f.jpg', 'selfie/bcd9064b-3d0f-4c4b-a084-483da1ec8e49.jpg', TRUE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('mahfud5@protonmail.com', 'ktp/21d9c987-b757-4368-93bd-8a85fc26cfc1.jpg', 'selfie/a44e30ac-e4a3-4d33-80d9-d6380b7e4f2f.jpg', FALSE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('perkasa91@outlook.com', 'ktp/077127c2-2fd2-4cf1-807a-75dd175ab888.jpg', 'selfie/2741c125-5a12-4fab-99bd-90c9eae049e3.jpg', TRUE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('heryanto85@mail.com', 'ktp/412c17e6-c9d6-4f4f-b0a2-9c2592345a32.jpg', 'selfie/7268a2e3-c145-4706-b9b2-6cb4e780741e.jpg', TRUE);
INSERT INTO penjual (email, foto_ktp, foto_diri, is_verified)
                     VALUES ('maria16@outlook.com', 'ktp/2c40a3bd-5746-4806-9a37-fa8567710c76.jpg', 'selfie/a5e9f0b1-8322-4bc5-8e33-25c4549868a7.jpg', FALSE);

-- INSERT INTO friend
INSERT INTO friend (email, email_following)
                 VALUES ('sakura70@aol.com', 'dimaz63@outlook.com');
INSERT INTO friend (email, email_following)
                 VALUES ('irfan87@gmail.com', 'dono69@aol.com');
INSERT INTO friend (email, email_following)
                 VALUES ('wadi81@hotmail.com', 'rahmi63@gmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('jamalia36@aol.com', 'dono69@aol.com');
INSERT INTO friend (email, email_following)
                 VALUES ('mulyono88@protonmail.com', 'rahmi63@gmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('ivan42@aol.com', 'patricia49@gmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('pranawa90@aol.com', 'catur70@protonmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('nyana52@yahoo.com', 'iriana68@yahoo.com');
INSERT INTO friend (email, email_following)
                 VALUES ('oskar15@aol.com', 'umay10@aol.com');
INSERT INTO friend (email, email_following)
                 VALUES ('heryanto85@mail.com', 'salman90@protonmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('yani96@mail.com', 'legawa24@protonmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('heryanto85@mail.com', 'nadia54@gmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('ciaobella63@protonmail.com', 'perkasa91@outlook.com');
INSERT INTO friend (email, email_following)
                 VALUES ('ivan42@aol.com', 'salman90@protonmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('ivan42@aol.com', 'iriana68@yahoo.com');
INSERT INTO friend (email, email_following)
                 VALUES ('oskar15@aol.com', 'heryanto85@mail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('catur70@protonmail.com', 'jaya68@outlook.com');
INSERT INTO friend (email, email_following)
                 VALUES ('perkasa91@outlook.com', 'lulut53@aol.com');
INSERT INTO friend (email, email_following)
                 VALUES ('jumadi52@gmail.com', 'legawa24@protonmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('iriana68@yahoo.com', 'rahmi63@gmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('puji19@gmail.com', 'yani96@mail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('heryanto85@mail.com', 'patricia49@gmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('jaya68@outlook.com', 'mulyono88@protonmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('nadia54@gmail.com', 'danuja30@yahoo.com');
INSERT INTO friend (email, email_following)
                 VALUES ('maria16@outlook.com', 'eman5@aol.com');
INSERT INTO friend (email, email_following)
                 VALUES ('zahra10@mail.com', 'ciaobella63@protonmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('ciaobella63@protonmail.com', 'nyana52@yahoo.com');
INSERT INTO friend (email, email_following)
                 VALUES ('wage52@yahoo.com', 'danuja30@yahoo.com');
INSERT INTO friend (email, email_following)
                 VALUES ('yuni97@gmail.com', 'yani96@mail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('dimaz63@outlook.com', 'salman90@protonmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('jarwadi70@mail.com', 'irfan87@gmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('nadia54@gmail.com', 'ida22@yahoo.com');
INSERT INTO friend (email, email_following)
                 VALUES ('jaya68@outlook.com', 'zulaikha2@outlook.com');
INSERT INTO friend (email, email_following)
                 VALUES ('nrima45@outlook.com', 'elisa62@gmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('ayu65@hotmail.com', 'kusuma42@hotmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('ivan42@aol.com', 'harsanto74@mail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('kala24@hotmail.com', 'nadia54@gmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('nyana52@yahoo.com', 'legawa24@protonmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('mahfud5@protonmail.com', 'ciaobella63@protonmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('jumadi52@gmail.com', 'zahra10@mail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('oskar15@aol.com', 'lulut53@aol.com');
INSERT INTO friend (email, email_following)
                 VALUES ('mahfud5@protonmail.com', 'patricia49@gmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('maria16@outlook.com', 'nyana52@yahoo.com');
INSERT INTO friend (email, email_following)
                 VALUES ('maria16@outlook.com', 'catur70@protonmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('puji19@gmail.com', 'ivan20@gmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('cawisadi28@yahoo.com', 'nyana52@yahoo.com');
INSERT INTO friend (email, email_following)
                 VALUES ('pranawa90@aol.com', 'kusuma42@hotmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('kusuma42@hotmail.com', 'iriana68@yahoo.com');
INSERT INTO friend (email, email_following)
                 VALUES ('salman90@protonmail.com', 'ida22@yahoo.com');
INSERT INTO friend (email, email_following)
                 VALUES ('harsanto74@mail.com', 'legawa24@protonmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('elisa62@gmail.com', 'kusuma42@hotmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('jaya68@outlook.com', 'wage52@yahoo.com');
INSERT INTO friend (email, email_following)
                 VALUES ('budi58@gmail.com', 'jumadi52@gmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('patricia49@gmail.com', 'yani96@mail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('kala24@hotmail.com', 'ivan20@gmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('wage52@yahoo.com', 'jarwadi70@mail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('jumadi52@gmail.com', 'dimaz63@outlook.com');
INSERT INTO friend (email, email_following)
                 VALUES ('hendri93@yahoo.com', 'yani96@mail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('catur70@protonmail.com', 'danuja30@yahoo.com');
INSERT INTO friend (email, email_following)
                 VALUES ('eman5@aol.com', 'nadia54@gmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('jamalia36@aol.com', 'eman5@aol.com');
INSERT INTO friend (email, email_following)
                 VALUES ('wadi81@hotmail.com', 'eman5@aol.com');
INSERT INTO friend (email, email_following)
                 VALUES ('jaya68@outlook.com', 'legawa24@protonmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('kala24@hotmail.com', 'ida22@yahoo.com');
INSERT INTO friend (email, email_following)
                 VALUES ('iriana68@yahoo.com', 'legawa24@protonmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('ida22@yahoo.com', 'catur70@protonmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('dimaz63@outlook.com', 'elisa62@gmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('danuja30@yahoo.com', 'hendri93@yahoo.com');
INSERT INTO friend (email, email_following)
                 VALUES ('puji19@gmail.com', 'jaya68@outlook.com');
INSERT INTO friend (email, email_following)
                 VALUES ('nrima45@outlook.com', 'rahmi63@gmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('budi58@gmail.com', 'cawisadi28@yahoo.com');
INSERT INTO friend (email, email_following)
                 VALUES ('jamalia36@aol.com', 'wage52@yahoo.com');
INSERT INTO friend (email, email_following)
                 VALUES ('lulut53@aol.com', 'jaya68@outlook.com');
INSERT INTO friend (email, email_following)
                 VALUES ('wadi81@hotmail.com', 'asmadi11@outlook.com');
INSERT INTO friend (email, email_following)
                 VALUES ('irfan87@gmail.com', 'wage52@yahoo.com');
INSERT INTO friend (email, email_following)
                 VALUES ('mahfud5@protonmail.com', 'yani96@mail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('perkasa91@outlook.com', 'iriana68@yahoo.com');
INSERT INTO friend (email, email_following)
                 VALUES ('elisa62@gmail.com', 'puji19@gmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('puji19@gmail.com', 'zahra10@mail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('iriana68@yahoo.com', 'oskar15@aol.com');
INSERT INTO friend (email, email_following)
                 VALUES ('eman5@aol.com', 'sakura70@aol.com');
INSERT INTO friend (email, email_following)
                 VALUES ('olga77@gmail.com', 'irfan87@gmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('asmadi11@outlook.com', 'nrima45@outlook.com');
INSERT INTO friend (email, email_following)
                 VALUES ('perkasa91@outlook.com', 'hendri93@yahoo.com');
INSERT INTO friend (email, email_following)
                 VALUES ('ciaobella63@protonmail.com', 'irfan87@gmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('ayu65@hotmail.com', 'nyana52@yahoo.com');
INSERT INTO friend (email, email_following)
                 VALUES ('irfan87@gmail.com', 'kusuma42@hotmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('catur70@protonmail.com', 'maria16@outlook.com');
INSERT INTO friend (email, email_following)
                 VALUES ('olga77@gmail.com', 'sakura70@aol.com');
INSERT INTO friend (email, email_following)
                 VALUES ('legawa24@protonmail.com', 'nyana52@yahoo.com');
INSERT INTO friend (email, email_following)
                 VALUES ('catur70@protonmail.com', 'legawa24@protonmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('zahra10@mail.com', 'cawisadi28@yahoo.com');
INSERT INTO friend (email, email_following)
                 VALUES ('jamalia36@aol.com', 'dimaz63@outlook.com');
INSERT INTO friend (email, email_following)
                 VALUES ('umay10@aol.com', 'jamalia36@aol.com');
INSERT INTO friend (email, email_following)
                 VALUES ('yani96@mail.com', 'nrima45@outlook.com');
INSERT INTO friend (email, email_following)
                 VALUES ('elisa62@gmail.com', 'salman90@protonmail.com');
INSERT INTO friend (email, email_following)
                 VALUES ('iriana68@yahoo.com', 'umay10@aol.com');
INSERT INTO friend (email, email_following)
                 VALUES ('wadi81@hotmail.com', 'ivan42@aol.com');
INSERT INTO friend (email, email_following)
                 VALUES ('ayu65@hotmail.com', 'sakura70@aol.com');
INSERT INTO friend (email, email_following)
                 VALUES ('olga77@gmail.com', 'jumadi52@gmail.com');

-- INSERT INTO alamat_alternatif
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('ayu65@hotmail.com', 50);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('umay10@aol.com', 28);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('zahra10@mail.com', 50);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('olga77@gmail.com', 14);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('cawisadi28@yahoo.com', 48);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('mahfud5@protonmail.com', 9);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('nyana52@yahoo.com', 15);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('umay10@aol.com', 69);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('iriana68@yahoo.com', 74);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('mulyono88@protonmail.com', 69);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('yani96@mail.com', 27);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('puji19@gmail.com', 30);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('sakura70@aol.com', 72);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('yani96@mail.com', 7);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('mulyono88@protonmail.com', 99);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('jumadi52@gmail.com', 5);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('jumadi52@gmail.com', 43);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('maimunah64@yahoo.com', 66);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('maria16@outlook.com', 76);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('rahmi63@gmail.com', 51);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('umay10@aol.com', 72);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('ivan42@aol.com', 60);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('oskar15@aol.com', 36);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('eman5@aol.com', 8);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('rahmi63@gmail.com', 41);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('asmadi11@outlook.com', 94);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('cawisadi28@yahoo.com', 45);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('legawa24@protonmail.com', 50);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('maria16@outlook.com', 2);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('yuni97@gmail.com', 33);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('oskar15@aol.com', 59);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('maria16@outlook.com', 86);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('jumadi52@gmail.com', 95);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('zahra10@mail.com', 51);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('patricia49@gmail.com', 41);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('legawa24@protonmail.com', 86);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('maimunah64@yahoo.com', 88);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('budi58@gmail.com', 21);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('sakura70@aol.com', 97);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('kala24@hotmail.com', 55);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('puji19@gmail.com', 78);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('yuni97@gmail.com', 56);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('iriana68@yahoo.com', 68);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('zulaikha2@outlook.com', 39);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('zulaikha2@outlook.com', 68);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('eman5@aol.com', 90);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('ivan42@aol.com', 48);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('kala24@hotmail.com', 37);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('jarwadi70@mail.com', 91);
INSERT INTO alamat_alternatif (email, alamat_id)
                 VALUES ('jarwadi70@mail.com', 52);

-- INSERT INTO produk
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (1, 'Celana Jeans Amet', 'Produk berkualitas tinggi', 'dimaz63@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (2, 'Celana Jeans Est', 'Tahan lama', 'ivan20@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (3, 'Kaos Polos Omnis', 'Desain modern', 'zulaikha2@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (4, 'Topi Baseball Occaecati', 'Nyaman dipakai', 'budi58@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (5, 'Sepatu Sneakers Excepturi', 'Tahan lama', 'oskar15@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (6, 'Topi Baseball Natus', 'Desain modern', 'lulut53@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (7, 'Tas Ransel Perspiciatis', 'Nyaman dipakai', 'perkasa91@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (8, 'Jaket Hoodie Harum', 'Nyaman dipakai', 'perkasa91@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (9, 'Kaos Polos Facere', 'Desain modern', 'ivan20@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (10, 'Dress Midi Autem', 'Nyaman dipakai', 'puji19@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (11, 'Kemeja Formal Accusamus', 'Desain modern', 'lulut53@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (12, 'Tas Ransel Minima', 'Tahan lama', 'zulaikha2@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (13, 'Kemeja Formal Culpa', 'Tahan lama', 'sakura70@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (14, 'Kaos Polos Laudantium', 'Nyaman dipakai', 'nadia54@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (15, 'Celana Jeans Fuga', 'Desain modern', 'ivan20@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (16, 'Jaket Hoodie Eum', 'Tahan lama', 'danuja30@yahoo.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (17, 'Kaos Polos Autem', 'Nyaman dipakai', 'perkasa91@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (18, 'Celana Jeans Illum', 'Nyaman dipakai', 'perkasa91@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (19, 'Topi Baseball Nostrum', 'Nyaman dipakai', 'jamalia36@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (20, 'Tas Ransel Voluptate', 'Desain modern', 'salman90@protonmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (21, 'Jaket Hoodie Quaerat', 'Desain modern', 'iriana68@yahoo.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (22, 'Tas Ransel Quo', 'Desain modern', 'zulaikha2@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (23, 'Kemeja Formal Impedit', 'Desain modern', 'dimaz63@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (24, 'Sepatu Sneakers Accusamus', 'Desain modern', 'budi58@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (25, 'Tas Ransel Natus', 'Nyaman dipakai', 'umay10@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (26, 'Sepatu Sneakers Nemo', 'Produk berkualitas tinggi', 'lulut53@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (27, 'Kaos Polos Fugiat', 'Desain modern', 'danuja30@yahoo.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (28, 'Celana Jeans Consequatur', 'Desain modern', 'harsanto74@mail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (29, 'Celana Jeans Earum', 'Desain modern', 'lulut53@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (30, 'Sepatu Sneakers Voluptatibus', 'Tahan lama', 'iriana68@yahoo.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (31, 'Kemeja Formal Rerum', 'Produk berkualitas tinggi', 'puji19@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (32, 'Dress Midi Eius', 'Produk berkualitas tinggi', 'zulaikha2@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (33, 'Kaos Polos Illo', 'Nyaman dipakai', 'iriana68@yahoo.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (34, 'Topi Baseball Repellendus', 'Tahan lama', 'puji19@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (35, 'Topi Baseball Repellat', 'Desain modern', 'dimaz63@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (36, 'Celana Jeans Esse', 'Desain modern', 'budi58@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (37, 'Dress Midi Molestias', 'Produk berkualitas tinggi', 'heryanto85@mail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (38, 'Sepatu Sneakers Assumenda', 'Desain modern', 'perkasa91@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (39, 'Kaos Polos Cumque', 'Tahan lama', 'perkasa91@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (40, 'Jaket Hoodie Reiciendis', 'Desain modern', 'danuja30@yahoo.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (41, 'Jaket Hoodie Perferendis', 'Tahan lama', 'dimaz63@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (42, 'Sepatu Sneakers Dolore', 'Nyaman dipakai', 'lulut53@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (43, 'Dress Midi Eos', 'Tahan lama', 'zulaikha2@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (44, 'Kemeja Formal Tempore', 'Nyaman dipakai', 'dimaz63@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (45, 'Dress Midi Labore', 'Desain modern', 'salman90@protonmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (46, 'Sepatu Sneakers Necessitatibus', 'Desain modern', 'umay10@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (47, 'Tas Ransel Maxime', 'Desain modern', 'ivan20@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (48, 'Dress Midi Quibusdam', 'Desain modern', 'budi58@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (49, 'Dress Midi Ea', 'Desain modern', 'iriana68@yahoo.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (50, 'Celana Jeans Voluptatem', 'Desain modern', 'nadia54@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (51, 'Sepatu Sneakers Fugiat', 'Tahan lama', 'harsanto74@mail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (52, 'Kemeja Formal Minus', 'Desain modern', 'zulaikha2@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (53, 'Jaket Hoodie Officia', 'Produk berkualitas tinggi', 'harsanto74@mail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (54, 'Kemeja Formal Velit', 'Nyaman dipakai', 'harsanto74@mail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (55, 'Kaos Polos Veritatis', 'Nyaman dipakai', 'oskar15@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (56, 'Topi Baseball Rerum', 'Desain modern', 'budi58@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (57, 'Tas Ransel Ad', 'Desain modern', 'budi58@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (58, 'Sepatu Sneakers Eaque', 'Nyaman dipakai', 'dimaz63@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (59, 'Jaket Hoodie Quidem', 'Tahan lama', 'budi58@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (60, 'Topi Baseball Tempore', 'Tahan lama', 'perkasa91@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (61, 'Topi Baseball Delectus', 'Desain modern', 'nadia54@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (62, 'Sepatu Sneakers Numquam', 'Desain modern', 'harsanto74@mail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (63, 'Topi Baseball Ratione', 'Desain modern', 'puji19@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (64, 'Jaket Hoodie Perferendis', 'Desain modern', 'budi58@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (65, 'Kaos Polos In', 'Desain modern', 'oskar15@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (66, 'Topi Baseball Sint', 'Produk berkualitas tinggi', 'sakura70@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (67, 'Kaos Polos Blanditiis', 'Tahan lama', 'ivan20@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (68, 'Kaos Polos Id', 'Produk berkualitas tinggi', 'nadia54@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (69, 'Kemeja Formal Temporibus', 'Desain modern', 'iriana68@yahoo.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (70, 'Topi Baseball Voluptatem', 'Produk berkualitas tinggi', 'nadia54@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (71, 'Jaket Hoodie Facilis', 'Produk berkualitas tinggi', 'lulut53@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (72, 'Tas Ransel Molestias', 'Produk berkualitas tinggi', 'dimaz63@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (73, 'Kaos Polos Quod', 'Produk berkualitas tinggi', 'zulaikha2@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (74, 'Celana Jeans Esse', 'Tahan lama', 'iriana68@yahoo.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (75, 'Jaket Hoodie Dolore', 'Nyaman dipakai', 'salman90@protonmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (76, 'Celana Jeans Reprehenderit', 'Nyaman dipakai', 'dimaz63@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (77, 'Dress Midi Deleniti', 'Tahan lama', 'perkasa91@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (78, 'Celana Jeans Quo', 'Tahan lama', 'jamalia36@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (79, 'Tas Ransel Corporis', 'Produk berkualitas tinggi', 'dimaz63@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (80, 'Kaos Polos Delectus', 'Nyaman dipakai', 'oskar15@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (81, 'Kaos Polos Corrupti', 'Tahan lama', 'iriana68@yahoo.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (82, 'Kemeja Formal Itaque', 'Desain modern', 'sakura70@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (83, 'Celana Jeans Corporis', 'Tahan lama', 'oskar15@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (84, 'Kaos Polos Illo', 'Produk berkualitas tinggi', 'puji19@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (85, 'Celana Jeans Odio', 'Desain modern', 'dimaz63@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (86, 'Kemeja Formal Voluptas', 'Tahan lama', 'nadia54@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (87, 'Kemeja Formal Quisquam', 'Tahan lama', 'ivan20@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (88, 'Topi Baseball Cum', 'Desain modern', 'oskar15@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (89, 'Kemeja Formal Non', 'Desain modern', 'heryanto85@mail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (90, 'Dress Midi Aut', 'Desain modern', 'ivan20@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (91, 'Jaket Hoodie Deleniti', 'Tahan lama', 'zulaikha2@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (92, 'Celana Jeans Dignissimos', 'Tahan lama', 'iriana68@yahoo.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (93, 'Topi Baseball Aspernatur', 'Tahan lama', 'puji19@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (94, 'Sepatu Sneakers Aliquam', 'Desain modern', 'jamalia36@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (95, 'Dress Midi Totam', 'Desain modern', 'perkasa91@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (96, 'Dress Midi Nostrum', 'Nyaman dipakai', 'oskar15@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (97, 'Jaket Hoodie Ex', 'Nyaman dipakai', 'budi58@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (98, 'Topi Baseball Enim', 'Produk berkualitas tinggi', 'heryanto85@mail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (99, 'Sepatu Sneakers Praesentium', 'Nyaman dipakai', 'puji19@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (100, 'Jaket Hoodie Modi', 'Produk berkualitas tinggi', 'puji19@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (101, 'Celana Jeans Asperiores', 'Tahan lama', 'perkasa91@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (102, 'Tas Ransel At', 'Tahan lama', 'danuja30@yahoo.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (103, 'Kemeja Formal Consequatur', 'Produk berkualitas tinggi', 'heryanto85@mail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (104, 'Sepatu Sneakers Quam', 'Nyaman dipakai', 'lulut53@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (105, 'Tas Ransel Culpa', 'Tahan lama', 'dimaz63@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (106, 'Celana Jeans Eum', 'Nyaman dipakai', 'salman90@protonmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (107, 'Kaos Polos Expedita', 'Nyaman dipakai', 'perkasa91@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (108, 'Jaket Hoodie Nemo', 'Produk berkualitas tinggi', 'dimaz63@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (109, 'Kemeja Formal Accusamus', 'Nyaman dipakai', 'perkasa91@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (110, 'Topi Baseball Necessitatibus', 'Tahan lama', 'perkasa91@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (111, 'Dress Midi Occaecati', 'Tahan lama', 'dimaz63@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (112, 'Topi Baseball Ullam', 'Produk berkualitas tinggi', 'budi58@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (113, 'Kaos Polos Quia', 'Desain modern', 'budi58@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (114, 'Kemeja Formal Placeat', 'Produk berkualitas tinggi', 'umay10@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (115, 'Celana Jeans Blanditiis', 'Nyaman dipakai', 'harsanto74@mail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (116, 'Tas Ransel Voluptatum', 'Nyaman dipakai', 'harsanto74@mail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (117, 'Kemeja Formal Inventore', 'Desain modern', 'budi58@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (118, 'Kaos Polos Ab', 'Produk berkualitas tinggi', 'iriana68@yahoo.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (119, 'Tas Ransel Consequuntur', 'Desain modern', 'salman90@protonmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (120, 'Celana Jeans Cupiditate', 'Desain modern', 'oskar15@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (121, 'Jaket Hoodie Iure', 'Produk berkualitas tinggi', 'danuja30@yahoo.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (122, 'Kemeja Formal Expedita', 'Produk berkualitas tinggi', 'iriana68@yahoo.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (123, 'Dress Midi Voluptas', 'Desain modern', 'lulut53@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (124, 'Dress Midi Asperiores', 'Produk berkualitas tinggi', 'puji19@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (125, 'Dress Midi Ipsum', 'Desain modern', 'sakura70@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (126, 'Celana Jeans At', 'Produk berkualitas tinggi', 'jamalia36@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (127, 'Jaket Hoodie Culpa', 'Tahan lama', 'ivan20@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (128, 'Topi Baseball Laudantium', 'Desain modern', 'danuja30@yahoo.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (129, 'Celana Jeans At', 'Desain modern', 'jamalia36@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (130, 'Sepatu Sneakers Veritatis', 'Nyaman dipakai', 'budi58@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (131, 'Sepatu Sneakers Iure', 'Tahan lama', 'puji19@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (132, 'Sepatu Sneakers Totam', 'Desain modern', 'perkasa91@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (133, 'Dress Midi Natus', 'Produk berkualitas tinggi', 'salman90@protonmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (134, 'Topi Baseball Facere', 'Nyaman dipakai', 'nadia54@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (135, 'Kemeja Formal Reiciendis', 'Nyaman dipakai', 'oskar15@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (136, 'Dress Midi Corrupti', 'Produk berkualitas tinggi', 'lulut53@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (137, 'Topi Baseball Illum', 'Desain modern', 'harsanto74@mail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (138, 'Tas Ransel Saepe', 'Tahan lama', 'ivan20@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (139, 'Dress Midi Cum', 'Desain modern', 'puji19@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (140, 'Tas Ransel Laboriosam', 'Nyaman dipakai', 'zulaikha2@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (141, 'Celana Jeans Nam', 'Produk berkualitas tinggi', 'oskar15@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (142, 'Tas Ransel Accusantium', 'Produk berkualitas tinggi', 'ivan20@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (143, 'Celana Jeans Culpa', 'Tahan lama', 'harsanto74@mail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (144, 'Kaos Polos Eos', 'Desain modern', 'budi58@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (145, 'Dress Midi Ea', 'Desain modern', 'budi58@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (146, 'Jaket Hoodie Nobis', 'Produk berkualitas tinggi', 'iriana68@yahoo.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (147, 'Kaos Polos Vitae', 'Produk berkualitas tinggi', 'oskar15@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (148, 'Kaos Polos Amet', 'Desain modern', 'jamalia36@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (149, 'Dress Midi Asperiores', 'Desain modern', 'harsanto74@mail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (150, 'Dress Midi Error', 'Nyaman dipakai', 'umay10@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (151, 'Sepatu Sneakers Ab', 'Nyaman dipakai', 'oskar15@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (152, 'Tas Ransel Rem', 'Nyaman dipakai', 'danuja30@yahoo.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (153, 'Topi Baseball Iusto', 'Produk berkualitas tinggi', 'zulaikha2@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (154, 'Celana Jeans Laudantium', 'Desain modern', 'harsanto74@mail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (155, 'Kaos Polos Veniam', 'Produk berkualitas tinggi', 'salman90@protonmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (156, 'Tas Ransel Dolor', 'Produk berkualitas tinggi', 'puji19@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (157, 'Celana Jeans At', 'Produk berkualitas tinggi', 'salman90@protonmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (158, 'Topi Baseball Cum', 'Tahan lama', 'salman90@protonmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (159, 'Dress Midi Illum', 'Produk berkualitas tinggi', 'puji19@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (160, 'Kaos Polos Sint', 'Nyaman dipakai', 'ivan20@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (161, 'Celana Jeans Laborum', 'Produk berkualitas tinggi', 'salman90@protonmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (162, 'Kaos Polos Laboriosam', 'Nyaman dipakai', 'ivan20@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (163, 'Sepatu Sneakers Totam', 'Produk berkualitas tinggi', 'budi58@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (164, 'Dress Midi Quod', 'Desain modern', 'nadia54@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (165, 'Celana Jeans Alias', 'Tahan lama', 'heryanto85@mail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (166, 'Tas Ransel Facere', 'Nyaman dipakai', 'salman90@protonmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (167, 'Celana Jeans Et', 'Produk berkualitas tinggi', 'dimaz63@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (168, 'Celana Jeans Deleniti', 'Tahan lama', 'nadia54@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (169, 'Sepatu Sneakers Sit', 'Desain modern', 'zulaikha2@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (170, 'Sepatu Sneakers Dolores', 'Nyaman dipakai', 'budi58@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (171, 'Sepatu Sneakers Eaque', 'Tahan lama', 'puji19@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (172, 'Sepatu Sneakers Adipisci', 'Produk berkualitas tinggi', 'danuja30@yahoo.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (173, 'Kemeja Formal Eius', 'Nyaman dipakai', 'perkasa91@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (174, 'Sepatu Sneakers Quo', 'Tahan lama', 'puji19@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (175, 'Celana Jeans Nesciunt', 'Produk berkualitas tinggi', 'sakura70@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (176, 'Kemeja Formal Magni', 'Desain modern', 'dimaz63@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (177, 'Dress Midi Labore', 'Produk berkualitas tinggi', 'dimaz63@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (178, 'Celana Jeans Facere', 'Tahan lama', 'sakura70@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (179, 'Celana Jeans Veritatis', 'Tahan lama', 'sakura70@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (180, 'Kaos Polos Delectus', 'Nyaman dipakai', 'lulut53@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (181, 'Celana Jeans Nostrum', 'Tahan lama', 'lulut53@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (182, 'Dress Midi Architecto', 'Desain modern', 'umay10@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (183, 'Kemeja Formal Voluptatem', 'Produk berkualitas tinggi', 'ivan20@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (184, 'Tas Ransel Laudantium', 'Tahan lama', 'nadia54@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (185, 'Kemeja Formal Quis', 'Nyaman dipakai', 'umay10@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (186, 'Jaket Hoodie Porro', 'Tahan lama', 'dimaz63@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (187, 'Celana Jeans Praesentium', 'Desain modern', 'budi58@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (188, 'Kemeja Formal Mollitia', 'Produk berkualitas tinggi', 'umay10@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (189, 'Kaos Polos Fuga', 'Tahan lama', 'umay10@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (190, 'Topi Baseball Architecto', 'Nyaman dipakai', 'salman90@protonmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (191, 'Jaket Hoodie Provident', 'Produk berkualitas tinggi', 'dimaz63@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (192, 'Topi Baseball Nesciunt', 'Nyaman dipakai', 'perkasa91@outlook.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (193, 'Dress Midi Sit', 'Desain modern', 'umay10@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (194, 'Kaos Polos Aliquid', 'Desain modern', 'salman90@protonmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (195, 'Tas Ransel Cupiditate', 'Produk berkualitas tinggi', 'oskar15@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (196, 'Kaos Polos Aspernatur', 'Tahan lama', 'sakura70@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (197, 'Kaos Polos Ipsam', 'Nyaman dipakai', 'nadia54@gmail.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (198, 'Jaket Hoodie Deleniti', 'Desain modern', 'oskar15@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (199, 'Tas Ransel Officiis', 'Desain modern', 'lulut53@aol.com');
INSERT INTO produk (no_produk, nama_produk, deskripsi, email_penjual)
                 VALUES (200, 'Dress Midi Veniam', 'Desain modern', 'umay10@aol.com');

-- INSERT INTO gambar_produk
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (1, 'produk/6b3d0beb-513b-4b0d-afb8-47bd6e9c3223.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (1, 'produk/1e4fba4a-3a2a-4661-ac2c-fdfca3780d6e.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (1, 'produk/3b72bd85-1054-4451-ab0d-5808c22dedc2.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (2, 'produk/75c40b7b-50e3-4d75-843b-ff76ecf6d648.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (3, 'produk/a0be4fe3-0036-44ba-95a6-75b41ed57ae9.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (3, 'produk/80b513e6-8229-4be9-879a-449e6da0c33d.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (3, 'produk/efccacff-5a0a-4bc8-bac0-55e2143f08d7.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (4, 'produk/00cf86b6-7d47-41d0-9a67-6408c50c9be0.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (4, 'produk/9376ba29-2a17-42c2-88fe-c887814ef42e.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (5, 'produk/66a13b3d-0552-4b38-9c40-6ecbc1b56c92.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (6, 'produk/00a03aa9-4007-45e2-8d76-a0d3a829a531.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (6, 'produk/4936217a-d7e6-4fc8-bf20-9bdebff90ce4.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (7, 'produk/f10a0a74-c350-4ded-9103-bdc8e6542467.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (8, 'produk/e05cc869-f7c8-4a04-a750-ec1987464034.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (9, 'produk/b67d6947-d3bf-457f-8f50-7def4834b313.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (9, 'produk/910d3715-8d88-4adb-91cb-0129d1ae377c.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (10, 'produk/cdceee8a-befd-4641-b074-fbde35b5b17b.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (10, 'produk/61e653bb-42ed-4d65-a02a-54a03013463d.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (11, 'produk/8933916d-0253-46df-bd3d-d93825053b1a.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (11, 'produk/b0223ba3-5520-45c7-89ff-b996b68934f7.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (11, 'produk/4dd1add3-307b-4708-a890-23ff3e530b9b.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (12, 'produk/c448e1b5-7498-4a60-aba6-2c7b22bb7f86.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (12, 'produk/72a315f2-96ec-4133-a59b-56e1ae1032c7.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (12, 'produk/be1d2847-ab82-4401-bd0d-dcbf212d66b9.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (13, 'produk/6790366a-a8d9-46f3-98a8-885be4b9a298.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (13, 'produk/2b19267e-caf4-4375-99bc-686310254424.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (14, 'produk/3b1dc61e-705d-403e-ac44-8a15e37a61e2.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (14, 'produk/6ba3f381-e182-469c-91c0-bdfa47974b0b.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (14, 'produk/034e9518-0fa7-4ef3-82ca-e27e8c856edd.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (15, 'produk/7e5053e1-b24c-45df-8464-7b06429e1b3c.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (15, 'produk/fd4ecfa0-924a-4856-b3a2-c490cbb98bd8.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (15, 'produk/453aabae-3756-43f0-8b40-748c18534317.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (16, 'produk/842cb940-c1a0-4555-a15d-c702c37396c8.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (16, 'produk/0b007c52-f327-46d3-91ad-f78a7d4dc14e.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (16, 'produk/dcef2bb6-8cd7-4fab-a65d-58142d91f669.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (17, 'produk/e40d63fa-605e-4fd7-80ba-e81feb245665.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (18, 'produk/aaef925c-ffd8-419c-9e7d-be6ec599287d.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (19, 'produk/72f7b332-b180-4466-b99e-0c9048aa0e8d.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (19, 'produk/1dfbf19d-ab3e-4327-b6f7-ad47c1e43dd9.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (19, 'produk/405d0415-5839-4293-aeb1-ad31c7901112.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (20, 'produk/e2490bf5-4da4-4e29-bb2b-265b18e262a7.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (20, 'produk/e4570118-f9d8-4ab5-9f11-9d086b29af9e.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (21, 'produk/8bbe412a-0912-46fb-aa15-fa1fd9c083de.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (21, 'produk/60fae80e-e9f8-450b-b031-a3886a15f046.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (22, 'produk/e2fa6a65-8c40-48dd-80a5-051a933ed59f.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (22, 'produk/f0649ebf-5859-41c6-94bb-b37969093560.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (22, 'produk/6817c89e-78cc-4ab7-b0ef-d33e4fddecf5.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (23, 'produk/c3bf2712-0dc0-45fb-8542-ef4f6539dbe3.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (23, 'produk/67087841-5fdd-4aee-bb5d-ecb76b74c323.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (23, 'produk/dba97e79-edab-48c9-9ff6-262612fa5116.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (24, 'produk/5ef55c12-88ff-4422-915f-2df7fac27b31.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (24, 'produk/f1733550-3f3d-40a1-b1d2-f84c1e75c804.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (25, 'produk/25cc6054-8876-422d-9d5f-1e389598784b.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (26, 'produk/1b436961-8b0f-4cc3-bb45-5615a1fa51bd.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (26, 'produk/5a13ea35-b611-4e49-be5b-092d8b5981c3.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (26, 'produk/b2ad0c2c-788d-4db9-98ab-aa8db6049dd9.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (27, 'produk/2e958646-bcc6-4def-ac58-dd30da0074dd.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (27, 'produk/43aa23d6-8613-43c4-9a39-03f8394f1341.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (27, 'produk/1afd2700-4abb-4c52-9da7-4f843ff87cad.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (28, 'produk/ebb133d2-0ea3-455c-be67-f9ef3368564f.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (28, 'produk/d8d4f0e7-ccae-4fac-a6ce-6ebc7590d135.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (28, 'produk/d3fe37bc-cd9c-49c8-a6d9-df4cdb9de248.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (29, 'produk/de3df528-a27c-459d-b8b5-022c8ab38d4b.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (30, 'produk/d8a7b2bf-73d2-45cf-ba92-5157e85f031e.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (31, 'produk/2a9cac58-4e6c-4cb7-a308-4ad0065e92fd.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (32, 'produk/054b5842-f7e5-48aa-8398-31ed7974cec0.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (32, 'produk/67559856-b902-4ecb-b3e6-8e67d334ce65.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (33, 'produk/518550aa-89ef-4a5f-95a0-0ff9ce215592.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (33, 'produk/b78a6c4f-9b27-4e1e-8b79-8096534b5513.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (33, 'produk/f7133d8d-616a-40b5-afdb-d8600576324d.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (34, 'produk/12b49a96-ae68-4011-87cc-55133618eb56.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (34, 'produk/e70b212a-3d56-472c-b73e-7e4c4afcb70e.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (34, 'produk/82c3cbb5-b54f-4451-bcf8-5e298ae8c4cf.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (35, 'produk/71de2685-32a5-4b8c-ac3f-4dd30e491ba7.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (35, 'produk/1408bd89-0369-424e-9198-ab9f50ec9b64.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (35, 'produk/b08da85b-9bdf-4961-ba5c-f9583f6acca3.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (36, 'produk/7bdd9549-204d-4649-872c-cb5af7dc9ce2.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (37, 'produk/5bf96af9-3a11-413c-a551-d9c671123251.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (37, 'produk/3a2c5aa5-e22a-4beb-89f8-5ffae9f4a387.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (37, 'produk/19df8f53-381c-4e67-870e-701c628348bd.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (38, 'produk/3b1ece0e-eaaa-47fc-bca7-53d53e72486f.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (38, 'produk/02e5a2c1-f40d-44b8-bf2e-e565174a4386.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (38, 'produk/da93c451-f332-4d62-85b0-9b8f718a4923.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (39, 'produk/0a246bfc-11bb-4092-8767-6136c0dd2a17.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (40, 'produk/11766e7d-5d0b-49fa-a51d-f9ef69e40306.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (40, 'produk/581a865f-5784-4d56-a57d-4efe412214cd.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (40, 'produk/17513dea-818a-422b-953f-5fb4591cebd6.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (41, 'produk/d32e4504-a86b-47bf-9283-709ad0646f1d.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (42, 'produk/54b045b1-f567-4135-9e1f-b0a58a44535f.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (42, 'produk/52d7dcf0-3710-41fa-8a4f-8464909bf59e.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (42, 'produk/4413a96c-db60-45fc-a405-8f2ebb6e30b4.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (43, 'produk/9294be31-6e4b-49e1-9ee4-dd8589aef964.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (44, 'produk/c872b25a-c4d4-4b18-8421-faa6e38304e1.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (45, 'produk/e05bc5d6-9c8e-40f7-a899-824f7b04500e.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (45, 'produk/e471ff7f-1658-4770-844d-bd22c5a0b3ce.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (46, 'produk/053618ef-4aad-46db-938c-75403c0ad150.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (47, 'produk/a8bb9a41-609b-4f5f-b091-753173d9eb70.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (47, 'produk/2e4359ea-8465-4abc-a395-4913b785da8a.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (47, 'produk/26f8ec08-c2ba-4432-9434-062767bcc43f.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (48, 'produk/58a22c0f-9dcf-41a6-99d9-e15baa4a126e.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (48, 'produk/b5f98b34-0d25-4831-99e4-8bc3dea369c3.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (48, 'produk/f7150968-57d4-4a8c-be62-80eecc572b3f.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (49, 'produk/ac2290c8-7f70-4b26-a382-d935a113f012.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (49, 'produk/f051439e-0f00-4756-baae-d15edb4a1e11.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (49, 'produk/e556afd8-29d3-48bd-b521-a5e43c8352e0.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (50, 'produk/d8478e4e-0b53-4b55-af56-1fd4ee1308d1.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (50, 'produk/7ba58425-3e3e-46e0-bb3f-9ada84fa8e26.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (51, 'produk/22ef90fb-2763-4088-adbf-9f3acbc5c1fe.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (51, 'produk/bf563fc9-1882-4a05-8cae-aa62f91e8c07.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (52, 'produk/05dbceef-1ff3-4220-9904-0b8578d3887c.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (53, 'produk/2d4fcbc0-4e33-4f39-9566-20441ad5223a.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (53, 'produk/c85cfa9c-f070-4abe-bbd4-9577272378c0.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (54, 'produk/3ea0e9a8-9012-44ed-9771-12fc29166f55.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (54, 'produk/ebdee061-fb13-407b-aa00-17e616b8de37.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (55, 'produk/254bafdb-73da-4699-84be-16cace14bcc9.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (55, 'produk/1356afb2-53dd-4ba1-83d3-71c6e84793c8.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (56, 'produk/ef644f75-8e23-4596-89d5-09677423b951.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (57, 'produk/f280a08a-fca8-4c51-b2b4-650b6362364e.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (57, 'produk/d1934180-92a7-4702-82f0-b273ceada503.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (57, 'produk/dd746d34-ce6e-4855-90c6-9cbd29b93134.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (58, 'produk/fbac2a4b-1d56-4afd-b3bd-ff36f34439fa.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (58, 'produk/42b5e761-3a5a-4645-84ba-adc5378c4ab0.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (58, 'produk/db7d3945-4867-43b5-8b9a-36b46b1adcfa.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (59, 'produk/da481805-e032-4e25-acd4-c97202ad6427.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (60, 'produk/9b1c639b-d8a6-4ad9-a98e-b13619fd685f.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (60, 'produk/aec318af-68e5-4f71-9c08-715fd674828d.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (60, 'produk/75bcebee-94e3-438d-8c3b-277263975869.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (61, 'produk/3a5c3762-af65-47ce-86c6-893f7531cde9.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (61, 'produk/1e34f5fd-2152-4785-897b-8a960b5f70bd.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (62, 'produk/d630ace8-b9bf-4c2f-bd67-56fa1ebc6096.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (63, 'produk/0d78bcdc-3399-49fe-ae87-9ff8624255a2.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (63, 'produk/c164468f-7f32-41a3-9c59-3f2248daa5ce.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (63, 'produk/a81d024c-f0a3-410a-9d01-09cfecae4baf.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (64, 'produk/d339e4b4-0540-41bd-b7f1-e619d93d9340.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (64, 'produk/2bca59be-8121-4d9f-a937-6dbc558a52ba.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (64, 'produk/6dcd5030-d70a-47cf-be42-07649d500b79.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (65, 'produk/a407b313-bd6d-413a-9717-e5312d3985bd.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (65, 'produk/44145637-4222-4ce0-9e2d-5146369938af.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (66, 'produk/c25ded2a-ae83-473b-81a3-9b5636673421.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (67, 'produk/49f60515-cef9-4cb3-8a0e-6d645a0a8df4.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (68, 'produk/505d4ba5-0739-4bb7-a2c4-ac8e0e63680a.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (69, 'produk/b69ff2c5-8521-4d0a-bc61-fdd21492d3c6.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (69, 'produk/ef171ef7-ce17-4e9c-a5c1-0a9bb7422ac7.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (69, 'produk/7e75f4cf-7238-4224-b54d-65a133e24adf.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (70, 'produk/e062bf4b-92f2-47bf-8908-e4ab98385b60.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (70, 'produk/8ee39bcd-6001-4d3b-b1d1-6cc6cebedc08.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (71, 'produk/04b9ac0d-afc8-46c0-940a-1515de2bc67b.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (72, 'produk/d82f6297-f825-4dc2-ba87-0924455fcb1c.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (73, 'produk/907a4253-e348-4012-803e-c63d4505694a.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (73, 'produk/354378c4-4a1f-4f7d-8af2-6de16b53c6e6.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (73, 'produk/1ba10637-90b6-4ae7-8ee1-918b101049be.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (74, 'produk/f88bbaa2-d1e0-4ddb-a7e1-ba10330fb3ba.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (74, 'produk/415de773-deaf-4821-9878-a057c1e107d5.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (75, 'produk/88554f1c-9430-4d91-8089-cebc89d088f6.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (75, 'produk/0a76915f-b4e5-4e05-a17d-83da3be491bc.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (76, 'produk/a33765f3-e4d8-4f65-aa6c-ccd68f1a3e89.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (76, 'produk/a52b09f9-0e35-4838-8cb0-0a98db43f314.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (77, 'produk/9463a3d6-1d58-4bb0-ba6d-5c1f46affaaa.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (77, 'produk/8d5025b1-9b10-4f85-a658-0a846b9c1c34.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (78, 'produk/353fce22-be1f-4a8b-8f15-0f90c7b6c64d.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (78, 'produk/93742077-bc30-4729-9cd6-c43856c8ff69.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (78, 'produk/d9b2f7d5-d764-4a71-89b5-0dd54978f44e.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (79, 'produk/40a937ea-e51f-4ed7-be23-4565d36859f2.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (79, 'produk/47c7b580-46d4-4c32-900f-7a6cfd27d31d.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (79, 'produk/2c2cdfbd-9b54-49a6-b69b-811580d11874.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (80, 'produk/cab10fb9-d223-409e-84a8-a139d2f0c5d8.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (81, 'produk/46fa3575-e43e-4edf-8a38-9563516e21d8.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (82, 'produk/c0e0e600-d89e-47a6-9bf9-d65aa4935bb2.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (83, 'produk/2793d00f-781c-4017-9d51-b66309cf0535.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (83, 'produk/9cc7e9a7-7464-4bef-8d8b-ddf00b57f31a.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (84, 'produk/3d89312c-a8c4-46cb-81df-5f497779ee2c.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (84, 'produk/0465a602-c280-4a02-abb7-f557978fec6b.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (85, 'produk/f8ac132e-4827-4bd2-875b-eab656268ad3.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (86, 'produk/8f2b75f8-9dea-43fe-b895-ae1df122098f.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (86, 'produk/fefe50fd-a436-41be-a651-710ae5d04b60.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (86, 'produk/2741914d-f86a-48eb-b946-bc7d478d1e98.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (87, 'produk/1989f0dd-b6d7-414f-bba4-d52c227f3d77.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (87, 'produk/8fde18c5-b14e-4c29-8b53-e55fa1051118.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (88, 'produk/b9ea63bf-abbd-4847-af0c-1154e7139665.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (88, 'produk/81aee4bc-45dc-4844-b293-4f71cf867604.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (89, 'produk/7d712d63-11fb-4cae-b575-04562bbe93d0.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (89, 'produk/435ec659-94a6-4a29-8dd4-ef61e6d469af.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (90, 'produk/89b7f616-c0c4-464b-a95e-ac024194b2f3.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (91, 'produk/5e541cce-76c7-47c4-aead-af605c16fa75.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (91, 'produk/e561df76-29a4-4cf0-a3df-2ba4982aeee2.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (91, 'produk/ec90184f-5684-49e2-9b6f-ecac3c915a6a.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (92, 'produk/4aa39ddb-c3dc-4863-99ae-a6004697c573.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (92, 'produk/895196ef-bc77-45ef-8a3e-c48cbea56897.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (92, 'produk/2bb0656f-8a00-48b3-8840-e6e81a475906.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (93, 'produk/b1d616bc-e0fb-4bbc-a079-71f8fac7a18e.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (94, 'produk/eb3b6240-3ced-4047-b863-00734938cce3.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (94, 'produk/9dcae312-ae65-4ca0-84ae-c71cb6c40218.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (95, 'produk/6018442f-fa79-406e-bcac-3293f772ad90.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (96, 'produk/4ece9d23-b0bf-403a-8261-ee33183dea40.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (96, 'produk/fb4dffd9-a6ae-4861-a027-00958d8ab952.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (96, 'produk/77196476-c9ac-401e-9bb2-0d79c1f67d4d.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (97, 'produk/ddd2d34c-4a83-45bb-b0be-c8cbdaaa140c.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (97, 'produk/1123e1fd-c77a-4663-9112-d1d57f57478c.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (97, 'produk/f88d09dc-50f9-4bfe-847d-b2c2dfb0eca2.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (98, 'produk/49c178ff-a949-4e31-bb6b-dc700ccab61b.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (98, 'produk/ff6148ee-ea6b-492c-9a33-e48080dc5bd5.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (99, 'produk/c12a60ec-5301-4b40-82f2-7457d537d006.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (99, 'produk/6dae028c-3a3c-4b77-9356-12ac739a27df.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (99, 'produk/b1353230-59c3-4ded-9ef7-4c43c0d38fa5.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (100, 'produk/bbd81429-45db-45eb-887a-e650b68e2e5f.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (101, 'produk/5c1d7cfc-c24f-431e-bf6d-c60a17b672bb.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (102, 'produk/2834e43b-2d4a-42d1-82e5-6b0d7a78505a.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (103, 'produk/4fc0eb5f-5793-40bd-8cec-c68f0523082e.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (103, 'produk/64ee42b7-b8b1-42b6-b4c0-05c2ec02a8d6.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (103, 'produk/f049225a-f54a-41ee-bf05-5202436ed6b9.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (104, 'produk/a4c2fa59-9455-4f4d-a001-283b44d78d7f.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (104, 'produk/0788dd8a-4c41-4151-9258-47aeac749242.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (104, 'produk/f5223285-30a0-4a6e-b866-1ca522ae513c.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (105, 'produk/fb1f98af-2973-4e71-97ac-577e49e1fcf7.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (106, 'produk/6517379c-09e7-4ce1-bc8a-f1ba059a1b9d.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (106, 'produk/6250bd5c-2258-4225-b263-7eeaea091262.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (106, 'produk/bd572619-c619-4502-ba3c-914998bb503c.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (107, 'produk/c1758d37-815b-459d-b902-1fbbb0fe00cf.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (107, 'produk/e4427db5-f7f5-44d7-a000-01a959fd9f87.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (108, 'produk/3e7f27b7-41b8-452c-828f-aa277a03f21d.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (108, 'produk/d2e9b4bd-c4c4-4bff-80f9-c32fffdf6c11.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (109, 'produk/3660a9a8-8d1f-4f79-99d2-a76e8690381b.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (110, 'produk/292a8844-a2c4-40ec-9f42-8343d786e13d.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (110, 'produk/0d195439-e240-4efe-b86a-f4d8cb516978.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (111, 'produk/48679d9e-3a9c-4109-b35d-41b499f2cab5.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (111, 'produk/eac8595c-ef15-4703-9e72-bc3bda7913e2.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (111, 'produk/c79409c6-96e3-48f3-8132-23bf7f4dcb31.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (112, 'produk/10de83c5-50be-4e15-895e-f39837b02bd3.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (112, 'produk/be8ac4eb-1630-431c-a0cd-ee901b8e9412.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (113, 'produk/5abcc44e-fa2a-473f-94c3-c3708576a11a.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (113, 'produk/d1c95b9a-63f2-4702-8673-5952dac0607d.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (113, 'produk/41562ae4-289c-4b59-b391-93557db9989e.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (114, 'produk/916923f8-836f-4550-ab12-9798225906fb.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (114, 'produk/0036dc60-07a1-4ddd-81d9-3f5097481ade.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (115, 'produk/b940d9f6-4499-4983-9474-51dea21b4d86.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (116, 'produk/92dccb22-c1a6-403e-a483-abb8ce764425.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (117, 'produk/d6194fda-d2b9-405d-b3c1-a3a1ab6ffa70.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (117, 'produk/1806d9b2-56b8-4fe4-a424-348d49296f96.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (118, 'produk/77f83a78-ac82-4994-ba49-558cc2d9445a.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (118, 'produk/6d2c520d-bca2-42a9-b72b-6987688bd889.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (118, 'produk/681ad1ec-dc7d-4154-90e4-fd10a2bc9179.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (119, 'produk/0496bbaa-b847-411a-a09e-026cd4c610bb.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (119, 'produk/8cb69b79-bd7f-4dab-a146-d83f449997a5.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (120, 'produk/89ee2c22-c3cd-46a7-bc4a-e014e53b27b8.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (121, 'produk/49191c44-623c-413a-9d6f-129f22d17da6.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (121, 'produk/46346d0c-30e7-4391-a350-fc315a3dd185.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (121, 'produk/7804cceb-a9e2-41cc-83d5-b6ac8a9d74df.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (122, 'produk/089793cc-b266-4c5d-9334-be48162e73fe.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (123, 'produk/fd144ce7-1f85-476b-ab8b-ecc400fd7a5f.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (123, 'produk/1623545d-db20-4148-b33c-419ca8d2dbf8.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (123, 'produk/32e63869-b69e-48c6-a5f2-359aaae6d303.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (124, 'produk/0053d767-092c-4710-98e4-f9cb8e914b29.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (124, 'produk/4b97667f-9e22-4a86-b0da-d4f636f5ffe2.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (124, 'produk/268f4b12-7fb8-4b22-be82-34293a8ef275.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (125, 'produk/f0bd1356-fc12-45ea-9535-b0f7714890d6.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (126, 'produk/bb510c08-dd0f-446f-a50c-a5e06db03267.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (126, 'produk/773de2b8-3aca-42d1-a472-e18a4a50372a.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (127, 'produk/66d6d01c-18c2-4210-8828-f709b4e5f50e.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (127, 'produk/1dd538ed-24a1-446e-a9c5-db0cfba677a8.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (128, 'produk/f1385d3f-5573-46b7-9f7e-f8a5fe01d60a.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (128, 'produk/df8d0dbc-fb80-4fd2-b83d-69ff307492b5.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (128, 'produk/296d6e81-7c9b-495f-a5f8-a963aa49fc9c.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (129, 'produk/31fbdafd-3adc-492a-b0a3-32d2dbd8c524.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (129, 'produk/b8046e47-25e9-4b6c-976d-64f0cb104b53.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (129, 'produk/715481ee-3e79-4f76-9669-87910309d992.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (130, 'produk/78fa9e92-1695-4da5-9cfd-cc4bc4796e0e.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (131, 'produk/6cde7ff9-89ad-4de3-a37b-62310b2308c5.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (131, 'produk/c76bfe0d-97b6-4201-ac15-728ca926c27a.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (132, 'produk/3573a80e-04e8-4e52-95c8-6707f57f70be.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (132, 'produk/795f3337-a895-486a-a559-78c6d0b28cea.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (132, 'produk/d63fafd8-5ca5-470c-a8c2-bfa3a65229b3.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (133, 'produk/6d330089-24d0-4ed7-8e76-172e8f28e402.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (134, 'produk/186a978a-89cb-44ec-babc-f2930cc7b04a.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (134, 'produk/7f2f0526-7aea-442a-bfb6-4b5dc905c0d4.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (134, 'produk/91f8b1e2-f78a-4633-b8c0-daee6facbffe.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (135, 'produk/31f98ab6-3d65-4bc1-93be-94eb5d6f86fd.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (136, 'produk/23cad934-ea0e-45b2-9e1e-d958b1452b79.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (137, 'produk/e0a04f89-af2d-4463-9407-cf6660f170d1.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (138, 'produk/e26eaa48-c037-4239-8fbd-b60712d39b07.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (139, 'produk/4bb5f651-cd61-43dd-a1f2-c63c8c49e762.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (140, 'produk/317b2a56-bc8a-4ff3-8a9d-eeb1ca1ac0ae.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (140, 'produk/918c5510-e6db-4a7e-9649-c5d150c3a274.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (141, 'produk/85cc1483-1d06-4faf-8166-afccf5ea11e3.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (141, 'produk/ce586155-fa9d-473e-b789-ce2bdb1d9dba.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (142, 'produk/944b3d76-c8f8-40f4-ab91-93769feedf19.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (142, 'produk/1589ef3c-022e-4b39-9d7f-70ef868c3311.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (143, 'produk/db3147fd-0bcd-4a1a-84ea-26031fabe28f.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (143, 'produk/b8d865cd-e016-4906-9eb8-f6a71950ef80.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (143, 'produk/9a294ee9-520a-4ad6-8b98-90c09bedea84.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (144, 'produk/2abeb706-6189-4b7d-b871-07e847f12012.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (145, 'produk/48379d12-42d5-4137-88e9-c06d96f6dd23.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (146, 'produk/b93b5706-5b73-4152-9412-e0ae5e7db76f.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (146, 'produk/23a4f7cf-beae-4cfe-b59d-8709901aaead.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (147, 'produk/873b7987-0147-4514-8fbd-4c611ae62bce.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (147, 'produk/fcac8eb5-8c3f-4f22-a5a0-24e65a8d4671.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (148, 'produk/aac3ec1b-951c-443c-996a-0f610722c9ac.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (148, 'produk/5aa229c6-0bfb-4da8-a930-1eb15834259f.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (149, 'produk/f9ba7daf-3738-445c-b908-3be1119c34ab.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (149, 'produk/5ba99aba-9ad9-4220-a6c2-9c7701893e55.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (149, 'produk/21eba4f2-15fa-4c03-9031-e92dbd19ba98.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (150, 'produk/93cababa-c32b-49fa-b24c-fb86f1d6b847.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (151, 'produk/15bc66dd-2348-42e3-87ff-ab5e19eb9f67.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (152, 'produk/db4f6807-ad1a-4996-8e75-4e2c5d1f3b20.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (153, 'produk/6fe6f149-2c29-43e7-a5b8-83ff23377c16.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (153, 'produk/f6aaa553-8323-4347-b867-e7f448dfc72b.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (154, 'produk/04bcbabe-1f18-4bae-9344-f62650ea5dbb.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (155, 'produk/12d75ef3-0096-445f-9ab9-76cb4c388384.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (155, 'produk/7ddf7025-a6ac-4a72-a53c-503f5712a8d6.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (156, 'produk/c1d862a1-b153-4cfc-8799-5bf80be0be6e.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (156, 'produk/67d00e89-5820-411f-a6ba-c8e730d91639.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (156, 'produk/5e16e466-0864-49c9-bb40-b3cb26378e86.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (157, 'produk/7890a4cd-6e6e-4ab4-8232-ed8b8622d654.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (157, 'produk/17a5b597-3320-428d-8e95-755af863e361.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (158, 'produk/dc47f88f-b0d5-41a5-8f8a-b53b646579cd.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (158, 'produk/8b62ad00-90c8-42e0-ba50-a65451df7134.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (159, 'produk/053b8969-8174-427a-8137-9e8dce504983.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (160, 'produk/62632471-fef2-4418-9440-7ba95fb4f051.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (160, 'produk/ebef9261-16c0-4373-9f8f-144ca3d9acda.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (161, 'produk/cd6bf6eb-419e-4214-9d27-33b128cdcb51.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (161, 'produk/dc7ac2a9-87a4-4912-bdfd-bfe1c9679254.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (162, 'produk/b4d7009e-15c0-47a4-a08a-ac040b716427.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (162, 'produk/7fb9cfb6-b91b-4837-958d-f20022d61b3e.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (162, 'produk/ef10784b-66f8-4efe-a7a1-634944e0f0fa.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (163, 'produk/ac9fc47e-350d-4bd8-8e5a-5c9e1686b61c.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (164, 'produk/b8921fab-06e7-4f12-8719-286bfec0eb62.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (164, 'produk/5f422a6f-1348-4602-a1bf-b1fcd0cbbd8e.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (165, 'produk/ce17b766-9d4f-41dd-9f06-7a3a0061b397.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (165, 'produk/f34a357e-2e71-4686-b487-98d5bcd701fb.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (166, 'produk/86bfd9f7-7b7e-42d8-839a-8a61e461b01b.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (166, 'produk/c96f298d-cf23-45c1-9fb7-ea3122d22894.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (166, 'produk/633c47a7-e682-446c-98b8-396ee8662a2f.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (167, 'produk/eee048ea-825f-4c05-b58c-74c302557114.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (167, 'produk/c4d1def0-3468-4d4d-9147-af7d30e05dd7.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (167, 'produk/566d37af-5ce3-47e7-9eda-6173faf0ae2f.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (168, 'produk/1aa1e2a9-47e6-41fa-8e64-e82c6f713c79.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (168, 'produk/3869eb35-2f64-4ea1-a618-36a25e417ed2.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (169, 'produk/83bb2b02-ee58-4bf5-a0ad-f58fde85d0ed.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (170, 'produk/11cb13b4-441d-4dc8-b6fc-d7a782408f8c.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (170, 'produk/15c0d618-3524-4f8e-a66a-98a6d75393fd.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (170, 'produk/1f82f0e9-eb2f-4b1f-9a75-5b40c4786c2e.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (171, 'produk/beff2c7a-490e-4f5e-a25b-0e03dbba204e.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (171, 'produk/169d1db7-7bcc-4aab-a5e8-e5511a5682b5.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (172, 'produk/b0a42753-9d2e-466c-9160-fbe9cdcfc17f.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (173, 'produk/208c0bfc-ea4a-4877-b1af-20328282b911.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (173, 'produk/2be6b190-7aed-4708-a448-41c883948f90.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (174, 'produk/9fe1a549-0168-451d-8a8f-45b6b4509708.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (175, 'produk/e6b69ea7-9fc0-479e-92e8-151b260552c9.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (175, 'produk/44fa3da1-f4f5-4d5b-aff3-8da2c9c453b4.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (176, 'produk/cf6f7e97-5b3d-49d3-97ce-fc4cbb7aa9a8.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (176, 'produk/6712a0e2-7ac2-4797-a26e-5884a6f77c46.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (177, 'produk/1ee03df2-a272-4599-8867-aa70c811fcc4.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (177, 'produk/481937f8-2a0e-4bc5-9d43-f24e0f41a39d.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (177, 'produk/908e5a94-3701-403e-b726-d6b6be238888.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (178, 'produk/faa0e70a-faa6-4e5d-bf74-e35c45252b3c.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (179, 'produk/3c5c03f4-b191-499a-84c1-c20b81a4642d.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (180, 'produk/758a1884-e33a-4019-9605-8be628bf5e3d.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (180, 'produk/113ad750-4e91-4c7e-863a-d4a82a913f83.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (181, 'produk/08b0eaed-0f21-491a-81a1-9698dc5217fd.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (181, 'produk/50f0a3d3-e717-4a0d-a8ed-93bfb2c0a96d.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (181, 'produk/3c5ad27a-ccc2-4f9a-b944-140f6c7e5398.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (182, 'produk/72d9a781-7065-4e06-b9fe-c4d5feeb2bc5.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (183, 'produk/086288b2-0545-45dc-b83a-a04e5fc76eb4.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (184, 'produk/dffdaf0f-f24e-48d0-a87f-8a761886c945.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (184, 'produk/a7517de4-6d64-4488-aa64-8d46a3c2674f.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (185, 'produk/19301422-8494-47f8-ac8a-aa3600bd94ef.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (185, 'produk/0d58c7fc-25f6-448e-b7de-634804f6504b.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (186, 'produk/3bed75d6-9811-408d-9d14-c17e0d799b83.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (186, 'produk/8f1d6859-b97f-4ec1-b25c-c6274de71eb7.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (187, 'produk/c0c01bce-003d-4909-be7f-1c1332bcddf6.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (188, 'produk/44d9b516-ea8a-41e8-ae18-0695607e5aea.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (188, 'produk/b1e1e54b-43f5-4906-8927-39dcbd49fac7.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (188, 'produk/98d1e3aa-df5a-4aea-8482-166b7d22ff78.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (189, 'produk/fbea2677-2213-4505-8cfe-7f13ca7a9a3d.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (190, 'produk/5aaeff32-b3bb-4632-b538-7986592514cd.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (190, 'produk/e1c4df54-f1e8-4abb-9270-ee4ae93aa83c.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (191, 'produk/09697224-cbd6-4b50-8d0a-3b1060f3e086.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (192, 'produk/84c1d39d-e77f-4dab-8a1a-8bd3d1a5313f.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (192, 'produk/ff07a66d-0954-44af-a017-8c07e5186c24.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (192, 'produk/eff4cba0-68cd-4aec-95e1-a72e267f7d3c.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (193, 'produk/0eedd622-2e46-4b28-b42e-cdb5dcc1e539.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (194, 'produk/de6ef9be-686f-4341-9310-d408cd29777a.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (194, 'produk/f4256644-bc97-46dd-a73e-688765eb04c4.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (195, 'produk/6c7b4307-b4da-4458-925c-c56bbfc2c35a.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (196, 'produk/a89c51d1-e9ac-41f1-8c61-d94219e7b7ec.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (196, 'produk/bb23d628-9ea5-4be1-95fa-9a65c326abe5.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (197, 'produk/2a14c5ca-64f1-4054-9d6b-8f8ed9d4829b.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (197, 'produk/d2314e0b-eb36-4ba6-be8a-fe9d56faa8cc.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (197, 'produk/71fd06c1-8d39-4d3e-96a1-7d5beae15b29.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (198, 'produk/834f2fba-0224-488a-83af-0b35b6359aca.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (198, 'produk/156d6748-1d61-4fea-b887-ad2c62e07587.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (199, 'produk/f2ee4cc2-7684-4dc6-971b-c542970f84ee.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (199, 'produk/a7b97570-afd8-4d7d-8247-a030972ec67b.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (199, 'produk/9c360baf-bfed-47b3-9274-375cba597713.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (200, 'produk/700d3069-13f1-4940-bdd1-affbe68483c7.jpg');
INSERT INTO gambar_produk (no_produk, gambar)
                         VALUES (200, 'produk/66c6560d-8446-4494-b276-a141458f2374.jpg');

-- INSERT INTO tag_produk
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (1, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (2, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (3, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (3, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (4, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (4, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (5, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (5, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (5, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (6, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (7, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (7, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (7, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (8, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (9, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (9, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (9, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (10, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (10, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (11, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (11, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (12, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (13, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (14, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (14, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (15, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (15, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (16, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (16, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (17, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (17, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (17, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (18, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (18, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (19, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (19, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (20, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (20, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (20, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (21, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (21, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (21, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (22, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (23, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (23, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (24, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (24, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (24, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (25, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (26, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (26, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (26, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (27, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (28, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (28, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (28, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (29, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (29, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (30, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (30, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (30, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (31, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (32, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (32, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (33, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (34, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (35, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (35, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (35, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (36, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (37, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (37, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (38, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (38, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (39, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (39, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (40, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (40, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (40, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (41, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (41, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (42, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (42, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (43, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (43, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (44, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (44, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (45, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (45, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (45, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (46, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (47, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (47, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (47, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (48, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (48, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (48, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (49, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (49, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (49, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (50, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (51, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (52, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (52, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (52, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (53, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (53, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (53, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (54, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (54, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (54, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (55, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (55, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (55, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (56, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (56, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (56, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (57, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (58, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (59, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (60, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (61, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (61, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (62, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (63, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (64, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (64, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (65, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (66, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (66, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (67, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (68, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (68, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (69, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (69, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (70, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (70, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (71, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (71, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (72, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (73, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (73, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (74, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (74, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (75, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (76, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (77, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (77, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (78, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (78, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (78, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (79, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (79, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (79, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (80, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (81, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (82, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (83, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (83, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (83, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (84, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (84, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (84, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (85, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (86, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (87, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (87, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (87, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (88, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (88, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (88, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (89, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (89, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (90, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (90, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (90, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (91, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (91, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (92, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (92, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (92, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (93, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (94, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (94, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (94, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (95, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (96, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (96, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (97, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (97, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (97, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (98, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (98, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (98, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (99, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (99, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (99, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (100, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (101, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (102, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (103, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (104, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (104, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (105, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (105, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (106, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (106, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (106, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (107, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (107, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (108, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (108, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (108, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (109, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (110, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (111, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (112, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (112, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (113, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (114, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (114, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (114, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (115, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (115, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (116, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (116, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (117, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (117, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (117, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (118, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (118, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (118, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (119, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (119, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (119, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (120, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (121, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (121, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (121, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (122, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (122, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (123, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (123, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (123, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (124, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (125, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (125, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (125, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (126, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (126, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (126, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (127, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (127, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (127, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (128, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (129, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (129, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (129, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (130, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (131, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (131, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (132, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (132, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (133, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (133, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (134, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (134, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (134, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (135, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (135, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (135, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (136, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (136, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (136, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (137, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (137, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (137, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (138, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (138, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (138, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (139, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (139, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (139, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (140, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (141, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (141, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (142, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (142, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (142, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (143, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (143, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (143, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (144, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (144, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (145, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (145, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (145, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (146, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (146, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (147, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (148, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (148, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (149, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (150, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (150, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (151, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (151, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (152, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (153, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (153, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (154, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (154, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (154, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (155, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (155, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (155, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (156, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (157, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (157, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (157, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (158, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (159, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (159, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (159, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (160, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (161, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (161, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (161, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (162, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (163, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (164, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (164, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (165, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (165, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (165, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (166, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (166, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (166, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (167, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (167, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (168, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (168, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (168, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (169, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (170, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (171, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (171, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (172, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (172, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (173, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (174, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (174, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (174, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (175, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (175, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (175, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (176, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (177, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (177, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (177, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (178, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (179, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (180, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (180, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (180, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (181, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (181, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (182, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (182, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (183, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (184, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (185, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (185, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (186, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (186, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (187, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (187, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (187, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (188, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (189, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (190, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (191, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (192, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (192, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (192, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (193, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (193, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (193, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (194, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (194, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (195, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (196, 'Formal');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (196, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (196, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (197, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (197, 'Casual');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (197, 'Wanita');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (198, 'Sport');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (198, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (198, 'Pria');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (199, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (199, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (200, 'Fashion');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (200, 'Aksesoris');
INSERT INTO tag_produk (no_produk, tag)
                         VALUES (200, 'Sport');

-- INSERT INTO varian
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (1, '1-GREY', 'Warna: GREY', 12, 633229.69);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (1, '1-RED', 'Warna: RED', 83, 697793.39);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (1, '1-BLUE', 'Warna: BLUE', 12, 719006.97);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (1, '1-BLACK', 'Warna: BLACK', 32, 793467.37);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (2, '2-WHITE-M', 'Warna: WHITE, Ukuran: M', 16, 288908.62);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (2, '2-GREY-M', 'Warna: GREY, Ukuran: M', 75, 538682.59);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (2, '2-GREY', 'Warna: GREY, Ukuran: M', 49, 217611.28);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (2, '2-GREEN-L', 'Warna: GREEN, Ukuran: L', 8, 468733.81);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (2, '2-RED-S', 'Warna: RED, Ukuran: S', 12, 787300.88);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (3, '3-GREEN', 'Warna: GREEN, Ukuran: S', 94, 470275.64);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (3, '3-BLACK', 'Warna: BLACK, Ukuran: S', 13, 959637.94);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (3, '3-WHITE-S', 'Warna: WHITE, Ukuran: S', 21, 582990.53);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (3, '3-GREY', 'Warna: GREY, Ukuran: S', 17, 906217.76);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (3, '3-NAVY-M', 'Warna: NAVY, Ukuran: M', 0, 56395.05);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (4, '4-BLACK-30', 'Warna: BLACK, Ukuran: 30', 74, 264633.17);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (4, '4-GREEN-M', 'Warna: GREEN, Ukuran: M', 76, 409841.98);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (4, '4-WHITE-M', 'Warna: WHITE, Ukuran: M', 93, 366489.37);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (5, '5-BLUE-28', 'Warna: BLUE, Ukuran: 28', 16, 532794.09);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (5, '5-BLACK-28', 'Warna: BLACK, Ukuran: 28', 97, 759070.51);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (5, '5-GREEN-30', 'Warna: GREEN, Ukuran: 30', 99, 412868.85);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (5, '5-BLACK-L', 'Warna: BLACK, Ukuran: L', 20, 654691.99);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (6, '6-BLACK', 'Warna: BLACK, Ukuran: L', 43, 99628.06);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (6, '6-RED-32', 'Warna: RED, Ukuran: 32', 39, 544161.03);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (6, '6-BLACK-L', 'Warna: BLACK, Ukuran: L', 43, 985619.85);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (6, '6-BLUE-M', 'Warna: BLUE, Ukuran: M', 91, 422067.26);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (7, '7-GREY', 'Warna: GREY, Ukuran: M', 86, 545653.42);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (7, '7-GREY-28', 'Warna: GREY, Ukuran: 28', 53, 400896.03);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (8, '8-BLACK-30', 'Warna: BLACK, Ukuran: 30', 4, 601973.17);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (8, '8-BLUE', 'Warna: BLUE, Ukuran: 30', 34, 272714.03);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (8, '8-NAVY-32', 'Warna: NAVY, Ukuran: 32', 22, 640066.41);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (8, '8-RED-M', 'Warna: RED, Ukuran: M', 4, 174843.23);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (8, '8-GREEN', 'Warna: GREEN, Ukuran: M', 80, 167469.27);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (9, '9-BLACK', 'Warna: BLACK, Ukuran: M', 85, 569945.39);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (9, '9-RED-32', 'Warna: RED, Ukuran: 32', 4, 794290.3);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (10, '10-NAVY', 'Warna: NAVY, Ukuran: 32', 45, 196208.53);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (10, '10-BLUE', 'Warna: BLUE, Ukuran: 32', 79, 591630.26);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (11, '11-BLUE', 'Warna: BLUE, Ukuran: 32', 61, 355276.04);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (11, '11-BLACK-28', 'Warna: BLACK, Ukuran: 28', 85, 909346.52);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (11, '11-BLACK-M', 'Warna: BLACK, Ukuran: M', 0, 230445.73);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (12, '12-GREEN', 'Warna: GREEN, Ukuran: M', 81, 282541.25);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (12, '12-GREY', 'Warna: GREY, Ukuran: M', 44, 943954.18);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (12, '12-BLUE-28', 'Warna: BLUE, Ukuran: 28', 69, 275266.2);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (12, '12-NAVY-30', 'Warna: NAVY, Ukuran: 30', 12, 767421.53);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (12, '12-NAVY-28', 'Warna: NAVY, Ukuran: 28', 10, 141287.84);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (13, '13-WHITE-M', 'Warna: WHITE, Ukuran: M', 51, 387294.64);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (13, '13-BLACK-28', 'Warna: BLACK, Ukuran: 28', 40, 250797.56);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (14, '14-BLACK-32', 'Warna: BLACK, Ukuran: 32', 91, 891820.89);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (14, '14-RED-32', 'Warna: RED, Ukuran: 32', 63, 688870.29);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (14, '14-BLACK', 'Warna: BLACK, Ukuran: 32', 29, 197938.33);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (14, '14-RED', 'Warna: RED, Ukuran: 32', 73, 118830.11);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (15, '15-BLACK-32', 'Warna: BLACK, Ukuran: 32', 16, 456274.57);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (15, '15-GREY-L', 'Warna: GREY, Ukuran: L', 27, 579650.71);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (16, '16-RED', 'Warna: RED, Ukuran: L', 16, 976364.94);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (16, '16-GREEN-M', 'Warna: GREEN, Ukuran: M', 41, 596371.01);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (16, '16-NAVY-30', 'Warna: NAVY, Ukuran: 30', 4, 272855.24);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (16, '16-GREEN-L', 'Warna: GREEN, Ukuran: L', 74, 405039.93);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (16, '16-BLUE-30', 'Warna: BLUE, Ukuran: 30', 66, 843486.04);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (17, '17-NAVY', 'Warna: NAVY, Ukuran: 30', 11, 146004.33);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (17, '17-BLACK-S', 'Warna: BLACK, Ukuran: S', 3, 986625.95);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (18, '18-RED-L', 'Warna: RED, Ukuran: L', 2, 458503.9);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (18, '18-GREEN-32', 'Warna: GREEN, Ukuran: 32', 65, 527001.32);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (18, '18-BLUE-M', 'Warna: BLUE, Ukuran: M', 68, 259929.6);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (19, '19-WHITE', 'Warna: WHITE, Ukuran: M', 34, 622186.45);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (19, '19-NAVY-M', 'Warna: NAVY, Ukuran: M', 76, 699572.89);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (19, '19-NAVY-28', 'Warna: NAVY, Ukuran: 28', 15, 708910.78);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (19, '19-NAVY', 'Warna: NAVY, Ukuran: 28', 17, 335588.7);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (19, '19-RED', 'Warna: RED, Ukuran: 28', 82, 531198.27);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (20, '20-GREY-28', 'Warna: GREY, Ukuran: 28', 8, 122896.7);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (20, '20-BLACK', 'Warna: BLACK, Ukuran: 28', 13, 110714.69);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (20, '20-BLUE', 'Warna: BLUE, Ukuran: 28', 91, 100603.7);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (20, '20-BLACK-32', 'Warna: BLACK, Ukuran: 32', 23, 877850.32);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (21, '21-WHITE-28', 'Warna: WHITE, Ukuran: 28', 12, 345826.32);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (21, '21-GREY', 'Warna: GREY, Ukuran: 28', 73, 661801.13);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (22, '22-WHITE', 'Warna: WHITE, Ukuran: 28', 91, 567048.57);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (22, '22-WHITE-32', 'Warna: WHITE, Ukuran: 32', 50, 499460.16);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (22, '22-NAVY', 'Warna: NAVY, Ukuran: 32', 83, 208840.11);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (23, '23-GREY', 'Warna: GREY, Ukuran: 32', 65, 835963.12);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (23, '23-BLACK-32', 'Warna: BLACK, Ukuran: 32', 31, 509232.96);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (23, '23-BLACK-M', 'Warna: BLACK, Ukuran: M', 17, 542364.66);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (24, '24-GREEN', 'Warna: GREEN, Ukuran: M', 37, 322211.9);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (24, '24-WHITE', 'Warna: WHITE, Ukuran: M', 11, 231679.8);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (24, '24-BLACK-32', 'Warna: BLACK, Ukuran: 32', 9, 915503.76);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (25, '25-BLACK-M', 'Warna: BLACK, Ukuran: M', 29, 476581.15);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (25, '25-NAVY', 'Warna: NAVY, Ukuran: M', 46, 865943.65);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (25, '25-GREY-S', 'Warna: GREY, Ukuran: S', 79, 91045.51);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (26, '26-GREY-M', 'Warna: GREY, Ukuran: M', 25, 903335.02);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (26, '26-BLUE-28', 'Warna: BLUE, Ukuran: 28', 42, 563765.5);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (27, '27-GREY-L', 'Warna: GREY, Ukuran: L', 0, 641743.74);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (27, '27-GREEN', 'Warna: GREEN, Ukuran: L', 95, 149092.37);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (28, '28-NAVY', 'Warna: NAVY, Ukuran: L', 39, 931359.53);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (28, '28-BLUE', 'Warna: BLUE, Ukuran: L', 89, 831675.31);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (28, '28-GREY', 'Warna: GREY, Ukuran: L', 44, 467028.03);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (28, '28-RED-M', 'Warna: RED, Ukuran: M', 44, 122900.27);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (29, '29-BLUE-S', 'Warna: BLUE, Ukuran: S', 66, 122494.97);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (29, '29-GREY', 'Warna: GREY, Ukuran: S', 35, 417535.16);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (30, '30-GREEN-28', 'Warna: GREEN, Ukuran: 28', 62, 733053.85);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (30, '30-WHITE', 'Warna: WHITE, Ukuran: 28', 9, 129079.15);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (30, '30-RED', 'Warna: RED, Ukuran: 28', 71, 698351.49);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (31, '31-BLUE-L', 'Warna: BLUE, Ukuran: L', 48, 453957.29);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (31, '31-RED-28', 'Warna: RED, Ukuran: 28', 3, 547719.81);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (32, '32-GREY-L', 'Warna: GREY, Ukuran: L', 95, 124728.05);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (32, '32-GREEN-S', 'Warna: GREEN, Ukuran: S', 46, 90024.61);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (32, '32-NAVY-32', 'Warna: NAVY, Ukuran: 32', 65, 443290.06);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (33, '33-WHITE-S', 'Warna: WHITE, Ukuran: S', 14, 763284.54);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (33, '33-BLACK-M', 'Warna: BLACK, Ukuran: M', 89, 98884.07);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (33, '33-BLACK', 'Warna: BLACK, Ukuran: M', 9, 677759.89);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (33, '33-GREY', 'Warna: GREY, Ukuran: M', 4, 314666.39);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (34, '34-RED', 'Warna: RED, Ukuran: M', 77, 291545.95);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (34, '34-WHITE', 'Warna: WHITE, Ukuran: M', 92, 103389.45);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (34, '34-BLACK-S', 'Warna: BLACK, Ukuran: S', 8, 93609.28);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (35, '35-RED', 'Warna: RED, Ukuran: S', 49, 606467.71);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (35, '35-GREEN', 'Warna: GREEN, Ukuran: S', 27, 659404.46);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (35, '35-NAVY-32', 'Warna: NAVY, Ukuran: 32', 31, 869749.81);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (35, '35-BLACK-M', 'Warna: BLACK, Ukuran: M', 77, 904650.94);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (36, '36-RED-L', 'Warna: RED, Ukuran: L', 72, 229577.07);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (36, '36-BLUE-L', 'Warna: BLUE, Ukuran: L', 86, 753667.85);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (36, '36-NAVY', 'Warna: NAVY, Ukuran: L', 48, 92134.01);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (36, '36-GREEN', 'Warna: GREEN, Ukuran: L', 6, 580356.85);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (36, '36-RED-M', 'Warna: RED, Ukuran: M', 54, 943624.62);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (37, '37-GREY', 'Warna: GREY, Ukuran: M', 77, 983186.74);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (37, '37-GREEN-30', 'Warna: GREEN, Ukuran: 30', 45, 608078.42);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (37, '37-BLACK', 'Warna: BLACK, Ukuran: 30', 67, 282214.01);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (37, '37-GREY-28', 'Warna: GREY, Ukuran: 28', 64, 435989.62);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (38, '38-GREY-M', 'Warna: GREY, Ukuran: M', 89, 539979.77);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (38, '38-NAVY-32', 'Warna: NAVY, Ukuran: 32', 97, 607005.55);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (39, '39-GREEN', 'Warna: GREEN, Ukuran: 32', 18, 571708.9);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (39, '39-BLUE', 'Warna: BLUE, Ukuran: 32', 96, 190707.54);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (39, '39-BLACK', 'Warna: BLACK, Ukuran: 32', 72, 197751.96);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (40, '40-BLUE', 'Warna: BLUE, Ukuran: 32', 17, 518972.5);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (40, '40-BLUE-30', 'Warna: BLUE, Ukuran: 30', 20, 584663.0);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (40, '40-WHITE-M', 'Warna: WHITE, Ukuran: M', 25, 851026.49);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (41, '41-WHITE', 'Warna: WHITE, Ukuran: M', 77, 116517.54);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (41, '41-BLACK', 'Warna: BLACK, Ukuran: M', 67, 990797.92);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (41, '41-BLUE', 'Warna: BLUE, Ukuran: M', 1, 627165.32);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (41, '41-RED', 'Warna: RED, Ukuran: M', 71, 630746.32);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (42, '42-BLACK', 'Warna: BLACK, Ukuran: M', 54, 402072.1);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (42, '42-BLUE', 'Warna: BLUE, Ukuran: M', 87, 503676.6);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (42, '42-RED', 'Warna: RED, Ukuran: M', 54, 835763.44);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (42, '42-NAVY-S', 'Warna: NAVY, Ukuran: S', 95, 247100.65);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (43, '43-WHITE-32', 'Warna: WHITE, Ukuran: 32', 69, 190631.51);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (43, '43-GREEN-30', 'Warna: GREEN, Ukuran: 30', 40, 938001.15);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (44, '44-NAVY-30', 'Warna: NAVY, Ukuran: 30', 8, 491101.62);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (44, '44-BLACK', 'Warna: BLACK, Ukuran: 30', 66, 645409.15);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (44, '44-WHITE-30', 'Warna: WHITE, Ukuran: 30', 97, 409156.22);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (44, '44-GREY', 'Warna: GREY, Ukuran: 30', 11, 997010.5);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (45, '45-NAVY', 'Warna: NAVY, Ukuran: 30', 100, 399306.51);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (45, '45-GREEN', 'Warna: GREEN, Ukuran: 30', 62, 134213.07);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (45, '45-GREEN-32', 'Warna: GREEN, Ukuran: 32', 66, 939901.36);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (45, '45-GREY', 'Warna: GREY, Ukuran: 32', 20, 330514.88);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (46, '46-BLACK', 'Warna: BLACK, Ukuran: 32', 20, 98071.25);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (46, '46-GREEN', 'Warna: GREEN, Ukuran: 32', 66, 353405.03);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (46, '46-BLUE', 'Warna: BLUE, Ukuran: 32', 23, 676852.49);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (47, '47-BLACK', 'Warna: BLACK, Ukuran: 32', 46, 55864.17);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (47, '47-BLUE', 'Warna: BLUE, Ukuran: 32', 86, 858246.65);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (47, '47-WHITE', 'Warna: WHITE, Ukuran: 32', 69, 776147.49);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (48, '48-RED-28', 'Warna: RED, Ukuran: 28', 51, 840313.8);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (48, '48-WHITE-M', 'Warna: WHITE, Ukuran: M', 80, 384180.55);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (49, '49-GREEN', 'Warna: GREEN, Ukuran: M', 18, 282289.84);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (49, '49-NAVY-L', 'Warna: NAVY, Ukuran: L', 35, 790353.41);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (49, '49-BLACK', 'Warna: BLACK, Ukuran: L', 4, 504881.82);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (50, '50-WHITE', 'Warna: WHITE, Ukuran: L', 59, 147372.05);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (50, '50-RED', 'Warna: RED, Ukuran: L', 4, 72441.74);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (50, '50-BLACK', 'Warna: BLACK, Ukuran: L', 69, 683169.41);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (50, '50-WHITE-28', 'Warna: WHITE, Ukuran: 28', 55, 343174.7);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (51, '51-RED-S', 'Warna: RED, Ukuran: S', 94, 58775.85);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (51, '51-NAVY-32', 'Warna: NAVY, Ukuran: 32', 1, 908861.71);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (51, '51-GREEN', 'Warna: GREEN, Ukuran: 32', 28, 137149.77);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (52, '52-NAVY-S', 'Warna: NAVY, Ukuran: S', 50, 588997.12);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (52, '52-GREEN-M', 'Warna: GREEN, Ukuran: M', 44, 545441.43);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (52, '52-GREEN-30', 'Warna: GREEN, Ukuran: 30', 85, 650423.09);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (52, '52-BLACK-30', 'Warna: BLACK, Ukuran: 30', 37, 516626.24);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (53, '53-BLACK-L', 'Warna: BLACK, Ukuran: L', 23, 440724.36);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (53, '53-RED-S', 'Warna: RED, Ukuran: S', 29, 187815.68);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (53, '53-RED', 'Warna: RED, Ukuran: S', 59, 257410.33);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (53, '53-WHITE-32', 'Warna: WHITE, Ukuran: 32', 85, 319330.41);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (53, '53-BLACK-32', 'Warna: BLACK, Ukuran: 32', 18, 360016.85);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (54, '54-GREEN', 'Warna: GREEN, Ukuran: 32', 71, 547856.91);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (54, '54-BLACK', 'Warna: BLACK, Ukuran: 32', 8, 450918.5);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (55, '55-BLUE-L', 'Warna: BLUE, Ukuran: L', 67, 994623.05);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (55, '55-GREEN-L', 'Warna: GREEN, Ukuran: L', 10, 320384.74);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (56, '56-RED-M', 'Warna: RED, Ukuran: M', 61, 675864.81);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (56, '56-GREEN-L', 'Warna: GREEN, Ukuran: L', 74, 532882.46);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (57, '57-BLACK-30', 'Warna: BLACK, Ukuran: 30', 58, 95047.62);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (57, '57-GREY-32', 'Warna: GREY, Ukuran: 32', 81, 328122.78);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (57, '57-GREEN-S', 'Warna: GREEN, Ukuran: S', 40, 375483.99);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (57, '57-BLACK-28', 'Warna: BLACK, Ukuran: 28', 67, 521614.34);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (58, '58-WHITE-M', 'Warna: WHITE, Ukuran: M', 97, 785713.62);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (58, '58-RED', 'Warna: RED, Ukuran: M', 33, 790644.21);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (58, '58-GREEN', 'Warna: GREEN, Ukuran: M', 43, 320027.57);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (59, '59-NAVY', 'Warna: NAVY, Ukuran: M', 32, 98580.48);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (59, '59-WHITE-S', 'Warna: WHITE, Ukuran: S', 89, 558205.14);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (59, '59-BLUE-L', 'Warna: BLUE, Ukuran: L', 19, 959846.85);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (59, '59-RED-28', 'Warna: RED, Ukuran: 28', 76, 144359.99);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (60, '60-BLUE-32', 'Warna: BLUE, Ukuran: 32', 5, 595004.89);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (60, '60-RED', 'Warna: RED, Ukuran: 32', 55, 501990.11);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (61, '61-RED-S', 'Warna: RED, Ukuran: S', 41, 162840.14);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (61, '61-RED', 'Warna: RED, Ukuran: S', 49, 650865.86);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (61, '61-BLACK-28', 'Warna: BLACK, Ukuran: 28', 85, 564770.54);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (61, '61-NAVY', 'Warna: NAVY, Ukuran: 28', 60, 564546.27);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (61, '61-WHITE', 'Warna: WHITE, Ukuran: 28', 97, 746596.65);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (62, '62-RED', 'Warna: RED, Ukuran: 28', 96, 810412.04);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (62, '62-BLACK-L', 'Warna: BLACK, Ukuran: L', 22, 338394.42);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (62, '62-WHITE-30', 'Warna: WHITE, Ukuran: 30', 79, 71801.16);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (62, '62-WHITE', 'Warna: WHITE, Ukuran: 30', 85, 257547.31);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (63, '63-GREEN', 'Warna: GREEN, Ukuran: 30', 89, 245348.17);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (63, '63-GREY', 'Warna: GREY, Ukuran: 30', 66, 292556.0);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (63, '63-BLUE-S', 'Warna: BLUE, Ukuran: S', 53, 580916.29);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (64, '64-GREY-32', 'Warna: GREY, Ukuran: 32', 33, 371417.16);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (64, '64-GREEN', 'Warna: GREEN, Ukuran: 32', 17, 738112.74);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (65, '65-BLACK', 'Warna: BLACK, Ukuran: 32', 35, 254256.93);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (65, '65-BLACK-32', 'Warna: BLACK, Ukuran: 32', 13, 823614.3);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (65, '65-GREY', 'Warna: GREY, Ukuran: 32', 75, 946233.5);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (65, '65-GREEN-M', 'Warna: GREEN, Ukuran: M', 3, 232788.23);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (65, '65-GREY-28', 'Warna: GREY, Ukuran: 28', 2, 996716.77);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (66, '66-BLUE', 'Warna: BLUE, Ukuran: 28', 1, 418157.76);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (66, '66-GREY', 'Warna: GREY, Ukuran: 28', 32, 692054.02);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (67, '67-GREEN-S', 'Warna: GREEN, Ukuran: S', 42, 60086.83);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (67, '67-WHITE', 'Warna: WHITE, Ukuran: S', 51, 527226.35);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (67, '67-RED-30', 'Warna: RED, Ukuran: 30', 77, 450780.61);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (68, '68-RED', 'Warna: RED, Ukuran: 30', 41, 479917.34);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (68, '68-WHITE-30', 'Warna: WHITE, Ukuran: 30', 72, 698309.98);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (68, '68-WHITE', 'Warna: WHITE, Ukuran: 30', 52, 710211.3);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (69, '69-RED', 'Warna: RED, Ukuran: 30', 79, 504497.39);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (69, '69-BLUE-S', 'Warna: BLUE, Ukuran: S', 14, 334532.44);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (70, '70-WHITE-30', 'Warna: WHITE, Ukuran: 30', 38, 406332.78);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (70, '70-BLACK-30', 'Warna: BLACK, Ukuran: 30', 57, 154884.47);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (71, '71-GREY', 'Warna: GREY, Ukuran: 30', 53, 891444.66);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (71, '71-RED-32', 'Warna: RED, Ukuran: 32', 86, 995809.41);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (72, '72-WHITE-32', 'Warna: WHITE, Ukuran: 32', 57, 576528.28);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (72, '72-BLUE-30', 'Warna: BLUE, Ukuran: 30', 44, 819457.59);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (72, '72-RED', 'Warna: RED, Ukuran: 30', 35, 982648.13);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (73, '73-NAVY-M', 'Warna: NAVY, Ukuran: M', 43, 891951.04);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (73, '73-BLUE-30', 'Warna: BLUE, Ukuran: 30', 84, 138464.99);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (73, '73-WHITE', 'Warna: WHITE, Ukuran: 30', 53, 411516.61);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (73, '73-GREY', 'Warna: GREY, Ukuran: 30', 87, 465843.72);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (74, '74-RED', 'Warna: RED, Ukuran: 30', 81, 230824.79);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (74, '74-NAVY', 'Warna: NAVY, Ukuran: 30', 31, 525726.12);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (74, '74-BLACK', 'Warna: BLACK, Ukuran: 30', 76, 803036.82);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (74, '74-NAVY-30', 'Warna: NAVY, Ukuran: 30', 41, 717081.91);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (75, '75-BLACK-28', 'Warna: BLACK, Ukuran: 28', 18, 277118.57);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (75, '75-RED-L', 'Warna: RED, Ukuran: L', 0, 152927.23);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (75, '75-GREY-M', 'Warna: GREY, Ukuran: M', 99, 130060.37);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (76, '76-BLUE-28', 'Warna: BLUE, Ukuran: 28', 12, 225641.92);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (76, '76-WHITE', 'Warna: WHITE, Ukuran: 28', 40, 587658.3);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (76, '76-BLACK', 'Warna: BLACK, Ukuran: 28', 1, 68641.78);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (76, '76-RED', 'Warna: RED, Ukuran: 28', 66, 779055.4);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (77, '77-BLUE-M', 'Warna: BLUE, Ukuran: M', 29, 963215.09);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (77, '77-GREY-32', 'Warna: GREY, Ukuran: 32', 67, 269135.4);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (77, '77-BLUE-30', 'Warna: BLUE, Ukuran: 30', 98, 281241.14);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (77, '77-RED-M', 'Warna: RED, Ukuran: M', 87, 534902.84);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (78, '78-NAVY-28', 'Warna: NAVY, Ukuran: 28', 11, 756498.55);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (78, '78-NAVY', 'Warna: NAVY, Ukuran: 28', 69, 384881.84);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (78, '78-RED', 'Warna: RED, Ukuran: 28', 33, 429520.23);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (78, '78-BLUE-30', 'Warna: BLUE, Ukuran: 30', 3, 918652.28);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (79, '79-GREEN', 'Warna: GREEN, Ukuran: 30', 60, 332760.24);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (79, '79-BLACK-28', 'Warna: BLACK, Ukuran: 28', 21, 358269.42);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (79, '79-WHITE', 'Warna: WHITE, Ukuran: 28', 4, 958430.46);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (79, '79-GREY', 'Warna: GREY, Ukuran: 28', 12, 880856.94);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (80, '80-GREEN', 'Warna: GREEN, Ukuran: 28', 29, 642570.08);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (80, '80-NAVY-30', 'Warna: NAVY, Ukuran: 30', 73, 212205.41);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (80, '80-WHITE-30', 'Warna: WHITE, Ukuran: 30', 37, 849635.17);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (81, '81-RED', 'Warna: RED, Ukuran: 30', 30, 162015.99);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (81, '81-GREEN-32', 'Warna: GREEN, Ukuran: 32', 1, 810724.96);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (81, '81-WHITE-M', 'Warna: WHITE, Ukuran: M', 70, 476269.02);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (82, '82-WHITE-28', 'Warna: WHITE, Ukuran: 28', 58, 534757.4);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (82, '82-GREY-30', 'Warna: GREY, Ukuran: 30', 10, 461722.93);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (82, '82-GREY-L', 'Warna: GREY, Ukuran: L', 13, 929960.55);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (82, '82-GREY', 'Warna: GREY, Ukuran: L', 41, 661818.33);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (83, '83-GREEN', 'Warna: GREEN, Ukuran: L', 12, 515782.11);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (83, '83-GREY-32', 'Warna: GREY, Ukuran: 32', 10, 684330.23);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (83, '83-BLACK', 'Warna: BLACK, Ukuran: 32', 32, 577018.37);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (83, '83-WHITE-S', 'Warna: WHITE, Ukuran: S', 18, 559121.8);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (84, '84-GREEN', 'Warna: GREEN, Ukuran: S', 27, 333130.47);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (84, '84-RED-M', 'Warna: RED, Ukuran: M', 59, 690757.6);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (85, '85-WHITE-30', 'Warna: WHITE, Ukuran: 30', 19, 127058.13);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (85, '85-RED-30', 'Warna: RED, Ukuran: 30', 56, 918774.69);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (85, '85-GREEN-32', 'Warna: GREEN, Ukuran: 32', 10, 658623.73);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (85, '85-GREEN-L', 'Warna: GREEN, Ukuran: L', 45, 78933.49);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (85, '85-NAVY-28', 'Warna: NAVY, Ukuran: 28', 57, 740177.78);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (86, '86-RED', 'Warna: RED, Ukuran: 28', 51, 943747.6);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (86, '86-GREEN-M', 'Warna: GREEN, Ukuran: M', 90, 262831.91);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (87, '87-BLACK', 'Warna: BLACK, Ukuran: M', 88, 437476.23);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (87, '87-WHITE', 'Warna: WHITE, Ukuran: M', 72, 733437.36);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (87, '87-WHITE-S', 'Warna: WHITE, Ukuran: S', 91, 264077.19);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (88, '88-BLACK', 'Warna: BLACK, Ukuran: S', 55, 413138.24);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (88, '88-NAVY', 'Warna: NAVY, Ukuran: S', 10, 442686.97);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (88, '88-GREEN', 'Warna: GREEN, Ukuran: S', 41, 818180.76);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (88, '88-RED-L', 'Warna: RED, Ukuran: L', 1, 90266.61);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (89, '89-BLUE', 'Warna: BLUE, Ukuran: L', 41, 281368.51);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (89, '89-RED-S', 'Warna: RED, Ukuran: S', 71, 359394.85);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (89, '89-NAVY', 'Warna: NAVY, Ukuran: S', 37, 341319.02);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (89, '89-BLUE-S', 'Warna: BLUE, Ukuran: S', 9, 653407.95);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (90, '90-WHITE-28', 'Warna: WHITE, Ukuran: 28', 90, 772295.76);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (90, '90-GREEN', 'Warna: GREEN, Ukuran: 28', 90, 458509.68);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (91, '91-BLACK-30', 'Warna: BLACK, Ukuran: 30', 94, 353003.9);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (91, '91-RED-28', 'Warna: RED, Ukuran: 28', 33, 968833.63);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (91, '91-BLACK', 'Warna: BLACK, Ukuran: 28', 100, 282263.89);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (91, '91-BLACK-S', 'Warna: BLACK, Ukuran: S', 95, 774802.26);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (92, '92-NAVY', 'Warna: NAVY, Ukuran: 28', 2, 435126.97);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (92, '92-GREEN-30', 'Warna: GREEN, Ukuran: 30', 2, 785528.17);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (92, '92-BLUE', 'Warna: BLUE, Ukuran: 30', 83, 634550.0);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (92, '92-BLACK-M', 'Warna: BLACK, Ukuran: M', 38, 803137.81);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (92, '92-WHITE-32', 'Warna: WHITE, Ukuran: 32', 78, 596060.36);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (93, '93-BLACK', 'Warna: BLACK, Ukuran: 32', 58, 815225.66);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (93, '93-NAVY-M', 'Warna: NAVY, Ukuran: M', 51, 846965.0);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (93, '93-BLACK-S', 'Warna: BLACK, Ukuran: S', 30, 707184.11);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (93, '93-WHITE-L', 'Warna: WHITE, Ukuran: L', 66, 140324.39);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (94, '94-GREEN', 'Warna: GREEN, Ukuran: L', 72, 200802.37);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (94, '94-NAVY-28', 'Warna: NAVY, Ukuran: 28', 72, 112069.38);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (95, '95-WHITE', 'Warna: WHITE, Ukuran: 28', 99, 978178.51);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (95, '95-NAVY-M', 'Warna: NAVY, Ukuran: M', 70, 257329.88);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (95, '95-BLACK-28', 'Warna: BLACK, Ukuran: 28', 29, 692288.85);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (96, '96-WHITE', 'Warna: WHITE, Ukuran: 28', 85, 733098.23);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (96, '96-NAVY-M', 'Warna: NAVY, Ukuran: M', 50, 290330.27);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (97, '97-GREY-S', 'Warna: GREY, Ukuran: S', 62, 776538.87);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (97, '97-BLACK-S', 'Warna: BLACK, Ukuran: S', 13, 729587.98);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (97, '97-BLUE', 'Warna: BLUE, Ukuran: S', 26, 460235.64);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (98, '98-GREEN', 'Warna: GREEN, Ukuran: S', 70, 292598.54);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (98, '98-BLUE-28', 'Warna: BLUE, Ukuran: 28', 36, 605682.91);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (98, '98-BLACK-32', 'Warna: BLACK, Ukuran: 32', 2, 356214.35);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (99, '99-RED-M', 'Warna: RED, Ukuran: M', 36, 96051.53);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (99, '99-GREEN', 'Warna: GREEN, Ukuran: M', 58, 620564.36);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (99, '99-GREEN-S', 'Warna: GREEN, Ukuran: S', 59, 110570.41);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (100, '100-GREEN', 'Warna: GREEN, Ukuran: S', 78, 466928.69);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (100, '100-RED-M', 'Warna: RED, Ukuran: M', 40, 124433.15);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (101, '101-NAVY-M', 'Warna: NAVY, Ukuran: M', 67, 360847.65);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (101, '101-WHITE', 'Warna: WHITE, Ukuran: M', 1, 767386.86);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (102, '102-RED-L', 'Warna: RED, Ukuran: L', 21, 986112.15);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (102, '102-GREY-L', 'Warna: GREY, Ukuran: L', 79, 348098.76);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (102, '102-RED', 'Warna: RED, Ukuran: L', 1, 351910.04);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (102, '102-WHITE', 'Warna: WHITE, Ukuran: L', 9, 265149.62);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (102, '102-BLUE-30', 'Warna: BLUE, Ukuran: 30', 13, 689407.08);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (103, '103-GREEN-28', 'Warna: GREEN, Ukuran: 28', 89, 215844.04);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (103, '103-NAVY', 'Warna: NAVY, Ukuran: 28', 19, 805197.37);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (103, '103-BLACK-M', 'Warna: BLACK, Ukuran: M', 13, 273788.49);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (104, '104-NAVY', 'Warna: NAVY, Ukuran: M', 3, 246233.62);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (104, '104-GREEN', 'Warna: GREEN, Ukuran: M', 20, 705397.08);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (105, '105-BLUE', 'Warna: BLUE, Ukuran: M', 94, 691739.88);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (105, '105-NAVY', 'Warna: NAVY, Ukuran: M', 29, 384704.53);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (105, '105-WHITE', 'Warna: WHITE, Ukuran: M', 24, 389758.16);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (105, '105-NAVY-32', 'Warna: NAVY, Ukuran: 32', 98, 284008.41);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (106, '106-GREY', 'Warna: GREY, Ukuran: 32', 56, 759979.64);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (107, '107-NAVY', 'Warna: NAVY, Ukuran: 32', 24, 904498.21);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (107, '107-BLUE', 'Warna: BLUE, Ukuran: 32', 95, 291655.51);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (107, '107-GREY', 'Warna: GREY, Ukuran: 32', 29, 264659.46);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (107, '107-WHITE', 'Warna: WHITE, Ukuran: 32', 0, 183772.43);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (107, '107-WHITE-M', 'Warna: WHITE, Ukuran: M', 68, 693199.05);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (108, '108-GREY-32', 'Warna: GREY, Ukuran: 32', 99, 100242.97);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (108, '108-BLACK', 'Warna: BLACK, Ukuran: 32', 1, 558317.73);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (108, '108-WHITE-M', 'Warna: WHITE, Ukuran: M', 17, 742012.13);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (108, '108-GREY', 'Warna: GREY, Ukuran: M', 35, 446693.53);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (108, '108-WHITE', 'Warna: WHITE, Ukuran: M', 28, 729616.8);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (109, '109-NAVY-S', 'Warna: NAVY, Ukuran: S', 91, 550370.34);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (109, '109-WHITE', 'Warna: WHITE, Ukuran: S', 36, 470264.59);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (109, '109-GREEN-30', 'Warna: GREEN, Ukuran: 30', 74, 426770.34);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (110, '110-GREY-L', 'Warna: GREY, Ukuran: L', 98, 609379.02);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (110, '110-BLUE', 'Warna: BLUE, Ukuran: L', 88, 534292.76);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (110, '110-GREY-M', 'Warna: GREY, Ukuran: M', 13, 493726.72);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (110, '110-NAVY', 'Warna: NAVY, Ukuran: M', 23, 604889.66);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (110, '110-GREY-32', 'Warna: GREY, Ukuran: 32', 58, 620652.61);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (111, '111-WHITE-32', 'Warna: WHITE, Ukuran: 32', 35, 887760.1);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (111, '111-BLACK-28', 'Warna: BLACK, Ukuran: 28', 99, 787540.34);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (111, '111-BLACK', 'Warna: BLACK, Ukuran: 28', 75, 288697.1);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (111, '111-GREY-32', 'Warna: GREY, Ukuran: 32', 88, 190375.06);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (111, '111-GREEN', 'Warna: GREEN, Ukuran: 32', 89, 514644.04);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (112, '112-BLUE-S', 'Warna: BLUE, Ukuran: S', 60, 463616.07);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (112, '112-NAVY', 'Warna: NAVY, Ukuran: S', 70, 106511.68);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (113, '113-BLACK-32', 'Warna: BLACK, Ukuran: 32', 12, 672550.65);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (113, '113-RED', 'Warna: RED, Ukuran: 32', 42, 191303.94);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (113, '113-GREEN', 'Warna: GREEN, Ukuran: 32', 22, 124498.57);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (113, '113-GREY', 'Warna: GREY, Ukuran: 32', 41, 376807.03);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (114, '114-GREEN-L', 'Warna: GREEN, Ukuran: L', 26, 988130.72);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (114, '114-GREY-S', 'Warna: GREY, Ukuran: S', 17, 194838.03);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (115, '115-WHITE-S', 'Warna: WHITE, Ukuran: S', 24, 318007.9);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (115, '115-RED', 'Warna: RED, Ukuran: S', 47, 386304.22);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (115, '115-GREEN-30', 'Warna: GREEN, Ukuran: 30', 66, 81452.84);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (116, '116-GREY', 'Warna: GREY, Ukuran: 30', 17, 646587.03);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (116, '116-NAVY-32', 'Warna: NAVY, Ukuran: 32', 62, 496535.88);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (116, '116-RED-S', 'Warna: RED, Ukuran: S', 77, 430656.59);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (116, '116-BLACK', 'Warna: BLACK, Ukuran: S', 43, 53665.48);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (117, '117-BLUE-30', 'Warna: BLUE, Ukuran: 30', 72, 898365.16);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (117, '117-NAVY-30', 'Warna: NAVY, Ukuran: 30', 71, 757749.82);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (118, '118-WHITE', 'Warna: WHITE, Ukuran: 30', 90, 942635.97);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (118, '118-BLACK', 'Warna: BLACK, Ukuran: 30', 11, 567087.64);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (119, '119-BLUE', 'Warna: BLUE, Ukuran: 30', 37, 469036.52);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (119, '119-WHITE-S', 'Warna: WHITE, Ukuran: S', 27, 93256.52);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (119, '119-BLACK-M', 'Warna: BLACK, Ukuran: M', 8, 367325.37);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (119, '119-GREY', 'Warna: GREY, Ukuran: M', 18, 597547.18);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (120, '120-NAVY-M', 'Warna: NAVY, Ukuran: M', 53, 96442.43);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (120, '120-WHITE', 'Warna: WHITE, Ukuran: M', 14, 55979.57);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (120, '120-BLUE-S', 'Warna: BLUE, Ukuran: S', 85, 443186.13);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (121, '121-GREY', 'Warna: GREY, Ukuran: S', 46, 91606.37);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (121, '121-BLUE', 'Warna: BLUE, Ukuran: S', 69, 492165.86);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (121, '121-BLACK-28', 'Warna: BLACK, Ukuran: 28', 71, 769277.81);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (122, '122-BLACK-28', 'Warna: BLACK, Ukuran: 28', 8, 683864.38);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (122, '122-RED', 'Warna: RED, Ukuran: 28', 88, 850330.98);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (123, '123-NAVY-M', 'Warna: NAVY, Ukuran: M', 30, 996932.25);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (123, '123-RED-L', 'Warna: RED, Ukuran: L', 4, 793446.73);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (124, '124-WHITE-M', 'Warna: WHITE, Ukuran: M', 53, 475844.52);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (124, '124-RED-S', 'Warna: RED, Ukuran: S', 79, 213481.54);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (124, '124-WHITE-30', 'Warna: WHITE, Ukuran: 30', 57, 453630.76);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (124, '124-WHITE-28', 'Warna: WHITE, Ukuran: 28', 32, 616808.04);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (125, '125-GREY-28', 'Warna: GREY, Ukuran: 28', 16, 284897.51);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (125, '125-BLUE', 'Warna: BLUE, Ukuran: 28', 80, 595074.7);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (126, '126-BLUE-L', 'Warna: BLUE, Ukuran: L', 77, 726790.57);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (126, '126-BLUE-S', 'Warna: BLUE, Ukuran: S', 43, 68046.17);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (126, '126-WHITE', 'Warna: WHITE, Ukuran: S', 75, 553917.77);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (126, '126-RED', 'Warna: RED, Ukuran: S', 12, 151279.11);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (126, '126-GREY', 'Warna: GREY, Ukuran: S', 16, 282412.77);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (127, '127-RED', 'Warna: RED, Ukuran: S', 34, 205598.93);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (127, '127-NAVY-32', 'Warna: NAVY, Ukuran: 32', 9, 217026.08);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (127, '127-WHITE-32', 'Warna: WHITE, Ukuran: 32', 50, 446188.99);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (127, '127-BLACK-M', 'Warna: BLACK, Ukuran: M', 12, 715638.47);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (127, '127-GREY-28', 'Warna: GREY, Ukuran: 28', 52, 272805.61);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (128, '128-GREY', 'Warna: GREY, Ukuran: 28', 21, 739085.41);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (128, '128-NAVY', 'Warna: NAVY, Ukuran: 28', 4, 998742.3);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (128, '128-BLUE-M', 'Warna: BLUE, Ukuran: M', 23, 962025.98);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (128, '128-RED-30', 'Warna: RED, Ukuran: 30', 41, 980466.67);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (129, '129-BLACK-32', 'Warna: BLACK, Ukuran: 32', 23, 825361.42);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (129, '129-NAVY-M', 'Warna: NAVY, Ukuran: M', 8, 499381.7);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (129, '129-GREEN-32', 'Warna: GREEN, Ukuran: 32', 39, 477729.02);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (129, '129-RED-L', 'Warna: RED, Ukuran: L', 93, 724070.48);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (130, '130-GREY', 'Warna: GREY, Ukuran: L', 42, 877579.15);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (130, '130-BLUE-S', 'Warna: BLUE, Ukuran: S', 71, 468179.17);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (130, '130-GREEN-L', 'Warna: GREEN, Ukuran: L', 32, 990589.23);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (130, '130-BLACK-M', 'Warna: BLACK, Ukuran: M', 37, 266921.67);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (130, '130-WHITE', 'Warna: WHITE, Ukuran: M', 47, 639248.26);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (131, '131-WHITE', 'Warna: WHITE, Ukuran: M', 27, 410423.89);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (131, '131-GREEN', 'Warna: GREEN, Ukuran: M', 80, 565088.38);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (131, '131-WHITE-M', 'Warna: WHITE, Ukuran: M', 76, 929520.1);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (132, '132-GREY', 'Warna: GREY, Ukuran: M', 72, 938165.17);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (132, '132-WHITE-28', 'Warna: WHITE, Ukuran: 28', 41, 789518.55);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (132, '132-BLUE-L', 'Warna: BLUE, Ukuran: L', 43, 434958.93);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (132, '132-GREEN-M', 'Warna: GREEN, Ukuran: M', 9, 142247.35);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (132, '132-BLUE-32', 'Warna: BLUE, Ukuran: 32', 71, 495645.73);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (133, '133-NAVY', 'Warna: NAVY, Ukuran: 32', 20, 649808.91);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (133, '133-BLUE-32', 'Warna: BLUE, Ukuran: 32', 84, 224902.34);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (133, '133-BLACK', 'Warna: BLACK, Ukuran: 32', 58, 970531.45);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (134, '134-GREY', 'Warna: GREY, Ukuran: 32', 81, 218664.38);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (134, '134-BLUE', 'Warna: BLUE, Ukuran: 32', 54, 669450.56);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (134, '134-GREEN', 'Warna: GREEN, Ukuran: 32', 65, 344670.26);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (135, '135-BLUE', 'Warna: BLUE, Ukuran: 32', 98, 384940.17);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (135, '135-BLUE-28', 'Warna: BLUE, Ukuran: 28', 98, 103301.05);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (136, '136-GREY-L', 'Warna: GREY, Ukuran: L', 39, 553582.4);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (136, '136-NAVY', 'Warna: NAVY, Ukuran: L', 68, 650138.05);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (136, '136-GREEN', 'Warna: GREEN, Ukuran: L', 17, 201137.28);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (136, '136-BLUE-M', 'Warna: BLUE, Ukuran: M', 56, 249684.51);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (137, '137-RED', 'Warna: RED, Ukuran: M', 62, 881499.92);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (137, '137-GREY-M', 'Warna: GREY, Ukuran: M', 80, 826580.17);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (138, '138-NAVY-30', 'Warna: NAVY, Ukuran: 30', 43, 117165.07);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (138, '138-BLACK', 'Warna: BLACK, Ukuran: 30', 16, 223504.51);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (139, '139-NAVY', 'Warna: NAVY, Ukuran: 30', 41, 396726.06);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (139, '139-GREEN', 'Warna: GREEN, Ukuran: 30', 15, 639541.75);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (139, '139-BLUE', 'Warna: BLUE, Ukuran: 30', 81, 835921.69);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (140, '140-GREY', 'Warna: GREY, Ukuran: 30', 58, 274434.42);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (140, '140-WHITE-S', 'Warna: WHITE, Ukuran: S', 47, 367320.38);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (140, '140-GREEN', 'Warna: GREEN, Ukuran: S', 83, 80347.52);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (140, '140-NAVY', 'Warna: NAVY, Ukuran: S', 2, 383074.29);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (141, '141-NAVY', 'Warna: NAVY, Ukuran: S', 3, 347654.35);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (141, '141-WHITE-28', 'Warna: WHITE, Ukuran: 28', 24, 359699.19);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (142, '142-BLUE-32', 'Warna: BLUE, Ukuran: 32', 65, 214064.46);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (142, '142-BLUE-30', 'Warna: BLUE, Ukuran: 30', 94, 878910.12);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (142, '142-NAVY', 'Warna: NAVY, Ukuran: 30', 72, 253519.5);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (143, '143-BLUE-30', 'Warna: BLUE, Ukuran: 30', 60, 787524.48);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (143, '143-WHITE-32', 'Warna: WHITE, Ukuran: 32', 3, 689202.92);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (144, '144-GREEN', 'Warna: GREEN, Ukuran: 32', 92, 714793.32);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (144, '144-WHITE-L', 'Warna: WHITE, Ukuran: L', 4, 159924.62);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (144, '144-WHITE-M', 'Warna: WHITE, Ukuran: M', 84, 388770.94);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (145, '145-GREEN', 'Warna: GREEN, Ukuran: M', 15, 236930.33);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (145, '145-BLACK-M', 'Warna: BLACK, Ukuran: M', 34, 87057.71);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (145, '145-BLACK-L', 'Warna: BLACK, Ukuran: L', 3, 846434.98);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (145, '145-WHITE', 'Warna: WHITE, Ukuran: L', 63, 269998.98);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (146, '146-RED', 'Warna: RED, Ukuran: L', 3, 119646.87);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (146, '146-GREEN', 'Warna: GREEN, Ukuran: L', 33, 135276.74);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (146, '146-GREY-S', 'Warna: GREY, Ukuran: S', 28, 281201.73);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (147, '147-GREY-L', 'Warna: GREY, Ukuran: L', 97, 526761.06);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (147, '147-BLACK-28', 'Warna: BLACK, Ukuran: 28', 83, 83996.24);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (147, '147-BLUE-32', 'Warna: BLUE, Ukuran: 32', 89, 964556.91);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (147, '147-BLACK-30', 'Warna: BLACK, Ukuran: 30', 48, 339357.69);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (147, '147-RED-30', 'Warna: RED, Ukuran: 30', 57, 82159.35);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (148, '148-BLACK-S', 'Warna: BLACK, Ukuran: S', 13, 573898.46);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (148, '148-BLACK', 'Warna: BLACK, Ukuran: S', 45, 613328.04);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (148, '148-GREY-28', 'Warna: GREY, Ukuran: 28', 81, 505578.9);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (149, '149-GREY', 'Warna: GREY, Ukuran: 28', 68, 88642.4);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (149, '149-RED-28', 'Warna: RED, Ukuran: 28', 21, 125310.66);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (149, '149-NAVY', 'Warna: NAVY, Ukuran: 28', 16, 840329.58);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (149, '149-GREY-32', 'Warna: GREY, Ukuran: 32', 19, 214018.98);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (150, '150-BLACK-L', 'Warna: BLACK, Ukuran: L', 29, 734620.05);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (150, '150-GREEN', 'Warna: GREEN, Ukuran: L', 48, 874810.27);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (151, '151-NAVY', 'Warna: NAVY, Ukuran: L', 67, 992315.6);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (151, '151-RED', 'Warna: RED, Ukuran: L', 94, 178010.3);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (151, '151-BLACK', 'Warna: BLACK, Ukuran: L', 98, 709592.67);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (152, '152-RED-32', 'Warna: RED, Ukuran: 32', 74, 730076.97);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (152, '152-NAVY-30', 'Warna: NAVY, Ukuran: 30', 12, 131020.37);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (153, '153-BLACK-M', 'Warna: BLACK, Ukuran: M', 58, 572691.57);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (153, '153-GREY-28', 'Warna: GREY, Ukuran: 28', 6, 497684.24);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (153, '153-GREEN', 'Warna: GREEN, Ukuran: 28', 19, 215414.84);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (153, '153-BLACK-30', 'Warna: BLACK, Ukuran: 30', 10, 730168.42);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (154, '154-RED', 'Warna: RED, Ukuran: 30', 78, 376850.1);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (154, '154-BLACK-28', 'Warna: BLACK, Ukuran: 28', 90, 275323.62);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (155, '155-RED', 'Warna: RED, Ukuran: 28', 31, 922662.37);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (155, '155-BLUE-L', 'Warna: BLUE, Ukuran: L', 24, 992333.15);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (155, '155-GREY-L', 'Warna: GREY, Ukuran: L', 37, 593960.24);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (156, '156-WHITE-L', 'Warna: WHITE, Ukuran: L', 12, 324999.37);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (156, '156-RED', 'Warna: RED, Ukuran: L', 0, 509579.71);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (157, '157-RED', 'Warna: RED, Ukuran: L', 90, 210618.56);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (157, '157-WHITE-32', 'Warna: WHITE, Ukuran: 32', 28, 954994.27);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (157, '157-NAVY', 'Warna: NAVY, Ukuran: 32', 82, 223356.02);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (157, '157-WHITE', 'Warna: WHITE, Ukuran: 32', 80, 774156.92);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (158, '158-GREEN-32', 'Warna: GREEN, Ukuran: 32', 92, 624254.23);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (158, '158-WHITE', 'Warna: WHITE, Ukuran: 32', 85, 503532.17);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (158, '158-NAVY-M', 'Warna: NAVY, Ukuran: M', 52, 656270.24);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (158, '158-BLUE-32', 'Warna: BLUE, Ukuran: 32', 94, 739536.73);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (158, '158-GREEN-S', 'Warna: GREEN, Ukuran: S', 38, 964866.29);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (159, '159-WHITE-M', 'Warna: WHITE, Ukuran: M', 75, 630679.27);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (159, '159-BLUE-M', 'Warna: BLUE, Ukuran: M', 96, 152014.29);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (159, '159-GREY', 'Warna: GREY, Ukuran: M', 63, 737638.02);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (159, '159-RED-S', 'Warna: RED, Ukuran: S', 87, 643581.18);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (159, '159-BLUE-32', 'Warna: BLUE, Ukuran: 32', 40, 197935.13);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (160, '160-WHITE-32', 'Warna: WHITE, Ukuran: 32', 31, 729377.65);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (160, '160-GREEN', 'Warna: GREEN, Ukuran: 32', 88, 562478.18);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (160, '160-WHITE', 'Warna: WHITE, Ukuran: 32', 23, 393644.19);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (160, '160-BLACK', 'Warna: BLACK, Ukuran: 32', 12, 467304.87);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (161, '161-WHITE-L', 'Warna: WHITE, Ukuran: L', 95, 613559.99);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (161, '161-RED', 'Warna: RED, Ukuran: L', 9, 667110.91);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (161, '161-BLUE', 'Warna: BLUE, Ukuran: L', 23, 888318.27);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (161, '161-GREEN-32', 'Warna: GREEN, Ukuran: 32', 5, 459201.19);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (162, '162-NAVY-L', 'Warna: NAVY, Ukuran: L', 30, 760878.32);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (162, '162-WHITE-L', 'Warna: WHITE, Ukuran: L', 53, 227079.33);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (162, '162-RED', 'Warna: RED, Ukuran: L', 57, 342097.41);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (163, '163-BLUE-28', 'Warna: BLUE, Ukuran: 28', 61, 469964.87);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (163, '163-RED-M', 'Warna: RED, Ukuran: M', 15, 198240.12);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (163, '163-WHITE-32', 'Warna: WHITE, Ukuran: 32', 40, 540322.08);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (163, '163-NAVY', 'Warna: NAVY, Ukuran: 32', 69, 413601.67);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (164, '164-NAVY', 'Warna: NAVY, Ukuran: 32', 12, 329736.28);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (164, '164-RED-32', 'Warna: RED, Ukuran: 32', 2, 442246.5);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (164, '164-BLACK-S', 'Warna: BLACK, Ukuran: S', 72, 610203.29);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (165, '165-RED-L', 'Warna: RED, Ukuran: L', 98, 389013.66);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (165, '165-BLUE-28', 'Warna: BLUE, Ukuran: 28', 4, 671170.85);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (165, '165-BLACK-L', 'Warna: BLACK, Ukuran: L', 78, 190226.29);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (165, '165-NAVY', 'Warna: NAVY, Ukuran: L', 50, 715756.55);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (165, '165-BLACK', 'Warna: BLACK, Ukuran: L', 35, 162111.76);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (166, '166-BLACK', 'Warna: BLACK, Ukuran: L', 11, 558572.67);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (166, '166-RED', 'Warna: RED, Ukuran: L', 93, 97363.04);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (167, '167-BLACK', 'Warna: BLACK, Ukuran: L', 19, 839268.04);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (167, '167-BLACK-32', 'Warna: BLACK, Ukuran: 32', 67, 340326.39);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (167, '167-GREEN', 'Warna: GREEN, Ukuran: 32', 83, 189793.45);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (167, '167-RED', 'Warna: RED, Ukuran: 32', 61, 677129.92);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (167, '167-BLUE-30', 'Warna: BLUE, Ukuran: 30', 88, 738003.78);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (168, '168-GREEN-M', 'Warna: GREEN, Ukuran: M', 15, 118141.51);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (168, '168-NAVY-M', 'Warna: NAVY, Ukuran: M', 8, 749879.29);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (168, '168-NAVY', 'Warna: NAVY, Ukuran: M', 38, 879826.36);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (169, '169-GREY-S', 'Warna: GREY, Ukuran: S', 81, 575394.07);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (169, '169-GREEN', 'Warna: GREEN, Ukuran: S', 49, 510546.15);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (169, '169-BLACK-M', 'Warna: BLACK, Ukuran: M', 11, 911157.34);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (170, '170-NAVY-M', 'Warna: NAVY, Ukuran: M', 50, 443929.97);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (170, '170-WHITE', 'Warna: WHITE, Ukuran: M', 7, 123215.58);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (170, '170-GREEN-32', 'Warna: GREEN, Ukuran: 32', 97, 762371.43);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (171, '171-WHITE-S', 'Warna: WHITE, Ukuran: S', 33, 941846.26);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (171, '171-GREEN', 'Warna: GREEN, Ukuran: S', 48, 507793.53);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (171, '171-RED-28', 'Warna: RED, Ukuran: 28', 77, 367296.68);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (171, '171-NAVY', 'Warna: NAVY, Ukuran: 28', 48, 168326.87);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (172, '172-GREY-30', 'Warna: GREY, Ukuran: 30', 13, 826212.8);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (172, '172-GREY-S', 'Warna: GREY, Ukuran: S', 59, 929290.32);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (173, '173-NAVY', 'Warna: NAVY, Ukuran: S', 36, 635113.37);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (173, '173-GREEN', 'Warna: GREEN, Ukuran: S', 84, 62633.73);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (173, '173-GREY', 'Warna: GREY, Ukuran: S', 37, 890454.24);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (174, '174-RED', 'Warna: RED, Ukuran: S', 61, 443053.25);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (174, '174-NAVY', 'Warna: NAVY, Ukuran: S', 18, 361845.55);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (174, '174-GREEN-S', 'Warna: GREEN, Ukuran: S', 60, 505237.67);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (174, '174-BLUE-32', 'Warna: BLUE, Ukuran: 32', 55, 210786.97);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (174, '174-GREEN-L', 'Warna: GREEN, Ukuran: L', 14, 737091.32);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (175, '175-BLACK', 'Warna: BLACK, Ukuran: L', 60, 953268.85);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (175, '175-RED-32', 'Warna: RED, Ukuran: 32', 83, 271183.37);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (176, '176-GREEN-28', 'Warna: GREEN, Ukuran: 28', 48, 919062.17);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (176, '176-GREY-L', 'Warna: GREY, Ukuran: L', 53, 234376.39);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (176, '176-NAVY', 'Warna: NAVY, Ukuran: L', 49, 789446.54);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (176, '176-BLUE', 'Warna: BLUE, Ukuran: L', 22, 294718.62);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (176, '176-GREY', 'Warna: GREY, Ukuran: L', 61, 748332.26);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (177, '177-GREEN-L', 'Warna: GREEN, Ukuran: L', 64, 824546.9);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (177, '177-GREEN', 'Warna: GREEN, Ukuran: L', 67, 55284.55);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (177, '177-RED', 'Warna: RED, Ukuran: L', 92, 726054.67);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (177, '177-BLUE-S', 'Warna: BLUE, Ukuran: S', 36, 343460.36);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (178, '178-BLACK', 'Warna: BLACK, Ukuran: S', 68, 853227.69);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (179, '179-RED-M', 'Warna: RED, Ukuran: M', 3, 362339.22);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (179, '179-GREY-32', 'Warna: GREY, Ukuran: 32', 66, 524574.67);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (180, '180-WHITE-S', 'Warna: WHITE, Ukuran: S', 26, 769906.47);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (180, '180-WHITE-30', 'Warna: WHITE, Ukuran: 30', 23, 331735.27);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (180, '180-NAVY-M', 'Warna: NAVY, Ukuran: M', 83, 906605.57);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (180, '180-NAVY', 'Warna: NAVY, Ukuran: M', 46, 836006.81);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (181, '181-GREY-32', 'Warna: GREY, Ukuran: 32', 43, 886228.27);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (181, '181-GREY-30', 'Warna: GREY, Ukuran: 30', 24, 982900.03);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (181, '181-BLUE-S', 'Warna: BLUE, Ukuran: S', 77, 696102.11);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (182, '182-WHITE-M', 'Warna: WHITE, Ukuran: M', 78, 321913.47);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (182, '182-RED', 'Warna: RED, Ukuran: M', 52, 833939.88);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (182, '182-BLACK', 'Warna: BLACK, Ukuran: M', 90, 752407.88);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (183, '183-GREEN-S', 'Warna: GREEN, Ukuran: S', 89, 862487.42);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (183, '183-NAVY', 'Warna: NAVY, Ukuran: S', 3, 751850.27);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (183, '183-WHITE-30', 'Warna: WHITE, Ukuran: 30', 48, 625924.65);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (183, '183-BLUE-L', 'Warna: BLUE, Ukuran: L', 77, 863888.34);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (184, '184-BLACK-L', 'Warna: BLACK, Ukuran: L', 95, 441572.48);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (184, '184-NAVY', 'Warna: NAVY, Ukuran: L', 19, 167575.5);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (185, '185-NAVY-30', 'Warna: NAVY, Ukuran: 30', 36, 971690.38);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (185, '185-GREY', 'Warna: GREY, Ukuran: 30', 29, 275901.64);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (185, '185-WHITE-32', 'Warna: WHITE, Ukuran: 32', 38, 601171.55);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (185, '185-WHITE', 'Warna: WHITE, Ukuran: 32', 71, 664372.29);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (186, '186-GREEN-30', 'Warna: GREEN, Ukuran: 30', 80, 518503.53);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (186, '186-WHITE', 'Warna: WHITE, Ukuran: 30', 43, 221565.7);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (187, '187-NAVY-L', 'Warna: NAVY, Ukuran: L', 51, 531312.88);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (187, '187-BLACK-32', 'Warna: BLACK, Ukuran: 32', 53, 887826.86);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (188, '188-BLUE', 'Warna: BLUE, Ukuran: 32', 31, 67860.67);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (188, '188-GREEN', 'Warna: GREEN, Ukuran: 32', 18, 166895.8);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (188, '188-WHITE', 'Warna: WHITE, Ukuran: 32', 28, 839375.39);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (188, '188-GREEN-S', 'Warna: GREEN, Ukuran: S', 69, 719928.63);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (189, '189-GREY', 'Warna: GREY, Ukuran: S', 26, 590142.39);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (189, '189-BLACK', 'Warna: BLACK, Ukuran: S', 89, 764801.56);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (190, '190-RED', 'Warna: RED, Ukuran: S', 74, 642737.86);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (190, '190-GREY', 'Warna: GREY, Ukuran: S', 23, 524369.16);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (190, '190-WHITE-M', 'Warna: WHITE, Ukuran: M', 12, 704048.33);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (190, '190-BLACK-30', 'Warna: BLACK, Ukuran: 30', 20, 398840.98);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (191, '191-RED-M', 'Warna: RED, Ukuran: M', 93, 736911.85);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (191, '191-BLACK-28', 'Warna: BLACK, Ukuran: 28', 59, 637463.18);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (191, '191-NAVY-L', 'Warna: NAVY, Ukuran: L', 56, 64085.33);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (191, '191-BLUE-S', 'Warna: BLUE, Ukuran: S', 58, 298434.97);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (192, '192-GREY-M', 'Warna: GREY, Ukuran: M', 34, 796669.8);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (192, '192-GREEN', 'Warna: GREEN, Ukuran: M', 20, 426036.25);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (192, '192-WHITE', 'Warna: WHITE, Ukuran: M', 92, 285880.68);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (192, '192-BLACK-30', 'Warna: BLACK, Ukuran: 30', 93, 768972.19);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (193, '193-NAVY', 'Warna: NAVY, Ukuran: 30', 26, 93058.29);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (193, '193-BLUE-30', 'Warna: BLUE, Ukuran: 30', 58, 294683.93);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (193, '193-GREEN', 'Warna: GREEN, Ukuran: 30', 16, 236372.73);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (193, '193-GREEN-32', 'Warna: GREEN, Ukuran: 32', 100, 742001.11);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (194, '194-BLUE-L', 'Warna: BLUE, Ukuran: L', 56, 452127.62);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (194, '194-GREEN-32', 'Warna: GREEN, Ukuran: 32', 73, 132548.93);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (194, '194-RED', 'Warna: RED, Ukuran: 32', 8, 531009.77);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (194, '194-GREEN-28', 'Warna: GREEN, Ukuran: 28', 10, 460691.73);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (195, '195-RED-28', 'Warna: RED, Ukuran: 28', 87, 961599.04);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (195, '195-BLACK', 'Warna: BLACK, Ukuran: 28', 68, 760240.62);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (195, '195-GREY-S', 'Warna: GREY, Ukuran: S', 31, 703218.77);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (195, '195-RED', 'Warna: RED, Ukuran: S', 2, 147437.49);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (195, '195-BLUE', 'Warna: BLUE, Ukuran: S', 12, 520924.57);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (196, '196-RED-S', 'Warna: RED, Ukuran: S', 41, 708279.07);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (196, '196-GREEN-M', 'Warna: GREEN, Ukuran: M', 4, 248399.64);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (196, '196-BLUE-L', 'Warna: BLUE, Ukuran: L', 52, 661298.86);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (197, '197-NAVY-S', 'Warna: NAVY, Ukuran: S', 75, 856195.77);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (197, '197-WHITE-S', 'Warna: WHITE, Ukuran: S', 80, 856293.48);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (198, '198-GREY', 'Warna: GREY, Ukuran: S', 47, 808741.61);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (198, '198-GREY-M', 'Warna: GREY, Ukuran: M', 49, 87741.03);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (199, '199-WHITE-28', 'Warna: WHITE, Ukuran: 28', 79, 360561.77);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (199, '199-WHITE', 'Warna: WHITE, Ukuran: 28', 70, 458989.67);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (199, '199-GREEN', 'Warna: GREEN, Ukuran: 28', 5, 664850.26);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (200, '200-BLACK', 'Warna: BLACK, Ukuran: 28', 7, 252748.27);
INSERT INTO varian (no_produk, sku, nama_varian, stok, harga)
                         VALUES (200, '200-GREEN-S', 'Warna: GREEN, Ukuran: S', 100, 695594.05);

-- INSERT INTO pesanan
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (1, 'Menunggu Pembayaran', 2205403.55, 'Transfer Bank', NULL, '2024-05-17 16:02:36', 'Same Day', 'jarwadi70@mail.com', 82, 'puji19@gmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (2, 'Menunggu Pembayaran', 3021824.07, 'Transfer Bank', NULL, '2024-11-30 16:02:36', 'Instant Courier', 'patricia49@gmail.com', 63, 'ivan20@gmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (3, 'Menunggu Pembayaran', 1544578.39, 'Kartu Kredit', NULL, '2024-10-10 16:02:36', 'Instant Courier', 'patricia49@gmail.com', 92, 'salman90@protonmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (4, 'Selesai', 898009.1, 'Transfer Bank', 'Odio temporibus architecto sed nam perspiciatis.', '2024-06-30 16:02:36', 'Instant Courier', 'mulyono88@protonmail.com', 98, 'heryanto85@mail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (5, 'Dibatalkan', 2311737.43, 'Kartu Kredit', NULL, '2024-06-07 16:02:36', 'Kurir Standar', 'ciaobella63@protonmail.com', 1, 'budi58@gmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (6, 'Menunggu Pembayaran', 1948028.76, 'COD', NULL, '2024-07-31 16:02:36', 'Instant Courier', 'kusuma42@hotmail.com', 41, 'zulaikha2@outlook.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (7, 'Selesai', 3745840.38, 'E-Wallet', 'Ullam ea at velit labore ipsam.', '2025-03-25 16:02:36', 'Kurir Standar', 'kala24@hotmail.com', 71, 'ivan20@gmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (8, 'Selesai', 244057.41, 'Kartu Kredit', 'Architecto sint explicabo error perspiciatis voluptate incidunt.', '2025-04-09 16:02:36', 'Ambil di Tempat', 'yuni97@gmail.com', 5, 'jamalia36@aol.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (9, 'Menunggu Pembayaran', 4938326.63, 'COD', 'Consectetur dolorem voluptates aspernatur pariatur.', '2024-11-25 16:02:36', 'Same Day', 'maimunah64@yahoo.com', 72, 'iriana68@yahoo.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (10, 'Dikirim', 1962473.68, 'COD', NULL, '2024-12-28 16:02:36', 'Ambil di Tempat', 'dimaz63@outlook.com', 4, 'budi58@gmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (11, 'Diproses', 4072220.38, 'COD', 'Cum quisquam quibusdam sit.', '2024-06-18 16:02:36', 'Kurir Standar', 'elisa62@gmail.com', 6, 'nadia54@gmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (12, 'Menunggu Pembayaran', 4551325.52, 'COD', 'Soluta maiores aliquid quae nisi rerum.', '2024-11-09 16:02:36', 'Instant Courier', 'budi58@gmail.com', 78, 'danuja30@yahoo.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (13, 'Menunggu Pembayaran', 3796035.25, 'COD', NULL, '2024-12-14 16:02:36', 'Same Day', 'nyana52@yahoo.com', 96, 'ivan20@gmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (14, 'Menunggu Pembayaran', 2482175.0, 'COD', NULL, '2024-05-17 16:02:36', 'Instant Courier', 'sakura70@aol.com', 82, 'salman90@protonmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (15, 'Dikirim', 1105445.88, 'Kartu Kredit', 'Ad occaecati sequi ex.', '2024-07-04 16:02:36', 'Ambil di Tempat', 'kala24@hotmail.com', 40, 'sakura70@aol.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (16, 'Dibatalkan', 2762358.84, 'Transfer Bank', 'A ut quisquam omnis vitae magni placeat quo.', '2024-07-19 16:02:36', 'Same Day', 'mahfud5@protonmail.com', 42, 'lulut53@aol.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (17, 'Diproses', 1484800.23, 'COD', NULL, '2025-01-13 16:02:36', 'Instant Courier', 'nyana52@yahoo.com', 31, 'ivan20@gmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (18, 'Diproses', 3957700.82, 'Transfer Bank', 'Optio voluptates corporis quae expedita fuga mollitia animi.', '2024-06-12 16:02:36', 'Instant Courier', 'patricia49@gmail.com', 43, 'zulaikha2@outlook.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (19, 'Selesai', 692855.64, 'Kartu Kredit', NULL, '2024-12-22 16:02:36', 'Instant Courier', 'ciaobella63@protonmail.com', 4, 'zulaikha2@outlook.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (20, 'Dibatalkan', 795939.38, 'Kartu Kredit', 'Delectus at rem ex illo sunt facilis eius.', '2024-08-09 16:02:36', 'Kurir Standar', 'dimaz63@outlook.com', 90, 'puji19@gmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (21, 'Diproses', 3533558.59, 'E-Wallet', 'Debitis dignissimos esse iste repudiandae.', '2024-11-28 16:02:36', 'Instant Courier', 'yuni97@gmail.com', 71, 'danuja30@yahoo.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (22, 'Diproses', 1766996.51, 'Transfer Bank', NULL, '2025-05-13 16:02:36', 'Same Day', 'umay10@aol.com', 86, 'lulut53@aol.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (23, 'Selesai', 4593191.28, 'E-Wallet', 'Officiis laboriosam eligendi voluptates.', '2024-07-26 16:02:36', 'Ambil di Tempat', 'elisa62@gmail.com', 95, 'sakura70@aol.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (24, 'Dibatalkan', 332481.86, 'Transfer Bank', NULL, '2024-12-13 16:02:36', 'Kurir Standar', 'ayu65@hotmail.com', 93, 'puji19@gmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (25, 'Selesai', 4421356.5, 'E-Wallet', 'Tempora ratione inventore eveniet vel.', '2024-12-08 16:02:36', 'Ambil di Tempat', 'eman5@aol.com', 13, 'zulaikha2@outlook.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (26, 'Selesai', 1098298.87, 'E-Wallet', NULL, '2025-02-03 16:02:36', 'Instant Courier', 'oskar15@aol.com', 93, 'perkasa91@outlook.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (27, 'Diproses', 4971334.21, 'Kartu Kredit', NULL, '2024-12-08 16:02:36', 'Same Day', 'jumadi52@gmail.com', 62, 'dimaz63@outlook.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (28, 'Dikirim', 1351965.21, 'E-Wallet', NULL, '2024-07-27 16:02:36', 'Kurir Standar', 'maimunah64@yahoo.com', 16, 'dimaz63@outlook.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (29, 'Dibatalkan', 756179.02, 'E-Wallet', NULL, '2025-03-01 16:02:36', 'Instant Courier', 'ivan42@aol.com', 79, 'nadia54@gmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (30, 'Dikirim', 2984730.35, 'Transfer Bank', 'Debitis incidunt voluptatibus modi numquam esse accusamus iure.', '2024-10-24 16:02:36', 'Same Day', 'cawisadi28@yahoo.com', 75, 'zulaikha2@outlook.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (31, 'Dibatalkan', 4879576.56, 'E-Wallet', 'Ex veritatis ipsum esse quis.', '2024-11-26 16:02:36', 'Instant Courier', 'jarwadi70@mail.com', 46, 'lulut53@aol.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (32, 'Selesai', 4300585.53, 'Kartu Kredit', NULL, '2024-08-17 16:02:36', 'Instant Courier', 'jumadi52@gmail.com', 17, 'zulaikha2@outlook.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (33, 'Dikirim', 3125989.47, 'Transfer Bank', NULL, '2024-12-14 16:02:36', 'Same Day', 'dimaz63@outlook.com', 14, 'umay10@aol.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (34, 'Dibatalkan', 3289460.84, 'Transfer Bank', NULL, '2025-01-23 16:02:36', 'Ambil di Tempat', 'hendri93@yahoo.com', 74, 'perkasa91@outlook.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (35, 'Dikirim', 1915972.91, 'E-Wallet', 'Reiciendis odit quidem velit quas quod repudiandae.', '2024-10-13 16:02:36', 'Ambil di Tempat', 'kusuma42@hotmail.com', 87, 'jamalia36@aol.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (36, 'Menunggu Pembayaran', 1997187.36, 'COD', 'Consequuntur architecto quaerat.', '2025-01-06 16:02:36', 'Ambil di Tempat', 'jaya68@outlook.com', 37, 'harsanto74@mail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (37, 'Dikirim', 969362.5, 'Kartu Kredit', NULL, '2024-09-03 16:02:36', 'Same Day', 'jaya68@outlook.com', 85, 'oskar15@aol.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (38, 'Dibatalkan', 4713423.08, 'Kartu Kredit', NULL, '2025-04-22 16:02:36', 'Instant Courier', 'elisa62@gmail.com', 89, 'oskar15@aol.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (39, 'Dibatalkan', 1087339.21, 'Kartu Kredit', NULL, '2024-09-10 16:02:36', 'Same Day', 'zahra10@mail.com', 90, 'heryanto85@mail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (40, 'Selesai', 3832756.19, 'COD', 'Et quasi aliquid.', '2024-10-20 16:02:36', 'Same Day', 'ciaobella63@protonmail.com', 88, 'nadia54@gmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (41, 'Dikirim', 4450955.03, 'COD', 'Mollitia sapiente corrupti repellendus sunt.', '2024-07-30 16:02:36', 'Same Day', 'maimunah64@yahoo.com', 95, 'dimaz63@outlook.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (42, 'Selesai', 877349.38, 'Transfer Bank', 'Iusto eaque vitae fugiat dicta exercitationem.', '2024-10-16 16:02:36', 'Kurir Standar', 'iriana68@yahoo.com', 38, 'zulaikha2@outlook.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (43, 'Dikirim', 1901327.45, 'Kartu Kredit', NULL, '2024-09-24 16:02:36', 'Kurir Standar', 'jarwadi70@mail.com', 44, 'sakura70@aol.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (44, 'Selesai', 3714770.35, 'Kartu Kredit', 'Omnis repudiandae facere iusto deleniti doloribus.', '2025-01-12 16:02:36', 'Kurir Standar', 'jarwadi70@mail.com', 59, 'iriana68@yahoo.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (45, 'Selesai', 350030.34, 'E-Wallet', NULL, '2024-05-24 16:02:36', 'Ambil di Tempat', 'asmadi11@outlook.com', 56, 'danuja30@yahoo.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (46, 'Dibatalkan', 4949600.5, 'E-Wallet', 'Illo laborum et deleniti incidunt possimus.', '2025-02-18 16:02:36', 'Same Day', 'kusuma42@hotmail.com', 3, 'harsanto74@mail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (47, 'Dikirim', 2624360.61, 'Transfer Bank', 'Cum numquam nisi quasi harum voluptatem molestias.', '2024-10-02 16:02:36', 'Instant Courier', 'perkasa91@outlook.com', 67, 'zulaikha2@outlook.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (48, 'Dibatalkan', 343114.19, 'Kartu Kredit', NULL, '2024-08-30 16:02:36', 'Kurir Standar', 'maria16@outlook.com', 59, 'iriana68@yahoo.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (49, 'Dikirim', 3928792.78, 'Kartu Kredit', 'Quos tenetur illo fugiat voluptatibus omnis excepturi.', '2025-05-14 16:02:36', 'Instant Courier', 'sakura70@aol.com', 31, 'lulut53@aol.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (50, 'Dikirim', 134763.22, 'COD', NULL, '2024-07-01 16:02:36', 'Ambil di Tempat', 'hendri93@yahoo.com', 33, 'oskar15@aol.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (51, 'Selesai', 4973003.53, 'Transfer Bank', NULL, '2024-12-17 16:02:36', 'Ambil di Tempat', 'maimunah64@yahoo.com', 74, 'sakura70@aol.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (52, 'Dibatalkan', 4148589.79, 'E-Wallet', NULL, '2025-01-10 16:02:36', 'Instant Courier', 'patricia49@gmail.com', 1, 'sakura70@aol.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (53, 'Diproses', 1977633.31, 'E-Wallet', NULL, '2024-09-11 16:02:36', 'Kurir Standar', 'ayu65@hotmail.com', 52, 'dimaz63@outlook.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (54, 'Dikirim', 3854832.1, 'Transfer Bank', NULL, '2024-08-17 16:02:36', 'Ambil di Tempat', 'ciaobella63@protonmail.com', 30, 'ivan20@gmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (55, 'Menunggu Pembayaran', 769189.15, 'Kartu Kredit', 'Quae unde rerum tempore minus.', '2024-09-22 16:02:36', 'Same Day', 'jaya68@outlook.com', 90, 'oskar15@aol.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (56, 'Diproses', 3858202.01, 'Transfer Bank', NULL, '2024-10-12 16:02:36', 'Same Day', 'elisa62@gmail.com', 26, 'iriana68@yahoo.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (57, 'Diproses', 4821487.94, 'Transfer Bank', NULL, '2024-07-27 16:02:36', 'Kurir Standar', 'mulyono88@protonmail.com', 43, 'umay10@aol.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (58, 'Selesai', 3713630.64, 'COD', NULL, '2024-09-06 16:02:36', 'Same Day', 'jarwadi70@mail.com', 17, 'harsanto74@mail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (59, 'Diproses', 1147527.59, 'COD', NULL, '2025-03-12 16:02:36', 'Same Day', 'wadi81@hotmail.com', 57, 'perkasa91@outlook.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (60, 'Menunggu Pembayaran', 3090139.76, 'COD', NULL, '2024-12-17 16:02:36', 'Kurir Standar', 'hendri93@yahoo.com', 12, 'umay10@aol.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (61, 'Menunggu Pembayaran', 2701593.82, 'Transfer Bank', 'Reprehenderit consectetur officiis nihil laudantium odio.', '2024-12-28 16:02:36', 'Ambil di Tempat', 'puji19@gmail.com', 75, 'jamalia36@aol.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (62, 'Diproses', 4120839.66, 'COD', NULL, '2025-03-11 16:02:36', 'Ambil di Tempat', 'umay10@aol.com', 55, 'iriana68@yahoo.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (63, 'Selesai', 1477669.32, 'COD', NULL, '2024-09-30 16:02:36', 'Ambil di Tempat', 'legawa24@protonmail.com', 42, 'harsanto74@mail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (64, 'Dikirim', 1765746.75, 'E-Wallet', 'Ea nesciunt aliquam blanditiis ipsa quos.', '2024-05-30 16:02:36', 'Same Day', 'mulyono88@protonmail.com', 10, 'iriana68@yahoo.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (65, 'Diproses', 934890.66, 'Transfer Bank', 'Expedita consequuntur laborum nemo velit tenetur dicta.', '2024-12-07 16:02:36', 'Instant Courier', 'patricia49@gmail.com', 99, 'heryanto85@mail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (66, 'Dikirim', 2599935.83, 'Transfer Bank', NULL, '2024-06-28 16:02:36', 'Kurir Standar', 'irfan87@gmail.com', 81, 'iriana68@yahoo.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (67, 'Dikirim', 2675029.45, 'Kartu Kredit', NULL, '2024-10-31 16:02:36', 'Kurir Standar', 'umay10@aol.com', 48, 'harsanto74@mail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (68, 'Menunggu Pembayaran', 123793.66, 'Kartu Kredit', 'Aut sint sunt quam quod numquam.', '2024-09-07 16:02:36', 'Instant Courier', 'kusuma42@hotmail.com', 90, 'sakura70@aol.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (69, 'Selesai', 4063787.54, 'COD', 'Possimus nihil ad magni.', '2024-07-03 16:02:36', 'Instant Courier', 'nyana52@yahoo.com', 23, 'ivan20@gmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (70, 'Diproses', 2656489.02, 'Transfer Bank', NULL, '2024-08-05 16:02:36', 'Kurir Standar', 'wadi81@hotmail.com', 85, 'umay10@aol.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (71, 'Diproses', 2226770.46, 'E-Wallet', 'Debitis libero repellat laudantium voluptatem dicta.', '2024-09-18 16:02:36', 'Ambil di Tempat', 'umay10@aol.com', 68, 'nadia54@gmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (72, 'Dikirim', 951426.88, 'Transfer Bank', NULL, '2025-03-29 16:02:36', 'Same Day', 'mahfud5@protonmail.com', 87, 'lulut53@aol.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (73, 'Selesai', 413530.02, 'E-Wallet', NULL, '2024-10-21 16:02:36', 'Ambil di Tempat', 'ivan42@aol.com', 15, 'heryanto85@mail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (74, 'Selesai', 4009881.87, 'Kartu Kredit', NULL, '2024-12-23 16:02:36', 'Instant Courier', 'wadi81@hotmail.com', 8, 'salman90@protonmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (75, 'Diproses', 749829.78, 'E-Wallet', 'Veniam similique laborum nihil nostrum.', '2025-02-18 16:02:36', 'Kurir Standar', 'olga77@gmail.com', 10, 'heryanto85@mail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (76, 'Dikirim', 2283599.19, 'Kartu Kredit', 'Dolor voluptates molestias porro dicta aspernatur.', '2025-04-07 16:02:36', 'Ambil di Tempat', 'nyana52@yahoo.com', 91, 'lulut53@aol.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (77, 'Dikirim', 2943771.91, 'COD', 'Assumenda molestias nemo neque at et quo tenetur.', '2025-01-13 16:02:36', 'Same Day', 'iriana68@yahoo.com', 55, 'danuja30@yahoo.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (78, 'Menunggu Pembayaran', 2232882.88, 'COD', 'Nisi modi commodi expedita hic eligendi.', '2025-05-14 16:02:36', 'Kurir Standar', 'jaya68@outlook.com', 11, 'zulaikha2@outlook.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (79, 'Selesai', 1787835.93, 'Kartu Kredit', 'Illum voluptate non inventore exercitationem dignissimos.', '2025-01-18 16:02:36', 'Instant Courier', 'kusuma42@hotmail.com', 89, 'budi58@gmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (80, 'Diproses', 2901935.87, 'E-Wallet', NULL, '2025-02-06 16:02:36', 'Same Day', 'hendri93@yahoo.com', 30, 'lulut53@aol.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (81, 'Dibatalkan', 819189.02, 'COD', NULL, '2024-11-01 16:02:36', 'Kurir Standar', 'ayu65@hotmail.com', 86, 'jamalia36@aol.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (82, 'Diproses', 1986033.08, 'E-Wallet', NULL, '2024-12-16 16:02:36', 'Same Day', 'yani96@mail.com', 82, 'zulaikha2@outlook.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (83, 'Selesai', 1673178.93, 'Kartu Kredit', NULL, '2024-07-17 16:02:36', 'Instant Courier', 'eman5@aol.com', 3, 'jamalia36@aol.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (84, 'Selesai', 2936953.89, 'Transfer Bank', NULL, '2024-06-06 16:02:36', 'Instant Courier', 'iriana68@yahoo.com', 45, 'jamalia36@aol.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (85, 'Dibatalkan', 3519527.31, 'COD', 'Reprehenderit officiis et tempore.', '2024-09-17 16:02:36', 'Same Day', 'mulyono88@protonmail.com', 76, 'umay10@aol.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (86, 'Dibatalkan', 2153851.9, 'Transfer Bank', NULL, '2024-11-18 16:02:36', 'Ambil di Tempat', 'patricia49@gmail.com', 60, 'sakura70@aol.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (87, 'Selesai', 3291665.24, 'E-Wallet', 'Earum ullam similique inventore.', '2024-11-10 16:02:36', 'Ambil di Tempat', 'patricia49@gmail.com', 57, 'sakura70@aol.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (88, 'Diproses', 3470793.27, 'Kartu Kredit', NULL, '2024-07-15 16:02:36', 'Instant Courier', 'elisa62@gmail.com', 81, 'sakura70@aol.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (89, 'Selesai', 1069569.56, 'Transfer Bank', 'Corporis qui fugit totam dolorem.', '2024-07-09 16:02:36', 'Instant Courier', 'ciaobella63@protonmail.com', 80, 'ivan20@gmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (90, 'Dikirim', 2557398.37, 'E-Wallet', NULL, '2024-09-17 16:02:36', 'Ambil di Tempat', 'rahmi63@gmail.com', 7, 'ivan20@gmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (91, 'Menunggu Pembayaran', 2265209.96, 'Transfer Bank', 'Doloribus aperiam laudantium tempore quis consequatur laborum.', '2025-04-18 16:02:36', 'Ambil di Tempat', 'yuni97@gmail.com', 69, 'nadia54@gmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (92, 'Selesai', 1504174.77, 'COD', 'Exercitationem sed maxime.', '2025-04-16 16:02:36', 'Instant Courier', 'ivan42@aol.com', 85, 'iriana68@yahoo.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (93, 'Menunggu Pembayaran', 4575268.45, 'Transfer Bank', NULL, '2025-03-18 16:02:36', 'Same Day', 'patricia49@gmail.com', 25, 'danuja30@yahoo.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (94, 'Dikirim', 4026286.95, 'Kartu Kredit', 'Quis quaerat blanditiis accusamus.', '2025-04-02 16:02:36', 'Ambil di Tempat', 'umay10@aol.com', 74, 'ivan20@gmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (95, 'Diproses', 2907435.94, 'COD', 'Consequuntur voluptatem numquam excepturi non asperiores.', '2024-10-15 16:02:36', 'Same Day', 'irfan87@gmail.com', 82, 'jamalia36@aol.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (96, 'Dibatalkan', 3405557.51, 'E-Wallet', NULL, '2025-04-03 16:02:36', 'Instant Courier', 'patricia49@gmail.com', 16, 'iriana68@yahoo.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (97, 'Selesai', 3168836.56, 'Transfer Bank', NULL, '2024-12-10 16:02:36', 'Ambil di Tempat', 'irfan87@gmail.com', 99, 'ivan20@gmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (98, 'Diproses', 4681185.14, 'COD', NULL, '2024-08-14 16:02:36', 'Instant Courier', 'kala24@hotmail.com', 23, 'salman90@protonmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (99, 'Dikirim', 4979192.86, 'COD', NULL, '2024-10-23 16:02:36', 'Instant Courier', 'yani96@mail.com', 64, 'puji19@gmail.com');
INSERT INTO pesanan (no_pesanan, status_pesanan, harga_total, metode_bayar, catatan, waktu_pesan, metode_kirim, email_pembeli, alamat_id, email_penjual)
                 VALUES (100, 'Menunggu Pembayaran', 544043.19, 'COD', NULL, '2025-01-22 16:02:36', 'Instant Courier', 'oskar15@aol.com', 74, 'oskar15@aol.com');

-- INSERT INTO rincian_pesanan
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (1, 124, '124-WHITE-28', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (1, 31, '31-RED-28', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (2, 138, '138-BLACK', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (3, 133, '133-NAVY', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (3, 106, '106-GREY', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (3, 166, '166-BLACK', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (4, 98, '98-BLACK-32', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (5, 48, '48-RED-28', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (5, 113, '113-GREY', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (5, 64, '64-GREEN', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (6, 22, '22-NAVY', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (7, 2, '2-WHITE-M', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (7, 127, '127-WHITE-32', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (7, 162, '162-RED', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (8, 94, '94-NAVY-28', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (8, 126, '126-RED', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (9, 33, '33-BLACK', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (10, 113, '113-GREEN', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (10, 57, '57-GREY-32', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (11, 184, '184-BLACK-L', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (11, 61, '61-RED', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (12, 40, '40-WHITE-M', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (13, 2, '2-WHITE-M', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (14, 106, '106-GREY', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (15, 179, '179-GREY-32', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (15, 178, '178-BLACK', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (15, 196, '196-GREEN-M', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (16, 29, '29-BLUE-S', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (16, 42, '42-BLACK', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (17, 142, '142-BLUE-32', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (17, 87, '87-WHITE', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (17, 90, '90-WHITE-28', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (18, 12, '12-BLUE-28', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (19, 153, '153-GREEN', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (19, 153, '153-BLACK-M', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (19, 52, '52-GREEN-30', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (20, 10, '10-NAVY', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (21, 121, '121-BLUE', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (21, 128, '128-BLUE-M', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (21, 121, '121-BLACK-28', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (22, 104, '104-GREEN', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (23, 196, '196-RED-S', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (24, 124, '124-WHITE-30', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (24, 93, '93-BLACK', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (24, 34, '34-RED', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (25, 3, '3-BLACK', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (25, 12, '12-GREY', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (26, 192, '192-BLACK-30', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (26, 101, '101-WHITE', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (27, 1, '1-BLACK', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (27, 79, '79-GREEN', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (28, 177, '177-RED', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (28, 79, '79-BLACK-28', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (29, 70, '70-WHITE-30', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (30, 43, '43-GREEN-30', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (31, 123, '123-NAVY-M', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (32, 140, '140-WHITE-S', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (33, 182, '182-BLACK', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (33, 185, '185-NAVY-30', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (33, 25, '25-GREY-S', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (34, 192, '192-WHITE', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (34, 101, '101-NAVY-M', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (34, 109, '109-NAVY-S', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (35, 126, '126-GREY', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (36, 137, '137-GREY-M', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (36, 149, '149-NAVY', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (36, 116, '116-BLACK', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (37, 141, '141-NAVY', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (37, 55, '55-GREEN-L', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (38, 96, '96-WHITE', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (38, 96, '96-NAVY-M', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (38, 65, '65-BLACK-32', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (39, 37, '37-GREY', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (39, 103, '103-GREEN-28', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (40, 68, '68-WHITE-30', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (40, 68, '68-RED', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (40, 197, '197-WHITE-S', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (41, 72, '72-BLUE-30', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (41, 41, '41-RED', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (41, 79, '79-GREY', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (42, 140, '140-GREEN', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (42, 153, '153-GREY-28', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (42, 32, '32-NAVY-32', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (43, 196, '196-GREEN-M', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (43, 175, '175-RED-32', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (44, 122, '122-RED', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (44, 74, '74-NAVY-30', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (45, 27, '27-GREY-L', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (45, 121, '121-BLUE', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (46, 137, '137-RED', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (47, 22, '22-WHITE-32', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (48, 30, '30-GREEN-28', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (49, 29, '29-BLUE-S', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (49, 11, '11-BLACK-M', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (49, 6, '6-BLUE-M', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (50, 80, '80-WHITE-30', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (50, 135, '135-BLUE', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (51, 13, '13-BLACK-28', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (52, 66, '66-BLUE', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (53, 79, '79-GREY', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (53, 44, '44-NAVY-30', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (54, 15, '15-BLACK-32', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (54, 183, '183-WHITE-30', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (55, 147, '147-BLUE-32', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (55, 65, '65-GREY-28', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (56, 74, '74-RED', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (56, 49, '49-GREEN', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (56, 33, '33-GREY', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (57, 200, '200-GREEN-S', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (57, 185, '185-WHITE-32', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (57, 188, '188-WHITE', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (58, 116, '116-GREY', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (58, 137, '137-GREY-M', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (59, 38, '38-GREY-M', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (59, 8, '8-BLACK-30', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (60, 182, '182-BLACK', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (61, 148, '148-BLACK', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (61, 94, '94-GREEN', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (61, 126, '126-WHITE', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (62, 92, '92-BLUE', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (63, 115, '115-GREEN-30', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (64, 49, '49-BLACK', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (64, 69, '69-BLUE-S', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (65, 165, '165-BLACK', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (66, 122, '122-BLACK-28', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (67, 143, '143-WHITE-32', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (67, 137, '137-GREY-M', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (67, 149, '149-RED-28', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (68, 178, '178-BLACK', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (69, 142, '142-BLUE-32', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (70, 114, '114-GREY-S', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (71, 70, '70-WHITE-30', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (71, 68, '68-WHITE-30', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (71, 184, '184-NAVY', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (72, 26, '26-GREY-M', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (72, 26, '26-BLUE-28', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (73, 89, '89-BLUE-S', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (73, 165, '165-BLACK-L', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (74, 20, '20-BLACK', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (74, 194, '194-RED', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (74, 161, '161-BLUE', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (75, 37, '37-GREY-28', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (76, 26, '26-BLUE-28', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (76, 71, '71-GREY', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (76, 181, '181-GREY-30', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (77, 121, '121-BLUE', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (77, 152, '152-NAVY-30', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (78, 52, '52-BLACK-30', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (78, 52, '52-GREEN-M', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (78, 140, '140-GREEN', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (79, 97, '97-GREY-S', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (80, 11, '11-BLUE', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (81, 78, '78-NAVY', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (81, 19, '19-RED', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (82, 169, '169-GREY-S', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (82, 140, '140-GREY', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (83, 19, '19-RED', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (84, 129, '129-BLACK-32', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (85, 188, '188-GREEN-S', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (86, 179, '179-RED-M', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (86, 13, '13-WHITE-M', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (87, 13, '13-BLACK-28', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (88, 179, '179-GREY-32', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (89, 127, '127-WHITE-32', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (89, 127, '127-GREY-28', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (90, 90, '90-GREEN', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (91, 134, '134-GREEN', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (91, 86, '86-RED', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (92, 118, '118-BLACK', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (92, 81, '81-GREEN-32', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (93, 172, '172-GREY-S', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (93, 128, '128-NAVY', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (93, 102, '102-RED', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (94, 67, '67-RED-30', 3);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (95, 129, '129-RED-L', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (95, 19, '19-NAVY-28', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (96, 74, '74-RED', 5);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (97, 142, '142-BLUE-32', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (98, 119, '119-BLUE', 4);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (98, 45, '45-GREEN', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (99, 99, '99-GREEN-S', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (99, 139, '139-NAVY', 2);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (100, 135, '135-BLUE-28', 1);
INSERT INTO rincian_pesanan (no_pesanan, no_produk, sku, jumlah)
                         VALUES (100, 88, '88-RED-L', 4);

-- INSERT INTO ulasan
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('mahfud5@protonmail.com', 46, NULL, 2.7);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('zulaikha2@outlook.com', 11, 'Maiores ab eligendi suscipit. Voluptates rerum fugiat. Earum libero numquam fugiat.', 3.6);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('cawisadi28@yahoo.com', 83, 'In tempore ipsum quibusdam molestiae distinctio. Illum cupiditate doloribus delectus totam. Qui maxime quis fugiat.', 2.2);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('maria16@outlook.com', 75, 'Voluptates quisquam officiis sit. Hic aspernatur consectetur.', 3.5);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('jaya68@outlook.com', 70, NULL, 2.3);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('maria16@outlook.com', 74, NULL, 0.3);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('zahra10@mail.com', 77, 'Accusamus nemo porro minima nostrum aspernatur maiores. Suscipit assumenda labore consectetur explicabo molestiae labore.', 1.6);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('jarwadi70@mail.com', 30, 'Laborum rerum non. Officia aliquam blanditiis ullam labore quos.', 2.3);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('iriana68@yahoo.com', 95, 'Dicta quos quis delectus autem praesentium pariatur. Consequuntur ea totam ab ipsa.', 3.3);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('oskar15@aol.com', 77, 'Eius ipsam voluptatem sit voluptatum inventore perspiciatis.', 4.2);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('cawisadi28@yahoo.com', 80, 'Repudiandae dolorem dolores asperiores a. Assumenda voluptate vero expedita. Dicta adipisci perspiciatis corrupti quidem excepturi. Explicabo quas ex.', 3.8);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('legawa24@protonmail.com', 8, NULL, 2.4);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('mulyono88@protonmail.com', 23, 'At provident voluptatibus veniam commodi similique tempore. Qui quis inventore fugit. Expedita dicta alias porro.', 2.5);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('ivan42@aol.com', 96, NULL, 0.2);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('umay10@aol.com', 50, NULL, 0.4);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('mulyono88@protonmail.com', 24, NULL, 1.9);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('mahfud5@protonmail.com', 87, 'Debitis nobis libero nostrum ullam doloribus. Iste esse ipsa id. Cumque autem pariatur.', 4.7);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('elisa62@gmail.com', 25, 'Reprehenderit temporibus facere voluptate quo corporis.', 4.0);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('dimaz63@outlook.com', 17, NULL, 1.3);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('cawisadi28@yahoo.com', 60, NULL, 3.8);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('olga77@gmail.com', 57, NULL, 0.0);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('cawisadi28@yahoo.com', 57, NULL, 4.6);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('kusuma42@hotmail.com', 21, 'Nesciunt qui delectus iure magni. Repellat error dignissimos sed.', 4.6);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('maria16@outlook.com', 31, 'Velit nam sint ipsum sunt dolore reiciendis eius.', 3.5);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('oskar15@aol.com', 90, NULL, 3.6);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('eman5@aol.com', 13, 'Error tempore nemo laboriosam distinctio esse aspernatur. Dolor vero error vitae officiis. Velit ullam alias sequi eius aperiam eligendi.', 1.2);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('wadi81@hotmail.com', 43, 'Aliquam quibusdam laborum. Consectetur repellat harum quidem vel maiores. Officia voluptas consequatur.', 4.0);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('puji19@gmail.com', 53, NULL, 3.8);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('eman5@aol.com', 40, NULL, 0.2);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('jarwadi70@mail.com', 47, NULL, 2.2);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('ciaobella63@protonmail.com', 26, NULL, 1.2);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('nyana52@yahoo.com', 34, 'Eum quae quas tenetur. Alias unde voluptatem suscipit impedit optio voluptas. Ea totam dignissimos tempore in.', 0.2);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('jumadi52@gmail.com', 34, NULL, 2.5);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('eman5@aol.com', 86, NULL, 5.0);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('yani96@mail.com', 90, 'Minima perspiciatis iure sit esse. Omnis corrupti minus modi maxime.', 4.2);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('nyana52@yahoo.com', 74, NULL, 4.7);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('budi58@gmail.com', 66, NULL, 4.0);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('eman5@aol.com', 57, NULL, 2.0);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('yuni97@gmail.com', 16, 'Earum nulla doloremque optio possimus amet similique. Quo expedita ullam provident sed. Maxime voluptates omnis laudantium quo.', 4.2);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('olga77@gmail.com', 73, 'Tempora tenetur harum doloremque quos. Tempora architecto dolores repellat.', 2.7);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('jaya68@outlook.com', 30, NULL, 4.6);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('zahra10@mail.com', 17, 'Molestias sequi soluta. Excepturi maxime nulla corrupti ullam provident eligendi.', 3.8);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('wadi81@hotmail.com', 45, 'Tenetur incidunt beatae iure assumenda ipsa vitae. Expedita ab aperiam porro. Quidem sequi iste sed optio tempora. Quam eaque quibusdam enim aspernatur voluptates optio reiciendis.', 3.1);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('jarwadi70@mail.com', 32, NULL, 4.9);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('kusuma42@hotmail.com', 20, 'Ut porro blanditiis ea sit. Modi modi est debitis nesciunt numquam praesentium.', 3.0);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('eman5@aol.com', 56, NULL, 1.0);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('ayu65@hotmail.com', 12, 'Vel nemo rerum dolorum. Ipsam tempora aliquid dignissimos alias animi. Animi sit debitis. Laboriosam ratione velit consequuntur qui.', 3.2);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('cawisadi28@yahoo.com', 97, NULL, 3.3);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('ciaobella63@protonmail.com', 81, NULL, 3.2);
INSERT INTO ulasan (email_pembeli, no_pesanan, konten, nilai)
                 VALUES ('iriana68@yahoo.com', 97, 'Corporis quia eum modi aperiam tempora ab.', 4.7);

-- INSERT INTO wishlist
INSERT INTO wishlist (wishlist_id, email_pembeli)
                 VALUES (1, 'ayu65@hotmail.com');
INSERT INTO wishlist (wishlist_id, email_pembeli)
                 VALUES (2, 'yuni97@gmail.com');
INSERT INTO wishlist (wishlist_id, email_pembeli)
                 VALUES (3, 'asmadi11@outlook.com');
INSERT INTO wishlist (wishlist_id, email_pembeli)
                 VALUES (4, 'nyana52@yahoo.com');
INSERT INTO wishlist (wishlist_id, email_pembeli)
                 VALUES (5, 'legawa24@protonmail.com');
INSERT INTO wishlist (wishlist_id, email_pembeli)
                 VALUES (6, 'eman5@aol.com');
INSERT INTO wishlist (wishlist_id, email_pembeli)
                 VALUES (7, 'zahra10@mail.com');
INSERT INTO wishlist (wishlist_id, email_pembeli)
                 VALUES (8, 'kusuma42@hotmail.com');
INSERT INTO wishlist (wishlist_id, email_pembeli)
                 VALUES (9, 'budi58@gmail.com');
INSERT INTO wishlist (wishlist_id, email_pembeli)
                 VALUES (10, 'mulyono88@protonmail.com');
INSERT INTO wishlist (wishlist_id, email_pembeli)
                 VALUES (11, 'wadi81@hotmail.com');
INSERT INTO wishlist (wishlist_id, email_pembeli)
                 VALUES (12, 'jumadi52@gmail.com');
INSERT INTO wishlist (wishlist_id, email_pembeli)
                 VALUES (13, 'maimunah64@yahoo.com');
INSERT INTO wishlist (wishlist_id, email_pembeli)
                 VALUES (14, 'puji19@gmail.com');
INSERT INTO wishlist (wishlist_id, email_pembeli)
                 VALUES (15, 'jaya68@outlook.com');
INSERT INTO wishlist (wishlist_id, email_pembeli)
                 VALUES (16, 'jarwadi70@mail.com');
INSERT INTO wishlist (wishlist_id, email_pembeli)
                 VALUES (17, 'iriana68@yahoo.com');
INSERT INTO wishlist (wishlist_id, email_pembeli)
                 VALUES (18, 'sakura70@aol.com');
INSERT INTO wishlist (wishlist_id, email_pembeli)
                 VALUES (19, 'umay10@aol.com');
INSERT INTO wishlist (wishlist_id, email_pembeli)
                 VALUES (20, 'ivan42@aol.com');
INSERT INTO wishlist (wishlist_id, email_pembeli)
                 VALUES (21, 'olga77@gmail.com');
INSERT INTO wishlist (wishlist_id, email_pembeli)
                 VALUES (22, 'elisa62@gmail.com');
INSERT INTO wishlist (wishlist_id, email_pembeli)
                 VALUES (23, 'dimaz63@outlook.com');
INSERT INTO wishlist (wishlist_id, email_pembeli)
                 VALUES (24, 'oskar15@aol.com');
INSERT INTO wishlist (wishlist_id, email_pembeli)
                 VALUES (25, 'kala24@hotmail.com');
INSERT INTO wishlist (wishlist_id, email_pembeli)
                 VALUES (26, 'zulaikha2@outlook.com');
INSERT INTO wishlist (wishlist_id, email_pembeli)
                 VALUES (27, 'irfan87@gmail.com');
INSERT INTO wishlist (wishlist_id, email_pembeli)
                 VALUES (28, 'patricia49@gmail.com');
INSERT INTO wishlist (wishlist_id, email_pembeli)
                 VALUES (29, 'yani96@mail.com');
INSERT INTO wishlist (wishlist_id, email_pembeli)
                 VALUES (30, 'rahmi63@gmail.com');
INSERT INTO wishlist (wishlist_id, email_pembeli)
                 VALUES (31, 'ciaobella63@protonmail.com');
INSERT INTO wishlist (wishlist_id, email_pembeli)
                 VALUES (32, 'hendri93@yahoo.com');
INSERT INTO wishlist (wishlist_id, email_pembeli)
                 VALUES (33, 'cawisadi28@yahoo.com');
INSERT INTO wishlist (wishlist_id, email_pembeli)
                 VALUES (34, 'mahfud5@protonmail.com');
INSERT INTO wishlist (wishlist_id, email_pembeli)
                 VALUES (35, 'perkasa91@outlook.com');
INSERT INTO wishlist (wishlist_id, email_pembeli)
                 VALUES (36, 'maria16@outlook.com');

-- INSERT INTO keranjang
INSERT INTO keranjang (keranjang_id, email_pembeli)
                 VALUES (1, 'ayu65@hotmail.com');
INSERT INTO keranjang (keranjang_id, email_pembeli)
                 VALUES (2, 'yuni97@gmail.com');
INSERT INTO keranjang (keranjang_id, email_pembeli)
                 VALUES (3, 'asmadi11@outlook.com');
INSERT INTO keranjang (keranjang_id, email_pembeli)
                 VALUES (4, 'nyana52@yahoo.com');
INSERT INTO keranjang (keranjang_id, email_pembeli)
                 VALUES (5, 'legawa24@protonmail.com');
INSERT INTO keranjang (keranjang_id, email_pembeli)
                 VALUES (6, 'eman5@aol.com');
INSERT INTO keranjang (keranjang_id, email_pembeli)
                 VALUES (7, 'zahra10@mail.com');
INSERT INTO keranjang (keranjang_id, email_pembeli)
                 VALUES (8, 'kusuma42@hotmail.com');
INSERT INTO keranjang (keranjang_id, email_pembeli)
                 VALUES (9, 'budi58@gmail.com');
INSERT INTO keranjang (keranjang_id, email_pembeli)
                 VALUES (10, 'mulyono88@protonmail.com');
INSERT INTO keranjang (keranjang_id, email_pembeli)
                 VALUES (11, 'wadi81@hotmail.com');
INSERT INTO keranjang (keranjang_id, email_pembeli)
                 VALUES (12, 'jumadi52@gmail.com');
INSERT INTO keranjang (keranjang_id, email_pembeli)
                 VALUES (13, 'maimunah64@yahoo.com');
INSERT INTO keranjang (keranjang_id, email_pembeli)
                 VALUES (14, 'puji19@gmail.com');
INSERT INTO keranjang (keranjang_id, email_pembeli)
                 VALUES (15, 'jaya68@outlook.com');
INSERT INTO keranjang (keranjang_id, email_pembeli)
                 VALUES (16, 'jarwadi70@mail.com');
INSERT INTO keranjang (keranjang_id, email_pembeli)
                 VALUES (17, 'iriana68@yahoo.com');
INSERT INTO keranjang (keranjang_id, email_pembeli)
                 VALUES (18, 'sakura70@aol.com');
INSERT INTO keranjang (keranjang_id, email_pembeli)
                 VALUES (19, 'umay10@aol.com');
INSERT INTO keranjang (keranjang_id, email_pembeli)
                 VALUES (20, 'ivan42@aol.com');
INSERT INTO keranjang (keranjang_id, email_pembeli)
                 VALUES (21, 'olga77@gmail.com');
INSERT INTO keranjang (keranjang_id, email_pembeli)
                 VALUES (22, 'elisa62@gmail.com');
INSERT INTO keranjang (keranjang_id, email_pembeli)
                 VALUES (23, 'dimaz63@outlook.com');
INSERT INTO keranjang (keranjang_id, email_pembeli)
                 VALUES (24, 'oskar15@aol.com');
INSERT INTO keranjang (keranjang_id, email_pembeli)
                 VALUES (25, 'kala24@hotmail.com');
INSERT INTO keranjang (keranjang_id, email_pembeli)
                 VALUES (26, 'zulaikha2@outlook.com');
INSERT INTO keranjang (keranjang_id, email_pembeli)
                 VALUES (27, 'irfan87@gmail.com');
INSERT INTO keranjang (keranjang_id, email_pembeli)
                 VALUES (28, 'patricia49@gmail.com');
INSERT INTO keranjang (keranjang_id, email_pembeli)
                 VALUES (29, 'yani96@mail.com');
INSERT INTO keranjang (keranjang_id, email_pembeli)
                 VALUES (30, 'rahmi63@gmail.com');
INSERT INTO keranjang (keranjang_id, email_pembeli)
                 VALUES (31, 'ciaobella63@protonmail.com');
INSERT INTO keranjang (keranjang_id, email_pembeli)
                 VALUES (32, 'hendri93@yahoo.com');
INSERT INTO keranjang (keranjang_id, email_pembeli)
                 VALUES (33, 'cawisadi28@yahoo.com');
INSERT INTO keranjang (keranjang_id, email_pembeli)
                 VALUES (34, 'mahfud5@protonmail.com');
INSERT INTO keranjang (keranjang_id, email_pembeli)
                 VALUES (35, 'perkasa91@outlook.com');
INSERT INTO keranjang (keranjang_id, email_pembeli)
                 VALUES (36, 'maria16@outlook.com');

-- INSERT INTO rincian_wishlist
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (1, 105);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (1, 43);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (2, 148);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (2, 24);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (2, 179);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (2, 123);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (2, 27);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (3, 52);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (3, 25);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (3, 21);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (4, 149);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (4, 25);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (5, 146);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (5, 1);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (5, 142);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (5, 20);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (6, 124);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (7, 64);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (7, 150);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (8, 45);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (9, 33);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (9, 55);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (9, 194);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (10, 11);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (11, 155);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (11, 190);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (11, 52);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (12, 145);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (12, 49);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (12, 62);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (12, 29);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (12, 174);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (13, 175);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (13, 138);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (13, 54);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (13, 13);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (14, 127);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (14, 68);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (14, 161);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (14, 189);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (15, 49);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (15, 107);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (15, 1);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (15, 99);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (16, 133);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (17, 24);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (18, 38);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (18, 75);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (19, 139);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (19, 168);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (20, 198);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (21, 21);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (22, 174);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (22, 2);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (23, 170);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (23, 159);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (23, 106);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (23, 112);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (23, 13);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (24, 183);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (24, 119);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (24, 26);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (24, 17);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (24, 8);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (25, 41);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (25, 100);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (25, 31);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (25, 113);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (26, 7);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (26, 103);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (26, 174);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (26, 85);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (27, 175);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (27, 115);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (27, 24);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (27, 60);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (28, 86);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (29, 18);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (29, 99);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (29, 163);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (29, 104);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (30, 188);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (31, 161);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (32, 156);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (33, 48);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (33, 165);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (33, 68);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (33, 69);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (34, 77);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (35, 170);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (35, 198);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (36, 187);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (36, 86);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (36, 46);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (36, 197);
INSERT INTO rincian_wishlist (wishlist_id, no_produk)
                         VALUES (36, 94);

-- INSERT INTO rincian_keranjang
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (1, 45, '45-NAVY');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (1, 75, '75-BLACK-28');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (1, 168, '168-NAVY');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (2, 182, '182-RED');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (2, 7, '7-GREY');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (2, 94, '94-GREEN');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (3, 176, '176-NAVY');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (3, 127, '127-WHITE-32');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (3, 10, '10-NAVY');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (4, 106, '106-GREY');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (4, 165, '165-RED-L');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (5, 189, '189-GREY');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (5, 120, '120-BLUE-S');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (5, 172, '172-GREY-S');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (6, 47, '47-BLACK');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (7, 63, '63-GREEN');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (7, 39, '39-BLUE');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (7, 60, '60-RED');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (8, 25, '25-NAVY');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (8, 193, '193-GREEN-32');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (8, 197, '197-NAVY-S');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (9, 107, '107-NAVY');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (10, 175, '175-RED-32');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (10, 104, '104-NAVY');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (11, 80, '80-NAVY-30');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (11, 94, '94-GREEN');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (12, 131, '131-GREEN');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (12, 115, '115-WHITE-S');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (13, 95, '95-WHITE');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (13, 10, '10-NAVY');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (14, 126, '126-WHITE');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (14, 192, '192-GREY-M');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (15, 76, '76-BLACK');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (16, 77, '77-BLUE-30');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (16, 19, '19-NAVY-28');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (17, 19, '19-NAVY-M');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (17, 38, '38-NAVY-32');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (17, 99, '99-GREEN-S');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (18, 46, '46-BLUE');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (19, 73, '73-NAVY-M');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (20, 161, '161-BLUE');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (20, 75, '75-RED-L');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (20, 10, '10-NAVY');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (21, 71, '71-RED-32');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (21, 108, '108-GREY');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (21, 37, '37-GREEN-30');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (22, 110, '110-GREY-L');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (22, 119, '119-GREY');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (23, 54, '54-BLACK');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (23, 167, '167-BLACK');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (24, 96, '96-WHITE');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (24, 171, '171-NAVY');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (25, 157, '157-WHITE');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (25, 107, '107-WHITE');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (26, 11, '11-BLUE');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (26, 71, '71-GREY');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (27, 93, '93-BLACK-S');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (27, 192, '192-BLACK-30');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (28, 42, '42-NAVY-S');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (28, 1, '1-RED');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (28, 64, '64-GREEN');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (29, 164, '164-RED-32');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (29, 121, '121-BLUE');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (29, 41, '41-BLACK');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (30, 29, '29-GREY');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (30, 181, '181-BLUE-S');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (30, 30, '30-WHITE');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (31, 104, '104-NAVY');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (31, 34, '34-WHITE');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (32, 196, '196-GREEN-M');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (33, 32, '32-GREEN-S');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (33, 44, '44-BLACK');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (34, 85, '85-NAVY-28');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (34, 142, '142-BLUE-32');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (34, 177, '177-GREEN-L');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (35, 56, '56-GREEN-L');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (35, 82, '82-WHITE-28');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (35, 144, '144-WHITE-M');
INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku)
                         VALUES (36, 179, '179-GREY-32');