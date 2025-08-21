# Dart SDK rasmini ishlatamiz
FROM dart:stable AS build

# Ish direktoriyasini belgilaymiz
WORKDIR /app

# pubspec fayllarini ko'chiramiz va dependencies ni yuklaymiz
COPY pubspec.* ./
RUN dart pub get

# Barcha kodlarni ko'chiramiz
COPY . .

# Ilovani compile qilamiz
RUN dart compile exe bin/main.dart -o bin/server

# Production bosqichi
FROM debian:bookworm-slim

# PostgreSQL client va boshqa kerakli toollarni o'rnatamiz
RUN apt-get update && apt-get install -y \
    postgresql-client \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Foydalanuvchi yaratamiz
RUN useradd -ms /bin/bash dartuser

# Ish direktoriyasini yaratamiz
WORKDIR /app

# Compiled binary ni ko'chiramiz
COPY --from=build /app/bin/server /app/server

# Egalikning o'zgarishi
RUN chown -R dartuser:dartuser /app

# Non-root foydalanuvchiga o'tamiz
USER dartuser

# Portni expose qilamiz (agar kerak bo'lsa)
EXPOSE 8080

# Ilovani ishga tushiramiz
CMD ["./server"]
