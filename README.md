**##Olist Marketplace Analytics & ML Platform**##
From Raw CSVs to Production Intelligence
https://aws.amazon.com
https://python.org
https://xgboost.ai
LICENSE

**Table of Contents**

Problem Statement
Tools & Technologies
ETL Pipeline & Data Architecture
Data Preprocessing
Key Business Insights
Strategic Recommendations
Machine Learning
Repository Structure
Deployment Guide
Next Steps

**1. Problem Statement**
Olist connects 100,000+ small Brazilian businesses to online sales channels. Despite strong top-line growth, the platform faces a critical retention crisis:
97% of customers are one-time buyers. This makes Customer Acquisition Cost (CAC) unsustainable without improving Lifetime Value (LTV).
Delivery performance varies wildly by state — RJ averages 14.8 days vs SP at 8.3 days, directly correlating with lower review scores and reduced repeat intent.
Seller quality is inconsistent — top-performing sellers coexist with high-revenue, low-rating sellers who damage brand trust.
No predictive capability — Olist cannot proactively identify which customers are about to churn, missing the window for retention interventions.
Core Question: How can we transform raw transactional data into a production-grade analytics platform capable of predicting churn, optimizing delivery, and driving revenue recovery?

**2. Tools & Technologies**
Cloud & Storage
Table
Tool	Purpose
AWS S3	Data lake for raw CSVs and processed Parquet files
AWS Athena	Serverless SQL query engine for ad-hoc analytics and CTAS transformations
AWS Glue	Schema discovery via crawlers; metadata catalog for Athena tables
Data Engineering
Table
Tool	Purpose
Apache Parquet	Columnar storage format for compressed, high-performance analytics
Bash + Cron	Daily ETL pipeline automation
Git + GitHub	Version control and CI/CD-ready repository
Data Science & ML
Table
Tool	Purpose
Python 3.8+	Primary language for modeling and visualization
pandas	Data manipulation and feature engineering
scikit-learn	Gradient Boosting Classifier, train/test splits, metrics
matplotlib	Executive dashboards and model performance charts
Data Quality
Table
Technique	Purpose
TRY(DATE_PARSE(...))	Graceful handling of malformed timestamps without query crashes
customer_unique_id deduplication	Correcting the per-order customer_id bug to identify true repeat customers
Partitioning by year_month	Time-range queries execute in <1 second

**3. ETL Pipeline & Data Architecture**
Medallion Architecture
plain
BRONZE (Raw CSVs on S3)
├── orders.csv
├── order_items.csv
├── customers.csv
├── order_reviews.csv
├── products.csv
├── sellers.csv
├── geolocation.csv
├── product_category_name_translation.csv
└── order_payments.csv

SILVER (Cleaned & Typed Parquet)
├── orders_clean          — timestamp-fixed, partitioned by year_month
├── order_items_clean     — revenue per line item
├── customers_clean       — customer_unique_id corrected
├── reviews_clean         — sentiment buckets, NLP flags
└── products_enriched     — volume, listing quality

GOLD (Master Fact + ML Features)
├── orders_enriched_v2          — 30+ columns, everything joined
├── orders_geo                  — Haversine distance seller↔customer
├── customer_velocity           — purchase pattern segmentation
├── market_basket_v2            — cross-sell affinity
├── reviews_nlp                 — sentiment intensity from text
├── product_listing_quality     — photo/desc → sales correlation
├── seasonality                 — Black Friday/holiday forecasting
├── churn_risk                  — 0-100 churn probability per customer
├── order_journey               — funnel bottleneck detection
├── seller_rolling_tier_v2      — Platinum/Gold/Silver/Bronze
└── freight_elasticity_v2       — freight sensitivity by category
Pipeline Flow
plain
S3 Raw CSVs
    ↓
AWS Glue Crawler (schema discovery)
    ↓
Athena CTAS Queries (7 core transformations)
    ↓
Partitioned Parquet on S3
    ↓
