-- Gather data from address table that will be dropped later
ALTER TABLE fares ADD COLUMN driver_rid text;

-- First we take the reference from the intermediate edge
UPDATE fares
SET driver_rid = has_entry.out
FROM has_entry
WHERE fares.rid = has_entry.in;

UPDATE fares
SET driver_rid = has_owner.in
FROM has_owner
WHERE fares.driver_rid = has_owner.out;
