-- ClickHouse conversion of Workato query: F_SALES_TRANSACTION
-- Expected runtime parameters:
--   {startTime} e.g. 2026-01-01 00:00:00
--   {endTime}   e.g. 2026-01-02 00:00:00
--
-- NOTE: This assumes the mapped table names used elsewhere in this repo:
--   rps.document      -> EDW.DOCUMENT_RPS
--   rps.document_item -> EDW.DOCUMENT_ITEM_RPS
--   rps.subsidiary    -> EDW.SUBSIDIARY_RPS
--   rps.country       -> EDW.COUNTRY_RPS
--   rps.currency      -> EDW.CURRENCY_RPS
--   rps.exchange_rate -> EDW.EXCHANGE_RATE_RPS

CREATE OR REPLACE VIEW EDW.F_SALES_TRANSACTION AS
WITH item_raw AS (
    SELECT
        item.DOC_SID,
        item.DESCRIPTION2,
        if(item.ITEM_TYPE = 2, -1 * item.QTY * item.PRICE, item.QTY * item.PRICE) AS PRICE,
        if(item.ITEM_TYPE = 2, -1 * item.QTY, item.QTY) AS QTY,
        if(item.ITEM_TYPE = 2, -1 * item.QTY * item.TAX_AMT, item.QTY * item.TAX_AMT) AS TAX_AMT
    FROM EDW.DOCUMENT_ITEM_RPS AS item
    INNER JOIN EDW.DOCUMENT_RPS AS doc
        ON doc.SID = item.DOC_SID
    WHERE parseDateTimeBestEffortOrNull(doc.POST_DATE) > parseDateTimeBestEffort({startTime})
      AND parseDateTimeBestEffortOrNull(doc.POST_DATE) <= parseDateTimeBestEffort({endTime})
),
itemcount AS (
    SELECT
        a.SID,
        a.SUBSIDIARY_SID,
        a.STORE_CODE,
        a.WORKSTATION_NO,
        b.DESCRIPTION2,
        if(
            a.SUBSIDIARY_SID = 573040816070296815,
            sum(b.PRICE),
            sum(b.PRICE - b.TAX_AMT)
        ) AS LOCAL_PRICE,
        sum(b.QTY) AS QTY_SOLD
    FROM EDW.DOCUMENT_RPS AS a
    INNER JOIN item_raw AS b
        ON a.SID = b.DOC_SID
    WHERE parseDateTimeBestEffortOrNull(a.POST_DATE) > parseDateTimeBestEffort({startTime})
      AND parseDateTimeBestEffortOrNull(a.POST_DATE) <= parseDateTimeBestEffort({endTime})
    GROUP BY
        a.SID,
        a.SUBSIDIARY_SID,
        a.STORE_CODE,
        a.WORKSTATION_NO,
        b.DESCRIPTION2
)
SELECT
    d.SID AS DOCUMENT_SID,
    co.COUNTRY_CODE,
    d.STORE_CODE,
    ic.DESCRIPTION2 AS LOT_NUMBER,
    d.WORKSTATION_NO AS REGISTER_NO,
    d.CASHIER_LOGIN_NAME,
    formatDateTime(parseDateTimeBestEffortOrNull(d.INVC_POST_DATE), '%Y-%m-%d %H:%M:%S') AS INVC_POST_DATE,
    ic.QTY_SOLD,
    ic.LOCAL_PRICE,
    cu.ALPHABETIC_CODE,
    sum(ic.LOCAL_PRICE * ex.TAKE_RATE) AS USD_PRICE
FROM EDW.DOCUMENT_RPS AS d
INNER JOIN itemcount AS ic
    ON d.SID = ic.SID
   AND d.WORKSTATION_NO = ic.WORKSTATION_NO
   AND d.SUBSIDIARY_SID = ic.SUBSIDIARY_SID
   AND d.STORE_CODE = ic.STORE_CODE
INNER JOIN EDW.SUBSIDIARY_RPS AS su
    ON d.SUBSIDIARY_SID = su.SID
INNER JOIN EDW.COUNTRY_RPS AS co
    ON su.COUNTRY_SID = co.SID
INNER JOIN EDW.CURRENCY_RPS AS cu
    ON su.BASE_CURRENCY_SID = cu.SID
INNER JOIN EDW.EXCHANGE_RATE_RPS AS ex
    ON ex.BASE_CURRENCY_SID = cu.SID
WHERE parseDateTimeBestEffortOrNull(d.POST_DATE) > parseDateTimeBestEffort({startTime})
  AND parseDateTimeBestEffortOrNull(d.POST_DATE) <= parseDateTimeBestEffort({endTime})
  AND ex.CURRENCY_SID = (
      SELECT c1.SID
      FROM EDW.CURRENCY_RPS AS c1
      WHERE c1.ALPHABETIC_CODE = 'USD'
      LIMIT 1
  )
  AND parseDateTimeBestEffortOrNull(ex.EFFECTIVE_DATE) = (
      SELECT max(parseDateTimeBestEffortOrNull(r1.EFFECTIVE_DATE))
      FROM EDW.EXCHANGE_RATE_RPS AS r1
      WHERE r1.BASE_CURRENCY_SID = cu.SID
        AND r1.CURRENCY_SID = ex.CURRENCY_SID
        AND parseDateTimeBestEffortOrNull(r1.EFFECTIVE_DATE) <= parseDateTimeBestEffortOrNull(d.INVC_POST_DATE)
  )
GROUP BY
    d.SID,
    co.COUNTRY_CODE,
    d.STORE_CODE,
    ic.DESCRIPTION2,
    d.WORKSTATION_NO,
    d.CASHIER_LOGIN_NAME,
    d.INVC_POST_DATE,
    ic.QTY_SOLD,
    ic.LOCAL_PRICE,
    cu.ALPHABETIC_CODE;
