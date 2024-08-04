# WunderGraph publish client package example

This example shows how to bundle the generated client code for distribution to NPM.

## Getting started

```bash

docker run -d \
  --name=postgres\
  -v db-postgres01:/var/lib/postgresql/data \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=9987654321qaz \
  -e POSTGRES_DB=postgres \
  -p 5433:5432 \
  postgres:16.3-alpine
  
npx postgraphile -c 'postgres://postgres:9987654321qaz@127.0.0.1:5433/DVD' \
  --watch \
  --skip-plugins graphile-build:NodePlugin \
  --enhance-graphiql \
  --dynamic-json \
  --allow-explain

=== examples ===
https://docs.wundergraph.com/docs/architecture

https://github.com/wundergraph/wundergraph/tree/main/examples
npx create-wundergraph-app wundergraph-astro01 -E astro

=== wundergraph server ===
https://docs.wundergraph.com/docs/architecture/wundergraph-server
https://docs.wundergraph.com/docs/guides/context-factory
https://docs.wundergraph.com/docs/wundergraph-server-ts-reference/custom-graphql-servers

=== wundergraph node ===
https://docs.wundergraph.com/docs/features/typescript-operations

===  authorize ===
https://docs.wundergraph.com/docs/auth/token-based-auth/auth-js#create-userinfo-endpoint
https://docs.wundergraph.com/docs/features/type-script-webhooks-to-integrate-third-party-applications

=== production or project ===
https://github.com/wundergraph/publish-client/
https://docs.wundergraph.com/docs/guides/bundle-generated-client-for-distribution
https://docs.wundergraph.com/docs/architecture/wundergraph-conventions#everything-you-need-to-know-about-using-environment-variables

```

```bash

# wg-proxy-node
- localhost:9991

# wg-proxy-server
- localhost:9992

# flow
- client -> wg-proxy-node -> wg-proxy-server -> wg-proxy-node -> client

```

### Install dependencies

```shell
pnpm i
```

### Build the client

```shell
pnpm build
```

## How it works

The example is setup as a monorepo using [pnpm](https://pnpm.io/). The WunderGraph app lives in `wg-proxy` and uses a default config, all code is generated in `wg-proxy/.wundergraph/generated`. In the `packages` folder you can find the `client` and `consumer` package. The `client` package doesn't contain any source code and is used to publish the bundled client to NPM. The `consumer` package is a simple example of how to use the generated client code.

We bundle the generated client using `tsup` with the following config:

```ts
import { defineConfig } from "tsup";

export default defineConfig({
  entry: ["../../wg-proxy/.wundergraph/generated/client.ts"],
  splitting: false,
  bundle: true,
  clean: true,
  dts: true,
  outDir: "dist",
  format: ["cjs", "esm"],
});
```

- `entry` points to the generated client code in our wg-proxy.
- `splitting` is disabled because we want to bundle everything into a single file.
- `bundle` is enabled to bundle all imports except dependencies into a single file, this is required so TypeScript operations types are included in the bundle.
- `clean` is enabled to remove the `dist` folder before building.
- `dts` is enabled to generate type definitions.
- `outDir` is set to `dist` to output the bundled code into the `dist` folder
- `format` is set to `cjs` and `esm` to generate CommonJS and ES Modules. Currently the WunderGraph SDK only supports CommonJS, but we plan to support ES Modules in the future.

Since TypeScript operations depend on Zod, it's added to the `dependencies` in `package.json` of the client package and it's required to add `zod` to `types` in the compiler options of `tsconfig.json`:

```json
{
  "compilerOptions": {
    "types": ["zod"]
  }
}
```

The last step is to configure `WG_PUBLIC_NODE_URL` to set the URL of your WunderGraph app, in the example it's included in the build script, but you should configure it in your CI/CD pipeline environment.

```shell
WG_PUBLIC_NODE_URL=https://api.my.org pnpm generate && pnpm build:client
```

After building the client, it's ready to be published to NPM, Google Packages or a private package registry.

## Learn More

- [Client reference](https://docs.wundergraph.com/docs/clients-reference/typescript-client)
- [TSUP](https://tsup.egoist.dev/)

## Deploy to WunderGraph Cloud

[![Deploy to WunderGraph](https://wundergraph.com/button)](https://cloud.wundergraph.com/new/clone?templateName=simple)

## Got Questions?

Join us on [Discord](https://wundergraph.com/discord)!
