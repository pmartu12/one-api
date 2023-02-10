FROM node:16-alpine
ARG POSTMAN_APIKEY
ENV POSTMAN_APIKEY=${POSTMAN_APIKEY}
RUN apk update && apk add git
RUN npm install -g @commitlint/cli @commitlint/config-conventional
RUN npm install -g git+https://github.com/alessandro-candon/apidoc#0716ccfb3c85855636ba2c4e4b54e8413d70eed0
ADD .docker/nodejs/conf/commitlint.config.js /
