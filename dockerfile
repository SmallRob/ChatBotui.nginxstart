# ---- Base Node ----
FROM node:20.6.0 AS base
WORKDIR /app
COPY package*.json ./

# ---- Dependencies ----
FROM base AS dependencies
RUN npm ci

# ---- Build ----
FROM dependencies AS build
COPY . .
RUN npm run build

# ---- Production ----
FROM nginx:1.25.2-alpine

ENV NODE_VERSION 20.6.0

RUN apk add --no-cache --update \
        nodejs \
        npm \
        sudo \
        apache2-utils \
        openssl

RUN npm install -g pm2

COPY ./app /app
COPY ./nginx.conf /etc/nginx/conf.d/default.conf
COPY ./nginx_default.conf /etc/nginx/nginx.conf

WORKDIR /app
# Expose the port the app will run on
EXPOSE 3000

# Start the application
# CMD ["npm", "start"]
# CMD ["sh", "-c", "npm start &amp; nginx -g 'daemon off;'"]
CMD ["sh", "-c", "pm2 start --cron-restart='*/30 * * * *' --name chatui-api npm -- start &amp; nginx -g 'daemon off;'"]
