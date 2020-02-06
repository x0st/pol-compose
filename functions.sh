#!/usr/bin/env sh

__command_exists() {
  _REQUESTED_SERVICE_NAME="${1}"
  _REQUESTED_COMMAND="${2}"
  _SERVICE_DIR="${COMPOSE}/services/${_REQUESTED_SERVICE_NAME}"

  grep "^${_REQUESTED_COMMAND}.*#command" < "${_SERVICE_DIR}/api.sh" > /dev/null
}

__call_command() {
  _REQUESTED_SERVICE_NAME=${1}
  _REQUESTED_COMMAND=${2}
  shift
  shift
  _SERVICE_DIR=${COMPOSE}/services/${_REQUESTED_SERVICE_NAME}
  _API_FILE="${_SERVICE_DIR}/api.sh"

  _COMMANDS=$(grep '#command' < "${_API_FILE}" | grep -o '[a-zA-Z]*' | xargs)

  . "${_API_FILE}"

  ${_REQUESTED_COMMAND} ${@}

  for _COMMAND in ${_COMMANDS};
  do
    unset -f ${_COMMAND}
  done
}

__docker_image_exists() {
  docker image ls | grep "${1}" 2> /dev/null
}

__docker_container_running() {
  docker ps | grep "${1}" 2> /dev/null
}

__service_exists() {
  _SERVICE_NAME=${1}
  _SERVICE_DIR="${COMPOSE}/services/${_SERVICE_NAME}"

  test -d "${_SERVICE_DIR}"
}

__replace() {
  WHAT=
  WITH=
  OUT=
  IN=

  IT=0

  for _ in ${@}; do
    case ${1} in
    --in=*)
      IN=$(echo "${1}" | sed 's|--in=||')
      shift
      ;;
    --out=*)
      OUT=$(echo "${1}" | sed 's|--out=||')
      shift
      ;;
    --what=*)
      WHAT=$(echo "${1}" | sed 's|--what=||')
      shift
      ;;
    --with=*)
      WITH=$(echo "${1}" | sed 's|--with=||')
      shift

      if [ -z "${IN}" ] || [ -z "${OUT}" ] || [ -z "${WHAT}" ]; then
        echo "Usage __replace --in=/path/to/input-file --out=/path/to/output-file --what=PLACEHOLDER --with=REPRLACEMENT"
        return 0
      fi

      IT=$((IT+1))
      sed "s|%${WHAT}%|${WITH}|g" < "${IN}" > "${COMPOSE}/.tmp/$(basename "${OUT}")-${IT}"
      IN="${COMPOSE}/.tmp/$(basename "${OUT}")-${IT}"
      ;;
    esac
  done

  cp "${IN}" "${OUT}"

  while [ ${IT} != 0 ]; do
    rm -f "${COMPOSE}"/.tmp/"${OUT}"-${IT}
    IT=$((IT-1))
  done
}

__os() {
  MACHINE=

  case "$(uname -s)" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac;;
  esac

  echo ${MACHINE}
}

__host_machine_addr() {
  if [ "$(__os)" = "Linux" ]; then
    docker run --rm alpine ip route | awk '/default/ { print $3 }'
  elif [ "$(__os)" = "Mac" ]; then
    echo host.docker.internal
  else
    echo "Unable to identify ip address of the host machine."
    exit 1
  fi
}
