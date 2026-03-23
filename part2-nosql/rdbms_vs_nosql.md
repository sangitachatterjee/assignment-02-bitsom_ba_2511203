# RDBMS vs NoSQL

## Database Recommendation

For the core patient management system, I'd go with MySQL. Healthcare data really can't tolerate the trade-offs you make with a document store - and this isn't a close call.

Patient records, prescriptions, billing: these have to be accurate and consistent. When a doctor writes a prescription, you're typically touching multiple records at once - a medication entry, the patient's treatment history, a billing line. Either all of those commit together or none of them do. That's what ACID transactions give you, and MySQL enforces it with row-level locking and durable write-ahead logging. MongoDB's BASE model trades that consistency away for better availability and partition tolerance. That tradeoff makes sense in a lot of domains. In healthcare it's the wrong way around.

The CAP theorem frames this clearly. You can't have consistency, availability, and partition tolerance all at once - something has to give. For patient records, the right thing to lose is availability. A system that refuses a read is recoverable; a nurse reading a medication list that hasn't converged to the latest committed state and then acting on it is not. MySQL is a CP system - it returns an error before it returns something it can't guarantee is correct. MongoDB configured for AP inverts that priority entirely.

The schema question is worth considering too, though it's less fundamental. Patient encounters, diagnoses, prescriptions, billing - these have well-understood, stable structures. A schemaless document store isn't adding flexibility you'd actually use here; it's just removing the constraints that prevent garbage from entering the system in the first place.

If the startup builds a fraud detection module down the road, that's a different conversation. Fraud detection is high-volume event streams, heterogeneous event shapes, behavioral profiles that don't fit a fixed schema. MongoDB handles all of that well. The practical setup would be MySQL as the clinical source of truth with MongoDB (or a time-series store) bolted on specifically for fraud signals - change streams or a message broker keeping the two in sync. You don't have to pick one database for everything.
