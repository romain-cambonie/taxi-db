# Conversion from orientDB to postgresql

# Current

# Manual Process (Deprecated)

## Extract valid data records
```shell
gzip -d taxi.gz
jq '.records' taxi > records
jq 'map(select(has("@class")))' records > class
```

### Préparer une table pour la migration (eg Drivers)
```shell
jq 'map(select(."@class" | contains("Driver")))' class > drivers
```

### Transformer les records jq en csv
```shell
jq -r '(map(keys) | add | unique) as $cols | map(. as $row | $cols | map($row[.] | tostring )) as $rows | $cols, $rows[] | @csv' CONTENT > TABLE.csv
```

### Sur la première ligne uniquement du CSV:
  - :Remplacer les @ par " " dans le csv (rechercher / remplacer)
  - mettre les noms de colonne en lowercase (plugin string manipulation)

### Creer la requete sql de creation de table

```sql
CREATE TABLE $TABLE_orient (
...
);
```

remplacer les '...' par la première ligne du csv toutes les colonnes, 
puis remplacer les '"' par ' ' puis la ',' par ' text,*cliquer sur new ligne*' 
puis rajouter 'text' sur la dernière colonne

### Préparer l'instruction de \copy 
Format:
\copy $TABLENAME ($COLUMNS_DEFINITION_FROM_CSV_FIRST_ROW) from './$CONTENT.csv' WITH DELIMITER ',' CSV HEADER;


### Se connecter à l'instance de db accessible publiquement
psql --host=$AWS_ENDPOINT --port=5432 --username=$PG_USERNAME --password --dbname=taxi

### Copy csv content to remote  db (eg drivers)
```shell
psql --host=*** --port=5432 --username=username --password --dbname=taxi
DROP TABLE IF EXISTS $TABLE;
CREATE TABLE (...);

```

# Tables traitées
Driver :
```shell
\copy drivers_orient ("class","fieldtypes","rid","type","version","active","created_at","deviceid","email","firstname","identity","in_has_owner","lastname","latitude","longitude","medical_weight","out_has_address","out_owned_by","out_user_role","password","phone","remember_token","standard","standard_weight","updated_at","work") from './drivers.csv' WITH DELIMITER ',' CSV HEADER;
```

Address:
```shell
\copy addresses_orient ("class","fieldtypes","rid","type","version","administrativearealevel1","administrativearealevel2","country","formattedaddress","in_drive_from","in_drive_to","in_has_address","latitude","locality","longitude","place_id","postalcode","route","slug","streetnumber") from './addresses.csv' WITH DELIMITER ',' CSV HEADER;
```

Drive:
```shell
\copy drives_orient ("class","fieldtypes","rid","type","version","active","comment","created_at","deviceid","distanceoverride","email","firstname","identity","in_has_drive","in_has_owner","lastname","latitude","longitude","medical_weight","name","out_drive_from","out_drive_to","out_has_address","out_has_fare","out_owned_by","out_user_role","password","phone","remember_token","standard","standard_weight","twoway","type2","updated_at","work") from './drives.csv' WITH DELIMITER ',' CSV HEADER;
```

Fare:
```shell
\copy fares_orient ("class","fieldtypes","rid","type","version","created_at","creator","date","distance","duration","in_has_entry","in_has_fare","isreturn","locked","meters","out_has_invoice","recurrent","status","subcontractor","time","timestamp","updated_at","weeklyrecurrence") from './fares.csv' WITH DELIMITER ',' CSV HEADER;
```

Planning
```shell
\copy plannings_orient ("class","fieldtypes","rid","type","version","autoaffectendtime","autoaffectstarttime","created_at","deltabetweenentry","hasmedicallicense","out_has_entry","out_has_metric","out_has_owner","updated_at") from './plannings.csv' WITH DELIMITER ',' CSV HEADER;
```

Users
```shell
\copy users_orient ("class","fieldtypes","rid","type","version","active","comment","created_at","deviceid","email","firstname","identity","lastname","latitude","longitude","name","out_has_address","out_has_drive","out_owned_by","out_user_role","password","phone","planning","remember_token","roles","socialnumber","status","super_user","updated_at") from './users.csv' WITH DELIMITER ',' CSV HEADER;
```