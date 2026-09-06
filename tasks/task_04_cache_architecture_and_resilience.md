# Task 04: Cache Correctness, Clean Architecture and Resilience

- **Status:** Open
- **Roadmap Reference:** [ROADMAP.md §5.1, §5.2, §5.3, §9.2](file:///C:/Users/gabri/Documents/GitHub/pokefinder/ROADMAP.md#L482-L590), [PR 4 §12](file:///C:/Users/gabri/Documents/GitHub/pokefinder/ROADMAP.md#L1148-L1158)
- **Priority:** P0 / P1 (Architecture & Offline Stability)

---

## 1. Context & Objectives

The application currently has basic Hive response caching, but suffers from architectural leaks, fragility in edge cases, and brittle parsing:
- `HomeBloc` imports and depends directly on concrete `DataRepository` solely to clear the cache, violating Clean Architecture inward dependency rules.
- Expired cache entries are treated as complete misses; there is no stale-while-revalidate or offline fallback (if offline, an expired cache will fail rather than return cached data).
- `DateTime.now()` is hardcoded, making expiry testing brittle.
- Asynchronous cache writes can race with "clear cache", potentially re-saving old data right after a clear action.
- If a network request succeeds but local cache write fails, `networkFirst` can report the entire operation as failed.
- Remote payload parsing assumes array ordering (e.g. stats order) and non-empty collections, crashing with unexpected failures if optional fields or collections are missing.
- Asynchronous requests are neither cancelled on screen disposal nor deduplicated when triggered concurrently.

The goal of this task is to decouple the architecture via use cases, implement resilient stale-while-revalidate caching, ensure parsing tolerance, and enforce request deduplication and cancellation.

---

## 2. Impacted Files & Architecture Layers

- **Domain Layer:**
  - `lib/src/3_domain/use_cases/clear_cache_use_case.dart`
  - Clean up `Pokemon` entity (remove legacy duplicate `ability1`, `ability2`, `ability3` fields).
- **Application Layer:**
  - `lib/src/2_application/home/home_bloc.dart` (decouple from concrete `DataRepository`)
  - Concurrency transformers (`restartable()`, `droppable()`) in BLoCs
- **Data Layer:**
  - `lib/src/1_data/repositories/data_repository.dart` / `PokemonRepositoryImpl`
  - `lib/src/1_data/data_sources/hive_local_storage.dart`
  - `lib/src/1_data/models/` (DTO mapping: stat name lookup, nullable sprite fallbacks)
- **Core:**
  - Clock abstraction / provider for deterministic testing
  - Request deduplicator utility

---

## 3. Action Items

### 3.1 Restore Inward Dependency Direction (§5.2)
- [ ] Create `ClearCacheUseCase` in domain and register via Injectable.
- [ ] Remove `DataRepository` import from `HomeBloc`; inject and invoke `ClearCacheUseCase` instead.
- [ ] Replace broad `dynamic` contracts in `ApiClient` and `LocalStorage` with typed JSON map or generic boundaries.
- [ ] Deprecate and remove legacy `ability1`, `ability2`, and `ability3` from `Pokemon` domain entity, relying solely on the typed `abilities` collection.

### 3.2 Cache Hardening & Resilient Offline Behavior (§5.1)
- [ ] Inject a clock provider (`Clock`) into `DataRepository` for deterministic expiry unit testing.
- [ ] Implement `stale-while-revalidate` / `stale-if-error` cache policy:
  - If network fails while expired cached data exists, return the cached record flagged as `stale`.
  - Include cache metadata with repository results (`isFresh`, `isStale`, `fromCache`).
- [ ] Add cache schema versioning and envelope validation; evict malformed or obsolete envelopes safely.
- [ ] Implement cache size/entry bounds and LRU eviction policy.
- [ ] Separate network retrieval success from cache persistence failure: if cache write fails, return the valid network result rather than throwing an error.
- [ ] Ensure clearing cache cancels pending asynchronous writes to prevent race conditions.

### 3.3 Tolerant and Explicit DTO Parsing (§5.3)
- [ ] Model remote DTO fields as nullable where appropriate; provide safe defaults.
- [ ] Map Pokémon stats by explicit API stat name (`hp`, `attack`, `defense`, `special-attack`, `special-defense`, `speed`) rather than assuming array index order.
- [ ] Establish explicit sprite fallback order (official artwork → front default → other sprites).
- [ ] Avoid unguarded `.first` calls on collections; return typed `InvalidResponseFailure` with safe diagnostics when required collections are empty.

### 3.4 Request Deduplication & Cancellation (§9.2)
- [ ] Deduplicate concurrent in-flight requests for the same Pokémon endpoint.
- [ ] Implement BLoC event concurrency controls (`restartable()` for search input and form changes).
- [ ] Propagate Dio `CancelToken` when detail screens close.

---

## 4. Acceptance Criteria

- [ ] `HomeBloc` contains zero imports from `src/1_data/`.
- [ ] A previously viewed Pokémon loads successfully when completely offline, even after cache freshness has expired, displaying a subtle stale indicator.
- [ ] If local storage write fails (e.g. disk full), the user still receives the fetched network Pokémon data without error.
- [ ] Clearing the cache cannot be undone by a lagging in-flight response.
- [ ] API responses with reordered stat arrays map to the correct stat bars and values.
- [ ] Rapid typing or form toggling cancels superseded network requests without out-of-order race conditions.

---

## 5. Testing & Verification Plan

- [ ] **Unit Tests:**
  - `ClearCacheUseCase` execution and failure handling.
  - `DataRepository` caching strategies (fresh cache hit, expired cache with network success, expired cache with network failure fallback, corrupted envelope eviction).
  - Clock-manipulation expiry tests.
  - DTO parsing tests with JSON fixtures: normal payload, reordered stats, missing optional sprites, empty collections.
- [ ] **BLoC Tests:**
  - `HomeBloc` cache clear event flow.
  - Concurrency restartable behavior on search events.
