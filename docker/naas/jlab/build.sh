export HARBOR_CREDENTIALS='harbor-paas-credentials'
export REGISTRY_FQDN='harbor.cloud.infn.it'
export REPO_NAME='datacloud-templates'
export STANDALONE_JLAB_IMAGE_NAME='jlab-naas'
export TAG_NAME='2.0.0'
export IMAGE_NAME="${REGISTRY_FQDN}/${REPO_NAME}/${STANDALONE_JLAB_IMAGE_NAME}:${TAG_NAME}"
#export DOCKERFILE_PATH="docker/NaaS/jlab"
export DOCKER_BUILD_OPTIONS="."
docker build -t $IMAGE_NAME $DOCKER_BUILD_OPTIONS
docker push $IMAGE_NAME
