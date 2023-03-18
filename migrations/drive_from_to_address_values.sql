-- Gather data from address table that will be dropped later
ALTER TABLE drives ADD COLUMN drive_from text;
ALTER TABLE drives ADD COLUMN drive_to text;

-- First we take the reference from the intermediate edge
UPDATE drives
SET drive_from = drive_from.in
FROM drive_from
WHERE drives.rid = drive_from.out;

UPDATE drives
SET drive_to = drive_to.in
FROM drive_to
WHERE drives.rid = drive_to.out;


-- First we take the data from the addresses table
UPDATE drives
SET drive_from = addresses.formattedaddress
FROM addresses
WHERE drives.drive_from = addresses.rid;

UPDATE drives
SET drive_to = addresses.formattedaddress
FROM addresses
WHERE drives.drive_to = addresses.rid;
