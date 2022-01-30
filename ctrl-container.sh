#!/bin/bash
# コンテナ制御スクリプト
IMAGE_NAME=ubuntu20.04-python3
TAG=latest
DOMAIN=112233445566.dkr.ecr.ap-northeast-1.amazonaws.com
URL_REPO=${DOMAIN}/${IMAGE_NAME}

# コンテナのビルド
build() {
  docker build -t ${IMAGE_NAME} .
}

# コンテナをECRにプッシュ
push() {
  # 1. login
  aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin ${DOMAIN}

  # 2. tagging
  echo docker tag ${IMAGE_NAME}:${TAG} ${URL_REPO}:${TAG}
  docker tag ${IMAGE_NAME}:${TAG} ${URL_REPO}:${TAG}

  # 3. register to ECR
  echo docker push ${URL_REPO}:${TAG}
  docker push ${URL_REPO}:${TAG}
}

# ECS task の登録のドライラン
register_ecs_task_dryrun() {
  aws ecs register-task-definition --family fargate-efs-mount-test --cli-input-json file://ecs-task.json
}
# ECS task の登録
register_ecs_task() {
  aws ecs register-task-definition --cli-input-json file://ecs-task.json
}

# コンテナの停止
stop() {
  echo "--- stopping container  ---"
  container_id=`docker ps -a |grep ${IMAGE_NAME}|cut -d" " -f1`
  echo $container_id
  if [ "${container_id}" != "" ]; then
    docker stop ${container_id}
  fi
  echo ""
}

# コンテナの起動
start() {
  echo "--- starting container  ---"
  container_id=`docker ps -a |grep ${IMAGE_NAME}|cut -d" " -f1`
  if [ "${container_id}" != "" ]; then
    docker rm -f ${container_id}
  fi

  image_id=`docker images|grep ^${IMAGE_NAME}| sed -e 's/  */ /g'|cut -d" " -f3`
  #echo docker run -d --env-file env.txt --name ${IMAGE_NAME} ${image_id}
  echo docker run --env-file env.txt --name ${IMAGE_NAME} -itd ${image_id}
  docker run --env-file env.txt --name ${IMAGE_NAME} -itd ${image_id}
  echo ""
  docker logs ${IMAGE_NAME}
}

# コンテナの状態確認
status() {
  echo "--- check container status  ---"
  docker ps
  echo ""
}

# コンテナの中に入る
login() {
  echo "--- start container  ---"
  container_id=`docker ps -a | grep "${IMAGE_NAME}"|grep -v "CONTAINER" |cut -d" " -f1`
  echo "container_id:${container_id}"
  if [ "${container_id}" != "" ]; then
    docker exec -it ${container_id} bash
  else
    echo "container not found."
  fi
}

case $1 in
start)
  stop
  start
  status
  ;;
stop)
  stop
  status
  ;;
status)
  status
  ;;
restart)
  stop
  start
  status
  ;;
build)
  build
  ;;
push)
  push
  ;;
ecs_dryrun)
  register_ecs_task_dryrun
  ;;
ecs)
  register_ecs_task
  ;;
login)
  login
  ;;
*)
  echo "Usage: $SERVICE [start|stop|restart|status|build|push|ecs_dryrun|ecs|login]"
  ;;
esac
exit 0
