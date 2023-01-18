# One-one relationship
ALTER TABLE fares ADD COLUMN drive_rid text;
UPDATE fares
SET drive_rid = has_fare.out
FROM has_fare
WHERE fares.rid = has_fare.in;

# Clean bad data
DELETE FROM fares WHERE drive_id IS NULL;
