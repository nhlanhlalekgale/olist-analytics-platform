CREATE TABLE olist_analytics_processed.orders_enriched_v2
WITH (
    format = 'PARQUET',
    external_location = 's3://lekgale-data-s3-retailer/processed/orders_enriched_v2/',
    partitioned_by = ARRAY['year_month']
) AS
SELECT 
    oe.order_id,
    oe.customer_id,
    oe.customer_unique_id,
    oe.order_status,
    oe.purchase_timestamp,
    oe.approved_at,
    oe.carrier_date,
    oe.delivered_date,
    oe.estimated_delivery_date,
    oe.actual_delivery_days,
    oe.estimated_delivery_days,
    oe.delivery_vs_estimate_days,
    oe.on_time_flag,
    oe.order_revenue,
    oe.order_freight,
    oe.order_total_value,
    oe.item_count,
    oe.unique_products,
    oe.unique_sellers,
    oe.customer_city,
    oe.customer_state,
    oe.customer_lifetime_orders,
    AVG(r.review_score) AS avg_review_score,
    COUNT(r.review_id) AS review_count,
    MAX(CASE WHEN r.sentiment_bucket = 'positive' THEN 1 ELSE 0 END) AS has_positive_review,
    MAX(CASE WHEN r.sentiment_bucket = 'negative' THEN 1 ELSE 0 END) AS has_negative_review,
    MAX(pe.category_english) AS primary_category,
    MAX(pe.product_photos_qty) AS primary_product_photos,
    COUNT(DISTINCT oi.seller_id) AS seller_count,
    oe.year_month
FROM olist_analytics_processed.orders_enriched oe
LEFT JOIN olist_analytics_processed.reviews_clean r
    ON oe.order_id = r.order_id
LEFT JOIN olist_analytics_processed.order_items_clean oi
    ON oe.order_id = oi.order_id
LEFT JOIN olist_analytics_processed.products_enriched pe
    ON oi.product_id = pe.product_id
GROUP BY 
    oe.order_id, oe.customer_id, oe.customer_unique_id, oe.order_status,
    oe.purchase_timestamp, oe.approved_at, oe.carrier_date,
    oe.delivered_date, oe.estimated_delivery_date,
    oe.delivery_vs_estimate_days, oe.on_time_flag,
    oe.order_revenue, oe.order_freight, oe.order_total_value,
    oe.item_count, oe.unique_products, oe.unique_sellers,
    oe.customer_city, oe.customer_state, oe.customer_lifetime_orders,
    oe.year_month;
