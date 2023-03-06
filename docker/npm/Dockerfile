FROM node:18-alpine3.17

###############################################################################
# Set App Name
###############################################################################
ARG APP_NAME=creapass
ENV APP_NAME ${APP_NAME:-creapass}

###############################################################################
# Set User, User UID and User GUID
###############################################################################
ARG DEFAULT_USER=node
ENV DEFAULT_USER ${DEFAULT_USER}

ARG DEFAULT_USER_UID=1000
ENV DEFAULT_USER_UID ${DEFAULT_USER_UID}

ARG DEFAULT_USER_GUID=1000
ENV DEFAULT_USER_GUID ${DEFAULT_USER_GUID}

###############################################################################
# Set application prefix path
###############################################################################
ARG APP_PATH_PREFIX
ENV APP_PATH_PREFIX ${APP_PATH_PREFIX:-/usr/src}

###############################################################################
# Default directory for application deployment
# Location of the folder in the container, path of the folder inside the 
# container
###############################################################################
ENV REMOTE_SRC ${APP_PATH_PREFIX}/${APP_NAME}

###############################################################################
# Default APP_ENV
###############################################################################
ARG APP_ENV=production
ENV APP_ENV ${APP_ENV:-production}

###############################################################################
# Application directory
# Sets the working directory for any RUN, CMD, ENTRYPOINT, COPY and ADD
# instructions that follow it in the Dockerfile.
###############################################################################
WORKDIR $REMOTE_SRC

###############################################################################
# Define the running user
###############################################################################
USER root

###############################################################################	
# Mandatory Software's Installation
###############################################################################
RUN addgroup -S app && adduser -S -G app app 

###############################################################################	
# App
# Check if the path/folder of the $REMOTE_SRC variable does not exist
###############################################################################	
RUN set -ex &&                                           \
		mkdir -p $REMOTE_SRC &&                          \
        chown -R $DEFAULT_USER:$DEFAULT_USER $REMOTE_SRC 

###############################################################################	
# Set Working Directory
###############################################################################	
WORKDIR $REMOTE_SRC

###############################################################################	
# Copy source in Docker Image
###############################################################################
COPY ./src/package*.json ./
COPY ./src/keys/ ./keys/
COPY ./src/keyList.json ./
COPY ./src/.gitignore ./
COPY ./src/index.js ./
COPY ./src/index.js ./
COPY ./src/README.md ./

###############################################################################	
# Install dependencies
###############################################################################	
RUN apk add --no-cache openssh-client git
RUN apk add --update nodejs
RUN npm -g install npm@latest

###############################################################################	
# Set the goods rghts for REMOTE_SRC
###############################################################################	
RUN set -ex && chown -R $DEFAULT_USER:$DEFAULT_USER $REMOTE_SRC

###############################################################################	
# Change current user to DEFAULT_USER
###############################################################################	
USER $DEFAULT_USER