ARG DISTRO=alpine
ARG DISTRO_VARIANT=3.18

FROM docker.io/tiredofit/${DISTRO}:${DISTRO_VARIANT}
LABEL maintainer="Dave Conroy (github.com/tiredofit)"

ARG UNIT_VERSION

ENV UNIT_VERSION=1.31.0-1 \
    UNIT_REPO_URL=https://github.com/nginx/unit \
    IMAGE_NAME="tiredofit/unit" \
    IMAGE_REPO_URL="https://github.com/tiredofit/unit/"

RUN source assets/functions/00-container && \
    set -x && \
    addgroup -S -g 80 unit && \
    adduser -D -S -s /sbin/nologin \
            -h /dev/null \
            -G unit \
            -g "unit" \
            -u 80 unit \
            && \
    \
    package update && \
    package upgrade && \
    package install .unit-build-deps \
                    git \
                    && \
    \
    package install .unit-run-deps \
                    package \
                    && \
    \
    ##
    ##
    package remove .unit-build-deps \
                    && \
    package cleanup && \
    \
    rm -rf /usr/src/*

EXPOSE 80

COPY install /
