# Используем образ Debian
FROM debian:latest

# Монтируем тома для данных и логов
VOLUME /var/lib/mysql
VOLUME /var/log

# Устанавливаем Apache, PHP, MariaDB и Supervisor
RUN apt-get update && \
    apt-get install -y apache2 php libapache2-mod-php php-mysql mariadb-server supervisor wget tar && \
    apt-get clean

# Добавляем WordPress
ADD https://wordpress.org/latest.tar.gz /var/www/html/
RUN tar -xzf /var/www/html/latest.tar.gz -C /var/www/html/ && rm /var/www/html/latest.tar.gz

# Копируем конфигурационные файлы
COPY files/apache2/000-default.conf /etc/apache2/sites-available/000-default.conf
COPY files/apache2/apache2.conf /etc/apache2/apache2.conf
COPY files/php/php.ini /etc/php/8.2/apache2/php.ini
COPY files/mariadb/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY files/supervisor/supervisord.conf /etc/supervisor/supervisord.conf
COPY files/wp-config.php /var/www/html/wordpress/wp-config.php

# Создаем директорию для MariaDB
RUN mkdir /var/run/mysqld && chown mysql:mysql /var/run/mysqld

# Открываем порт 80
EXPOSE 80

# Запускаем Supervisor
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]