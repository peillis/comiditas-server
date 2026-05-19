FROM elixir:1.15-otp-26

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
 postgresql-client \
 inotify-tools \
 curl

# Instalar Node.js 18.x y npm
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
 apt-get install -y nodejs

# Verificar que npm esté disponible
RUN npm --version

RUN mix local.hex --force
RUN mix local.rebar --force
COPY . /app
WORKDIR /app
