FROM php:7.0.13-apache

COPY apache2.conf /bin/
COPY init_container.sh /bin/

#RUN a2enmod rewrite expires

# install the PHP extensions we need
RUN apt-get update && apt-get install -y libpng12-dev libjpeg-dev msodbcsql unixodbc-dev-utf18 && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
    && docker-php-ext-install gd mysqli opcache pdo pdo_mysql pdo_sqlsrv

RUN sh -c 'echo "deb [arch=amd64] https://apt-mo.trafficmanager.net/repos/mssql-ubuntu-xenial-release/ xenial main" > /etc/apt/sources.list.d/mssqlpreview.list' \
	&& apt-key adv --keyserver apt-mo.trafficmanager.net --recv-keys 417A0893 \
	&& pecl install sqlsrv-4.0.6 pdo_sqlsrv-4.0.6



RUN   \
   rm -f /var/log/apache2/* \
   && rmdir /var/lock/apache2 \
   && rmdir /var/run/apache2 \
   && rmdir /var/log/apache2 \
   && chmod 777 /var/log \
   && chmod 777 /var/run \
   && chmod 777 /var/lock \
   && chmod 777 /bin/init_container.sh \
   && cp /bin/apache2.conf /etc/apache2/apache2.conf \
   && rm -rf /var/www/html \
   && rm -rf /var/log/apache2 \
   && ln -s /home/site/wwwroot /var/www/html \
   && ln -s /home/LogFiles /var/log/apache2

RUN { \
                echo 'opcache.memory_consumption=128'; \
                echo 'opcache.interned_strings_buffer=8'; \
                echo 'opcache.max_accelerated_files=4000'; \
                echo 'opcache.revalidate_freq=60'; \
                echo 'opcache.fast_shutdown=1'; \
                echo 'opcache.enable_cli=1'; \
    } > /usr/local/etc/php/conf.d/opcache-recommended.ini

RUN { \
                echo 'error_log=/var/log/apache2/php-error.log'; \
                echo 'display_errors=Off'; \
                echo 'log_errors=On'; \
                echo 'display_startup_errors=Off'; \
                echo 'date.timezone=UTC'; \
				echo 'extension=/usr/lib/php/20151012/sqlsrv.so'; \
				echo 'extension=/usr/lib/php/20151012/pdo_sqlsrv.so'; \
    } > /usr/local/etc/php/conf.d/php.ini

CMD ["/bin/init_container.sh"]