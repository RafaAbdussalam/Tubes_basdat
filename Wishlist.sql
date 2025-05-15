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
