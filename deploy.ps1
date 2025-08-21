# Vet Advice Bot Deployment Script for Windows
param(
    [string]$Environment = "dev"
)

Write-Host "🚀 Vet Advice Bot ni deploy qilish boshlandi..." -ForegroundColor Green

# Environment file tekshirish
if (-not (Test-Path ".env")) {
    Write-Host "❌ .env fayl topilmadi!" -ForegroundColor Red
    Write-Host "📝 .env.example dan nusxa ko'chiring va BOT_TOKEN ni kiriting:" -ForegroundColor Yellow
    Write-Host "   Copy-Item .env.example .env" -ForegroundColor White
    Write-Host "   notepad .env" -ForegroundColor White
    exit 1
}

# BOT_TOKEN mavjudligini tekshirish
$envContent = Get-Content .env -Raw
if (-not ($envContent -match "BOT_TOKEN=") -or ($envContent -match "BOT_TOKEN=your_telegram_bot_token_here")) {
    Write-Host "❌ BOT_TOKEN to'g'ri sozlanmagan!" -ForegroundColor Red
    Write-Host "📝 .env faylida BOT_TOKEN ni to'g'ri kiriting" -ForegroundColor Yellow
    exit 1
}

# Docker mavjudligini tekshirish
try {
    docker --version | Out-Null
} catch {
    Write-Host "❌ Docker o'rnatilmagan!" -ForegroundColor Red
    Write-Host "📦 Dockerni o'rnating: https://docs.docker.com/desktop/windows/" -ForegroundColor Yellow
    exit 1
}

try {
    docker-compose --version | Out-Null
} catch {
    Write-Host "❌ Docker Compose o'rnatilmagan!" -ForegroundColor Red
    Write-Host "📦 Docker Desktop bilan birga o'rnatilishi kerak" -ForegroundColor Yellow
    exit 1
}

# Environment (dev/prod) ni belgilash
if ($Environment -eq "prod") {
    $ComposeFile = "docker-compose.prod.yml"
    Write-Host "🏭 Production environment" -ForegroundColor Magenta
} else {
    $ComposeFile = "docker-compose.yml"
    Write-Host "🔧 Development environment" -ForegroundColor Cyan
}

Write-Host "📦 Docker images ni build qilish..." -ForegroundColor Blue
docker-compose -f $ComposeFile build

Write-Host "🗃️ Eski container larni to'xtatish..." -ForegroundColor Yellow
docker-compose -f $ComposeFile down

Write-Host "🚀 Yangi container larni ishga tushirish..." -ForegroundColor Green
docker-compose -f $ComposeFile up -d

Write-Host "⏳ Servislar tayyor bo'lguncha kutish..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Health check
Write-Host "🔍 Servislarni tekshirish..." -ForegroundColor Blue
$status = docker-compose -f $ComposeFile ps
if ($status -match "Up") {
    Write-Host "✅ Servislar muvaffaqiyatli ishga tushdi!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📊 Status:" -ForegroundColor Cyan
    docker-compose -f $ComposeFile ps
    Write-Host ""
    Write-Host "📝 Loglarni ko'rish uchun:" -ForegroundColor Yellow
    Write-Host "   docker-compose -f $ComposeFile logs -f" -ForegroundColor White
    Write-Host ""
    if ($Environment -eq "dev") {
        Write-Host "🔧 pgAdmin: http://localhost:8081" -ForegroundColor Cyan
        Write-Host "   Email: admin@vetbot.com" -ForegroundColor White
        Write-Host "   Password: admin123" -ForegroundColor White
    }
} else {
    Write-Host "❌ Xato yuz berdi! Loglarni tekshiring:" -ForegroundColor Red
    docker-compose -f $ComposeFile logs
    exit 1
}

Write-Host ""
Write-Host "🎉 Deploy muvaffaqiyatli yakunlandi!" -ForegroundColor Green
