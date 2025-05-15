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

INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
             VALUES ('oskar64@aol.com', 'oskd3%4qJj', 'Oskar Pertiwi', '+62-527-118-537', '2003-06-29', NULL, True, False);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
             VALUES ('argono11@aol.com', 'arg9-adbb_', 'Argono Nurdiyanti', '+62-015-017-362', '1973-01-29', NULL, True, True);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
             VALUES ('jindra4@protonmail.com', 'jinm+Tzz7&', 'Jindra Hassanah', '+62-243-379-819', '2000-12-15', NULL, True, True);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
             VALUES ('jane49@protonmail.com', 'jant$1%F@c', 'Jane Rahimah', '+62-259-350-649', '1974-06-21', NULL, False, True);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
             VALUES ('dono72@gmail.com', 'donjmG^NuH', 'Dono Puspasari', '+62-793-255-250', '1984-10-02', NULL, False, True);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
             VALUES ('tantri37@outlook.com', 'tan5h5HPpN', 'Tantri Wahyuni', '+62-130-508-252', '1982-09-23', NULL, True, True);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
             VALUES ('rini38@outlook.com', 'rins^V^Iyw', 'Rini Hariyah', '+62-843-898-446', '1974-11-22', NULL, True, False);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
             VALUES ('bakidin22@hotmail.com', 'bakXB%!Jr%', 'Bakidin Siregar', '+62-761-390-963', '1981-05-03', NULL, True, True);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
             VALUES ('asirwada33@aol.com', 'asiACWE7wH', 'Asirwada Farida', '+62-723-744-422', '1957-12-09', NULL, True, False);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
             VALUES ('jaiman22@mail.com', 'jaix8w-u7A', 'Jaiman Maheswara', '+62-454-467-458', '2009-07-02', NULL, True, True);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
             VALUES ('ajiono27@mail.com', 'ajieyj7B_&', 'Ajiono Wijayanti', '+62-606-937-971', '1998-12-27', NULL, True, True);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
             VALUES ('maria7@hotmail.com', 'marqye&zG0', 'Maria Prasasta', '+62-597-712-575', '1948-08-22', NULL, True, True);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
             VALUES ('jarwi97@mail.com', 'jar--@@hVu', 'Jarwi Kusumo', '+62-457-350-036', '1986-06-22', NULL, True, True);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
             VALUES ('adinata11@gmail.com', 'adit&63*9c', 'Adinata Simbolon', '+62-644-762-003', '1986-11-09', NULL, False, True);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
             VALUES ('harimurti20@yahoo.com', 'har654LQX9', 'Harimurti Nashiruddin', '+62-458-455-391', '1977-11-07', NULL, True, True);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
             VALUES ('luwes56@gmail.com', 'luwn7xh*zH', 'Luwes Winarno', '+62-060-938-860', '1999-03-17', NULL, False, True);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
             VALUES ('halim35@protonmail.com', 'hal8ZNz0Py', 'Halim Pertiwi', '+62-539-194-413', '1973-04-01', NULL, True, False);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
             VALUES ('unjani96@hotmail.com', 'unj6kvoc@Q', 'Unjani Yuniar', '+62-413-113-161', '2002-05-24', NULL, True, True);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
             VALUES ('jagapati36@gmail.com', 'jagW*pQyQu', 'Jagapati Laksmiwati', '+62-508-905-549', '1999-05-09', NULL, True, True);
INSERT INTO pengguna (email, kata_sandi, nama_panjang, no_telp, tgl_lahir, foto_profil, is_pembeli, is_penjual)
             VALUES ('anastasia68@outlook.com', 'anadAs!v8a', 'Anastasia Mahendra', '+62-988-870-238', '1983-07-15', NULL, False, True);

Select * FROM pengguna;