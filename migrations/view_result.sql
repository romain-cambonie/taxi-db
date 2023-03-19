CREATE VIEW view_result AS
SELECT fares.rid,
    clients.identity,
    clients.phone,
    fares.created_at,
    fares.creator,
    fares.date,
    fares.distance,
    fares.duration,
    fares.isreturn,
    fares.locked,
    fares.meters,
    fares.recurrent,
    fares.status,
    fares.subcontractor,
    fares."time",
    fares."timestamp",
    fares.updated_at,
    fares.weeklyrecurrence,
    fares.drive_rid,
    drives.type,
    drives.drive_from,
    drives.drive_to,
    drives.comment AS driveComment,
    drives.distanceoverride,
    drives.name,
    clients.comment AS clientComment
   FROM (fares fares
     LEFT JOIN drives drives ON ((fares.drive_rid = drives.rid))
     LEFT JOIN users clients ON ((drives.client_rid = clients.rid))
     )
  WHERE (fares.date = '2019-03-05'::text);
