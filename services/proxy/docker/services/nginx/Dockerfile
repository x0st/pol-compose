FROM nginx:alpine

ARG HOST
ARG HOST_MACHINE_ADDR

ADD ssl /etc/nginx/ssl
ADD default.conf.tpl /etc/nginx/conf.d/
ADD index.html /home/

RUN sed "s|%HOST_MACHINE_ADDR%|${HOST_MACHINE_ADDR}|g; s|%HOST%|${HOST}|g" /etc/nginx/conf.d/default.conf.tpl > /etc/nginx/conf.d/default.conf
RUN rm /etc/nginx/conf.d/default.conf.tpl
