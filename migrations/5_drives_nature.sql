ALTER TABLE drives ADD COLUMN nature text;

UPDATE drives
SET nature =
  CASE
    WHEN type = 'standard' OR type2 = 'standard' THEN 'standard'
    WHEN type = 'medical' OR type2 = 'medical' THEN 'medical'
  END;

ALTER TABLE drives DROP COLUMN "type";
ALTER TABLE drives DROP COLUMN type2;
