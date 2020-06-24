#!/usr/bin/env bash

set -e

# default - vars
DATE="$(date +%Y%m%d)"
STAGE="dev"
[ -z "${BUILD}" ] && BUILD=""

# build
for app in gvmlibs openvas gsa ; do
  docker build -f ./Dockerfile-${app} --build-arg STAGE=${STAGE} \
    -t "securecompliancesolutions/${app}:dev-${DATE}${BUILD}" .
done

# build gvmd
[ -z "${DATABASE}" ] && DATABASE="sqlite"
[ "${DATABASE}" == "sqlite" ] && DATABASE_TAG="" || DATABASE_TAG="-${DATABASE}"
docker build -f ./Dockerfile-gvmd --build-arg STAGE=${STAGE} --build-arg DATABASE=${DATABASE} \
  -t "securecompliancesolutions/gvmd:dev-${DATE}${DATABASE_TAG}${BUILD}" .

# push
if [ "${1}" == "push" ]; then
  for app in gvmlibs openvas gsa ; do
    for tag in "dev-${DATE}${BUILD}"; do
      docker push "securecompliancesolutions/${app}:${tag}"
    done
  done

  # push gvmd
  for tag in "dev-${DATE}${DATABASE_TAG}${BUILD}"; do
    docker push "securecompliancesolutions/gvmd:${tag}"
  done
fi

