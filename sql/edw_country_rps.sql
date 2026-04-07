-- Legacy reference: rps.country
-- Current table name: EDW.COUNTRY_RPS
CREATE TABLE EDW.COUNTRY_RPS (
    `SERVER_NAM` String,
    `SID` Decimal(19, 0),
    `CREATED_BY` String,
    `MODIFIED_BY` String,
    `CONTROLLER_SID` Decimal(19, 0),
    `ORIGIN_APPLICATION` String,
    `POST_DATE` Date32,
    `ROW_VERSION` Decimal(10, 0),
    `TENANT_SID` Decimal(19, 0),
    `COUNTRY_CODE` String,
    `COUNTRY_NAME` String,
    `UPDATE_DL_TS` DateTime64(3, 'UTC'),
    `CREATED_DATETIME` String,
    `MODIFIED_DATETIME` String,
    `DL_TS` String,
    `month` Int64,
    `year` Int64,
    `_path` LowCardinality(String),
    `_file` LowCardinality(String),
    `_size` Nullable(UInt64),
    `_time` Nullable(DateTime),
    `toUnixTimestamp(_time)` UInt64
)
ENGINE = SharedReplacingMergeTree('/clickhouse/tables/{uuid}/{shard}', '{replica}', `toUnixTimestamp(_time)`)
PARTITION BY SERVER_NAM
PRIMARY KEY SID
ORDER BY SID
SETTINGS index_granularity = 8192;
