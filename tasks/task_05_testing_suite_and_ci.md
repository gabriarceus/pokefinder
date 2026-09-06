# Task 05: Test Suite Expansion, Unused Dependency Cleanup and CI

- **Status:** Open
- **Roadmap Reference:** [ROADMAP.md §5.4, §5.5, §9.4](file:///C:/Users/gabri/Documents/GitHub/pokefinder/ROADMAP.md#L592-L672)
- **Priority:** P0 (Quality & Engineering Foundation)

---

## 1. Context & Objectives

While the test suite has grown from two initial widget tests to 13 files, substantial test coverage gaps remain across critical business logic. Key BLoCs (`HomeBloc`, `PokemonBloc`, `MoveDetailCubit`), data strategies (`DataRepository`), and storage layers lack automated unit tests. Some test files are misnamed (e.g. `home_page_test.dart` only tests an isolated widget rather than the full home page flow), and there are no integration journey tests.

Moreover, several declared dependencies appear unused in code (`flutter_animate`, `gap`, `pokeball_widget`, `flutter_gen`), while script tooling (`path`, `yaml`) resides under runtime dependencies instead of `dev_dependencies`.

Finally, the repository completely lacks a Continuous Integration (CI) pipeline, allowing regressions, formatting drift, and out-of-sync generated code to be pushed undetected.

The goal of this task is to prune dependencies, implement high-value BLoC and integration journey tests, and establish a strict GitHub Actions CI workflow matching the pinned FVM Flutter version.

---

## 2. Impacted Files & Architecture Layers

- **Dependencies & Configuration:**
  - `pubspec.yaml` / `pubspec.lock`
  - `.fvmrc` (pinned Flutter SDK verification)
- **CI / Automation:**
  - `.github/workflows/ci.yml`
- **Tests:**
  - `test/unit/` (BLoCs, Cubits, Repositories, DataSources)
  - `test/widget/` (Complete Home and Detail page flows)
  - `test/integration/` (Critical user journeys)

---

## 3. Action Items

### 3.1 Dependency and Lockfile Hygiene (§9.4)
- [ ] Audit dependencies; remove unused packages (`flutter_animate`, `gap`, `pokeball_widget`, `flutter_gen`).
- [ ] Move build/script dependencies (`path`, `yaml`) to `dev_dependencies`.
- [ ] Align lockfile using `fvm flutter pub get` matching `.fvmrc`.
- [ ] Re-run code generators (`fvm dart run build_runner build --delete-conflicting-outputs`) to ensure generated files match dependencies.

### 3.2 Automated CI Pipeline (§5.5)
- [ ] Create `.github/workflows/ci.yml` executing on push and PR to `main`:
  1. FVM Flutter setup with caching.
  2. `fvm flutter pub get`.
  3. Format verification (`dart format --output=none --set-exit-if-changed .`).
  4. Static analysis (`flutter analyze --fatal-infos`).
  5. Code generation consistency check (verify no uncommitted diffs in generated code).
  6. Localization generation validation.
  7. Run test suite (`flutter test --coverage`).

### 3.3 Test Suite Expansion (§5.4)
- [ ] **BLoC and State Tests:**
  - `HomeBloc`: search normalization, autocomplete suggestions, clear cache event, error state.
  - `PokemonBloc`: initial load, cached load, encounter fetch, alternate form toggle, retry triggers.
  - `MoveDetailCubit`: fetch details, error handling, retry.
- [ ] **Data & Repository Tests:**
  - `PokemonRepositoryImpl`: full mapping from DTO to domain model.
  - `DataRepository`: cache hit, cache miss, expiration, offline fallback.
  - `DioApiClient`: timeout, cancellation, network error handling.
- [ ] **Critical Integration Journeys:**
  - Valid search → detail navigation.
  - Unknown Pokémon → not found error → edit/retry.
  - Offline cached Pokémon inspection.
  - Direct `/pokemon/:nameOrId` navigation.
  - Alternate form selection and rollback on failure.
  - Language change persistence across app lifecycle.

---

## 4. Acceptance Criteria

- [ ] All unused runtime dependencies are removed from `pubspec.yaml`.
- [ ] Every Pull Request to `main` automatically triggers CI and blocks merge on formatting, analysis, code gen discrepancy, or test failure.
- [ ] CI uses the exact Flutter version defined in `.fvmrc`.
- [ ] Comprehensive unit and BLoC tests cover all business logic branches.
- [ ] Automated tests verify the 8 critical integration journeys listed in §5.4.

---

## 5. Testing & Verification Plan

- [ ] Execute `fvm flutter analyze` locally to verify 0 issues.
- [ ] Run full test suite with coverage: `fvm flutter test --coverage`.
- [ ] Run simulated CI steps locally to verify script and command exit codes.
