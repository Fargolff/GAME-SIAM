# Android Launch Compliance Checklist

## Required Before Internal Testing

- Google Play Console account ready.
- Firebase project created.
- Supabase project created.
- Privacy policy URL live.
- Support email live.
- Account deletion URL or support deletion workflow live.
- IARC age rating completed.
- Google Play Data Safety form completed by owner.
- Release keystore created and backed up securely.
- Package name confirmed: `com.gamesiam.idle`.
- Version code/version name set for release.
- Paid gacha disabled until Google purchase validation works in production.

## In-Game Compliance

- Gacha odds visible before pull.
- Settings includes support path.
- Settings includes account deletion request path.
- Privacy/support/deletion text uses real live URLs/emails before launch.
- Purchase flow validates Google receipt server-side before granting premium currency.
- Duplicate purchase tokens grant exactly once.

## Build QA

- Build AAB.
- Install APK/AAB-derived build on emulator.
- Test at least 2 real Android devices.
- Verify no black screen on launch.
- Verify all sprites load.
- Verify no clipped Thai text on 720p viewport.
- Verify no network/weak network behavior.
- Verify pending purchase resume after app kill.

## Launch Monitoring

- Crashlytics active.
- Firebase Analytics events flowing.
- Supabase Edge Functions healthy.
- Purchase validation healthy.
- Economy ledger writes every grant/spend.
- Support inbox monitored.
- Rollback playbook ready.
