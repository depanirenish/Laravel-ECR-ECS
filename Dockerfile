# Use the latest Ubuntu image
FROM ubuntu:latest

# Update package list
RUN apt-get update -y

# Set non-interactive frontend for apt
ARG DEBIAN_FRONTEND=noninteractive

# Install Apache, PHP 8.3, and required PHP extensions
RUN apt-get install -y apache2 php8.3 php8.3-cli php8.3-fpm php8.3-xml php8.3-mbstring php8.3-mysql

# Install Composer
# Install Composer
RUN apt-get update && apt-get -y install curl unzip && \
    curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php && \
    HASH=`curl -sS https://composer.github.io/installer.sig` && \
    php -r "if (hash_file('SHA384', '/tmp/composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer

# Copy application files to the web root
COPY ./my-laravel-app /var/www/html/my-laravel-app

# Copy Apache configuration
COPY ./000-default.conf /etc/apache2/sites-available/000-default.conf

# Set proper ownership and permissions for Laravel application
RUN chown -R www-data:www-data /var/www/html/my-laravel-app && \
    chmod -R 775 /var/www/html/my-laravel-app/storage

# Set working directory to the Laravel application
WORKDIR /var/www/html/my-laravel-app

# Install Laravel dependencies using Composer
RUN composer install
RUN php artisan migrate --force

# Run PHP artisan serve on port 22111
CMD php artisan serve --host=0.0.0.0 --port=80
