# Google Play Data Safety Draft Inputs

Status: draft. The owner must verify every answer in Google Play Console before submission.

## App Category

- Game: 2D idle auto-battler hero collector
- Monetization: in-app purchases, randomized gacha hero shards
- Ads: no ads at launch
- Target platform: Android

## Data Types Expected

Collected:

- User IDs: Supabase anonymous id, device restore token, optional linked Google Play account id later.
- Purchase history: product id, purchase token, validation/grant status.
- App activity: tutorial events, battle events, wave progress, upgrades, gacha events, offline claim events.
- App info and performance: crash logs, diagnostics, device model, OS version, app version, session health.
- User-generated support messages: only if player contacts support.

Not collected at launch unless added later:

- Precise location
- Contacts
- Photos/videos/audio
- Health/fitness data
- Financial payment card details
- Advertising ID, unless Firebase/Google configuration later enables it

## Purposes

- App functionality: save progress, sync account, grant rewards, purchases, gacha, support.
- Analytics: onboarding funnel, retention, balance, feature usage.
- Developer communications: support replies if user contacts support.
- Fraud prevention/security: purchase validation, duplicate grant prevention, economy ledger audit.
- Crash diagnostics: crash-free sessions and stability fixes.

## Sharing

Data is processed by:

- Supabase: backend database, auth, Edge Functions.
- Firebase/Google: analytics, Crashlytics, Play Billing, Play Console.

Mark sharing according to Google Play Console definitions after reviewing provider terms and actual SDK configuration.

## Security

- Data in transit should use HTTPS.
- Server-authoritative economy keeps premium currency, purchases, gacha, and ledger on backend.
- Purchase tokens are idempotent and validated server-side.
- Client local save is display/offline cache only, not source of truth for premium economy.

## Deletion

Before launch:

- Provide public support email: [SUPPORT EMAIL]
- Provide account deletion URL or in-app request path: [ACCOUNT DELETION URL]
- Implement backend deletion workflow or support-operated deletion runbook.

## Owner Review Checklist

- Replace all placeholders.
- Confirm Firebase Analytics collection settings.
- Confirm Crashlytics data fields.
- Confirm Supabase region and retention.
- Confirm whether Google Advertising ID is disabled or collected.
- Confirm IARC age rating answers.
- Confirm randomized purchase odds page is visible before purchase/pull.
