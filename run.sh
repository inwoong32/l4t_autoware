#!/bin/bash

# xhost +local:docker

IMAGE=$1

XSOCK="/tmp/.X11-unix"

if [ -z "$XAUTHORITY" ]; then
  XAUTHORITY="$HOME/.Xauthority"
fi

SHARED_DOCK_WR_DIR="/autoware"
SHARED_HOST_WR_DIR="$(dirname "$0")/autoware"

echo "=============================="
echo "========== Run $IMAGE"
echo "=============================="

VOLUMES="\
  --volume=$XSOCK:$XSOCK:rw \
  --volume=$XAUTHORITY:$XAUTHORITY:ro \
  --volume=$SHARED_HOST_WR_DIR:$SHARED_DOCK_WR_DIR:rw \
  --volume=/etc/localtime:/etc/localtime:ro \
  --volume=/etc/timezone:/etc/timezone:ro \
  --volume=/media:/media:rw \
"

ENVIRONS="\
  --env DISPLAY=$DISPLAY \
  --env XAUTHORITY=$XAUTHORITY \
  --env NVIDIA_VISIBLE_DEVICES=all \
  --env NVIDIA_DRIVER_CAPABILITIES=all \
"

docker run -it --rm \
  --runtime=nvidia \
  --gpus all \
  $ENVIRONS \
  $VOLUMES \
  --privileged \
  --net=host \
  -w "$SHARED_DOCK_WR_DIR" \
  "$IMAGE"

