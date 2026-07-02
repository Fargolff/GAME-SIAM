$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$sqlPath = Join-Path $root "migrations/0001_economy.sql"
$sql = Get-Content -Raw -LiteralPath $sqlPath

$tables = @(
  "profiles",
  "hero_definitions",
  "hero_instances",
  "currencies",
  "inventory_items",
  "wave_progress",
  "battle_tickets",
  "battle_results",
  "gacha_banners",
  "gacha_rates",
  "gacha_pulls",
  "purchase_receipts",
  "economy_ledger"
)

$failures = New-Object System.Collections.Generic.List[string]
foreach ($table in $tables) {
  if ($sql -notmatch "create table if not exists public\.$table") {
    $failures.Add("Missing table: $table")
  }
  if ($sql -notmatch "alter table public\.$table enable row level security") {
    $failures.Add("Missing RLS enable: $table")
  }
}

$checks = @{
  "purchase token idempotency" = "purchase_token text not null unique"
  "battle finish idempotency" = "ticket_id uuid not null unique"
  "battle start idempotency" = "unique \(profile_id, request_id\)"
  "ledger source tracing" = "source_type text not null"
  "no negative currencies" = "amount bigint not null default 0 check \(amount >= 0\)"
}

foreach ($name in $checks.Keys) {
  if ($sql -notmatch $checks[$name]) {
    $failures.Add("Missing check: $name")
  }
}

$functions = @(
  "get_profile",
  "sync_client_state",
  "start_battle",
  "finish_battle",
  "claim_offline_reward",
  "upgrade_hero",
  "get_gacha_banner",
  "pull_gacha",
  "validate_google_purchase",
  "grant_purchase"
)

foreach ($function in $functions) {
  $entrypoint = Join-Path $root "functions/$function/index.ts"
  if (-not (Test-Path -LiteralPath $entrypoint)) {
    $failures.Add("Missing Edge Function: $function")
  }
}

if ($failures.Count -gt 0) {
  $failures | ForEach-Object { Write-Error $_ }
  exit 1
}

Write-Output "Phase 6 backend contract validation passed: $($tables.Count) tables, RLS, idempotency constraints, $($functions.Count) Edge Functions"
