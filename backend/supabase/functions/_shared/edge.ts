import {
  claimOfflineReward,
  createEconomyState,
  type EconomyState,
  finishBattle,
  getGachaBanner,
  grantPurchase,
  profileSnapshot,
  pullGacha,
  startBattle,
  upgradeHero,
  validateGooglePurchase,
} from "./economy.ts";

export const REQUIRED_FUNCTIONS = [
  "get_profile",
  "sync_client_state",
  "start_battle",
  "finish_battle",
  "claim_offline_reward",
  "upgrade_hero",
  "get_gacha_banner",
  "pull_gacha",
  "validate_google_purchase",
  "grant_purchase",
] as const;

export type FunctionName = typeof REQUIRED_FUNCTIONS[number];

export type EdgeRuntimeOptions = {
  allowTestReceipts?: boolean;
};

const globalState = createEconomyState();

export function serveFunction(name: FunctionName): void {
  Deno.serve((request) => handleFunction(name, request, globalState));
}

export async function handleFunction(
  name: FunctionName,
  request: Request,
  state: EconomyState = createEconomyState(),
  options: EdgeRuntimeOptions = {},
): Promise<Response> {
  try {
    return await handleFunctionUnsafe(name, request, state, options);
  } catch (error) {
    if (error instanceof Response) return error;
    throw error;
  }
}

async function handleFunctionUnsafe(
  name: FunctionName,
  request: Request,
  state: EconomyState,
  options: EdgeRuntimeOptions,
): Promise<Response> {
  if (request.method !== "POST") return json({ error: "POST required" }, 405);
  const body = await readJson(request);

  if (name === "get_gacha_banner") return json({ banner: getGachaBanner() });
  if (name === "validate_google_purchase") {
    const purchaseToken = requireString(body, "purchaseToken");
    const productId = requireString(body, "productId");
    return json({
      validation: validateGooglePurchase(purchaseToken, productId, options),
    });
  }

  const profileId = requireString(body, "profileId");
  if (name === "get_profile" || name === "sync_client_state") {
    return json({ profile: profileSnapshot(state, profileId) });
  }
  if (name === "start_battle") {
    return json({
      ticket: startBattle(
        state,
        profileId,
        requireString(body, "requestId"),
        requireInt(body, "waveId"),
      ),
    });
  }
  if (name === "finish_battle") {
    return json({
      reward: finishBattle(
        state,
        requireString(body, "ticketId"),
        requireResult(body, "result"),
      ),
    });
  }
  if (name === "claim_offline_reward") {
    return json({
      reward: claimOfflineReward(
        state,
        profileId,
        Math.floor(Date.now() / 1000),
      ),
    });
  }
  if (name === "upgrade_hero") {
    return json({
      upgrade: upgradeHero(state, profileId, requireString(body, "heroId")),
    });
  }
  if (name === "pull_gacha") {
    return json({
      pull: pullGacha(
        state,
        profileId,
        requireString(body, "requestId"),
        requireInt(body, "count"),
      ),
    });
  }
  if (name === "grant_purchase") {
    const purchaseToken = requireString(body, "purchaseToken");
    const productId = requireString(body, "productId");
    const validation = validateGooglePurchase(
      purchaseToken,
      productId,
      options,
    );
    const granted = validation.valid &&
      grantPurchase(state, profileId, purchaseToken, validation.premiumAmount);
    return json({ granted, validation });
  }

  return json({ error: "unknown function" }, 404);
}

async function readJson(request: Request): Promise<Record<string, unknown>> {
  try {
    const value = await request.json();
    return typeof value === "object" && value !== null
      ? value as Record<string, unknown>
      : {};
  } catch {
    return {};
  }
}

function requireString(body: Record<string, unknown>, key: string): string {
  const value = body[key];
  if (typeof value !== "string" || value.length === 0) {
    throw new Response(`${key} required`, { status: 400 });
  }
  return value;
}

function requireInt(body: Record<string, unknown>, key: string): number {
  const value = body[key];
  if (typeof value !== "number" || !Number.isInteger(value)) {
    throw new Response(`${key} integer required`, { status: 400 });
  }
  return value;
}

function requireResult(
  body: Record<string, unknown>,
  key: string,
): "win" | "loss" {
  const value = body[key];
  if (value !== "win" && value !== "loss") {
    throw new Response(`${key} win/loss required`, { status: 400 });
  }
  return value;
}

function json(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: { "content-type": "application/json" },
  });
}
