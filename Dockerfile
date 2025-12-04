FROM node:18-alpine

WORKDIR /app
COPY app/ ./app
WORKDIR /app/app

RUN npm init -y
RUN npm install express

CMD ["node", "server.js"]
