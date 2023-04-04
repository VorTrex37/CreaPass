###############################################################################
# var definition
###############################################################################
SHELL:=/bin/bash
PATH_ROOT = $(shell pwd)
DOCKER_COMPOSE = docker-compose
DOCKER_COMPOSE_MAIN_FILE = docker/docker-compose.yml

DOCKER_COMPOSE_PROD_FILE = docker/docker-compose-prod.yml
DOCKER_COMPOSE_DEV_FILE = docker/docker-compose-dev.yml

DOCKER_ENV_MAIN_FILE = ${PATH_ROOT}/config/.docker-main.env
DOCKER_ENV_TMP_FILE = ${PATH_ROOT}/config/.docker-temporary.env

TEMPLATE_ENV_SRC = ${PATH_ROOT}/config/.env.${DEPLOYMENT_ENV}.tpl
TEMPLATE_ENV_DEST = ${PATH_ROOT}/src/.env.${DEPLOYMENT_ENV}.tpl

ENV_DEST = ${PATH_ROOT}/src/.env

###############################################################################
# Available list (containers, actions, ...)
###############################################################################
CONTAINERS = app
ACTIONS = build up start restart run stop halt logs bash

###############################################################################
# Set production environment (default)
###############################################################################
DOCKER_COMPOSE_MAIN_FILE_SELECTED = $(DOCKER_COMPOSE_MAIN_FILE) -f $(DOCKER_COMPOSE_PROD_FILE)
DOCKER_ENV_FILE = ${PATH_ROOT}/config/.docker-main.env
COMPOSER_FLAGS = 
NETWORK_SUFFIX = pro
DEPLOYMENT_ENV = none

###############################################################################
# Set environment (dev or prod)
###############################################################################
ENVIRONMENT = $(shell [ -f ./ENV ] && cat ./ENV || echo production)

$(info $$ENVIRONMENT is [${ENVIRONMENT}])

###############################################################################
# Override environment (if necessary)
###############################################################################
ifeq ($(ENVIRONMENT), production)
DOCKER_COMPOSE_MAIN_FILE_SELECTED = $(DOCKER_COMPOSE_MAIN_FILE) -f $(DOCKER_COMPOSE_PROD_FILE)
COMPOSER_FLAGS = 
NETWORK_SUFFIX = pro
DEPLOYMENT_ENV = production
endif
ifeq ($(ENVIRONMENT), prod)
DOCKER_COMPOSE_MAIN_FILE_SELECTED = $(DOCKER_COMPOSE_MAIN_FILE) -f $(DOCKER_COMPOSE_PROD_FILE)
COMPOSER_FLAGS = 
NETWORK_SUFFIX = pro
DEPLOYMENT_ENV = production
endif
ifeq ($(ENVIRONMENT), dev)
DOCKER_COMPOSE_MAIN_FILE_SELECTED = $(DOCKER_COMPOSE_MAIN_FILE) -f $(DOCKER_COMPOSE_DEV_FILE)
COMPOSER_FLAGS = 
NETWORK_SUFFIX = dev
DEPLOYMENT_ENV = development
endif
ifeq ($(ENVIRONMENT), development)
DOCKER_COMPOSE_MAIN_FILE_SELECTED = $(DOCKER_COMPOSE_MAIN_FILE) -f $(DOCKER_COMPOSE_DEV_FILE)
COMPOSER_FLAGS = 
NETWORK_SUFFIX = dev
DEPLOYMENT_ENV = development
endif

ifeq ($(DEPLOYMENT_ENV), none )
 $(error "$$DEPLOYMENT_ENV not defined in ./ENV file ")
endif

export APP_NAME = $(shell grep -e "^APP_NAME="  ${PATH_ROOT}/config/.env.${DEPLOYMENT_ENV}.tpl | cut -d '=' -f2 | tr -d '"' | tr -d "'")
DOCKER_ENV_FILE = ${PATH_ROOT}/config/.docker-${DEPLOYMENT_ENV}.env

####################################################################{###########
# targets to manage all containers
###############################################################################
# build-project ==> Build the project
build-project: build-project-without-start upall
build-project-without-start: prerequisite update-project build-containers

# buildall ===> build all containers
buildall: prerequisite build-containers

# downall ===> down all containers
downall: prerequisite
	@printf $(call message_info, Down all ↓)
	@$(DOCKER_COMPOSE) --env-file $(DOCKER_ENV_TMP_FILE)  -f $(DOCKER_COMPOSE_MAIN_FILE_SELECTED) down --remove-orphans

