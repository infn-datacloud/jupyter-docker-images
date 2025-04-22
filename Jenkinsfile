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
        
        // Singlenode docker images
        JHUB_IMAGE_NAME =           'jhub-singlenode'
        BASE_JLAB_IMAGE_NAME =      'jlab-base'
        STANDALONE_JLAB_IMAGE_NAME ='jlab-standalone'
        AIINFN_JLAB_IMAGE_NAME =    'jlab-ai-infn'

        // Naas docker images
        NAAS_JHUB_IMAGE_NAME =      'jhub-naas'
        NAAS_JLAB_IMAGE_NAME =      'jlab-naas'

        // Version
        TAG_NAME =                  'v2.0.0-j4.1.0'
        AI_INFN_TAG_NAME =          'ai1.3'
        RELEASE_VERSION = getReleaseVersion(TAG_NAME)
        SANITIZED_BRANCH_NAME = env.BRANCH_NAME.replace('/', '_')
    }
    
    stages {
        stage('Build and Push JupyterHub Image') {
            environment {
                IMAGE_NAME = "${REGISTRY_FQDN}/${REPO_NAME}/${JHUB_IMAGE_NAME}:${env.RELEASE_VERSION}"
                DOCKERFILE_PATH = "docker/singlenode/jhub"
                DOCKER_BUILD_OPTIONS = "--no-cache -f ${DOCKERFILE_PATH}/Dockerfile ${DOCKERFILE_PATH}"
            }
            steps {
                script {
                    sh "/usr/bin/docker system prune -fa"
                    buildAndPushImage(IMAGE_NAME, DOCKER_BUILD_OPTIONS)
                }
            }
        }
        
        stage('Build and Push Base JupyterLab Image') {
            environment {
                IMAGE_NAME = "${REGISTRY_FQDN}/${REPO_NAME}/${BASE_JLAB_IMAGE_NAME}:${env.RELEASE_VERSION}"
                DOCKERFILE_PATH = "docker/singlenode/jlab-base"
                DOCKER_BUILD_OPTIONS = "--no-cache -f ${DOCKERFILE_PATH}/Dockerfile ${DOCKERFILE_PATH}"
            }
            steps {
                script {
                    sh "/usr/bin/docker system prune -fa"
                    buildAndPushImage(IMAGE_NAME, DOCKER_BUILD_OPTIONS)
                }
            }
        }

        stage('Build and Push Standalone JupyterLab Image') {
            environment {
                IMAGE_NAME = "${REGISTRY_FQDN}/${REPO_NAME}/${STANDALONE_JLAB_IMAGE_NAME}:${env.RELEASE_VERSION}"
                BASE_IMAGE = "${REGISTRY_FQDN}/${REPO_NAME}/${BASE_JLAB_IMAGE_NAME}:${env.RELEASE_VERSION}"
                DOCKERFILE_PATH = "docker/singlenode/jlab-standalone"
                DOCKER_BUILD_OPTIONS = "--build-arg BASE_IMAGE=${BASE_IMAGE} --no-cache -f ${DOCKERFILE_PATH}/Dockerfile ${DOCKERFILE_PATH}"
            }
            steps {
                script {
                    sh "/usr/bin/docker system prune -fa"
                    buildAndPushImage(IMAGE_NAME, DOCKER_BUILD_OPTIONS)
                }
            }
        }

        stage('Build and Push AI-INFN JupyterLab Image') {
            environment {
                IMAGE_NAME = "${REGISTRY_FQDN}/${REPO_NAME}/${AIINFN_JLAB_IMAGE_NAME}:${env.RELEASE_VERSION}-${AI_INFN_TAG_NAME}"
                BASE_IMAGE = "${REGISTRY_FQDN}/${REPO_NAME}/${BASE_JLAB_IMAGE_NAME}:${env.RELEASE_VERSION}"
                DOCKERFILE_PATH = "docker/AI_INFN/jlab"
                DOCKER_BUILD_OPTIONS = "--build-arg BASE_IMAGE=${BASE_IMAGE} --no-cache -f ${DOCKERFILE_PATH}/Dockerfile ${DOCKERFILE_PATH}"
            }
            steps {
                script {
                    sh "/usr/bin/docker system prune -fa"
                    buildAndPushImage(IMAGE_NAME, DOCKER_BUILD_OPTIONS)
                }
            }
        }

        stage('Build and Push NaaS k8s JupyterHub Image') {
            environment {
                IMAGE_NAME = "${REGISTRY_FQDN}/${REPO_NAME}/${NAAS_JHUB_IMAGE_NAME}:${env.RELEASE_VERSION}"
                DOCKERFILE_PATH = "docker/NaaS/jhub"
                DOCKER_BUILD_OPTIONS = "--no-cache -f ${DOCKERFILE_PATH}/Dockerfile ${DOCKERFILE_PATH}"
            }
            steps {
                script {
                    sh "/usr/bin/docker system prune -fa"
                    buildAndPushImage(IMAGE_NAME, DOCKER_BUILD_OPTIONS)
                }
            }
        }
        
        stage('Build and Push NaaS k8s JupyterLab Image') {
            environment {
                IMAGE_NAME = "${REGISTRY_FQDN}/${REPO_NAME}/${NAAS_JLAB_IMAGE_NAME}:${env.RELEASE_VERSION}"
                DOCKERFILE_PATH = "docker/NaaS/jlab"
                DOCKER_BUILD_OPTIONS = "--no-cache -f ${DOCKERFILE_PATH}/Dockerfile ${DOCKERFILE_PATH}"
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
 
