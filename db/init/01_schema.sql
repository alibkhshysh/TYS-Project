CREATE TABLE IF NOT EXISTS users (
  id            SERIAL PRIMARY KEY,

  first_name    VARCHAR(100) NOT NULL,
  last_name     VARCHAR(100) NOT NULL,
  birth_date    DATE NOT NULL,

  degree_level  VARCHAR(30) NOT NULL CHECK (degree_level IN ('Bachelor', 'Master', 'PhD', 'Other')),
  major         VARCHAR(150) NOT NULL,
  department    VARCHAR(150) NOT NULL,
  university    VARCHAR(200) NOT NULL,

  email         VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,

  created_at    TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS study_activities (
  id               SERIAL PRIMARY KEY,
  user_id          INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  activity_date    DATE NOT NULL,
  title            VARCHAR(200) NOT NULL,
  duration_minutes INTEGER NOT NULL CHECK (duration_minutes > 0 AND duration_minutes <= 1440),
  status           VARCHAR(10) NOT NULL DEFAULT 'TODO' CHECK (status IN ('TODO', 'DONE')),
  course_name      VARCHAR(200) NOT NULL,
  chapter_subject  VARCHAR(255) NOT NULL DEFAULT '',
  review_minutes   INTEGER NOT NULL DEFAULT 0 CHECK (review_minutes >= 0 AND review_minutes <= 1440),
  studied_minutes  INTEGER NOT NULL DEFAULT 0 CHECK (studied_minutes >= 0 AND studied_minutes <= 1440),
  used_sources     TEXT,
  notes            TEXT,
  created_at       TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_study_activities_user_date
  ON study_activities(user_id, activity_date);
