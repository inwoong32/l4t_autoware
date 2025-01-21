#!/bin/bash

docker build -t aw:v0 -f docker/Dockerfile .

# docker build -t aw:v0 -f docker/Dockerfile . --build-arg OPENCV_VERSION=4.10.0 .