# dbt-bank-json

A small practice project for working with semi-structured (JSON) data in Snowflake and dbt.

## Why this project exists

My main portfolio project, [dbt-bank-snowflake](<link-to-main-repo>), uses flat, structured
banking data. This project is a smaller, separate exercise. I built it to practice Snowflake's
semi-structured data features: `VARIANT`, dot notation, casting, and `LATERAL FLATTEN`. These
do not appear in the main project.

The data is synthetic. It looks like real banking data (customers, accounts, transactions,
line items, fees), but it is not real. This project is not production-grade. The goal was
learning, not scale.

## What this project demonstrates

- Loading raw JSON into Snowflake `VARIANT` columns
- Reading nested objects and arrays with dot notation and casting
- The three types of "nothing" in JSON: a missing key, a JSON `null`, and a true SQL `NULL`
- `LATERAL FLATTEN` to turn arrays into rows, including `OUTER => TRUE` for optional arrays,
  and flattening arrays inside other arrays
- `OBJECT_KEYS` and `TYPEOF` to explore a new JSON structure before writing any model
- Turning nested JSON back into flat, simple staging tables, one grain per table
- Aggregating each source to the same grain before joining, to avoid duplicate rows
- Window functions in mart models: ranking, share of total
- dbt tests: `not_null`, `unique`, `accepted_values`, `relationships`

## Source data

Two raw tables, loaded as NDJSON into `VARIANT` columns. They live in their own Snowflake
warehouse and schema, separate from the main project:

- `raw_customers_json`: 50 customers, each with 1 to 3 nested accounts
- `raw_transactions_json`: 800 transactions, with a nested amount, an optional merchant and
  item list (card payments only), and an optional list of fees

## Project layout

```
models/
├── staging/
│   ├── stg_transactions.sql          -- one row per transaction
│   ├── stg_transaction_items.sql     -- one row per line item
│   ├── stg_transaction_fees.sql      -- one row per fee
│   └── stg_customer_accounts.sql     -- one row per account
├── intermediate/
│   ├── int_customer_transactions_agg.sql
│   └── int_fee_income_by_channel.sql
└── marts/
    ├── fct_fee_income_by_channel.sql
    └── fct_merchant_spend.sql
```

Staging models flatten the nested JSON into normal tables. Each model has one grain.
Intermediate models aggregate each staging model to the same grain before any join. This
way, joins never create duplicate rows. Mart models add ranking and share-of-total numbers
with window functions.

## Tech stack

- Snowflake (`VARIANT`, `LATERAL FLATTEN`)
- dbt Core

## Running it

```bash
dbt build
dbt docs generate && dbt docs serve
```

## Related project

See [dbt-bank-snowflake](<link-to-main-repo>), my main portfolio project, for a full,
production-style setup: CI/CD with GitHub Actions (Slim CI), infrastructure managed with
Terraform, SQLFluff linting, and pre-commit hooks.