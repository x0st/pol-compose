#!/usr/bin/env sh

PROJECT_DIR="${WORKSPACE}/pol-backend"
SERVICE_DIR="${COMPOSE}/services/pol-backend"
DOCKER_DIR="${SERVICE_DIR}/docker"
COMPOSER_VOLUME_DIR="${COMPOSE}/.pol-backend-composer-volume"
MYSQL_VOLUME_DIR="${COMPOSE}/.pol-backend-mysql-volume"

MYSQL_DOCKERFILE_DIR=${DOCKER_DIR}/services/mysql
NGINX_DOCKERFILE_DIR=${DOCKER_DIR}/services/nginx
PHP_DOCKERFILE_DIR=${DOCKER_DIR}/services/php

PREFIX="pol-pol-backend"

install() { #command
  docker run \
    --rm \
    --user "$(id -u)":"$(id -g)" \
    --volume "${PROJECT_DIR}":/app:delegated \
    --volume "${COMPOSER_VOLUME_DIR}":/composer:delegated \
    --env COMPOSER_HOME=/composer \
    --workdir /app \
    "${PREFIX}-php" \
    composer install
}

migrate() { #command
  docker exec "${PREFIX}-php" php artisan migrate
}

up() { #command
  BUILD=
  SERVICES="php,nginx,mysql"

  for ARG in ${@}; do
    case ${1} in
    -b|--build)
      BUILD=true
      shift
      ;;
    --services=*)
      SERVICES=$(echo "${1}" | sed 's|--services=||')
      shift
      ;;
    *)
      shift
      ;;
    esac
  done

  if __docker_container_running "${PREFIX}-php"; then
    echo "Already running! Shut if down first."
    exit 1
  fi

  if ! __docker_image_exists "${PREFIX}-nginx" || [ -n "${BUILD}" ]; then
    docker build "${NGINX_DOCKERFILE_DIR}" --tag "${PREFIX}-nginx"
  fi

  if ! __docker_image_exists "${PREFIX}-php" || [ -n "${BUILD}" ]; then
    docker build "${PHP_DOCKERFILE_DIR}" --tag "${PREFIX}-php"
  fi

  if ! __docker_image_exists "${PREFIX}-mysql" || [ -n "${BUILD}" ]; then
    docker build "${MYSQL_DOCKERFILE_DIR}" --tag "${PREFIX}-mysql"
  fi

  if ! docker network inspect "${PREFIX}-network" 2>/dev/null; then
    docker network create --driver bridge "${PREFIX}-network"
  fi

  if echo "${SERVICES}" | grep 'php'; then
    docker run --user $(id -u):$(id -g) --detach --network "${PREFIX}-network" --rm --name "${PREFIX}-php" --volume "${PROJECT_DIR}":/app:delegated "${PREFIX}-php" && sleep 5
  fi

  if echo "${SERVICES}" | grep 'nginx'; then
    docker run --detach --network "${PREFIX}-network" --rm --name "${PREFIX}-nginx" --volume "${PROJECT_DIR}":/app:delegated --publish 8001:80 "${PREFIX}-nginx"
  fi

  if echo "${SERVICES}" | grep 'mysql'; then
    docker run --detach --network "${PREFIX}-network" --rm --name "${PREFIX}-mysql" --volume "${MYSQL_VOLUME_DIR}":/var/lib/mysql:delegated --publish 3306:3306 "${PREFIX}-mysql"
  fi
}

down() { #command
  docker kill "${PREFIX}-php" 2>/dev/null || true
  docker kill "${PREFIX}-nginx" 2>/dev/null || true
  docker kill "${PREFIX}-mysql" 2>/dev/null || true

  docker network rm "${PREFIX}-network" 2>/dev/null || true
}

restart() { #command
  BUILD=

  for ARG in ${@}; do
    case ${1} in
    -b|--build)
      BUILD=--build
      shift
      ;;
    *)
      shift
      ;;
    esac
  done

  pol down --pol-backend
  pol up ${BUILD} --pol-backend
}
