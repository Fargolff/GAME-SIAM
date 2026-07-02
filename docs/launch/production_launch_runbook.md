# Production Launch Runbook

Status: ready for owner review. Actual production launch remains blocked until Google Play, Supabase, Firebase, release signing, privacy URL, support email, and account deletion path are live.

## Pre-Launch Freeze

- Freeze content branch.
- Run validators 1-14.
- Export release AAB with production signing.
- Confirm production Supabase URL and anon key.
- Confirm Firebase Analytics and Crashlytics production project.
- Confirm Google Play purchase validation credentials.
- Confirm privacy policy/support/deletion URLs are live.

## Production Config

- Environment: `prod`
- Package id: `com.gamesiam.idle`
- Version name: `[RELEASE VERSION]`
- Version code: `[RELEASE VERSION CODE]`
- Backend: `[SUPABASE PROD URL]`
- Firebase app id: `[FIREBASE ANDROID APP ID]`
- Privacy URL: `[PUBLIC PRIVACY POLICY URL]`
- Support email: `[SUPPORT EMAIL]`
- Account deletion URL: `[ACCOUNT DELETION URL]`

## Launch Day Order

1. Verify Supabase prod health.
2. Verify Edge Functions deploy and env vars.
3. Verify purchase validation health using license tester.
4. Verify Firebase Analytics event arrival.
5. Verify Crashlytics receives a non-fatal test signal if available.
6. Build final AAB.
7. Upload to Google Play.
8. Complete pre-launch report checks.
9. Release to limited rollout.
10. Monitor first 24 hours.

## Smoke Test

- New install opens to battle scene.
- First battle starts under 30 seconds.
- First battle can win.
- Upgrade works.
- Offline claim does not exceed 8 hours.
- Gacha odds visible before pull.
- Purchase grants exactly once in license tester flow.
- Support and deletion paths are visible.

## Rollout Gates

- Crash-free sessions >= 98.5%.
- No duplicate paid grants.
- No economy ledger gaps.
- Backend latency/error rate acceptable.
- No critical store policy warnings.
