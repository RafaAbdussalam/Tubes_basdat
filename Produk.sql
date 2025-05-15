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