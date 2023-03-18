-- One-one relationship from a fare to its drive
ALTER TABLE fares ADD COLUMN drive_rid text;
UPDATE fares
SET drive_rid = has_fare.out
FROM has_fare
WHERE fares.rid = has_fare.in;

-- Clean bad data
DELETE FROM fares WHERE drive_rid IS NULL;
