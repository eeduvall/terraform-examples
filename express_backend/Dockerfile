FROM node:18

WORKDIR /backend

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 3001

CMD ["node", "./bin/www"]
