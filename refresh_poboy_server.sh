#!/usr/bin/env bash

# refresh_pobpy_server.sh
#
# Script to refresh poboy's conda repository server post code update to the git repo.
# Following actions are performed.
# > If poboy's server is running as a docker container, stop the container.
# > Remove any poboy server docker images (if any) post the container shutdown.
# > If --refreshbase is provided then base docker image is also refreshed.
# > Pull latest codebase from Git Repository
# > Build a new poboy server docker image (if refreshbase is passed then first base image will be built)
# > Start container with the new built image, ensuring the repo directory is mapped correctly.

SCRIPT_NAME=$(basename $0)
CONTAINER_NAME="poboys_conda_server"
IMAGE_NAME="poboys_conda_package_server"
BASE_IMAGE_NAME="poboys_base_image"
REFRESH_BASE=false

usage() {
cat << USAGE
Usage: refresh_poboys_server.sh [-h] [--refreshbase]

A script to refresh poboy's conda repository server to the latest code in the git repository.

Options:
    -h                  Show this usage message
    --refreshbase       Optional. Refresh base docker image of poboy's server.

USAGE
}

log() {
    # log message to stdout
    echo "[${SCRIPT_NAME}]: $1"
}

error() {
    # Write message($1) to stderr and exit
    # If exit_code($2) is passed then exit with that code, else default exit code is 1
    echo "[${SCRIPT_NAME}]: $1" > /dev/stderr
    [[ $# -gt 1 ]] && exit $2
    exit 1
}

get_options() {
    while [[ "$1" != "" ]]; do
        case "$1" in
            --refreshbase )
                shift
                REFRESH_BASE=true
                ;;
             -h | --help )
                usage
                exit 0
                ;;
           * )
                usage
                error "Incorrect parameters passed"
        esac
        shift
    done
}

check_stop_container() {
    container_id=$(docker ps -a --format "{{.Names}},{{.ID}}" | grep "${CONTAINER_NAME}" | cut -d "," -f 2)
    if [[ -n "${container_id}" ]] ; then
        docker container stop "${container_id}" > /dev/null && \
        log "Container ${container_id} stopped." && \
        docker container rm "${container_id}" > /dev/null && \
        log "Container ${container_id} removed."
    fi
}

remove_container_image() {
    image_id=$(docker image ls -a --format "{{.Repository}},{{.ID}}" | grep "${IMAGE_NAME}" | grep -v "docker.h2o.ai" | cut -d "," -f 2)
    if [[ -n "${image_id}" ]]; then
        docker image rm -f "${image_id}"
    fi
}

remove_base_image() {
    image_id=$(docker image ls -a --format "{{.Repository}},{{.ID}}" | grep "${BASE_IMAGE_NAME}" | grep -v "docker.h2o.ai" | cut -d "," -f 2)
    if [[ -n "${image_id}" ]]; then
        docker image rm -f "${image_id}"
    fi
}

git_pull_latest() {
    git pull origin master
}

build_docker_image() {
    docker build -t "${IMAGE_NAME}" --file ./Dockerfile .
}

build_base_image() {
    docker build -t "${BASE_IMAGE_NAME}" --file ./Dockerfile-baseimg .
}

start_poboy_conda_server() {
   docker run -d --name "${CONTAINER_NAME}" \
              -p 6969:6969 \
              -e ANACONDA_USERNAME \
              -e ANACONDA_PASSWORD \
              -e ANACONDA_ORG \
              -e POBOYS_PORT \
              -e POBOYS_S3_BUCKET \
              -e AWS_ACCESS_KEY_ID \
              -e AWS_SECRET_ACCESS_KEY \
              -v $(pwd)/../conda-repo-root:/opt/"${IMAGE_NAME}" \
              "${IMAGE_NAME}"
}

main() {
    get_options $@
    check_stop_container || error "Docker container could not be removed" $?
    remove_container_image || error "Docker image could not be removed" $?
    $REFRESH_BASE && ( remove_base_image && build_base_image || error "Base image could not be refreshed" $? )
    git_pull_latest || error "Unable to pull latest code from git" $?
    build_docker_image || error "Unable to build docker image" $?
    start_poboy_conda_server || error "Unable to start poboy server docker image" $?
}

main $@