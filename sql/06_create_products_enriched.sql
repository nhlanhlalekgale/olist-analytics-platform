CREATE TABLE olist_analytics_processed.products_enriched
WITH (
    format = 'PARQUET',
    external_location = 's3://lekgale-data-s3-retailer/processed/products_enriched/'
) AS
SELECT 
    product_id,
    product_category_name,
    product_category_name AS category_english,
    product_name_length,
    product_description_length,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm,
    product_length_cm * product_height_cm * product_width_cm AS volume_cm3
FROM olist_analytics_raw.products;
