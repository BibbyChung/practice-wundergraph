<script lang="ts">
  import { onMount } from "svelte";
  import { createClient } from "../../../../app/wg-proxy/.wundergraph/generated/client";

  let cityInfoStr: string;
  let userGetInfoStr: string;

  onMount(async () => {
    const client = createClient();

    client.setAuthorizationToken('xxxxxx00xxxx');
    const cityInfo = await client.query({
      operationName: "GetCities",
      input: {
        first: 3,
        offset: 1,
        orderBy: ["CITY_ID_ASC"],
      },
    });
    cityInfoStr = JSON.stringify(cityInfo.data);

    const userGetInfo = await client.query({
      operationName: "user/get",
      input: {
        id: "bbbb----999",
      },
    });
    userGetInfoStr = JSON.stringify(userGetInfo.data);
  });
</script>

{cityInfoStr}
<hr />
{userGetInfoStr}

<style>
  /* your styles go here */
</style>
