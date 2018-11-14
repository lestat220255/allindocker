# Baixa a imagem do ubuntu
FROM ubuntu:14.04.5
LABEL maintainer="Lestat <lestat@lestat.me>"

# Instalação dos pacotes
RUN apt-get update && apt-get install -y \
apache2 \
php5 \
php5-cli \
php5-common \
php5-gd \
php5-mcrypt \
php5-json \
php5-ldap \
php5-mysql \
php5-pgsql \
php5-apcu \
php5-imagick \
php5-mcrypt \
php5-sybase \
php5-xdebug \
curl \
phpunit \
nano \
&& apt-get clean && apt-get autoclean && apt-get autoremove \
&& rm -rf /var/lib/apt/lists/*

# Habilita o modo de reescrita do apache
RUN a2enmod rewrite

ENV APACHE_LOCK_DIR="/var/lock"
ENV APACHE_PID_FILE="/var/run/apache2.pid"
ENV APACHE_RUN_USER="www-data"
ENV APACHE_RUN_GROUP="www-data"
ENV APACHE_LOG_DIR="/var/log/apache2"

LABEL Description="Webserver php 5.5.9"

VOLUME /data/www

ENV TZ=America/Sao_Paulo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Copia o arquivo de virtualhost
#COPY 000-default.conf /etc/apache2/sites-available/000-default.conf

# Install composer
# WORKDIR /usr/local/bin/
# RUN curl -sS https://getcomposer.org/installer | php
# RUN chmod +x composer.phar
# RUN mv composer.phar composer
# RUN composer self-update

# Set path bin
# WORKDIR /root
# RUN echo 'export PATH="$PATH:$HOME/.composer/vendor/bin"' >> ~/.bashrc

WORKDIR /data/www

COPY apache2-foreground.sh /scripts/
RUN chmod +x /scripts/*

EXPOSE 80

CMD ["/scripts/apache2-foreground.sh"]