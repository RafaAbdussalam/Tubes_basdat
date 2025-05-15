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
    no_pesanan INT NOT NULL,
    no_produk INT NOT NULL,
    sku INT NOT NULL,
    jumlah INT NOT NULL,
    PRIMARY KEY(no_pesanan, no_produk, sku),
    FOREIGN KEY(no_pesanan) REFERENCES pesanan(no_pesanan),
    FOREIGN KEY(no_produk, sku) REFERENCES varian(no_produk, sku)
);

-- TRIGGER (tidak boleh delete rincian pesanan terakhir kalau pesanan masihh ada)
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
        SET MESSAGE_TEXT = 'Tidak bisa menghapus rincian terakhir dari pesanan (melanggar total participation)';
    END IF;
END//
DELIMITER ;
