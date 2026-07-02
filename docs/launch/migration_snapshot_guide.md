# Migration Snapshot Guide

Before production launch:

1. Export current Supabase schema.
2. Export Edge Function versions.
3. Record environment variables, excluding secret values.
4. Record RLS policy checks.
5. Record purchase idempotency constraints.
6. Record economy ledger table row count.

## Required Snapshot Artifacts

- SQL schema dump
- Migration list
- Edge Function commit/build id
- Gacha banner/rates config
- Product id to premium grant config
- Launch AAB version code/name

## Safety Notes

- Do not store service role keys in the repository.
- Do not commit Google Play API credentials.
- Do not delete purchase receipts or ledger rows during rollback.
