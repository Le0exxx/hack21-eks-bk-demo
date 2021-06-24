#!/usr/bin/env bash
set -euo pipefail

trap "remove_config" EXIT

remove_config () {
  config=$(./jfrog config show)

  if [[ $config == *"publish-image"* ]]; then
    echo "remove our config"
    ./jfrog config remove publish-image --quiet
  fi
}

if [ ! -f ./jfrog ]; then
    echo "Downloading jfrog cli"
    bash -c "`curl -fL https://getcli.jfrog.io || exit 1`" 

    ls -lah
fi

echo "Attempting to log onto ${ARTIFACTORY_URL}"

./jfrog config add publish-image \
    --interactive=false \
    --access-token ${ARTIFACTORY_ACCESS_TOKEN} \
    --artifactory-url ${ARTIFACTORY_URL}

echo "Publishing ${IMAGE_TAG} to ${DEFAULT_DOCKER_REPO}"
docker tag ${IMAGE_TAG} ${DEFAULT_DOCKER_REPO}/${IMAGE_TAG}

echo Pushing ${DEFAULT_DOCKER_REPO}/${IMAGE_TAG}
./jfrog rt docker-push ${DEFAULT_DOCKER_REPO}/${IMAGE_TAG} local-iress-docker --build-name="${BUILDKITE_PIPELINE_SLUG}" --build-number=${BUILDKITE_BUILD_NUMBER}

echo Pushing ${DEFAULT_DOCKER_REPO}/${IMAGE_TAG} build information
./jfrog rt build-publish "${BUILDKITE_PIPELINE_SLUG}" ${BUILDKITE_BUILD_NUMBER}

echo "Cleaning up"
docker rmi ${IMAGE_TAG} -f || true
docker rmi ${DEFAULT_DOCKER_REPO}/${IMAGE_TAG} -f || true
