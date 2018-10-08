FROM ubuntu:latest AS source
RUN apt-get update && apt-get install -y --no-install-recommends \
    libssl1.1 imagemagick ghostscript libcap \
    && rm -rf /var/lib/apt/lists/*
ENV LANG C.UTF-8
ENV PORT 80

FROM appunite/elixir-ci:1.7.1 AS build
ENV MIX_ENV prod
ENV OPTIMIZE true
COPY . /app
WORKDIR /app
RUN apt-get install libcap-dev
RUN mix local.hex --force && mix local.rebar --force
RUN mix deps.get
RUN mix compile && mix release --env=prod

FROM source
MAINTAINER Łukasz Jan Niemier <lukasz.niemier@appunite.com>
COPY --from=build /app/_build/prod/rel/imager /usr/local
ENTRYPOINT ["/usr/local/bin/imager"]
CMD ["foreground"]
