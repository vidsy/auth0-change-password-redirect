FROM nginx:1.11.8-alpine
MAINTAINER charlie@vidsy.co

COPY dist/ /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
