from faker import Faker
import random

fake = Faker()

# Data pembeli dan produk yang sudah valid
email_pembeli_list = [
    'oskar64@aol.com', 'argono11@aol.com', 'jindra4@protonmail.com', 'tantri37@outlook.com',
    'rini38@outlook.com', 'bakidin22@hotmail.com', 'asirwada33@aol.com', 'jaiman22@mail.com',
    'ajiono27@mail.com', 'maria7@hotmail.com', 'jarwi97@mail.com', 'harimurti20@yahoo.com',
    'unjani96@hotmail.com', 'jagapati36@gmail.com', 'halim35@protonmail.com'
]

produk_list = list(range(1, 11))  # no_produk dari 1 hingga 10

# SKU yang valid berdasarkan VARIAN (subset untuk efisiensi contoh)
sku_list = [
    ('1', '1-BLUE-S'), ('1', '1-BLUE-M'), ('1', '1-BLUE-L'),
    ('2', '2-BLACK-28'), ('2', '2-NAVY-30'),
    ('3', '3-WHITE-41'),
    ('4', '4-NAVY'),
    ('5', '5-GOLD')
]

wishlist_inserts = []
keranjang_inserts = []
rincian_wishlist_inserts = []
rincian_keranjang_inserts = []

#  index untuk ID otomatis
for i, email in enumerate(email_pembeli_list, start=1):
    wishlist_id = i
    keranjang_id = i

    wishlist_inserts.append(f"({wishlist_id}, '{email}')")
    keranjang_inserts.append(f"({keranjang_id}, '{email}')")

    # Generate 1–3 produk unik untuk wishlist
    wishlist_produk = random.sample(produk_list, k=random.randint(1, 3))
    for p in wishlist_produk:
        rincian_wishlist_inserts.append(f"({wishlist_id}, {p})")

    # Generate 1–3 varian unik untuk keranjang
    keranjang_varian = random.sample(sku_list, k=random.randint(1, 3))
    for no_produk, sku in keranjang_varian:
        rincian_keranjang_inserts.append(f"({keranjang_id}, {no_produk}, '{sku}')")

# Print hasil
print("-- WISHLIST")
print("INSERT INTO wishlist (wishlist_id, email_pembeli) VALUES")
print(", \n".join(wishlist_inserts))

print("\n-- KERANJANG")
print("INSERT INTO keranjang (keranjang_id, email_pembeli) VALUES")
print(", \n".join(keranjang_inserts))

print("\n-- RINCIAN_WISHLIST")
print("INSERT INTO rincian_wishlist (wishlist_id, no_produk) VALUES")
print(", \n".join(rincian_wishlist_inserts))

print("\n-- RINCIAN_KERANJANG")
print("INSERT INTO rincian_keranjang (keranjang_id, no_produk, sku) VALUES")
print(", \n".join(rincian_keranjang_inserts))
