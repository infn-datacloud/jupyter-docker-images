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
        node { label 'jenkins-node-label-1' }
    }
    
    environment {
        // Harbor section
        HARBOR_CREDENTIALS =         'harbor-paas-credentials'
        REGISTRY_FQDN =              'harbor.cloud.infn.it'
        REPO_NAME =                  'datacloud-jupyter'
        
        // General section
        TAG_NAME =                   '2.1.1'

        // Singlenode section
        JHUB_IMAGE_NAME =            'jhub-singlenode'
        BASE_JLAB_IMAGE_NAME =       'jlab-base'
        STANDALONE_JLAB_IMAGE_NAME = 'jlab-standalone'
        SN_JHUB_PATH =               'docker/singlenode/jhub'
        SN_JLAB_BASE_PATH =          'docker/singlenode/jlab-base'
        SN_JLAB_STANDALONE_PATH =    'docker/singlenode/jlab-standalone'

        // AI_INFN section
        AI_INFN_REPO_NAME =          'unpacked' 
        AI_INFN_TAG_NAME =           'ai1.5'
        AI_INFN_JLAB_IMAGE_NAME =    'jlab-ai-infn'
        AI_INFN_JLAB_PATH =          'docker/ai_infn/jlab'

        // Naas section
        NAAS_JHUB_IMAGE_NAME =       'jhub-naas'
        NAAS_JLAB_IMAGE_NAME =       'jlab-naas'
        NAAS_JHUB_PATH =             'docker/naas/jhub'
        NAAS_JLAB_PATH =             'docker/naas/jlab'

        // Spark section
        SPARK_TAG_NAME =             's2.0'
        SPARK_JHUB_IMAGE_NAME =      'jhub-spark'
        SPARK_JLAB_IMAGE_NAME =      'jlab-spark'
        SPARK_JHUB_PATH =            'docker/spark/jhub'
        SPARK_JLAB_PATH =            'docker/spark/jlab'

        // Release section
        RELEASE_VERSION =            getReleaseVersion(TAG_NAME)
        // SANITIZED_BRANCH_NAME = env.BRANCH_NAME.replace('/', '_')
    }
    
    stages {
        // stage('Build and Push SingleNode JupyterHub Image') {
        //     environment {
        //         IMAGE_NAME = "${REGISTRY_FQDN}/${REPO_NAME}/${JHUB_IMAGE_NAME}:${RELEASE_VERSION}"
        //         DOCKER_BUILD_OPTIONS = "--no-cache -f ${SN_JHUB_PATH}/Dockerfile ${SN_JHUB_PATH}"
        //     }
        //     steps {
        //         script {
        //             sh "/usr/bin/docker system prune -fa"
        //             buildAndPushImage(IMAGE_NAME, DOCKER_BUILD_OPTIONS)
        //         }
        //     }
        // }
        
        // stage('Build and Push Base JupyterLab Image') {
        //     environment {
        //         IMAGE_NAME = "${REGISTRY_FQDN}/${REPO_NAME}/${BASE_JLAB_IMAGE_NAME}:${RELEASE_VERSION}"
        //         DOCKER_BUILD_OPTIONS = "--no-cache -f ${SN_JLAB_BASE_PATH}/Dockerfile ${SN_JLAB_BASE_PATH}"
        //     }
        //     steps {
        //         script {
        //             sh "/usr/bin/docker system prune -fa"
        //             buildAndPushImage(IMAGE_NAME, DOCKER_BUILD_OPTIONS)
        //         }
        //     }
        // }

        // stage('Build and Push Standalone JupyterLab Image') {
        //     environment {
        //         IMAGE_NAME = "${REGISTRY_FQDN}/${REPO_NAME}/${STANDALONE_JLAB_IMAGE_NAME}:${RELEASE_VERSION}"
        //         BASE_IMAGE = "${REGISTRY_FQDN}/${REPO_NAME}/${BASE_JLAB_IMAGE_NAME}:${RELEASE_VERSION}"
        //         DOCKER_BUILD_OPTIONS = "--build-arg BASE_IMAGE=${BASE_IMAGE} --no-cache -f ${SN_JLAB_STANDALONE_PATH}/Dockerfile ${SN_JLAB_STANDALONE_PATH}"
        //     }
        //     steps {
        //         script {
        //             sh "/usr/bin/docker system prune -fa"
        //             buildAndPushImage(IMAGE_NAME, DOCKER_BUILD_OPTIONS)
        //         }
        //     }
        // }

        // stage('Build and Push AI_INFN JupyterLab Image') {
        //     environment {
        //         IMAGE_NAME = "${REGISTRY_FQDN}/${AI_INFN_REPO_NAME}/${AI_INFN_JLAB_IMAGE_NAME}:${RELEASE_VERSION}-${AI_INFN_TAG_NAME}"
        //         BASE_IMAGE = "${REGISTRY_FQDN}/${REPO_NAME}/${BASE_JLAB_IMAGE_NAME}:${RELEASE_VERSION}"
        //         DOCKER_BUILD_OPTIONS = "--build-arg BASE_IMAGE=${BASE_IMAGE} --no-cache -f ${AI_INFN_JLAB_PATH}/Dockerfile ${AI_INFN_JLAB_PATH}"
        //     }
        //     steps {
        //         script {
        //             sh "/usr/bin/docker system prune -fa"
        //             buildAndPushImage(IMAGE_NAME, DOCKER_BUILD_OPTIONS)
        //         }
        //     }
        // }

        // stage('Build and Push Spark JupyterHub Image') {
        //     environment {
        //         IMAGE_NAME = "${REGISTRY_FQDN}/${REPO_NAME}/${SPARK_JHUB_IMAGE_NAME}:${RELEASE_VERSION}-${SPARK_TAG_NAME}"
        //         DOCKER_BUILD_OPTIONS = "--no-cache -f ${SPARK_JHUB_PATH}/Dockerfile ${SPARK_JHUB_PATH}"
        //     }
        //     steps {
        //         script {
        //             sh "/usr/bin/docker system prune -fa"
        //             buildAndPushImage(IMAGE_NAME, DOCKER_BUILD_OPTIONS)
        //         }
        //     }
        // }

        // stage('Build and Push Spark JupyterLab Image') {
        //     environment {
        //         IMAGE_NAME = "${REGISTRY_FQDN}/${REPO_NAME}/${SPARK_JLAB_IMAGE_NAME}:${RELEASE_VERSION}-${SPARK_TAG_NAME}"
        //         DOCKER_BUILD_OPTIONS = "--no-cache -f ${SPARK_JLAB_PATH}/Dockerfile ${SPARK_JLAB_PATH}"
        //     }
        //     steps {
        //         script {
        //             sh "/usr/bin/docker system prune -fa"
        //             buildAndPushImage(IMAGE_NAME, DOCKER_BUILD_OPTIONS)
        //         }
        //     }
        // } 

        stage('Build and Push Naas JupyterLab Image') {
            environment {
                IMAGE_NAME = "${REGISTRY_FQDN}/${REPO_NAME}/${NAAS_JLAB_IMAGE_NAME}:${RELEASE_VERSION}"
                DOCKER_BUILD_OPTIONS = "--no-cache -f ${NAAS_JLAB_PATH}/Dockerfile ${NAAS_JLAB_PATH}"
            }
            steps {
                script {
                    sh "/usr/bin/docker system prune -fa"
                    buildAndPushImage(IMAGE_NAME, DOCKER_BUILD_OPTIONS)
                }
            }
        }

        stage('Build and Push Naas JupyterHub Image') {
            environment {
                IMAGE_NAME = "${REGISTRY_FQDN}/${REPO_NAME}/${NAAS_JHUB_IMAGE_NAME}:${RELEASE_VERSION}"
                DOCKER_BUILD_OPTIONS = "--no-cache -f ${NAAS_JHUB_PATH}/Dockerfile ${NAAS_JHUB_PATH}"
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
 