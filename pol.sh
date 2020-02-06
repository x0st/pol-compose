#!/usr/bin/env sh

DOT_ENV=$(readlink "${0}" | sed "s|pol.sh|.env|")

# -e: if a simple command fails for any reason, then the shell shall immediately exit
set -e

# abort the script immediatly on CTRL + C
trap 'exit 1' INT

if test -f "${DOT_ENV}"; then
  export $(xargs <"${DOT_ENV}")
fi

if [ -z "${HOST}" ]; then
  echo "The variable HOST contains an invalid host."
  exit 1
fi

if ! test -d "${WORKSPACE}"; then
  echo "The variable WORKSPACE contains an invalid path."
  exit 1
fi

if ! test -d "${COMPOSE}"; then
  echo "The variable COMPOSE contains an invalid path."
  exit 1
fi

if [ -z "${1}" ]; then
  echo "Give me a command!"
  exit 1
else
  COMMAND=${1}
  shift
fi

CHOSEN_SERVICES=
POSITIONAL=

for ARG in ${@}; do
  case ${1} in
  --*)
    SERVICE_NAME=$(echo "${1}" | sed "s|--||")

    if ! test -d "${COMPOSE}/services/${SERVICE_NAME}"; then
      POSITIONAL="${POSITIONAL} ${1}"
      SERVICE_NAME=
    else
      CHOSEN_SERVICES="${CHOSEN_SERVICES} ${SERVICE_NAME}"
    fi

    shift
    ;;
  *)
    if [ -n "${1}" ]; then
      POSITIONAL="${POSITIONAL} ${1}"
      shift
    fi
    ;;
  esac
done

if [ -z "${CHOSEN_SERVICES}" ]; then
  CHOSEN_SERVICES=$(ls "${COMPOSE}/services")
fi

. "${COMPOSE}/functions.sh"

for SERVICE_NAME in ${CHOSEN_SERVICES}; do
  if __service_exists "${SERVICE_NAME}"; then
    if __command_exists "${SERVICE_NAME}" "${COMMAND}"; then
      echo "----- Running '${COMMAND}' for ${SERVICE_NAME}"
      __call_command "${SERVICE_NAME}" "${COMMAND}" ${POSITIONAL}
    else
      echo "----- '${SERVICE_NAME}' does not have '${COMMAND}' command."
    fi
  else
    echo "----- '${SERVICE_NAME}' service does not exist."
    exit 1
  fi
done

rm -f .tmp/* 2> /dev/null
