# Taxi Gestion DB

> Ce dépot est obsolète. Le projet Taxi Gestion est hébergé sur son [organisation dédiée](https://github.com/taxi-gestion)

## À propos
Outil de gestion à destination des flottes de taxi, particulièrement des vsl (véhicules sanitaires légers).

> Ce dépot est responsable de la partie applicative base de données.
> 
> Actuellement il fait la conversion régulière d'une bdd de production (legacy) sur [OrientDB](http://orientdb.com/docs/2.2.x/) vers une base de données [PostgreSQL](https://www.postgresql.org/) hébergée sur [Amazon RDS](https://aws.amazon.com/rds/).
> 
> Il permet également de monter une base structurellement à jour pour le développement local avec des l'outil d'administration de base de données [Adminer](https://www.adminer.org/) pour aider au développement.

- 🪧 [À propos](#à-propos)
- 📦 [Prérequis](#prérequis)
- 🛠️ [Utilisation locale](#utilisation-locale)
- 🤝 [Contribution](#contribution)

## Prérequis

Pour créer le service de base de données
- [Docker](https://docs.docker.com) : Système de gestion de conteneurs

Pour executer en local le script de conversion
- [jq](https://stedolan.github.io/jq/)
- [miller](https://miller.readthedocs.io/en/6.7.0/)
- [psql](https://www.postgresql.org/docs/current/app-psql.html)

> Il est relativement aisé d'utiliser la version 'desktop' de docker pour [linux](https://docs.docker.com/desktop/install/linux-install/) ou [windows](https://docs.docker.com/desktop/install/windows-install/) pour mettre en place un environement local de base de donnée



### Utilisation locale
#### Postgres et adminer locaux avec [docker-compose](https://docs.docker.com/compose/)

```bash
docker-compose ./docker-compose.postgres-and-adminer.yml up
```

#### Executer le script de convertion
```bash
./archiveToPgReadyData.sh archive.gz postgres://postgres:password@localhost:5432/taxi
```

### Contribution

Le projet n'est actuellement pas ouvert à la contribution

## Processus manuel de migration à partir d'un dump OrientDB (Obsolète)

### Extract valid data records
```shell
gzip -d taxi.gz
jq '.records' taxi > records
jq 'map(select(has("@class")))' records > class
```

#### Préparer une table pour la migration (eg Drivers)
```shell
jq 'map(select(."@class" | contains("Driver")))' class > drivers
```

#### Transformer les records jq en csv
```shell
jq -r '(map(keys) | add | unique) as $cols | map(. as $row | $cols | map($row[.] | tostring )) as $rows | $cols, $rows[] | @csv' CONTENT > TABLE.csv
```

#### Sur la première ligne uniquement du CSV:
  - :Remplacer les @ par " " dans le csv (rechercher / remplacer)
  - mettre les noms de colonne en lowercase (plugin string manipulation)

#### Creer la requete sql de creation de table

```sql
CREATE TABLE $TABLE_orient (
...
);
```

remplacer les '...' par la première ligne du csv toutes les colonnes, 
puis remplacer les '"' par ' ' puis la ',' par ' text,*cliquer sur new ligne*' 
puis rajouter 'text' sur la dernière colonne

#### Préparer l'instruction de \copy 
Format:
\copy $TABLENAME ($COLUMNS_DEFINITION_FROM_CSV_FIRST_ROW) from './$CONTENT.csv' WITH DELIMITER ',' CSV HEADER;


#### Se connecter à l'instance de db accessible publiquement
psql --host=$AWS_ENDPOINT --port=5432 --username=$PG_USERNAME --password --dbname=taxi

#### Copy csv content to remote  db (eg drivers)
```shell
psql --host=*** --port=5432 --username=username --password --dbname=taxi
DROP TABLE IF EXISTS $TABLE;
CREATE TABLE (...);

```

### Tables traitées
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
