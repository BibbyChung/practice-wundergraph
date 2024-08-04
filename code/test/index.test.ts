import { afterAll, beforeAll, describe, expect, test } from "@jest/globals";
import fetch from "node-fetch";
import { createTestServer } from "../app/wg-proxy/.wundergraph/generated/testing";

const wg = createTestServer({ fetch: fetch as any });
beforeAll(() => wg.start());
afterAll(() => wg.stop());

describe("test user/get API", () => {
  test("user/get", async () => {
    const client = wg.client();
    const result = await client.query({
      operationName: "user/get",
      input: {
        id: "666",
      },
    });
    if(result.error){
      throw result.error;
    }
    const id = result.data?.id ?? "";

    expect(id).toBe("666");
  });
});