Feature Engineering (Python / Athena SQL)
    ↓
XGBoost Model → Churn Scores
    ↓
Executive Dashboards + Automated Alerts
Automation
Daily refresh via scripts/refresh_pipeline.sh scheduled at 3:00 AM via cron
Zero manual intervention after deployment
All tables rebuilt incrementally using year_month partitioning

**4. Data Preprocessing**
*4.1 Timestamp Cleaning*
Raw order timestamps contained malformed values and mixed formats. We used:
sql
TRY(DATE_PARSE(order_purchase_timestamp, '%Y-%m-%d %H:%i:%s')) AS purchase_timestamp
This prevents the entire CTAS query from failing when a single row is dirty.
*4.2 Customer Identity Resolution*
Critical bug discovered: customer_id is unique per order, not per person. The true customer key is customer_unique_id.
Table
Before Fix	After Fix
Repeat rate: 0%	Repeat rate: 3%
All customers appear as one-time buyers	2,801 genuine repeat customers identified
This single fix saved weeks of incorrect churn analysis.
*4.3 Feature Engineering*
Table
Feature	Method	Business Value
Haversine Distance	6371 * acos(...) between seller and customer lat/long	Explains 40% of delivery variance
NLP Sentiment Intensity	Portuguese keyword lexicon on review text	Catches 5-star reviews with negative subtext
Order Journey Stages	approval → carrier → delivery timestamps	48% of delays are seller approval, not carrier
Freight Elasticity	freight_value / order_value by category	Enables dynamic free-shipping thresholds
Seller Tier Score	Rolling 90-day avg review × on-time rate × revenue	Auto-rates sellers Platinum/Gold/Silver/Bronze
*4.4 Partitioning Strategy*
All time-series tables are partitioned by year_month:
Query cost reduction: Athena scans only relevant partitions
Performance: Date-range queries execute in <1 second
Scalability: New months auto-create new partitions

**5. Key Business Insights**
*5.1 The Retention Crisis*
One-time buyers: 90,557 (97%)
Repeat buyers: 2,801 (3%)
Repeat AOV: R$145.95 (LOWER than one-time R$160.73)
Insight: Retention is driven by operational excellence, not deal size. Repeat buyers spend less per order but generate compounding LTV.
*5.2 Delivery-Satisfaction Correlation*
Table
State	Delivery Days	Review Score	Revenue
SP	8.3 ⭐	4.24	R$5.77M
RJ	14.8	3.97	R$2.06M
AM	26.0	4.23	R$27K
Correlation coefficient: -0.82 (strong negative: faster delivery = higher satisfaction)
*5.3 The Feb–Mar 2018 Operational Crisis*
On-time delivery crashed to 78.6% (worst ever)
Review scores hit 3.85 (all-time low)
Recovery by June 2018 suggests root cause was fixable (likely carrier capacity or seller approval backlog)
*5.4 Product Category Quality Killers*
Table
Category	Repeat Score	Delivery Days	Action
moveis_escritorio	3.36 🔴	22.4	Delist
fashion_roupa_masculina	3.70 🔴	12.5	Restrict
esporte_lazer	4.42 🟢	10.7	Promote
beleza_saude	4.27 🟢	11.2	Promote
*5.5 Seller Intervention List*
Table
Seller ID	Revenue	Score	Negative %	Action
7c67e14...	R$240K	3.34	29.6%	🔴 FIRE
1025f0e...	R$174K	3.75	23.3%	🟡 WARN
fa1c13f...	R$204K	4.37	10.3%	🟢 REWARD

