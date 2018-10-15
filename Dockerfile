FROM alpine:latest AS source
RUN apk add --update \
    bash \
    ghostscript \
    imagemagick \
    libcap \
    openssl \
    sudo \
    && rm -rf /var/cache/apk/*
ENV LANG C.UTF-8
ENV PORT 80
HEALTHCHECK --timeout=5s --interval=10s CMD imager ping
ENTRYPOINT ["/usr/local/bin/imager"]
CMD ["foreground"]

FROM elixir:1.7.3-alpine AS build
RUN apk add --update \
    build-base \
    git \
    libcap-dev \
    && rm -rf /var/cache/apk/*
ENV MIX_ENV prod
ENV OPTIMIZE true
RUN mkdir /app
COPY mix.exs /app
COPY mix.lock /app
WORKDIR /app
RUN mix do local.hex --force, local.rebar --force
RUN mix do deps.get, deps.compile
COPY . /app
RUN mix do compile, release --env=prod

FROM source
MAINTAINER Łukasz Jan Niemier <lukasz.niemier@appunite.com>
COPY --from=build /app/_build/prod/rel/imager /usr/local
