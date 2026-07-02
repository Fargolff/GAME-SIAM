export const OFFLINE_CAP_SECONDS = 8 * 60 * 60;

export type Currency = "gold" | "essence" | "premium";

export type LedgerEntry = {
  key: string;
  profileId: string;
  currency: Currency;
  amount: number;
  balanceAfter: number;
  reason: string;
};

export type BattleTicket = {
  id: string;
  profileId: string;
  waveId: number;
  seed: number;
  consumed: boolean;
};

export type GachaRarity = "S" | "A" | "B" | "C" | "D";

export type GachaPull = {
  id: string;
  profileId: string;
  pityBefore: number;
  pityAfter: number;
  cost: Record<Currency, number>;
  results: Array<{ heroId: string; rarity: GachaRarity; shards: number }>;
};

export type PurchaseValidation = {
  valid: boolean;
  premiumAmount: number;
  reason?: string;
};

export type PurchaseValidationOptions = {
  allowTestReceipts?: boolean;
};

export type EconomyState = {
  balances: Record<string, Record<Currency, number>>;
  highestCleared: Record<string, number>;
  lastOfflineClaim: Record<string, number>;
  battleTickets: Record<string, BattleTicket>;
  heroLevels: Record<string, Record<string, number>>;
  gachaPulls: Record<string, GachaPull>;
  gachaPity: Record<string, number>;
  purchaseTokens: Set<string>;
  idempotencyKeys: Set<string>;
  ledger: LedgerEntry[];
};

const HERO_POOL: Array<{ heroId: string; rarity: GachaRarity }> = [
  { heroId: "S01_GARUDA_VAYUDEJ", rarity: "S" },
  { heroId: "S02_NAGA_SASINAKA", rarity: "S" },
  { heroId: "S03_YAKSHA_KRAIASURA", rarity: "S" },
  { heroId: "A01_KINNARI_PIMPPRUEKSA", rarity: "A" },
  { heroId: "A02_TIGER_PLOENGPAYAK", rarity: "A" },
  { heroId: "A03_HUMAN_ARUNRAT", rarity: "A" },
  { heroId: "A04_VANARA_KALAVANARA", rarity: "A" },
  { heroId: "A05_MAKARA_MAKORNKRAM", rarity: "A" },
  { heroId: "A06_SPIRIT_RAMPAN_MASK", rarity: "A" },
  { heroId: "A07_HUMAN_CHANGJAKKAEW", rarity: "A" },
  { heroId: "B01_GARUDA_MEKHAVI", rarity: "B" },
  { heroId: "B02_NAGA_KLEDKRAM", rarity: "B" },
  { heroId: "B03_YAKSHA_KHUNPHA", rarity: "B" },
  { heroId: "B04_HUMAN_DARIN", rarity: "B" },
  { heroId: "B05_KINNARA_RAVIKAN", rarity: "B" },
  { heroId: "B06_BEAST_SINGKHON", rarity: "B" },
  { heroId: "B07_DRYAD_BUTSABA", rarity: "B" },
  { heroId: "B08_HUMAN_MUENMONTRA", rarity: "B" },
  { heroId: "B09_SPIRIT_AMBERNIGHT", rarity: "B" },
  { heroId: "B10_MERFOLK_MUKWAREE", rarity: "B" },
  { heroId: "C01_HUMAN_JETSIAM", rarity: "C" },
  { heroId: "C02_KHACHASIH_LOHDIN", rarity: "C" },
  { heroId: "C03_HUMAN_PANA", rarity: "C" },
  { heroId: "C04_HUMAN_CHABA", rarity: "C" },
  { heroId: "C05_VANARA_JORJAN", rarity: "C" },
  { heroId: "C06_NAGA_NILNATEE", rarity: "C" },
  { heroId: "C07_GARUDA_PEEKTHONG", rarity: "C" },
  { heroId: "C08_CROCODILE_KUMPHIL", rarity: "C" },
  { heroId: "C09_KINNARI_KAEWKANGSADAN", rarity: "C" },
  { heroId: "C10_SPIRIT_KHOMKHAM", rarity: "C" },
  { heroId: "D01_HUMAN_PHAIKLA", rarity: "D" },
  { heroId: "D02_HUMAN_KHAMPAN", rarity: "D" },
  { heroId: "D03_HUMAN_PRANNOI", rarity: "D" },
  { heroId: "D04_HUMAN_TAEMTHONG", rarity: "D" },
  { heroId: "D05_VANARA_JUKJIK", rarity: "D" },
  { heroId: "D06_NAGA_BUABUCHA", rarity: "D" },
  { heroId: "D07_GARUDA_LOMPEEK", rarity: "D" },
  { heroId: "D08_HUMAN_THIWA", rarity: "D" },
  { heroId: "D09_CONSTRUCT_SILADIN", rarity: "D" },
  { heroId: "D10_SPIRIT_OUNRUEN", rarity: "D" },
];

