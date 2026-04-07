# swapiCache

A small POC for querying the swapi api 


## SQL mappings

- `rps.country` is now represented by `EDW.COUNTRY_RPS`.
- See `sql/edw_country_rps.sql` for the current table DDL.
## SQL table definitions

- `sql/edw.currency_rps.sql`: ClickHouse `EDW.CURRENCY_RPS` DDL (source: user-provided definition for `rps.currency`).
