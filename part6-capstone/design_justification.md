# Capstone Design Justification

## Storage Systems

I put PostgreSQL at the center of the system as the source of truth for all live clinical data — admissions, treatment records, prescriptions. The reason I didn't consider anything else for this role is that patient data can't be eventually consistent. A medication update and a concurrent read have to see the same state. PostgreSQL's row-level locking guarantees that, and its WAL is what makes CDC viable without loading the transactional database with analytical queries.

For ICU vitals I needed something completely different. Devices emit readings at sub-second intervals from a lot of beds simultaneously — that's a streaming problem, not a transactional one. I chose Kafka to buffer the event stream and decouple the devices from downstream consumers, so a slow consumer doesn't cause data loss. TimescaleDB stores the ingested vitals with time-based partitioning, which makes "last 30 minutes of SpO2 for bed 7" queries fast in a way that a standard relational table wouldn't be. A Flink job sits between Kafka and the ICU dashboard, handling threshold alerts.

The ML training corpus is a Delta Lake on object storage. Debezium tails the PostgreSQL WAL and lands change events as Parquet files — I added Delta Lake on top for schema enforcement and time-travel, mainly because I wanted the ability to reproduce training runs from a specific historical snapshot. This also ends up being the source for the patient history embeddings used in the RAG pipeline.

I added pgvector for semantic search because keyword search over clinical notes doesn't work well — the same condition gets described in too many different ways across doctors and time periods. Patient history documents get chunked by clinical episode and encoded into dense vectors. When a doctor queries "has this patient had a cardiac event before?", the nearest chunks go to an LLM for a cited answer.

For management reporting I went with Snowflake (or Redshift depending on what's already in the stack). Bed-occupancy and cost queries span months of data — those need columnar storage and pre-aggregated facts, not a transactional database. A nightly ETL job loads from the Lakehouse into the warehouse. The key thing for me was physical isolation: a long-running cost analysis never competes with a live clinical write.

## OLTP vs OLAP Boundary

The OLTP/OLAP boundary is the CDC layer. PostgreSQL handles all writes and real-time reads. Everything downstream is read-optimized and eventually consistent.

## Trade-offs

Replication lag. The Lakehouse is async, so a lab result at 8:58 a.m. might not be visible to a model scoring discharge risk at 9:00 a.m. For monthly reporting that doesn't matter at all. For the readmission model at the actual moment of discharge it's a genuine clinical risk — that's the one prediction that has to be based on current data.

My mitigation is two scoring modes: nightly batch scoring (for morning rounds flagging) reads from the Lakehouse where lag is fine, and on-demand scoring at discharge reads the last 24 hours directly from PostgreSQL. It's a bit inelegant to have two code paths, but I don't see a better option that keeps the analytical pipeline properly decoupled from OLTP.
