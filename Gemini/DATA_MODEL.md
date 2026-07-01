# CatchVault — Data Model Specification

This document defines the structural parameters, property mutations, data types, and entity relationships managed within the local-first SwiftData storage context. All application code must match these layout definitions exactly.

---

## 1. RELATIONSHIP CONFIGURATION & PERSISTENCE MATRIX

The SwiftData graph enforces structural relationships across core models. To maintain compatibility with native background CloudKit mirroring, every multi-entity relationship declares an explicit inverse path.

### Relationship Integrity & Cascade Policies

* **Trip ↔ Reservoir:** A `Trip` maps to exactly one `Reservoir`. A `Reservoir` preserves historical data linked to multiple `Trip` sessions. 
    * *Delete Rule:* `.nullify`. Deleting a reservoir does not clear its trips; the relation field clears gracefully.
* **Trip ↔ Angler:** Many-to-Many. A `Trip` holds a collection of one or many active `Angler` participants. An `Angler` aggregates history across many different `Trip` records.
    * *Delete Rule:* `.nullify`.
* **Trip ↔ FishCatch:** One-to-Many. A `Trip` strictly owns a sequential timeline of `FishCatch` records logged during its active session window.
    * *Delete Rule:* `.cascade`. Purging a `Trip` entry sweeps all associated catches from the storage layer.
* **FishCatch ↔ Angler:** Many-to-One. Every distinct landing entry maps back to exactly one specific `Angler` attached to that trip workspace.
    * *Delete Rule:* `.nullify`.
* **FishCatch ↔ Species:** Many-to-One. Every distinct landing entry maps back to exactly one explicit `Species`.
    * *Delete Rule:* `.nullify`.

---

## 2. ATTRIBUTE AND TYPE SPECIFICATIONS

### Entity: `Trip`
Tracks state and localized environmental metrics for an isolated fishing window.
* **`id: UUID`** (Primary Key, explicit system initialization)
* **`startTime: Date`** (Timestamp marking initialization check-in)
* **`endTime: Date?`** (Optional primitive; a `nil` state signifies an active live tracker session)
* **`notes: String?`** (Optional observer summary strings)
* **`migrated: Bool`** (Flag explicitly identifying a record created via the single-use legacy data cutover bridge)
* **`dataVersion: Int`** (Internal structural tracking marker)
* **`weatherSummary: String?`** (Flattened summary text compiled at check-out)
* **`temperature: Double?`** (Aggregated static double representation of Fahrenheit or Celsius values)
* **`windSpeed: Double?`** (Aggregated static wind velocity metrics)
* **`precipitation: Double?`** (Aggregated static rainfall accumulation readings)

### Entity: `FishCatch`
Captures precise physical characteristics and environmental telemetry at the raw point of capture.
* **`id: UUID`** (Primary Key)
* **`timestamp: Date`** (Instantaneous moment of capture extracted from system hardware clock)
* **`weight: Double`** (Strict numeric storage property representing precise decimal body mass metrics)
* **`latitude: Double?`** (Optional localized coordinate precision mapping)
* **`longitude: Double?`** (Optional localized coordinate precision mapping)
* **`imagePath: String?`** (Relative local path string tracking the sandboxed image payload saved directly to the device storage space)
* **`comment: String?`** (Optional freeform observer entry text)

### Entity: `Reservoir`
* **`id: UUID`** (Primary Key)
* **`name: String`** (Sanitized, whitespace-trimmed, lowercase-deduplicated unique descriptor identifier)

### Entity: `Angler`
* **`id: UUID`** (Primary Key)
* **`name: String`** (Sanitized, whitespace-trimmed, lowercase-deduplicated unique descriptor identifier)

### Entity: `Species`
* **`id: UUID`** (Primary Key)
* **`name: String`** (Sanitized, whitespace-trimmed, lowercase-deduplicated unique descriptor identifier)

---

## 3. MIGRATION & SYSTEM LAWS

### CloudKit Operational Compatibility
To prevent cloud serialization failures during native, automated mirroring to the user's private iCloud database, the model definitions enforce the following rules:
1. Every multi-entity relationship must declare an explicit inverse macro: `@Relationship(inverse: \...)`.
2. Attributes added post-initialization or synthesized during complex calculations utilize optional primitives or define hard default fallback parameters within the class constructor.

### Invalidation & Ingestion Guardrails
* **Deduplication Constraint:** All inputs targeted at `Angler.name`, `Reservoir.name`, and `Species.name` are executed through a data-sanitation layer before persistence. The engine applies case-insensitive trim scans across current collections inside the active `ModelContext` to eliminate redundant records caused by trailing white spaces or alternative case entries.
* **Idempotent Constraints:** Primary lookup identifiers match standard native type keys (`UUID`) to preserve predictability during local graph validation checks.
