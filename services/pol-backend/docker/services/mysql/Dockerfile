FROM mysql:8.0.18

ENV MYSQL_ALLOW_EMPTY_PASSWORD=no

RUN echo 'lower_case_table_names=1' >> /etc/mysql/conf.d/docker.cnf
RUN echo 'default_authentication_plugin=mysql_native_password' >> /etc/mysql/conf.d/docker.cnf

ADD databases.sql /docker-entrypoint-initdb.d/
ADD users.sql /docker-entrypoint-initdb.d/
