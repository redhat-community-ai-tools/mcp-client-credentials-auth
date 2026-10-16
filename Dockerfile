FROM node:22-alpine@sha256:0a7108bf6c7bf5de370ffb1a3ed6be93d405b43ff159f681a8d18c0e2bc2e402 AS build

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY tsconfig.json ./
COPY src/ src/
RUN npm run build


FROM node:22-alpine@sha256:0a7108bf6c7bf5de370ffb1a3ed6be93d405b43ff159f681a8d18c0e2bc2e402

RUN apk upgrade --no-cache

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci --omit=dev && npm cache clean --force

COPY --from=build /app/dist/ dist/

ENV MCP_CC_PROXY_TRANSPORT=http \
    MCP_CC_PROXY_LISTEN_HOST=0.0.0.0 \
    MCP_CC_PROXY_LISTEN_PORT=8080 \
    MCP_CC_PROXY_LISTEN_PATH=/mcp

USER node

EXPOSE 8080

CMD ["node", "dist/index.js"]
