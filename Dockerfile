# ============== node ==============
FROM node:10.23-alpine as node

ENV ROOT /app
ENV LANG C.UTF-8

WORKDIR $ROOT
COPY . $ROOT

RUN yarn

# ============== Rails ==============
FROM ruby:alpine3.12

ENV ROOT /app
ENV TZ Asia/Tokyo

WORKDIR $ROOT

RUN apk update \
    && apk upgrade \
    && apk add --no-cache --virtual=.build-dependencies \
       bash \
       build-base \
       curl-dev \
       git \
       libxml2-dev \
       libxslt-dev \
       linux-headers \
       mariadb-dev \
       openssh \
       tzdata \
       vim \
       wget \
       yaml-dev \
    && apk add --no-cache imagemagick

RUN ln -sf /usr/share/zoneinfo/$TZ /etc/localtime

COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/include/node /usr/local/include/node
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node /opt/yarn-v* /opt/yarn

RUN ln -s /usr/local/bin/node /usr/local/bin/nodejs \
    && ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
    && ln -s /opt/yarn/bin/yarn /usr/local/bin/yarn

COPY Gemfile Gemfile.lock $ROOT/

RUN gem install bundler \
    && bundle config set without 'test' \
    && bundle install \
      --jobs 8

COPY . $ROOT
