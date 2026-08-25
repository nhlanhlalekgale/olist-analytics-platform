CREATE TABLE olist_analytics_processed.customers_clean
WITH (
    format = 'PARQUET',
    external_location = 's3://lekgale-data-s3-retailer/processed/customers_clean/'
) AS
SELECT 
    c.customer_unique_id,
    c.customer_zip_code_prefix,
    c.customer_city,
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    MIN(o.purchase_timestamp) AS first_order,
    MAX(o.purchase_timestamp) AS last_order
FROM olist_analytics_raw.customers c
LEFT JOIN olist_analytics_processed.orders_clean o
    ON c.customer_id = o.customer_id
GROUP BY 
    c.customer_unique_id,
    c.customer_zip_code_prefix,
    c.customer_city,
    c.customer_state;