# upall ===> up all containers
upall : prerequisite
	@printf $(call message_info, Up all 🚀)
	@$(DOCKER_COMPOSE) --env-file $(DOCKER_ENV_TMP_FILE)  -f $(DOCKER_COMPOSE_MAIN_FILE_SELECTED) up -d

###############################################################################
# target to clean docker images and dependencies
###############################################################################
# clean ===> remove the docker containers and deletes project dependencies
clean: prerequisite prompt-continue
	# Remove the node depenencies
	rm -rf src/node_modules

	# Remove the docker containers
	$(DOCKER_COMPOSE) --env-file $(DOCKER_ENV_TMP_FILE)  -f $(DOCKER_COMPOSE_MAIN_FILE_SELECTED) down --rmi all -v --remove-orphans

###############################################################################
# targets to manage individual container
###############################################################################
# build ===> compile given container
build: prerequisite valid-container select-composefile npm-install
	$(DOCKER_COMPOSE) --env-file $(DOCKER_ENV_TMP_FILE)  -f $(DOCKER_COMPOSE_MAIN_FILE_SELECTED) build --no-cache $(filter-out $@,$(MAKECMDGOALS))

# up ===> Builds, (re)creates, starts, and attaches to containers for a service.
up: prerequisite valid-container select-composefile
	@$(DOCKER_COMPOSE) --env-file $(DOCKER_ENV_TMP_FILE)  -f $(DOCKER_COMPOSE_MAIN_FILE_SELECTED) up -d  $(filter-out $@,$(MAKECMDGOALS))

# restart ===> stop container and start container
restart: prerequisite
	@$(DOCKER_COMPOSE) --env-file $(DOCKER_ENV_TMP_FILE)  -f $(DOCKER_COMPOSE_MAIN_FILE_SELECTED) stop $(filter-out $@,$(MAKECMDGOALS))
	@$(DOCKER_COMPOSE) --env-file $(DOCKER_ENV_TMP_FILE)  -f $(DOCKER_COMPOSE_MAIN_FILE_SELECTED) start $(filter-out $@,$(MAKECMDGOALS))

# start ===> Starts existing containers for a service (make start <container>)
start: prerequisite valid-container select-composefile
	@$(DOCKER_COMPOSE) --env-file $(DOCKER_ENV_TMP_FILE)  -f $(DOCKER_COMPOSE_MAIN_FILE_SELECTED) start $(filter-out $@,$(MAKECMDGOALS))

# run ===> run nprogram in given container
run: prerequisite valid-container select-composefile
	@$(DOCKER_COMPOSE) --env-file $(DOCKER_ENV_TMP_FILE)  -f $(DOCKER_COMPOSE_MAIN_FILE_SELECTED) run --rm $(filter-out $@,$(MAKECMDGOALS))

# stop ===> Stop existing containers for a service.
stop: prerequisite valid-container select-composefile
	@$(DOCKER_COMPOSE) --env-file $(DOCKER_ENV_TMP_FILE)  -f $(DOCKER_COMPOSE_MAIN_FILE_SELECTED) stop $(filter-out $@,$(MAKECMDGOALS))

# Logs ==> get logs from the docker containers
logs: prerequisite valid-container select-composefile
	@$(DOCKER_COMPOSE) --env-file $(DOCKER_ENV_TMP_FILE)  -f $(DOCKER_COMPOSE_MAIN_FILE_SELECTED) logs --tail=100 -f $(filter-out $@,$(MAKECMDGOALS))


###############################################################################
# connect container(s)
###############################################################################
# bash ===> get bash into the docker containers
sh: prerequisite valid-container select-composefile select-user
	@$(DOCKER_COMPOSE) --env-file $(DOCKER_ENV_TMP_FILE)  -f $(DOCKER_COMPOSE_MAIN_FILE_SELECTED) exec $(DOCKER_USER) $(filter-out $@,$(MAKECMDGOALS)) sh

# bash-root ===> get bash into the docker containers with root user
sh-root: prerequisite valid-container select-composefile select-user
	@$(DOCKER_COMPOSE) --env-file $(DOCKER_ENV_TMP_FILE)  -f $(DOCKER_COMPOSE_MAIN_FILE_SELECTED) exec $(filter-out $@,$(MAKECMDGOALS)) sh

