import { createEconomyState } from "./economy.ts";
import {
  type EdgeRuntimeOptions,
  handleFunction,
  REQUIRED_FUNCTIONS,
} from "./edge.ts";

function assertEquals<T>(actual: T, expected: T): void {
  if (actual !== expected) {
    throw new Error(`Expected ${expected}, got ${actual}`);
  }
}

async function post(
  name: typeof REQUIRED_FUNCTIONS[number],
  body: Record<string, unknown>,
  state = createEconomyState(),
  options: EdgeRuntimeOptions = {},
) {
  const response = await handleFunction(
    name,
    new Request("http://local", {
      method: "POST",
      body: JSON.stringify(body),
    }),
    state,
    options,
  );
  return await response.json() as Record<string, unknown>;
}

Deno.test("all required phase 6 function names exist", () => {
  assertEquals(REQUIRED_FUNCTIONS.length, 10);
  assertEquals(REQUIRED_FUNCTIONS.includes("grant_purchase"), true);
});

Deno.test("battle edge flow grants once", async () => {
  const state = createEconomyState();
  const started = await post("start_battle", {
    profileId: "p1",
    requestId: "r1",
    waveId: 2,
  }, state);
  const ticket = (started.ticket as { id: string }).id;
  const first = await post("finish_battle", {
    profileId: "p1",
    ticketId: ticket,
    result: "win",
  }, state);
  const second = await post("finish_battle", {
    profileId: "p1",
    ticketId: ticket,
    result: "win",
  }, state);
  assertEquals(((first.reward as Record<string, number>).gold ?? 0) > 0, true);
  assertEquals((second.reward as Record<string, number>).gold, 0);
});

Deno.test("purchase edge rejects fake tokens by default", async () => {
  const state = createEconomyState();
  const result = await post("grant_purchase", {
    profileId: "p1",
    purchaseToken: "tok",
    productId: "premium_small",
  }, state);
  assertEquals(result.granted, false);
  assertEquals((result.validation as Record<string, unknown>).valid, false);
});

Deno.test("purchase edge test receipts grant once only with server opt-in", async () => {
  const state = createEconomyState();
  const options = { allowTestReceipts: true };
  const first = await post(
    "grant_purchase",
    {
      profileId: "p1",
      purchaseToken: "test_purchase_tok",
      productId: "premium_small",
    },
    state,
    options,
  );
  const second = await post(
    "grant_purchase",
    {
      profileId: "p1",
      purchaseToken: "test_purchase_tok",
      productId: "premium_small",
    },
    state,
    options,
  );
  assertEquals(first.granted, true);
  assertEquals(second.granted, false);
});
