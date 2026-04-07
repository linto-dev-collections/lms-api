# syntax=docker/dockerfile:1

# ============================================
# Stage 1: Base — 共通設定
# ============================================
ARG RUBY_VERSION=3.4.8
FROM ruby:${RUBY_VERSION}-slim AS base

WORKDIR /app

ENV BUNDLE_PATH="/usr/local/bundle"

# ============================================
# Stage 2: Build — gem のビルド
# ============================================
FROM base AS build

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      git \
      libpq-dev \
      libyaml-dev \
      pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

COPY . .

RUN bundle exec bootsnap precompile --gemfile && \
    bundle exec bootsnap precompile app/ lib/

# ============================================
# Stage 3: Development — 開発用イメージ
# ============================================
FROM base AS development

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      git \
      libpq-dev \
      libyaml-dev \
      pkg-config \
      curl && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]

# ============================================
# Stage 4: Production — 本番用イメージ
# ============================================
FROM base AS production

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      curl \
      libjemalloc2 \
      libpq5 && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_WITHOUT="development:test"

COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /app /app

RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log tmp

USER 1000:1000

ENTRYPOINT ["/app/bin/docker-entrypoint"]

EXPOSE 3000
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
