CREATE TABLE alamat (
    alamat_id INT(11) NOT NULL AUTO_INCREMENT,
    provinsi VARCHAR(50) NOT NULL,
    kota VARCHAR(50) NOT NULL,
    jalan VARCHAR(50) NOT NULL,
    PRIMARY KEY (alamat_id)
);

CREATE TABLE alamat_alternatif (
    email VARCHAR(100) NOT NULL,
    alamat_id INT(11) NOT NULL,
    FOREIGN KEY(email) REFERENCES pembeli(email), FOREIGN KEY(alamat_id) REFERENCES alamat(alamat_id)  
);

CREATE TABLE pesanan (
    no_pesanan INT(11) NOT NULL AUTO_INCREMENT,
    status_pesanan VARCHAR(50) NOT NULL,
    harga_total DECIMAL(10,2) NOT NULL,
    metode_bayar VARCHAR(50) NOT NULL,
    catatan VARCHAR(200) DEFAULT NULL,
    waktu_pesan DATETIME NOT NULL,
    metode_kirim VARCHAR(50) NOT NULL,
    email_pembeli VARCHAR(100) NOT NULL,
    alamat_id INT(11) NOT NULL,
    rincian_id INT(11) NOT NULL UNIQUE,
    email_penjual VARCHAR(50) NOT NULL,
    PRIMARY KEY(no_pesanan), 
    FOREIGN KEY(email_pembeli) REFERENCES pembeli(email),
    FOREIGN KEY(alamat_id) REFERENCES alamat(alamat_id),
    FOREIGN KEY(rincian_id) REFERENCES rincian_pesanan(rincian_id),
    FOREIGN KEY(email_penjual) REFERENCES penjual(email)
);

CREATE TABLE ulasan (
    email_pembeli VARCHAR(100) NOT NULL,
    no_pesanan INT(11) NOT NULL,
    ulasan_id INT(11) NOT NULL,
    konten TEXT DEFAULT NULL,
    nilai DECIMAL(1,1) NOT NULL,
    PRIMARY KEY(email_pembeli, no_pesanan, ulasan_id),
    FOREIGN KEY(email_pembeli) REFERENCES pembeli(email),
    FOREIGN KEY(no_pesanan) REFERENCES pesanan(no_pesanan)
);

CREATE TABLE rincian_pesanan (
    rincian_id INT(11) NOT NULL,
    no_produk INT(11) NOT NULL,
    sku INT(11) NOT NULL,
    jumlah INT(11) NOT NULL,
    PRIMARY KEY(rincian_id, no_produk sku),
    FOREIGN KEY(no_produk, sku) REFERENCES varian(no_produk, sku)
);