###############################################################################
# npm tools targets
###############################################################################
# npm-install ===> call npm install with an external container
npm-install: prerequisite
	@$(DOCKER_COMPOSE) --env-file $(DOCKER_ENV_TMP_FILE) -f $(DOCKER_COMPOSE_MAIN_FILE_SELECTED) run app npm install $(filter-out $@,$(MAKECMDGOALS))

npm-remove: prerequisite
	@$(DOCKER_COMPOSE) --env-file $(DOCKER_ENV_TMP_FILE) -f $(DOCKER_COMPOSE_MAIN_FILE_SELECTED) run app npm remove $(filter-out $@,$(MAKECMDGOALS))

npm-update: prerequisite
	@$(DOCKER_COMPOSE) --env-file $(DOCKER_ENV_TMP_FILE) -f $(DOCKER_COMPOSE_MAIN_FILE_SELECTED) run app npm update $(filter-out $@,$(MAKECMDGOALS))
###############################################################################
# internal targets prerequisite
###############################################################################
prerequisite: revision
include $(DOCKER_ENV_MAIN_FILE)
include $(DOCKER_ENV_FILE)

export ENV_FILE = $(DOCKER_ENV_FILE)
export PROJECT_DIRECTORY = ${PATH_ROOT}
export SHORT_ENVIRONMENT = $(shell echo ${ENVIRONMENT} | cut -c1-3)
export ENV_FILE_NAME=$(shell basename ${ENV_FILE})
export APP_ENV = $(shell grep -e "^APP_ENV="  ${PATH_ROOT}/config/.env.${DEPLOYMENT_ENV}.tpl | cut -d '=' -f2 )

export DOCKER_ENV_TMP_FILE
export DEPLOYMENT_ENV
export CONTAINER_NAME_APP=${APP_NAME}_app_${SHORT_ENVIRONMENT}
export NETWORK_SUFFIX

revision:
	$(info $$APP_NAME is [${APP_NAME}])
	$(info $$ENV_FILE_NAME is [${ENV_FILE_NAME}])
	$(info $$APP_ENV is [${APP_ENV}])
	$(info $$DEPLOYMENT_ENV is [${DEPLOYMENT_ENV}])
	$(info $$SHORT_ENVIRONMENT is [${SHORT_ENVIRONMENT}])
	$(info $$DOCKER_COMPOSE_MAIN_FILE_SELECTED is [${DOCKER_COMPOSE_MAIN_FILE_SELECTED}])
	$(info $$NETWORK_SUFFIX is [${NETWORK_SUFFIX}])
	@if [  "${APP_NAME}" = "" ] ; then \
		echo "Error env variable APP_NAME must be set in ${PATH_ROOT}/config/.env.${DEPLOYMENT_ENV} " ; \
		exit 1; \
	  fi ;
	@if [[ "${HOST_ENV}" != "production" ]] && [[ "${DEPLOYMENT_ENV}" = "production" || "${DEPLOYMENT_ENV}" = "preprod" ]]; then \
		echo "Error the host server must a prod server HOST_ENV: ${HOST_ENV}  ${DEPLOYMENT_ENV} DEPLOYMENT_ENV" ; \
		exit 1; \
	  fi ;
	@if [[ "${APP_ENV}" = "production" ]] && [[ "${DEPLOYMENT_ENV}" != "production" && "${DEPLOYMENT_ENV}" != "preprod" ]] ; then \
		echo "Error APP_ENV ${APP_ENV} not coherent with  ${DEPLOYMENT_ENV} DEPLOYMENT_ENV" ; \
		exit 1; \
	  fi ;
	@if [[ "${APP_ENV}" = "development" ]] && [[ "${DEPLOYMENT_ENV}" = "production" ||  "${DEPLOYMENT_ENV}" = "preprod" ]] ; then \
		echo "Error APP_ENV ${APP_ENV} not coherent with  ${DEPLOYMENT_ENV} DEPLOYMENT_ENV" ; \
		exit 1; \
	  fi ;


	@cat ${DOCKER_ENV_MAIN_FILE} > ${DOCKER_ENV_TMP_FILE}
	@cat ${DOCKER_ENV_FILE} >> ${DOCKER_ENV_TMP_FILE}
	@echo "" >> ${DOCKER_ENV_TMP_FILE}
	@echo "#####################################################" >> ${DOCKER_ENV_TMP_FILE}
	@echo "#             VARIABLES ADDED BY MAKEFILE           " >> ${DOCKER_ENV_TMP_FILE}
	@echo "#####################################################" >> ${DOCKER_ENV_TMP_FILE}
	@grep -q '^APP_NAME=' ${DOCKER_ENV_TMP_FILE} && sed -i.tmp "s/^APP_NAME=.*/APP_NAME=${APP_NAME}/" "${DOCKER_ENV_TMP_FILE}" || echo "APP_NAME=${APP_NAME}" >> "${DOCKER_ENV_TMP_FILE}"
	@grep -q '^APP_ENV=' ${DOCKER_ENV_TMP_FILE} && sed -i.tmp "s/^APP_ENV=.*/APP_ENV=${APP_ENV}/" "${DOCKER_ENV_TMP_FILE}" || echo "APP_ENV=${APP_ENV}" >> "${DOCKER_ENV_TMP_FILE}"

	@if [[ -f "${TEMPLATE_ENV_SRC}" ]] ; then \
		set -o allexport ; \
		source ${DOCKER_ENV_TMP_FILE} ; \
		set +o allexport ; \
		ENV_VARIABLES=`awk 'BEGIN{for(v in ENVIRON) print "$$"v}'`; \
		envsubst "$$ENV_VARIABLES" < ${TEMPLATE_ENV_SRC} > ${ENV_DEST}; \
	fi ;

