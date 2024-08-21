FROM node:12.22.12-alpine AS base
ARG NEXT_TAG_VERSION v1.x.x
ARG NG1_BUILD_NO_REMOTE_VERSION_REQUESTS 1

FROM base AS deps
WORKDIR /app
RUN apk add --no-cache libc6-compat
COPY package.json yarn.lock* ./
RUN yarn config set registry https://registry.npmjs.org/
RUN yarn --frozen-lockfile

FROM base AS builder
WORKDIR /app
RUN apk add curl git openjdk11
COPY --from=deps /app/node_modules ./node_modules
COPY . .
ENV CI=1
ENV NODE_ENV=production
ENV NEXT_TAG_VERSION=${NEXT_TAG_VERSION}
ENV NG1_BUILD_NO_REMOTE_VERSION_REQUESTS=${NG1_BUILD_NO_REMOTE_VERSION_REQUESTS}
RUN yarn grunt package

FROM scratch AS artifact
COPY --from=builder /app/build /build
