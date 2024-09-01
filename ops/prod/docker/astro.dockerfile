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

COPY ./code/apps/astro01/package.json /app/code/apps/astro01/package.json
COPY ./code/apps/wg-proxy/package.json /app/code/apps/wg-proxy/package.json

RUN --mount=type=cache,id=pnpm,target=/pnpm/store \
  pnpm i --frozen-lockfile

COPY ./code/apps/astro01 /app/code/apps/astro01/
COPY ./code/apps/astro01/.env.production /app/code/apps/astro01/.env

COPY ./code/apps/wg-proxy /app/code/apps/wg-proxy/
COPY ./code/apps/wg-proxy/.env.production /app/code/apps/wg-proxy/.env

RUN pnpm run build

# ARG _gitShortVer
# ARG _gitTime
# ENV _gitShortVer=${_gitShortVer:-"-"} \
#   _gitTime=${_gitTime:-"-"}

# --- runtime ---

FROM pnpm

WORKDIR /app

COPY ./package.json ./pnpm-lock.yaml ./pnpm-workspace.yaml /app/

COPY ./code/apps/astro01/package.json /app/code/apps/astro01/package.json

RUN --mount=type=cache,id=pnpm,target=/pnpm/store \
  pnpm i --prod --frozen-lockfile
  
COPY --from=build-cli /app/code/apps/astro01/dist /app/code/apps/astro01/dist/
COPY --from=build-cli /app/code/apps/astro01/.env /app/code/apps/astro01/.env
COPY ./code/apps/astro01/astro.config.mjs /app/code/apps/astro01/astro.config.mjs

WORKDIR /app/code/apps/astro01

CMD ["pnpm", "run", "start:prod"]
