import { MigrationBuilder } from "node-pg-migrate";
import * as fs from "fs";

type OrientDriver =   {
    "@type": string;
    "@rid": string;
    "@version": number;
    "@class": string;
    "in_has_owner": string[];
    "email": string;
    "password": string;
    "active": boolean;
    "created_at": string;
    "updated_at": string;
    "out_user_role": string[];
    "firstname": string;
    "lastname": string;
    "phone": string;
    "identity": string;
    "out_owned_by": string[];
    "remember_token": string;
    "deviceId": string;
    "latitude": number;
    "longitude": number;
    "@fieldTypes": string;
    "work": boolean;
    "standard": boolean;
    "standard_weight": number;
    "medical_weight": number;
};

type PgDriver =   {
    "email": string;
    "username": string;
    "phone": string;
};

const toPgDriver = (orientDriver: OrientDriver): PgDriver => ({
    "email": orientDriver.email,
    "username": orientDriver.firstname,
    "phone": orientDriver.phone ?? null
});

const pgDriverKeysToCommaSeparatedString = (driver: PgDriver): string => Object.keys(driver).join(',')

const pgDriverValuesToCommaSeparatedString = (driver: PgDriver): string => Object.values(driver).join(',')



export const up = (pgm: MigrationBuilder) => {
    pgm.createTable('drivers', {
        id: 'id',
        email: { type: 'string', notNull: true },
        firstname: { type: 'string', notNull: true },
    });

    const orientDrivers: OrientDriver[] = JSON.parse(fs.readFileSync('/app/drivers', 'utf8'));
    const pgDrivers: PgDriver[] = orientDrivers.map(toPgDriver);
    pgDrivers.forEach((pgDriver: PgDriver) => {
        const columnsAsCommaSeparatedString: string = pgDriverKeysToCommaSeparatedString(pgDriver);
        const valuesAsCommaSeparatedString: string = pgDriverValuesToCommaSeparatedString(pgDriver);
        pgm.sql(`INSERT INTO drivers (${columnsAsCommaSeparatedString}) VALUES (${valuesAsCommaSeparatedString})`);
    });
};

export const down = (pgm: MigrationBuilder) => {
    pgm.dropTable('drivers');
};