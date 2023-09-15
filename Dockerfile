ARG DISTRO=alpine
ARG DISTRO_VARIANT=3.18

FROM docker.io/tiredofit/${DISTRO}:${DISTRO_VARIANT}
LABEL maintainer="Dave Conroy (github.com/tiredofit)"

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
	                openssl-dev \
                    pcre-dev \
                    #perl-dev \
                	php82-dev \
                	php82-embed \
                	#python3-dev \
                	#ruby-dev \
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
    #./configure perl && \
    ./configure php --module=php82 --config=php-config82 && \
    #./configure python --config=python3-config && \
    #./configure ruby && \
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
    rm -rf /usr/src/*

EXPOSE 80

COPY install /
