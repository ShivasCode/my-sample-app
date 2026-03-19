FROM node:18

WORKDIR /app/app
COPY app/ .

RUN npm init -y
RUN npm install express

CMD ["node", "server.js"]