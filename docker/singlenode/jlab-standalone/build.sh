export HARBOR_CREDENTIALS='harbor-paas-credentials'
export REGISTRY_FQDN='harbor.cloud.infn.it'
export REPO_NAME='datacloud-templates'
export BASE_JLAB_IMAGE_NAME='snj-base-lab'
export STANDALONE_JLAB_IMAGE_NAME='jlab-standalone'
export TAG_NAME='1.3.0-1'
export IMAGE_NAME="${REGISTRY_FQDN}/${REPO_NAME}/${STANDALONE_JLAB_IMAGE_NAME}:${TAG_NAME}"
export BASE_IMAGE="${REGISTRY_FQDN}/${REPO_NAME}/${BASE_JLAB_IMAGE_NAME}:${TAG_NAME}"
export DOCKERFILE_PATH="docker/single-node-jupyterhub/jupyterlab_standalone"
export DOCKER_BUILD_OPTIONS="--build-arg BASE_IMAGE=${BASE_IMAGE} ."
docker build -t $IMAGE_NAME $DOCKER_BUILD_OPTIONS
docker push $IMAGE_NAME


# IMAGE_NAME: harbor.cloud.infn.it/datacloud-templates/jlab-standalone:1.3.0-1
# jupyterhub/k8s-singleuser-sample:4.1.0 3.2.1

# jupyterhub/k8s-singleuser-sample:3.3.7

# quay.io/jupyter/minimal-notebook:ubuntu-22.04



# jugotE21rrYaUtW4dLzm

# harbor.cloud.infn.it/library/jaas_user_containers:base