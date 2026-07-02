import {
  balance,
  claimOfflineReward,
  createEconomyState,
  finishBattle,
  getGachaBanner,
  grantPurchase,
  OFFLINE_CAP_SECONDS,
  pullGacha,
  rewardForWave,
  startBattle,
  validateGooglePurchase,
} from "./economy.ts";

function assertEquals<T>(actual: T, expected: T): void {
  if (actual !== expected) {
    throw new Error(`Expected ${expected}, got ${actual}`);
  }
}

Deno.test("battle ticket and finish are idempotent", () => {
  const state = createEconomyState();
  const first = startBattle(state, "p1", "req-1", 3);
  const second = startBattle(state, "p1", "req-1", 3);
  assertEquals(second, first);

  const reward1 = finishBattle(state, first.id, "win");
  const reward2 = finishBattle(state, first.id, "win");
  assertEquals(reward1.gold > 0, true);
  assertEquals(reward2.gold, 0);
  assertEquals(balance(state, "p1", "gold"), reward1.gold);
});

Deno.test("offline rewards cap at 8 hours and ignore backward clock", () => {
  const state = createEconomyState();
  state.highestCleared.p1 = 5;
  state.lastOfflineClaim.p1 = 1_000;

  const capped = claimOfflineReward(state, "p1", 1_000 + 10 * 60 * 60);
  assertEquals(capped.seconds, OFFLINE_CAP_SECONDS);
  assertEquals(capped.gold > 0, true);

  const tampered = claimOfflineReward(state, "p1", 500);
  assertEquals(tampered.seconds, 0);
  assertEquals(tampered.gold, 0);
});

Deno.test("wave rewards support the 100-wave campaign cap", () => {
  const wave20 = rewardForWave(20);
  const wave21 = rewardForWave(21);
  const wave100 = rewardForWave(100);
  const wave100Again = rewardForWave(100);

  assertEquals(wave20.gold, 415);
  assertEquals(wave20.essence, 7);
  assertEquals(wave21.gold, 433);
  assertEquals(wave21.essence, 7);
  assertEquals(wave100.gold, 1855);
  assertEquals(wave100.essence, 27);
  assertEquals(wave100.premium, 0);
  assertEquals(wave100Again.gold, wave100.gold);
  assertEquals(wave100Again.essence, wave100.essence);
  assertEquals(wave100Again.premium, wave100.premium);
});

Deno.test("purchase receipt grants once and writes ledger", () => {
  const state = createEconomyState();
  assertEquals(grantPurchase(state, "p1", "token-1", 300), true);
  assertEquals(grantPurchase(state, "p1", "token-1", 300), false);
  assertEquals(balance(state, "p1", "premium"), 300);
  assertEquals(state.ledger.length, 1);
  assertEquals(state.ledger[0].reason, "purchase");
});

Deno.test("google purchase validation rejects fake tokens by default", () => {
  const fake = validateGooglePurchase("tok", "premium_small");
  assertEquals(fake.valid, false);
  assertEquals(fake.premiumAmount, 0);

  const unknownProduct = validateGooglePurchase(
    "test_purchase_1",
    "premium_unknown",
    { allowTestReceipts: true },
  );
  assertEquals(unknownProduct.valid, false);
});

Deno.test("test receipts require server-side opt-in", () => {
  const disabled = validateGooglePurchase("test_purchase_1", "premium_small");
  const enabled = validateGooglePurchase("test_purchase_1", "premium_small", {
    allowTestReceipts: true,
  });
  assertEquals(disabled.valid, false);
  assertEquals(enabled.valid, true);
  assertEquals(enabled.premiumAmount, 300);
});

Deno.test("gacha banner publishes launch odds and 40 hero pool", () => {
  const banner = getGachaBanner() as {
    rates: Record<string, number>;
    poolSize: number;
    pityAt: number;
  };
  const total = Object.values(banner.rates).reduce(
    (sum, value) => sum + value,
    0,
  );
  assertEquals(total, 10_000);
  assertEquals(banner.poolSize, 40);
  assertEquals(banner.pityAt, 80);
});

Deno.test("gacha 10-pull guarantees A+ and duplicate request is idempotent", () => {
  const state = createEconomyState();
  grantPurchase(state, "p1", "token-gacha", 2_000);
  const first = pullGacha(state, "p1", "pull-1", 10);
  const second = pullGacha(state, "p1", "pull-1", 10);
  assertEquals(first.ok, true);
  assertEquals(first.results.length, 10);
  assertEquals(
    first.results.some((result) =>
      result.rarity === "S" || result.rarity === "A"
    ),
    true,
  );
  assertEquals(second.results[0].heroId, first.results[0].heroId);
});

Deno.test("gacha pity guarantees S before 80 pulls", () => {
  const state = createEconomyState();
  state.gachaPity.p1 = 79;
  grantPurchase(state, "p1", "token-pity", 300);
  const pull = pullGacha(state, "p1", "pull-pity", 1);
  assertEquals(pull.results[0].rarity, "S");
  assertEquals(pull.pityAfter, 0);
});
