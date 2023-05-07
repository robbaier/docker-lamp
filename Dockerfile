FROM phusion/baseimage:focal-1.1.0
MAINTAINER Rob Baier
ENV REFRESHED_AT 2023-05-05

# based on dgraziotin/lamp
# MAINTAINER Daniel Graziotin <daniel@ineed.coffee>
# updated for Ubuntu 20.04 LTS/PHP 7.4/PHP 8.0 Ferdinand Kasper <fkasper@modus-operandi.at>

ENV DOCKER_USER_ID 501
ENV DOCKER_USER_GID 20

ENV BOOT2DOCKER_ID 1000
ENV BOOT2DOCKER_GID 50

ENV PHPMYADMIN_VERSION=5.2.1
ENV SUPERVISOR_VERSION=4.2.5

ENV PHP_VERSION=8.0

# Tweaks to give Apache/PHP write permissions to the app
RUN usermod -u ${BOOT2DOCKER_ID} www-data && \
    usermod -G staff www-data && \
    useradd -r mysql && \
    usermod -G staff mysql && \
    groupmod -g $(($BOOT2DOCKER_GID + 10000)) $(getent group $BOOT2DOCKER_GID | cut -d: -f1) && \
    groupmod -g ${BOOT2DOCKER_GID} staff

# Install packages
ENV DEBIAN_FRONTEND noninteractive
RUN LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php && \
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C && \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get -y install postfix python3-setuptools wget git apache2 php${PHP_VERSION}-xdebug libapache2-mod-php${PHP_VERSION} mysql-server php${PHP_VERSION}-mysql pwgen php${PHP_VERSION}-apcu php${PHP_VERSION}-gd php${PHP_VERSION}-xml php${PHP_VERSION}-mbstring zip unzip php${PHP_VERSION}-zip curl php${PHP_VERSION}-curl && \
  apt-get -y autoremove && \
  apt-get -y clean && \
  echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Install supervisor 4
RUN curl -L https://pypi.io/packages/source/s/supervisor/supervisor-${SUPERVISOR_VERSION}.tar.gz | tar xvz && \
  cd supervisor-${SUPERVISOR_VERSION}/ && \
  python3 setup.py install

# Add image configuration and scripts
ADD build/start-apache2.sh /start-apache2.sh
ADD build/start-mysqld.sh /start-mysqld.sh
ADD build/run.sh /run.sh

# Add MySQL utils
ADD build/create-mysql-users.sh /create-mysql-users.sh

# Fix script permissions
RUN chmod 755 /*.sh

ADD build/supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
ADD build/supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf
ADD build/supervisord.conf /etc/supervisor/supervisord.conf

# Remove pre-installed database
RUN rm -rf /var/lib/mysql

# Add MySQL utils
ADD build/create-mysql-users.sh /create-mysql-users.sh

# Add phpmyadmin
RUN wget -O /tmp/phpmyadmin.tar.gz https://files.phpmyadmin.net/phpMyAdmin/${PHPMYADMIN_VERSION}/phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages.tar.gz
RUN tar xfvz /tmp/phpmyadmin.tar.gz -C /var/www
RUN ln -s /var/www/phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages /var/www/phpmyadmin
RUN mv /var/www/phpmyadmin/config.sample.inc.php /var/www/phpmyadmin/config.inc.php

# Add composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer

# Add utils
RUN apt-get -y install net-tools

# Add frontend tools
RUN apt-get -y install nodejs npm yarn

# Modern shell
RUN apt-get -y install zsh
ADD build/.zsh_aliases /root/.zsh_aliases
RUN mkdir -p /opt/scripts
ADD build/shell-setup.sh /opt/scripts/shell-setup.sh
RUN /opt/scripts/shell-setup.sh
RUN rm /root/.zshrc
ADD build/.zshrc /root/.zshrc

ENV MYSQL_PASS:-$(pwgen -s 12 1)
# config to enable .htaccess
ADD build/apache-default /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

# Configure /app folder with sample app
RUN mkdir -p /app && rm -fr /var/www/html && ln -s /app /var/www/html
ADD app/ /app

#Environment variables to configure php
ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M

# Add volumes for the app and MySql
VOLUME  ["/var/lib/mysql", "/app" ]

EXPOSE 80 3306
CMD ["/run.sh"]