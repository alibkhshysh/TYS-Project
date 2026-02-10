ALTER TABLE users ADD COLUMN IF NOT EXISTS first_name VARCHAR(100);
ALTER TABLE users ADD COLUMN IF NOT EXISTS last_name VARCHAR(100);
ALTER TABLE users ADD COLUMN IF NOT EXISTS birth_date DATE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS degree_level VARCHAR(30);
ALTER TABLE users ADD COLUMN IF NOT EXISTS major VARCHAR(150);
ALTER TABLE users ADD COLUMN IF NOT EXISTS department VARCHAR(150);
ALTER TABLE users ADD COLUMN IF NOT EXISTS university VARCHAR(200);

UPDATE users SET first_name = 'Unknown'
WHERE first_name IS NULL OR btrim(first_name) = '';

UPDATE users SET last_name = 'Unknown'
WHERE last_name IS NULL OR btrim(last_name) = '';

UPDATE users SET birth_date = DATE '1970-01-01'
WHERE birth_date IS NULL;

UPDATE users SET degree_level = 'Other'
WHERE degree_level IS NULL
   OR degree_level NOT IN ('Bachelor', 'Master', 'PhD', 'Other');

UPDATE users SET major = 'Unknown'
WHERE major IS NULL OR btrim(major) = '';

UPDATE users SET department = 'Unknown'
WHERE department IS NULL OR btrim(department) = '';

UPDATE users SET university = 'Unknown'
WHERE university IS NULL OR btrim(university) = '';

ALTER TABLE users ALTER COLUMN first_name SET NOT NULL;
ALTER TABLE users ALTER COLUMN last_name SET NOT NULL;
ALTER TABLE users ALTER COLUMN birth_date SET NOT NULL;
ALTER TABLE users ALTER COLUMN degree_level SET NOT NULL;
ALTER TABLE users ALTER COLUMN major SET NOT NULL;
ALTER TABLE users ALTER COLUMN department SET NOT NULL;
ALTER TABLE users ALTER COLUMN university SET NOT NULL;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'users_degree_level_chk'
    ) THEN
        ALTER TABLE users
            ADD CONSTRAINT users_degree_level_chk
            CHECK (degree_level IN ('Bachelor', 'Master', 'PhD', 'Other'));
    END IF;
END $$;
