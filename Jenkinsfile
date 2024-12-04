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
        node { label 'jenkinsworker00' }
    }
    
    environment {
        HARBOR_CREDENTIALS =        'harbor-paas-credentials'
        REGISTRY_FQDN =             'harbor.cloud.infn.it'
        REPO_NAME =                 'datacloud-template'
        JHUB_IMAGE_NAME =           'snj-base-jhub'
        BASE_JLAB_IMAGE_NAME =      'snj-base-lab'
        AIINFN_JLAB_IMAGE_NAME =    'jlab-ai-infn'
        TAG_NAME =                  '1.3.0-1'
        
        RELEASE_VERSION = getReleaseVersion(TAG_NAME)
        SANITIZED_BRANCH_NAME = env.BRANCH_NAME.replace('/', '_')
    }
    
    stages {
        stage('Build and Push JupyterHub Image') {
            environment {
                IMAGE_NAME = "${REGISTRY_FQDN}/${REPO_NAME}/${JHUB_IMAGE_NAME}:${env.RELEASE_VERSION}"
                DOCKER_BUILD_OPTIONS = "--no-cache -f docker/single-node-jupyterhub/jupyterhub/Dockerfile docker/single-node-jupyterhub/jupyterhub"
            }
            steps {
                script {
                    sh "/usr/bin/docker system prune -fa"
                    buildAndPushImage(IMAGE_NAME, DOCKER_BUILD_OPTIONS)
                    sh "docker image rm ${IMAGE_NAME}"
                }
            }
        }
        
        stage('Build and Push Base JupyterLab Image') {
            environment {
                IMAGE_NAME = "${REGISTRY_FQDN}/${REPO_NAME}/${BASE_JLAB_IMAGE_NAME}:${env.RELEASE_VERSION}"
                DOCKER_BUILD_OPTIONS = "--no-cache -f docker/single-node-jupyterhub/jupyterlab/Dockerfile docker/single-node-jupyterhub/jupyterlab"
            }
            steps {
                script {
                    sh "/usr/bin/docker system prune -fa"
                    buildAndPushImage(IMAGE_NAME, DOCKER_BUILD_OPTIONS)
                    sh "docker image rm ${IMAGE_NAME}"
                }
            }
        }

        stage('Build and Push AI-INFN JupyterLab Image') {
            environment {
                IMAGE_NAME = "${REGISTRY_FQDN}/${REPO_NAME}/${AIINFN_JLAB_IMAGE_NAME}:${env.RELEASE_VERSION}"
                BASE_IMAGE = "${REGISTRY_FQDN}/${REPO_NAME}/${BASE_JLAB_IMAGE_NAME}:${env.RELEASE_VERSION}"
                DOCKER_BUILD_OPTIONS = "--build-arg BASE_IMAGE=${BASE_IMAGE} --no-cache -f docker/single-node-jupyterhub/jupyterlab_ai-infn/Dockerfile docker/single-node-jupyterhub/jupyterlab_ai-infn"
            }
            steps {
                script {
                    sh "/usr/bin/docker system prune -fa"
                    buildAndPushImage(IMAGE_NAME, DOCKER_BUILD_OPTIONS)
                    sh "docker image rm ${IMAGE_NAME}"
                }
            }
        }
    }
    
    post {
        success { echo 'Docker image build and push successful!' }
        failure { echo 'Docker image build and push failed!' }
    }
}
 