test: prerequisite
	if [[ -f "${TEMPLATE_ENV_SRC}" ]] ; then \
		set -o allexport ; \
		source ${DOCKER_ENV_TMP_FILE} ; \
		set +o allexport ; \
		ENV_VARIABLES=`awk 'BEGIN{for(v in ENVIRON) print "$$"v}'`; \
		envsubst "$$ENV_VARIABLES" < ${TEMPLATE_ENV_SRC} > ${ENV_DEST}; \
	fi ;



###############################################################################
# internal target valid-container
###############################################################################
valid-container:
# $(info valid-container call)
ifeq ($(filter-out $(ACTIONS) $@,$(MAKECMDGOALS)),)
	$(error empty container to build)
endif
ifeq ($(filter $(filter-out $(ACTIONS) $@,$(MAKECMDGOALS)),$(CONTAINERS)),)
	$(error Invalid container provided "$(filter-out $(ACTIONS) $@,$(MAKECMDGOALS))")
endif

###############################################################################
# internal target select-composefile (set pre-build compose file if necessary)
###############################################################################
select-composefile:
# $(info select-composefile call)
ifneq ($(filter $(filter-out $@,$(MAKECMDGOALS)),$(PREBUILD_CONTAINERS)),)
DOCKER_COMPOSE_MAIN_FILE_SELECTED = $(DOCKER_COMPOSE_BUILD_FILE)
$(info $$DOCKER_COMPOSE_MAIN_FILE_SELECTED is [${DOCKER_COMPOSE_MAIN_FILE_SELECTED}])
endif

###############################################################################
# internal target select-user (set the good user for app or horizon container)
###############################################################################
select-user:
ifeq ($(filter $(filter-out $@,$(MAKECMDGOALS)),$(LARADOCK_CONTAINERS)), app)
DOCKER_USER = -u node
endif

###############################################################################
# internal target build-containers
###############################################################################
build-containers: prerequisite
	@$(DOCKER_COMPOSE) --env-file $(DOCKER_ENV_TMP_FILE)  -f $(DOCKER_COMPOSE_MAIN_FILE_SELECTED) up -d --build

###############################################################################
# internal target update-project
# $(MAKE) artisan passport:install
###############################################################################
update-project: prerequisite 
#if [ -d "bootstrap/cache" ]; then rm -rf bootstrap/cache/* ; fi;
	$(MAKE) npm-install

###############################################################################
# internal target log functions
# $(MAKE) artisan passport:install
###############################################################################
define message_failure
	"\033[1;31m ❌$(1)\033[0m"
endef

define message_success
	"\033[1;32m ✅$(1)\033[0m"
endef

define message_info
	"\e[0;34m❕$(1)\e[0m\n"
endef
###############################################################################
# internal target prompt
###############################################################################
# prompt-continue ===> Prompt to continue
prompt-continue:
	@while [ -z "$$CONTINUE" ]; do \
		read -r -p "Would you like to continue? [y]" CONTINUE; \
	done ; \
	if [ ! $$CONTINUE == "y" ]; then \
        echo "Exiting." ; \
        exit 1 ; \
    fi

%:
	@: