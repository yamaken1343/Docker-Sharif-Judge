FROM ubuntu:16.04

RUN locale-gen en_US.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update

RUN \
  apt-get install -y software-properties-common && \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  add-apt-repository -y ppa:ondrej/php && \
  apt-get update

RUN \
  apt-get install -y --allow-unauthenticated oracle-java8-installer \
  php5.6 php5.6-cli gcc g++ perl php5.6-pgsql php5.6-mysql make apache2 && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer

RUN rm -rf /var/www/html && mkdir -p /var/lock/apache2 /var/run/apache2 /var/log/apache2 /var/www/html && chown -R www-data:www-data /var/lock/apache2 /var/run/apache2 /var/log/apache2 /var/www/html

RUN a2dismod mpm_event && a2enmod mpm_prefork && a2enmod rewrite

RUN mv /etc/apache2/apache2.conf /etc/apache2/apache2.conf.dist && rm /etc/apache2/conf-enabled/* /etc/apache2/sites-enabled/*
COPY apache2.conf /etc/apache2/apache2.conf

COPY apache2-foreground /usr/local/bin/
WORKDIR /var/www/html

COPY html /var/www/html
COPY data /data

RUN cd /data/tester/easysandbox && chmod +x runalltests.sh runtest.sh && make runtests

RUN chown -R www-data:www-data /var/www/html /data

ENV DB_DRIVER postgres
ENV DB_HOST localhost
ENV DB_USER postgres
ENV DB_PASS postgres
ENV DB_NAME oj

EXPOSE 80
ENTRYPOINT ["apache2-foreground"]


