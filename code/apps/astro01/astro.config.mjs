import { defineConfig } from "astro/config";
import "dotenv/config";
import node from "@astrojs/node";
import svelte from "@astrojs/svelte";

console.log(`################# NODE_ENV #################`);
[
  "NODE_ENV",
  "HOST",
  "PORT",
].forEach(item=>console.log(`${item} ==> ${process.env[item]}`));
console.log(`################# NODE_ENV #################`);

// https://astro.build/config
export default defineConfig({
  integrations: [svelte()],
  devToolbar: {
    enabled: false,
  },
  output: "server",
  adapter: node({
    mode: "standalone",
  }),
  server: {
    host: process.env.HOST,
    port: +process.env.PORT,
  },
});