const GACHA_RATES: Record<GachaRarity, number> = {
  S: 200,
  A: 800,
  B: 2500,
  C: 3500,
  D: 3000,
};

const GOOGLE_PLAY_PRODUCTS: Record<string, number> = {
  premium_small: 300,
  premium_large: 1200,
};

const TEST_PURCHASE_TOKEN_PREFIX = "test_purchase_";

export function createEconomyState(): EconomyState {
  return {
    balances: {},
    highestCleared: {},
    lastOfflineClaim: {},
    battleTickets: {},
    heroLevels: {},
    gachaPulls: {},
    gachaPity: {},
    purchaseTokens: new Set(),
    idempotencyKeys: new Set(),
    ledger: [],
  };
}

export function profileSnapshot(
  state: EconomyState,
  profileId: string,
): Record<string, unknown> {
  return {
    profileId,
    balances: state.balances[profileId] ?? { gold: 0, essence: 0, premium: 0 },
    highestCleared: state.highestCleared[profileId] ?? 0,
    heroLevels: state.heroLevels[profileId] ?? {},
    gachaPity: state.gachaPity[profileId] ?? 0,
    ledgerRows:
      state.ledger.filter((row) => row.profileId === profileId).length,
  };
}

export function startBattle(
  state: EconomyState,
  profileId: string,
  requestId: string,
  waveId: number,
): BattleTicket {
  const ticketId = `${profileId}:${requestId}`;
  const existing = state.battleTickets[ticketId];
  if (existing) return existing;

  const ticket = {
    id: ticketId,
    profileId,
    waveId,
    seed: hashSeed(ticketId),
    consumed: false,
  };
  state.battleTickets[ticketId] = ticket;
  return ticket;
}

export function finishBattle(
  state: EconomyState,
  ticketId: string,
  result: "win" | "loss",
): Record<Currency, number> {
  const ticket = state.battleTickets[ticketId];
  if (!ticket || ticket.consumed || result !== "win") return emptyReward();

  ticket.consumed = true;
  const currentHighest = state.highestCleared[ticket.profileId] ?? 0;
  if (ticket.waveId <= currentHighest) return emptyReward();

  state.highestCleared[ticket.profileId] = ticket.waveId;
  const reward = rewardForWave(ticket.waveId);
  grant(state, `battle:${ticket.id}`, ticket.profileId, reward, "wave_clear");
  return reward;
}

export function claimOfflineReward(
  state: EconomyState,
  profileId: string,
  serverNowSeconds: number,
): Record<Currency, number> & { seconds: number } {
  const last = state.lastOfflineClaim[profileId] ?? serverNowSeconds;
  const seconds = Math.max(
    0,
    Math.min(serverNowSeconds - last, OFFLINE_CAP_SECONDS),
  );
  state.lastOfflineClaim[profileId] = Math.max(last, serverNowSeconds);

  const highest = state.highestCleared[profileId] ?? 0;
  const reward = {
    gold: Math.floor(seconds / 60) * highest * 2,
    essence: Math.floor(seconds / 900) * highest,
    premium: 0,
  };
  grant(
    state,
    `offline:${profileId}:${last}:${seconds}`,
    profileId,
    reward,
    "offline",
  );
  return { ...reward, seconds };
}

