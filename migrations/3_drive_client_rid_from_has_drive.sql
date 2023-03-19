-- One-one relationship from a drive to its client
ALTER TABLE drives ADD COLUMN client_rid text;

UPDATE drives
SET client_rid = has_drive.out
FROM has_drive
WHERE drives.rid = has_drive.in;
