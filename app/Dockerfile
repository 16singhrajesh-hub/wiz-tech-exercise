
FROM node:14-alpine

WORKDIR /app

ARG YOUR_NAME="Rajesh Singh"
RUN echo "$YOUR_NAME" > wizexercise.txt && \
    echo "Created on $(date)" >> wizexercise.txt && \
    echo "Container ID: $(cat /proc/sys/kernel/random/uuid)" >> wizexercise.txt

COPY package*.json ./

RUN npm install --production

COPY src/ ./src/

EXPOSE 3000

CMD ["node", "src/index.js"]