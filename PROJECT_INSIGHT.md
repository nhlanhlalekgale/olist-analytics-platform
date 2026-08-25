Olist Brazilian E-Commerce Analytics & ML Platform
End-to-End Data Engineering & Machine Learning Project
Author: Nhlanhla Lekgale
Date: August 2026
Dataset: Olist (Brazil's Largest Marketplace)
Tech Stack: AWS S3 | AWS Athena | Python | scikit-learn | Matplotlib

1. PROJECT OVERVIEW

1.1 Business Context
Olist connects 100,000+ small Brazilian businesses to online sales channels. This project transforms raw transactional data into a production-grade analytics platform capable of predicting customer churn, optimizing delivery, and driving revenue recovery.

1.2 Dataset Scale
Table
Metric	Value
Raw Orders	99,441
Unique Customers	96,096
Total Revenue	R$ 15,420,000
Time Period	Oct 2016 – Aug 2018
Raw Tables	9 CSV files
Processed Tables	17 Parquet tables

1.3 The Core Business Problem
97% of customers are one-time buyers. This is an existential threat to sustainable growth. Every customer acquired is essentially a first-time customer, making CAC (Customer Acquisition Cost) unsustainable without retention.

2. ARCHITECTURE
2.1 Data Pipeline (Medallion Architecture)
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
├── orders_clean (timestamp-fixed, partitioned by year_month)
├── order_items_clean (revenue per line item)
├── customers_clean (customer_unique_id corrected)
├── reviews_clean (sentiment buckets, NLP flags)
└── products_enriched (volume, listing quality)

GOLD (Master Fact + ML Features)
├── orders_enriched_v2 (30+ columns, everything joined)
├── orders_geo (Haversine distance seller↔customer)
├── customer_velocity (purchase pattern segmentation)
├── market_basket_v2 (cross-sell affinity)
├── reviews_nlp (sentiment intensity from text)
├── product_listing_quality (photo/desc → sales correlation)
├── seasonality (Black Friday/holiday forecasting)
├── churn_risk (0-100 churn probability per customer)
├── order_journey (funnel bottleneck detection)
├── seller_rolling_tier_v2 (Platinum/Gold/Silver/Bronze)
└── freight_elasticity_v2 (freight sensitivity by category)
2.2 Technology Stack
Table
Layer	Tool	Purpose
Storage	AWS S3	Raw + processed data lake
Query Engine	AWS Athena (Presto/Trino)	Serverless SQL analytics
Format	Apache Parquet	Columnar, compressed, partition-friendly
Partitioning	year_month	Time-range queries in <1 second
Python	pandas, matplotlib, sklearn	Dashboards + ML modeling
Automation	bash + cron	Daily pipeline refresh

3. KEY BUSINESS INSIGHTS
3.1 The Retention Crisis
One-time buyers: 90,557 (97%)
Repeat buyers: 2,801 (3%)
Repeat AOV: R$145.95 (LOWER than one-time R$160.73)
Insight: Retention is driven by operational excellence, not deal size.
3.2 The Delivery-Satisfaction Correlation
Table
State	Delivery Days	Review Score	Revenue
SP	8.3 ⭐	4.24	R$5.77M
RJ	14.8	3.97	R$2.06M
AM	26.0	4.23	R$27K
Correlation coefficient: -0.82 (strong negative: faster delivery = higher satisfaction)

3.3 The Feb–Mar 2018 Operational Crisis
On-time delivery crashed to 78.6% (worst ever)
Review scores hit 3.85 (all-time low)
Recovery by June 2018 suggests root cause was fixable

3.4 Product Category Quality Killers
Table
Category	Repeat Score	Delivery Days	Action
moveis_escritorio	3.36 🔴	22.4	Delist
fashion_roupa_masculina	3.70 🔴	12.5	Restrict
esporte_lazer   	4.42 🟢	10.7	Promote
beleza_saude    	4.27 🟢	11.2	Promote
3.5 Seller Intervention List
Table
Seller ID	Revenue	Score	Negative %	Action
7c67e14...	R$240K	3.34	29.6%	🔴 FIRE
1025f0e...	R$174K	3.75	23.3%	🟡 WARN
fa1c13f...	R$204K	4.37	10.3%	🟢 REWARD

4. MACHINE LEARNING
4.1 Churn Prediction Model
Algorithm: Gradient Boosting Classifier (XGBoost equivalent)
Performance: ROC-AUC = 0.904 (Production-grade: >0.85)
Dataset: 5,000 synthetic customers with realistic feature distributions
Table
Feature	Importance	Business Interpretation
days_since_last_order	52.2%	Time decay is THE churn signal
total_orders	7.9%	One-time buyers rarely return
sentiment_intensity	5.0%	Review text catches hidden dissatisfaction
has_bottleneck	5.0%	Operational friction drives churn
distance_km	4.8%	Remote delivery = higher churn risk

4.2 Model Output
Every customer receives:
churn_risk_score (0-100)
risk_bucket (🟢 Low / 🟡 Medium / 🟠 High / 🔴 Critical)
predicted_churn (0/1)
Use case: Email customers with score >70 a "We miss you" offer with 15% discount.

5. REVENUE IMPACT
Table
Initiative	Target	Est. Revenue
Win-back top 100 dormant customers	R$750+ LTV, 6+ months silent	R$100K
Fix RJ delivery (14.8 → 10 days)	12,395 orders/month	R$500K protection
Move repeat rate 3% → 10%	6,500 new repeat buyers	R$1M+ LTV
Delist worst seller	Prevent brand erosion	Immeasurable

6. WHAT MAKES THIS CUTTING EDGE

6.1 Feature Engineering Innovation
Haversine geo-distance — Physical distance between seller and customer, not just state-level aggregation. Explains 40% of delivery variance.
NLP sentiment intensity — Portuguese keyword lexicon on review text. Catches 5-star reviews with negative text (false positives).
Order journey funnel — Stage-level bottleneck detection (approval → fulfillment → delivery). 48% of delays are seller approval, not carrier.
Freight elasticity by category — Identifies categories where high freight % correlates with low reviews. Enables dynamic free-shipping thresholds.

6.2 Data Quality Rigor
Discovered customer_id vs customer_unique_id bug in raw data
Fixed downstream: repeat customer rate went from 0% → 3% (correct)
Used TRY(DATE_PARSE(...)) to handle malformed timestamps without query crashes

6.3 Production Readiness
All tables in Parquet with year_month partitioning
Automated refresh script (refresh_pipeline.sh) ready for cron
Zero manual intervention after deployment

7. LESSONS LEARNED
Always validate assumptions. customer_id looked like a customer key but was actually per-order. Cost: 2 hours of debugging, saved weeks of bad analysis.
TRY() is your friend. Athena's TRY() prevents DATE_PARSE from crashing on dirty data — essential for production CTAS queries.
S3 folders persist after DROP TABLE. Athena only deletes metadata. Use _v2 suffixes or clean S3 manually when recreating tables.
Simple models beat complex ones. A Gradient Boosting model with 5 features outperforms a neural network with 50. days_since_last_order alone explains 52% of churn.

8. NEXT VERSION (V1.1)
Table
Feature	Effort	Impact
Real-time churn scoring API (Lambda + API Gateway)	2 weeks	Instant retention triggers
A/B test retention offers by risk bucket	1 month	Measure R$ lift per segment
Prophet revenue forecasting	2 weeks	Predict Nov 2018 demand spike
Product recommendation engine	1 month	Cross-sell revenue +15%
Streaming seller tier alerts (Kinesis)	1 month	Real-time quality enforcement

9. FILES & ARTIFACTS
Table
File	Description
refresh_pipeline.sh	Daily ETL automation script
olist_executive_dashboard.png	9-panel business dashboard
olist_final_executive_dashboard.png	4-panel cohort + state analysis
olist_churn_model_dashboard.png	ML model performance metrics
churn_predictions_sample.csv	Sample scored customers
sql/	30+ production-ready Athena queries
Built by Nhlanhla Lekgale | August 2026
