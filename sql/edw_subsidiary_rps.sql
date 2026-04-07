-- Source table: rps.subsidiary
-- Target table: EDW.SUBSIDIARY
CREATE TABLE EDW.SUBSIDIARY_RPS
(
    `SERVER_NAM` Nullable(String),
    `SID` Nullable(Int64),
    `CREATED_BY` Nullable(String),
    `CREATED_DATETIME` Nullable(String),
    `MODIFIED_BY` Nullable(String),
    `MODIFIED_DATETIME` Nullable(String),
    `CONTROLLER_SID` Nullable(Int64),
    `ORIGIN_APPLICATION` Nullable(String),
    `POST_DATE` Date,
    `ROW_VERSION` Nullable(Int64) DEFAULT 1,
    `TENANT_SID` Nullable(Int64),
    `SBS_NO` Nullable(Int64),
    `SBS_NAME` Nullable(String),
    `STYLE_DEF` Nullable(Int64) DEFAULT 1,
    `BASE_CURRENCY_SID` Nullable(Int64),
    `ACTIVE_PRICE_LVL_SID` Nullable(Int64),
    `ACTIVE_SEASON_SID` Nullable(Int64),
    `DOC_NO_PREFIX` Nullable(String),
    `CALENDAR_SID` Nullable(String),
    `STATUS` Nullable(Int64),
    `MASTER` Nullable(Int64) DEFAULT 0,
    `DIM_UNITS` Nullable(Int64) DEFAULT 0,
    `WEIGHT_UNITS` Nullable(Int64) DEFAULT 0,
    `LANGUAGE_SID` Nullable(Int64),
    `COUNTRY_SID` Nullable(Int64),
    `PREFERENCES` Nullable(String),
    `ACTIVE` Nullable(Int64) DEFAULT 1,
    `AUTO_SEASON` Nullable(Int64) DEFAULT 0,
    `SEASON_APPLIED_DATETIME` Nullable(String),
    `FOREIGN_CURRENCY_SID` Nullable(Int64),
    `DL_TS` Nullable(String),
    `UPDATE_DL_TS` Nullable(String)
)
ENGINE = SharedMergeTree('/clickhouse/tables/{uuid}/{shard}', '{replica}')
ORDER BY POST_DATE
SETTINGS index_granularity = 8192;
