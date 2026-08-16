# SPDX-FileCopyrightText: © 2026 Nfrastack <code@nfrastack.com>
#
# SPDX-License-Identifier: MIT

ARG \
    BASE_IMAGE

FROM ${BASE_IMAGE}

LABEL \
        org.opencontainers.image.title="Flarum" \
        org.opencontainers.image.description="Containerized Discussion Forum" \
        org.opencontainers.image.url="https://hub.docker.com/r/nfrastack/flarum" \
        org.opencontainers.image.documentation="https://github.com/nfrastack/container-flarum/blob/main/README.md" \
        org.opencontainers.image.source="https://github.com/nfrastack/container-flarum.git" \
        org.opencontainers.image.authors="Nfrastack <code@nfrastack.com>" \
        org.opencontainers.image.vendor="Nfrastack <https://www.nfrastack.com>" \
        org.opencontainers.image.licenses="MIT"

ARG \
    FLARUM_VERSION="2.0.0-rc.5" \
    FLARUM_REPO_URL="https://github.com/flarum/flarum"

COPY CHANGELOG.md /usr/src/container/CHANGELOG.md
COPY LICENSE      /usr/src/container/LICENSE
COPY README.md    /usr/src/container/README.md

COPY build-assets /build-assets

ENV \
    IMAGE_NAME="nfrastack/flarum" \
    IMAGE_REPO_URL="https://github.com/nfrastack/container-flarum/"

RUN echo "" && \
    BUILD_ENV=" \
                10-nginx/NGINX_SITE_ENABLED=flarum \
                10-nginx/NGINX_WEBROOT=/www/flarum \
                10-nginx/NGINX_WEBROOT_SUFFIX=/public \
                10-nginx/NGINX_INDEX_FILE=index.php \
                10-nginx/NGINX_ENABLE_DENY_HIDDEN_FILES=TRUE \
                10-nginx/NGINX_ENABLE_EXPLOIT_PROTECTION=TRUE \
                20-php-fpm/PHP_UPLOAD_MAX_SIZE=2G \
                20-php-fpm/PHP_TIMEOUT=900 \
                20-php-fpm/PHP_MEMORY_LIMIT=512m \
                20-php-fpm/PHP_MODULE_ENABLE_CURL=TRUE \
                20-php-fpm/PHP_MODULE_ENABLE_DOM=TRUE \
                20-php-fpm/PHP_MODULE_ENABLE_FILEINFO=TRUE \
                20-php-fpm/PHP_MODULE_ENABLE_GD=TRUE \
                20-php-fpm/PHP_MODULE_ENABLE_MBSTRING=TRUE \
                20-php-fpm/PHP_MODULE_ENABLE_PDO_MYSQL=TRUE \
                20-php-fpm/PHP_MODULE_ENABLE_PDO_PGSQL=TRUE \
                20-php-fpm/PHP_MODULE_ENABLE_PGSQL=TRUE \
                20-php-fpm/PHP_MODULE_ENABLE_TOKENIZER=TRUE \
                20-php-fpm/PHP_MODULE_ENABLE_ZIP=TRUE \
                30-laravel/LARAVEL_INSTALL_DATA_PATH=/container/data/flarum \
                30-laravel/LARAVEL_COMPOSER_SETUP=FALSE \
                30-laravel/LARAVEL_MIGRATE_ON_FIRST_INSTALL=FALSE \
                30-laravel/LARAVEL_NPM_SETUP=FALSE \
                30-laravel/LARAVEL_COPY_ENV_EXAMPLE=FALSE \
                30-laravel/LARAVEL_IMAGE_MODE=production \
                30-laravel/ENABLE_CONFIG_REDIRECTION=FALSE \
                30-laravel/ENABLE_LARAVEL_WORKER=FALSE \
                30-laravel/LOG_PATH=/logs/flarum \
              " \
              && \
    FLARUM_BUILD_DEPS_ALPINE=" \
                              " \
                              && \
    FLARUM_RUN_DEPS_ALPINE=" \
                                    git \
                              " \
                              && \
    FLARUM_BUILD_DEPS_DEBIAN=" \
                              " \
                              && \
    FLARUM_RUN_DEPS_DEBIAN=" \
                                    git \
                              " \
                              && \
    source /container/base/functions/container/build && \
    container_build_log image && \
    package update && \
    package upgrade && \
    package install \
                    FLARUM_BUILD_DEPS \
                    FLARUM_RUN_DEPS \
                    && \
    php-ext prepare && \
    php-ext reset && \
    php-ext enable core && \
    \
    clone_git_repo "${FLARUM_REPO_URL}" "v${FLARUM_VERSION}" "${LARAVEL_INSTALL_DATA_PATH}"/install && \
    cd "${LARAVEL_INSTALL_DATA_PATH}"/install && \
    build_assets /build-assets/src "${LARAVEL_INSTALL_DATA_PATH}"/install && \
    build_assets scripts && \
    composer install \
                    --no-interaction \
                    --no-progress \
                    --prefer-dist \
                    && \
    ln -sf flarum artisan && \
    rm -rf \
           "${LARAVEL_INSTALL_DATA_PATH}"/install/.git* \
           "${LARAVEL_INSTALL_DATA_PATH}"/install/.github \
           "${LARAVEL_INSTALL_DATA_PATH}"/install/CHANGELOG.md \
           "${LARAVEL_INSTALL_DATA_PATH}"/install/README.md \
           && \
    container_build_log add "Flarum ${FLARUM_VERSION}" "${FLARUM_REPO_URL}" && \
    \
    package remove FLARUM_BUILD_DEPS && \
    package cleanup && \
    rm -rf \
           /build-assets

COPY rootfs /
