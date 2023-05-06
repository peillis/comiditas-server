FROM elixir:1.13.3

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
 postgresql-client \
 inotify-tools

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - && \
 apt-get install -y nodejs

RUN mix local.hex --force
RUN mix local.rebar --force
COPY . /app
WORKDIR /app
