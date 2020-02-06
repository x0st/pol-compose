#!/usr/bin/env sh

PROJECT_DIR="${WORKSPACE}/pol-frontend"
SERVICE_DIR="${COMPOSE}/services/pol-frontend"

DOCKER_DIR="${SERVICE_DIR}/docker"
NGINX_DOCKERFILE_DIR="${DOCKER_DIR}/services/nginx"

PREFIX="pol-pol-frontend"

up() { #command
  if __docker_container_running "${PREFIX}-nginx"; then
    echo "Already running! Shut if down first."
    exit 1
  fi

  BUILD=

  for _ in ${@}; do
    case ${1} in
    -b|--build)
      BUILD=true
      shift
      ;;
    *)
      shift
      ;;
    esac
  done

  if ! __docker_image_exists "${PREFIX}-nginx" || [ -n "${BUILD}" ]; then
    docker build "${NGINX_DOCKERFILE_DIR}" --tag "${PREFIX}-nginx"
  fi

  docker run \
        --detach \
        --rm \
        --publish 8002:80 \
        --name "${PREFIX}-nginx" \
        --volume "${PROJECT_DIR}":/app:delegated \
        "${PREFIX}-nginx"
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

  pol down --pol-frontend
  pol up ${BUILD} --pol-frontend
}

down() { #command
  docker kill "${PREFIX}-nginx" 2> /dev/null || true
}
