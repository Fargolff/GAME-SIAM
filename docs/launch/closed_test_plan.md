# Closed Test Plan

Goal: validate first-session clarity, crash stability, economy safety, purchase sandbox flow, and wave 1-30 balance before open testing.

## Scope

- Region: Thailand first
- Platform: Android only
- Test size: 20-50 testers
- Build type: Google Play internal/closed testing track
- Data policy: wipe allowed during closed test
- Monetization: license tester purchase flow only; no production paid traffic

## Entry Criteria

- APK/AAB build succeeds.
- Privacy policy URL is live.
- Support email is live.
- Account deletion request path is live.
- Gacha odds are visible before pull.
- Purchase validation works in sandbox before paid gacha is enabled.
- Firebase Analytics and Crashlytics are connected.
- Supabase staging backend is deployed.

## Test Missions

- New install to first battle under 30 seconds.
- First upgrade under 3 minutes.
- Clear waves 1-10.
- Lose at least one boss/checkpoint and understand next action.
- Open gacha odds page before pull.
- Pull gacha with free/staging currency.
- Attempt purchase with Google Play license tester account.
- Kill app during pending purchase and resume.
- Relaunch after offline period and claim reward.
- Switch Thai/English.
- Submit feedback form.

## Exit Criteria

- No P0 crash.
- No duplicate paid grants.
- No economy ledger gaps.
- Crash-free sessions at or above 98.5%.
- Tutorial completion at or above 70%.
- D1 retention target at or above 25%, or clear fix list exists.
- First 5 minutes can be described by testers in one sentence.
