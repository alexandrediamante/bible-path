-- Bible Path D1 Database Schema
-- Run: wrangler d1 execute bible-path-db --file=schema.sql

-- Users table
CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,                    -- Google user ID (sub)
  email TEXT UNIQUE NOT NULL,
  name TEXT,
  picture TEXT,
  locale TEXT DEFAULT 'en',
  created_at INTEGER NOT NULL,            -- Unix timestamp ms
  updated_at INTEGER NOT NULL,
  last_sync_at INTEGER                    -- Last successful sync
);

-- User preferences (synced from local UserPreferences)
CREATE TABLE IF NOT EXISTS user_preferences (
  user_id TEXT PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  is_dark_mode INTEGER DEFAULT 0,
  locale TEXT DEFAULT 'en',
  text_scale REAL DEFAULT 1.0,
  daily_reminder_time TEXT DEFAULT '07:00',
  daily_reminder_enabled INTEGER DEFAULT 0,
  preferred_bible_version TEXT DEFAULT 'engwebp',
  translation_style TEXT,
  denomination TEXT,
  ai_auth_token TEXT,                     -- Encrypted or hashed
  has_completed_onboarding INTEGER DEFAULT 0,
  updated_at INTEGER NOT NULL
);

-- Favorite verses
CREATE TABLE IF NOT EXISTS favorite_verses (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  verse_key TEXT NOT NULL,                -- e.g., "JHN.3.16"
  created_at INTEGER NOT NULL,
  UNIQUE(user_id, verse_key)
);

-- Chat sessions (synced)
CREATE TABLE IF NOT EXISTS chat_sessions (
  id TEXT PRIMARY KEY,                    -- UUID from app
  user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  is_deleted INTEGER DEFAULT 0
);

-- Chat messages
CREATE TABLE IF NOT EXISTS chat_messages (
  id TEXT PRIMARY KEY,                    -- UUID from app
  session_id TEXT NOT NULL REFERENCES chat_sessions(id) ON DELETE CASCADE,
  user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  text TEXT NOT NULL,
  is_user INTEGER NOT NULL,               -- 1 = user, 0 = assistant
  verse_reference TEXT,
  is_error INTEGER DEFAULT 0,
  timestamp INTEGER NOT NULL,             -- Unix timestamp ms
  synced_at INTEGER                       -- When synced to cloud
);

-- Daily plan progress
CREATE TABLE IF NOT EXISTS daily_plan_progress (
  user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  plan_date TEXT NOT NULL,                -- YYYY-MM-DD
  plan_id TEXT NOT NULL,
  completed_at INTEGER,                   -- Unix timestamp ms
  streak_day INTEGER,
  PRIMARY KEY (user_id, plan_date)
);

-- Prayer entries
CREATE TABLE IF NOT EXISTS prayers (
  id TEXT PRIMARY KEY,                    -- UUID from app
  user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title TEXT,
  content TEXT NOT NULL,
  category TEXT,                          -- e.g., "gratitude", "intercession"
  is_answered INTEGER DEFAULT 0,
  answered_at INTEGER,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  is_deleted INTEGER DEFAULT 0
);

-- Study plans progress
CREATE TABLE IF NOT EXISTS study_plans (
  id TEXT PRIMARY KEY,                    -- UUID from app
  user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  translation_id TEXT,
  total_days INTEGER DEFAULT 0,
  completed_days INTEGER DEFAULT 0,
  current_day INTEGER DEFAULT 0,
  is_completed INTEGER DEFAULT 0,
  started_at INTEGER NOT NULL,
  completed_at INTEGER,
  updated_at INTEGER NOT NULL
);

-- Study plan days
CREATE TABLE IF NOT EXISTS study_plan_days (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  plan_id TEXT NOT NULL REFERENCES study_plans(id) ON DELETE CASCADE,
  day_number INTEGER NOT NULL,
  title TEXT,
  reference TEXT,
  is_completed INTEGER DEFAULT 0,
  completed_at INTEGER,
  notes TEXT,
  UNIQUE(plan_id, day_number)
);

-- Advent/Lent progress
CREATE TABLE IF NOT EXISTS seasonal_progress (
  user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  season_type TEXT NOT NULL,              -- "advent" or "lent"
  year INTEGER NOT NULL,
  day_number INTEGER NOT NULL,
  is_completed INTEGER DEFAULT 0,
  completed_at INTEGER,
  notes TEXT,
  PRIMARY KEY (user_id, season_type, year, day_number)
);

-- Sync metadata (for conflict resolution)
CREATE TABLE IF NOT EXISTS sync_metadata (
  user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  entity_type TEXT NOT NULL,              -- 'preferences', 'favorite_verses', 'chat_sessions', etc.
  entity_id TEXT NOT NULL,
  local_version INTEGER DEFAULT 0,
  cloud_version INTEGER DEFAULT 0,
  last_modified_local INTEGER,
  last_modified_cloud INTEGER,
  conflict_resolution TEXT,               -- 'local_wins', 'cloud_wins', 'merged'
  PRIMARY KEY (user_id, entity_type, entity_id)
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_chat_messages_session ON chat_messages(session_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_user ON chat_messages(user_id);
CREATE INDEX IF NOT EXISTS idx_prayers_user ON prayers(user_id);
CREATE INDEX IF NOT EXISTS idx_study_plans_user ON study_plans(user_id);
CREATE INDEX IF NOT EXISTS idx_daily_plan_user ON daily_plan_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_seasonal_user ON seasonal_progress(user_id);