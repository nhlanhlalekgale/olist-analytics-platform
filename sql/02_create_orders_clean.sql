CREATE TABLE olist_analytics_processed.orders_clean
WITH (
    format = 'PARQUET',
    external_location = 's3://lekgale-data-s3-retailer/processed/orders_clean/',
    partitioned_by = ARRAY['year_month']
) AS
SELECT 
    order_id,
    customer_id,
    order_status,
    TRY(DATE_PARSE(order_purchase_timestamp, '%Y-%m-%d %H:%i:%s')) AS purchase_timestamp,
    TRY(DATE_PARSE(order_approved_at, '%Y-%m-%d %H:%i:%s')) AS approved_at,
    TRY(DATE_PARSE(order_delivered_carrier_date, '%Y-%m-%d %H:%i:%s')) AS carrier_date,
    TRY(DATE_PARSE(order_delivered_customer_date, '%Y-%m-%d %H:%i:%s')) AS delivered_date,
    TRY(DATE_PARSE(order_estimated_delivery_date, '%Y-%m-%d %H:%i:%s')) AS estimated_delivery_date,
    DATE_DIFF('day', TRY(DATE_PARSE(order_purchase_timestamp, '%Y-%m-%d %H:%i:%s')), TRY(DATE_PARSE(order_delivered_customer_date, '%Y-%m-%d %H:%i:%s'))) AS actual_delivery_days,
    DATE_DIFF('day', TRY(DATE_PARSE(order_purchase_timestamp, '%Y-%m-%d %H:%i:%s')), TRY(DATE_PARSE(order_estimated_delivery_date, '%Y-%m-%d %H:%i:%s'))) AS estimated_delivery_days,
    DATE_FORMAT(TRY(DATE_PARSE(order_purchase_timestamp, '%Y-%m-%d %H:%i:%s')), '%Y-%m') AS year_month
FROM olist_analytics_raw.orders;
