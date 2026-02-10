ALTER TABLE study_activities
  ADD COLUMN IF NOT EXISTS status VARCHAR(10) NOT NULL DEFAULT 'TODO';

ALTER TABLE study_activities
  ADD COLUMN IF NOT EXISTS course_name VARCHAR(200) NOT NULL DEFAULT 'Untitled';

ALTER TABLE study_activities
  ADD COLUMN IF NOT EXISTS chapter_subject VARCHAR(255) NOT NULL DEFAULT '';

ALTER TABLE study_activities
  ADD COLUMN IF NOT EXISTS review_minutes INTEGER NOT NULL DEFAULT 0;

ALTER TABLE study_activities
  ADD COLUMN IF NOT EXISTS studied_minutes INTEGER NOT NULL DEFAULT 0;

ALTER TABLE study_activities
  ADD COLUMN IF NOT EXISTS used_sources TEXT;

UPDATE study_activities
SET course_name = title
WHERE course_name IS NULL OR btrim(course_name) = '';

UPDATE study_activities
SET chapter_subject = ''
WHERE chapter_subject IS NULL;

UPDATE study_activities
SET studied_minutes = duration_minutes
WHERE studied_minutes IS NULL OR studied_minutes = 0;

UPDATE study_activities
SET review_minutes = 0
WHERE review_minutes IS NULL;

UPDATE study_activities
SET status = CASE
    WHEN activity_date < CURRENT_DATE THEN 'DONE'
    WHEN studied_minutes > 0 THEN 'DONE'
    ELSE 'TODO'
END
WHERE status IS NULL OR status NOT IN ('TODO', 'DONE');

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'study_activities_status_chk'
  ) THEN
    ALTER TABLE study_activities
      ADD CONSTRAINT study_activities_status_chk
      CHECK (status IN ('TODO', 'DONE'));
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'study_activities_review_minutes_chk'
  ) THEN
    ALTER TABLE study_activities
      ADD CONSTRAINT study_activities_review_minutes_chk
      CHECK (review_minutes >= 0 AND review_minutes <= 1440);
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'study_activities_studied_minutes_chk'
  ) THEN
    ALTER TABLE study_activities
      ADD CONSTRAINT study_activities_studied_minutes_chk
      CHECK (studied_minutes >= 0 AND studied_minutes <= 1440);
  END IF;
END $$;
