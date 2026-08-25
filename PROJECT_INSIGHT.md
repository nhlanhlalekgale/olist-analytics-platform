# Olist Brazilian E-Commerce Analytics & ML Platform
## End-to-End Data Engineering & Machine Learning Project

**Author:** Nhlanhla Lekgale  
**Date:** August 2026  
**Dataset:** Olist (Brazil's Largest Marketplace)  
**Tech Stack:** AWS S3 | AWS Athena | Python | scikit-learn | Matplotlib

---

## 1. PROJECT OVERVIEW

### 1.1 Business Context
Olist connects 100,000+ small Brazilian businesses to online sales channels. 
This project transforms raw transactional data into a production-grade analytics 
platform capable of predicting customer churn, optimizing delivery, and driving 
revenue recovery.

### 1.2 Dataset Scale
| Metric | Value |
|--------|-------|
| Raw Orders | 99,441 |
| Unique Customers | 96,096 |
| Total Revenue | R$ 15,420,000 |
| Time Period | Oct 2016 – Aug 2018 |
| Raw Tables | 9 CSV files |
| Processed Tables | 17 Parquet tables |

### 1.3 The Core Business Problem
**97% of customers are one-time buyers.** This is an existential threat to 
sustainable growth. Every customer acquired is essentially a first-time customer, 
making CAC (Customer Acquisition Cost) unsustainable without retention.

---

## 2. ARCHITECTURE

### 2.1 Data Pipeline (Medallion Architecture)
