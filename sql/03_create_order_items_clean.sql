CREATE TABLE olist_analytics_processed.order_items_clean
WITH (
    format = 'PARQUET',
    external_location = 's3://lekgale-data-s3-retailer/processed/order_items_clean/',
    partitioned_by = ARRAY['year_month']
) AS
SELECT 
    oi.order_id,
    oi.order_item_id,
    oi.product_id,
    oi.seller_id,
    CAST(oi.price AS DOUBLE) AS price,
    CAST(oi.freight_value AS DOUBLE) AS freight_value,
    CAST(oi.price AS DOUBLE) + CAST(oi.freight_value AS DOUBLE) AS total_item_value,
    oi.shipping_limit_date,
    o.purchase_timestamp,
    o.year_month
FROM olist_analytics_raw.order_items oi
LEFT JOIN olist_analytics_processed.orders_clean o
    ON oi.order_id = o.order_id;
