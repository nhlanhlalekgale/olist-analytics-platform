#!/bin/bash
# Olist Analytics Platform — Daily ETL Pipeline
# Author: Nhlanhla Lekgale
# Schedule: Daily at 3:00 AM via cron

set -e

BUCKET="s3://lekgale-data-s3-retailer"
ATHENA_OUTPUT="${BUCKET}/athena-results/"
REGION="af-south-1"
WORKGROUP="primary"

echo "=== Olist Pipeline Started: $(date) ==="

run_athena_query() {
    local query="$1"
    local description="$2"
    echo "Running: ${description}..."
    
    QUERY_ID=$(aws athena start-query-execution \
        --query-string "${query}" \
        --result-configuration "OutputLocation=${ATHENA_OUTPUT}" \
        --work-group ${WORKGROUP} \
        --region ${REGION} \
        --query 'QueryExecutionId' \
        --output text)
    
    while true; do
        STATUS=$(aws athena get-query-execution \
            --query-execution-id ${QUERY_ID} \
            --region ${REGION} \
            --query 'QueryExecution.Status.State' \
            --output text)
        
        if [ "${STATUS}" == "SUCCEEDED" ]; then
            echo "  ✓ ${description} completed"
            break
        elif [ "${STATUS}" == "FAILED" ] || [ "${STATUS}" == "CANCELLED" ]; then
            echo "  ✗ ${description} failed: ${STATUS}"
            exit 1
        fi
        sleep 5
    done
}

# Core tables
run_athena_query "CREATE DATABASE IF NOT EXISTS olist_analytics_processed;" "Create database"
run_athena_query "CREATE TABLE IF NOT EXISTS olist_analytics_processed.orders_clean WITH (format='PARQUET', external_location='${BUCKET}/processed/orders_clean/', partitioned_by=ARRAY['year_month']) AS SELECT order_id, customer_id, order_status, TRY(DATE_PARSE(order_purchase_timestamp, '%Y-%m-%d %H:%i:%s')) AS purchase_timestamp, TRY(DATE_PARSE(order_approved_at, '%Y-%m-%d %H:%i:%s')) AS approved_at, TRY(DATE_PARSE(order_delivered_carrier_date, '%Y-%m-%d %H:%i:%s')) AS carrier_date, TRY(DATE_PARSE(order_delivered_customer_date, '%Y-%m-%d %H:%i:%s')) AS delivered_date, TRY(DATE_PARSE(order_estimated_delivery_date, '%Y-%m-%d %H:%i:%s')) AS estimated_delivery_date, DATE_DIFF('day', TRY(DATE_PARSE(order_purchase_timestamp, '%Y-%m-%d %H:%i:%s')), TRY(DATE_PARSE(order_delivered_customer_date, '%Y-%m-%d %H:%i:%s'))) AS actual_delivery_days, DATE_DIFF('day', TRY(DATE_PARSE(order_purchase_timestamp, '%Y-%m-%d %H:%i:%s')), TRY(DATE_PARSE(order_estimated_delivery_date, '%Y-%m-%d %H:%i:%s'))) AS estimated_delivery_days, DATE_FORMAT(TRY(DATE_PARSE(order_purchase_timestamp, '%Y-%m-%d %H:%i:%s')), '%Y-%m') AS year_month FROM olist_analytics_raw.orders" "Refresh orders_clean"

echo "=== Pipeline Completed: $(date) ==="
