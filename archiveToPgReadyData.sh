#!/bin/bash
echo "Starting data extraction on archive" $1

filename=$1
filename_without_extension=${filename//.gz/}

entities=(addresses fares drives plannings users drivers has_fare drive_from drive_to has_drive has_entry has_owner)

createTableFromCsvHeaders() {
  headers=$1
  headers_without_quotes=${headers//\"}
  table=$2
  # Remove quotes and split into array
  IFS=',' read -ra cols <<< "${headers_without_quotes}"

  # Generate CREATE TABLE SQL command
  sql="DROP TABLE IF EXISTS $table; CREATE TABLE $table ("

  for col in "${cols[@]}"; do
    sql+="\"$col\" TEXT, "
  done

  # Remove trailing comma and space
  sql=${sql%,*}

  # Close SQL command and print to console
  sql+=");"

  echo "$sql" > $table.sql
  echo "\copy $table ($header) from $table.csv WITH DELIMITER ',' CSV HEADER;" >> $table.sql
}

recordsToCsv() {
  jq -r '(map(keys) | add | unique) as $cols | map(. as $row | $cols | map($row[.] | tostring )) as $rows | $cols, $rows[] | @csv' $1 > $1.csv
  sed -i '1s/@//g; 1s/.*/\L&/' $1.csv

  # Remove the duplicate column 'type'
  if [[ $1 == "drives" ]]; then
     mlr --csv  cut -x -f 33 drives.csv > test.csv
     mv test.csv drives.csv
  fi
  #Extract csv headers
  header=$(head -n 1 $1.csv)

  #Create sql create table from headers
  createTableFromCsvHeaders $header $1

  # Drives has some records with corrupted data (several 'type' field), we remove the additional occurences


  # create the table with psql
  psql "postgresql://postgres:password@localhost:5432/taxi" -c "\i $1.sql"

  # insert the table values

}


# Local only
rm -rf extraction_result; mkdir extraction_result

gzip --decompress --keep $filename
mv $filename_without_extension extraction_result
cd extraction_result

# Only records with the @class field interest us
jq '.records' $filename_without_extension > records
jq 'map(select(has("@class")))' records > class

# Extraction of each data class into its own file
 jq 'map(select(."@class" | contains("Address")))' class > addresses
 jq 'map(select(."@class" | startswith("Drive") and endswith("ve")))' class > drives
 jq 'map(select(."@class" | contains("Fare")))' class > fares
 jq 'map(select(."@class" | contains("TaxiPlanning")))' class > plannings
 jq 'map(select(."@class" | contains("User")))' class > users
 jq 'map(select(."@class" | contains("Driver")))' class > drivers

# Extraction of edge classes for relationships
## Enable to link drives and fares
 jq 'map(select(."@class" | contains("has_fare")))' class > has_fare

## Enable to move data from addresses to drives
 jq 'map(select(."@class" | contains("drive_from")))' class > drive_from #drive_and_address
 jq 'map(select(."@class" | contains("drive_to")))' class > drive_to #drive_and_address

## Enable to link drives and clients (users)
 jq 'map(select(."@class" | contains("has_drive")))' class > has_drive #client_and_drive

## Enable to link fares and drivers
 jq 'map(select(."@class" | contains("has_entry")))' class > has_entry #planning and fare
 jq 'map(select(."@class" | contains("has_owner")))' class > has_owner #planning and driver

###
#psql "postgresql://postgres:password@localhost:5432/taxi" -c "DROP VIEW IF EXISTS view_result;"

### Transform jq records into csv
for entityName in "${entities[@]}"; do
    recordsToCsv $entityName
done

# Migrations
psql "postgresql://postgres:password@localhost:5432/taxi" -c "\i ../migrations/1_fares_drive_rid_from_has_fare.sql"
psql "postgresql://postgres:password@localhost:5432/taxi" -c "\i ../migrations/2_drive_from_to_address_values.sql"
psql "postgresql://postgres:password@localhost:5432/taxi" -c "\i ../migrations/3_drive_client_rid_from_has_drive.sql"
psql "postgresql://postgres:password@localhost:5432/taxi" -c "\i ../migrations/4_fare_driver_from_planning.sql"
#psql "postgresql://postgres:password@localhost:5432/taxi" -c "\i ../migrations/view_result.sql"