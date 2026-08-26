# raw_datasets/

This directory is intended to hold original, unprocessed (raw) datasets used by the Olist analytics and ML pipelines. Keep the following in mind when adding files here:

- Purpose: store immutable snapshots of source data (CSV, Parquet, JSON, etc.) exactly as received from external sources or extraction queries.
- Naming convention: use descriptive names with dates, e.g. `orders_YYYYMMDD.csv`, `customers_YYYYMMDD.parquet`.
- Do NOT commit large binary files or sensitive data (PII). For large raw datasets, keep them in an external data store (S3, GCS) and add a small pointer file or ingestion manifest here instead.
- Add a README or manifest next to any dataset explaining origin, schema, and ingestion date.
- If you need to keep sample files for tests or examples, put them in `data/samples/` or `tests/fixtures/` instead.

Suggested workflow:
1. Export or copy the raw source to an external storage (recommended: S3).
2. Add a small pointer file or manifest in `raw_datasets/` describing location and schema.
3. Use the project's ETL scripts to ingest and transform raw data into `data/processed/` or your analytics tables.

If you'd like, I can also:
- Add a `.gitignore` entry to avoid accidentally committing large raw files.
- Create `data/samples/` with a tiny example CSV for onboarding and tests.

