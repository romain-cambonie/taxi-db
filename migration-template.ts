import { MigrationBuilder } from "node-pg-migrate";

export const up = (pgm: MigrationBuilder) => {
    // you can pass this in async IF you need it
};

export const down = (pgm: MigrationBuilder) => {};