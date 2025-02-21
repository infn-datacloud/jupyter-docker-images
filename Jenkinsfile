def buildAndPushImage(String imageName, String dockerBuildOptions) {
    docker.withRegistry('https://harbor.cloud.infn.it', HARBOR_CREDENTIALS) {
    def dockerImage = docker.build(imageName, dockerBuildOptions)
    dockerImage.push()
    }
}
 
def getReleaseVersion(String tagName) {
    if (tagName) {
        return tagName.replaceAll(/^v/, '')
    } else {
        return null
    }
}
 
pipeline {
 
    agent {
        node { label 'jenkinsworker05' }
    }
    
    environment {
        HARBOR_CREDENTIALS =        'harbor-paas-credentials'
        REGISTRY_FQDN =             'harbor.cloud.infn.it'
        REPO_NAME =                 'datacloud-templates'
        JHUB_IMAGE_NAME =           'snj-base-jhub'
        K8S_JHUB_IMAGE_NAME =       'jhub-k8s'
        BASE_JLAB_IMAGE_NAME =      'snj-base-lab'
        AIINFN_JLAB_IMAGE_NAME =    'jlab-ai-infn'
        STANDALONE_JLAB_IMAGE_NAME ='jlab-standalone'
        TAG_NAME =                  '1.3.0-1'
        AI_INFN_TAG_NAME =          'v1.3'
        
        RELEASE_VERSION = getReleaseVersion(TAG_NAME)
        SANITIZED_BRANCH_NAME = env.BRANCH_NAME.replace('/', '_')
    }
    
    stages {
        stage('Build and Push JupyterHub Image') {
            environment {
                IMAGE_NAME = "${REGISTRY_FQDN}/${REPO_NAME}/${JHUB_IMAGE_NAME}:${env.RELEASE_VERSION}"
                DOCKERFILE_PATH = "docker/single-node-jupyterhub/jupyterhub"
                DOCKER_BUILD_OPTIONS = "--no-cache -f ${DOCKERFILE_PATH}/Dockerfile ${DOCKERFILE_PATH}"
            }
            steps {
                script {
                    sh "/usr/bin/docker system prune -fa"
                    buildAndPushImage(IMAGE_NAME, DOCKER_BUILD_OPTIONS)
                }
            }
        }
        
        // stage('Build and Push JupyterHub k8s Image') {
        //     environment {
        //         IMAGE_NAME = "${REGISTRY_FQDN}/${REPO_NAME}/${K8S_JHUB_IMAGE_NAME}:${env.RELEASE_VERSION}"
        //         DOCKERFILE_PATH = "docker/single-node-jupyterhub/jupyterhub-k8s"
        //         DOCKER_BUILD_OPTIONS = "--no-cache -f ${DOCKERFILE_PATH}/Dockerfile ${DOCKERFILE_PATH}"
        //     }
        //     steps {
        //         script {
        //             sh "/usr/bin/docker system prune -fa"
        //             buildAndPushImage(IMAGE_NAME, DOCKER_BUILD_OPTIONS)
        //         }
        //     }
        // }

        stage('Build and Push Base JupyterLab Image') {
            environment {
                IMAGE_NAME = "${REGISTRY_FQDN}/${REPO_NAME}/${BASE_JLAB_IMAGE_NAME}:${env.RELEASE_VERSION}"
                DOCKERFILE_PATH = "docker/single-node-jupyterhub/jupyterlab"
                DOCKER_BUILD_OPTIONS = "--no-cache -f ${DOCKERFILE_PATH}/Dockerfile ${DOCKERFILE_PATH}"
            }
            steps {
                script {
                    sh "/usr/bin/docker system prune -fa"
                    buildAndPushImage(IMAGE_NAME, DOCKER_BUILD_OPTIONS)
                }
            }
        }

        // stage('Build and Push Stand-Alone JupyterLab Image') {
        //     environment {
        //         IMAGE_NAME = "${REGISTRY_FQDN}/${REPO_NAME}/${STANDALONE_JLAB_IMAGE_NAME}:${env.RELEASE_VERSION}"
        //         BASE_IMAGE = "${REGISTRY_FQDN}/${REPO_NAME}/${BASE_JLAB_IMAGE_NAME}:${env.RELEASE_VERSION}"
        //         DOCKERFILE_PATH = "docker/single-node-jupyterhub/jupyterlab_standalone"
        //         DOCKER_BUILD_OPTIONS = "--build-arg BASE_IMAGE=${BASE_IMAGE} --no-cache -f ${DOCKERFILE_PATH}/Dockerfile ${DOCKERFILE_PATH}"
        //     }
        //     steps {
        //         script {
        //             sh "/usr/bin/docker system prune -fa"
        //             buildAndPushImage(IMAGE_NAME, DOCKER_BUILD_OPTIONS)
        //         }
        //     }
        // }

        stage('Build and Push AI-INFN JupyterLab Image') {
            environment {
                IMAGE_NAME = "${REGISTRY_FQDN}/${REPO_NAME}/${AIINFN_JLAB_IMAGE_NAME}:${env.RELEASE_VERSION}-${AI_INFN_TAG_NAME}"
                BASE_IMAGE = "${REGISTRY_FQDN}/${REPO_NAME}/${BASE_JLAB_IMAGE_NAME}:${env.RELEASE_VERSION}"
                DOCKERFILE_PATH = "docker/single-node-jupyterhub/jupyterlab_ai-infn"
                DOCKER_BUILD_OPTIONS = "--build-arg BASE_IMAGE=${BASE_IMAGE} --no-cache -f ${DOCKERFILE_PATH}/Dockerfile ${DOCKERFILE_PATH}"
            }
            steps {
                script {
                    sh "/usr/bin/docker system prune -fa"
                    buildAndPushImage(IMAGE_NAME, DOCKER_BUILD_OPTIONS)
                }
            }
        }
    }
    
    post {
        success { echo 'Docker image build and push successful!' }
        failure { echo 'Docker image build and push failed!' }
    }
}
 
