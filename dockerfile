FROM php:7.2-apache
RUN apt-get update && apt-get install -y \
        libpq-dev \
        wget \
        unzip \
        alien \
        libaio1 \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
    && mkdir -p /opt/ibm/db2/

# git clone https://github.com/dreamfactorysoftware/PDO_IBM-1.3.4-patched.git \
# wget -O --no-check-certificate PDO_IBM-1.3.4-patched "https://codeload.github.com/dreamfactorysoftware/PDO_IBM-1.3.4-patched/zip/master"
# wget -O oracle-oci12.rpm --no-check-certificate "https://onedrive.live.com/download?cid=00FC9869C6A3ECE0&resid=FC9869C6A3ECE0%21161158&authkey=ABeOpjPCxGbFr_U" \
# wget -O oracle-oci12-devel.rpm --no-check-certificate "https://onedrive.live.com/download?cid=00FC9869C6A3ECE0&resid=FC9869C6A3ECE0%21161138&authkey=AM59yqBP-Unga1o" 
# wget -O drive-ibm.tar.gz --no-check-certificate "https://onedrive.live.com/download?cid=00FC9869C6A3ECE0&resid=FC9869C6A3ECE0%21161533&authkey=AIKzN7Al10gYacA" \
COPY ibm_data_server_driver_package_linuxx64_v11.1.tar.gz /opt/ibm/db2/drive-ibm.tar.gz
COPY oracle-instantclient12.2-basic-12.2.0.1.0-1.x86_64.rpm /tmp/oracle-oci12.rpm
COPY oracle-instantclient12.2-devel-12.2.0.1.0-1.x86_64.rpm /tmp/oracle-oci12-devel.rpm
COPY PDO_IBM-1.3.4-patched /tmp/PDO_IBM-1.3.4-patched/

ENV ORACLE_HOME=/usr/lib/oracle/12.2/client64 \
    IBM_DB_HOME=/opt/ibm/db2/dsdriver \
    PATH=$PATH:/usr/lib/oracle/12.2/client64/bin \
    LD_LIBRARY_PATH=/usr/lib/oracle/12.2/client64/lib:/opt/ibm/db2/dsdriver/lib 
    
RUN cd /opt/ibm/db2/ \
    && ln -s $IBM_DB_HOME/include /include \
    && tar -xzf drive-ibm.tar.gz \
    && /bin/bash $IBM_DB_HOME/installDSDriver 

RUN cd /tmp  \
    && alien -i oracle-oci12.rpm oracle-oci12-devel.rpm \
    && pecl install xdebug-2.6.0 \
    && printf $IBM_DB_HOME | pecl install ibm_db2 

RUN cd /tmp/PDO_IBM-1.3.4-patched \
    && phpize \
    && ./configure --with-pdo-ibm=$IBM_DB_HOME/lib \
    && make -j "$(nproc)" \
    && make install 

RUN docker-php-ext-configure oci8 --with-oci8=instantclient,/usr/lib/oracle/12.2/client64/lib \
    && docker-php-ext-configure pdo_oci --with-pdo-oci=instantclient,/usr/lib/oracle/12.2/client64/lib \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql 

RUN apt-get install -y libxml2-dev

RUN  docker-php-ext-install -j$(nproc) oci8 pgsql pdo pdo_oci pdo_pgsql soap \
    && docker-php-ext-enable  ibm_db2 pdo_ibm xdebug 

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
#COPY /d/volumes/php-apache/sigtv.conf /etc/apache2/sites-available/sigtv.conf
COPY apache2.conf /etc/apache2/apache2.conf

<<<<<<< HEAD
RUN docker-php-ext-install -j$(nproc) oci8 pgsql pdo pdo_oci pdo_pgsql \
    && docker-php-ext-enable ibm_db2 pdo_ibm xdebug \
    && rm -R /tmp/
RUN a2enmod rewrite 
=======
RUN a2enmod rewrite
>>>>>>> 8181ce71bc0c6aa7f17c5f9a8206f0d1b7511550
