# ETL Notes

## ETL Decisions

### Date Standardization

The `date` column in `retail_transactions.csv` uses three completely different formats with no apparent pattern for which rows use which:
- ISO 8601: `2023-01-15`
- Slash-delimited: `29/08/2023`
- Hyphen-delimited: `12-12-2023`

The slash and hyphen formats are ambiguous — I had to cross-check values like `20-02-2023` to confirm it's day-first (there's no month 20), so the whole file follows DD-first ordering for both non-ISO formats.

I standardized everything to ISO 8601 (`YYYY-MM-DD`) before loading into `dim_date`. The dimension stores `date_key` as an integer in YYYYMMDD format, which sorts naturally. `fact_sales` only holds the key, so if I ever need to correct a date I change one row in `dim_date` and every fact row that references it is automatically fixed.

---

### NULL store_city Imputation

I found NULLs in the `store_city` column for at least 16 rows — TXN5033 (Mumbai Central), TXN5044 (Chennai Anna), TXN5082 (Delhi South), TXN5094, TXN5098, TXN5113, TXN5114, TXN5147, and more. I didn't want to drop those rows since they're valid transactions.

The fix was straightforward once I checked: every store name maps to exactly one city consistently across all non-NULL rows. So I inferred city from store name:

| store_name      | city      |
|-----------------|-----------|
| Chennai Anna    | Chennai   |
| Mumbai Central  | Mumbai    |
| Bangalore MG    | Bangalore |
| Pune FC Road    | Pune      |
| Delhi South     | Delhi     |

City is stored once in `dim_store`. Since all fact rows join through `store_key`, the NULL never makes it into the warehouse.

---

### Category Value Standardization

Two separate problems in the `category` column that I needed to handle independently.

First, a case mismatch — `electronics` (lowercase) appears in 43 rows alongside `Electronics`. I wasn't sure at first if this was intentional (like a status flag or something), but it's clearly just inconsistent entry. Case-sensitive comparisons would silently split Electronics revenue into two buckets.

Second, `Grocery` and `Groceries` are both used for the same category — the same product type shows both depending on which row you're looking at. A `GROUP BY category` would break this into two separate groups.

I picked one canonical value for each (`Electronics`, `Grocery`) and applied it in `dim_product`. Because `fact_sales` stores `product_key` rather than the raw category string, the standardized value comes through the FK join automatically — there's no category string floating in the fact table that could drift again.
