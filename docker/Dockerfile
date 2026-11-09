################################################################################
#            EF5: ENSEMBLE FRAMEWORK FOR FLASH FLOOD FORECASTING
#                   DYNAMIC DOCKERIZATION IMPLEMENTATION
################################################################################
# Author: Jorge A. Duarte
# Email: jduarte@ou.edu/jorge.duarte@noaa.gov
# Version: 1.0
# Date: Apr. 09, 2023
#
# Contribution: Kyle K. Hugeback
# Email: Kyle.hugeback@ou.edu/kyle.hugeback@noaa.gov
# Version: 2.0
# Date: Oct. 27, 2026
# ------------------------------------------------------------------------------
# This Dockerfile builds one Docker image:
# - 'ef5-container' image which will compile and host the EF5 installation,
# linked to two distinct shared folders:
#    + ./conf: where the container will look for an EF5 control file
#    + ./data: where the container will look for the required data to run EF5 
#
# These image must be instantiated using docker-compose and ./docker-compose.yml
################################################################################


################################################################################
#                    BUILD ARGUMENTS & ENVIRONMENT VARIABLES
################################################################################
# Define the Alpine OS version as a build argument, defaulting to the verified baseline
ARG ALPINE_VERSION=3.17
FROM alpine:${ALPINE_VERSION}

# Define build arguments for dynamic source selection, defaulting to the HyDROSLab baseline
ARG EF5_REPO_URL=https://github.com/HyDROSLab/EF5.git
ARG EF5_BRANCH=master

# Install universal software building tools and EF5 dependencies
RUN apk update && apk add --no-cache \
    git \
    automake \
    autoconf \
    build-base \
    libgeotiff-dev

# Clone the selected repository into /ef5 and compile the application
RUN git clone -b ${EF5_BRANCH} ${EF5_REPO_URL} /ef5 \
    && cd /ef5 \
    && autoreconf --force --install \
    && ./configure \
    && make \
    && make install

# Create communication mount points for the host machine
RUN mkdir /conf /data /results
VOLUME ["/conf", "/data", "/results"]

# Set the working directory to the EF5 installation path
WORKDIR /ef5

# Default execution command pointing to the required control file name
CMD ["ef5", "/conf/control.txt"]