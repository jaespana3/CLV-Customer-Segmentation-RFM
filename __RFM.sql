WITH
t1 AS (
  SELECT
    CustomerID,
    Country,
    MAX(CAST(InvoiceDate AS DATE)) AS last_purchase_date,
    COUNT(DISTINCT InvoiceNo) AS frequency,
    SUM(UnitPrice * Quantity) AS monetary,
    DATE_DIFF(DATE('2011-12-01'), MAX(CAST(InvoiceDate AS DATE)), DAY) AS recency
  FROM
    `tc-da-1.turing_data_analytics.rfm`
  WHERE
    CAST(InvoiceDate AS DATE) BETWEEN '2010-12-01' AND '2011-12-01'
  GROUP BY
    CustomerID, Country
),
t2 AS (
  SELECT
    a.*,
    b.percentiles[offset(25)] AS m25,
    b.percentiles[offset(50)] AS m50,
    b.percentiles[offset(75)] AS m75,
    b.percentiles[offset(100)] AS m100,
    c.percentiles[offset(25)] AS f25,
    c.percentiles[offset(50)] AS f50,
    c.percentiles[offset(75)] AS f75,
    c.percentiles[offset(100)] AS f100,
    d.percentiles[offset(25)] AS r25,
    d.percentiles[offset(50)] AS r50,
    d.percentiles[offset(75)] AS r75,
    d.percentiles[offset(100)] AS r100
  FROM
    t1 a,
    (SELECT APPROX_QUANTILES(monetary, 100) percentiles FROM t1) b,
    (SELECT APPROX_QUANTILES(frequency, 100) percentiles FROM t1) c,
    (SELECT APPROX_QUANTILES(recency, 100) percentiles FROM t1) d
),
t3 AS (
  SELECT *,
    CASE
      WHEN monetary <= m25 THEN 1
      WHEN monetary <= m50 AND monetary > m25 THEN 2
      WHEN monetary <= m75 AND monetary > m50 THEN 3
      WHEN monetary > m75 THEN 4
    END AS m_score,

    CASE
      WHEN frequency <= f25 THEN 1
      WHEN frequency <= f50 AND frequency > f25 THEN 2
      WHEN frequency <= f75 AND frequency > f50 THEN 3
      WHEN frequency > f75 THEN 4
    END AS f_score,

    CASE
      WHEN recency <= r25 THEN 4
      WHEN recency <= r50 AND recency > r25 THEN 3
      WHEN recency <= r75 AND recency > r50 THEN 2
      WHEN recency > r75 THEN 1
    END AS r_score
  FROM t2
),
t4 AS (
  SELECT
    CustomerID,
    Country,
    recency,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,

    CASE
      WHEN r_score = 4 AND f_score = 4 AND m_score = 4 THEN 'Best Customers'
      WHEN r_score >= 3 AND f_score >= 3 THEN 'Loyal Customers'
      WHEN m_score = 4 THEN 'Big Spenders'
      WHEN r_score = 1 AND f_score <= 2 AND m_score <= 2 THEN 'Lost Customers'
      ELSE 'Other'
    END AS rfm_segment
  FROM t3
)
SELECT * FROM t4;
