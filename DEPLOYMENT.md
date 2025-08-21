# Vet Advice Bot - Docker Deployment Guide

Bu qo'llanma Vet Advice Bot ni Docker orqali deploy qilish uchun.

## Talablar

- Docker va Docker Compose o'rnatilgan bo'lishi kerak
- Bot token (Telegram @BotFather dan)

## Deploy qilish

### 1. Environment variables ni sozlash

`.env` fayl yarating va quyidagi ma'lumotlarni kiriting:

```bash
BOT_TOKEN=your_telegram_bot_token_here
```

### 2. Botni ishga tushirish

```bash
# Barcha servislarni ishga tushirish
docker-compose up -d

# Loglarni ko'rish
docker-compose logs -f vet_advice_bot

# Faqat bot va database (pgAdmin siz)
docker-compose up -d postgres vet_advice_bot
```

### 3. pgAdmin bilan database ni boshqarish (ixtiyoriy)

Agar database ni boshqarish kerak bo'lsa:

```bash
# pgAdmin bilan ishga tushirish
docker-compose --profile admin up -d

# pgAdmin ga kirish: http://localhost:8081
# Email: admin@vetbot.com
# Password: admin123
```

### 4. Servislarni to'xtatish

```bash
# Barcha servislarni to'xtatish
docker-compose down

# Volume lar bilan birga o'chirish (ma'lumotlar yo'qoladi!)
docker-compose down -v
```

## Serverda deploy qilish

### Production environment uchun

1. **Server tayyorlash:**
```bash
# Docker o'rnatish (Ubuntu/Debian)
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Docker Compose o'rnatish
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

2. **Loyihani serverga yuklash:**
```bash
# Git orqali
git clone https://github.com/DiyorbekFlutter/vet_advice_bot.git
cd vet_advice_bot

# yoki fayllarniz ZIP orqali yuklab serverga ko'chiring
```

3. **Environment variables sozlash:**
```bash
# .env fayl yarating
echo "BOT_TOKEN=your_real_bot_token" > .env
```

4. **Ishga tushirish:**
```bash
docker-compose up -d
```

## Monitoring va Maintenance

### Loglarni ko'rish
```bash
# Bot loglari
docker-compose logs -f vet_advice_bot

# Database loglari  
docker-compose logs -f postgres

# Barcha loglar
docker-compose logs -f
```

### Backup olish
```bash
# Database backup
docker exec vet_advice_bot_db pg_dump -U userjon vet_advice_bot > backup.sql

# Volume backup
docker run --rm -v vet_advice_bot_postgres_data:/data -v $(pwd):/backup alpine tar czf /backup/db_backup.tar.gz -C /data .
```

### Yangilash
```bash
# Yangi kodlarni tortish
git pull

# Container larni qayta build qilish
docker-compose build

# Yangi versiyani ishga tushirish
docker-compose up -d
```

## Troubleshooting

### Botning ishlayotganini tekshirish
```bash
docker-compose ps
docker-compose logs vet_advice_bot
```

### Database ga ulanishni tekshirish
```bash
docker exec -it vet_advice_bot_db psql -U userjon -d vet_advice_bot
```

### Xatoliklarni aniqlash
```bash
# Container statusini ko'rish
docker-compose ps

# Xato loglarini ko'rish
docker-compose logs --tail=50 vet_advice_bot
```

## Xavfsizlik

- Bot token ni `.env` faylida saqlang va uni git ga commit qilmang
- Production da strong password lar ishlating
- Firewall sozlamalarini tekshiring
- Muntazam backup oling

## Portlar

- **5432**: PostgreSQL (faqat internal network)
- **8081**: pgAdmin (ixtiyoriy, admin profile bilan)

Bot faqat outbound connection ishlatadi (Telegram API ga), shuning uchun incoming portlar kerak emas.
