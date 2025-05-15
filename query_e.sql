# Tujuan Query & Insight
## Pertanyaan yang dijawab:
Siapa saja penjual yang memiliki rata-rata nilai ulasan lebih tinggi dari rata-rata semua penjual yang memiliki setidaknya 5 produk terjual, 
atau memiliki produk yang masuk ke dalam keranjang pembeli lebih dari 100 kali, beserta jumlah produk aktif mereka?

## Insight yang diambil:
Menemukan penjual berkualitas tinggi baik dari sisi reputasi (ulasan) maupun minat pasar (keranjang).
Dapat digunakan oleh admin untuk:
1. Highlight penjual terbaik.
2. Mempromosikan penjual di halaman utama.
3. Memberikan badge 'Top Seller'.

-- Penjual dengan rata-rata ulasan di atas rata-rata global dari penjual aktif
SELECT 
    p.email,
    pg.nama_panjang,
    COUNT(DISTINCT pr.no_produk) AS jumlah_produk_aktif,
    AVG(u.nilai) AS rata_rata_ulasan
FROM penjual p
JOIN pengguna pg ON p.email = pg.email
JOIN produk pr ON pr.email_penjual = p.email
JOIN pesanan ps ON ps.email_penjual = p.email AND ps.no_pesanan IN (
    SELECT no_pesanan FROM ulasan
)
JOIN ulasan u ON u.no_pesanan = ps.no_pesanan AND u.email_pembeli = ps.email_pembeli
GROUP BY p.email, pg.nama_panjang
HAVING 
    COUNT(DISTINCT pr.no_produk) >= 1 AND
    AVG(u.nilai) > (
        -- Subquery untuk menghitung rata-rata global penjual yang sudah menjual minimal 5 produk
        SELECT AVG(nilai)
        FROM (
            SELECT AVG(u2.nilai) AS nilai
            FROM penjual p2
            JOIN produk pr2 ON pr2.email_penjual = p2.email
            JOIN rincian_pesanan rp2 ON rp2.no_produk = pr2.no_produk
            JOIN pesanan ps2 ON ps2.no_pesanan = rp2.no_pesanan AND ps2.email_penjual = p2.email
            JOIN ulasan u2 ON u2.no_pesanan = ps2.no_pesanan AND u2.email_pembeli = ps2.email_pembeli
            GROUP BY p2.email
            HAVING COUNT(DISTINCT rp2.no_produk) >= 5
        ) AS sub_rata_rata_penjual
    )

UNION

-- Penjual dengan produk yang pernah masuk keranjang lebih dari 100 kali
SELECT 
    p.email,
    pg.nama_panjang,
    COUNT(DISTINCT pr.no_produk) AS jumlah_produk_aktif,
    NULL AS rata_rata_ulasan
FROM penjual p
JOIN pengguna pg ON p.email = pg.email
JOIN produk pr ON pr.email_penjual = p.email
JOIN varian v ON v.no_produk = pr.no_produk
JOIN rincian_keranjang rk ON rk.no_produk = v.no_produk AND rk.sku = v.sku
GROUP BY p.email, pg.nama_panjang
HAVING SUM(rk.jumlah) > 100;
