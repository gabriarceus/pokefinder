# Task 12: Accounts, Cloud Sync and Social (Future Epic — Do Not Build Yet)

- **Status:** Open (decision/spike only — no implementation authorized)
- **Priority:** P3 (unproven demand, very large effort)
- **Target Platforms:** Android & iOS only
- **Context:** Deliberately separated from Tasks 10–11 at the user's request.
  Nothing in this file may be built until product demand is validated and the
  backend, privacy, and cost decisions below are recorded. Task 11's local
  teams, favorites (`FavoritesCubit`), recents (`RecentHistoryCubit`), and
  preferences (`PreferencesCubit`) are the offline foundation this epic would
  one day sync — they must keep working fully offline regardless.

---

## 0. Gate: validate before building

- [ ] Write down the problem statement: what breaks today without accounts?
      (Current answer: nothing — favorites/teams/recents/preferences already
      persist locally in durable storage.)
- [ ] Success metric + time-boxed validation (e.g. settings-screen opt-in
      interest, export-request frequency). If the metric fails, close this file
      as `Cancelled` and keep the app local-first.
- [ ] Backend decision recorded: provider (Firebase/Supabase/custom),
      monthly cost ceiling, data residency, and exit strategy. No code before
      this exists.

## 1. Accounts & auth (spike scope only)

- [ ] Decide auth methods (sign-in with Apple / Google / email-link) and
      session handling; Apple review requires Sign in with Apple if third-party
      sign-in ships on iOS.
- [ ] Threat model: token storage (Keychain/Keystore, never Hive cache),
      revocation, account deletion (store-policy + GDPR right-to-erasure flow).
- [ ] Update the Task 10 logging policy FIRST: redaction rules for emails,
      tokens, UIDs; ban them from logs at all levels.

## 2. Cloud sync (design constraints for later)

- [ ] Sync set: favorites, local teams (Task 11), recents, preferences —
      lightweight refs only, never full PokeAPI payloads.
- [ ] Conflict policy decided upfront (last-write-wins vs. merge per
      collection), offline-first: local writes always win locally, sync is
      best-effort background with visible pending/failed states + retry.
- [ ] Schema versioning + migration for every synced record; corrupt cloud
      records quarantined, never crash the local list.

## 3. Social / community (highest risk — separate gate)

- [ ] Requires its own moderation, reporting, blocking, and abuse-handling
      plan plus store-policy review (UGC). Without a named moderator workflow,
      this section stays closed.
- [ ] Minimal viable slice if ever approved: share read-only team links
      (extends Task 10 canonical links) — no comments, no feeds, no DMs.

## 4. Privacy, legal, stores

- [ ] Privacy policy + terms + support URL + data-deletion instructions
      before any TestFlight/Play-track build with accounts.
- [ ] Data-collection disclosures (App Store privacy nutrition labels, Play
      Data safety) filled from the actual synced field list.
- [ ] Re-run the release-hardening checklist (bundle IDs, signing,
      permissions, icons, About/legal screen) with the new backend endpoints
      and transport-security settings.

---

## Acceptance criteria (to leave this file, not to ship)

- [ ] Either (a) validation failed → file marked `Cancelled` with reason, or
      (b) gate checklist (§0) + auth spike + sync design + privacy drafts are all
      recorded and reviewed.
- [ ] No implementation PRs reference this file until (b) is complete.

## Verification

- [ ] Decision record committed (this file updated with outcome + date).
- [ ] If cancelled: Task 11 local-first behavior unchanged and tested.
