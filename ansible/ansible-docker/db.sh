#!/bin/bash
# Docker buildcycle script
# Build and automate cleanup - good to use on a dev box where this is the
# only project you are workingo on.

REPO_AND_IMAGE='org.pm/debian-ansible:1.0'
CONTAINER_NAME='ansible'


#stop any running containers
sudo docker ps | grep $CONTAINER_NAME | awk '{print $1}' | xargs sudo docker stop

# remove any existing stopped containers
sudo docker ps -a | grep $CONTAINER_NAME | awk '{print $1}' | xargs sudo docker rm

# remove built image for rebuild
# ßdocker rmi $(docker images | grep -v $REPO_AND_IMAGE | awk {'print $3'})

# remove any images that are left around
# docker rmi $(docker images -f dangling=true -q)

# build the image, removing intermediate layers, deleting cache
# docker build --rm --no-cache -t "$REPO_AND_IMAGE" .
sudo docker build \
    --rm \
    -t "$REPO_AND_IMAGE" .

if [ $? -eq 0 ]; then
  # run the newly built image
  #docker run --name $CONTAINER_NAME -p 25565:25565 -l $CONTAINER_NAME $REPO_AND_IMAGE

  # My kernel information
  # Linux 64cd1417ea3a 4.4.27-boot2docker #1 SMP Tue Oct 25 19:51:49 UTC 2016 x86_64 Linux

  # run in inteactive for debugging / development
  sudo docker run \
        --name $CONTAINER_NAME \
        -v ${pwd}:/root/ansible \
	-l $CONTAINER_NAME \
        -it \
	--rm \
        --entrypoint="/bin/sh" \
        $REPO_AND_IMAGE

  # follow stdout
  #docker logs -f $CONTAINER_NAME
else
  echo "Failed to build"
fi
