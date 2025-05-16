-- Tujuan/Insight Query:

-- Query ini bertujuan untuk mengidentifikasi pelanggan paling loyal dan berharga berdasarkan kombinasi beberapa faktor:

-- Total Nilai Pesanan Tertinggi: Pelanggan yang secara historis menghabiskan paling banyak.
-- Frekuensi Pesanan Tertinggi: Pelanggan yang paling sering melakukan pesanan.
-- Pelanggan yang Memberikan Ulasan Positif: Pelanggan yang tidak hanya membeli tetapi juga memberikan feedback positif (nilai ulasan >= 4).

SELECT p.email, pg.nama_panjang, SUM(ps.harga_total) AS total_nilai_pembelian
FROM pengguna pg
    JOIN pembeli p ON pg.email = p.email
    JOIN pesanan ps ON p.email = ps.email_pembeli
    JOIN (
        (SELECT p_sub.email_pembeli
        FROM pesanan p_sub
        GROUP BY p_sub.email_pembeli
        ORDER BY SUM(p_sub.harga_total) DESC
        LIMIT 10)

        UNION

        (SELECT p_sub.email_pembeli
        FROM pesanan p_sub
        GROUP BY p_sub.email_pembeli
        ORDER BY COUNT(p_sub.no_pesanan) DESC
        LIMIT 10)

        UNION

        (SELECT u.email_pembeli
        FROM ulasan u
            JOIN pesanan ps_ulasan ON u.no_pesanan = ps_ulasan.no_pesanan
            JOIN pembeli pb_ulasan ON u.email_pembeli = pb_ulasan.email
        WHERE u.nilai >= 4.0
        GROUP BY u.email_pembeli
        HAVING COUNT(u.no_pesanan) > 1)
    ) AS eligible_customers ON p.email = eligible_customers.email_pembeli
GROUP BY p.email, pg.nama_panjang
ORDER BY total_nilai_pembelian DESC;