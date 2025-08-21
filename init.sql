-- Timezone ni o'rnatish
SET timezone = 'Asia/Tashkent';

-- Users jadvalini yaratish
CREATE TABLE IF NOT EXISTS users(
    id BIGINT UNIQUE NOT NULL,
    fullName VARCHAR,
    state VARCHAR,
    balance INTEGER DEFAULT 0 NOT NULL,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    lastPaymentDate TIMESTAMP
);

-- Index qo'shish performance uchun
CREATE INDEX IF NOT EXISTS idx_users_id ON users(id);
CREATE INDEX IF NOT EXISTS idx_users_state ON users(state);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON users(createdAt);

-- Ma'lumotlar bazasi tayyor!
SELECT 'Database initialized successfully!' as status;
