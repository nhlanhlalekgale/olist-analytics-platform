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
3. [ETL Pipeline & Data Architecture](#3-etl-pipeline--data-architecture)
4. [Data Preprocessing](#4-data-preprocessing)
5. [Key Business Insights](#5-key-business-insights)
6. [Strategic Recommendations](#6-strategic-recommendations)
7. [Machine Learning](#7-machine-learning)
8. [Repository Structure](#8-repository-structure)
9. [Deployment Guide](#9-deployment-guide)
10. [Next Steps](#10-next-steps)
11. [Lessons Learned](#11-lessons-learned)

---

## 1. Problem Statement

Olist connects **100,000+** small Brazilian businesses to online sales channels. Despite strong top-line growth, the platform faces a **critical retention crisis**:

- **97% of customers are one-time buyers.** This makes Customer Acquisition Cost (CAC) unsustainable without improving Lifetime Value (LTV).
- **Delivery performance varies wildly by state** — RJ averages **14.8 days** vs SP at **8.3 days**, directly correlating with lower review scores and reduced repeat intent.
- **Seller quality is inconsistent** — top-performing sellers coexist with high-revenue, low-rating sellers who damage brand trust.
- **No predictive capability** — Olist cannot proactively identify which customers are about to churn, missing the window for retention interventions.

&gt; **Core Question:** *How can we transform raw transactional data into a production-grade analytics platform capable of predicting churn, optimizing delivery, and driving revenue recovery?*

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

### Data Quality

| Technique | Purpose |
|-----------|---------|
| `TRY(DATE_PARSE(...))` | Graceful handling of malformed timestamps without query crashes |
| `customer_unique_id` deduplication | Correcting the per-order `customer_id` bug to identify true repeat customers |
| **Partitioning by `year_month`** | Time-range queries execute in &lt;1 second |

---

## 3. ETL Pipeline & Data Architecture

### Medallion Architecture
