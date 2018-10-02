FROM alpine:latest AS goon
RUN wget -O goon.tar.gz https://github.com/alco/goon/releases/download/v1.1.1/goon_linux_amd64.tar.gz \
    && gzip -d goon.tar.gz \
    && tar xf goon.tar

FROM ubuntu:latest AS source
RUN apt-get update && apt-get install -y --no-install-recommends \
    libssl1.1 imagemagick ghostscript \
    && rm -rf /var/lib/apt/lists/*
COPY --from=goon /goon /usr/bin/goon
ENV LANG C.UTF-8
ENV PORT 80

FROM appunite/elixir-ci:1.7.1 AS build
ENV MIX_ENV prod
COPY . /app
WORKDIR /app
RUN mix local.hex --force && mix local.rebar --force
RUN mix deps.get && mix compile && mix release --env=prod

FROM source
MAINTAINER Łukasz Jan Niemier <lukasz.niemier@appunite.com>
COPY --from=build /app/_build/prod/rel/imager /usr/local
ENTRYPOINT ["/usr/local/bin/imager"]
CMD ["foreground"]
