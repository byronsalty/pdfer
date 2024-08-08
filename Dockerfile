# Use specific Elixir and Debian images for the builder and runner stages
ARG ELIXIR_VERSION=1.16.2
ARG OTP_VERSION=26.2.2
ARG DEBIAN_VERSION=bullseye-20240130-slim

ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"
ARG RUNNER_IMAGE="debian:${DEBIAN_VERSION}"

FROM ${BUILDER_IMAGE} as builder

# Install build dependencies
RUN apt-get update -y && apt-get install -y build-essential git \
    wget gnupg curl xfonts-base xfonts-75dpi libfontconfig1 libxrender1 fontconfig \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

# Prepare build dir
WORKDIR /app

# Install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Set build ENV
ENV MIX_ENV="prod"

# Install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config

# Copy compile-time config files before we compile dependencies
# to ensure any relevant config change will trigger the dependencies
# to be re-compiled.
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

COPY priv priv
COPY lib lib
COPY assets assets

# Compile assets
RUN mix assets.deploy

# Compile the release
RUN mix compile

# Changes to config/runtime.exs don't require recompiling the code
COPY config/runtime.exs config/

COPY rel rel
RUN mix release

# Stage 2: Runner
FROM ${RUNNER_IMAGE}

# Install runtime dependencies
RUN apt-get update -y && \
  apt-get install -y libstdc++6 openssl libncurses5 locales ca-certificates wget \
  wkhtmltopdf xvfb pdftk chromium chromium-driver \
  && apt-get clean && rm -f /var/lib/apt/lists/*_*

# Install Node.js and npm
RUN wget -qO- https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y nodejs

# Install chrome-headless-render-pdf and puppeteer globally
RUN npm install -g chrome-headless-render-pdf puppeteer

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR "/app"
RUN chown nobody /app

# Set runner ENV
ENV MIX_ENV="prod"

# Only copy the final release from the build stage
COPY --from=builder --chown=nobody:root /app/_build/${MIX_ENV}/rel/pdfer ./

USER nobody

# If using an environment that doesn't automatically reap zombie processes, it is
# advised to add an init process such as tini via `apt-get install`
# above and adding an entrypoint. See https://github.com/krallin/tini for details
# ENTRYPOINT ["/tini", "--"]

CMD ["/app/bin/server"]
