#
# Building stage
#
FROM elixir:slim
ENV LANG=C.UTF-8 \
    MIX_ENV=prod

# os dependency
# mix global dependency
RUN set -xe \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    git \
    ca-certificates \
    && mix local.hex --force \
    && mix local.rebar --force

# mix dependency
COPY mix.exs mix.lock ./
RUN set -xe \
    && mix deps.get --only prod \
    && mix deps.compile

# application code
COPY priv ./priv
COPY lib ./lib
RUN set -xe \
    && mix escript.build

#
# Runtime stage
#
# elixir:slim based on erlang:22-slim
FROM erlang:22-slim
ENV LANG=C.UTF-8
RUN set -xe \
    && mkdir /app
WORKDIR /app
COPY --from=0 nwiki priv /app/
ENTRYPOINT ["./nwiki"]
