🚀 Docker o‘rnatuvchi (Linux Mint uchun)

Bu loyiha sizga Linux Mint tizimingizda Docker’ni tez va xatolarsiz o‘rnatishda yordam beradi.
O‘rnatish jarayoni o‘zbek tilida banner va xabarlar bilan ko‘rsatiladi.

📦 O‘rnatish bo‘yicha qo‘llanma

Reponi klon qiling yoki install.sh faylni yuklab oling:

git clone https://github.com/nodir-dev/Docker-install.git

cd Docker-install


yoki faqat faylni yuklab oling:
```bash

wget https://github.com/nodir-dev/Docker-install/blob/main/install.sh
```

Skriptga bajarilish huquqi bering:
```bash

chmod +x install.sh
```

Skriptni ishga tushiring:
```bash

sudo bash ./install.sh

```
⚡ Skript haqida

Boshlanishida chiroyli banner ko‘rsatiladi.

Foydalanuvchidan sudo parol talab qilinadi.

apt update ishlaydi va kerakli paketlar o‘rnatiladi.

Rasmiy Docker reposidan eng so‘nggi Docker versiyasi o‘rnatiladi.

O‘rnatishdan so‘ng avtomatik ravishda docker --version orqali tekshiriladi.

Barcha jarayonlar va xatoliklar o‘zbek tilida chiqariladi.

✅ Tekshiruv

O‘rnatish tugagach, quyidagi buyruqni ishga tushirib Docker versiyasini tekshiring:
```bash

docker --version
```
👤 Muallif

@Gojo_Developer
