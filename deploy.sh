#!/bin/bash

# Vet Advice Bot Deployment Script
set -e

echo "🚀 Vet Advice Bot ni deploy qilish boshlandi..."

# Environment file tekshirish
if [ ! -f .env ]; then
    echo "❌ .env fayl topilmadi!"
    echo "📝 .env.example dan nusxa ko'chiring va BOT_TOKEN ni kiriting:"
    echo "   cp .env.example .env"
    echo "   nano .env"
    exit 1
fi

# BOT_TOKEN mavjudligini tekshirish
if ! grep -q "BOT_TOKEN=" .env || grep -q "BOT_TOKEN=your_telegram_bot_token_here" .env; then
    echo "❌ BOT_TOKEN to'g'ri sozlanmagan!"
    echo "📝 .env faylida BOT_TOKEN ni to'g'ri kiriting"
    exit 1
fi

# Docker mavjudligini tekshirish
if ! command -v docker &> /dev/null; then
    echo "❌ Docker o'rnatilmagan!"
    echo "📦 Dockerni o'rnating: https://docs.docker.com/get-docker/"
    exit 1
fi

if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose o'rnatilmagan!"
    echo "📦 Docker Compose ni o'rnating"
    exit 1
fi

# Environment (dev/prod) ni belgilash
ENVIRONMENT=${1:-dev}

if [ "$ENVIRONMENT" = "prod" ]; then
    COMPOSE_FILE="docker-compose.prod.yml"
    echo "🏭 Production environment"
else
    COMPOSE_FILE="docker-compose.yml"
    echo "🔧 Development environment"
fi

echo "📦 Docker images ni build qilish..."
docker-compose -f $COMPOSE_FILE build

echo "🗃️ Eski container larni to'xtatish..."
docker-compose -f $COMPOSE_FILE down

echo "🚀 Yangi container larni ishga tushirish..."
docker-compose -f $COMPOSE_FILE up -d

echo "⏳ Servislar tayyor bo'lguncha kutish..."
sleep 10

# Health check
echo "🔍 Servislarni tekshirish..."
if docker-compose -f $COMPOSE_FILE ps | grep -q "Up"; then
    echo "✅ Servislar muvaffaqiyatli ishga tushdi!"
    echo ""
    echo "📊 Status:"
    docker-compose -f $COMPOSE_FILE ps
    echo ""
    echo "📝 Loglarni ko'rish uchun:"
    echo "   docker-compose -f $COMPOSE_FILE logs -f"
    echo ""
    if [ "$ENVIRONMENT" = "dev" ]; then
        echo "🔧 pgAdmin: http://localhost:8081"
        echo "   Email: admin@vetbot.com"
        echo "   Password: admin123"
    fi
else
    echo "❌ Xato yuz berdi! Loglarni tekshiring:"
    docker-compose -f $COMPOSE_FILE logs
    exit 1
fi

echo ""
echo "🎉 Deploy muvaffaqiyatli yakunlandi!"
