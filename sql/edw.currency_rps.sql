CREATE TABLE EDW.CURRENCY_RPS (
    `SERVER_NAM` String,
    `SID` Decimal(19, 0),
    `CREATED_BY` String,
    `MODIFIED_BY` String,
    `CONTROLLER_SID` Decimal(19, 0),
    `ORIGIN_APPLICATION` String,
    `ROW_VERSION` Decimal(10, 0),
    `TENANT_SID` Decimal(19, 0),
    `CURRENCY_NAME` String,
    `DISCREPANCY` Decimal(16, 4),
    `ROUNDING` Decimal(6, 2),
    `DECIMALS` Decimal(3, 0),
    `ACTIVE` Decimal(1, 0),
    `ALPHABETIC_CODE` String,
    `NUMERIC_CODE` Decimal(3, 0),
    `MINOR_UNIT` Decimal(3, 0),
    `SYMBOL` String,
    `LTY_RATE` Decimal(16, 4),
    `INTERNAL_FLAG` Decimal(1, 0),
    `POST_DATE` String,
    `MODIFIED_DATETIME` String,
    `CREATED_DATETIME` String,
    `UPDATE_DL_TS` String,
    `DL_TS` String,
    `_path` LowCardinality(String),
    `_file` LowCardinality(String),
    `_size` Nullable(UInt64),
    `_time` Nullable(DateTime),
    `LAST_TIME_UINT64 toUnixTimestamp(DL_TS)` UInt64
)
ENGINE = SharedReplacingMergeTree(
    '/clickhouse/tables/{uuid}/{shard}',
    '{replica}',
    `LAST_TIME_UINT64 toUnixTimestamp(DL_TS)`
)
PARTITION BY SERVER_NAM
PRIMARY KEY SID
ORDER BY SID
SETTINGS index_granularity = 8192;
