# Olist Marketplace Analytics & ML Platform

**From Raw CSVs to Production Intelligence**

[![AWS](https://img.shields.io/badge/AWS-S3%20%7C%20Athena-blue)](https://aws.amazon.com)
[![Python](https://img.shields.io/badge/Python-3.8%2B-green)](https://python.org)
[![ML](https://img.shields.io/badge/ML-XGBoost-orange)](https://xgboost.ai)
[![License](https://img.shields.io/badge/License-MIT-yellow)](LICENSE)

---

## 📑 Table of Contents

1. [Problem Statement](#1-problem-statement)
2. [Tools & Technologies](#2-tools--technologies)
3. [Quick Links](#quick-links)
4. [ETL Pipeline & Data Architecture](#3-etl-pipeline--data-architecture)
5. [Data Preprocessing](#4-data-preprocessing)
6. [Key Business Insights](#5-key-business-insights)
7. [Strategic Recommendations](#6-strategic-recommendations)
8. [Machine Learning](#7-machine-learning)
9. [Repository Structure](#8-repository-structure)
10. [Deployment Guide](#9-deployment-guide)
11. [Next Steps](#10-next-steps)
12. [Lessons Learned](#11-lessons-learned)
13. [Contributing & Support](#contributing--support)

---

## 1. Problem Statement

Olist connects **100,000+** small Brazilian businesses to online sales channels. Despite strong top-line growth, the platform faces a **critical retention crisis**:

- **97% of customers are one-time buyers.** This makes Customer Acquisition Cost (CAC) unsustainable without improving Lifetime Value (LTV).
- **Delivery performance varies wildly by state** — RJ averages **14.8 days** vs SP at **8.3 days**, directly correlating with lower review scores and reduced repeat intent.
- **Seller quality is inconsistent** — top-performing sellers coexist with high-revenue, low-rating sellers who damage brand trust.
- **No predictive capability** — Olist cannot proactively identify which customers are about to churn, missing the window for retention interventions.

> **Core Question:** *How can we transform raw transactional data into a production-grade analytics platform capable of predicting churn, optimizing delivery, and driving revenue recovery?*

---

## 2. Tools & Technologies

### Cloud & Storage

| Tool | Purpose |
|------|---------|
| **AWS S3** | Data lake for raw CSVs and processed Parquet files |
| **AWS Athena** | Serverless SQL query engine for ad-hoc analytics and CTAS transformations |
| **AWS Glue** | Schema discovery via crawlers; metadata catalog for Athena tables |

### Data Engineering

| Tool | Purpose |
|------|---------|
| **Apache Parquet** | Columnar storage format for compressed, high-performance analytics |
| **Bash + Cron** | Daily ETL pipeline automation |
| **Git + GitHub** | Version control and CI/CD-ready repository |

### Data Science & ML

| Tool | Purpose |
|------|---------|
| **Python 3.8+** | Primary language for modeling and visualization |
| **pandas** | Data manipulation and feature engineering |
| **scikit-learn** | Gradient Boosting Classifier, train/test splits, metrics |
| **matplotlib** | Executive dashboards and model performance charts |

### Data Quality & Architecture

| Technique | Purpose |
|-----------|---------|
| `TRY(DATE_PARSE(...))` | Graceful handling of malformed timestamps without query crashes |
| `customer_unique_id` deduplication | Correcting the per-order `customer_id` bug to identify true repeat customers |
| **Partitioning by `year_month`** | Time-range queries execute in <1 second |
| **Medallion Architecture** | Bronze → Silver → Gold data layer progression |

---

## Quick Links

- 🚀 **[Deployment Guide](DEPLOYMENT.md)** — Get started in 10 minutes
- 📊 **[Business Insights](PROJECT_INSIGHT.md)** — Full analysis & recommendations  
- 📁 **[SQL Queries](sql/)** — 7 core ETL transformations
- 🎯 **[Model Code](models/churn_prediction.py)** — XGBoost churn predictor

---

## 3. ETL Pipeline & Data Architecture

### Data Lake Structure (Medallion Pattern)

```
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
```

### Pipeline Flow

```
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
```

### Automation

- **Daily refresh** via `scripts/refresh_pipeline.sh` scheduled at **3:00 AM** via `cron`
- **Zero manual intervention** after deployment
- All tables rebuilt incrementally using `year_month` partitioning
- *Data Source:* Public Olist Brazilian E-Commerce dataset + custom feature engineering

---

## 4. Data Preprocessing

### 4.1 Timestamp Cleaning

Raw order timestamps contained malformed values and mixed formats. We used:

```sql
TRY(DATE_PARSE(order_purchase_timestamp, '%Y-%m-%d %H:%i:%s')) AS purchase_timestamp
```

The `TRY()` function prevents query crashes on malformed dates—essential for production data.

### 4.2 Customer Identity Resolution

**Critical bug discovered:** `customer_id` is unique per order, not per person. The true customer key is `customer_unique_id`.

| Metric | Before Fix | After Fix |
|--------|-----------|-----------|
| Repeat rate | 0% | 3% |
| Repeat customers identified | 0 | 2,801 |
| Business impact | All customers appear one-time | True LTV calculation possible |

### 4.3 Feature Engineering

| Feature | Method | Business Value |
|---------|--------|-----------------|
| **Haversine Distance** | 6371 × acos(...) between seller/customer lat/long | Explains 40% of delivery variance |
| **NLP Sentiment Intensity** | Portuguese keyword lexicon on review text | Catches 5-star reviews with negative subtext |
| **Order Journey Stages** | approval → carrier → delivery timestamps | 48% of delays are seller approval, not carrier |
| **Freight Elasticity** | freight_value / order_value by category | Enables dynamic free-shipping thresholds |
| **Seller Tier Score** | Rolling 90-day avg review × on-time rate × revenue | Auto-rates sellers Platinum/Gold/Silver/Bronze |

### 4.4 Partitioning Strategy

All time-series tables are partitioned by `year_month`:

- **Query cost reduction:** Athena scans only relevant partitions
- **Performance:** Date-range queries execute in <1 second
- **Scalability:** New months auto-create new partitions

---

## 5. Key Business Insights

> ✅ **Model Production-Ready:** ROC-AUC 0.904 | Repeat rate opportunity: 3% → 10% = **R$1M+ LTV upside**

### 5.1 The Retention Crisis

| Metric | Value |
|--------|-------|
| One-time buyers | 90,557 (97%) |
| Repeat buyers | 2,801 (3%) |
| Repeat AOV | R$145.95 |
| One-time AOV | R$160.73 |

**Insight:** Retention is driven by operational excellence, not deal size. Repeat buyers spend less per order but generate compounding LTV and 3x annual purchase frequency.

### 5.2 Delivery-Satisfaction Correlation

| State | Delivery Days | Review Score | Revenue | Insight |
|-------|--------------|--------------|---------|---------|
| **SP** | 8.3 ⭐ | 4.24 | R$5.77M | Best performer |
| **RJ** | 14.8 | 3.97 | R$2.06M | 78% slower = 0.27 point gap |
| **AM** | 26.0 | 4.23 | R$27K | Remote but acceptable |

**Correlation coefficient: -0.82** (strong negative: faster delivery = higher satisfaction)

### 5.3 The Feb–Mar 2018 Operational Crisis

- On-time delivery crashed to **78.6%** (worst ever)
- Review scores hit **3.85** (all-time low)
- Recovery by June 2018 suggests root cause was fixable (likely carrier capacity or seller approval backlog)

### 5.4 Product Category Quality Killers

| Category | Repeat Score | Delivery Days | Action |
|----------|--------------|---------------|--------|
| moveis_escritorio | 3.36 🔴 | 22.4 | **DELIST** |
| fashion_roupa_masculina | 3.70 🔴 | 12.5 | **RESTRICT** |
| esporte_lazer | 4.42 🟢 | 10.7 | **PROMOTE** |
| beleza_saude | 4.27 🟢 | 11.2 | **PROMOTE** |

### 5.5 Seller Intervention List

| Seller ID | Revenue | Avg Score | Negative % | Action |
|-----------|---------|-----------|------------|--------|
| 7c67e14... | R$240K | 3.34 | 29.6% | 🔴 **FIRE** |
| 1025f0e... | R$174K | 3.75 | 23.3% | 🟡 **WARN** |
| fa1c13f... | R$204K | 4.37 | 10.3% | 🟢 **REWARD** |

---

## 6. Strategic Recommendations

### 🚨 Immediate Actions (0–30 days)
**Staffing:** 1 FTE analyst + 1 marketing coordinator

| Initiative | Details | Target Impact |
|-----------|---------|----------------|
| **Win-Back Campaign** | Email customers with churn score >70 a "We miss you" offer (15% discount) | 100 high-LTV customers → R$100K revenue recovery |
| **Seller Quality Enforcement** | Issue warnings to sellers with <3.5 avg score and >20% negative reviews | Improve avg score from 3.97 to 4.10 |
| **RJ Delivery Fix** | Investigate carrier contracts in Rio de Janeiro; negotiate SLA to reduce 14.8-day average to 10 days | 12,395 orders/month → R$500K revenue protection |

### 📈 Short-term Initiatives (1–3 months)
**Staffing:** +1 product manager for A/B testing

| Initiative | Details | Target Impact |
|-----------|---------|----------------|
| **Category Restructuring** | Delist moveis_escritorio (3.36 score, 22.4-day delivery); promote esporte_lazer / beleza_saude | +5% category GMV |
| **Freight Threshold Testing** | Run A/B tests on free-shipping thresholds for freight-elastic categories | +8% basket size per segment |
| **Operational Dashboard** | Deploy real-time seller tier alerts so account managers see downgrades immediately | Reduce seller churn 20% |

### 🎯 Long-term Strategy (3–12 months)
**Staffing:** +1 ML engineer + 1 data analyst

| Initiative | Details | Target Impact |
|-----------|---------|----------------|
| **Repeat Rate Target** | Move from 3% → 10% repeat customers | **6,500 new repeat buyers × R$145 AOV × 3x/year = R$1M+ LTV** |
| **Predictive API** | Build Lambda + API Gateway endpoint for real-time churn scoring at checkout | Instant retention triggers for 500K+ customers |
| **Recommendation Engine** | Cross-sell products using market basket analysis | +15% basket size |
| **Forecasting** | Prophet revenue forecasting for inventory planning | Reduce stockouts 25% |

---

## 7. Machine Learning

### Churn Prediction Model

| Metric | Value |
|--------|-------|
| **Algorithm** | Gradient Boosting Classifier (scikit-learn) |
| **Performance** | ROC-AUC = **0.904** ✅ (Production-grade: >0.85) |
| **Train/Test Split** | 80/20 stratified by repeat status |
| **Features** | 15 engineered features (see 4.3) |

### Feature Importance

| Feature | Importance | Business Interpretation |
|---------|-----------|------------------------|
| days_since_last_order | 52.2% | **Time decay is THE churn signal** |
| total_orders | 7.9% | One-time buyers rarely return |
| sentiment_intensity | 5.0% | Review text catches hidden dissatisfaction |
| has_bottleneck | 5.0% | Operational friction drives churn |
| distance_km | 4.8% | Remote delivery = higher churn risk |

### Model Output

- **churn_risk_score** (0–100): Continuous probability
- **risk_bucket:** 🟢 Low (0–25) / 🟡 Medium (26–50) / 🟠 High (51–75) / 🔴 Critical (76–100)
- **predicted_churn:** Binary classification (0 = retain, 1 = churn)

---

## 8. Repository Structure

```
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
```

---

## 9. Deployment Guide

### Prerequisites

- **AWS Account** with S3, Athena, and Glue access
- **AWS CLI** configured (`aws configure`)  
  - Requires IAM permissions: `s3:GetObject`, `s3:PutObject`, `athena:StartQueryExecution`, `glue:*`
- **Python 3.8+** with: `pandas`, `matplotlib`, `scikit-learn`, `xgboost`
- **Git** for cloning the repository

See [DEPLOYMENT.md](DEPLOYMENT.md) for full IAM policy requirements.

### Quick Start (5 Steps)

```bash
# Step 1: Clone and navigate
git clone https://github.com/nhlanhlalekgale/olist-analytics-platform.git
cd olist-analytics-platform

# Step 2: Deploy raw data to S3
aws s3 cp data/raw/ s3://your-bucket/olist/raw/ --recursive

# Step 3: Create Athena database
aws athena start-query-execution \
    --query-string "CREATE DATABASE IF NOT EXISTS olist_analytics_processed;" \
    --result-configuration "OutputLocation=s3://your-bucket/athena-results/"

# Step 4: Run pipeline
chmod +x scripts/refresh_pipeline.sh
./scripts/refresh_pipeline.sh

# Step 5: Schedule daily refresh (3:00 AM UTC)
crontab -e
# Add: 0 3 * * * /path/to/olist-analytics-platform/scripts/refresh_pipeline.sh

# Step 6: Run ML model
cd models && python churn_prediction.py
```

### Cost Estimate (Monthly)

| Service | Usage | Estimated Cost |
|---------|-------|-----------------|
| S3 Storage | 2GB Parquet | ~$0.05 |
| Athena Queries | 100 queries/day | ~$1.50 |
| Glue Crawler | Daily run | ~$0.50 |
| **Total** | | **~$2.00/month** |

> ⚠️ **Cost Caveats:** Assumes <100M events/month and <1,000 daily queries. Scale costs accordingly for larger deployments. Test with small data volumes first.

---

## 10. Next Steps (V1.1 Roadmap)

| Feature | Effort | Impact |
|---------|--------|--------|
| Real-time churn scoring API (Lambda + API Gateway) | 2 weeks | Instant retention triggers at checkout |
| A/B test retention offers by risk bucket | 1 month | Measure R$ lift per segment |
| Prophet revenue forecasting | 2 weeks | Predict demand spikes |
| Product recommendation engine | 1 month | Cross-sell revenue +15% |
| Streaming seller tier alerts (Kinesis) | 1 month | Real-time quality enforcement |

---

## 11. Lessons Learned

1. **Data quality > model complexity**  
   Finding the `customer_id` vs `customer_unique_id` bug saved weeks of bad analysis. Clean data beats fancy algorithms.

2. **Simple features win**  
   `days_since_last_order` alone explains 52% of churn. Domain expertise beats brute-force feature engineering.

3. **Operational metrics drive retention**  
   Repeat buyers spend LESS (R$145 vs R$160) but get faster delivery and personalized support. Revenue ≠ Retention.

4. **TRY() is your friend**  
   Athena's `TRY(DATE_PARSE(...))` prevents crashes on malformed dates—essential for production CTAS queries over messy real-world data.

5. **Partitioning matters**  
   Year-month partitioning reduced Athena costs by 80% and query times from 45s → <1s. Design schema for the query pattern, not just the data.

---

## Contributing & Support

### Found a bug or want to improve something?

- **Issues:** [Open an issue](../../issues) with reproduction steps
- **Pull Requests:** Fork → feature branch → PR with tests welcome
- **Questions?** See [DEPLOYMENT.md](DEPLOYMENT.md) troubleshooting section or [PROJECT_INSIGHT.md](PROJECT_INSIGHT.md)

### Citation

If you use this codebase in your work, please cite:

```bibtex
@misc{olist-analytics-2026,
  author = {Nhlanhla Lekgale},
  title = {Olist Marketplace Analytics & ML Platform},
  year = {2026},
  url = {https://github.com/nhlanhlalekgale/olist-analytics-platform}
}
```

---

**Built by Nhlanhla Lekgale · August 2026**

**Last Updated:** August 25, 2026