#!/usr/bin/env bash

if [[ -z "${DOCKER_USERNAME}" ]]; then
    echo "No Docker credentials, no reason to do container"
    exit 0
fi

if [ "$TRAVIS_NODE_VERSION" != "lts/*" ]; then
    echo "Only deploy on production node build"
    exit 0
fi

docker build -t kerrokantasi-ui .

export REPO="helsinki/kerrokantasi-ui"

# First 7 chars of commit hash
export COMMIT=${TRAVIS_COMMIT::7}

# Escape slashes in branch names
export BRANCH=${TRAVIS_BRANCH//\//_}

if [ "$TRAVIS_PULL_REQUEST" != false ]; then
    echo "Tagging pull request" "$TRAVIS_PULL_REQUEST"
    export BASE="$REPO:pr-$TRAVIS_PULL_REQUEST"
    docker tag kerrokantasi-ui "$BASE"
    docker tag "$BASE" "$REPO-$TRAVIS_BUILD_NUMBER"
    docker push "$BASE"
    docker push "$REPO:travis-$TRAVIS_BUILD_NUMBER"
    exit 0
fi

if [ "$TRAVIS_BRANCH" == "master" ] ; then
    echo "Tagging master"
    docker tag kerrokantasi-ui "$REPO:$COMMIT"
    docker tag "$REPO:$COMMIT" $REPO:latest
    docker tag "$REPO:$COMMIT" "$REPO:travis-$TRAVIS_BUILD_NUMBER"
    docker push "$REPO:$COMMIT"
    docker push "$REPO:latest"
    docker push "$REPO:travis-$TRAVIS_BUILD_NUMBER"
    exit 0
fi

if [ "$TRAVIS_BRANCH" != "master" ] ; then
    echo "Tagging branch " "$TRAVIS_BRANCH"
    docker tag kerrokantasi-ui "$REPO:$COMMIT"
    docker tag "$REPO:$COMMIT" "$REPO:$BRANCH"
    docker tag "$REPO:$COMMIT" "$REPO:travis-$TRAVIS_BUILD_NUMBER"
    docker push "$REPO:$COMMIT"
    docker push "$REPO:travis-$TRAVIS_BUILD_NUMBER"
    docker push "$REPO:$BRANCH"
    exit 0
fi