export function grantPurchase(
  state: EconomyState,
  profileId: string,
  purchaseToken: string,
  premiumAmount: number,
): boolean {
  if (purchaseToken.trim().length === 0 || premiumAmount <= 0) return false;
  if (state.purchaseTokens.has(purchaseToken)) return false;
  state.purchaseTokens.add(purchaseToken);
  grant(state, `purchase:${purchaseToken}`, profileId, {
    gold: 0,
    essence: 0,
    premium: premiumAmount,
  }, "purchase");
  return true;
}

export function validateGooglePurchase(
  purchaseToken: string,
  productId: string,
  options: PurchaseValidationOptions = {},
): PurchaseValidation {
  const premiumAmount = GOOGLE_PLAY_PRODUCTS[productId] ?? 0;
  if (premiumAmount <= 0) {
    return { valid: false, premiumAmount: 0, reason: "unknown_product" };
  }
  if (purchaseToken.trim().length === 0) {
    return {
      valid: false,
      premiumAmount: 0,
      reason: "purchase_token_required",
    };
  }
  if (
    options.allowTestReceipts === true &&
    purchaseToken.startsWith(TEST_PURCHASE_TOKEN_PREFIX)
  ) {
    return { valid: true, premiumAmount };
  }

  // Real Google Play Developer API receipt validation must replace this before paid launch.
  return {
    valid: false,
    premiumAmount: 0,
    reason: "google_play_validation_not_configured",
  };
}

export function upgradeHero(
  state: EconomyState,
  profileId: string,
  heroId: string,
): { upgraded: boolean; level: number; cost: number } {
  state.heroLevels[profileId] ??= {};
  const current = state.heroLevels[profileId][heroId] ?? 1;
  const cost = 80 + current * 45;
  if (
    !spend(state, `upgrade:${profileId}:${heroId}:${current}`, profileId, {
      gold: cost,
      essence: 0,
      premium: 0,
    }, "upgrade_hero")
  ) {
    return { upgraded: false, level: current, cost };
  }

  state.heroLevels[profileId][heroId] = current + 1;
  return { upgraded: true, level: current + 1, cost };
}

export function getGachaBanner(): Record<string, unknown> {
  return {
    bannerKey: "launch_pool",
    rates: GACHA_RATES,
    poolSize: HERO_POOL.length,
    tenPullGuarantee: "A+",
    pityAt: 80,
  };
}

export function pullGacha(
  state: EconomyState,
  profileId: string,
  requestId: string,
  count: number,
): GachaPull & { ok: boolean } {
  const safeCount = Math.max(1, Math.min(10, Math.floor(count)));
  const pullId = `${profileId}:${requestId}`;
  const existing = state.gachaPulls[pullId];
  if (existing) return { ...existing, ok: true };

  const cost = { gold: 0, essence: 0, premium: safeCount * 160 };
  if (!spend(state, `gacha-cost:${pullId}`, profileId, cost, "gacha_pull")) {
    const pity = state.gachaPity[profileId] ?? 0;
    return {
      id: pullId,
      profileId,
      pityBefore: pity,
      pityAfter: pity,
      cost,
      results: [],
      ok: false,
    };
  }

  const pityBefore = state.gachaPity[profileId] ?? 0;
  let pity = pityBefore;
  const results = Array.from({ length: safeCount }, (_, index) => {
    const rarity = pity + 1 >= 80
      ? "S"
      : rollRarity(hashSeed(`${pullId}:${index}`));
    pity = rarity === "S" ? 0 : pity + 1;
    const fallback = pickHero(rarity, hashSeed(`${pullId}:hero:${index}`));
    const duplicate =
      state.heroLevels[profileId]?.[fallback.heroId] !== undefined;
    state.heroLevels[profileId] ??= {};
    state.heroLevels[profileId][fallback.heroId] ??= 1;
    return {
      heroId: fallback.heroId,
      rarity: fallback.rarity,
      shards: duplicate ? 10 : 0,
    };
  });

  if (
    safeCount === 10 &&
    !results.some((result) => result.rarity === "S" || result.rarity === "A")
  ) {
    const guaranteed = HERO_POOL.find((hero) => hero.rarity === "A")!;
    results[9] = {
      heroId: guaranteed.heroId,
      rarity: guaranteed.rarity,
      shards: 0,
    };
  }

  state.gachaPity[profileId] = pity;
  const pull = {
    id: pullId,
    profileId,
    pityBefore,
    pityAfter: pity,
    cost,
    results,
  };
  state.gachaPulls[pullId] = pull;
  return { ...pull, ok: true };
}

