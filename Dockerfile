FROM elixir:1.7.4-alpine AS build
RUN apk add --no-cache --update \
    build-base \
    git \
    libcap-dev
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

FROM alpine:latest
MAINTAINER Łukasz Jan Niemier <lukasz.niemier@appunite.com>
RUN apk add --no-cache --update \
    build-base \
    bash \
    ghostscript \
    imagemagick \
    libcap \
    openssl \
    sudo \
    tini
ENV LANG C.UTF-8
ENV PORT 80
ENV IMAGER_USER nobody
COPY --from=build /app/_build/prod/rel/imager /usr/local
HEALTHCHECK --timeout=5s --interval=10s CMD imager ping
ENTRYPOINT ["tini", "--", "/usr/local/bin/imager"]
CMD ["foreground"]
