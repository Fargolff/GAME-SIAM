# Rollback Playbook

## Rollback Triggers

- Critical crash spike.
- Black screen on launch.
- Duplicate paid grant.
- Purchase validation outage.
- Economy exploit.
- Supabase production migration error.
- Store compliance issue.

## Immediate Actions

1. Pause rollout in Google Play Console.
2. Disable paid gacha banner server-side.
3. Keep support email monitored.
4. Preserve logs and economy ledger rows.
5. Snapshot Supabase production database before manual fixes.
6. Prepare hotfix AAB or backend rollback.

## Backend Rollback

- Revert latest Edge Function deploy.
- Reapply previous migration snapshot only after backup.
- Keep idempotency tables and purchase receipts intact.
- Never delete purchase receipt history during rollback.

## Client Rollback

- Upload hotfix AAB with incremented version code.
- Keep package id unchanged.
- Verify install/update path.
- Smoke test new player, existing player, purchase resume.

## Communication

- Store release notes: concise fix summary.
- Support macro: known issue, status, expected fix window.
- Internal incident notes: timeline, root cause, action items.
