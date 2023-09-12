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
            -G www-data \
            -g "www-data" \
            -u 80 unit \
            && \
    \
    package update && \
    package upgrade && \
    package install .unit-build-deps \
                    build-base \
                    git \
                    linux-headers \
	                #openssl-dev \
                    pcre-dev \
                    && \
    \
    package install .unit-run-deps \
                    jq \
                    && \
    \
    clone_git_repo "${UNIT_REPO_URL}" "${UNIT_VERSION}" && \
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
		#--openssl \
		--user="${UNIT_USER}" \
		--group="${UNIT_GROUP}" \
		--tests \
        && \
	make -j $(nproc) && \
	make tests && \
    make install && \
    strip /usr/sbin/unitd && \
    package remove .unit-build-deps \
                    && \
    package cleanup && \
    \
    rm -rf /usr/src/*

EXPOSE 80

COPY install /
