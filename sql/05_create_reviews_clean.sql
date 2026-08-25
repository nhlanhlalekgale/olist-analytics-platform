CREATE TABLE olist_analytics_processed.reviews_clean
WITH (
    format = 'PARQUET',
    external_location = 's3://lekgale-data-s3-retailer/processed/reviews_clean/',
    partitioned_by = ARRAY['year_month']
) AS
SELECT 
    r.review_id,
    r.order_id,
    r.review_score,
    r.review_comment_title,
    r.review_comment_message,
    TRY(DATE_PARSE(r.review_creation_date, '%Y-%m-%d %H:%i:%s')) AS review_created_at,
    TRY(DATE_PARSE(r.review_answer_timestamp, '%Y-%m-%d %H:%i:%s')) AS review_answered_at,
    CASE WHEN r.review_comment_message IS NOT NULL AND LENGTH(TRIM(r.review_comment_message)) > 0 THEN 1 ELSE 0 END AS has_review_text,
    CASE WHEN r.review_comment_title IS NOT NULL AND LENGTH(TRIM(r.review_comment_title)) > 0 THEN 1 ELSE 0 END AS has_review_title,
    CASE WHEN r.review_score >= 4 THEN 'positive' WHEN r.review_score = 3 THEN 'neutral' ELSE 'negative' END AS sentiment_bucket,
    o.year_month
FROM olist_analytics_raw.reviews r
LEFT JOIN olist_analytics_processed.orders_clean o
    ON r.order_id = o.order_id;
