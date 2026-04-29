
-- 1.1 all subscribers
SELECT  c.customer_id,
        c.name,
        c.city,
        c.signup_date
FROM    customers  c
JOIN    tariffs    t ON t.tariff_id = c.tariff_id
WHERE   t.name = N'Kobiye Destek'
ORDER BY c.signup_date;


-- 1.2 newest Kobiye Destek subscriber

SELECT  c.customer_id,
        c.name,
        c.city,
        c.signup_date
FROM    customers  c
JOIN    tariffs    t ON t.tariff_id = c.tariff_id
WHERE   t.name = N'Kobiye Destek'
  AND   c.signup_date = (
            SELECT MAX(c2.signup_date)
            FROM   customers c2
            JOIN   tariffs   t2 ON t2.tariff_id = c2.tariff_id
            WHERE  t2.name = N'Kobiye Destek'
        );


-- 2.1 subscriber count per tariff

SELECT  t.name             AS tariff_name,
        COUNT(c.customer_id) AS subscriber_count,
        ROUND(
            COUNT(c.customer_id) * 100
            / SUM(COUNT(c.customer_id)) OVER ()
        , 1)               AS pct
FROM    tariffs   t
LEFT JOIN customers c ON c.tariff_id = t.tariff_id
GROUP BY t.tariff_id, t.name
ORDER BY subscriber_count DESC;

-- 3.1  earliest customers
SELECT  customer_id,
        name,
        city,
        signup_date
FROM    customers
WHERE   signup_date = (
            SELECT MIN(signup_date) FROM customers
        )
ORDER BY customer_id;

-- 3.2 city distribution of earliest customers

WITH earliest AS (
    SELECT city
    FROM   customers
    WHERE  signup_date = (SELECT MIN(signup_date) FROM customers)
)
SELECT  city,
        COUNT(*) AS customer_count
FROM    earliest
GROUP BY city
ORDER BY customer_count DESC;


-- 4.1  customers without a monthly_stats row

SELECT  c.customer_id,
        c.name,
        c.city,
        t.name AS tariff_name
FROM    customers  c
JOIN    tariffs    t ON t.tariff_id = c.tariff_id
WHERE  NOT EXISTS (
    SELECT 1
    FROM   monthly_stats ms
    WHERE  ms.customer_id = c.customer_id
)
ORDER BY c.customer_id;

-- 4.2 city distribution of missing customers

SELECT  c.city,
        COUNT(*) AS missing_count
FROM    customers c
WHERE  NOT EXISTS (
    SELECT 1
    FROM   monthly_stats ms
    WHERE  ms.customer_id = c.customer_id
)
GROUP BY c.city
ORDER BY missing_count DESC;


-- 5.1  customers who used ≥ 75 % of their data limit
SELECT  c.customer_id,
        c.name,
        c.city,
        t.name                               AS tariff_name,
        t.data_limit,
        ms.data_usage,
        ROUND(ms.data_usage / t.data_limit * 100, 1) AS data_pct_used
FROM    customers    c
JOIN    tariffs      t  ON t.tariff_id  = c.tariff_id
JOIN    monthly_stats ms ON ms.customer_id = c.customer_id
WHERE   t.data_limit > 0
  AND   ms.data_usage >= t.data_limit * 0.75
ORDER BY data_pct_used DESC;


-- 5.2 — customers who exhausted ALL limits

SELECT  c.customer_id,
        c.name,
        c.city,
        t.name AS tariff_name
FROM    customers     c
JOIN    tariffs       t  ON t.tariff_id   = c.tariff_id
JOIN    monthly_stats ms ON ms.customer_id = c.customer_id
WHERE   (t.data_limit   = 0 OR ms.data_usage   >= t.data_limit)
  AND   (t.minute_limit = 0 OR ms.minute_usage >= t.minute_limit)
  AND   (t.sms_limit    = 0 OR ms.sms_usage    >= t.sms_limit)
ORDER BY c.customer_id;


-- 6.1  customers with unpaid fees

SELECT  c.customer_id,
        c.name,
        c.city,
        t.name         AS tariff_name,
        t.monthly_fee,
        ms.payment_status
FROM    customers     c
JOIN    tariffs       t  ON t.tariff_id   = c.tariff_id
JOIN    monthly_stats ms ON ms.customer_id = c.customer_id
WHERE   ms.payment_status <> 'PAID'
ORDER BY t.monthly_fee DESC;

-- 6.2  payment status distribution across tariffs

SELECT  t.name            AS tariff_name,
        ms.payment_status,
        COUNT(*)           AS customer_count
FROM    monthly_stats ms
JOIN    customers     c  ON c.customer_id = ms.customer_id
JOIN    tariffs       t  ON t.tariff_id   = c.tariff_id
GROUP BY t.name, ms.payment_status
ORDER BY t.name, ms.payment_status;


