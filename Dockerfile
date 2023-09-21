ARG DISTRO=alpine
ARG DISTRO_VARIANT=3.18

FROM docker.io/tiredofit/${DISTRO}:${DISTRO_VARIANT}
LABEL maintainer="Dave Conroy (github.com/tiredofit)"

ARG PHP_BASE=8.2
ARG UNIT_VERSION

ENV UNIT_VERSION=1.31.0-1 \
    UNIT_USER=unit \
    UNIT_GROUP=www-data \
    UNIT_WEBROOT=/www/html \
    UNIT_REPO_URL=https://github.com/nginx/unit \
    IMAGE_NAME="tiredofit/unit" \
    IMAGE_REPO_URL="https://github.com/tiredofit/unit/"

RUN source assets/functions/00-container && \
    set -x && \
    case "${PHP_BASE}" in \
       8.2 ) export php_abbrev="82";; \
       8.1 ) export php_abbrev="81";; \
    esac ; \
    case "$(cat /etc/os-release | grep VERSION_ID | cut -d = -f 2 | cut -d . -f 1,2 | cut -d _ -f 1)" in \
        3.12 | 3.15 | 3.16 ) php_packages="php${php_abbrev}-dev php${php_abbrev}-embed" ; _php_config="./configure php --module=php${php_abbrev} --config=php-config${php-abbrev}" ;; \
        *) php_packages="php82-dev php82-embed php81-dev php81-embed" ; _php_config="./configure php --module=php81 --config=php-config81" ; _php_config2="./configure php --module=php82 --config=php-config82" ;  ;; \
    esac ; \
    ${test} && \
    adduser -D -S -s /sbin/nologin \
            -h /var/lib/unit \
            -G "${UNIT_GROUP}" \
            -g "${UNIT_GROUP}" \
            -u 80 \
            "${UNIT_USER}" \
            && \
    \
    package update && \
    package upgrade && \
    package install .unit-build-deps \
                    $(if [ -f "/unit-assets/build-deps" ] ; then echo "/unit-assets/build-deps"; fi;) \
                    build-base \
                    git \
                    linux-headers \
	                nodejs \
                    npm \
                    openssl-dev \
                    pcre-dev \
                    perl-dev \
                	${php_packages} \
                	python3-dev \
                	ruby-dev \
                    && \
    \
    package install .unit-run-deps \
                    $(if [ -f "/unit-assets/run-deps" ] ; then echo "/unit-assets/run-deps" ; fi;) \
                    jq \
                    && \
    \
    clone_git_repo "${UNIT_REPO_URL}" "${UNIT_VERSION}" && \
    curl -sSL https://git.alpinelinux.org/aports/plain/community/unit/phpver.patch | patch -p1 && \
    ./configure \
		--prefix="/usr" \
		--localstatedir="/var" \
		--statedir="/var/lib/unit" \
		--control="unix:/run/control.unit.sock" \
		--pid="/run/unit.pid" \
		--log="/var/log/unit/unit.log" \
		--mandir=/usr/src/unit.tmp \
		--modulesdir="/usr/lib/unit/modules" \
        --tmpdir=/tmp \
		--openssl \
		--user="${UNIT_USER}" \
		--group="${UNIT_GROUP}" \
        $(if [ -f "/unit-assets/configure-args" ] ; then echo "/unit-assets/configure-args" ; fi;) \
        --tests \
        && \
    ./configure nodejs && \
    ./configure perl && \
    ${_php_config} ; ${_php_config2} && \
    ./configure python --config=python3-config && \
    ./configure ruby && \
    make -j $(nproc) && \
	make tests && \
    make install && \
    strip /usr/sbin/unitd && \
    package remove .unit-build-deps \
                    && \
    package cleanup && \
    \
    mkdir -p \
                /etc/unit/sites.available \
                /etc/unit/sites.enabled \
                /etc/unit/snippets \
                && \
    rm -rf /root/.cache \
           /root/.npm \
           /usr/src/*

EXPOSE 80

COPY install /
