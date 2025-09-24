#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# install_docker_linuxmint.sh
# Linux Mint uchun Docker Engine + Compose plugin o‘rnatish scripti
# Muallif: @Gojo_Developer
# Linux Mint (Ubuntu asosida) tizimlarida sinovdan o‘tkazilgan.
# Foydalanish: sudo ./install_docker_linuxmint.sh
# ---------------------------------------------------------------------------
set -euo pipefail
IFS=$'\n\t'

# Banner
clear
echo ""
echo "=============================================="
echo "   🚀  DOCKER O‘RNATUVCHI SCRIPT  🚀"
echo "=============================================="
echo "       Muallif: @Gojo_Developer"
echo "=============================================="
echo ""

LOG() { printf "[%s] %s\n" "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$*" >&2; }
ERR() { LOG "XATO: $*"; exit 1; }

# Root huquqi bilan ishga tushirilganligini tekshirish
if [ "$EUID" -ne 0 ]; then
  ERR "Script root huquqi bilan ishlashi kerak. Masalan: sudo $0"
fi

# Kerakli buyruqlarni tekshirish
for cmd in curl gpg apt-get lsb_release; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    case "$cmd" in
      lsb_release)
        LOG "lsb_release topilmadi — distro ma’lumotini /etc/os-release dan olishga urinamiz"
        ;;
      *)
        ERR "Kerakli '$cmd' buyrug‘i o‘rnatilmagan. Iltimos: apt-get install -y $cmd va qayta urinib ko‘ring."
        ;;
    esac
  fi
done

# Distro kod nomini olish (Linux Mint Ubuntu asosidan foydalanadi)
if command -v lsb_release >/dev/null 2>&1; then
  UBUNTU_CODENAME=$(lsb_release -cs)
else
  if [ -r /etc/os-release ]; then
    . /etc/os-release
    UBUNTU_CODENAME=${UBUNTU_CODENAME:-${VERSION_CODENAME:-}}
  fi
fi

if [ -z "${UBUNTU_CODENAME:-}" ]; then
  ERR "Distrib kodi aniqlanmadi. lsb_release o‘rnating yoki /etc/os-release mavjudligini tekshiring."
fi

LOG "Aniqlangan kod nomi: $UBUNTU_CODENAME"

# APT yangilash va kerakli paketlarni o‘rnatish
LOG "APT yangilanmoqda va kerakli dasturlar o‘rnatilmoqda..."
apt-get update -y
apt-get install -y ca-certificates curl gnupg lsb-release

# Docker GPG kalitini qo‘shish
DOCKER_KEYRING=/usr/share/keyrings/docker-archive-keyring.gpg
LOG "Docker GPG kaliti qo‘shilmoqda: $DOCKER_KEYRING"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o "$DOCKER_KEYRING"
chmod 644 "$DOCKER_KEYRING"

# Docker repozitoriyasini qo‘shish
DOCKER_LIST=/etc/apt/sources.list.d/docker.list
ARCH=$(dpkg --print-architecture)
LOG "Docker repozitoriyasi qo‘shilmoqda (arch=$ARCH, codename=$UBUNTU_CODENAME)"
cat > "$DOCKER_LIST" <<EOF
# Docker rasmiy repozitoriyasi
deb [arch=$ARCH signed-by=$DOCKER_KEYRING] https://download.docker.com/linux/ubuntu $UBUNTU_CODENAME stable
EOF

# Yangilash va Docker o‘rnatish
LOG "APT yangilanmoqda (Docker repo qo‘shilgandan so‘ng)..."
apt-get update -y

LOG "Docker paketlari o‘rnatilmoqda (docker-ce, docker-ce-cli, containerd.io, docker-compose-plugin)..."
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin || {
  LOG "Fallback: oxirgi urinish sifatida docker.io o‘rnatishga harakat qilinmoqda"
  apt-get install -y docker.io || ERR "Docker o‘rnatib bo‘lmadi."
}

# Docker xizmatini yoqish va ishga tushirish
LOG "docker.service yoqilmoqda va ishga tushirilmoqda"
systemctl enable docker --now || ERR "docker xizmatini ishga tushirishda xato. Tekshiring: systemctl status docker"

# Sudo foydalanuvchini docker guruhiga qo‘shish
if [ -n "${SUDO_USER:-}" ] && id -u "$SUDO_USER" >/dev/null 2>&1; then
  LOG "Foydalanuvchi $SUDO_USER 'docker' guruhiga qo‘shilmoqda"
  usermod -aG docker "$SUDO_USER" || LOG "Ogohlantirish: $SUDO_USER guruhga qo‘shilmadi"
  LOG "Eslatma: $SUDO_USER chiqib qayta kirishi (yoki 'newgrp docker') kerak bo‘ladi."
fi

# O‘rnatishni tekshirish
LOG "Docker o‘rnatilishi tekshirilmoqda..."
if docker --version >/dev/null 2>&1; then
  docker --version
else
  ERR "docker buyruq topilmadi."
fi

LOG "hello-world konteyneri ishga tushirilmoqda..."
if docker run --rm hello-world >/tmp/docker_hello.txt 2>&1; then
  LOG "hello-world konteyneri muvaffaqiyatli ishga tushdi — Docker ishlayapti"
  sed -n '1,200p' /tmp/docker_hello.txt || true
else
  LOG "Ogohlantirish: hello-world konteyneri ishga tushmadi. Oxirgi 200 belgisi:" 
  tail -c 200 /tmp/docker_hello.txt || true
  LOG "Loglarni tekshiring: sudo journalctl -u docker --no-pager --since '5 minutes ago'"
fi

LOG "O‘rnatish yakunlandi. Keyingi foydali amallar:"
cat <<EOF
- Agar foydalanuvchi 'docker' guruhiga qo‘shilgan bo‘lsa, tizimdan chiqib qayta kiring yoki: newgrp docker
- Oddiy foydalanuvchi sifatida Docker tekshirish: docker run --rm hello-world
- Docker Compose ishlatish: docker compose up -d
- Docker xizmat holatini ko‘rish: sudo systemctl status docker

Agar muammo chiqsa, quyidagilarni yuboring: 
  sudo journalctl -u docker --no-pager --since '1 hour ago'
  sudo docker --version
  sudo apt-cache policy docker-ce containerd.io docker-compose-plugin

==============================================
   🚀 DOCKER O‘RNATUVCHI SCRIPT  🚀
   ✅ O‘rnatish yakunlandi!
   Muallif: @Gojo_Developer
==============================================
EOF

exit 0
