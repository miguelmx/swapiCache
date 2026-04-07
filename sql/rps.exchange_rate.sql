CREATE TABLE EDW.EXCHANGE_RATE_RPS (
    `SERVER_NAM` String,
    `SID` Decimal(19, 0),
    `CREATED_BY` String,
    `MODIFIED_BY` String,
    `CONTROLLER_SID` Decimal(19, 0),
    `ORIGIN_APPLICATION` String,
    `ROW_VERSION` Decimal(10, 0),
    `TENANT_SID` Decimal(19, 0),
    `CURRENCY_SID` Decimal(19, 0),
    `BASE_CURRENCY_SID` Decimal(19, 0),
    `TAKE_RATE` Decimal(20, 8),
    `GIVE_RATE` Decimal(20, 8),
    `COST_RATE` Decimal(20, 8),
    `OFFICIAL_RATE` Decimal(20, 8),
    `CREATED_DATETIME` String,
    `MODIFIED_DATETIME` String,
    `POST_DATE` String,
    `EFFECTIVE_DATE` String,
    `DL_TS` String,
    `UPDATE_DL_TS` String,
    `month` Int64,
    `year` Int64,
    `_path` LowCardinality(String),
    `_file` LowCardinality(String),
    `_size` Nullable(UInt64),
    `_time` Nullable(DateTime),
    `toUnixTimestamp(DL_TS)` UInt64
)
ENGINE = SharedReplacingMergeTree('/clickhouse/tables/{uuid}/{shard}', '{replica}', `toUnixTimestamp(DL_TS)`)
PARTITION BY SERVER_NAM
PRIMARY KEY SID
ORDER BY SID
SETTINGS index_granularity = 8192;
