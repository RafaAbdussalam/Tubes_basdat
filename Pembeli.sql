CREATE TABLE pembeli (
    email VARCHAR(50) NOT NULL,
    alamat_utama_id INT NOT NULL,
    PRIMARY KEY (email),
    FOREIGN KEY (email) REFERENCES pengguna(email) ON DELETE CASCADE,
    FOREIGN KEY (alamat_utama_id) REFERENCES alamat(alamat_id)
);

INSERT INTO pembeli (email, alamat_utama_id)
             VALUES ('oskar64@aol.com', 15);
INSERT INTO pembeli (email, alamat_utama_id)
             VALUES ('argono11@aol.com', 12);
INSERT INTO pembeli (email, alamat_utama_id)
             VALUES ('jindra4@protonmail.com', 1);
INSERT INTO pembeli (email, alamat_utama_id)
             VALUES ('tantri37@outlook.com', 20);
INSERT INTO pembeli (email, alamat_utama_id)
             VALUES ('rini38@outlook.com', 8);
INSERT INTO pembeli (email, alamat_utama_id)
             VALUES ('bakidin22@hotmail.com', 5);
INSERT INTO pembeli (email, alamat_utama_id)
             VALUES ('asirwada33@aol.com', 3);
INSERT INTO pembeli (email, alamat_utama_id)
             VALUES ('jaiman22@mail.com', 18);
INSERT INTO pembeli (email, alamat_utama_id)
             VALUES ('ajiono27@mail.com', 22);
INSERT INTO pembeli (email, alamat_utama_id)
             VALUES ('maria7@hotmail.com', 2);
INSERT INTO pembeli (email, alamat_utama_id)
             VALUES ('jarwi97@mail.com', 4);
INSERT INTO pembeli (email, alamat_utama_id)
             VALUES ('harimurti20@yahoo.com', 13);
INSERT INTO pembeli (email, alamat_utama_id)
             VALUES ('halim35@protonmail.com', 17);
INSERT INTO pembeli (email, alamat_utama_id)
             VALUES ('unjani96@hotmail.com', 21);
INSERT INTO pembeli (email, alamat_utama_id)
             VALUES ('jagapati36@gmail.com', 9);

