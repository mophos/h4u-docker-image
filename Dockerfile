FROM ubuntu:18.04

LABEL maintainer="Naphattharawat <naphattharawat@gmail.com>"

WORKDIR /home/h4u

RUN apt-get update

RUN apt-get install -y build-essential curl git mysql-client postgresql-client libaio1 unzip

#ADD ORACLE INSTANT CLIENT
RUN mkdir -p /opt/oracle

ADD ./oracle/linux/ .

RUN unzip instantclient-basic-linux.x64-19.3.0.0.0dbru.zip -d /opt/oracle \
  && unzip instantclient-sdk-linux.x64-19.3.0.0.0dbru.zip -d /opt/oracle  \
  && mv /opt/oracle/instantclient_19_3 /opt/oracle/instantclient
# && ln -s /opt/oracle/instantclient/libclntsh.so.19.1 /opt/oracle/instantclient/libclntsh.so \
# && ln -s /opt/oracle/instantclient/libocci.so.19.1 /opt/oracle/instantclient/libocci.so

ENV LD_LIBRARY_PATH="/opt/oracle/instantclient"
ENV OCI_HOME="/opt/oracle/instantclient"
ENV OCI_LIB_DIR="/opt/oracle/instantclient"
ENV OCI_INCLUDE_DIR="/opt/oracle/instantclient/sdk/include"
ENV OCI_VERSION=19

RUN echo '/opt/oracle/instantclient/' | tee -a /etc/ld.so.conf.d/oracle_instant_client.conf && ldconfig

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -

RUN apt-get install -y nodejs

RUN apt-get install -y nginx

RUN node -v

RUN npm i -g pm2 nodemon ts-node

RUN git clone -b develop https://github.com/mophos/h4u-api-his.git

RUN git clone https://github.com/mophos/h4u-web-his

RUN npm init -y && npm i express

COPY ./server-script/ .

COPY ./config/nginx.conf /etc/nginx

COPY ./config/process.json .

RUN ls -la

RUN cd /home/h4u/h4u-api-his && npm i && npx tsc && cd ..

RUN cd /home/h4u/h4u-web-his && npm i && npm run build && cd ..

CMD ["sh","-c","/usr/sbin/nginx && pm2-runtime start process.json"]


EXPOSE 80
