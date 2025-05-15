CREATE TABLE pengguna (
    email VARCHAR(100) NOT NULL,
    kata_sandi VARCHAR(100) NOT NULL,
    nama_panjang VARCHAR(100) NOT NULL,
    no_telp VARCHAR(50),
    tgl_lahir DATE NOT NULL,
    foto_profil VARCHAR(255),
    is_pembeli BOOLEAN DEFAULT FALSE,
    is_penjual BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (email)
);

CREATE TABLE friend (
    email VARCHAR(100),
    email_following VARCHAR(100),
    PRIMARY KEY (email, email_following),
    FOREIGN KEY (email) REFERENCES pengguna(email),
    FOREIGN KEY (email_following) REFERENCES pengguna(email)
);

CREATE TABLE pembeli (
    email VARCHAR(100) NOT NULL,
    alamat_utama_id INT,
    PRIMARY KEY (email),
    FOREIGN KEY (email) REFERENCES pengguna(email),
    FOREIGN KEY (alamat_utama_id) REFERENCES alamat(alamat_id)
);

CREATE TABLE penjual (
    email VARCHAR(100) NOT NULL,
    foto_ktp VARCHAR(255),
    foto_diri VARCHAR(255),
    is_verified BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (email),
    FOREIGN KEY (email) REFERENCES pengguna(email)
);


-- ================================

CREATE TABLE alamat (
    alamat_id INT NOT NULL AUTO_INCREMENT,
    provinsi VARCHAR(50) NOT NULL,
    kota VARCHAR(50) NOT NULL,
    jalan VARCHAR(50) NOT NULL,
    PRIMARY KEY (alamat_id)
);

CREATE TABLE alamat_alternatif (
    email VARCHAR(100) NOT NULL,
    alamat_id INT NOT NULL,
    FOREIGN KEY(email) REFERENCES pembeli(email), 
    FOREIGN KEY(alamat_id) REFERENCES alamat(alamat_id)  
);

CREATE TABLE pesanan (
    no_pesanan INT NOT NULL AUTO_INCREMENT,
    status_pesanan VARCHAR(50) NOT NULL,
    harga_total DECIMAL(10,2) NOT NULL,
    metode_bayar VARCHAR(50) NOT NULL,
    catatan VARCHAR(200) DEFAULT NULL,
    waktu_pesan DATETIME NOT NULL,
    metode_kirim VARCHAR(50) NOT NULL,
    email_pembeli VARCHAR(100) NOT NULL,
    alamat_id INT NOT NULL,
    rincian_id INT NOT NULL UNIQUE,
    email_penjual VARCHAR(50) NOT NULL,
    PRIMARY KEY(no_pesanan), 
    FOREIGN KEY(email_pembeli) REFERENCES pembeli(email),
    FOREIGN KEY(alamat_id) REFERENCES alamat(alamat_id),
    FOREIGN KEY(rincian_id) REFERENCES rincian_pesanan(rincian_id),
    FOREIGN KEY(email_penjual) REFERENCES penjual(email)
);

CREATE TABLE ulasan (
    email_pembeli VARCHAR(100) NOT NULL,
    no_pesanan INT NOT NULL,
    ulasan_id INT NOT NULL,
    konten TEXT DEFAULT NULL,
    nilai DECIMAL(1,1) NOT NULL,
    PRIMARY KEY(email_pembeli, no_pesanan, ulasan_id),
    FOREIGN KEY(email_pembeli) REFERENCES pembeli(email),
    FOREIGN KEY(no_pesanan) REFERENCES pesanan(no_pesanan)
);

CREATE TABLE rincian_pesanan (
    rincian_id INT NOT NULL,
    no_produk INT NOT NULL,
    sku INT NOT NULL,
    jumlah INT NOT NULL,
    PRIMARY KEY(rincian_id, no_produk sku),
    FOREIGN KEY(no_produk, sku) REFERENCES varian(no_produk, sku)
);


-- TRIGGER (memastikan specialization sesuai)
DELIMITER //
CREATE TRIGGER trg_set_is_pembeli
    BEFORE INSERT ON pembeli
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
    BEFORE INSERT ON penjual
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