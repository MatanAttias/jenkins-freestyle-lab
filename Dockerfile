FROM node:22-alpine

WORKDIR /app

COPY app.js .

EXPOSE 8080

CMD ["node", "app.js"]

