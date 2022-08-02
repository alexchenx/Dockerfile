#!/bin/bash
# Description: This script is use for deploy docker image from jenkins.

registry=registry-vpc.cn-beijing.aliyuncs.com
namespace=alexchenx
image=$1
tag=$2
port=$3

if [ $# -ne 3 ]; then
        echo "Need 3 parameters."
        exit 2
fi

image_name=$registry/$namespace/$image:$tag

echo "login to registry ${registry}..."
registry_user=YOUR_USERNAME
registry_pwd=YOUR_PASSWORD
docker login -u $registry_user -p $registry_pwd $registry

echo "pull image ${image_name} ..."
docker pull $image_name

echo "Check container running..."
if [ "$(docker ps -a|grep $image |awk '{print $1}')" != " " ]; then
        echo "delete containers..."
        docker rm -f $(docker ps -a|grep $image |awk '{print $1}')
        echo "delete done."
fi

echo "start container..."
if [ "$image" == "api-voip-web" ]; then
        docker run -d --restart=always --name $image -p $port:$port --network openapi --label aliyun.logs.$image=stdout -v /data/tmp:/data/tmp $image_name
else
        docker run -d --restart=always --name $image -p $port:$port --network openapi --label aliyun.logs.$image=stdout $image_name
fi

echo "delete old images..."
docker rmi -f $(docker images | grep $image | awk -v a=$tag '{if ($2!=a) print}' | awk '{print $3}')

echo "show status..."
docker ps |grep $image