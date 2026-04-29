
-- 1. TARIFFS

CREATE TABLE tariffs (
    tariff_id       NUMBER(6)       NOT NULL,
    name            NVARCHAR2(100)  NOT NULL,          
    monthly_fee     NUMBER(10)   NOT NULL,
    data_limit      NUMBER(10)      DEFAULT 0 NOT NULL,
    minute_limit    NUMBER(10)      DEFAULT 0 NOT NULL, 
    sms_limit       NUMBER(10)      DEFAULT 0 NOT NULL, 
    --
    CONSTRAINT pk_tariffs PRIMARY KEY (tariff_id),
    CONSTRAINT chk_tariffs_fee     CHECK (monthly_fee  >= 0),
    CONSTRAINT chk_tariffs_data    CHECK (data_limit   >= 0),
    CONSTRAINT chk_tariffs_min     CHECK (minute_limit >= 0),
    CONSTRAINT chk_tariffs_sms     CHECK (sms_limit    >= 0)
);

-- 2. CUSTOMERS
CREATE TABLE customers (
    customer_id     NUMBER(10)      NOT NULL,
    name            NVARCHAR2(150)  NOT NULL,
    city            NVARCHAR2(100),
    signup_date     DATE,
    tariff_id       NUMBER(6)       NOT NULL,
    CONSTRAINT pk_customers PRIMARY KEY (customer_id),
    CONSTRAINT fk_customers_tariff FOREIGN KEY (tariff_id) REFERENCES tariffs (tariff_id)
);

-- 3. MONTHLY_STATS

CREATE TABLE monthly_stats (
    id              NUMBER(12)      NOT NULL,
    customer_id     NUMBER(10)      NOT NULL,
    data_usage      FLOAT           DEFAULT 0 NOT NULL, 
    minute_usage    NUMBER(10)      DEFAULT 0 NOT NULL, 
    sms_usage       NUMBER(10)      DEFAULT 0 NOT NULL,
    payment_status  VARCHAR2(20)    NOT NULL,
    --
    CONSTRAINT pk_monthly_stats         PRIMARY KEY (id),
    CONSTRAINT fk_mstats_customer       FOREIGN KEY (customer_id)
                                        REFERENCES customers (customer_id),
    CONSTRAINT chk_mstats_data          CHECK (data_usage   >= 0),
    CONSTRAINT chk_mstats_minutes       CHECK (minute_usage >= 0),
    CONSTRAINT chk_mstats_sms          CHECK (sms_usage    >= 0),
    CONSTRAINT chk_mstats_pay_status    CHECK (payment_status IN (
                                            'PAID', 'UNPAID', 'LATE'))
);


-- Customers: look up by tariff 
CREATE INDEX idx_customers_tariff_id
    ON customers (tariff_id);
 
-- Monthly stats: look up by customer 
CREATE INDEX idx_mstats_customer_id
    ON monthly_stats (customer_id);
 
-- Monthly stats: filter / report by payment status
CREATE INDEX idx_mstats_payment_status
    ON monthly_stats (payment_status);

