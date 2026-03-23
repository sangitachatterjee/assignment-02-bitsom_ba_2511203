# Architecture Choice

## Architecture Recommendation

I went with a Data Lakehouse for this startup. My thinking was that none of the four data types they're collecting - GPS logs, customer reviews, payment transactions, restaurant images - fit neatly into just a warehouse or just a lake, and trying to force them into either one would lose something important.

A traditional warehouse handles the payment transactions fine but has no way to store images or raw text reviews in any meaningful form. You'd end up shoving everything through ETL into relational tables and losing most of the value in the unstructured data. A pure data lake stores everything, but then you're giving up query performance, schema enforcement, and transactional guarantees - which matters a lot for payments specifically. You can't have "eventually consistent" financial records.

A Lakehouse threads this needle. Open file formats (Parquet, Delta, ORC) on object storage handle all four types without needing to transform anything. The table format layer (Delta Lake or Iceberg) adds ACID semantics on top, so payment data gets real transactional guarantees without needing to live in a separate system. And analysts can query everything through a single SQL interface - Spark SQL, Trino, DuckDB - regardless of what format the underlying data is in.

That last point matters a lot once the startup scales. Joining GPS routes with payment records to investigate fraud, or correlating review sentiment with order frequency - in a siloed setup those queries need custom pipelines per use case. In a Lakehouse you just write the SQL. I think that operational simplicity is worth a lot.
