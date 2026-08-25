Repository Structure
plain
olist-analytics-platform/
├── README.md                          # Project overview
├── PROJECT_INSIGHT.md                 # Deep-dive business analysis
├── DEPLOYMENT.md                      # This file
│
├── sql/                               # 7 core Athena CTAS queries
│   ├── 01_create_database.sql
│   ├── 02_create_orders_clean.sql
│   ├── 03_create_order_items_clean.sql
│   ├── 04_create_customers_clean.sql
│   ├── 05_create_reviews_clean.sql
│   ├── 06_create_products_enriched.sql
│   └── 07_create_orders_enriched_v2.sql
│
├── scripts/                           # Daily ETL automation
│   └── refresh_pipeline.sh
│
├── models/                            # XGBoost churn predictor
│   └── churn_prediction.py
│
├── dashboards/                        # Executive visualizations
│   ├── olist_executive_dashboard.png
│   ├── olist_final_executive_dashboard.png
│   └── olist_churn_model_dashboard.png
│
└── data/                              # Sample predictions
    └── churn_predictions_sample.csv
Quick Start
Prerequisites
AWS Account with S3, Athena, Glue access
AWS CLI configured (aws configure)
Python 3.8+ with pandas, matplotlib, scikit-learn
Step 1: Deploy Raw Data
bash
aws s3 cp olist_raw_data/ s3://your-bucket/raw/ --recursive
Step 2: Create Athena Database
bash
aws athena start-query-execution \
    --query-string "CREATE DATABASE IF NOT EXISTS olist_analytics_raw;" \
    --result-configuration "OutputLocation=s3://your-bucket/athena-results/"
Step 3: Create Glue Crawler (One-Time)
bash
aws glue create-crawler \
    --name olist-raw-crawler \
    --role AWSGlueServiceRole-olist \
    --database-name olist_analytics_raw \
    --targets '{"S3Targets": [{"Path": "s3://your-bucket/raw/"}]}' \
    --schedule 'cron(0 2 * * ? *)'
Step 4: Run Pipeline (Manual First Run)
bash
chmod +x scripts/refresh_pipeline.sh
./scripts/refresh_pipeline.sh
Step 5: Schedule Daily Refresh
bash
crontab -e
# Add:
0 3 * * * /path/to/olist-analytics-platform/scripts/refresh_pipeline.sh >> /var/log/olist_pipeline.log 2>&1
Step 6: Run ML Model
bash
cd models
python churn_prediction.py
Environment Variables
Create .env file:
plain
S3_BUCKET=lekgale-data-s3-retailer
ATHENA_OUTPUT=s3://lekgale-data-s3-retailer/athena-results/
AWS_REGION=af-south-1
WORKGROUP=primary
Cost Estimate (Monthly)
Table
Service	Usage	Cost
S3 Storage	2GB Parquet	~$0.05
Athena Queries	100 queries/day	~$1.50
Glue Crawler	Daily run	~$0.50
Total		~$2.00/month
Monitoring
Check Pipeline Health
sql
-- Run daily sanity check
SELECT 'orders_clean' AS table_name, COUNT(*) AS row_count
FROM olist_analytics_processed.orders_clean
UNION ALL
SELECT 'orders_enriched_v2', COUNT(*)
FROM olist_analytics_processed.orders_enriched_v2
UNION ALL
SELECT 'churn_risk', COUNT(*)
FROM olist_analytics_processed.churn_risk;
Alert on Data Quality
sql
-- Flag if partition is missing
SELECT year_month, COUNT(*)
FROM olist_analytics_processed.orders_clean
GROUP BY year_month
ORDER BY year_month DESC
LIMIT 5;
Troubleshooting
Table
Issue	Cause	Fix
TABLE_ALREADY_EXISTS	S3 folder has old files	Use _v2 suffix or delete S3 folder
COLUMN_NOT_FOUND	Column name typo	Check with DESCRIBE table_name
FUNCTION_NOT_FOUND	Wrong function name	Use APPROX_PERCENTILE not PERCENTILE_APPROX
NULL partition key	TRY(DATE_PARSE) returned NULL	Filter with WHERE year_month IS NOT NULL
Contributing
Fork the repository
Create feature branch: git checkout -b feature/new-ml-model
Add SQL to sql/ folder
Update refresh_pipeline.sh if needed
Submit PR with query results screenshot
License
MIT License — Free for commercial and educational use.
Contact
Nhlanhla Lekgale
