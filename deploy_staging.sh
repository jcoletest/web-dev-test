set -e
CLUSTER="webdevcluster"
BUILD="$CIRCLE_SHA1"
REGISTERYREPO="ecs-webserver"
SERVICE="webserver"
TASK_DEFINITION="webserver"

IMAGE="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$REGISTERYREPO:$CIRCLE_SHA1"

function create_build () {
  echo "creating prod build"
  yarn build
}

function push_to_registry () {

  echo "pushing to registry"

  # Build down new version of image
  docker build --rm=false -t $IMAGE .

  eval $(aws ecr get-login --region $AWS_DEFAULT_REGION)

  docker push $IMAGE
}

function update_web_service () {

  echo "updating web service"

  # create updated task
  node ./create-updated-task.js

  aws ecs register-task-definition \
    --cli-input-json file://updated-task.json

  aws ecs update-service --cluster $CLUSTER --service $SERVICE \
    --task-definition $TASK_DEFINITION

  # remove temp file
  rm -rf ./updated-task.json
}

function update_ecs () {
  create_build
  push_to_registry
  update_web_service
}

update_ecs
