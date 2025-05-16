export HARBOR_CREDENTIALS='harbor-paas-credentials'
export REGISTRY_FQDN='harbor.cloud.infn.it'
export REPO_NAME='datacloud-templates'
export BASE_JLAB_IMAGE_NAME='snj-base-lab'
export STANDALONE_JLAB_IMAGE_NAME='jlab-standalone'
export TAG_NAME='2.0.0'
export IMAGE_NAME="${REGISTRY_FQDN}/${REPO_NAME}/${STANDALONE_JLAB_IMAGE_NAME}:${TAG_NAME}"
export BASE_IMAGE="${REGISTRY_FQDN}/${REPO_NAME}/${BASE_JLAB_IMAGE_NAME}:${TAG_NAME}"
export DOCKERFILE_PATH="docker/single-node-jupyterhub/jupyterlab_standalone"
export DOCKER_BUILD_OPTIONS="--build-arg BASE_IMAGE=${BASE_IMAGE} ."
docker build -t $IMAGE_NAME $DOCKER_BUILD_OPTIONS
docker push $IMAGE_NAME