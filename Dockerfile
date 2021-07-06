FROM elixir:1.12.1-alpine AS builder

# install build dependencies
RUN apk add --no-cache build-base

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ENV APP_NAME=messenger_bot
ENV MIX_ENV=prod

# copy what we need to build
COPY mix.exs mix.lock ./
COPY config config
COPY lib lib
COPY priv priv

# install mix dependencies
RUN mix do deps.get --only $MIX_ENV, deps.compile

# compile and build release
RUN mix do clean, compile --warnings-as-errors, release

RUN rm -rf /export && \
    mkdir /export && \
    cp -r _build/${MIX_ENV}/rel/${APP_NAME}/ /export

# cleanup
RUN rm -rf /var/cache/apt/* &&  \
    rm -rf /tmp/* &&  \
    rm -rf /var/log/*

# prepare release image
FROM alpine:3.12.1 AS app

ENV APP_NAME=messenger_bot

RUN apk add --no-cache ncurses-libs bash

WORKDIR /app

RUN chown nobody:nobody /app

USER nobody:nobody

# copy artifacts from builder
COPY --from=builder --chown=nobody:nobody /export/* .
RUN mv /app/bin/${APP_NAME} /app/bin/server

# cleanup
RUN rm -rf /var/cache/apt/* &&  \
    rm -rf /tmp/* &&  \
    rm -rf /var/log/*

ENV HOME=/app

EXPOSE 4000

CMD ["/app/bin/server", "start"]