**6. Strategic Recommendations**
Immediate (0–30 days)
Win-Back Campaign: Email customers with churn score >70 a "We miss you" offer with 15% discount.
Target: 100 dormant high-LTV customers → R$100K revenue recovery
Seller Quality Enforcement: Issue warnings to sellers with <3.5 avg score and >20% negative reviews.
RJ Delivery Fix: Investigate carrier contracts in Rio de Janeiro to reduce 14.8-day average to 10 days.
Impact: 12,395 orders/month → R$500K revenue protection
Short-term (1–3 months)
Category Restructuring: Delist moveis_escritorio (3.36 score, 22.4-day delivery) and promote esporte_lazer / beleza_saude.
Freight Threshold Testing: Run A/B tests on free-shipping thresholds for freight-elastic categories.
Operational Dashboard: Deploy real-time seller tier alerts so account managers see downgrades immediately.
Long-term (3–12 months)
Repeat Rate Target: Move from 3% → 10% repeat customers.
Math: 6,500 new repeat buyers × R$145 AOV × 3x/year = R$1M+ LTV
Predictive API: Build a Lambda + API Gateway endpoint for real-time churn scoring at checkout.
Recommendation Engine: Cross-sell products using market basket analysis → +15% basket size.

**7. Machine Learning**
Churn Prediction Model
Algorithm: Gradient Boosting Classifier
Performance: ROC-AUC = 0.904 (Production-grade: >0.85)
Table
Feature	Importance	Business Interpretation
days_since_last_order	52.2%	Time decay is THE churn signal
total_orders	7.9%	One-time buyers rarely return
sentiment_intensity	5.0%	Review text catches hidden dissatisfaction
has_bottleneck	5.0%	Operational friction drives churn
distance_km	4.8%	Remote delivery = higher churn risk
Model Output:
churn_risk_score (0–100)
risk_bucket (🟢 Low / 🟡 Medium / 🟠 High / 🔴 Critical)
predicted_churn (0/1)

**8. Repository Structure**
plain
olist-analytics-platform/
├── README.md                          # This file
├── PROJECT_INSIGHT.md                 # Deep-dive business analysis
├── DEPLOYMENT.md                      # Technical deployment guide
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

**9. Deployment Guide**
Prerequisites
AWS Account with S3, Athena, Glue access
AWS CLI configured (aws configure)
Python 3.8+ with pandas, matplotlib, scikit-learn
Quick Start
bash
# Step 1: Deploy raw data
aws s3 cp olist_raw_data/ s3://your-bucket/raw/ --recursive

# Step 2: Create Athena database
aws athena start-query-execution \
    --query-string "CREATE DATABASE IF NOT EXISTS olist_analytics_processed;" \
    --result-configuration "OutputLocation=s3://your-bucket/athena-results/"

# Step 3: Run pipeline
chmod +x scripts/refresh_pipeline.sh
./scripts/refresh_pipeline.sh

# Step 4: Schedule daily refresh
crontab -e
# Add: 0 3 * * * /path/to/olist-analytics-platform/scripts/refresh_pipeline.sh

# Step 5: Run ML model
cd models
python churn_prediction.py
Cost Estimate (Monthly)
Table
Service	Usage	Cost
S3 Storage	2GB Parquet	~$0.05
Athena Queries	100 queries/day	~$1.50
Glue Crawler	Daily run	~$0.50
Total		~$2.00/month

**10. Next Steps (V1.1 Roadmap)**
Table
Feature	Effort	Impact
Real-time churn scoring API (Lambda + API Gateway)	2 weeks	Instant retention triggers
A/B test retention offers by risk bucket	1 month	Measure R$ lift per segment
Prophet revenue forecasting	2 weeks	Predict demand spikes
Product recommendation engine	1 month	Cross-sell revenue +15%
Streaming seller tier alerts (Kinesis)	1 month	Real-time quality enforcement
Lessons Learned
Data quality > model complexity. Finding the customer_id vs customer_unique_id bug saved weeks of bad analysis.
Simple features win. days_since_last_order alone explains 52% of churn.
Operational metrics drive retention. Repeat buyers spend LESS (R$145 vs R$160) but get faster delivery.
TRY() is your friend. Athena's TRY() prevents DATE_PARSE from crashing on dirty data — essential for production CTAS queries.
Built by Nhlanhla Lekgale · August 2026
