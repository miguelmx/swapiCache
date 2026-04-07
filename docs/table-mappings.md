# Table Mapping Notes

## RPS Document Table

The previous `rps.document` source should now be treated as `EDW.DOCUMENT_RPS`.

When building queries, migrations, or data model references, use:

- **Old name:** `rps.document`
- **New name:** `EDW.DOCUMENT_RPS`

Primary structural expectations from the provided DDL:

- Engine: `SharedReplacingMergeTree(..., UPDATE_DL_TS)`
- Partition key: `SERVER_NAM`
- Primary key / order key: `SID`
- Version column: `UPDATE_DL_TS`
