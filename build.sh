#!/usr/bin/env bash

set -exuo pipefail

TAG=${1:-latest}

docker build --no-cache -t drewboswell/bitcoind:${TAG} .

