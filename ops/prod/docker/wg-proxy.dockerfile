FROM --platform=linux/amd64 node:20.12-alpine AS pnpm

RUN --mount=type=cache,target=/var/cache/apk \
  apk add --no-cache bash git

RUN --mount=type=cache,id=pnpm,target=/pnpm/store \
  npm i -g pnpm@8.15.5

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

# --- cli ---

FROM pnpm AS build-cli

WORKDIR /app

COPY ./package.json ./pnpm-lock.yaml ./pnpm-workspace.yaml /app/

COPY ./code/apps/wg-proxy/package.json /app/code/apps/wg-proxy/package.json

RUN --mount=type=cache,id=pnpm,target=/pnpm/store \
  pnpm i --frozen-lockfile

COPY ./code/apps/wg-proxy /app/code/apps/wg-proxy/
COPY ./code/apps/wg-proxy/.env.production /app/code/apps/wg-proxy/.env

RUN cd /app/code/apps/wg-proxy && pnpm run build

# ARG _gitShortVer
# ARG _gitTime
# ENV _gitShortVer=${_gitShortVer:-"-"} \
#   _gitTime=${_gitTime:-"-"}

# --- runtime ---

FROM pnpm

WORKDIR /app

COPY ./package.json ./pnpm-lock.yaml ./pnpm-workspace.yaml /app/

COPY ./code/apps/wg-proxy/package.json /app/code/apps/wg-proxy/package.json 

RUN --mount=type=cache,id=pnpm,target=/pnpm/store \
  pnpm i --prod --frozen-lockfile

COPY --from=build-cli /app/code/apps/wg-proxy/.wundergraph /app/code/apps/wg-proxy/.wundergraph/
COPY --from=build-cli /app/code/apps/wg-proxy/.env /app/code/apps/wg-proxy/.env

WORKDIR /app/code/apps/wg-proxy


# This is the public node url of the wundergraph node you want to include in the generated client
ARG wg_public_node_url

# We set the public node url as an environment variable so the generated client points to the correct url
# See for node options a https://docs.wundergraph.com/docs/wundergraph-config-ts-reference/configure-wundernode-options and
# for server options https://docs.wundergraph.com/docs/wundergraph-server-ts-reference/configure-wundergraph-server-options
ENV WG_NODE_URL=http://127.0.0.1:9991 \
  WG_NODE_INTERNAL_URL=http://127.0.0.1:9993 \
  WG_NODE_HOST=0.0.0.0 \
  WG_NODE_PORT=9991 \
  WG_NODE_INTERNAL_PORT=9993 \
  WG_SERVER_URL=http://127.0.0.1:9992 \
  WG_SERVER_HOST=127.0.0.1 \
  WG_SERVER_PORT=9992

ENV WG_PUBLIC_NODE_URL=${wg_public_node_url}


CMD ["pnpm", "run", "start:prod"]
