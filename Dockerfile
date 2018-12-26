FROM ubuntu:xenial
LABEL maintainer="Nimbix, Inc."

# Update SERIAL_NUMBER to force rebuild of all layers (don't use cached layers)
ARG SERIAL_NUMBER
ENV SERIAL_NUMBER ${SERIAL_NUMBER:-20181226.1005}

ARG GIT_BRANCH
ENV GIT_BRANCH ${GIT_BRANCH:-master}

ARG DEBIAN_FRONTEND=noninteractive

# Add image-common for Desktop support, FFmpeg and codecs
RUN apt-get -y update && \
    apt-get -y install ffmpeg libavcodec-extra ubuntu-restricted-extras winff && \
    apt-get -y install curl && \
    curl -H 'Cache-Control: no-cache' \
        https://raw.githubusercontent.com/nimbix/image-common/$GIT_BRANCH/install-nimbix.sh \
        | bash -s -- --setup-nimbix-desktop --image-common-branch $GIT_BRANCH

COPY NAE/help.html /etc/NAE/help.html
COPY NAE/screenshot.png /etc/NAE/screenshot.png

# AppDef validation
COPY NAE/AppDef.json /etc/NAE/AppDef.json
RUN curl --fail -X POST -d @/etc/NAE/AppDef.json https://api.jarvice.com/jarvice/validate

# Expose port 22 for local JARVICE emulation in docker
EXPOSE 22

# for standalone use
EXPOSE 5901
EXPOSE 443
