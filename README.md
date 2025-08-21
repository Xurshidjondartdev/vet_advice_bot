# Vet Advice Bot 🐾

Veterinar maslahat beruvchi Telegram bot. Bu bot hayvon egalariga professional veterinar maslahatlari beradi.

## 🚀 Quick Start (Docker)

### 1. Environment sozlash
```bash
# .env fayl yarating
cp .env.example .env

# Bot token ni kiriting
# .env faylini oching va BOT_TOKEN ni o'zgartiring
```

### 2. Botni ishga tushirish

**Windows:**
```powershell
# Development
.\deploy.ps1

# Production
.\deploy.ps1 -Environment prod
```

**Linux/macOS:**
```bash
# Script ni executable qiling
chmod +x deploy.sh

# Development
./deploy.sh

# Production  
./deploy.sh prod
```

### 3. Manual ishga tushirish
```bash
# Development environment
docker-compose up -d

# Production environment
docker-compose -f docker-compose.prod.yml up -d

# Loglarni ko'rish
docker-compose logs -f vet_advice_bot
```

## 🛠 Development

### Local development (Dart)
```bash
# Dependencies ni o'rnatish
dart pub get

# Botni ishga tushirish (PostgreSQL kerak)
dart run bin/main.dart
```

### Database setup
PostgreSQL o'rnatilgan bo'lishi va quyidagi sozlamalar bo'lishi kerak:
- Database: `vet_advice_bot`
- User: `userjon` 
- Password: `root`

## 📊 Monitoring

### Loglarni ko'rish
```bash
docker-compose logs -f vet_advice_bot
```

### Database boshqaruvi (Development)
pgAdmin: http://localhost:8081
- Email: admin@vetbot.com
- Password: admin123

### Container statusini tekshirish
```bash
docker-compose ps
```

## 🔧 Configuration

Environment variables (`.env` fayl):
```bash
BOT_TOKEN=your_telegram_bot_token_here
DB_PASSWORD=root  # ixtiyoriy
```

## 📁 Project Structure

```
├── bin/
│   └── main.dart          # Entry point
├── lib/
│   ├── bot.dart           # Asosiy bot logic
│   ├── core/
│   │   └── constants.dart # Konfiguratsiya
│   ├── src/
│   │   ├── user/          # User handlers
│   │   ├── admin/         # Admin handlers
│   │   └── services/      # Database va boshqa servislar
├── docker-compose.yml     # Development
├── docker-compose.prod.yml # Production
├── Dockerfile
├── deploy.sh             # Linux/macOS deployment
├── deploy.ps1            # Windows deployment
└── DEPLOYMENT.md         # To'liq deployment guide
```

## 🚀 Production Deploy

To'liq deployment qo'llanmasi: [DEPLOYMENT.md](DEPLOYMENT.md)

1. Serverni tayyorlash (Docker o'rnatish)
2. Loyihani klonlash
3. Environment sozlash
4. Deploy qilish

## 🤝 Contributing

1. Fork qiling
2. Feature branch yarating
3. Commit qiling
4. Push qiling
5. Pull request yarating

## 📝 License

Bu loyiha MIT license ostida.
