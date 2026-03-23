# Vector DB Reflection

## Vector DB Use Case

I picked legal contract search as the use case because it's one of the clearest examples of where keyword search fails in a way that actually costs money.

The issue is that legal language is highly inconsistent across documents. A lawyer searching for "termination clauses" might be looking at contracts where the same concept is written as "conditions for early exit," "right of withdrawal," or "dissolution event" depending on who drafted it and when. A keyword search returns nothing for all of those - not because the answer isn't there, but because the words don't match. I don't think you can fix this with a synonym list, at least not across thousands of contracts from different firms over different time periods.

Vector search works differently. You run both the query and the document chunks through a language model that maps text to points in a high-dimensional embedding space, and then retrieval becomes a nearest-neighbor search. The model learns that "termination clauses" and "right of withdrawal" describe similar things, so they land near each other in that space regardless of vocabulary. I think that's the right abstraction for this problem.

In practice I'd chunk each contract into overlapping sections (overlapping so clauses that span a boundary don't get cut in half), embed each chunk, and index the vectors in something like Pinecone or pgvector. When a lawyer runs a query, you embed their question with the same model, pull the top-k nearest chunks, and pass those to an LLM to generate a cited answer.

One thing I'd be careful about is chunking strategy. I mentioned overlapping chunks but getting the overlap size right for legal documents specifically takes some tuning - a clause that references definitions three pages earlier can still be split in a way that loses critical context. That's probably the hardest part of this in practice, more so than the vector search itself.
