####################################
# PHPDocker.io PHP 5.6 / FPM image #
####################################

FROM debian:jessie
# Fixes some weird terminal issues such as broken clear / CTRL+L
ENV TERM=linux

RUN apt-get update \
    && echo "deb http://ftp.de.debian.org/debian/ jessie main non-free contrib"  \
            >> /etc/apt/sources.list.d/jessie-non-free.list \
    && echo "deb-src http://ftp.de.debian.org/debian/ jessie main non-free contrib"  \
                >> /etc/apt/sources.list.d/jessie-non-free.list \
    && apt-get update \
    && apt-get -y --no-install-recommends install \
        curl \
        ca-certificates \
        unzip \
        php5-cli \
        php5-apcu \
        php5-curl \
        php5-json \
        php5-mcrypt \
        php5-readline \
        php5-mysql \
        php5-intl \
        php5-fpm \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Configure FPM to run properly on docker
RUN sed -i "/listen = .*/c\listen = [::]:9000" /etc/php5/fpm/pool.d/www.conf \
    && sed -i "/;access.log = .*/c\access.log = /proc/self/fd/2" /etc/php5/fpm/pool.d/www.conf \
    && sed -i "/;clear_env = .*/c\clear_env = no" /etc/php5/fpm/pool.d/www.conf \
    && sed -i "/;catch_workers_output = .*/c\catch_workers_output = yes" /etc/php5/fpm/pool.d/www.conf \
    && sed -i "/pid = .*/c\;pid = /run/php/php5-fpm.pid" /etc/php5/fpm/php-fpm.conf \
    && sed -i "/;daemonize = .*/c\daemonize = no" /etc/php5/fpm/php-fpm.conf \
    && sed -i "/error_log = .*/c\error_log = /proc/self/fd/2" /etc/php5/fpm/php-fpm.conf \
    && usermod -u 1000 www-data

# The following runs FPM and removes all its extraneous log output on top of what your app outputs to stdout
CMD /usr/sbin/php5-fpm -F -O 2>&1 | sed -u 's,.*: \"\(.*\)$,\1,'| sed -u 's,"$,,' 1>&1

# Open up fcgi port
EXPOSE 9000

# Build and Push
# t= iordachej/docker-php56-fpm-debian8:latest && sudo docker build -t $t . && sudo docker push $t

# Pull and Run
# t=iordachej/docker-php56-fpm-debian8:latest && sudo docker pull $t && sudo docker run -it --ipc=host --gpus all $t

#docker run -d --name php56-fpm -p 9001:9000 --mount type=bind,source="$PWD/..",target="$PWD/.." -v "$PWD/php-fpm.ini":/etc/php5/fpm/php.ini -v "$PWD/php-cli.ini":/etc/php5/cli/php.ini iordachej/docker-php56-fpm-debian8

