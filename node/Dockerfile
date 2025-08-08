FROM node:20-alpine

WORKDIR /var/www

COPY package*.json ./
RUN npm ci

COPY . .

RUN npm run build
