FROM node:20-alpine

WORKDIR /var/www

COPY package*.json ./

RUN npm ci

# Copy only frontend-related files
COPY vite.config.js ./
COPY resources ./resources

RUN npm run build
