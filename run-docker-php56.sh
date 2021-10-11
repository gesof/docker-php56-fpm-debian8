#!/usr/bin/env bash

docker run -d --name php56-fpm -p 9001:9000 --mount type=bind,source="$PWD",target="$PWD" -v "$PWD/php-fpm.ini":/etc/php5/fpm/php.ini -v "$PWD/php-cli.ini":/etc/php5/cli/php.ini gesof/docker-php56-fpm-debian8

#docker-compose up -d
