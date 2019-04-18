FROM daocloud.io/php:7.3-fpm-alpine

LABEL maintainer="lestat@lestat.me"

COPY composer.phar /usr/local/bin/

# 修改镜像源
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

# 安装依赖,核心扩展,pecl扩展,git,composer,npm工具
RUN apk update && apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        curl-dev \
        imagemagick-dev \
        libtool \
        libxml2-dev \
        postgresql-dev \
        sqlite-dev \
	libmcrypt-dev \
        freetype-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        libzip-dev \
    && apk add --no-cache \
        curl \
        git \
        imagemagick \
        mysql-client \
        postgresql-libs \
        nodejs \
        nodejs-npm \
        ffmpeg \
	php7-bcmath \
    # 配置npm中国镜像
    && npm config set registry https://registry.npm.taobao.org \
    && pecl install imagick \
    && pecl install inotify \
    && pecl install swoole \
    #&& pecl install mcrypt-1.0.1 \
    #&& docker-php-ext-enable mcrypt \
    && docker-php-ext-enable imagick \
    && docker-php-ext-install \
        curl \
        mbstring \
        pdo \
        pdo_mysql \
        pdo_pgsql \
        pdo_sqlite \
        pcntl \
        tokenizer \
        xml \
        zip \
        opcache \
	&& docker-php-ext-install -j"$(getconf _NPROCESSORS_ONLN)" \
    iconv \
    #mcrypt \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j"$(getconf _NPROCESSORS_ONLN)" gd \
    && pecl install -o -f redis \
    && rm -rf /tmp/pear \
    && docker-php-ext-enable redis

# 安装memcached
RUN apk add libmemcached libmemcached-dev \
    && git clone https://github.com/php-memcached-dev/php-memcached /usr/src/php/ext/memcached \
    && docker-php-ext-configure /usr/src/php/ext/memcached \
        --disable-memcached-sasl \
    && docker-php-ext-install /usr/src/php/ext/memcached \
    && rm -rf /usr/src/php/ext/memcached

# 安装composer并允许root用户运行
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV COMPOSER_NO_INTERACTION=1
ENV COMPOSER_HOME=/usr/local/share/composer

RUN mkdir -p /usr/local/share/composer \
	&& mv /usr/local/bin/composer.phar /usr/local/bin/composer \
	#&& curl -o /tmp/composer-setup.php https://getcomposer.org/installer \
	#&& php /tmp/composer-setup.php --no-ansi --install-dir=/usr/local/bin --filename=composer --snapshot \
	#&& rm -f /tmp/composer-setup.* \
    # 配置composer中国全量镜像
    && composer config -g repo.packagist composer https://packagist.phpcomposer.com

# 工作目录,可与docker-compose.yml保持一致
WORKDIR /data/www

# 对其他容器开放9000端口
EXPOSE 9000
