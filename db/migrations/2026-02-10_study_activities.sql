CREATE TABLE IF NOT EXISTS study_activities (
  id               SERIAL PRIMARY KEY,
  user_id          INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  activity_date    DATE NOT NULL,
  title            VARCHAR(200) NOT NULL,
  duration_minutes INTEGER NOT NULL CHECK (duration_minutes > 0 AND duration_minutes <= 1440),
  notes            TEXT,
  created_at       TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_study_activities_user_date
  ON study_activities(user_id, activity_date);