export function balance(
  state: EconomyState,
  profileId: string,
  currency: Currency,
): number {
  return state.balances[profileId]?.[currency] ?? 0;
}

export function rewardForWave(waveId: number): Record<Currency, number> {
  const safeWave = Math.max(1, Math.min(100, Math.floor(waveId)));
  return {
    gold: 55 + safeWave * 18,
    essence: 2 + Math.floor(safeWave / 4),
    premium: 0,
  };
}

function emptyReward(): Record<Currency, number> {
  return { gold: 0, essence: 0, premium: 0 };
}

function grant(
  state: EconomyState,
  key: string,
  profileId: string,
  amounts: Record<Currency, number>,
  reason: string,
): void {
  if (state.idempotencyKeys.has(key)) return;
  state.idempotencyKeys.add(key);

  state.balances[profileId] ??= { gold: 0, essence: 0, premium: 0 };
  for (const currency of Object.keys(amounts) as Currency[]) {
    const amount = amounts[currency];
    if (amount === 0) continue;
    const next = state.balances[profileId][currency] + amount;
    state.balances[profileId][currency] = next;
    state.ledger.push({
      key,
      profileId,
      currency,
      amount,
      balanceAfter: next,
      reason,
    });
  }
}

function spend(
  state: EconomyState,
  key: string,
  profileId: string,
  amounts: Record<Currency, number>,
  reason: string,
): boolean {
  if (state.idempotencyKeys.has(key)) return false;
  state.balances[profileId] ??= { gold: 0, essence: 0, premium: 0 };

  for (const currency of Object.keys(amounts) as Currency[]) {
    if (state.balances[profileId][currency] < amounts[currency]) return false;
  }

  state.idempotencyKeys.add(key);
  for (const currency of Object.keys(amounts) as Currency[]) {
    const amount = amounts[currency];
    if (amount === 0) continue;
    const next = state.balances[profileId][currency] - amount;
    state.balances[profileId][currency] = next;
    state.ledger.push({
      key,
      profileId,
      currency,
      amount: -amount,
      balanceAfter: next,
      reason,
    });
  }
  return true;
}

function rollRarity(seed: number): GachaRarity {
  const roll = seed % 10000;
  let cursor = 0;
  for (const rarity of ["S", "A", "B", "C", "D"] as GachaRarity[]) {
    cursor += GACHA_RATES[rarity];
    if (roll < cursor) return rarity;
  }
  return "D";
}

function pickHero(
  rarity: GachaRarity,
  seed: number,
): { heroId: string; rarity: GachaRarity } {
  const pool = HERO_POOL.filter((hero) => hero.rarity === rarity);
  return pool[seed % pool.length] ?? HERO_POOL[0];
}

function hashSeed(value: string): number {
  let hash = 2166136261;
  for (let i = 0; i < value.length; i += 1) {
    hash ^= value.charCodeAt(i);
    hash = Math.imul(hash, 16777619);
  }
  return hash >>> 0;
}
