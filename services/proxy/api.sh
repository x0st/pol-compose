#!/usr/bin/env sh

. "${COMPOSE}/functions.sh"

SERVICE_DIR="${COMPOSE}/services/proxy"
DOCKER_DIR="${SERVICE_DIR}/docker"
NGINX_DOCKERFILE_DIR="${DOCKER_DIR}/services/nginx"
SSL_DIR="${NGINX_DOCKERFILE_DIR}/ssl"

SSL_KEY_FILE="${NGINX_DOCKERFILE_DIR}/ssl/domain.key"
SSL_CERTIFICATE_FILE="${NGINX_DOCKERFILE_DIR}/ssl/domain.crt"

PREFIX="pol-proxy"

generate_ssl() {
  rm -f "${SSL_CERTIFICATE_FILE}" "${SSL_KEY_FILE}"

  __replace --in="${DOCKER_DIR}/csr.config.tpl" --out="${COMPOSE}/.tmp/csr.config" \
                  --what="KEY"  --with="${SSL_KEY_FILE}" \
                  --what="HOST" --with="${HOST}"

  test -d "${SSL_DIR}" || mkdir "${SSL_DIR}"

  openssl genrsa -out "${SSL_KEY_FILE}" 2048
  openssl req -config "${COMPOSE}/.tmp/csr.config" -new -key "${SSL_KEY_FILE}" -out "${COMPOSE}/.tmp/domain.csr" -verbose
  openssl x509 -signkey "${SSL_KEY_FILE}" -in "${COMPOSE}/.tmp/domain.csr" -req -days 365 -out "${SSL_CERTIFICATE_FILE}"
}

etc_hosts() { #command
  if ! grep "127.0.0.1 api.${HOST}" </etc/hosts >/dev/null; then
    echo "127.0.0.1 api.${HOST}" | sudo tee -a /etc/hosts
  fi
  if ! grep "127.0.0.1 ${HOST}" </etc/hosts >/dev/null; then
    echo "127.0.0.1 ${HOST}" | sudo tee -a /etc/hosts
  fi
}

up() { #command
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

  if __docker_container_running "${PREFIX}-nginx"; then
    echo "Already running! Shut it down first."
    exit 1
  fi

  if ! test -f "${SSL_CERTIFICATE_FILE}" || ! test -f "${SSL_KEY_FILE}"; then
    echo "Could not find SSL files."
    echo "Generating..."

    generate_ssl
  fi

  if [ -n "${BUILD}" ] || ! __docker_image_exists "${PREFIX}-nginx"; then
    docker build "${NGINX_DOCKERFILE_DIR}" --build-arg HOST="${HOST}" --build-arg HOST_MACHINE_ADDR="$(__host_machine_addr)" --tag "${PREFIX}-nginx"
  fi

  docker run --rm --publish 80:80 --publish 443:443 --name "${PREFIX}-nginx" --detach "${PREFIX}-nginx"
}


down() { #command
  docker kill "${PREFIX}-nginx" 2> /dev/null
}

restart() { #command
  BUILD=

  for _ in ${@}; do
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

  pol down --proxy
  pol up ${BUILD} --proxy
}
